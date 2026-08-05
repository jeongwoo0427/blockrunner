import 'dart:ui';

import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/feature/settings/domain/repository/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required this._preferences,
    required this._deviceLocales,
  });

  /// datasource 계층을 두지 않으므로 직접 받는다 (docs/architecture.md §3).
  final SharedPreferences _preferences;

  /// 기기 언어를 읽는 함수. **값이 아니라 함수로 받는다** — 기기 설정은 앱이
  /// 떠 있는 동안에도 바뀔 수 있고, 부팅 때 한 번 읽어 굳히면 그것을 놓친다.
  ///
  /// `PlatformDispatcher` 를 여기서 직접 부르지 않는 것은 테스트 때문이다.
  /// 실제 주입은 `settings_di.dart` 가 한다.
  final List<Locale> Function() _deviceLocales;

  /// 진행도와 **다른 접두사를 쓴다.** 진행도 초기화가 언어까지 날리면 안 된다.
  static const String _localeKey = 'settings_v1_locale';

  @override
  AppLocale? getSavedLocale() =>
      AppLocale.fromCode(_preferences.getString(_localeKey));

  @override
  Future<void> saveLocale(AppLocale locale) =>
      _preferences.setString(_localeKey, locale.code);

  @override
  AppLocale get deviceLocale => AppLocale.fromPlatform(_deviceLocales());
}
