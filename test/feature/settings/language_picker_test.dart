import 'package:blockrunner/core/di/core_providers.dart';
import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/core/i18n/app_strings_scope.dart';
import 'package:blockrunner/core/i18n/strings_catalog.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_root.dart';
import 'package:blockrunner/feature/level/presentation/level_select/widget/level_card.dart';
import 'package:blockrunner/feature/settings/settings_di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 언어 선택은 **레벨 선택 화면의 아이콘 → 다이얼로그**다 (11-i18n §5).
/// 설정 화면을 따로 세우지 않았으므로 이 경로가 유일한 입구다.
void main() {
  late ProviderContainer container;

  Future<Widget> boot() async {
    SharedPreferences.setMockInitialValues({
      'settings_v1_locale': 'ko',
      // 튜토리얼은 이 테스트와 무관하다.
      for (var level = 1; level <= 7; level++) 'tutorial_seen_$level': true,
    });
    final prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    return UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) => AppStringsScope(
          strings: ref.watch(appStringsProvider),
          child: const MaterialApp(home: LevelSelectRoot()),
        ),
      ),
    );
  }

  testWidgets('아이콘을 누르면 지원 언어가 그 언어의 이름으로 뜬다', (tester) async {
    await tester.pumpWidget(await boot());
    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();

    for (final locale in AppLocale.values) {
      expect(
        find.text(locale.nativeName),
        findsOneWidget,
        reason: '${locale.code} 가 목록에 없다',
      );
    }
  });

  testWidgets('고르면 화면이 즉시 그 언어로 바뀐다', (tester) async {
    await tester.pumpWidget(await boot());
    expect(find.text(stringsFor(AppLocale.ko).levelSelectTitle), findsOneWidget);

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLocale.ja.nativeName));
    await tester.pumpAndSettle();

    // 화면을 나갔다 오지 않았는데 제목과 레벨 이름이 함께 바뀌어야 한다.
    expect(find.text(stringsFor(AppLocale.ja).levelSelectTitle), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(LevelCard),
        matching: find.text(stringsFor(AppLocale.ja).levelName(1)),
      ),
      findsOneWidget,
    );
  });

  testWidgets('고른 언어가 저장된다', (tester) async {
    await tester.pumpWidget(await boot());

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLocale.fr.nativeName));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('settings_v1_locale'), 'fr');
  });

  testWidgets('닫기만 하면 언어가 그대로다', (tester) async {
    await tester.pumpWidget(await boot());

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    // 다이얼로그 바깥을 눌러 닫는다.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(container.read(localeNotifierProvider), AppLocale.ko);
    expect(find.text(stringsFor(AppLocale.ko).levelSelectTitle), findsOneWidget);
  });
}
