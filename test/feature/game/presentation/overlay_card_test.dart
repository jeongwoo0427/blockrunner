import 'package:blockrunner/core/theme/data/light_theme.dart';
import 'package:blockrunner/core/widget/game_button.dart';
import 'package:blockrunner/core/widget/overlay_transition.dart';
import 'package:blockrunner/feature/game/data/map_blueprints.dart';
import 'package:blockrunner/feature/game/data/map_parser.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_event.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_state.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
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

  testWidgets('카드는 각지고 옅은 테두리를 갖는다', (tester) async {
    // 버튼·레벨 카드와 같은 모양 언어를 쓰되, **카드에는 테두리가 있다** —
    // 표면색 위에 표면색으로 떠 있어서 윤곽이 없으면 경계가 흐릿하다.
    await pump(tester, resultOverlay());

    final shape =
        tester.widget<Card>(find.byType(Card)).shape
            as BeveledRectangleBorder;

    expect(shape.side.style, isNot(BorderStyle.none));
    // 시커먼 선이면 창틀처럼 무거워진다.
    expect(shape.side.color, lightTheme.colorScheme.outlineVariant);
  });

  testWidgets('블랙홀 결과에도 카드가 뜬다', (tester) async {
    await pump(tester, resultOverlay(isCleared: false));

    expect(find.byType(OverlayCard), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
  });

  group('등장·퇴장', () {
    // **연출은 화면이 몬다** — 사라지는 카드를 잠시 붙잡아 둘 수 있는 것은
    // 카드 자신이 아니라 띄운 쪽이다. 그래서 여기서는 실제 화면을 태운다.
    final map = const MapParser().parse(kMapBlueprints.first);

    Future<void> pumpScreen(WidgetTester tester, {required bool cleared}) {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      return tester.pumpWidget(
        withStrings(
          GamePlayScreen(
            state: GamePlayScreenState(
              level: kLevels.first,
              map: map,
              board: map.initialBoard,
              moveCount: 3,
              isCleared: cleared,
              hasNextLevel: true,
            ),
            onEvent: (GamePlayScreenEvent _) {},
          ),
        ),
      );
    }

    /// **렌더된 위젯이 아니라 애니메이션 값을 읽는다.**
    ///
    /// `Transform` 이나 `Opacity` 를 트리에서 찾으면 어느 것이 연출의 것인지
    /// 확신할 수 없다 — 실제로 엉뚱한 것을 잡아 몇 번 헤맸다.
    ///
    /// **키로 집는다.** `AnimatedScale` · `AnimatedOpacity` 가 안쪽에서 같은
    /// 위젯을 만들어 트리에 열 개 넘게 있다 — 타입으로 찾으면 별의 것을 잡는다.
    double cardScale(WidgetTester tester) =>
        tester.widget<ScaleTransition>(find.byKey(overlayCardKey)).scale.value;

    double cardFade(WidgetTester tester) => tester
        .widget<FadeTransition>(
          find
              .ancestor(
                of: find.byKey(overlayCardKey),
                matching: find.byType(FadeTransition),
              )
              .first,
        )
        .opacity
        .value;

    double scrimFade(WidgetTester tester) =>
        tester.widget<FadeTransition>(find.byKey(overlayScrimKey)).opacity.value;

    test('카드가 튕김을 보여줄 만큼 시간을 갖는다', () {
      // `elasticOut` 은 되튕기는 구간이 짧으면 그냥 커지기만 한 것처럼 보인다.
      // **하한만 둔다** — 정확한 값은 취향이지만 조용히 짧아지는 것은 막는다.
      final cardMs =
          overlayEntranceDuration.inMilliseconds * (1 - overlayScrimSplit);

      expect(cardMs, greaterThanOrEqualTo(400));

      // 배경은 반대로 짧아야 한다. 덮개가 늦게 깔리면 답답하다.
      final scrimMs =
          overlayEntranceDuration.inMilliseconds * overlayScrimSplit;

      expect(scrimMs, lessThan(cardMs));
    });

    test('작게 시작해서 1로 끝난다', () {
      // **곡선 자체를 검사한다.** 위젯으로 재면 프레임 타이밍에 걸린다 —
      // `elasticOut` 은 t=0.1 에서 이미 1을 지나므로 작게 보이는 구간이
      // 40ms 남짓이고, 첫 프레임이 그 안에 든다는 보장이 없다.
      expect(overlayScaleAt(overlayEnterCurve.transform(0)), lessThan(0.9));
      expect(overlayScaleAt(overlayEnterCurve.transform(1)), closeTo(1, 0.001));
    });

    testWidgets('들어올 때 카드가 1을 넘겼다 돌아온다', (tester) async {
      // 넘기지 않으면 그냥 커지기만 한 것이고, 그건 튕김이 아니다.
      await pumpScreen(tester, cleared: false);
      await pumpScreen(tester, cleared: true);

      var overshot = false;
      for (var i = 0; i < 40; i++) {
        await tester.pump(overlayEntranceDuration ~/ 40);
        if (find.byType(ScaleTransition).evaluate().isEmpty) continue;
        if (cardScale(tester) > 1.01) overshot = true;
      }

      expect(overshot, isTrue);
      await tester.pumpAndSettle();
      expect(cardScale(tester), closeTo(1, 0.001));
    });

    testWidgets('배경이 먼저 깔리고 카드가 뒤따른다', (tester) async {
      // 한꺼번에 뜨면 배경이 카드와 같은 물건처럼 보인다.
      await pumpScreen(tester, cleared: false);
      await pumpScreen(tester, cleared: true);
      await tester.pump(overlayEntranceDuration ~/ 4);

      expect(scrimFade(tester), greaterThan(0));
      expect(
        cardFade(tester),
        lessThan(scrimFade(tester)),
        reason: '배경이 앞선다',
      );
    });

    testWidgets('배경에는 배율이 걸리지 않는다', (tester) async {
      // 화면 전체를 덮는 것이 줄어들면 덮개가 아니라 또 하나의 카드로 보인다.
      await pumpScreen(tester, cleared: true);
      await tester.pumpAndSettle();

      // 스크림과 카드 배율 사이에 다른 배율이 끼어 있으면 안 된다.
      final between = find.ancestor(
        of: find.byKey(overlayCardKey),
        matching: find.byType(ScaleTransition),
      );

      expect(between, findsNothing);
    });

    testWidgets('사라질 때도 곧바로 없어지지 않는다', (tester) async {
      // 요청의 핵심 — 나가는 것도 보여야 한다.
      await pumpScreen(tester, cleared: true);
      await tester.pumpAndSettle();
      expect(find.byType(ResultOverlay), findsOneWidget);

      await pumpScreen(tester, cleared: false);
      await tester.pump(overlayExitDuration ~/ 2);

      expect(find.byType(ResultOverlay), findsOneWidget, reason: '아직 나가는 중이다');
      expect(cardScale(tester), lessThan(1), reason: '줄어들며 사라진다');
      expect(cardFade(tester), lessThan(1));
      expect(
        scrimFade(tester),
        1,
        reason: '카드가 먼저 사라지고 배경은 그대로 있다',
      );
    });

    testWidgets('카드가 먼저 사라지고 배경이 뒤따라 걷힌다', (tester) async {
      // 요청한 차례 — 카드 사라짐 → 배경 걷힘.
      await pumpScreen(tester, cleared: true);
      await tester.pumpAndSettle();

      await pumpScreen(tester, cleared: false);

      // 카드가 다 사라질 때까지 배경은 그대로다.
      await tester.pump(overlayExitDuration ~/ 2);
      expect(cardFade(tester), lessThan(1));
      expect(scrimFade(tester), 1);

      // 그 뒤에 배경이 걷힌다.
      await tester.pump(overlayExitDuration ~/ 2);
      expect(cardFade(tester), 0);
      expect(scrimFade(tester), lessThan(1));
    });

    testWidgets('다음 레벨은 카드가 사라진 뒤에 올라간다', (tester) async {
      // 먼저 보내면 카드가 사라지는 장면이 페이지 전환에 잘려 나간다.
      final events = <GamePlayScreenEvent>[];

      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        withStrings(
          GamePlayScreen(
            state: GamePlayScreenState(
              level: kLevels.first,
              map: map,
              board: map.initialBoard,
              moveCount: 3,
              isCleared: true,
              hasNextLevel: true,
            ),
            onEvent: events.add,
          ),
        ),
      );
      await tester.pumpAndSettle();
      // 별 연출이 끝나야 다음 레벨이 열린다.
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.text('다음 레벨'));
      await tester.pump();

      expect(events, isEmpty, reason: '아직 카드가 사라지는 중이다');

      // 레벨 1은 블랙홀도 튜토리얼도 없어 `pumpAndSettle` 이 끝난다.
      await tester.pumpAndSettle();

      expect(events.whereType<NextLevelRequested>(), hasLength(1));
    });

    testWidgets('다음을 눌러 넘어간 레벨의 튜토리얼이 뜬다', (tester) async {
      // **레벨 3에서 실제로 났던 버그다.** 결과 카드를 닫고 다음 레벨로 가면
      // 곧바로 튜토리얼이 뜨는데, 둘 다 "오버레이 있음" 이라 등장 연출이
      // 시작되지 않았다. 화면에는 아무것도 없는데 `showsTutorial` 은 참이라
      // **입력이 영영 막혔다.**
      //
      // 재현하려면 **다음 버튼을 눌러 닫는 경로**를 그대로 타야 한다 —
      // 상태만 갈아끼우면 진행도가 1 에 머물러 있어 버그가 드러나지 않는다.
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      Future<void> pumpState(GamePlayScreenState state) => tester.pumpWidget(
        withStrings(
          GamePlayScreen(state: state, onEvent: (GamePlayScreenEvent _) {}),
        ),
      );

      // 레벨 2를 깬 상태 — 결과 카드가 떠 있다.
      await pumpState(
        GamePlayScreenState(
          level: kLevels[1],
          map: map,
          board: map.initialBoard,
          moveCount: 3,
          isCleared: true,
          hasNextLevel: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2)); // 별 연출

      await tester.tap(find.text('다음 레벨'));
      await tester.pumpAndSettle();

      // 이제 다음 레벨(3번)로 넘어간다 — 이 레벨은 튜토리얼을 갖는다.
      await pumpState(
        GamePlayScreenState(
          level: kLevels[2],
          map: map,
          board: map.initialBoard,
          showsTutorial: true,
        ),
      );
      await tester.pump();
      await tester.pump(overlayEntranceDuration);

      expect(find.byType(TutorialOverlay), findsOneWidget);
      expect(scrimFade(tester), greaterThan(0), reason: '보이지 않으면 입력만 막힌다');
      expect(cardFade(tester), greaterThan(0));
    });

    testWidgets('다 나가면 트리에서 빠진다', (tester) async {
      await pumpScreen(tester, cleared: true);
      await tester.pumpAndSettle();

      await pumpScreen(tester, cleared: false);
      await tester.pumpAndSettle();

      expect(find.byType(ResultOverlay), findsNothing);
    });

    testWidgets('나가는 중에는 버튼이 눌리지 않는다', (tester) async {
      // 이미 닫힌 카드의 버튼이 먹으면 두 번 눌린 것처럼 동작한다.
      await pumpScreen(tester, cleared: true);
      await tester.pumpAndSettle();

      await pumpScreen(tester, cleared: false);
      await tester.pump(overlayExitDuration ~/ 2);

      final ignoring = tester
          .widgetList<IgnorePointer>(
            find.ancestor(
              of: find.byType(ResultOverlay),
              matching: find.byType(IgnorePointer),
            ),
          )
          .any((widget) => widget.ignoring);

      expect(ignoring, isTrue);
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
