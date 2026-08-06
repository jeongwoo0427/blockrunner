import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen_event.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen_state.dart';
import 'package:blockrunner/feature/level/presentation/level_select/widget/level_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/strings_harness.dart';

/// 레벨 카드가 **순서대로 떠오른다.**
void main() {
  /// **트리 모양을 항상 같게 유지한다.** 감싸는 위젯이 달라지면 `State` 가
  /// 새로 만들어져서 "다시 재생되지 않는다" 를 검사할 수 없다 — 실제로 그랬다.
  Future<void> pump(
    WidgetTester tester, {
    bool reduced = false,
    int highestUnlocked = 0,
  }) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: withStrings(
          LevelSelectScreen(
            state: LevelSelectScreenState(
              levels: kLevels,
              highestUnlockedLevel: highestUnlocked == 0
                  ? kLevels.length
                  : highestUnlocked,
            ),
            onEvent: (LevelSelectScreenEvent _) {},
          ),
        ),
      ),
    );
  }

  /// 각 카드의 지금 투명도. `Opacity` 는 카드마다 하나씩 붙는다.
  List<double> opacities(WidgetTester tester) => [
    for (var i = 0; i < kLevels.length; i++)
      tester
          .widget<Opacity>(
            find
                .ancestor(
                  of: find.byType(LevelCard).at(i),
                  matching: find.byType(Opacity),
                )
                .first,
          )
          .opacity,
  ];

  /// 각 카드의 세로 위치.
  List<double> tops(WidgetTester tester) => [
    for (var i = 0; i < kLevels.length; i++)
      tester.getTopLeft(find.byType(LevelCard).at(i)).dy,
  ];

  testWidgets('처음에는 아무것도 안 보인다', (tester) async {
    await pump(tester);

    expect(opacities(tester).every((o) => o == 0), isTrue);
  });

  testWidgets('앞 카드가 먼저 나타난다', (tester) async {
    await pump(tester);
    await tester.pump(const Duration(milliseconds: 200));

    final shown = opacities(tester);

    // 한꺼번에 켜지면 전부 같은 값이라 순서가 읽히지 않는다.
    expect(shown.first, greaterThan(0));
    expect(shown.first, greaterThan(shown.last));
  });

  testWidgets('아래에서 떠오른다', (tester) async {
    // 투명도만 바꾸면 그냥 켜지는 것처럼 보인다.
    await pump(tester);
    final start = tops(tester);

    await tester.pumpAndSettle();
    final settled = tops(tester);

    for (var i = 0; i < start.length; i++) {
      expect(start[i], greaterThan(settled[i]), reason: '$i 번째가 안 올라왔다');
    }
  });

  testWidgets('끝나면 전부 제자리에 온전히 보인다', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();

    expect(opacities(tester).every((o) => o == 1), isTrue);
  });

  testWidgets('동작 줄이기를 켜면 그냥 놓여 있다', (tester) async {
    await pump(tester, reduced: true);

    // 첫 프레임부터 제자리다.
    final settled = tops(tester);
    await tester.pumpAndSettle();

    expect(tops(tester), settled);
  });

  testWidgets('상태가 바뀌어도 다시 재생되지 않는다', (tester) async {
    // 연출은 화면에 처음 왔을 때의 것이다. 상태가 바뀔 때마다 다시 돌면
    // 클리어하고 돌아올 때마다 목록이 깜박인다.
    await pump(tester);
    await tester.pumpAndSettle();

    await pump(tester, highestUnlocked: 1);
    await tester.pump();

    expect(opacities(tester).every((o) => o == 1), isTrue);
  });
}
