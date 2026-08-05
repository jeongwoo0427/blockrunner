import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';

/// 이동 1회의 결과. 애니메이션이 필요로 하는 정보를 전부 담는다.
///
/// 화면은 [board] 만으로는 연출을 그릴 수 없다. "어느 블록이 어디서 어디로
/// 갔는지"를 알아야 하므로 출발·도착 좌표를 blockId 로 함께 넘긴다.
class MoveResult {
  const MoveResult({
    required this.board,
    required this.moved,
    required this.from,
    required this.to,
    required this.fellIntoHole,
  });

  /// 이동이 끝난 뒤의 보드. [moved] 가 `false` 면 입력 전 보드와 같다.
  final BoardState board;

  /// 한 블록이라도 위치가 바뀌었는가. `false` 면 무효 입력이며 이동 횟수를 세지 않는다.
  final bool moved;

  /// blockId → 출발 위치.
  final Map<int, Position> from;

  /// blockId → 도착 위치. 구멍에 빠진 블록은 **사라진 칸(구멍 위치)** 이 담긴다.
  final Map<int, Position> to;

  /// 구멍에 빠져 사라진 blockId 목록. [board] 에는 남아있지 않다.
  final List<int> fellIntoHole;
}
