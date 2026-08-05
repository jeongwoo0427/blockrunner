import 'package:blockrunner/feature/level/data/level_blueprints.dart';
import 'package:blockrunner/feature/level/data/level_parser.dart';
import 'package:flutter_test/flutter_test.dart';

import 'level_solver.dart';

void main() {
  const parser = LevelParser();

  test('레벨이 최소 6개 정의되어 있다', () {
    expect(kLevelBlueprints.length, greaterThanOrEqualTo(6));
  });

  test('레벨 번호가 1부터 빠짐없이 이어진다', () {
    expect(
      kLevelBlueprints.map((blueprint) => blueprint.number),
      List.generate(kLevelBlueprints.length, (index) => index + 1),
    );
  });

  // 레벨을 추가할 때마다 아래 두 검사가 자동으로 따라붙는다.
  for (final blueprint in kLevelBlueprints) {
    group('레벨 ${blueprint.number}', () {
      test('파싱과 유효성 검증을 통과한다', () {
        expect(() => parser.parse(blueprint), returnsNormally);
      });

      test('minMoves ${blueprint.minMoves} 가 실제 최소값과 일치한다', () {
        final level = parser.parse(blueprint);
        final actual = solveMinMoves(level.initialBoard);

        expect(actual, isNotNull, reason: '완전 탐색으로 풀리지 않는다 — 클리어 불가능한 레벨이다');
        expect(actual, blueprint.minMoves);
      });
    });
  }
}
