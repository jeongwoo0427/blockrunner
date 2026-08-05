import 'dart:ui';

import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';

/// 스와이프 이동량을 4방향 중 하나로 판정한다. 너무 짧으면 `null`(탭으로 본다).
///
/// 위젯에서 분리한 순수 함수다. 대각선을 4방향으로 강제 매핑하는 규칙이라
/// 경계 동작을 눈이 아니라 테스트로 고정해야 한다.
///
/// 판정 규칙:
/// - **가로·세로 성분 중 절대값이 큰 쪽**이 방향이 된다.
/// - 임계값은 그 **우세한 성분**에 적용한다. 두 성분이 모두 임계값 미만이면
///   대각선으로 합친 거리가 넘더라도 무시한다 — 어느 방향을 의도했는지
///   알 수 없는 입력을 넘겨짚지 않는다.
/// - 두 성분이 정확히 같으면 가로가 이긴다. 임의의 선택이지만 고정해둔다.
Direction? directionFromSwipe(
  Offset delta, {
  double threshold = AppConstants.swipeThreshold,
}) {
  final horizontal = delta.dx.abs();
  final vertical = delta.dy.abs();

  if (horizontal >= vertical) {
    if (horizontal < threshold) return null;
    return delta.dx > 0 ? Direction.right : Direction.left;
  }

  if (vertical < threshold) return null;
  return delta.dy > 0 ? Direction.down : Direction.up;
}
