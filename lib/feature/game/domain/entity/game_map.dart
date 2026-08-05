import 'package:blockrunner/feature/game/domain/entity/board_state.dart';

/// 한 레벨의 판. 레벨 번호로 [Level] 메타데이터와 이어진다.
///
/// `Map` 은 `dart:core` 와 충돌하므로 쓰지 않는다.
class GameMap {
  const GameMap({required this.levelNumber, required this.initialBoard});

  /// 대응하는 레벨 번호. 이 값이 두 상수 목록을 잇는 유일한 키다.
  final int levelNumber;

  /// 시작 배치. 다시하기가 되돌아갈 지점이기도 하다.
  final BoardState initialBoard;
}
