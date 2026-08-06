import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **앱의 모든 버튼은 `GameButton` · `GameIconButton` 이다** (13-game-feel §3).
///
/// "전부 바꿨다" 를 눈으로 세면 반드시 빠진다 — 특히 다이얼로그 안이나 AppBar
/// 처럼 늘 보이지 않는 자리가 남는다. 한 화면에서 어떤 버튼만 Material 기본이면
/// 그게 제일 어색하다.
void main() {
  /// 쓰지 않기로 한 Material 버튼들.
  ///
  /// `ListTile` 은 여기 없다 — 설정·언어 목록의 **줄**이지 버튼이 아니고,
  /// 다섯 줄을 전부 각진 버튼으로 만들면 오히려 무거워진다.
  const banned = [
    'FilledButton',
    'OutlinedButton',
    'ElevatedButton',
    'TextButton',
    'IconButton',
  ];

  test('lib 에 Material 기본 버튼이 남아 있지 않다', () {
    final offenders = <String>[];

    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in files) {
      final lines = file.readAsLinesSync();

      for (var i = 0; i < lines.length; i++) {
        final code = lines[i];
        if (code.trimLeft().startsWith('//')) continue;

        for (final widget in banned) {
          // `GameIconButton` 이 `IconButton` 으로 잡히지 않도록 앞 글자를 본다.
          final pattern = RegExp('(?<![A-Za-z])$widget[(.]');
          if (pattern.hasMatch(code)) {
            offenders.add('${file.path}:${i + 1}  ${code.trim()}');
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'GameButton / GameIconButton 으로 바꿔라 (lib/core/widget/):\n'
          '${offenders.join('\n')}',
    );
  });

  test('임시 비교용 화면이 남아 있지 않다', () {
    // 모양을 고르기 위해 만든 `lib/dev/` 는 고른 즉시 지웠다.
    // **임시 코드는 남으면 제품 코드처럼 보이기 시작한다.**
    expect(Directory('lib/dev').existsSync(), isFalse);
  });
}
