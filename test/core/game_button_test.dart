import 'package:blockrunner/core/theme/data/light_theme.dart';
import 'package:blockrunner/core/widget/game_button.dart';
import 'package:blockrunner/core/widget/game_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 공용 버튼 (13-game-feel §3).
void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      theme: lightTheme,
      home: Scaffold(body: Center(child: child)),
    ),
  );

  /// 지금 그려진 버튼의 배율. 누름 반응을 재는 유일한 방법이다.
  double scaleOf(WidgetTester tester) =>
      tester.widget<AnimatedScale>(find.byType(AnimatedScale).first).scale;

  group('GameButton', () {
    testWidgets('누르면 콜백이 온다', (tester) async {
      var taps = 0;
      await pump(tester, GameButton(label: '시작', onPressed: () => taps++));

      await tester.tap(find.byType(GameButton));
      expect(taps, 1);
    });

    testWidgets('누르는 동안 줄어들었다 돌아온다', (tester) async {
      await pump(tester, GameButton(label: '시작', onPressed: () {}));
      expect(scaleOf(tester), 1);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(GameButton)),
      );
      await tester.pump();
      expect(scaleOf(tester), lessThan(1), reason: '눌린 것이 보여야 한다');

      await gesture.up();
      await tester.pumpAndSettle();
      expect(scaleOf(tester), 1);
    });

    testWidgets('비활성이면 눌러도 아무 일이 없다', (tester) async {
      // 별 연출이 끝나기 전의 "다음 레벨" 이 이 상태다 (§5).
      await pump(tester, const GameButton(label: '다음 레벨', onPressed: null));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(GameButton)),
      );
      await tester.pump();

      expect(scaleOf(tester), 1, reason: '눌린 반응조차 없어야 한다');
      await gesture.up();
    });

    testWidgets('모서리가 깎여 있고 테두리는 없다', (tester) async {
      // 카드와 같은 모양 언어를 쓴다는 것의 실질이다.
      //
      // **테두리를 두지 않는다** — 모양은 깎인 모서리가 만들고 구분은 채움색이
      // 한다. 선까지 두르면 요소마다 윤곽선이 겹쳐 화면이 복잡해진다.
      await pump(tester, GameButton(label: '시작', onPressed: () {}));

      final decoration =
          tester
                  .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                  .decoration
              as ShapeDecoration;
      final shape = decoration.shape as BeveledRectangleBorder;

      expect(shape, isA<BeveledRectangleBorder>());
      expect(shape.side.style, BorderStyle.none);
    });

    testWidgets('보조 버튼도 표면색과 다른 색을 갖는다', (tester) async {
      // 표면색 그대로면 버튼인지 아닌지 읽히지 않는다.
      await pump(tester, GameButton(label: '목록으로', onPressed: () {}));

      final decoration =
          tester
                  .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                  .decoration
              as ShapeDecoration;

      expect(decoration.color, isNot(lightTheme.colorScheme.surface));
    });

    testWidgets('긴 문구도 넘치지 않는다', (tester) async {
      // 프랑스어 `Recommencer` 가 좁은 자리에 들어간다.
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: SizedBox(
              width: 120,
              child: GameButton(label: 'Recommencer', onPressed: () {}),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('GameIconButton', () {
    testWidgets('툴팁이 곧 이름이다', (tester) async {
      // 아이콘만으로는 뜻이 전달되지 않는다. 화면 낭독기도 이것을 읽는다.
      await pump(
        tester,
        GameIconButton(
          icon: Icons.settings,
          onPressed: () {},
          tooltip: '설정',
        ),
      );

      expect(find.byTooltip('설정'), findsOneWidget);
    });

    testWidgets('누르면 콜백이 온다', (tester) async {
      var taps = 0;
      await pump(
        tester,
        GameIconButton(
          icon: Icons.arrow_back,
          onPressed: () => taps++,
          tooltip: '뒤로',
        ),
      );

      await tester.tap(find.byType(GameIconButton));
      expect(taps, 1);
    });
  });
}
