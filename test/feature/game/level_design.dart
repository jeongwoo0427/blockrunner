import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/domain/entity/wall_edge.dart';
import 'package:blockrunner/feature/game/domain/usecase/game_usecases/apply_move_usecase.dart';

/// 레벨 하나를 완전 탐색해 **설계상 성립하는가**를 본다. 테스트 전용이다.
///
/// `minMoves` 만 맞아서는 부족하다. 되돌리기가 없으므로(기획서 §5.1) **한 번
/// 잘못 밀면 다시는 클리어할 수 없는 판**이 생길 수 있고, 그런 판은 화면상
/// 아무 일도 없는데 사실상 끝나 있다. 실패는 눈에 보여야 한다.
class LevelAnalysis {
  const LevelAnalysis({
    required this.minMoves,
    required this.reachable,
    required this.deadEnds,
    required this.sampleDeadEnd,
  });

  /// 최소 이동 횟수. 풀 수 없으면 `null`.
  final int? minMoves;

  /// 초기 배치에서 갈 수 있는 판의 수 (플레이어가 살아 있는 것만).
  final int reachable;

  /// 그중 **더 이상 클리어할 수 없는** 판의 수.
  ///
  /// 블랙홀에 빠진 판은 세지 않는다 — 그것은 눈에 보이는 실패이지 막다른
  /// 길이 아니다 (기획서 §3.5).
  final int deadEnds;

  /// 막다른 판 하나를 사람이 읽을 수 있게 그린 것. 없으면 `null`.
  final String? sampleDeadEnd;

  bool get isSolvable => minMoves != null;

  bool get hasDeadEnd => deadEnds > 0;
}

LevelAnalysis analyzeLevel(BoardState initial) {
  const applyMove = ApplyMoveUsecase();

  final states = <String, BoardState>{};
  final edges = <String, List<String>>{};
  final cleared = <String>{};

  // 1) 갈 수 있는 판을 전부 모은다. 블랙홀에 빠진 판은 실패이므로 넓히지 않는다.
  final queue = <BoardState>[initial];
  states[_key(initial)] = initial;

  while (queue.isNotEmpty) {
    final board = queue.removeLast();
    final key = _key(board);
    final next = <String>[];

    if (board.isCleared) {
      cleared.add(key);
      // 클리어한 판에서 더 미는 것은 게임이 받지 않는다(기획서 §6).
      edges[key] = next;
      continue;
    }

    for (final direction in Direction.values) {
      final result = applyMove(board, direction);
      if (!result.moved) continue;

      final moved = result.board;
      if (!moved.hasPlayer) continue; // 블랙홀에 빠졌다 — 보이는 실패다.

      final movedKey = _key(moved);
      next.add(movedKey);
      if (states.containsKey(movedKey)) continue;

      states[movedKey] = moved;
      queue.add(moved);
    }

    edges[key] = next;
  }

  // 2) 클리어에서 거꾸로 올라가며 "아직 살릴 수 있는 판"을 모은다.
  final incoming = <String, List<String>>{};
  edges.forEach((from, tos) {
    for (final to in tos) {
      (incoming[to] ??= []).add(from);
    }
  });

  final canClear = <String>{...cleared};
  final back = [...cleared];
  while (back.isNotEmpty) {
    for (final from in incoming[back.removeLast()] ?? const <String>[]) {
      if (canClear.add(from)) back.add(from);
    }
  }

  final dead = states.keys.where((key) => !canClear.contains(key)).toList();

  return LevelAnalysis(
    minMoves: _shortest(initial, cleared, edges),
    reachable: states.length,
    deadEnds: dead.length,
    sampleDeadEnd: dead.isEmpty ? null : render(states[dead.first]!),
  );
}

/// 초기 판에서 클리어까지의 최단 거리.
int? _shortest(
  BoardState initial,
  Set<String> cleared,
  Map<String, List<String>> edges,
) {
  final seen = <String>{_key(initial)};
  var frontier = [_key(initial)];

  if (cleared.contains(frontier.single)) return 0;

  for (var depth = 1; ; depth++) {
    final next = <String>[];

    for (final key in frontier) {
      for (final to in edges[key] ?? const <String>[]) {
        if (cleared.contains(to)) return depth;
        if (seen.add(to)) next.add(to);
      }
    }

    if (next.isEmpty) return null;
    frontier = next;
  }
}

/// 판을 사람이 읽을 수 있는 격자로 그린다. 실패한 테스트가 무엇을 보여줄지가
/// 곧 고치는 속도다.
String render(BoardState board) {
  final grid = [
    for (var row = 0; row < board.rowCount; row++)
      [
        for (var col = 0; col < board.colCount; col++)
          switch (board.floors[row][col]) {
            FloorType.empty => '.',
            FloorType.wall => '#',
            FloorType.goal => 'G',
            FloorType.blackHole => 'X',
          },
      ],
  ];

  for (final block in board.blocks) {
    grid[block.position.row][block.position.col] = switch (block.type) {
      BlockType.player => '@',
      BlockType.normal => 'O',
    };
  }

  return grid.map((row) => row.join(' ')).join('\n');
}

