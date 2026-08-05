import 'package:blockrunner/core/i18n/app_locale.dart';

/// 앱 설정 저장소. **읽기는 동기, 쓰기는 비동기다** (`progress` 와 같은 이유).
///
/// 지금 담는 것은 언어 하나뿐이다.
abstract class SettingsRepository {
  /// 사용자가 직접 고른 언어. 고른 적이 없으면 `null`.
  ///
  /// [deviceLocale] 과 나눠 두는 것이 요점이다 — "아직 고르지 않았다" 와
  /// "기기 언어와 같은 것을 골랐다" 는 다른 상태다. 합쳐 두면 기기 언어를
  /// 바꿨을 때 따라갈지 말지를 판단할 수 없다.
  AppLocale? getSavedLocale();

  Future<void> saveLocale(AppLocale locale);

  /// 기기가 알려준 언어. 지원하지 않으면 [AppLocale.fallback].
  AppLocale get deviceLocale;
}
