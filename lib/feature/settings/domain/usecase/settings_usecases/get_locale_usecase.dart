import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/feature/settings/domain/repository/settings_repository.dart';

/// 지금 쓸 언어를 정한다 (11-i18n §3).
///
/// ```
/// 저장된 선택이 있으면            → 그 언어
/// 없으면 기기 언어가 지원 목록에  → 그 언어
/// 그것도 아니면                   → ko
/// ```
///
/// 마지막 폴백은 `AppLocale.fromPlatform` 안에 있다.
class GetLocaleUsecase {
  const GetLocaleUsecase({required this._repository});

  final SettingsRepository _repository;

  AppLocale call() => _repository.getSavedLocale() ?? _repository.deviceLocale;
}
