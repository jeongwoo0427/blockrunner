/// 간격 척도. 4의 배수로 통일한다.
abstract class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// 보드 격자선 두께
  static const double gridLineWidth = 1;

  /// 경계 벽과 외곽 프레임 두께 (셀 크기 대비 비율).
  ///
  /// 격자선(1px)과 확실히 구분돼야 한다. 비슷한 굵기면 "여기 벽이 있다"가
  /// 읽히지 않아 플레이어가 규칙을 오해한다.
  static const double wallWidthRatio = 0.1;

  /// 블록 모서리 둥글기 (셀 크기 대비 비율)
  static const double blockRadiusRatio = 0.18;

  /// 판 아래에 깔리는 그림자 (셀 크기 대비 비율).
  ///
  /// **화면 크기가 아니라 셀에 비례시킨다.** 고정 px 로 두면 작은 폰에서는
  /// 판을 삼키고 큰 창에서는 종이에 붙은 것처럼 얇아진다.
  static const double boardShadowBlurRatio = 0.5;

  /// 그림자가 아래로 밀리는 거리 (셀 크기 대비 비율).
  ///
  /// 빛이 위에서 온다는 뜻이라 아래로만 민다. 사방으로 퍼지면 떠 있는 것이
  /// 아니라 빛나는 것으로 읽힌다.
  static const double boardShadowOffsetRatio = 0.16;

  /// 블록과 칸 경계 사이의 여백 (셀 크기 대비 비율, 사방).
  ///
  /// 블록이 칸을 꽉 채우면 격자선과 붙어 답답하고, 이웃한 블록끼리도
  /// 한 덩어리로 보인다.
  static const double blockInsetRatio = 0.11;
}
