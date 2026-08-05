import 'dart:ui';

/// 앱이 지원하는 언어 (11-i18n).
///
/// 언어 코드만 갖는다 — 지역(`zh-Hans-CN` 의 `CN`)까지 나누지 않는다.
/// 중국어 번체를 별개로 지원하게 되면 그때 이 enum 이 늘어난다.
enum AppLocale {
  ko('ko', '한국어'),
  en('en', 'English'),
  ja('ja', '日本語'),
  zh('zh', '简体中文'),
  fr('fr', 'Français');

  const AppLocale(this.code, this.nativeName);

  /// 저장·비교에 쓰는 언어 코드.
  final String code;

  /// 목록에 보여줄 이름. **그 언어로 적는다** — 읽을 수 없는 언어로 적힌
  /// 목록에서 자기 언어를 찾을 수는 없다.
  final String nativeName;

  /// 지원하지 않는 언어일 때의 기본값.
  static const AppLocale fallback = AppLocale.ko;

  static AppLocale? fromCode(String? code) {
    for (final locale in AppLocale.values) {
      if (locale.code == code) return locale;
    }
    return null;
  }

  /// 기기가 알려준 로케일 목록에서 지원하는 첫 언어를 고른다.
  ///
  /// **언어 코드만 본다.** 기기는 `zh-Hans-CN` · `en-GB` 처럼 지역을 붙여 주는데,
  /// 그대로 비교하면 어느 것도 맞지 않아 늘 [fallback] 으로 떨어진다.
  ///
  /// 목록의 순서가 곧 사용자의 선호 순서이므로 **앞에서부터** 찾는다.
  static AppLocale fromPlatform(List<Locale> locales) {
    for (final locale in locales) {
      final match = fromCode(locale.languageCode);
      if (match != null) return match;
    }
    return fallback;
  }
}
