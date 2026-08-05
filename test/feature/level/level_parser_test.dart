import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/core/error/failure_code.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/level/data/level_blueprints.dart';
import 'package:blockrunner/feature/level/data/level_parser.dart';
import 'package:flutter_test/flutter_test.dart';

const parser = LevelParser();

LevelBlueprint blueprintOf(List<String> rows) =>
    LevelBlueprint(number: 99, minMoves: 1, rows: rows);

/// 잘못된 레벨은 `invalidLevelData` 로 터져야 한다.
Matcher get throwsInvalidLevelData => throwsA(
  isA<ClientFailure>().having(
    (failure) => failure.code,
    'code',
    FailureCode.invalidLevelData,
  ),
);

void main() {
  group('정상 파싱', () {
    test('바닥과 블록을 분리해 보드를 만든다', () {
      final level = parser.parse(
        const LevelBlueprint(
          number: 7,
          name: '테스트',
          minMoves: 3,
          rows: ['@.O...', '..#X.G'],
        ),
      );

      expect(level.number, 7);
      expect(level.name, '테스트');
      expect(level.minMoves, 3);

      final board = level.initialBoard;
      expect(board.rowCount, 2);
      expect(board.colCount, 6);

      expect(board.floorAt(const Position(1, 2)), FloorType.wall);
      expect(board.floorAt(const Position(1, 3)), FloorType.hole);
      expect(board.floorAt(const Position(1, 5)), FloorType.goal);
      // 블록이 선 칸의 바닥은 빈 칸이다.
      expect(board.floorAt(const Position(0, 0)), FloorType.empty);

      expect(board.player?.position, const Position(0, 0));
      expect(board.blockAt(const Position(0, 2))?.type, BlockType.normal);
      expect(board.blocks, hasLength(2));
    });

    test('블록 id 는 행 우선 순서로 붙는다', () {
      final board = parser.parse(blueprintOf(['O.@..G'])).initialBoard;

      expect(board.blockAt(const Position(0, 0))?.id, 0);
      expect(board.blockAt(const Position(0, 2))?.id, 1);
    });
  });

  group('유효성 검증', () {
    test('행 길이가 다르면 거부한다', () {
      expect(
        () => parser.parse(blueprintOf(['@..G', '...'])),
        throwsInvalidLevelData,
      );
    });

    test('알 수 없는 기호를 거부한다', () {
      expect(
        () => parser.parse(blueprintOf(['@?.G'])),
        throwsInvalidLevelData,
      );
    });

    test('플레이어가 없으면 거부한다', () {
      expect(() => parser.parse(blueprintOf(['O..G'])), throwsInvalidLevelData);
    });

    test('플레이어가 둘이면 거부한다', () {
      expect(() => parser.parse(blueprintOf(['@.@G'])), throwsInvalidLevelData);
    });

    test('목표가 없으면 거부한다', () {
      expect(() => parser.parse(blueprintOf(['@...'])), throwsInvalidLevelData);
    });

    test('행이 없으면 거부한다', () {
      expect(() => parser.parse(blueprintOf([])), throwsInvalidLevelData);
    });

    test('목표 사방에 정지 요소가 없으면 거부한다', () {
      // 목표(2,2)는 맵 경계에도 닿지 않고 벽도 인접하지 않아 멈출 수가 없다.
      expect(
        () => parser.parse(
          blueprintOf(['.....', '.....', '..G..', '.@...', '.....']),
        ),
        throwsInvalidLevelData,
      );
    });

    test('맵 경계에 닿은 목표는 통과한다', () {
      expect(
        () => parser.parse(blueprintOf(['.....', '.@..G', '.....'])),
        returnsNormally,
      );
    });

    test('벽이 인접한 목표는 통과한다', () {
      expect(
        () => parser.parse(blueprintOf(['.....', '.@G#.', '.....'])),
        returnsNormally,
      );
    });
  });
}
