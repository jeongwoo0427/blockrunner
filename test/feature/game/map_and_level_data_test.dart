import 'package:blockrunner/feature/game/data/map_blueprints.dart';
import 'package:blockrunner/feature/game/data/map_parser.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'min_moves_solver.dart';

/// 맵(game)과 레벨 메타데이터(level)는 서로 다른 feature 의 상수 목록이고
/// **레벨 번호로만 이어져 있다.** 한쪽만 고치면 조용히 어긋나므로 여기서 조인해 막는다.
void main() {
  const parser = MapParser();

  final levelNumbers = kLevels.map((level) => level.number).toList();
  final mapNumbers = kMapBlueprints
      .map((blueprint) => blueprint.levelNumber)
      .toList();

  test('레벨이 최소 6개 정의되어 있다', () {
    expect(kLevels.length, greaterThanOrEqualTo(6));
  });

  test('레벨 번호가 1부터 빠짐없이 이어진다', () {
    expect(levelNumbers, List.generate(kLevels.length, (index) => index + 1));
  });

  test('모든 레벨에 맵이 있고, 모든 맵에 레벨이 있다', () {
    expect(
      mapNumbers.toSet(),
      levelNumbers.toSet(),
      reason: '한쪽 목록에만 추가하면 여기서 걸린다',
    );
    expect(mapNumbers.length, mapNumbers.toSet().length, reason: '맵 번호가 중복됐다');
  });

  for (final blueprint in kMapBlueprints) {
    group('레벨 ${blueprint.levelNumber}', () {
      test('맵이 파싱과 유효성 검증을 통과한다', () {
        expect(() => parser.parse(blueprint), returnsNormally);
      });

      test('Level.minMoves 가 맵의 실제 최소값과 일치한다', () {
        final level = kLevels.firstWhere(
          (level) => level.number == blueprint.levelNumber,
        );
        final actual = solveMinMoves(parser.parse(blueprint).initialBoard);

        expect(actual, isNotNull, reason: '완전 탐색으로 풀리지 않는다 — 클리어 불가능한 맵이다');
        expect(
          actual,
          level.minMoves,
          reason: '맵을 고쳤으면 level_data.dart 의 minMoves 도 고쳐야 한다',
        );
      });
    });
  }
}
