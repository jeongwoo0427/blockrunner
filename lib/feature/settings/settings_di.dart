import 'dart:ui';

import 'package:blockrunner/core/di/core_providers.dart';
import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/core/i18n/app_strings.dart';
import 'package:blockrunner/core/i18n/strings_catalog.dart';
import 'package:blockrunner/feature/settings/data/repository/settings_repository_impl.dart';
import 'package:blockrunner/feature/settings/domain/repository/settings_repository.dart';
import 'package:blockrunner/feature/settings/domain/usecase/settings_usecases.dart';
import 'package:blockrunner/feature/settings/presentation/locale_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// settings feature 의 계층별 DI Providers
///
/// 이 feature 는 **어떤 feature 도 알지 않는다** (docs/architecture.md §2).

/// ----------------------------------------------------------------------------
/// Data
/// ----------------------------------------------------------------------------

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(
    preferences: ref.read(sharedPreferencesProvider),
    // 기기 언어는 프레임워크가 알려준다 — 다국어 라이브러리를 쓰지 않는다.
    // `dart:io` 도 쓰지 않는다(웹에서 못 쓴다).
    deviceLocales: () => PlatformDispatcher.instance.locales,
  ),
);

/// ----------------------------------------------------------------------------
/// Domain
/// ----------------------------------------------------------------------------

final settingsUsecasesProvider = Provider(
  (ref) => SettingsUsecases.fromRepositories(
    settingsRepository: ref.read(settingsRepositoryProvider),
  ),
);

/// ----------------------------------------------------------------------------
/// Presentation
/// ----------------------------------------------------------------------------

final localeNotifierProvider = NotifierProvider<LocaleNotifier, AppLocale>(
  LocaleNotifier.new,
);

/// 현재 언어의 문구.
///
/// **provider 본문에서 `ref.watch` 를 쓴다** — 규약(§4)의 예외다. 이것은 DI
/// 배선이 아니라 **파생 상태**이고, 언어가 바뀔 때 다시 계산되지 않으면
/// 존재 이유가 없다. `ref.read` 로 두면 처음 언어에 영영 고정된다.
final appStringsProvider = Provider<AppStrings>(
  (ref) => stringsFor(ref.watch(localeNotifierProvider)),
);
