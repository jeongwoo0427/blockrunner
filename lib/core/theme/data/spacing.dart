/// 간격 척도. 4의 배수로 통일한다.
abstract class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// 보드 격자선 두께
  static const double gridLineWidth = 1;

  /// 블록 모서리 둥글기 (셀 크기 대비 비율)
  static const double blockRadiusRatio = 0.18;
}
