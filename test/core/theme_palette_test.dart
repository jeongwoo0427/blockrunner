import 'package:blockrunner/core/theme/data/dark_theme.dart';
import 'package:blockrunner/core/theme/data/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// UI 팔레트가 지켜야 하는 성질.
///
/// **값이 아니라 관계를 검사한다** — 색값을 박아 두면 색을 조금만 손봐도 깨져서
/// 아무도 안 읽게 된다 (`board_colors_test` 와 같은 방침).
void main() {
  final schemes = {'light': lightTheme, 'dark': darkTheme};

  double hue(Color c) => HSLColor.fromColor(c).hue;
  double lightness(Color c) => HSLColor.fromColor(c).lightness;
  double saturation(Color c) => HSLColor.fromColor(c).saturation;

  /// 색조를 말할 수 있을 만큼 색이 들어 있는가.
  ///
  /// **밝기도 함께 봐야 한다.** HSL 에서는 거의 흰색인 `#FAF8FF` 도 채도가 1.0
  /// 로 나온다 — 채도만 보면 눈에 보이지도 않는 색 기운으로 검사가 걸린다
  /// (실제로 `surface` 가 "보라(hue 257)" 로 잡혔다).
  bool hasColor(Color c) =>
      saturation(c) > 0.15 && lightness(c) > 0.12 && lightness(c) < 0.9;

  schemes.forEach((name, theme) {
    group(name, () {
      final scheme = theme.colorScheme;

      /// 화면에 실제로 쓰이는 역할들.
      final roles = <String, Color>{
        'primary': scheme.primary,
        'primaryContainer': scheme.primaryContainer,
        'secondary': scheme.secondary,
        'secondaryContainer': scheme.secondaryContainer,
        'tertiary': scheme.tertiary,
        'surface': scheme.surface,
        'surfaceContainerHighest': scheme.surfaceContainerHighest,
        'outlineVariant': scheme.outlineVariant,
      };

      test('보랏빛이 없다', () {
        // **사용자 요청의 핵심이다.** 색 계열 자체는 몇 번 바뀌었지만("갈색으로"
        // → "파란색으로") 매번 걸린 것은 같았다 — 보라다.
        //
        // 출처는 늘 파생이다. Material 3 는 tertiary 를 seed 에서 60° 돌려
        // 뽑는데, 파란 seed 에서는 그 자리가 정확히 보라다. 그래서 seed 를
        // 바꾸는 것만으로는 이 검사를 통과하지 못하고 `BaseTheme` 가 tertiary
        // 를 직접 골라야 한다.
        roles.forEach((role, color) {
          if (!hasColor(color)) return;

          final angle = hue(color);
          expect(
            angle > 255 && angle < 335,
            isFalse,
            reason: '$role 이 보라 쪽이다 (hue ${angle.round()})',
          );
        });
      });

      test('색이 있는 역할이 한 계열 안에 머문다', () {
        // 계열이 무엇인지는 정하지 않는다 — 그것은 취향이고 바뀌어 왔다.
        // 다만 **한 화면에 서로 먼 색조가 흩어지면** 통일감이 깨진다.
        final angles = [
          for (final color in roles.values)
            if (hasColor(color)) hue(color),
        ];
        expect(angles, isNotEmpty);

        // tertiary 는 일부러 떨어뜨린 강조색이라 가장 멀다. 그것까지 포함해
        // 한 바퀴의 3분의 1 안에 들어와야 한다.
        final spread = angles.reduce((a, b) => a > b ? a : b) -
            angles.reduce((a, b) => a < b ? a : b);
        expect(
          spread,
          lessThan(120),
          reason: '색조가 ${spread.round()}° 로 흩어져 있다',
        );
      });

      test('레벨 카드의 세 상태가 채움색만으로 갈린다', () {
        // 잠김 · 열림 · 깸 을 색으로 구분한다(`level_card.dart`). 전에 두 색이
        // 거의 같아 상태가 두 가지로 보인 적이 있다.
        final fills = {
          'locked': scheme.surfaceContainerHighest,
          'playable': scheme.primary,
          'cleared': scheme.tertiary,
        };

        for (final a in fills.entries) {
          for (final b in fills.entries) {
            if (a.key == b.key) continue;

            expect(
              (lightness(a.value) - lightness(b.value)).abs(),
              greaterThan(0.1),
              reason: '${a.key} 과 ${b.key} 의 밝기가 비슷하다',
            );
          }
        }
      });
    });
  });
}
