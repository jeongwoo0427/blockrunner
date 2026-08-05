import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:flutter/material.dart';

/// 라이트/다크 공통 ThemeData 조립.
///
/// 보드 색만 직접 고르고(BoardColors), 나머지 UI 색은 그 중 플레이어 색을
/// seed 로 삼아 Material 3 가 파생시키게 한다. 보드가 화면의 주인공이므로
/// UI 색이 보드 팔레트를 따라오는 방향이 맞다.
abstract class BaseTheme {
  static ThemeData build({
    required Brightness brightness,
    required BoardColors boardColors,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: boardColors.playerBlock,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: [boardColors],
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
    );
  }
}
