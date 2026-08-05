import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/core/i18n/strings_catalog.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:flutter_test/flutter_test.dart';

/// 레벨 이름·안내는 `Map` 이라 **컴파일 검사가 없는 유일한 구멍**이다
/// (11-i18n §2). 그 구멍을 여기서 막는다.
///
/// 나머지 문구는 추상 멤버라 빠뜨리면 빌드가 안 된다 — 테스트할 것이 없다.
void main() {
  final levelNumbers = kLevels.map((level) => level.number).toSet();
  final tutorialLevels = kLevels
      .where((level) => level.hasTutorial)
      .map((level) => level.number)
      .toSet();

  for (final locale in AppLocale.values) {
    final strings = stringsFor(locale);

    group(locale.code, () {
      test('레벨 이름이 모든 레벨에 있고 남는 것도 없다', () {
        expect(strings.levelNames.keys.toSet(), levelNumbers);
      });

      test('안내 문구가 hasTutorial 인 레벨과 정확히 일치한다', () {
        // 많아도 문제다 — 안 뜨는 문구를 번역하고 있다는 뜻이다.
        expect(strings.levelTutorials.keys.toSet(), tutorialLevels);
      });

      test('빈 문구가 없다', () {
        for (final text in [
          ...strings.levelNames.values,
          ...strings.levelTutorials.values,
        ]) {
          expect(text.trim(), isNotEmpty);
        }
      });
    });
  }

  test('언어마다 레벨 이름이 실제로 다르다', () {
    // 번역을 채운다면서 한국어를 복사해 두면 이 테스트가 잡는다.
    for (final locale in AppLocale.values.where((l) => l != AppLocale.ko)) {
      expect(
        stringsFor(locale).levelNames,
        isNot(stringsFor(AppLocale.ko).levelNames),
        reason: '${locale.code} 가 한국어를 그대로 쓰고 있다',
      );
    }
  });

  test('모든 언어가 화면 문구를 각자 갖는다', () {
    // 대표 문구 몇 개만 본다. 전부 열거하면 문구를 고칠 때마다 테스트가 깨진다.
    final resets = {
      for (final locale in AppLocale.values) stringsFor(locale).reset,
    };

    expect(resets, hasLength(AppLocale.values.length));
  });
}
