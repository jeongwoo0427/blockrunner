import 'dart:ui';

import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/feature/settings/data/repository/settings_repository_impl.dart';
import 'package:blockrunner/feature/settings/domain/usecase/settings_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 언어 결정 규칙 (11-i18n §3):
///
/// ```
/// 저장된 선택이 있으면            → 그 언어
/// 없으면 기기 언어가 지원 목록에  → 그 언어
/// 그것도 아니면                   → ko
/// ```
void main() {
  Future<SettingsUsecases> usecasesWith({
    Map<String, Object> preferences = const {},
    List<Locale> device = const [Locale('en')],
  }) async {
    SharedPreferences.setMockInitialValues(preferences);

    return SettingsUsecases.fromRepositories(
      settingsRepository: SettingsRepositoryImpl(
        preferences: await SharedPreferences.getInstance(),
        deviceLocales: () => device,
      ),
    );
  }

  group('AppLocale.fromPlatform', () {
    test('지원하는 언어를 그대로 고른다', () {
      expect(AppLocale.fromPlatform([const Locale('ja')]), AppLocale.ja);
    });

    test('지역 코드가 붙어 있어도 언어 코드로 맞춘다', () {
      // 기기는 zh-Hans-CN · en-GB 처럼 준다. 통째로 비교하면 어느 것도 맞지
      // 않아 늘 ko 로 떨어진다 — 이 테스트가 그것을 막는다.
      expect(
        AppLocale.fromPlatform([const Locale('zh', 'CN')]),
        AppLocale.zh,
      );
      expect(
        AppLocale.fromPlatform([
          const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hans',
            countryCode: 'CN',
          ),
        ]),
        AppLocale.zh,
      );
    });

    test('앞에 있는 것이 사용자의 선호다', () {
      expect(
        AppLocale.fromPlatform([const Locale('fr'), const Locale('en')]),
        AppLocale.fr,
      );
    });

    test('지원하지 않는 언어는 건너뛴다', () {
      expect(
        AppLocale.fromPlatform([const Locale('de'), const Locale('ja')]),
        AppLocale.ja,
      );
    });

    test('하나도 지원하지 않으면 ko 다', () {
      expect(AppLocale.fromPlatform([const Locale('de')]), AppLocale.ko);
      expect(AppLocale.fromPlatform(const []), AppLocale.ko);
    });
  });

  group('GetLocaleUsecase', () {
    test('저장된 선택이 기기 언어를 이긴다', () async {
      final usecases = await usecasesWith(
        preferences: {'settings_v1_locale': 'fr'},
        device: [const Locale('ja')],
      );

      expect(usecases.getLocale(), AppLocale.fr);
    });

    test('저장된 것이 없으면 기기 언어를 따른다', () async {
      final usecases = await usecasesWith(device: [const Locale('ja')]);

      expect(usecases.getLocale(), AppLocale.ja);
    });

    test('저장값이 깨져 있으면 기기 언어로 떨어진다', () async {
      // 앱 버전이 내려가거나 손으로 건드린 경우다. 터지지는 않아야 한다.
      final usecases = await usecasesWith(
        preferences: {'settings_v1_locale': 'klingon'},
        device: [const Locale('fr')],
      );

      expect(usecases.getLocale(), AppLocale.fr);
    });
  });

  group('SaveLocaleUsecase', () {
    test('고른 언어가 저장되고 다시 읽힌다', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final usecases = SettingsUsecases.fromRepositories(
        settingsRepository: SettingsRepositoryImpl(
          preferences: preferences,
          deviceLocales: () => [const Locale('en')],
        ),
      );

      await usecases.saveLocale(AppLocale.zh);

      // 앱을 다시 켠 상황 — 저장소를 새로 만들어도 남아 있어야 한다.
      final rebooted = SettingsUsecases.fromRepositories(
        settingsRepository: SettingsRepositoryImpl(
          preferences: preferences,
          deviceLocales: () => [const Locale('en')],
        ),
      );

      expect(rebooted.getLocale(), AppLocale.zh);
    });

    test('진행도 키를 건드리지 않는다', () async {
      // 진행도와 설정은 지워지는 시점이 다르다. 접두사가 갈려 있어야 한다.
      SharedPreferences.setMockInitialValues({
        'progress_v2_level_1': '{"bestMoveCount": 1, "stars": 3}',
      });
      final preferences = await SharedPreferences.getInstance();
      final usecases = SettingsUsecases.fromRepositories(
        settingsRepository: SettingsRepositoryImpl(
          preferences: preferences,
          deviceLocales: () => [const Locale('en')],
        ),
      );

      await usecases.saveLocale(AppLocale.ja);

      expect(
        preferences.getString('progress_v2_level_1'),
        '{"bestMoveCount": 1, "stars": 3}',
      );
    });
  });
}
