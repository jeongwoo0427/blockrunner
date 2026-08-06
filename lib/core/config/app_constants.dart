/// 앱 전역 상수. 매직넘버는 전부 여기에 모은다.
abstract class AppConstants {
  static const String appName = 'BlockRunner';

  static const int _moveMs = 150;
  static const int _fallMs = 120;

  /// 플레이어가 블랙홀에 빨려 들어가는 시간 (12-ui-polish §5.3).
  ///
  /// 일반 블록보다 훨씬 길다. 판이 끝나는 순간이라 연출을 길게 줄 이유가
  /// 있고, 반대로 일반 블록이 빠질 때마다 2초를 기다리면 답답해진다.
  static const int _playerFallMs = 2000;

  /// 블록 슬라이드 애니메이션 지속 시간.
  ///
  /// 이동 거리와 무관하게 모든 블록이 동시에 출발·도착해야 하므로
  /// 거리 비례가 아닌 고정값이다. (docs/game-design.md §7)
  static const Duration moveAnimationDuration = Duration(milliseconds: _moveMs);

  /// 블랙홀에 빠지는 연출 시간. 슬라이드가 끝난 뒤 별도로 재생한다.
  static const Duration fallAnimationDuration = Duration(milliseconds: _fallMs);

  /// 낙하가 있는 이동 한 번의 전체 소요 시간 — 슬라이드 + 낙하.
  static const Duration moveWithFallDuration = Duration(
    milliseconds: _moveMs + _fallMs,
  );

  /// 플레이어가 빨려 들어갈 때의 이동 한 번 전체 시간 — 슬라이드 + 흡입.
  static const Duration moveWithPlayerFallDuration = Duration(
    milliseconds: _moveMs + _playerFallMs,
  );

  /// 블랙홀이 한 바퀴 도는 데 걸리는 시간 (12-ui-polish §5.2).
  ///
  /// 빠르면 시선을 뺏고 어지럽다. 판 위에 늘 떠 있는 것이라 느려야 한다.
  static const Duration blackHoleRotationDuration = Duration(seconds: 6);

  /// 전체 구간 중 낙하 연출이 시작되는 지점의 비율.
  ///
  /// 낙하는 슬라이드가 **끝난 뒤** 재생돼야 하는데(기획서 §7) 암시적 애니메이션에는
  /// 시작 지연이 없다. 전체 구간을 하나로 잡고 `Interval` 로 뒷부분만 쓰게 해서
  /// 두 단계를 순서대로 재생한다. 타이머를 하나 더 두지 않아도 된다.
  static const double fallStartFraction = _moveMs / (_moveMs + _fallMs);

  /// 같은 것을 플레이어 흡입 구간에 대해 계산한 값.
  static const double playerFallStartFraction =
      _moveMs / (_moveMs + _playerFallMs);

  /// 레벨당 되돌리기 횟수 (기획서 §5.1).
  ///
  /// 무제한이면 아무 방향이나 눌러보고 무르는 것이 최적 전략이 되어 퍼즐이
  /// 성립하지 않는다. 실수를 만회할 만큼은 되지만 전수 탐색에는 모자란 값이다.
  /// 다시하기가 이 횟수를 되살리므로 막히는 일은 없다.
  static const int undoLimit = 3;

  /// 보드가 아무리 커도 이 크기를 넘지 않는다.
  /// 대형 모니터에서 보드가 화면을 다 먹으면 시선 이동이 커져 오히려 불편하다.
  static const double maxBoardExtent = 640;

  /// 스와이프로 인정할 최소 이동 거리(논리 픽셀).
  static const double swipeThreshold = 24;
}
