import 'package:blockrunner/core/widget/game_button.dart';
import 'package:blockrunner/core/widget/overlay_transition.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/overlay_card.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/result_overlay.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/tutorial_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/strings_harness.dart';

/// 결과·튜토리얼은 **같은 카드를 쓴다** (12-ui-polish §6).
void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(withStrings(Stack(children: [child])));
    await tester.pumpAndSettle();
  }

  Widget resultOverlay({bool isCleared = true}) => ResultOverlay(
    isCleared: isCleared,
    moveCount: 3,
    minMoves: 2,
    stars: 2,
    hasNextLevel: true,
    onReset: () {},
    onNextLevel: () {},
    onBackToLevelSelect: () {},
  );

  Widget tutorialOverlay() => TutorialOverlay(
    title: '미끄러지기',
    body: '블록은 벽이나 판 끝에 닿을 때까지 미끄러진다.',
    showsControls: true,
    onDismiss: () {},
  );

  testWidgets('결과가 OverlayCard 를 쓴다', (tester) async {
    await pump(tester, resultOverlay());

    expect(find.byType(OverlayCard), findsOneWidget);
  });

  testWidgets('튜토리얼도 같은 OverlayCard 를 쓴다', (tester) async {
    // 둘은 같은 종류의 레이어다. 하나만 카드가 되면 어긋나 보인다.
    await pump(tester, tutorialOverlay());

    expect(find.byType(OverlayCard), findsOneWidget);
  });

  testWidgets('카드가 화면 전체를 채우지 않는다', (tester) async {
    // "딱 글자와 별, 버튼이 차지하는 만큼만" 이 요청의 핵심이다.
    await pump(tester, resultOverlay());

    final card = tester.getSize(find.byType(Card));

    expect(card.width, lessThan(390));
    expect(card.height, lessThan(844 / 2), reason: '내용만 감싸야 한다');
  });

  testWidgets('스크림이 화면을 덮어 뒤 판과 글자를 갈라놓는다', (tester) async {
    // 카드만 있고 스크림이 없으면 예전처럼 글자가 판에 묻힌다.
    await pump(tester, resultOverlay());

    expect(
      tester.getSize(find.byType(OverlayCard)),
      const Size(390, 844),
    );
  });

  testWidgets('카드도 각져 있다', (tester) async {
    // 버튼·레벨 카드와 같은 모양 언어를 쓴다.
    await pump(tester, resultOverlay());

    expect(
      tester.widget<Card>(find.byType(Card)).shape,
      isA<BeveledRectangleBorder>(),
    );
  });

  testWidgets('블랙홀 결과에도 카드가 뜬다', (tester) async {
    await pump(tester, resultOverlay(isCleared: false));

    expect(find.byType(OverlayCard), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
  });

  group('등장 (13-game-feel §4)', () {
    /// 지금 그려진 카드의 배율.
    ///
    /// **키로 집는다.** 트리에 `Transform` 이 여럿이라 위치로 찾으면 엉뚱한
    /// 것을 잡는다 — 실제로 `.first` 가 카드가 아니었다.
    double scaleOf(WidgetTester tester) => tester
        .widget<Transform>(find.byKey(overlayScaleKey))
        .transform
        .getMaxScaleOnAxis();

    test('작게 시작해서 1로 끝난다', () {
      // **곡선 자체를 검사한다.** 위젯으로 재면 프레임 타이밍에 걸린다 —
      // `elasticOut` 은 t=0.1 에서 이미 1을 지나므로 작게 보이는 구간이
      // 40ms 남짓이고, 첫 프레임이 그 안에 든다는 보장이 없다.
      expect(overlayScaleAt(0), lessThan(0.9));
      expect(overlayScaleAt(1), closeTo(1, 0.001));
    });

    testWidgets('도중에 1을 넘겼다 돌아온다', (tester) async {
      // 넘기지 않으면 그냥 커지기만 한 것이고, 그건 튕김이 아니다.
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(withStrings(Stack(children: [resultOverlay()])));

      var overshot = false;
      for (var i = 0; i < 30; i++) {
        await tester.pump(overlayEntranceDuration ~/ 30);
        if (scaleOf(tester) > 1.01) overshot = true;
      }

      expect(overshot, isTrue);

      await tester.pumpAndSettle();
      expect(scaleOf(tester), closeTo(1, 0.001));
    });

    testWidgets('스크림도 함께 어두워진다', (tester) async {
      // 배경만 즉시 깔리면 카드가 튀어나오기 전에 화면이 먼저 죽는다.
      await tester.pumpWidget(withStrings(Stack(children: [resultOverlay()])));

      Color scrim() => tester
          .widget<ColoredBox>(
            find
                .descendant(
                  of: find.byType(OverlayCard),
                  matching: find.byType(ColoredBox),
                )
                .first,
          )
          .color;

      final first = scrim().a;
      await tester.pump(overlayEntranceDuration ~/ 2);

      expect(scrim().a, greaterThan(first));
    });
  });

  group('별 등장 (13-game-feel §5)', () {
    /// 지금 실제로 보이는 별 개수 — 배율이 0 이면 자리만 잡고 있는 것이다.
    int visibleStars(WidgetTester tester) => tester
        .widgetList<AnimatedScale>(
          find.ancestor(
            of: find.byIcon(Icons.star_rounded),
            matching: find.byType(AnimatedScale),
          ),
        )
        .where((scale) => scale.scale > 0)
        .length;

    /// 다음 레벨 버튼이 눌리는 상태인가.
    bool nextEnabled(WidgetTester tester) =>
        tester
            .widget<GameButton>(find.widgetWithText(GameButton, '다음 레벨'))
            .onPressed !=
        null;

    Future<void> pumpCleared(WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        withStrings(Stack(children: [resultOverlay(isCleared: true)])),
      );
    }

    testWidgets('처음에는 별이 하나도 안 보인다', (tester) async {
      await pumpCleared(tester);

      expect(visibleStars(tester), 0);
    });

    testWidgets('하나씩 늘어난다', (tester) async {
      await pumpCleared(tester);

      final counts = <int>[];
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 240));
        counts.add(visibleStars(tester));
      }

      // 한꺼번에 나오면 [2,2,2,2] 처럼 평평해진다.
      expect(counts.first, lessThan(counts.last));
      expect(counts, orderedEquals([1, 2, 2, 2]));
    });

    testWidgets('연출이 끝나기 전에는 다음 레벨이 비활성이다', (tester) async {
      // 요청의 핵심이다.
      await pumpCleared(tester);
      expect(nextEnabled(tester), isFalse);

      await tester.pump(const Duration(milliseconds: 240));
      expect(nextEnabled(tester), isFalse, reason: '아직 별이 남았다');

      await tester.pumpAndSettle();
      expect(nextEnabled(tester), isTrue);
    });

    testWidgets('목록으로·다시하기는 처음부터 열려 있다', (tester) async {
      // 별을 다 보지 않고 나갈 자유는 남긴다.
      await pumpCleared(tester);

      for (final label in ['목록으로', '다시하기']) {
        expect(
          tester
              .widget<GameButton>(find.widgetWithText(GameButton, label))
              .onPressed,
          isNotNull,
          reason: '$label 이 잠겨 있으면 안 된다',
        );
      }
    });

    testWidgets('실패 카드에는 별도 지연도 없다', (tester) async {
      // 별이 없는데 기다릴 이유가 없다. 다음 레벨 버튼도 아예 그리지 않으므로
      // "연출이 끝나야 열린다" 는 규칙이 여기까지 새어 나오지 않는다.
      await tester.pumpWidget(
        withStrings(Stack(children: [resultOverlay(isCleared: false)])),
      );

      expect(find.byIcon(Icons.star_rounded), findsNothing);
      expect(find.widgetWithText(GameButton, '다음 레벨'), findsNothing);
      expect(
        tester
            .widget<GameButton>(find.widgetWithText(GameButton, '다시하기'))
            .onPressed,
        isNotNull,
      );
    });
  });
}
