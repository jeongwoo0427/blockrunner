import 'dart:ui';

import 'package:blockrunner/core/di/core_providers.dart';
import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/core/i18n/strings_en.dart';
import 'package:blockrunner/core/i18n/strings_ja.dart';
import 'package:blockrunner/core/i18n/strings_ko.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen_event.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen_state.dart';
import 'package:blockrunner/feature/settings/data/repository/settings_repository_impl.dart';
import 'package:blockrunner/feature/settings/settings_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/strings_harness.dart';

void main() {
  group('화면이 주어진 언어로 그려진다', () {
    final state = LevelSelectScreenState(
      levels: kLevels,
      highestUnlockedLevel: kLevels.length,
    );

    Future<void> pumpIn(WidgetTester tester, dynamic strings) => tester
        .pumpWidget(
          withStrings(
            LevelSelectScreen(
              state: state,
              onEvent: (LevelSelectScreenEvent _) {},
            ),
            strings: strings,
          ),
        );

    testWidgets('영어', (tester) async {
      await pumpIn(tester, const StringsEn());

      expect(find.text('Levels'), findsOneWidget);
      expect(find.text('Sliding'), findsOneWidget);
      expect(find.text('레벨 선택'), findsNothing);
    });

    testWidgets('일본어', (tester) async {
      await pumpIn(tester, const StringsJa());

      expect(find.text('レベル選択'), findsOneWidget);
      expect(find.text('すべる'), findsOneWidget);
    });

    testWidgets('언어를 바꾸면 같은 화면이 다른 문구로 다시 그려진다', (tester) async {
      await pumpIn(tester, const StringsKo());
      expect(find.text('레벨 선택'), findsOneWidget);

      await pumpIn(tester, const StringsEn());

      // Scope 값만 바뀌었는데 아래가 전부 다시 그려져야 한다.
      expect(find.text('Levels'), findsOneWidget);
      expect(find.text('레벨 선택'), findsNothing);
    });
  });

  group('LocaleNotifier', () {
    late ProviderContainer container;

    Future<ProviderContainer> boot({
      Map<String, Object> preferences = const {},
      List<Locale> device = const [Locale('en')],
    }) async {
      SharedPreferences.setMockInitialValues(preferences);
      final prefs = await SharedPreferences.getInstance();

      return ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(
            SettingsRepositoryImpl(
              preferences: prefs,
              deviceLocales: () => device,
            ),
          ),
        ],
      );
    }

    tearDown(() => container.dispose());

    test('처음 값은 해석 규칙을 따른다', () async {
      container = await boot(device: [const Locale('fr')]);

      expect(container.read(localeNotifierProvider), AppLocale.fr);
    });

    test('언어를 바꾸면 문구도 함께 바뀐다', () async {
      container = await boot();
      expect(container.read(appStringsProvider).reset, const StringsEn().reset);

      await container.read(localeNotifierProvider.notifier).change(AppLocale.ja);

      // 이 단언이 `appStringsProvider` 가 ref.watch 인 이유다.
      // ref.read 였다면 처음 언어에 고정돼 여기서 실패한다.
      expect(container.read(appStringsProvider).reset, const StringsJa().reset);
    });

    test('바꾼 언어가 저장된다', () async {
      container = await boot();

      await container.read(localeNotifierProvider.notifier).change(AppLocale.zh);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('settings_v1_locale'), 'zh');
    });
  });
}
