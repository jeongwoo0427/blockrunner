import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/core/i18n/app_strings.dart';
import 'package:blockrunner/core/i18n/strings_en.dart';
import 'package:blockrunner/core/i18n/strings_fr.dart';
import 'package:blockrunner/core/i18n/strings_ja.dart';
import 'package:blockrunner/core/i18n/strings_ko.dart';
import 'package:blockrunner/core/i18n/strings_zh.dart';

/// 언어 → 문자열 한 벌.
///
/// `switch` 표현식이라 [AppLocale] 에 값을 추가하면 **컴파일이 깨진다.**
/// 언어를 늘리고 문자열 파일을 안 만드는 실수를 여기서 막는다.
AppStrings stringsFor(AppLocale locale) => switch (locale) {
  AppLocale.ko => const StringsKo(),
  AppLocale.en => const StringsEn(),
  AppLocale.ja => const StringsJa(),
  AppLocale.zh => const StringsZh(),
  AppLocale.fr => const StringsFr(),
};
