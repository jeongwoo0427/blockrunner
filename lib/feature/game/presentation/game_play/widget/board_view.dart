import 'dart:math';

import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/block_tile.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_painter.dart';
import 'package:flutter/material.dart';

/// 보드를 그린다. **셀 좌표계를 계산하는 유일한 곳이다.**
///
/// 페인터와 블록 위젯이 같은 좌표계를 써야 하므로, 셀 크기를 두 곳에서
/// 각자 계산하게 두면 언젠가 어긋난다. 여기서 계산해 페인터에도 넘긴다.
class BoardView extends StatelessWidget {
  const BoardView({super.key, required this.board});

  final BoardState board;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available = min(constraints.maxWidth, constraints.maxHeight);
          final extent = min(available, AppConstants.maxBoardExtent);

          // 격자 바깥에 외곽 프레임이 들어갈 여백을 양쪽으로 한 겹씩 남긴다.
          // 프레임이 칸 안쪽을 파고들면 가장자리 칸만 여백이 비대칭이 되어
          // 블록이 중앙에서 밀려 보인다.
          final longSide = max(board.rowCount, board.colCount);
          final cell = extent / (longSide + 2 * Spacing.wallWidthRatio);
          final margin = cell * Spacing.wallWidthRatio;

          return SizedBox(
            width: cell * board.colCount + 2 * margin,
            height: cell * board.rowCount + 2 * margin,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: BoardPainter(
                      board: board,
                      colors: context.boardColors,
                      cell: cell,
                      origin: Offset(margin, margin),
                    ),
                  ),
                ),
                for (final block in board.blocks)
                  Positioned(
                    // 06 에서 AnimatedPositioned 로 바꿀 때 같은 블록으로
                    // 추적되려면 안정적인 키가 있어야 한다.
                    key: ValueKey(block.id),
                    left: margin + block.position.col * cell,
                    top: margin + block.position.row * cell,
                    width: cell,
                    height: cell,
                    child: BlockTile(type: block.type, size: cell),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
