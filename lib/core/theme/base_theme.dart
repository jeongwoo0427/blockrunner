import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:flutter/material.dart';

/// 라이트/다크 공통 ThemeData 조립.
abstract class BaseTheme {
  /// UI 색을 파생시키는 seed.
  ///
  /// **보드 색과 갈라 두었다.** 전에는 플레이어 블록 색을 그대로 seed 로 썼는데,
  /// 그러면 보드에서 고른 색이 화면 전체를 정해버려 한쪽만 손볼 수가 없었다.
  /// 지금은 **UI 는 이 seed 를, 보드는 [BoardColors] 를** 따른다.
  ///
  /// 값은 파랑이지만 [BoardColors.playerBlock] 과 같은 색은 아니다. 우연히
  /// 비슷해지더라도 **두 상수는 서로를 참조하지 않는다** — 그것이 갈라 둔 이유다.
  static const seed = Color(0xFF2F5FD0);

  static ThemeData build({
    required Brightness brightness,
    required BoardColors boardColors,
  }) {
    final base = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

    // **tertiary 만 직접 고른다.** Material 3 는 tertiary 를 seed 에서 색상환으로
    // 60° 돌려 뽑으므로, **파란 seed 에서는 보랏빛이 나온다.** 그 색이 쓰이는
    // 곳이 하필 **깬 레벨 카드**라(`level_card.dart`) 화면에서 가장 눈에 띄는
    // 자리에 보라가 앉는다 — 처음에 눈에 거슬렸던 것이 바로 이것이다.
    //
    // 대신 같은 한색 안에서 **더 밝은 청록**으로 잡는다. 카드 세 상태
    // (잠김 · 열림 · 깸)가 채움색만으로 갈려야 하는데(12-ui-polish), 색상만
    // 맞추고 명도를 비슷하게 두면 열림과 깸이 붙어버린다.
    final colorScheme = brightness == Brightness.light
        ? base.copyWith(
            tertiary: const Color(0xFF4FC3DC),
            onTertiary: const Color(0xFF06323C),
          )
        : base.copyWith(
            tertiary: const Color(0xFF7FD3E8),
            onTertiary: const Color(0xFF04323E),
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
