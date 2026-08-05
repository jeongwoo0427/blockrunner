import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **마이그레이션이 끝났다는 것의 실질적 정의** (11-i18n §7).
///
/// "다 옮겼다" 를 눈으로 세면 반드시 빠진다. 특히 조건부 문구
/// (`isCleared ? '클리어!' : '구멍에 빠졌다'`)와 툴팁처럼 화면에 늘 보이지는
/// 않는 것들이 남는다.
///
/// **개발자용 문구는 대상이 아니다.** 파서 오류 · `assert` · `debugMessage` 는
/// 레벨을 만드는 사람이 읽는 것이라 한국어로 남긴다 — 그래서 `data/` 와
/// `domain/` 은 검사하지 않고 **화면이 읽는 곳만** 본다.
void main() {
  /// 한글 음절이 든 문자열 리터럴. 주석은 걸리지 않아야 하므로 따옴표를 요구한다.
  final koreanLiteral = RegExp("""['"][^'"]*[가-힣][^'"]*['"]""");

  /// 검사 대상 — **화면에 문구를 내보내는 곳만.**
  ///
  /// `domain/` 과 `data/` 는 빼둔다. `LevelProgress.toString()` 이나 파서 오류가
  /// 여기 걸리면, 개발자용 문구까지 번역하게 만드는 잘못된 압력이 된다.
  final targets = [
    Directory('lib/feature/game/presentation'),
    Directory('lib/feature/level/presentation'),
    Directory('lib/feature/settings/presentation'),
    File('lib/feature/level/data/level_data.dart'),
  ];

  /// 한 줄에서 주석 부분을 걷어낸다.
  ///
  /// 이 프로젝트는 주석을 한국어로 쓰므로(CLAUDE.md) 이것을 안 하면 거의 모든
  /// 파일이 걸린다. 문자열 안의 `//` 까지 정확히 가려내지는 않지만, 코드에
  /// 그런 리터럴이 없어 실용상 충분하다.
  String stripComments(String line) {
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('//')) return '';

    final marker = line.indexOf('//');
    return marker == -1 ? line : line.substring(0, marker);
  }

  Iterable<File> dartFilesIn(FileSystemEntity entity) => switch (entity) {
    File() => [entity],
    Directory() => entity
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart')),
    _ => const [],
  };

  test('화면 코드에 한국어 문자열 리터럴이 남아 있지 않다', () {
    final offenders = <String>[];

    for (final target in targets) {
      expect(target.existsSync(), isTrue, reason: '${target.path} 가 없다');

      for (final file in dartFilesIn(target)) {
        final lines = file.readAsLinesSync();

        for (var i = 0; i < lines.length; i++) {
          final code = stripComments(lines[i]);
          if (koreanLiteral.hasMatch(code)) {
            offenders.add('${file.path}:${i + 1}  ${code.trim()}');
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          '문구를 AppStrings 로 옮기고 context.strings 로 읽어야 한다:\n'
          '${offenders.join('\n')}',
    );
  });

  test('한국어 문구는 strings_ko.dart 에 실제로 있다', () {
    // 위 테스트는 "없앴다" 만 본다. 통째로 지워도 통과하므로 짝을 맞춰 둔다.
    final source = File('lib/core/i18n/strings_ko.dart').readAsStringSync();

    expect(koreanLiteral.allMatches(source).length, greaterThan(30));
  });
}
