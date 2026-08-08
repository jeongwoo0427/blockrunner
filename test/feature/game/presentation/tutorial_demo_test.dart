import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/black_hole_painter.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/block_tile.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/tutorial_demo_view.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/tutorial_overlay.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:blockrunner/feature/level/domain/entity/tutorial_demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/strings_harness.dart';

/// 튜토리얼 상단 데모 (13-game-feel §6).
///
/// **`pumpAndSettle` 을 쓰지 않는다.** 데모는 끝없이 반복하므로 영원히
/// 끝나지 않는다 — 블랙홀 회전과 같은 함정이다.
void main() {
  Future<void> pumpDemo(WidgetTester tester, TutorialDemo demo) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      withStrings(Center(child: SizedBox(width: 240, child: TutorialDemoView(demo: demo)))),
    );
  }

  /// 지금 그려진 블록들의 가로 위치.
  List<double> blockXs(WidgetTester tester) => tester
      .widgetList<BlockTile>(find.byType(BlockTile))
      .toList()
      .asMap()
      .keys
      .map((i) => tester.getTopLeft(find.byType(BlockTile).at(i)).dx)
      .toList();

  group('장면', () {
    for (final demo in TutorialDemo.values) {
      testWidgets('${demo.name} — 블록이 실제로 움직인다', (tester) async {
        await pumpDemo(tester, demo);

        final start = blockXs(tester);
        // 미끄러지는 구간 한가운데.
        await tester.pump(TutorialDemoView.cycle ~/ 2);
        final mid = blockXs(tester);

        expect(start, isNotEmpty);
        expect(
          mid.first,
          greaterThan(start.first),
          reason: '움직이지 않으면 규칙을 보여주지 못한다',
        );
      });
    }

    testWidgets('동료 블록 데모는 블록이 둘이다', (tester) async {
      // 하나만 나오면 "다른 블록이 막는다" 가 보이지 않는다.
      await pumpDemo(tester, TutorialDemo.blockBrake);

      expect(find.byType(BlockTile), findsNWidgets(2));
    });

    testWidgets('블랙홀 장면은 블록과 구멍이 함께 사라진다', (tester) async {
      await pumpDemo(tester, TutorialDemo.blackHole);

      double scale() => tester
          .widget<AnimatedScale>(find.byType(AnimatedScale).first)
          .scale;

      BlackHolePainter hole() =>
          tester
                  .widget<CustomPaint>(
                    find.byWidgetPredicate(
                      (w) => w is CustomPaint && w.painter is BlackHolePainter,
                    ),
                  )
                  .painter
              as BlackHolePainter;

      expect(scale(), 1);
      expect(hole().vanishProgress, 0);
      // 사라질 구멍을 판에서 다시 찾지 않고 블록이 멈추는 자리로 안다.
      expect(hole().vanishing, {const Position(0, 2)});

      // 도착 지점을 지나면 빨려 들어간다.
      await tester.pump(TutorialDemoView.cycle ~/ 2);
      await tester.pump(TutorialDemoView.cycle ~/ 4);

      // **구멍이 남으면 규칙의 절반만 가르치는 셈이다** (기획서 §3.3).
      expect(scale(), 0);
      expect(hole().vanishProgress, 1);
    });
  });

  group('크기', () {
    testWidgets('높이가 묶여 있어도 폭을 채운다', (tester) async {
      // **이것이 실제로 깨졌던 조건이다.** 높이가 무제한이면 `fit` 과
      // `fitWidth` 가 같은 값을 내서 차이가 드러나지 않는다 — 처음 짠 테스트가
      // 그래서 교란을 잡지 못했다.
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        withStrings(
          const Center(
            child: SizedBox(
              width: 240,
              height: 60,
              child: TutorialDemoView(demo: TutorialDemo.slide),
            ),
          ),
        ),
      );

      final cell = tester.getSize(find.byType(BlockTile).first).width;

      // 폭을 나눠 가지면 46 안팎, 높이에 눌리면 12 남짓이다.
      expect(cell, greaterThan(30));
    });

    testWidgets('칸이 폭을 나눠 가진다', (tester) async {
      // `BoardMetrics.fit` 은 짧은 변에 맞추므로 한 줄짜리 판을 주면 높이에
      // 눌려 아주 작아지고 왼쪽에 붙는다 — 실제로 그렇게 나왔다.
      //
      // **바깥 상자를 재면 안 된다.** 부모가 240 으로 묶어 두므로 안쪽이
      // 아무리 작아도 240 이 나온다 — 실패할 수 없는 테스트가 된다.
      // 실제로 그려지는 칸 크기를 본다.
      await pumpDemo(tester, TutorialDemo.slide);

      final cell = tester.getSize(find.byType(BlockTile).first).width;

      // 5칸이 240 을 나눠 가지면 한 칸이 46 안팎이다.
      // 높이에 눌리면 12 남짓으로 떨어진다.
      expect(cell, greaterThan(30));
      expect(cell, closeTo(240 / 5.2, 1));
    });

    testWidgets('판이 상자를 가로로 채운다', (tester) async {
      await pumpDemo(tester, TutorialDemo.slide);

      // 첫 칸의 왼쪽 끝이 상자 왼쪽에 거의 붙어 있어야 한다(외곽 여백만큼만).
      final demoLeft = tester.getRect(find.byType(TutorialDemoView)).left;
      final firstBlockLeft = tester.getRect(find.byType(BlockTile).first).left;

      expect(firstBlockLeft - demoLeft, lessThan(20));
    });
  });

  group('반복', () {
    testWidgets('한 바퀴 뒤 처음 자리로 돌아온다', (tester) async {
      await pumpDemo(tester, TutorialDemo.slide);

      final start = blockXs(tester);
      await tester.pump(TutorialDemoView.cycle);

      expect(blockXs(tester).first, closeTo(start.first, 0.5));
    });

    testWidgets('동작 줄이기를 켜면 멈춰 있다', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: withStrings(
            const Center(
              child: SizedBox(
                width: 240,
                child: TutorialDemoView(demo: TutorialDemo.slide),
              ),
            ),
          ),
        ),
      );

      final start = blockXs(tester);
      await tester.pump(TutorialDemoView.cycle ~/ 2);

      expect(blockXs(tester), start);
    });
  });

  group('붙는 자리', () {
    testWidgets('데모가 문구보다 위에 있다', (tester) async {
      // 말보다 먼저 보여준다.
      await tester.pumpWidget(
        withStrings(
          const TutorialOverlay(
            title: '미끄러지기',
            body: '블록은 벽에 닿을 때까지 미끄러진다.',
            showsControls: false,
            onDismiss: _noop,
            demo: TutorialDemo.slide,
          ),
        ),
      );

      expect(
        tester.getTopLeft(find.byType(TutorialDemoView)).dy,
        lessThan(tester.getTopLeft(find.text('미끄러지기')).dy),
      );
    });

    testWidgets('데모가 없으면 그리지 않는다', (tester) async {
      await tester.pumpWidget(
        withStrings(
          const TutorialOverlay(
            title: '벽에 기대어',
            body: '문구만 있는 경우',
            showsControls: false,
            onDismiss: _noop,
          ),
        ),
      );

      expect(find.byType(TutorialDemoView), findsNothing);
    });
  });

  test('안내가 있는 레벨은 모두 데모를 갖는다', () {
    // `demo` 가 곧 "안내가 있다" 이므로 둘이 어긋날 수 없다 — 그 사실을 못박는다.
    for (final level in kLevels) {
      expect(level.hasTutorial, level.demo != null);
    }

    expect(
      kLevels.where((level) => level.demo != null).map((level) => level.demo),
      containsAll(TutorialDemo.values),
      reason: '쓰이지 않는 데모가 있으면 만들 이유가 없다',
    );
  });
}

void _noop() {}
