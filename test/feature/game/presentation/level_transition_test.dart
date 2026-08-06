import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/di/core_providers.dart';
import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/core/i18n/strings_catalog.dart';
import 'package:blockrunner/core/router/route_paths.dart';
import 'package:blockrunner/core/router/router.dart';
import 'package:blockrunner/feature/game/data/map_blueprints.dart';
import 'package:blockrunner/feature/game/data/map_parser.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_event.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_state.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_view.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:blockrunner/feature/level/presentation/level_select/widget/level_card.dart';
import 'package:blockrunner/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/strings_harness.dart';

/// 레벨 전환 — **몸통만 밀린다.**
///
/// 레벨 선택 → 플레이는 머티리얼 페이지 전환 그대로, 다음 레벨로 갈 때는
/// 화면 전체가 아니라 판과 HUD 만 넘어간다.
void main() {
  final parser = const MapParser();

  GamePlayScreenState stateOf(int levelNumber) {
    final map = parser.parse(
      kMapBlueprints.firstWhere((map) => map.levelNumber == levelNumber),
    );

    return GamePlayScreenState(
      level: kLevels.firstWhere((level) => level.number == levelNumber),
      map: map,
      board: map.initialBoard,
      hasNextLevel: true,
    );
  }

  Future<void> pumpLevel(WidgetTester tester, int levelNumber) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      withStrings(
        GamePlayScreen(
          state: stateOf(levelNumber),
          onEvent: (GamePlayScreenEvent _) {},
        ),
      ),
    );
  }

  group('몸통 전환', () {
    testWidgets('레벨이 바뀌면 두 판이 함께 그려진다', (tester) async {
      await pumpLevel(tester, 1);
      expect(find.byType(BoardView), findsOneWidget);

      await pumpLevel(tester, 2);
      await tester.pump(AppConstants.levelSlideDuration ~/ 2);

      // 나가는 판과 들어오는 판이 겹쳐 있어야 "넘어간다" 로 보인다.
      expect(find.byType(BoardView), findsNWidgets(2));
    });

    testWidgets('한쪽은 나가고 한쪽은 들어온다', (tester) async {
      await pumpLevel(tester, 1);
      final resting = tester.getTopLeft(find.byType(BoardView)).dx;

      await pumpLevel(tester, 2);
      await tester.pump(AppConstants.levelSlideDuration ~/ 2);

      final xs = [
        for (var i = 0; i < 2; i++)
          tester.getTopLeft(find.byType(BoardView).at(i)).dx,
      ];

      expect(xs.first, lessThan(resting), reason: '이전 판은 왼쪽으로 빠진다');
      expect(xs.last, greaterThan(resting), reason: '새 판은 오른쪽에서 들어온다');
    });

    testWidgets('끝나면 새 판만 제자리에 남는다', (tester) async {
      await pumpLevel(tester, 1);
      final resting = tester.getTopLeft(find.byType(BoardView)).dx;

      await pumpLevel(tester, 2);
      await tester.pumpAndSettle();

      expect(find.byType(BoardView), findsOneWidget);
      expect(tester.getTopLeft(find.byType(BoardView)).dx, closeTo(resting, 0.5));
    });

    testWidgets('AppBar 는 함께 밀리지 않는다', (tester) async {
      // 화면 전체가 밀리면 레벨 선택에서 들어올 때와 구분이 안 된다.
      await pumpLevel(tester, 1);
      final appBar = tester.getTopLeft(find.byType(AppBar));

      await pumpLevel(tester, 2);
      await tester.pump(AppConstants.levelSlideDuration ~/ 2);

      expect(tester.getTopLeft(find.byType(AppBar)), appBar);
    });

    testWidgets('동작 줄이기를 켜면 곧바로 바뀐다', (tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      Future<void> pumpReduced(int levelNumber) => tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: withStrings(
            GamePlayScreen(
              state: stateOf(levelNumber),
              onEvent: (GamePlayScreenEvent _) {},
            ),
          ),
        ),
      );

      await pumpReduced(1);
      await pumpReduced(2);
      await tester.pump(AppConstants.levelSlideDuration ~/ 2);

      expect(find.byType(BoardView), findsOneWidget);
    });
  });

  group('라우팅', () {
    Future<void> bootToLevel1(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'settings_v1_locale': 'ko',
        for (final level in kLevels) 'tutorial_seen_${level.number}': true,
      });
      final prefs = await SharedPreferences.getInstance();
      addTearDown(() => router.go(RoutePaths.splash));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const BlockRunnerApp(),
        ),
      );
      await tester.pump(AppConstants.splashDuration);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(LevelCard).first);
      await tester.pumpAndSettle();
    }

    testWidgets('레벨 선택에서 들어올 때는 페이지가 새로 열린다', (tester) async {
      // 그래야 머티리얼 전환이 그대로 난다.
      await bootToLevel1(tester);

      expect(find.byType(GamePlayScreen), findsOneWidget);
      expect(router.canPop(), isTrue, reason: '레벨 선택 위에 얹혀야 한다');
    });

    testWidgets('다음 레벨로 갈 때는 페이지가 갈리지 않는다', (tester) async {
      // **이것이 라우터에 고정 키를 준 이유다.** 페이지가 새로 열리면 화면
      // 전체가 밀려서, 레벨 선택에서 들어올 때와 구분이 안 된다.
      await bootToLevel1(tester);

      // 레벨 1은 오른쪽으로 한 번 밀면 클리어다.
      await tester.drag(find.byType(BoardView), const Offset(300, 0));
      await tester.pump();
      await tester.pump(AppConstants.moveAnimationDuration);
      await tester.pump(const Duration(seconds: 2)); // 별 연출

      await tester.tap(find.text(stringsFor(AppLocale.ko).nextLevel));
      await tester.pump();
      await tester.pump(AppConstants.levelSlideDuration ~/ 2);

      // 페이지가 갈렸다면 전환 중 두 개가 함께 있다.
      expect(find.byType(GamePlayScreen), findsOneWidget);
      // 대신 몸통만 둘이다.
      expect(find.byType(BoardView), findsNWidgets(2));
    });

    testWidgets('판을 밀어도 화면이 넘어가지 않는다', (tester) async {
      // **`PageView` 를 쓰지 않는 이유다.** 손으로 밀어서 레벨이 옮겨지면
      // 판 위의 스와이프가 이동인지 페이지 넘김인지 갈리지 않는다.
      await bootToLevel1(tester);
      final before = router.state.uri.toString();

      await tester.drag(find.byType(BoardView), const Offset(-300, 0));
      await tester.pump();
      await tester.pump(AppConstants.moveAnimationDuration);

      expect(router.state.uri.toString(), before);
      expect(find.text(stringsFor(AppLocale.ko).levelTitle(1)), findsOneWidget);
    });
  });
}
