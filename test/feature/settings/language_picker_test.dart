import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/di/core_providers.dart';
import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/core/i18n/app_strings_scope.dart';
import 'package:blockrunner/core/i18n/strings_catalog.dart';
import 'package:blockrunner/core/widget/overlay_transition.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_root.dart';
import 'package:blockrunner/feature/level/presentation/level_select/widget/level_card.dart';
import 'package:blockrunner/feature/settings/presentation/language_picker/language_picker_dialog.dart';
import 'package:blockrunner/feature/settings/settings_di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 언어 선택은 **레벨 선택 화면의 톱니바퀴 → 설정 → 언어**다 (12-ui-polish §3).
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

  /// 톱니바퀴 → 설정 → 언어 까지 연다.
  Future<void> openLanguages(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
  }

  testWidgets('설정을 열면 언어와 초기화, 버전이 보인다', (tester) async {
    await tester.pumpWidget(await boot());
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    final strings = stringsFor(AppLocale.ko);
    expect(find.text(strings.language), findsOneWidget);
    expect(find.text(strings.resetProgress), findsOneWidget);
    expect(find.text(strings.version), findsOneWidget);
    expect(find.text(AppConstants.appVersion), findsOneWidget);
    // 지금 언어가 그 언어의 이름으로 보인다.
    expect(find.text(AppLocale.ko.nativeName), findsOneWidget);
  });

  testWidgets('언어를 열면 지원 언어가 그 언어의 이름으로 뜬다', (tester) async {
    await tester.pumpWidget(await boot());
    await openLanguages(tester);

    for (final locale in AppLocale.values) {
      // 설정 다이얼로그가 뒤에 남아 지금 언어 이름을 하나 더 갖고 있다.
      // 목록 안으로 좁혀서 센다.
      expect(
        find.descendant(
          of: find.byType(LanguagePickerDialog),
          matching: find.text(locale.nativeName),
        ),
        findsOneWidget,
        reason: '${locale.code} 가 목록에 없다',
      );
    }
  });

  testWidgets('고르면 화면이 즉시 그 언어로 바뀐다', (tester) async {
    await tester.pumpWidget(await boot());
    expect(find.text(stringsFor(AppLocale.ko).levelSelectTitle), findsOneWidget);

    await openLanguages(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(LanguagePickerDialog),
        matching: find.text(AppLocale.ja.nativeName),
      ),
    );
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

    await openLanguages(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(LanguagePickerDialog),
        matching: find.text(AppLocale.fr.nativeName),
      ),
    );
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('settings_v1_locale'), 'fr');
  });

  testWidgets('닫기만 하면 언어가 그대로다', (tester) async {
    await tester.pumpWidget(await boot());

    await openLanguages(tester);
    // 다이얼로그 바깥을 눌러 닫는다.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(container.read(localeNotifierProvider), AppLocale.ko);
    expect(find.text(stringsFor(AppLocale.ko).levelSelectTitle), findsOneWidget);
  });

  group('연출 (13-game-feel §4)', () {
    /// 다이얼로그도 **판 위 오버레이와 같은 것**을 탄다. 예전에는 이쪽만
    /// 곡선을 통째로 적용해서 카드가 배경과 동시에 뜨고 나갈 때도 튕겼다 —
    /// 튜토리얼과 나란히 놓고 보면 어색했다.
    double cardScale(WidgetTester tester) =>
        tester.widget<ScaleTransition>(find.byKey(overlayCardKey)).scale.value;

    testWidgets('열릴 때 카드가 배경보다 늦게 뜬다', (tester) async {
      await tester.pumpWidget(await boot());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();
      // 배경이 깔리는 구간에서는 카드가 아직 작다.
      await tester.pump(overlayEntranceDuration ~/ 4);

      expect(cardScale(tester), lessThan(1));
    });

    testWidgets('닫힐 때는 튕기지 않는다', (tester) async {
      await tester.pumpWidget(await boot());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(cardScale(tester), closeTo(1, 0.001));

      // 바깥을 눌러 닫는다.
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pump(overlayEntranceDuration ~/ 3);

      // 되튕김이 있으면 1을 넘어간다.
      expect(cardScale(tester), lessThanOrEqualTo(1));
    });

    testWidgets('다이얼로그도 옅은 테두리를 갖는다', (tester) async {
      await tester.pumpWidget(await boot());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      final shape =
          tester.widget<SimpleDialog>(find.byType(SimpleDialog)).shape
              as BeveledRectangleBorder;

      expect(shape.side.style, isNot(BorderStyle.none));
    });
  });
}
