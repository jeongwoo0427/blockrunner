import 'package:blockrunner/feature/game/data/map_blueprints.dart';
import 'package:blockrunner/feature/game/data/map_parser.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'level_design.dart';

/// **레벨 설계가 규칙을 지키는가** (기획서 §4.3).
///
/// 최소 수만 맞으면 되는 것이 아니다. 되돌리기가 없으므로(기획서 §5.1) 한 번
/// 잘못 밀어 다시는 깰 수 없게 되면, 화면상 아무 일도 없는데 판은 끝나 있다.
/// 실제로 예전 1번 레벨이 그랬다 — 위로 밀면 목표에 설 방법이 사라졌다.
///
/// 손으로 세는 검사가 아니라 **완전 탐색**이다. 맵을 고칠 때마다 다시 돈다.
void main() {
  const parser = MapParser();

  BoardState boardOf(int levelNumber) => parser
      .parse(kMapBlueprints.firstWhere((map) => map.levelNumber == levelNumber))
      .initialBoard;

  group('모든 레벨', () {
    for (final level in kLevels) {
      final number = level.number;

      test('$number 번은 풀 수 있고 막다른 판이 없다', () {
        final analysis = analyzeLevel(boardOf(number));

        expect(analysis.isSolvable, isTrue, reason: '깰 수 없는 판이다');
        expect(
          analysis.minMoves,
          level.minMoves,
          reason: 'kLevels 의 minMoves 가 실제 최단 수와 다르다',
        );
        expect(
          analysis.hasDeadEnd,
          isFalse,
          reason:
              '갈 수 있는 판 ${analysis.reachable} 개 중 ${analysis.deadEnds} 개가 막다른 길이다.\n'
              '예를 들어 이 판에서는 무엇을 해도 깰 수 없다:\n'
              '${analysis.sampleDeadEnd}',
        );
      });

      test('$number 번의 요소는 전부 제 몫을 한다', () {
        // 빼도 최소 수가 그대로면 장식이다. 판만 복잡해 보이고 어려워지지는
        // 않는다.
        expect(uselessElements(boardOf(number)), isEmpty);
      });

      test('$number 번에 빈 여백이 없다', () {
        // 넓이는 어려움이 아니다. 가장자리 한 줄을 잘라도 최소 수가 그대로면
        // 그 줄은 판을 넓어 **보이게** 할 뿐이다.
        expect(
          paddedSides(boardOf(number)),
          isEmpty,
          reason: '이 방향의 가장자리를 잘라내도 판이 달라지지 않는다',
        );
      });
    }
  });

  group('난이도 곡선 (기획서 §4.3)', () {
    final boards = [for (final level in kLevels) boardOf(level.number)];

    test('판은 커지기만 하고 작아지지 않는다', () {
      var previous = 0;

      for (final board in boards) {
        final area = board.rowCount * board.colCount;
        expect(area, greaterThanOrEqualTo(previous), reason: '판이 도로 작아졌다');
        previous = area;
      }
    });

    test('한 변이 10 을 넘지 않는다', () {
      for (final board in boards) {
        expect(board.rowCount, lessThanOrEqualTo(10));
        expect(board.colCount, lessThanOrEqualTo(10));
      }
    });

    test('가로로 긴 판과 세로로 긴 판이 고루 섞여 있다', () {
      // 계속 정사각이면 판이 커져도 늘 같은 그림으로 보인다. 긴 축으로는 멀리
      // 미끄러지고 짧은 축으로는 곧 벽에 닿는 것이 다른 감각이다.
      final wide = boards.where((b) => b.colCount > b.rowCount).length;
      final tall = boards.where((b) => b.rowCount > b.colCount).length;

      expect(wide, greaterThanOrEqualTo(5), reason: '가로로 긴 판이 모자라다');
      expect(tall, greaterThanOrEqualTo(5), reason: '세로로 긴 판이 모자라다');
    });

    test('블랙홀은 15번부터 나온다', () {
      // 잃을 것이 있는 요소는 규칙을 충분히 익힌 뒤에 꺼낸다.
      for (final level in kLevels) {
        final board = boardOf(level.number);
        final holes = [
          for (var r = 0; r < board.rowCount; r++)
            for (var c = 0; c < board.colCount; c++)
              if (board.floors[r][c] == FloorType.blackHole) 1,
        ].length;

        if (level.number < 15) {
          expect(holes, 0, reason: '${level.number} 번에 블랙홀이 있다');
        } else {
          expect(holes, greaterThan(0), reason: '${level.number} 번에 블랙홀이 없다');
        }
      }
    });

    test('첫 레벨은 한 수로 깨진다', () {
      expect(kLevels.first.minMoves, 1);
    });

    test('뒤로 갈수록 대체로 길어진다', () {
      // **매 레벨 단조 증가는 요구하지 않는다.** 새 요소가 나오는 판은 일부러
      // 짧게 만든다 — 규칙을 보여주는 것이 먼저다(15번이 그렇다).
      final front = kLevels.take(10).map((l) => l.minMoves).reduce((a, b) => a + b);
      final back = kLevels.skip(10).map((l) => l.minMoves).reduce((a, b) => a + b);

      expect(back, greaterThan(front));
    });
  });
}
