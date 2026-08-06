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

  testWidgets('블랙홀 결과에도 카드가 뜬다', (tester) async {
    await pump(tester, resultOverlay(isCleared: false));

    expect(find.byType(OverlayCard), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
  });
}
