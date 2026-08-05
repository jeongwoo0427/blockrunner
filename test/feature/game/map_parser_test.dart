import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/core/error/failure_code.dart';
import 'package:blockrunner/feature/game/data/map_blueprints.dart';
import 'package:blockrunner/feature/game/data/map_parser.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:flutter_test/flutter_test.dart';

const parser = MapParser();

MapBlueprint blueprintOf(List<String> rows) =>
    MapBlueprint(levelNumber: 99, rows: rows);

/// 잘못된 맵은 `invalidMapData` 로 터져야 한다.
Matcher get throwsInvalidMapData => throwsA(
  isA<ClientFailure>().having(
    (failure) => failure.code,
    'code',
    FailureCode.invalidMapData,
  ),
);

void main() {
  group('정상 파싱', () {
    test('칸 · 바닥 · 블록을 읽는다', () {
      final map = parser.parse(
        const MapBlueprint(
          levelNumber: 7,
          rows: [
            '+-+-+-+-+-+-+',
            '|@ . O . . .|',
            '+ + + + + + +',
            '|. . # X . G|',
            '+-+-+-+-+-+-+',
          ],
        ),
      );

      expect(map.levelNumber, 7);

      final board = map.initialBoard;
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
      final board = parser
          .parse(
            blueprintOf(const [
              '+-+-+-+-+-+-+',
              '|O . @ . . G|',
              '+-+-+-+-+-+-+',
            ]),
          )
          .initialBoard;

      expect(board.blockAt(const Position(0, 0))?.id, 0);
      expect(board.blockAt(const Position(0, 2))?.id, 1);
    });

    test('경계 벽을 읽고 양방향으로 조회된다', () {
      final board = parser
          .parse(
            blueprintOf(const [
              '+-+-+-+',
              '|@ .|G|',
              '+ +-+ +',
              '|. . .|',
              '+-+-+-+',
            ]),
          )
          .initialBoard;

      // (0,1) 오른쪽 세로 벽
      expect(
        board.hasWallBetween(const Position(0, 1), Direction.right),
        isTrue,
      );
      expect(board.hasWallBetween(const Position(0, 2), Direction.left), isTrue);
      // (0,1) 아래쪽 가로 벽
      expect(board.hasWallBetween(const Position(0, 1), Direction.down), isTrue);
      expect(board.hasWallBetween(const Position(1, 1), Direction.up), isTrue);

      expect(board.walls, hasLength(2));
    });

    test('외곽 테두리는 벽 목록에 담기지 않는다', () {
      // 맵 경계는 이미 벽으로 취급되므로(기획서 §2.2) 중복 저장하지 않는다.
      final board = parser
          .parse(blueprintOf(const ['+-+-+-+', '|@ . G|', '+-+-+-+']))
          .initialBoard;

      expect(board.walls, isEmpty);
    });
  });

  group('구조 검증', () {
    test('줄 수가 짝수면 거부한다', () {
      expect(
        () => parser.parse(
          blueprintOf(const ['+-+-+-+', '|@ . G|', '+ + + +', '|. . .|']),
        ),
        throwsInvalidMapData,
      );
    });

    test('글자 수가 짝수면 거부한다', () {
      expect(
        () => parser.parse(blueprintOf(const ['+-+-+-', '|@ . G', '+-+-+-'])),
        throwsInvalidMapData,
      );
    });

    test('줄 길이가 서로 다르면 거부한다', () {
      expect(
        () => parser.parse(blueprintOf(const ['+-+-+-+', '|@ . G|', '+-+-+'])),
        throwsInvalidMapData,
      );
    });

    test('교차점이 + 가 아니면 거부한다 — 열이 밀린 오타를 잡는다', () {
      expect(
        () =>
            parser.parse(blueprintOf(const ['+-+-+-+', '|@ . G|', '+-+-+-.'])),
        throwsInvalidMapData,
      );
    });

    test('경계 자리에 엉뚱한 기호가 있으면 거부한다', () {
      expect(
        () =>
            parser.parse(blueprintOf(const ['+-+-+-+', '|@ .XG|', '+-+-+-+'])),
        throwsInvalidMapData,
      );
    });

    test('외곽이 열려 있으면 거부한다', () {
      expect(
        () =>
            parser.parse(blueprintOf(const ['+-+ +-+', '|@ . G|', '+-+-+-+'])),
        throwsInvalidMapData,
        reason: '윗변에 구멍이 뚫려 있다',
      );
      expect(
        () =>
            parser.parse(blueprintOf(const ['+-+-+-+', '|@ . G ', '+-+-+-+'])),
        throwsInvalidMapData,
        reason: '오른쪽 변이 닫혀 있지 않다',
      );
    });

    test('너무 작으면 거부한다', () {
      expect(() => parser.parse(blueprintOf(const [])), throwsInvalidMapData);
      expect(
        () => parser.parse(blueprintOf(const ['+-+'])),
        throwsInvalidMapData,
      );
    });
  });

  group('내용 검증', () {
    test('알 수 없는 칸 기호를 거부한다', () {
      expect(
        () =>
            parser.parse(blueprintOf(const ['+-+-+-+', '|@ ? G|', '+-+-+-+'])),
        throwsInvalidMapData,
      );
    });

    test('플레이어가 없으면 거부한다', () {
      expect(
        () =>
            parser.parse(blueprintOf(const ['+-+-+-+', '|O . G|', '+-+-+-+'])),
        throwsInvalidMapData,
      );
    });

    test('플레이어가 둘이면 거부한다', () {
      expect(
        () =>
            parser.parse(blueprintOf(const ['+-+-+-+', '|@ @ G|', '+-+-+-+'])),
        throwsInvalidMapData,
      );
    });

    test('목표가 없으면 거부한다', () {
      expect(
        () =>
            parser.parse(blueprintOf(const ['+-+-+-+', '|@ . .|', '+-+-+-+'])),
        throwsInvalidMapData,
      );
    });
  });

  group('목표 도달 가능성', () {
    test('사방에 정지 요소가 없으면 거부한다', () {
      // 목표(2,2)는 맵 경계에도 닿지 않고 벽도 인접하지 않아 멈출 수가 없다.
      expect(
        () => parser.parse(
          blueprintOf(const [
            '+-+-+-+-+-+',
            '|. . . . .|',
            '+ + + + + +',
            '|. . . . .|',
            '+ + + + + +',
            '|. . G . .|',
            '+ + + + + +',
            '|. @ . . .|',
            '+ + + + + +',
            '|. . . . .|',
            '+-+-+-+-+-+',
          ]),
        ),
        throwsInvalidMapData,
      );
    });

    test('맵 경계에 닿은 목표는 통과한다', () {
      expect(
        () => parser.parse(
          blueprintOf(const [
            '+-+-+-+-+-+',
            '|. . . . .|',
            '+ + + + + +',
            '|. @ . . G|',
            '+ + + + + +',
            '|. . . . .|',
            '+-+-+-+-+-+',
          ]),
        ),
        returnsNormally,
      );
    });

    test('칸 벽이 인접한 목표는 통과한다', () {
      expect(
        () => parser.parse(
          blueprintOf(const [
            '+-+-+-+-+-+',
            '|. . . . .|',
            '+ + + + + +',
            '|. @ G # .|',
            '+ + + + + +',
            '|. . . . .|',
            '+-+-+-+-+-+',
          ]),
        ),
        returnsNormally,
      );
    });

    test('경계 벽이 있으면 칸을 버리지 않고도 통과한다', () {
      expect(
        () => parser.parse(
          blueprintOf(const [
            '+-+-+-+-+-+',
            '|. . . . .|',
            '+ + + + + +',
            '|. @ G|. .|',
            '+ + + + + +',
            '|. . . . .|',
            '+-+-+-+-+-+',
          ]),
        ),
        returnsNormally,
      );
    });
  });
}
