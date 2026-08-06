import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/core/i18n/app_strings.dart';
import 'package:blockrunner/core/i18n/strings_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// 화면에 나가는 문구의 **말투**를 지킨다.
///
/// 문구는 한 곳에 모여 있지 않고 언어마다 파일이 따로다. 하나를 고칠 때 나머지
/// 넷이 조용히 어긋나기 쉬운데, 말투는 화면을 열어 읽어보기 전에는 눈에 띄지
/// 않는다 — 실제로 다섯 언어 중 셋이 반말·tu 로 남아 있었다.
void main() {
  /// 문장으로 읽히는 문구들. 단어 라벨("설정", "취소")은 말투가 없다.
  List<String> sentencesOf(AppStrings s) => [
    s.resetProgressWarning,
    s.resetProgressDone,
    s.levelListLoadFailed,
    s.unlockHint(3),
    s.levelLoadFailed,
    s.fellIntoBlackHole,
    s.retryHint,
    s.swipeHint,
    s.keyboardHint,
    ...s.levelTutorials.values,
  ];

  group('한국어는 존댓말이다', () {
    final korean = stringsFor(AppLocale.ko);

    /// 고쳐 놓은 평서체 어미들. 한 문장의 **끝**에서만 본다 —
    /// "미끄러진다" 는 잡아야 하지만 "미끄러진다면" 은 아니다.
    const plainEndings = [
      '다',
      '자',
      '라',
    ];

    /// 존댓말에서 쓰는 끝맺음. 위 목록보다 이쪽이 먼저다 —
    /// "있습니다" 도 '다' 로 끝나기 때문이다.
    const politeEndings = ['니다', '세요', '어요', '아요', '예요', '에요'];

    test('문장이 반말로 끝나지 않는다', () {
      for (final text in sentencesOf(korean)) {
        for (final line in text.split('\n')) {
          final trimmed = line.replaceAll(RegExp(r'[.!?\s]+$'), '');
          if (trimmed.isEmpty) continue;

          if (politeEndings.any(trimmed.endsWith)) continue;

          expect(
            plainEndings.any(trimmed.endsWith),
            isFalse,
            reason: '반말로 끝난다: "$line"',
          );
        }
      }
    });
  });

  group('일본어는 です・ます 체다', () {
    final japanese = stringsFor(AppLocale.ja);

    /// 정중체의 끝맺음.
    const politeEndings = [
      'ます',
      'です',
      'ました',
      'ません',
      'ませんでした',
      'ましょう',
    ];

    /// 정중체가 아니면서 문장으로 끝나는 형태.
    const plainEndings = ['た', 'る', 'い', 'う', 'く', 'ぬ', 'よう', 'だ'];

    test('문장이 상시체로 끝나지 않는다', () {
      for (final text in sentencesOf(japanese)) {
        for (final line in text.split('\n')) {
          final trimmed = line.replaceAll(RegExp(r'[。！？\s]+$'), '');
          if (trimmed.isEmpty) continue;

          if (politeEndings.any(trimmed.endsWith)) continue;

          expect(
            plainEndings.any(trimmed.endsWith),
            isFalse,
            reason: '상시체로 끝난다: "$line"',
          );
        }
      }
    });
  });

  group('프랑스어는 vous 로 부른다', () {
    final french = stringsFor(AppLocale.fr);

    /// tu 로 부를 때만 나오는 명령형·대명사.
    const informal = [
      'Recommence ',
      'Balaie',
      'Arrête ',
      'Surveille ',
      'Appuie',
      ' tu ',
      ' ton ',
      ' ta ',
    ];

    test('반말(tu) 표현이 없다', () {
      for (final text in sentencesOf(french)) {
        for (final word in informal) {
          expect(
            text.contains(word),
            isFalse,
            reason: '"$word" 는 tu 형이다: "$text"',
          );
        }
      }
    });
  });
}
