import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:blockrunner/feature/level/domain/entity/level.dart';
import 'package:flutter_test/flutter_test.dart';

/// 별점 경계값 (기획서 §5.2). 표에 적힌 값이 실제로 그 값인지 못 박는다.
///
/// 경계는 비율(20% · 40%)과 고정 여유(1수 · 2수) 중 큰 쪽이라, **짧은 레벨과
/// 긴 레벨에서 지배하는 항이 다르다.** 양쪽 다 검사한다.
void main() {
  Level levelWith(int minMoves) => Level(number: 1, minMoves: minMoves);

  /// `minMoves` 별로 `[★★★ 상한, ★★☆ 상한]` — 기획서 §5.2 의 표 그대로다.
  const table = {
    1: [1, 3],
    2: [2, 4],
    3: [3, 5],
    5: [6, 7],
    10: [12, 14],
    20: [24, 28],
  };

  group('기획서 §5.2 표와 일치한다', () {
    table.forEach((minMoves, limits) {
      final [threeStar, twoStar] = limits;

      test('minMoves $minMoves — ★★★ $threeStar수까지, ★★☆ $twoStar수까지', () {
        final level = levelWith(minMoves);

        expect(level.starsFor(minMoves), 3, reason: '최소 수는 항상 ★★★');
        expect(level.starsFor(threeStar), 3);
        expect(level.starsFor(threeStar + 1), 2, reason: '★★★ 상한을 넘으면 ★★☆');
        expect(level.starsFor(twoStar), 2);
        expect(level.starsFor(twoStar + 1), 1, reason: '★★☆ 상한을 넘으면 ★☆☆');
      });
    });
  });

  test('짧은 레벨의 ★★★ 는 최적해를 요구한다', () {
    // minMoves 1 에서 한 수 더 쓰는 것은 100% 초과다. 여유를 주면 후해진다.
    expect(levelWith(1).starsFor(1), 3);
    expect(levelWith(1).starsFor(2), 2);
    expect(levelWith(3).starsFor(4), 2);
  });

  test('짧은 레벨에서도 ★★☆ 가 완충으로 남는다', () {
    // 여기에 고정 여유 2수가 없으면 ★★★ 와 경계가 붙어, 한 수만 어긋나도
    // 곧장 ★☆☆다. 튜토리얼 레벨일수록 가혹해지는 뒤집힌 난이도가 된다.
    expect(levelWith(2).starsFor(3), 2);
    expect(levelWith(2).starsFor(4), 2);
    expect(levelWith(2).starsFor(5), 1);
  });

  test('긴 레벨은 비율이 지배한다', () {
    // 고정 여유만 썼다면 21수에서 ★★☆로 떨어졌을 것이다.
    expect(levelWith(20).starsFor(24), 3);
    expect(levelWith(20).starsFor(25), 2);
    expect(levelWith(20).starsFor(28), 2);
    expect(levelWith(20).starsFor(29), 1);
  });

  test('별점은 이동 횟수가 늘수록 단조 감소한다', () {
    for (final minMoves in [1, 2, 3, 7, 20]) {
      final level = levelWith(minMoves);
      var previous = 3;

      for (var moves = minMoves; moves <= minMoves * 4 + 10; moves++) {
        final stars = level.starsFor(moves);
        expect(
          stars,
          lessThanOrEqualTo(previous),
          reason: 'minMoves $minMoves 에서 $moves 수의 별점이 되레 올랐다',
        );
        expect(stars, inInclusiveRange(1, 3));
        previous = stars;
      }
    }
  });

  test('최소보다 적게 나와도 별 셋으로 묶인다', () {
    // 완전 탐색이 검증하므로 실제로는 나올 수 없다. 나오더라도 별점이
    // 0 이나 음수로 떨어지지 않아야 한다.
    expect(levelWith(3).starsFor(1), 3);
  });

  test('실제 레벨들이 최소 이동 횟수로 별 셋을 받는다', () {
    for (final level in kLevels) {
      expect(
        level.starsFor(level.minMoves),
        3,
        reason: '레벨 ${level.number} 이 최소 수로 풀어도 별 셋이 아니다',
      );
    }
  });
}
