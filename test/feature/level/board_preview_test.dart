import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/di/core_providers.dart';
import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/core/i18n/app_strings_scope.dart';
import 'package:blockrunner/core/i18n/strings_catalog.dart';
import 'package:blockrunner/core/router/route_paths.dart';
import 'package:blockrunner/core/router/router.dart';
import 'package:blockrunner/feature/game/presentation/board_preview/board_preview.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_preview_painter.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_root.dart';
import 'package:blockrunner/feature/level/presentation/level_select/widget/level_card.dart';
import 'package:blockrunner/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 레벨 카드의 미니 보드 (12-ui-polish §2).
///
/// **조립은 라우터가 한다.** 아래 대부분은 그 배선을 흉내 내지만, 마지막
/// 하나는 **진짜 라우터를 태운다** — 흉내만 내면 라우터가 잘못 이어져 있어도
/// 통과한다(실제로 그런 상태를 만들어 확인했다). `level` 이 `game` 을 직접
/// 부르지 않는다는 것은 `no_game_dependency_test` 가 지킨다.
void main() {
  Future<Widget> boot({int clearedUpTo = 0}) async {
    SharedPreferences.setMockInitialValues({
      'settings_v1_locale': 'ko',
      for (var level = 1; level <= clearedUpTo; level++)
        'progress_v1_level_$level': '{"bestMoveCount": 1, "stars": 3}',
    });
    final prefs = await SharedPreferences.getInstance();

    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: AppStringsScope(
        strings: stringsFor(AppLocale.ko),
        child: MaterialApp(
          home: LevelSelectRoot(
            // 라우터가 하는 것과 같은 조립.
            previewBuilder: (context, levelNumber, isUnlocked) => BoardPreview(
              levelNumber: levelNumber,
              isSilhouette: !isUnlocked,
            ),
          ),
        ),
      ),
    );
  }

  List<BoardPreviewPainter> paintersOf(WidgetTester tester) => tester
      .widgetList<CustomPaint>(
        find.descendant(
          of: find.byType(BoardPreview),
          matching: find.byType(CustomPaint),
        ),
      )
      .map((paint) => paint.painter)
      .whereType<BoardPreviewPainter>()
      .toList();

  testWidgets('카드마다 미니 보드가 그려진다', (tester) async {
    await tester.pumpWidget(await boot());
    await tester.pumpAndSettle();

    expect(find.byType(LevelCard), findsNWidgets(kLevels.length));
    expect(paintersOf(tester), hasLength(kLevels.length));
  });

  testWidgets('레벨마다 다른 판을 그린다', (tester) async {
    await tester.pumpWidget(await boot());
    await tester.pumpAndSettle();

    final boards = paintersOf(tester).map((painter) => painter.board).toList();

    // 같은 판을 7번 그리고 있으면 미리보기가 레벨과 이어지지 않은 것이다.
    expect(boards.toSet(), hasLength(kLevels.length));
  });

  testWidgets('잠긴 레벨은 실루엣이다', (tester) async {
    // 판 모양이 곧 스포일러다 — 이름을 가린 것과 같은 이유다.
    await tester.pumpWidget(await boot());
    await tester.pumpAndSettle();

    final painters = paintersOf(tester);

    expect(painters.first.isSilhouette, isFalse, reason: '1번은 열려 있다');
    expect(
      painters.skip(1).every((painter) => painter.isSilhouette),
      isTrue,
      reason: '나머지는 전부 잠겨 있다',
    );
  });

  testWidgets('깨면 그 레벨의 판이 드러난다', (tester) async {
    await tester.pumpWidget(await boot(clearedUpTo: 2));
    await tester.pumpAndSettle();

    final painters = paintersOf(tester);

    // 1·2번을 깼으므로 3번까지 열린다.
    expect(painters[0].isSilhouette, isFalse);
    expect(painters[1].isSilhouette, isFalse);
    expect(painters[2].isSilhouette, isFalse);
    expect(painters[3].isSilhouette, isTrue);
  });

  testWidgets('진짜 라우터를 태워도 잠긴 레벨은 실루엣이다', (tester) async {
    // 위 테스트들은 previewBuilder 를 직접 넣으므로 라우터가 어떻게 잇든
    // 통과한다. 배선 자체를 검사하는 것은 이 하나뿐이다.
    SharedPreferences.setMockInitialValues({'settings_v1_locale': 'ko'});
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

    final painters = paintersOf(tester);

    expect(painters, hasLength(kLevels.length));
    expect(painters.first.isSilhouette, isFalse);
    expect(
      painters.skip(1).every((painter) => painter.isSilhouette),
      isTrue,
      reason: '라우터가 isUnlocked 를 넘기지 않고 있다',
    );
  });
}
