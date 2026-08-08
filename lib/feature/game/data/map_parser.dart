import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/core/error/failure_code.dart';
import 'package:blockrunner/feature/game/data/map_blueprints.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/entity/game_map.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/domain/entity/wall_edge.dart';

/// ASCII 격자를 도메인 [GameMap] 으로 바꾸고, 그 자리에서 유효성을 검증한다.
///
/// 표기는 기획서 §9.1 — 칸과 경계를 번갈아 적는 `2N+1` 격자다.
/// 경계 벽은 칸이 아니라 칸 **사이**에 있으므로 칸만 나열해서는 적을 수 없다.
///
/// 잘못된 맵은 배포 전에 터져야 한다. 조용히 넘어가면 플레이어가 클리어할 수
/// 없는 레벨을 만나게 되고, 그때는 원인을 찾기가 훨씬 어렵다.
class MapParser {
  const MapParser();

  static const String _corner = '+';
  static const String _horizontalWall = '-';
  static const String _verticalWall = '|';
  static const String _noWall = ' ';

  /// 위반 시 [FailureCode.invalidMapData] 를 담은 [ClientFailure] 를 throw 한다.
  GameMap parse(MapBlueprint blueprint) {
    final grid = blueprint.rows;
    final rowCount = _checkedRowCount(blueprint, grid);
    final colCount = _checkedColCount(blueprint, grid);

    _checkGridStructure(blueprint, grid);

    final floors = <List<FloorType>>[];
    final blocks = <Block>[];
    final goals = <Position>[];
    var nextId = 0;

    for (var row = 0; row < rowCount; row++) {
      final floorRow = <FloorType>[];

      for (var col = 0; col < colCount; col++) {
        final symbol = grid[2 * row + 1][2 * col + 1];
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
            floorRow.add(FloorType.blackHole);
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
            throw _invalid(blueprint, '칸 $position 에 알 수 없는 기호 "$symbol" 가 있다');
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

    // **파서는 이 판이 풀리는지 판단하지 않는다** (기획서 §9.2). 표기가 판으로
    // 읽히는지만 본다.
    //
    // 한때 목표 네 방향에 정지 요소(칸 벽 · 맵 경계 · 경계 벽)가 있는지도 검사해
    // 없으면 거절했는데, **의도한 배치를 막았다.** 일반 블록은 고정된 정지 요소가
    // 아니지만 브레이크로는 쓰이므로, 동료를 먼저 흘려 넣어 그 앞에 서는 판은
    // 고정 요소가 하나도 없어도 멀쩡하다 (기획서 §4.3 · §4.4-1 발판).
    //
    // 풀이 가능성은 `level_design_test` 의 완전 탐색이 본다. 인접 칸만 보는 검사는
    // 그보다 약해서, 통과시켜도 풀린다는 보장이 없고 거절한 것 중에 멀쩡한 판이
    // 섞인다. 약한 검사를 앞에 두면 강한 검사에 닿기도 전에 막힌다.
    return GameMap(
      levelNumber: blueprint.levelNumber,
      initialBoard: BoardState(
        rowCount: rowCount,
        colCount: colCount,
        floors: floors,
        blocks: blocks,
        walls: _readWalls(grid, rowCount, colCount),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 격자 구조 검증
  // ---------------------------------------------------------------------------

  int _checkedRowCount(MapBlueprint blueprint, List<String> grid) {
    if (grid.length < 3 || grid.length.isEven) {
      throw _invalid(
        blueprint,
        '줄 수는 3 이상의 홀수(2N+1)여야 하는데 ${grid.length} 이다',
      );
    }
    return (grid.length - 1) ~/ 2;
  }

  int _checkedColCount(MapBlueprint blueprint, List<String> grid) {
    final width = grid.first.length;
    if (width < 3 || width.isEven) {
      throw _invalid(blueprint, '글자 수는 3 이상의 홀수(2M+1)여야 하는데 $width 이다');
    }
    for (var line = 0; line < grid.length; line++) {
      if (grid[line].length != width) {
        throw _invalid(
          blueprint,
          '$line 번째 줄의 길이가 ${grid[line].length} 로 첫 줄($width)과 다르다',
        );
      }
    }
    return (width - 1) ~/ 2;
  }

  /// 자리마다 허용된 기호만 있는지, 그리고 외곽이 닫혀 있는지 본다.
  ///
  /// 격자 구조 자체가 검증 대상이라, 열이 하나 밀리는 종류의 오타는
  /// 레벨을 실행해보기 전에 잡힌다.
  void _checkGridStructure(MapBlueprint blueprint, List<String> grid) {
    for (var line = 0; line < grid.length; line++) {
      final width = grid[line].length;

      for (var index = 0; index < width; index++) {
        final symbol = grid[line][index];
        final onRowBoundary = line.isEven;
        final onColBoundary = index.isEven;

        if (onRowBoundary && onColBoundary) {
          if (symbol != _corner) {
            throw _invalid(
              blueprint,
              '교차점 [$line][$index] 은 "$_corner" 여야 하는데 "$symbol" 이다',
            );
          }
        } else if (onRowBoundary) {
          _checkBoundary(blueprint, symbol, _horizontalWall, line, index);
          // 맨 위·아래 줄은 맵 경계다. 반드시 벽이어야 한다.
          if ((line == 0 || line == grid.length - 1) &&
              symbol != _horizontalWall) {
            throw _invalid(blueprint, '외곽이 [$line][$index] 에서 열려 있다');
          }
        } else if (onColBoundary) {
          _checkBoundary(blueprint, symbol, _verticalWall, line, index);
          if ((index == 0 || index == width - 1) && symbol != _verticalWall) {
            throw _invalid(blueprint, '외곽이 [$line][$index] 에서 열려 있다');
          }
        }
        // 칸(홀·홀)의 기호 검증은 파싱 루프의 switch 가 맡는다.
      }
    }
  }

  void _checkBoundary(
    MapBlueprint blueprint,
    String symbol,
    String wall,
    int line,
    int index,
  ) {
    if (symbol != wall && symbol != _noWall) {
      throw _invalid(
        blueprint,
        '경계 [$line][$index] 은 "$wall" 또는 공백이어야 하는데 "$symbol" 이다',
      );
    }
  }

  // ---------------------------------------------------------------------------

  /// 오른쪽·아래쪽 경계만 읽는다. [WallEdge] 가 그 방향으로 정규화돼 있고,
  /// 맵 외곽은 데이터가 아니라 검증 대상이므로 담지 않는다.
  Set<WallEdge> _readWalls(List<String> grid, int rowCount, int colCount) {
    final walls = <WallEdge>{};

    for (var row = 0; row < rowCount; row++) {
      for (var col = 0; col < colCount; col++) {
        if (col < colCount - 1 &&
            grid[2 * row + 1][2 * col + 2] == _verticalWall) {
          walls.add(WallEdge.between(Position(row, col), Direction.right));
        }
        if (row < rowCount - 1 &&
            grid[2 * row + 2][2 * col + 1] == _horizontalWall) {
          walls.add(WallEdge.between(Position(row, col), Direction.down));
        }
      }
    }

    return walls;
  }

  ClientFailure _invalid(MapBlueprint blueprint, String reason) => ClientFailure(
    code: FailureCode.invalidMapData,
    stackTrace: StackTrace.current,
    debugMessage: '레벨 ${blueprint.levelNumber} 맵: $reason',
  );
}
