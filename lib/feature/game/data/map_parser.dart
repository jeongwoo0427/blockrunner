import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/core/error/failure_code.dart';
import 'package:blockrunner/feature/game/data/map_blueprints.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/entity/game_map.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';

/// ASCII 원본을 도메인 [GameMap] 으로 바꾸고, 그 자리에서 유효성을 검증한다.
///
/// 잘못된 맵은 배포 전에 터져야 한다. 조용히 넘어가면 플레이어가 클리어할 수
/// 없는 레벨을 만나게 되고, 그때는 원인을 찾기가 훨씬 어렵다.
class MapParser {
  const MapParser();

  /// 위반 시 [FailureCode.invalidMapData] 를 담은 [ClientFailure] 를 throw 한다.
  GameMap parse(MapBlueprint blueprint) {
    final rows = blueprint.rows;
    if (rows.isEmpty) {
      throw _invalid(blueprint, '행이 하나도 없다');
    }

    final colCount = rows.first.length;
    if (colCount == 0) {
      throw _invalid(blueprint, '첫 행이 비어 있다');
    }
    for (var row = 0; row < rows.length; row++) {
      if (rows[row].length != colCount) {
        throw _invalid(
          blueprint,
          '$row행의 길이가 ${rows[row].length} 로 첫 행($colCount)과 다르다',
        );
      }
    }

    final floors = <List<FloorType>>[];
    final blocks = <Block>[];
    final goals = <Position>[];
    var nextId = 0;

    for (var row = 0; row < rows.length; row++) {
      final floorRow = <FloorType>[];

      for (var col = 0; col < colCount; col++) {
        final symbol = rows[row][col];
        final position = Position(row, col);

        switch (symbol) {
          case '.':
            floorRow.add(FloorType.empty);
          case '#':
            floorRow.add(FloorType.wall);
          case 'G':
            floorRow.add(FloorType.goal);
            goals.add(position);
          case 'X':
            floorRow.add(FloorType.hole);
          case 'O':
            floorRow.add(FloorType.empty);
            blocks.add(
              Block(id: nextId++, type: BlockType.normal, position: position),
            );
          case '@':
            floorRow.add(FloorType.empty);
            blocks.add(
              Block(id: nextId++, type: BlockType.player, position: position),
            );
          default:
            throw _invalid(blueprint, '알 수 없는 기호 "$symbol" ($row행 $col열)');
        }
      }
      floors.add(floorRow);
    }

    final playerCount = blocks.where((block) => block.isPlayer).length;
    if (playerCount != 1) {
      throw _invalid(blueprint, '플레이어는 정확히 1개여야 하는데 $playerCount 개다');
    }
    if (goals.isEmpty) {
      throw _invalid(blueprint, '목표 지점이 없다');
    }

    final board = BoardState(
      rowCount: rows.length,
      colCount: colCount,
      floors: floors,
      blocks: blocks,
    );

    for (final goal in goals) {
      if (!_hasStopper(board, goal)) {
        throw _invalid(
          blueprint,
          '목표 $goal 의 네 방향 어디에도 정지 요소(벽·맵 경계)가 없어 멈출 수 없다',
        );
      }
    }

    return GameMap(levelNumber: blueprint.levelNumber, initialBoard: board);
  }

  /// 목표 칸에 멈추려면 그 뒤에 정지 요소가 있어야 한다(기획서 §4.3 레벨 디자인 원칙).
  ///
  /// 일반 블록은 함께 미끄러지므로 정지 요소로 세지 않는다. 블록을 브레이크로 쓰는
  /// 맵도 이 검사는 통과해야 하며, 실제 풀이 가능 여부는 `test/` 의 완전 탐색이 본다.
  bool _hasStopper(BoardState board, Position goal) => Direction.values.any(
    (direction) => board.floorAt(goal.translate(direction)) == FloorType.wall,
  );

  ClientFailure _invalid(MapBlueprint blueprint, String reason) =>
      ClientFailure(
        code: FailureCode.invalidMapData,
        stackTrace: StackTrace.current,
        debugMessage: '레벨 ${blueprint.levelNumber} 맵: $reason',
      );
}
