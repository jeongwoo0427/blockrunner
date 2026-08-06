import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/entity/move_result.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';

/// 방향 입력 하나를 받아 다음 보드 상태를 계산한다. 기획서 §3.2 의 구현이다.
///
/// 의존성이 없는 순수 계산이다. repository 도 받지 않으므로 위젯 없이 전부 테스트할 수 있고,
/// 이 게임의 규칙과 버그는 사실상 전부 이 클래스 안에 있다.
class ApplyMoveUsecase {
  const ApplyMoveUsecase();

  MoveResult call(BoardState board, Direction direction) {
    // 이동 방향의 "가장 앞쪽" 블록부터 처리한다. 앞쪽 블록이 먼저 최종 위치를
    // 확정해야 뒤따르는 블록이 그 앞에 멈춘다. 순서를 뒤집으면 블록이 서로를
    // 통과하거나 겹친다(기획서 §4.1).
    final ordered = [...board.blocks]
      ..sort(
        (a, b) => _frontness(b, direction).compareTo(_frontness(a, direction)),
      );

    final settled = <Block>[];
    // 이미 최종 위치를 확정한 블록만 장애물이다. 아직 처리하지 않은 블록은
    // 어차피 같은 방향으로 비켜나므로 막지 않는다.
    final occupied = <Position>{};
    final from = <int, Position>{};
    final to = <int, Position>{};
    final fellIntoBlackHole = <int>[];
    var moved = false;

    for (final block in ordered) {
      var current = block.position;
      var fell = false;

      while (true) {
        final next = current.translate(direction);
        // 맵 밖은 floorAt 이 벽으로 돌려주므로 경계를 따로 분기하지 않는다.
        // 경계 벽은 칸이 아니라 칸 사이를 막으므로 next 가 아니라 "나가는 길"을 본다.
        if (board.hasWallBetween(current, direction) ||
            board.floorAt(next) == FloorType.wall ||
            occupied.contains(next)) {
          break;
        }
        current = next;
        // 블랙홀은 정지 지점이 아니라 통과 경로에서 판정한다. 들어서는 순간
        // 사라지며 블랙홀 너머로 나아가지 않는다(기획서 §3.3).
        if (board.floorAt(current) == FloorType.blackHole) {
          fell = true;
          break;
        }
      }

      from[block.id] = block.position;
      to[block.id] = current;
      if (current != block.position) moved = true;

      if (fell) {
        fellIntoBlackHole.add(block.id);
      } else {
        settled.add(block.moveTo(current));
        occupied.add(current);
      }
    }

    return MoveResult(
      // 무효 입력이면 입력 보드를 그대로 돌려준다. 되돌리기 스택에 같은 판이
      // 쌓이지 않게 하려면 호출부가 moved 를 보고 판단하면 된다.
      board: moved ? board.withBlocks(settled) : board,
      moved: moved,
      from: from,
      to: to,
      fellIntoBlackHole: fellIntoBlackHole,
    );
  }

  /// 이동 방향 기준으로 얼마나 앞쪽에 있는지. 클수록 앞이다.
  ///
  /// `→` 는 열 내림차순, `←` 는 열 오름차순, `↓` 는 행 내림차순, `↑` 는 행 오름차순이
  /// 되어야 하는데, 이 값의 내림차순 정렬 하나로 네 경우가 모두 나온다.
  int _frontness(Block block, Direction direction) =>
      block.position.row * direction.rowDelta +
      block.position.col * direction.colDelta;
}
