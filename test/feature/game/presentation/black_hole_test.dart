import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/black_hole_painter.dart';
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

    testWidgets('일반 블록은 돌지 않는다', (tester) async {
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
}
