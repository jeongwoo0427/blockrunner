import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/usecase/game_usecases/apply_move_usecase.dart';

/// 너비 우선 완전 탐색으로 실제 최소 이동 횟수를 구한다. 풀 수 없으면 `null`.
///
/// **테스트 전용이다.** 레벨 데이터의 `minMoves` 가 손으로 센 값이라 틀리기 쉬운데,
/// 틀리면 별점 기준이 조용히 어긋나고 클리어 불가능한 레벨이 배포될 수 있다.
/// 상태 공간이 작아(6×6, 블록 2~3개) 완전 탐색이 실용적이다.
int? solveMinMoves(BoardState initial, {int maxMoves = 12}) {
  const applyMove = ApplyMoveUsecase();

  if (initial.isCleared) return 0;

  final visited = <String>{_key(initial)};
  var frontier = <BoardState>[initial];

  for (var depth = 1; depth <= maxMoves; depth++) {
    final next = <BoardState>[];

    for (final board in frontier) {
      for (final direction in Direction.values) {
        final result = applyMove(board, direction);
        if (!result.moved) continue;

        final moved = result.board;
        if (moved.isCleared) return depth;
        // 플레이어가 블랙홀에 빠진 판은 되돌리기 말고는 길이 없다.
        if (!moved.hasPlayer) continue;
        if (visited.add(_key(moved))) next.add(moved);
      }
    }

    if (next.isEmpty) break;
    frontier = next;
  }

  return null;
}

/// 블록 배치만이 상태다. 바닥은 레벨 내내 고정이므로 키에 넣지 않는다.
String _key(BoardState board) {
  final blocks = [...board.blocks]..sort((a, b) => a.id.compareTo(b.id));
  return blocks
      .map((block) => '${block.id}:${block.position.row},${block.position.col}')
      .join(';');
}
