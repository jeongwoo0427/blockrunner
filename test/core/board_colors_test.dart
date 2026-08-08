import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 팔레트가 지켜야 하는 성질 (12-ui-polish §4).
///
/// 색값 자체를 박아 두면 색을 조금만 손봐도 테스트가 깨져 아무도 안 읽게 된다.
/// **값이 아니라 관계를 검사한다.**
void main() {
  const palettes = {'light': BoardColors.light, 'dark': BoardColors.dark};

  /// 두 색상환 각도의 짧은 쪽 거리.
  double hueGap(Color a, Color b) {
    final gap = (HSLColor.fromColor(a).hue - HSLColor.fromColor(b).hue).abs();
    return gap > 180 ? 360 - gap : gap;
  }

  double lightness(Color c) => HSLColor.fromColor(c).lightness;
  double saturation(Color c) => HSLColor.fromColor(c).saturation;

  palettes.forEach((name, colors) {
    group(name, () {
      test('플레이어와 목표가 같은 색 계열이다', () {
        // 요청의 핵심 — "내가 어디로 가야 하는가" 가 색으로 읽혀야 한다.
        expect(hueGap(colors.playerBlock, colors.goal), lessThan(15));
      });

      test('그래도 둘의 밝기는 뚜렷이 다르다', () {
        // 플레이어가 목표 칸 위에 서는 것이 클리어 조건이라 둘은 반드시 겹친다.
        // 밝기까지 같으면 그 순간 목표가 사라진 것처럼 보인다.
        expect(
          (lightness(colors.playerBlock) - lightness(colors.goal)).abs(),
          greaterThanOrEqualTo(0.15),
        );
      });

      test('플레이어·목표가 동료 블록보다 훨씬 진하다', () {
        // 색상만으로는 셋이 전부 파란 계열이라 갈리지 않는다. 실제 구분자는
        // **채도**다 — 동료 블록은 흐린 회청색으로 뒤로 물러나 있어야 한다.
        expect(
          saturation(colors.playerBlock),
          greaterThan(saturation(colors.normalBlock) + 0.3),
        );
        expect(
          saturation(colors.goal),
          greaterThan(saturation(colors.normalBlock) + 0.2),
        );
      });

      test('블랙홀은 바탕보다 어둡다', () {
        expect(
          lightness(colors.blackHole),
          lessThan(lightness(colors.background)),
        );
      });
    });
  });

  test('라이트 판은 하얗다', () {
    // 화면 바탕이 옅게 색을 띠므로, 판까지 색이 있으면 배경의 일부처럼
    // 읽힌다. 흰 판이어야 그 위가 퍼즐이라는 것이 갈린다.
    expect(BoardColors.light.background, const Color(0xFFFFFFFF));
  });

  test('동료 블록 색은 그대로 둔다', () {
    // 사용자 요청 — 파랑으로 바꾸는 것은 플레이어와 목표뿐이다.
    expect(BoardColors.light.normalBlock, const Color(0xFF8598B8));
    expect(BoardColors.dark.normalBlock, const Color(0xFF4E5D78));
  });
}
