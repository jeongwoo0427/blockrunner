import 'package:blockrunner/feature/settings/domain/repository/settings_repository.dart';
import 'package:blockrunner/feature/settings/domain/usecase/settings_usecases/get_locale_usecase.dart';
import 'package:blockrunner/feature/settings/domain/usecase/settings_usecases/save_locale_usecase.dart';

/// 설정 usecase 묶음 (docs/architecture.md §6).
class SettingsUsecases {
  const SettingsUsecases({required this.getLocale, required this.saveLocale});

  factory SettingsUsecases.fromRepositories({
    required SettingsRepository settingsRepository,
  }) => SettingsUsecases(
    getLocale: GetLocaleUsecase(repository: settingsRepository),
    saveLocale: SaveLocaleUsecase(repository: settingsRepository),
  );

  final GetLocaleUsecase getLocale;
  final SaveLocaleUsecase saveLocale;
}
