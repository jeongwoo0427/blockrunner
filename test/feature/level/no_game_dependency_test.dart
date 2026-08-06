import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **`level` 은 `game` 을 모른다** (docs/architecture.md §2).
///
/// 이 프로젝트는 같은 순환을 두 번 만들고 두 번 끊었다 — `#22`(판을 `Level` 에
/// 품어서), `#46`(진행도 저장에 `Level` 을 넘겨서). 세 번째 유혹이 레벨 카드의
/// **미니 보드 미리보기**다. 판을 그리려면 `game` 이 필요한데 `game → level` 이
/// 이미 있다.
///
/// 우회로는 미리보기 위젯을 `level` 이 만들지 않고 **함수로 받는 것**이고,
/// 조립은 라우터가 한다 (12-ui-polish §2). 그 규칙이 지켜지는지 여기서 본다.
void main() {
  test('level feature 가 game 을 import 하지 않는다', () {
    final offenders = <String>[];

    final files = Directory('lib/feature/level')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in files) {
      final lines = file.readAsLinesSync();

      for (var i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('import') &&
            lines[i].contains('feature/game/')) {
          offenders.add('${file.path}:${i + 1}  ${lines[i].trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          '판이 필요하면 위젯을 만들지 말고 함수로 받아라. 조립은 라우터가 한다:\n'
          '${offenders.join('\n')}',
    );
  });

  test('progress 와 settings 는 아무 feature 도 모른다', () {
    // 잎 노드가 잎으로 남아 있는지 함께 본다. 여기가 무너지면 어떤 순환이든
    // 만들 수 있게 된다.
    for (final leaf in ['progress', 'settings']) {
      final files = Directory('lib/feature/$leaf')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final file in files) {
        for (final line in file.readAsLinesSync()) {
          if (!line.startsWith('import')) continue;

          expect(
            RegExp(r'feature/(?!' + leaf + r'/)').hasMatch(line),
            isFalse,
            reason: '${file.path} 가 다른 feature 를 import 한다: ${line.trim()}',
          );
        }
      }
    }
  });
}
