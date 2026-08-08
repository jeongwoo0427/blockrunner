import 'dart:io';

import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/di/core_providers.dart';
import 'package:blockrunner/core/widget/game_button.dart';
import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/core/i18n/app_strings_scope.dart';
import 'package:blockrunner/core/i18n/strings_catalog.dart';
import 'package:blockrunner/feature/level/level_di.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_root.dart';
import 'package:blockrunner/feature/settings/settings_di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 진행도 초기화 (12-ui-polish §3).
void main() {
  late ProviderContainer container;

  /// 레벨 3까지 깼고 튜토리얼도 봤으며 언어는 일본어로 골라 둔 상태.
  Future<Widget> boot() async {
    SharedPreferences.setMockInitialValues({
      'settings_v1_locale': 'ja',
      'progress_v2_level_1': '{"bestMoveCount": 1, "stars": 3}',
      'progress_v2_level_2': '{"bestMoveCount": 2, "stars": 3}',
      'tutorial_seen_v2_1': true,
      'tutorial_seen_v2_3': true,
    });
    final prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    return UncontrolledProviderScope(
      container: container,
      // **Scope 가 `MaterialApp` 위에 있어야 한다.** 다이얼로그는 앱의 오버레이에
      // 뜨므로 `home` 아래에 두면 `context.strings` 를 못 찾는다. `main.dart` 도
      // 같은 순서다.
      child: AppStringsScope(
        strings: stringsFor(AppLocale.ja),
        child: const MaterialApp(home: LevelSelectRoot()),
      ),
    );
  }

  Future<void> openReset(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text(stringsFor(AppLocale.ja).resetProgress));
    await tester.pumpAndSettle();
  }

  testWidgets('바로 지우지 않고 한 번 더 묻는다', (tester) async {
    await tester.pumpWidget(await boot());
    await openReset(tester);

    // 되돌릴 수 없는 일이다.
    expect(
      find.text(stringsFor(AppLocale.ja).resetProgressWarning),
      findsOneWidget,
    );

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('progress_v2_level_1'), isNotNull);
  });

  testWidgets('취소하면 아무것도 지워지지 않는다', (tester) async {
    await tester.pumpWidget(await boot());
    await openReset(tester);

    await tester.tap(find.text(stringsFor(AppLocale.ja).cancel));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('progress_v2_level_1'), isNotNull);
    expect(prefs.getBool('tutorial_seen_v2_1'), isTrue);
  });

  testWidgets('확인하면 진행도와 튜토리얼이 함께 지워진다', (tester) async {
    await tester.pumpWidget(await boot());
    await openReset(tester);

    // 경고 다이얼로그의 확인 버튼.
    await tester.tap(
      find.widgetWithText(
        GameButton,
        stringsFor(AppLocale.ja).resetProgress,
      ),
    );
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('progress_v2_level_1'), isNull);
    expect(prefs.getString('progress_v2_level_2'), isNull);
    // 진행도만 지우면 레벨 1을 다시 깨도 안내가 안 뜬다 — "처음부터" 가 아니다.
    expect(prefs.getBool('tutorial_seen_v2_1'), isNull);
    expect(prefs.getBool('tutorial_seen_v2_3'), isNull);
  });

  testWidgets('언어 설정은 살아남는다', (tester) async {
    // 언어는 진행도가 아니라 취향이다. 그래서 저장소 접두사를 갈라 두었다.
    await tester.pumpWidget(await boot());
    await openReset(tester);

    await tester.tap(
      find.widgetWithText(
        GameButton,
        stringsFor(AppLocale.ja).resetProgress,
      ),
    );
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('settings_v1_locale'), 'ja');
    expect(container.read(localeNotifierProvider), AppLocale.ja);
  });

  testWidgets('지우고 나면 화면이 곧바로 처음 상태로 보인다', (tester) async {
    await tester.pumpWidget(await boot());
    expect(container.read(levelSelectScreenNotifierProvider).isUnlocked(3), isTrue);

    await openReset(tester);
    await tester.tap(
      find.widgetWithText(
        GameButton,
        stringsFor(AppLocale.ja).resetProgress,
      ),
    );
    await tester.pumpAndSettle();

    // 나갔다 들어오지 않아도 잠겨 있어야 한다.
    final state = container.read(levelSelectScreenNotifierProvider);
    expect(state.isUnlocked(2), isFalse);
    expect(state.progressOf(1), isNull);
    expect(
      find.text(stringsFor(AppLocale.ja).resetProgressDone),
      findsOneWidget,
    );
  });

  test('표시 버전이 pubspec 과 같다', () {
    // 상수만 두면 언젠가 어긋나고, 그때는 아무도 모른다.
    final pubspec = File('pubspec.yaml').readAsLinesSync();
    final line = pubspec.firstWhere((line) => line.startsWith('version:'));
    final declared = line.split(':')[1].trim().split('+').first;

    expect(AppConstants.appVersion, declared);
  });
}
