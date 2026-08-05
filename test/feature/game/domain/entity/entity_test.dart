import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/domain/entity/wall_edge.dart';
import 'package:flutter_test/flutter_test.dart';

/// 기획서 §4.3 의 6×6 예시 레벨.
///
/// ```
///        0  1  2  3  4  5
///    0 | .  .  .  .  .  .
///    1 | .  @  .  .  .  .
///    2 | .  O  .  .  .  .
///    3 | .  .  .  .  .  .
///    4 | .  .  G  #  .  .
///    5 | .  .  .  .  .  .
/// ```
BoardState buildSampleBoard({List<Block>? blocks, Set<WallEdge> walls = const {}}) {
  final floors = List.generate(
    6,
    (_) => List.filled(6, FloorType.empty),
    growable: false,
  );
  floors[4][2] = FloorType.goal;
  floors[4][3] = FloorType.wall;

  return BoardState(
    rowCount: 6,
    colCount: 6,
    floors: floors,
    walls: walls,
    blocks:
        blocks ??
        const [
          Block(id: 0, type: BlockType.player, position: Position(1, 1)),
          Block(id: 1, type: BlockType.normal, position: Position(2, 1)),
        ],
  );
}

void main() {
  group('Position', () {
    test('방향대로 한 칸 이동한다', () {
      const start = Position(2, 3);

      expect(start.translate(Direction.up), const Position(1, 3));
      expect(start.translate(Direction.down), const Position(3, 3));
      expect(start.translate(Direction.left), const Position(2, 2));
      expect(start.translate(Direction.right), const Position(2, 4));
    });

    test('행과 열이 같으면 같은 좌표이고 Set 에서 중복되지 않는다', () {
      expect(const Position(1, 2), const Position(1, 2));
      expect(const Position(1, 2), isNot(const Position(2, 1)));
      final seen = <Position>{};
      seen.add(const Position(1, 2));
      seen.add(const Position(1, 2));
      expect(seen, hasLength(1));
    });
  });

  group('Block', () {
    test('moveTo 는 id 와 종류를 유지한 채 위치만 바꾼다', () {
      const block = Block(
        id: 7,
        type: BlockType.player,
        position: Position(1, 1),
      );

      final moved = block.moveTo(const Position(4, 1));

      expect(moved.id, 7);
      expect(moved.type, BlockType.player);
      expect(moved.position, const Position(4, 1));
      expect(block.position, const Position(1, 1), reason: '원본은 불변이어야 한다');
    });
  });

  group('WallEdge', () {
    test('같은 벽은 어느 칸에서 물어도 같은 값이다', () {
      // (2,3) 의 오른쪽 == (2,4) 의 왼쪽. 정규화하지 않으면 Set 안에 둘로 들어가
      // 한 방향에서만 막히는 조용한 버그가 된다.
      expect(
        WallEdge.between(const Position(2, 3), Direction.right),
        WallEdge.between(const Position(2, 4), Direction.left),
      );
      expect(
        WallEdge.between(const Position(2, 3), Direction.down),
        WallEdge.between(const Position(3, 3), Direction.up),
      );
    });

    test('정규화된 값은 Set 에서 하나로 합쳐진다', () {
      final walls = <WallEdge>{}
        ..add(WallEdge.between(const Position(2, 3), Direction.right))
        ..add(WallEdge.between(const Position(2, 4), Direction.left));

      expect(walls, hasLength(1));
      expect(walls.single.direction, Direction.right);
    });

    test('다른 경계는 다른 값이다', () {
      expect(
        WallEdge.between(const Position(2, 3), Direction.right),
        isNot(WallEdge.between(const Position(2, 3), Direction.down)),
      );
      expect(
        WallEdge.between(const Position(2, 3), Direction.right),
        isNot(WallEdge.between(const Position(2, 4), Direction.right)),
      );
    });
  });

  group('BoardState', () {
    test('맵 밖은 벽으로 취급한다', () {
      final board = buildSampleBoard();

      expect(board.contains(const Position(0, 0)), isTrue);
      expect(board.contains(const Position(-1, 0)), isFalse);
      expect(board.contains(const Position(6, 0)), isFalse);

      expect(board.floorAt(const Position(-1, 0)), FloorType.wall);
      expect(board.floorAt(const Position(4, 3)), FloorType.wall);
      expect(board.floorAt(const Position(4, 2)), FloorType.goal);
      expect(board.floorAt(const Position(0, 0)), FloorType.empty);
    });

    test('좌표로 블록을 찾고, 없으면 null 이다', () {
      final board = buildSampleBoard();

      expect(board.blockAt(const Position(1, 1))?.id, 0);
      expect(board.blockAt(const Position(2, 1))?.id, 1);
      expect(board.blockAt(const Position(0, 0)), isNull);
    });

    test('플레이어가 사라지면 player 가 null 이고 클리어가 아니다', () {
      final board = buildSampleBoard(
        blocks: const [
          Block(id: 1, type: BlockType.normal, position: Position(4, 2)),
        ],
      );

      expect(board.player, isNull);
      expect(board.hasPlayer, isFalse);
      expect(board.isCleared, isFalse, reason: '목표 칸에 있는 것은 일반 블록이다');
    });

    test('플레이어가 목표 칸에 있으면 클리어다', () {
      final onGoal = buildSampleBoard(
        blocks: const [
          Block(id: 0, type: BlockType.player, position: Position(4, 2)),
        ],
      );
      final beforeGoal = buildSampleBoard(
        blocks: const [
          Block(id: 0, type: BlockType.player, position: Position(4, 1)),
        ],
      );

      expect(onGoal.isCleared, isTrue);
      expect(beforeGoal.isCleared, isFalse);
    });

    test('withBlocks 는 바닥을 공유하고 블록만 교체한다', () {
      final board = buildSampleBoard();
      final next = board.withBlocks(const [
        Block(id: 0, type: BlockType.player, position: Position(4, 1)),
      ]);

      expect(next.floors, same(board.floors));
      expect(next.blocks, hasLength(1));
      expect(board.blocks, hasLength(2), reason: '원본은 불변이어야 한다');
    });

    test('블록 순서가 달라도 같은 판이다', () {
      const player = Block(
        id: 0,
        type: BlockType.player,
        position: Position(1, 1),
      );
      const normal = Block(
        id: 1,
        type: BlockType.normal,
        position: Position(2, 1),
      );

      final a = buildSampleBoard(blocks: const [player, normal]);
      final b = buildSampleBoard(blocks: const [normal, player]);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('경계 벽은 양방향으로 조회된다', () {
      final board = buildSampleBoard(
        walls: {WallEdge.between(const Position(1, 1), Direction.right)},
      );

      expect(
        board.hasWallBetween(const Position(1, 1), Direction.right),
        isTrue,
      );
      expect(
        board.hasWallBetween(const Position(1, 2), Direction.left),
        isTrue,
        reason: '같은 벽을 반대쪽에서 물어도 막혀 있어야 한다',
      );
      expect(
        board.hasWallBetween(const Position(1, 1), Direction.down),
        isFalse,
      );
    });

    test('벽이 없으면 어느 방향도 막히지 않는다', () {
      final board = buildSampleBoard();

      for (final direction in Direction.values) {
        expect(board.hasWallBetween(const Position(1, 1), direction), isFalse);
      }
    });

    test('벽이 다르면 다른 판이다', () {
      final walled = buildSampleBoard(
        walls: {WallEdge.between(const Position(1, 1), Direction.right)},
      );

      expect(buildSampleBoard(), isNot(walled));
    });

    test('withBlocks 는 벽을 유지한다', () {
      final walls = {WallEdge.between(const Position(1, 1), Direction.right)};
      final board = buildSampleBoard(walls: walls);

      expect(board.withBlocks(const []).walls, walls);
    });

    test('블록 위치가 다르면 다른 판이다', () {
      final a = buildSampleBoard();
      final b = buildSampleBoard(
        blocks: const [
          Block(id: 0, type: BlockType.player, position: Position(4, 1)),
          Block(id: 1, type: BlockType.normal, position: Position(5, 1)),
        ],
      );

      expect(a, isNot(b));
    });
  });
}
