import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/domain/entity/wall_edge.dart';
import 'package:flutter_test/flutter_test.dart';

/// 기획서 §9 의 ASCII 표기를 보드로 바꾸는 **테스트 전용** 헬퍼.
///
/// 정식 파서는 `03-level-data` 에서 `lib/` 에 만든다. 이동 엔진 테스트가 아직
/// 없는 파서에 묶이지 않도록 여기에 최소한만 둔다.
///
/// 이 표기는 **칸만** 나열하므로 경계 벽을 적을 수 없다. 필요하면 [walls] 로
/// 직접 넘긴다 — 이동 엔진 테스트가 검증하는 것은 미끄러짐·정렬 순서·블랙홀이지
/// 레벨 저작이 아니라서, 31개 케이스를 격자 표기로 바꾸면 읽기만 어려워진다.
///
/// 블록 id 는 좌상단부터 행 우선(row-major) 순서로 0 부터 붙는다.
BoardState parseBoard(List<String> rows, {Set<WallEdge> walls = const {}}) {
  final floors = <List<FloorType>>[];
  final blocks = <Block>[];
  var nextId = 0;

  for (var row = 0; row < rows.length; row++) {
    final line = rows[row];
    final floorRow = <FloorType>[];

    for (var col = 0; col < line.length; col++) {
      final symbol = line[col];
      switch (symbol) {
        case '.':
          floorRow.add(FloorType.empty);
        case '#':
          floorRow.add(FloorType.wall);
        case 'G':
          floorRow.add(FloorType.goal);
        case 'X':
          floorRow.add(FloorType.blackHole);
        case 'O':
          floorRow.add(FloorType.empty);
          blocks.add(
            Block(
              id: nextId++,
              type: BlockType.normal,
              position: Position(row, col),
            ),
          );
        case '@':
          floorRow.add(FloorType.empty);
          blocks.add(
            Block(
              id: nextId++,
              type: BlockType.player,
              position: Position(row, col),
            ),
          );
        default:
          fail('알 수 없는 기호: "$symbol" ($row행 $col열)');
      }
    }
    floors.add(floorRow);
  }

  return BoardState(
    rowCount: rows.length,
    colCount: rows.first.length,
    floors: floors,
    blocks: blocks,
    walls: walls,
  );
}

/// 보드를 ASCII 로 되돌린다.
///
/// **내용물이 바닥을 가린다.** 목표 칸 위에 선 플레이어는 `G` 가 아니라 `@` 로 찍히므로,
/// 클리어 여부는 ASCII 가 아니라 [BoardState.isCleared] 로 확인해야 한다.
List<String> formatBoard(BoardState board) {
  return List.generate(board.rowCount, (row) {
    final buffer = StringBuffer();
    for (var col = 0; col < board.colCount; col++) {
      final position = Position(row, col);
      final block = board.blockAt(position);
      if (block != null) {
        buffer.write(block.isPlayer ? '@' : 'O');
        continue;
      }
      buffer.write(switch (board.floorAt(position)) {
        FloorType.empty => '.',
        FloorType.wall => '#',
        FloorType.goal => 'G',
        FloorType.blackHole => 'X',
      });
    }
    return buffer.toString();
  });
}
