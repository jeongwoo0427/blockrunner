import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/black_hole_painter.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/block_tile.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/strings_harness.dart';

/// 블랙홀 연출 (12-ui-polish §5).
void main() {
  /// 1행 4열 판. [holes] 위치의 바닥이 블랙홀이다.
  BoardState boardWith({
    required List<int> holes,
    List<Block> blocks = const [],
  }) => BoardState(
    rowCount: 1,
    colCount: 4,
    floors: [
      [
        for (var col = 0; col < 4; col++)
          holes.contains(col) ? FloorType.blackHole : FloorType.empty,
      ],
    ],
    blocks: blocks,
  );

  Future<void> pumpBoard(
    WidgetTester tester,
    BoardState board, {
    List<Block> falling = const [],
    bool animating = false,
  }) async {
    await tester.pumpWidget(
      withStrings(
        Scaffold(
          body: BoardView(
            board: board,
            fallingBlocks: falling,
            isAnimating: animating,
          ),
        ),
      ),
    );
  }

  BlackHolePainter? painterOf(WidgetTester tester) {
    final found = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is BlackHolePainter,
    );
    if (found.evaluate().isEmpty) return null;

    return (tester.widget<CustomPaint>(found)).painter as BlackHolePainter;
  }

  group('회전', () {
    testWidgets('블랙홀이 없는 판에서는 레이어 자체가 없다', (tester) async {
      // 배터리 문제이기도 하고, 도는 컨트롤러가 있으면 pumpAndSettle 이
      // 끝나지 않는다.
      await pumpBoard(tester, boardWith(holes: const []));

      expect(painterOf(tester), isNull);
    });

    testWidgets('블랙홀이 있으면 계속 돈다', (tester) async {
      await pumpBoard(tester, boardWith(holes: const [2]));

      final start = painterOf(tester)!.turns;
      await tester.pump(AppConstants.blackHoleRotationDuration ~/ 4);
      final quarter = painterOf(tester)!.turns;

      expect(quarter, greaterThan(start));
      expect(quarter, closeTo(0.25, 0.02), reason: '4분의 1바퀴쯤 돌아 있어야 한다');
    });

    testWidgets('한 바퀴를 돌면 제자리로 온다', (tester) async {
      await pumpBoard(tester, boardWith(holes: const [1]));

      await tester.pump(AppConstants.blackHoleRotationDuration);
      expect(painterOf(tester)!.turns, closeTo(0, 0.02));
    });

    testWidgets('동작 줄이기를 켜면 멈춰 있다', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: withStrings(
            Scaffold(body: BoardView(board: boardWith(holes: const [2]))),
          ),
        ),
      );

      final start = painterOf(tester)!.turns;
      await tester.pump(AppConstants.blackHoleRotationDuration ~/ 2);

      expect(painterOf(tester)!.turns, start);
    });
  });

  group('빨려 들어가기', () {
    /// [block] 이 빠지는 중일 때 그 타일에 물린 회전 애니메이션.
    Animation<double> rotationOf(WidgetTester tester) => tester
        .widget<RotationTransition>(find.byType(RotationTransition).first)
        .turns;

    testWidgets('플레이어는 블랙홀과 같은 각도로 돈다', (tester) async {
      final board = boardWith(holes: const [3]);
      await pumpBoard(
        tester,
        board,
        falling: const [
          Block(id: 0, type: BlockType.player, position: Position(0, 3)),
        ],
        animating: true,
      );

      await tester.pump(AppConstants.blackHoleRotationDuration ~/ 4);

      // 어긋나면 빨려 들어가는 것으로 보이지 않고 따로 도는 두 물체가 된다.
      expect(rotationOf(tester).value, closeTo(painterOf(tester)!.turns, 0.001));
      expect(rotationOf(tester).value, greaterThan(0));
    });

    testWidgets('동료 블록은 돌지 않는다', (tester) async {
      await pumpBoard(
        tester,
        boardWith(holes: const [3]),
        falling: const [
          Block(id: 0, type: BlockType.normal, position: Position(0, 3)),
        ],
        animating: true,
      );

      await tester.pump(AppConstants.blackHoleRotationDuration ~/ 4);

      expect(rotationOf(tester).value, 0);
    });

    testWidgets('판 위의 블록도 돌지 않는다', (tester) async {
      await pumpBoard(
        tester,
        boardWith(
          holes: const [3],
          blocks: const [
            Block(id: 0, type: BlockType.player, position: Position(0, 0)),
          ],
        ),
      );

      await tester.pump(AppConstants.blackHoleRotationDuration ~/ 4);

      expect(rotationOf(tester).value, 0, reason: '멀쩡한 플레이어가 돌면 안 된다');
    });
  });

  group('삼켜진 구멍 (기획서 §3.3)', () {
    /// 블랙홀은 블록을 삼키는 순간 **판에서** 사라지지만, 그때 화면에서는 아직
    /// 블록이 빨려 드는 중이다 — 플레이어는 2초에 걸쳐 돈다.
    testWidgets('판에서 사라진 구멍도 낙하가 끝날 때까지 그려진다', (tester) async {
      // 바닥에는 구멍이 없다. 엔진이 이미 지운 뒤의 판이다.
      await pumpBoard(
        tester,
        boardWith(holes: const []),
        falling: const [
          Block(id: 0, type: BlockType.player, position: Position(0, 2)),
        ],
        animating: true,
      );

      final painter = painterOf(tester);
      expect(painter, isNotNull, reason: '구멍이 지워졌다고 회전 레이어까지 없애면 빈 바닥 위에서 돈다');
      expect(painter!.vanishing, {const Position(0, 2)});
    });

    testWidgets('낙하가 끝나면 구멍도 함께 사라진다', (tester) async {
      // 화면이 fallingBlocks 를 비우는 순간이 곧 구멍이 사라지는 순간이다.
      await pumpBoard(tester, boardWith(holes: const []));

      expect(painterOf(tester), isNull);
    });

    /// 빠지는 블록 자신에게 걸린 페이드. 구멍과 같은 값이어야 한다.
    double blockOpacity(WidgetTester tester) => tester
        .widget<FadeTransition>(
          find
              .ancestor(
                of: find.byType(BlockTile),
                matching: find.byType(FadeTransition),
              )
              .first,
        )
        .opacity
        .value;

    testWidgets('구멍은 블록과 정확히 같은 속도로 사라진다', (tester) async {
      // **판 위에 있던 상태에서 시작한다.** 처음부터 빠지는 채로 만들면 암시적
      // 애니메이션이 목표값부터 그려져(위 `_noRotation` 주석과 같은 이유) 아무것도
      // 재생되지 않는다 — 실제로도 블록은 먼저 판 위에 있다가 빠진다.
      final block = const Block(
        id: 0,
        type: BlockType.normal,
        position: Position(0, 2),
      );
      await pumpBoard(tester, boardWith(holes: const [2], blocks: [block]));

      // 엔진이 구멍을 지우고 블록을 낙하 목록으로 옮긴 뒤의 판.
      await pumpBoard(
        tester,
        boardWith(holes: const []),
        falling: [block],
        animating: true,
      );

      // 슬라이드 구간에는 아직 아무것도 사라지지 않는다 (기획서 §7).
      expect(painterOf(tester)!.vanishProgress, 0);
      expect(blockOpacity(tester), 1);

      await tester.pump(AppConstants.moveAnimationDuration);
      await tester.pump(AppConstants.fallAnimationDuration ~/ 2);

      final half = painterOf(tester)!.vanishProgress;
      expect(half, greaterThan(0));
      expect(half, lessThan(1));
      // 블록이 절반 흐려졌으면 구멍도 절반 사라져 있어야 한다.
      expect(half, closeTo(1 - blockOpacity(tester), 0.001));

      await tester.pump(AppConstants.fallAnimationDuration);
      expect(painterOf(tester)!.vanishProgress, 1);
      expect(blockOpacity(tester), 0);
    });
  });
}
