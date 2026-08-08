import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/domain/entity/wall_edge.dart';
import 'package:blockrunner/feature/game/domain/usecase/game_usecases/apply_move_usecase.dart';

import 'min_moves_solver.dart';

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

/// 갈 수 있는 판이 [maxStates] 를 넘으면 탐색을 멈추고 `null` 을 돌려준다.
///
/// **레벨을 고를 때만 쓴다.** 동료 블록이 넷쯤 되면 판 하나의 상태 공간이
/// 수백만으로 불어나, 후보를 수십만 개 훑는 탐색이 첫 판에서 멈춰 선다.
/// 완성된 레벨은 상한 없이 검사한다 — 그때는 판이 스무 개뿐이다.
LevelAnalysis? analyzeWithin(BoardState initial, int maxStates) =>
    _analyze(initial, maxStates);

LevelAnalysis analyzeLevel(BoardState initial) => _analyze(initial, null)!;

LevelAnalysis? _analyze(BoardState initial, int? maxStates) {
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
      if (maxStates != null && states.length > maxStates) return null;
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

/// 상태는 **블록 배치 + 남아 있는 블랙홀**이다 (`min_moves_solver.dart` 와 같은 이유).
///
/// 블랙홀이 소모되므로(기획서 §3.3) 바닥이 더는 고정이 아니다. 구멍이 하나 덜
/// 남은 판을 같은 판으로 세면 막다른 판 분석까지 함께 틀린다 — 실제로는 못 깨는
/// 판이 "깰 수 있다" 로 읽힌다.
String _key(BoardState board) => '${blockKey(board)}|${holeKey(board)}';

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

/// 최단 해법을 지나는 동안 **블랙홀에 삼켜지는 동료 블록의 수**.
///
/// 최단 해법이 여럿이면 그중 가장 적게 잃는 쪽을 센다 — "안 버려도 풀린다" 를
/// 잡아내야 하기 때문이다. 풀 수 없으면 `null`.
///
/// 동료 블록을 하나씩 블랙홀에 버려 길을 여는 레벨이 정말 그렇게 풀리는지
/// 검사하는 데 쓴다. 판에 블랙홀과 블록이 함께 있다고 해서 버리는 판은 아니다.
int? swallowedOnBestPath(BoardState initial) {
  const applyMove = ApplyMoveUsecase();

  int companionsIn(BoardState board) =>
      board.blocks.where((block) => block.type == BlockType.normal).length;

  final total = companionsIn(initial);

  // **깊이별로 층을 나눠 탐색한다.** 한 판을 나중에 더 적게 잃고 다시 만나도
  // 그것은 더 긴 해법이다 — 최단 해법 중에서만 고르려면 층을 섞으면 안 된다.
  final seen = <String>{_key(initial)};
  var frontier = {_key(initial): initial};
  var loss = {_key(initial): 0};

  while (frontier.isNotEmpty) {
    int? cleared;
    frontier.forEach((key, board) {
      if (!board.isCleared) return;
      final lost = loss[key]!;
      if (cleared == null || lost < cleared!) cleared = lost;
    });
    if (cleared != null) return cleared;

    final nextBoards = <String, BoardState>{};
    final nextLoss = <String, int>{};

    frontier.forEach((key, board) {
      for (final direction in Direction.values) {
        final result = applyMove(board, direction);
        if (!result.moved) continue;

        final moved = result.board;
        if (!moved.hasPlayer) continue;

        final movedKey = _key(moved);
        if (seen.contains(movedKey)) continue;

        final lost = total - companionsIn(moved);
        if (nextLoss.containsKey(movedKey) && nextLoss[movedKey]! <= lost) {
          continue;
        }
        nextBoards[movedKey] = moved;
        nextLoss[movedKey] = lost;
      }
    });

    seen.addAll(nextBoards.keys);
    frontier = nextBoards;
    loss = nextLoss;
  }

  return null;
}

/// 동료 블록을 전부 걷어낸 판.
///
/// "동료가 없으면 못 깬다" 를 검사하는 데 쓴다 — 발판형 레벨의 정의다
/// (기획서 §4.4-1).
BoardState withoutCompanions(BoardState board) => BoardState(
  rowCount: board.rowCount,
  colCount: board.colCount,
  floors: board.floors,
  blocks: board.blocks
      .where((block) => block.type == BlockType.player)
      .toList(),
  walls: board.walls,
);
