import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/feature/settings/domain/usecase/settings_usecases.dart';
import 'package:blockrunner/feature/settings/settings_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 지금 언어를 들고 있는 **유일한 곳** (11-i18n §4).
///
/// 화면 하나에 붙지 않으므로 이름이 `*ScreenNotifier` 가 아니다
/// (docs/architecture.md §5의 예외). 앱 전체가 이 하나를 본다.
class LocaleNotifier extends Notifier<AppLocale> {
  SettingsUsecases get _usecases => ref.read(settingsUsecasesProvider);

  @override
  AppLocale build() => _usecases.getLocale();

  /// 고른 언어로 바꾸고 기기에 저장한다.
  ///
  /// **상태를 먼저 세운다.** 저장을 기다린 뒤 바꾸면 다이얼로그를 닫고
  /// 한 박자 뒤에 문구가 바뀌어 눌린 것이 먹지 않은 것처럼 보인다.
  Future<void> change(AppLocale locale) async {
    if (state == locale) return;
    state = locale;
    await _usecases.saveLocale(locale);
  }
}
