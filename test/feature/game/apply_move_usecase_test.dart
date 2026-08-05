import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/entity/move_result.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/domain/entity/wall_edge.dart';
import 'package:blockrunner/feature/game/domain/usecase/game_usecases/apply_move_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import 'board_ascii.dart';

const applyMove = ApplyMoveUsecase();

/// [before] 판에 [direction] 을 입력하면 [after] 판이 되는지 검증한다.
///
/// 목표 칸 위의 블록은 ASCII 에서 `@`/`O` 로 찍히므로(바닥이 가려짐), 클리어 여부는
/// 반환된 [MoveResult] 의 `board.isCleared` 로 따로 확인한다.
MoveResult expectMove({
  required List<String> before,
  required Direction direction,
  required List<String> after,
  Set<WallEdge> walls = const {},
  bool moved = true,
}) {
  final result = applyMove(parseBoard(before, walls: walls), direction);

  expect(formatBoard(result.board), after, reason: '${direction.name} 입력 결과');
  expect(result.moved, moved, reason: '${direction.name} 입력의 moved 판정');

  return result;
}

void main() {
  group('기본 — 빈 판에서 맵 끝까지 미끄러진다', () {
    const before = ['.....', '.....', '..@..', '.....', '.....'];

    test('오른쪽', () {
      expectMove(
        before: before,
        direction: Direction.right,
        after: ['.....', '.....', '....@', '.....', '.....'],
      );
    });

    test('왼쪽', () {
      expectMove(
        before: before,
        direction: Direction.left,
        after: ['.....', '.....', '@....', '.....', '.....'],
      );
    });

    test('위', () {
      expectMove(
        before: before,
        direction: Direction.up,
        after: ['..@..', '.....', '.....', '.....', '.....'],
      );
    });

    test('아래', () {
      expectMove(
        before: before,
        direction: Direction.down,
        after: ['.....', '.....', '.....', '.....', '..@..'],
      );
    });
  });

  group('벽', () {
    test('벽 직전에 멈춘다', () {
      expectMove(
        before: ['@.#..'],
        direction: Direction.right,
        after: ['.@#..'],
      );
    });

    test('벽에 붙어 있으면 움직이지 못한다', () {
      expectMove(
        before: ['@#...'],
        direction: Direction.right,
        after: ['@#...'],
        moved: false,
      );
    });

    test('벽은 통과하지 못한다 — 벽 너머 빈 칸으로 가지 않는다', () {
      expectMove(
        before: ['..@#.'],
        direction: Direction.right,
        after: ['..@#.'],
        moved: false,
      );
    });
  });

  group('경계 벽', () {
    // (0,3) 과 (0,4) 사이를 막는 벽.
    final wallRightOf3 = {
      WallEdge.between(const Position(0, 3), Direction.right),
    };

    test('경계에 막혀 그 앞 칸에 멈춘다', () {
      expectMove(
        before: ['@.....'],
        walls: wallRightOf3,
        direction: Direction.right,
        after: ['...@..'],
      );
    });

    test('벽 양쪽 칸이 모두 살아 있다 — 칸 벽과 다른 점', () {
      // 왼쪽에서 온 블록은 (0,3) 에, 오른쪽에서 온 블록은 (0,4) 에 선다.
      expectMove(
        before: ['@....O'],
        walls: wallRightOf3,
        direction: Direction.left,
        after: ['@...O.'],
      );
    });

    test('반대 방향에서도 같은 벽에 막힌다', () {
      // (0,3) 의 오른쪽 벽 == (0,4) 의 왼쪽 벽. 정규화가 되어 있어야 통과한다.
      expectMove(
        before: ['.....@'],
        walls: wallRightOf3,
        direction: Direction.left,
        after: ['....@.'],
      );
    });

    test('벽에 붙어 있으면 움직이지 못한다', () {
      expectMove(
        before: ['...@..'],
        walls: wallRightOf3,
        direction: Direction.right,
        after: ['...@..'],
        moved: false,
      );
    });

    test('경계 벽 앞에서 멈춰 구멍을 피한다', () {
      final result = expectMove(
        before: ['@...X.'],
        walls: wallRightOf3,
        direction: Direction.right,
        after: ['...@X.'],
      );

      expect(result.board.hasPlayer, isTrue);
      expect(result.fellIntoHole, isEmpty);
    });

    test('세로 경계 벽도 같은 규칙이다', () {
      expectMove(
        before: ['@', '.', '.', '.'],
        walls: {WallEdge.between(const Position(1, 0), Direction.down)},
        direction: Direction.down,
        after: ['.', '@', '.', '.'],
      );
    });

    test('경계 벽에 막혀 목표 칸에 멈추면 클리어다', () {
      final result = expectMove(
        before: ['@..G..'],
        walls: {WallEdge.between(const Position(0, 3), Direction.right)},
        direction: Direction.right,
        after: ['...@..'],
      );

      expect(result.board.isCleared, isTrue);
    });
  });

  group('블록 — 처리 순서', () {
    test('기획서 §4.1 — 앞쪽 블록부터 처리해야 뒤 블록이 그 앞에 멈춘다', () {
      final result = expectMove(
        before: ['@O...G'],
        direction: Direction.right,
        after: ['....@O'],
      );

      // 플레이어는 목표 바로 앞에 멈췄고 목표 칸은 일반 블록이 점유했다.
      expect(result.board.isCleared, isFalse);
    });

    test('플레이어가 앞이어도 결과 위치는 뒤바뀌지 않는다', () {
      expectMove(
        before: ['O@....'],
        direction: Direction.right,
        after: ['....O@'],
      );
    });

    test('여러 블록이 줄을 선다', () {
      expectMove(
        before: ['@OO...'],
        direction: Direction.right,
        after: ['...@OO'],
      );
    });

    test('블록이 벽 앞에 줄을 선다', () {
      expectMove(
        before: ['@.O.#.'],
        direction: Direction.right,
        after: ['..@O#.'],
      );
    });

    test('세로 방향도 같은 순서 규칙을 따른다', () {
      expectMove(
        before: ['@', 'O', '.', '.'],
        direction: Direction.down,
        after: ['.', '.', '@', 'O'],
      );
    });
  });

  group('목표', () {
    test('목표 칸을 지나쳐 더 가면 클리어가 아니다', () {
      final result = expectMove(
        before: ['@.G..'],
        direction: Direction.right,
        after: ['..G.@'],
      );

      expect(result.board.isCleared, isFalse);
    });

    test('목표 칸에 멈추면 클리어다', () {
      final result = expectMove(
        before: ['@.G#.'],
        direction: Direction.right,
        after: ['..@#.'],
      );

      expect(result.board.isCleared, isTrue);
    });

    test('일반 블록이 목표 칸에 멈춘 것은 클리어가 아니다', () {
      final result = expectMove(
        before: ['@#OG#.'],
        direction: Direction.right,
        after: ['@#.O#.'],
      );

      expect(result.board.isCleared, isFalse);
    });
  });

  group('구멍', () {
    test('기획서 §4.2 — 플레이어가 지나가다 빠진다', () {
      final result = expectMove(
        before: ['.O.X.@'],
        direction: Direction.left,
        after: ['O..X..'],
      );

      expect(result.board.hasPlayer, isFalse);
      expect(result.board.isCleared, isFalse);
      expect(result.fellIntoHole, hasLength(1));
      // 낙하 연출이 "어디서 사라졌는지" 를 알아야 하므로 도착 위치는 구멍 칸이다.
      expect(result.to[result.fellIntoHole.single], const Position(0, 3));
    });

    test('일반 블록만 빠지고 플레이어는 남는다', () {
      final result = expectMove(
        before: ['@#O.X.'],
        direction: Direction.right,
        after: ['@#..X.'],
      );

      expect(result.board.hasPlayer, isTrue);
      expect(result.fellIntoHole, [1], reason: '행 우선 순서로 @ 가 0, O 가 1');
    });

    test('구멍은 소모되지 않는다 — 두 블록이 연달아 빠진다', () {
      final result = expectMove(
        before: ['OO.X..'],
        direction: Direction.right,
        after: ['...X..'],
      );

      expect(result.fellIntoHole, hasLength(2));
      expect(result.board.blocks, isEmpty);
    });

    test('구멍 앞에서 멈추면 빠지지 않는다', () {
      final result = expectMove(
        before: ['@.#X..'],
        direction: Direction.right,
        after: ['.@#X..'],
      );

      expect(result.board.hasPlayer, isTrue);
      expect(result.fellIntoHole, isEmpty);
    });
  });

  group('무효 입력', () {
    test('이미 그 방향 끝에 있으면 움직이지 않는다', () {
      final result = expectMove(
        before: ['....@'],
        direction: Direction.right,
        after: ['....@'],
        moved: false,
      );

      expect(result.fellIntoHole, isEmpty);
    });

    test('모든 블록이 그 방향 끝에 몰려 있으면 무효다', () {
      expectMove(
        before: ['...@O'],
        direction: Direction.right,
        after: ['...@O'],
        moved: false,
      );
    });

    test('무효 입력이면 보드 인스턴스를 그대로 돌려준다', () {
      final board = parseBoard(['....@']);
      final result = applyMove(board, Direction.right);

      expect(result.moved, isFalse);
      expect(result.board, same(board));
    });
  });

  group('회귀 — 기획서 §4.3 6×6 레벨 2수 클리어', () {
    const level = [
      '......',
      '.@....',
      '.O....',
      '......',
      '..G#..',
      '......',
    ];

    test('1수 ↓ — O 가 먼저 바닥에 정착하고 @ 가 그 위에 멈춘다', () {
      expectMove(
        before: level,
        direction: Direction.down,
        after: ['......', '......', '......', '......', '.@G#..', '.O....'],
      );
    });

    test('2수 → — @ 가 벽에 막혀 목표 칸에 멈춘다', () {
      final first = applyMove(parseBoard(level), Direction.down);
      final second = applyMove(first.board, Direction.right);

      expect(formatBoard(second.board), [
        '......',
        '......',
        '......',
        '......',
        '..@#..',
        '.....O',
      ]);
      expect(second.board.isCleared, isTrue);
    });

    test('1수로는 클리어할 수 없다', () {
      final board = parseBoard(level);

      for (final direction in Direction.values) {
        expect(
          applyMove(board, direction).board.isCleared,
          isFalse,
          reason: '$direction 한 수로 클리어되면 최소 이동 횟수 2가 거짓이 된다',
        );
      }
    });
  });

  group('MoveResult 의 from / to', () {
    test('움직이지 않은 블록도 포함해 전부 담는다', () {
      // @ 는 벽에 막혀 제자리, O 는 맵 끝까지 간다.
      final result = expectMove(
        before: ['@#O...'],
        direction: Direction.right,
        after: ['@#...O'],
      );

      expect(result.from, {0: const Position(0, 0), 1: const Position(0, 2)});
      expect(result.to, {0: const Position(0, 0), 1: const Position(0, 5)});
    });

    test('기획서 §4.1 의 출발·도착 좌표', () {
      final result = expectMove(
        before: ['@O...G'],
        direction: Direction.right,
        after: ['....@O'],
      );

      expect(result.from[0], const Position(0, 0));
      expect(result.to[0], const Position(0, 4));
      expect(result.from[1], const Position(0, 1));
      expect(result.to[1], const Position(0, 5));
      expect(result.fellIntoHole, isEmpty);
    });
  });

  group('경계', () {
    test('1×1 판은 어느 방향으로도 움직이지 않는다', () {
      for (final direction in Direction.values) {
        expectMove(
          before: ['@'],
          direction: direction,
          after: ['@'],
          moved: false,
        );
      }
    });

    test('1행 판에서 세로 입력은 무효다', () {
      expectMove(
        before: ['.@...'],
        direction: Direction.up,
        after: ['.@...'],
        moved: false,
      );
    });

    test('블록이 하나도 없으면 무효다', () {
      expectMove(
        before: ['..#..'],
        direction: Direction.right,
        after: ['..#..'],
        moved: false,
      );
    });

    test('정사각형이 아닌 판도 지원한다', () {
      expectMove(
        before: ['@....', '.....', '.....'],
        direction: Direction.down,
        after: ['.....', '.....', '@....'],
      );
    });
  });
}
