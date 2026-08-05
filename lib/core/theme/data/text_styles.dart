import 'package:flutter/material.dart';

/// 앱 공통 텍스트 스타일.
///
/// 색은 지정하지 않는다 — ColorScheme 에서 상속받아 라이트/다크 양쪽에서
/// 동작해야 한다.
abstract class AppTextStyles {
  /// 레벨 번호, 이동 횟수처럼 숫자를 크게 보여줄 때.
  ///
  /// tabular figures 를 쓰지 않으면 이동 횟수가 9 → 10 으로 넘어갈 때
  /// 글자 폭이 달라져 HUD 가 흔들린다.
  static const TextStyle counter = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle counterLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle levelTileNumber = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
