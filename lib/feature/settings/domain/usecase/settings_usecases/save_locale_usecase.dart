import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/feature/settings/domain/repository/settings_repository.dart';

/// 고른 언어를 기기에 저장한다.
///
/// **스트림을 흘리지 않는다.** `SaveClearResultUsecase` 와 달리 언어를 들고 있는
/// 곳이 `LocaleNotifier` 하나뿐이고 화면들은 전부 거기서 파생되므로, 스트림을
/// 두면 같은 사실에 이르는 길이 둘이 된다.
class SaveLocaleUsecase {
  const SaveLocaleUsecase({required this._repository});

  final SettingsRepository _repository;

  Future<void> call(AppLocale locale) => _repository.saveLocale(locale);
}
