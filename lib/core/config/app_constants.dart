/// 앱 전역 상수. 매직넘버는 전부 여기에 모은다.
abstract class AppConstants {
  static const String appName = 'BlockRunner';

  static const int _moveMs = 150;
  static const int _fallMs = 120;

  /// 블록 슬라이드 애니메이션 지속 시간.
  ///
  /// 이동 거리와 무관하게 모든 블록이 동시에 출발·도착해야 하므로
  /// 거리 비례가 아닌 고정값이다. (docs/game-design.md §7)
  static const Duration moveAnimationDuration = Duration(milliseconds: _moveMs);

  /// 구멍에 빠지는 연출 시간. 슬라이드가 끝난 뒤 별도로 재생한다.
  static const Duration fallAnimationDuration = Duration(milliseconds: _fallMs);

  /// 낙하가 있는 이동 한 번의 전체 소요 시간 — 슬라이드 + 낙하.
  static const Duration moveWithFallDuration = Duration(
    milliseconds: _moveMs + _fallMs,
  );

  /// 전체 구간 중 낙하 연출이 시작되는 지점의 비율.
  ///
  /// 낙하는 슬라이드가 **끝난 뒤** 재생돼야 하는데(기획서 §7) 암시적 애니메이션에는
  /// 시작 지연이 없다. 전체 구간을 하나로 잡고 `Interval` 로 뒷부분만 쓰게 해서
  /// 두 단계를 순서대로 재생한다. 타이머를 하나 더 두지 않아도 된다.
  static const double fallStartFraction = _moveMs / (_moveMs + _fallMs);

  /// 보드가 아무리 커도 이 크기를 넘지 않는다.
  /// 대형 모니터에서 보드가 화면을 다 먹으면 시선 이동이 커져 오히려 불편하다.
  static const double maxBoardExtent = 640;

  /// 스와이프로 인정할 최소 이동 거리(논리 픽셀).
  static const double swipeThreshold = 24;
}