String _key(BoardState board) {
  final blocks = [...board.blocks]..sort((a, b) => a.id.compareTo(b.id));
  return blocks
      .map((block) => '${block.id}:${block.position.row},${block.position.col}')
      .join(';');
}

/// 요소를 하나씩 빼 봤을 때 **최소 수가 달라지는가**.
///
/// 달라지지 않으면 그 벽·블록은 판에 있으나 마나다. 장식을 늘리면 판만
/// 복잡해 보이고 어려워지지는 않는다 (기획서 §4.3).
///
/// 뺄 수 있는 것만 본다 — 플레이어와 목표는 판의 정의다.
List<String> uselessElements(BoardState board) {
  final moves = analyzeLevel(board).minMoves;
  final useless = <String>[];

  bool unchanged(BoardState trimmed) => analyzeLevel(trimmed).minMoves == moves;

  for (var r = 0; r < board.rowCount; r++) {
    for (var c = 0; c < board.colCount; c++) {
      final floor = board.floors[r][c];
      if (floor != FloorType.wall && floor != FloorType.blackHole) continue;

      final floors = [
        for (var i = 0; i < board.rowCount; i++) [...board.floors[i]],
      ];
      floors[r][c] = FloorType.empty;
      if (unchanged(_with(board, floors: floors))) {
        useless.add('${floor == FloorType.wall ? '칸 벽' : '블랙홀'} ($r,$c)');
      }
    }
  }

  for (final wall in board.walls) {
    final walls = {...board.walls}..remove(wall);
    if (unchanged(_with(board, walls: walls))) {
      useless.add('경계 벽 $wall');
    }
  }

  for (final block in board.blocks) {
    if (block.type == BlockType.player) continue;
    final blocks = [...board.blocks]..remove(block);
    if (unchanged(_with(board, blocks: blocks))) {
      useless.add('블록 ${block.position}');
    }
  }

  return useless;
}

BoardState _with(
  BoardState board, {
  List<List<FloorType>>? floors,
  Set<WallEdge>? walls,
  List<Block>? blocks,
}) => BoardState(
  rowCount: board.rowCount,
  colCount: board.colCount,
  floors: floors ?? board.floors,
  blocks: blocks ?? board.blocks,
  walls: walls ?? board.walls,
);

/// 잘라내도 최소 수가 그대로인 **가장자리 빈 줄**들.
///
/// 비어 있기만 한 것으로는 부족하다 — 빈 줄도 미끄러지는 거리를 만들기 때문에
/// 대개는 잘라내면 판이 달라진다. 잘라내도 **최소 수가 그대로면** 그 줄은
/// 판을 넓어 보이게 할 뿐이다 (기획서 §4.4).
List<String> paddedSides(BoardState board) {
  final moves = analyzeLevel(board).minMoves;

  return [
    for (final side in _Side.values)
      if (_trim(board, side) case final trimmed?)
        if (analyzeLevel(trimmed).minMoves == moves) side.name,
  ];
}

enum _Side { top, bottom, left, right }

/// 그 가장자리 한 줄이 완전히 비어 있으면 잘라낸 판, 아니면 `null`.
BoardState? _trim(BoardState board, _Side side) {
  bool rowEmpty(int row) =>
      board.floors[row].every((floor) => floor == FloorType.empty) &&
      !board.blocks.any((block) => block.position.row == row) &&
      !board.walls.any((wall) => wall.position.row == row);

  bool colEmpty(int col) =>
      [for (var r = 0; r < board.rowCount; r++) board.floors[r][col]].every(
        (floor) => floor == FloorType.empty,
      ) &&
      !board.blocks.any((block) => block.position.col == col) &&
      !board.walls.any((wall) => wall.position.col == col);

  var dr = 0, dc = 0, rows = board.rowCount, cols = board.colCount;

  switch (side) {
    case _Side.top:
      if (!rowEmpty(0)) return null;
      dr = 1;
      rows--;
    case _Side.bottom:
      if (!rowEmpty(board.rowCount - 1)) return null;
      rows--;
    case _Side.left:
      if (!colEmpty(0)) return null;
      dc = 1;
      cols--;
    case _Side.right:
      if (!colEmpty(board.colCount - 1)) return null;
      cols--;
  }

  if (rows < 2 || cols < 2) return null;

  return BoardState(
    rowCount: rows,
    colCount: cols,
    floors: [
      for (var r = 0; r < rows; r++)
        [for (var c = 0; c < cols; c++) board.floors[r + dr][c + dc]],
    ],
    blocks: [
      for (final block in board.blocks)
        Block(
          id: block.id,
          type: block.type,
          position: Position(
            block.position.row - dr,
            block.position.col - dc,
          ),
        ),
    ],
    walls: {
      for (final wall in board.walls)
        WallEdge.between(
          Position(wall.position.row - dr, wall.position.col - dc),
          wall.direction,
        ),
    },
  );
}
