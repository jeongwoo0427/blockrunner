import 'dart:math';

import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/block_tile.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_painter.dart';
import 'package:flutter/material.dart';

/// 슬라이드가 끝난 뒤부터 낙하를 재생한다 (기획서 §7).
///
/// 전체 구간을 슬라이드+낙하로 잡고 앞부분을 [Interval] 로 비워 지연을 만든다.
/// 암시적 애니메이션에는 시작 지연이 없어서, 이렇게 하지 않으려면 타이머를
/// 하나 더 두고 두 단계를 손으로 이어붙여야 한다.
const Curve _fallCurve = Interval(
  AppConstants.fallStartFraction,
  1,
  curve: Curves.easeIn,
);

/// 보드를 그린다. **셀 좌표계를 계산하는 유일한 곳이다.**
///
/// 페인터와 블록 위젯이 같은 좌표계를 써야 하므로, 셀 크기를 두 곳에서
/// 각자 계산하게 두면 언젠가 어긋난다. 여기서 계산해 페인터에도 넘긴다.
class BoardView extends StatelessWidget {
  const BoardView({
    super.key,
    required this.board,
    this.fallingBlocks = const [],
    this.isAnimating = false,
  });

  final BoardState board;

  /// 구멍으로 사라지는 중인 블록. [board] 에는 없지만 연출이 끝날 때까지 그린다.
  final List<Block> fallingBlocks;

  /// 연출을 재생할 것인가.
  ///
  /// **암시적 애니메이션이라 이 플래그가 곧 "이번 변화를 보여줄지" 다.** 다시하기와
  /// 레벨 로드는 이 값이 `false` 인 채로 좌표가 바뀌므로 지속 시간이 0 이 되어
  /// 그대로 튄다 — 즉시 반영해야 한다는 기획서 §7 이 공짜로 지켜진다.
  final bool isAnimating;

  @override
  Widget build(BuildContext context) {
    // OS 의 "동작 줄이기" 를 켠 사용자에게는 연출을 건너뛴다. 게임 진행은 같다.
    final animates = isAnimating && !MediaQuery.disableAnimationsOf(context);
    final slide = animates ? AppConstants.moveAnimationDuration : Duration.zero;
    final whole = animates ? AppConstants.moveWithFallDuration : Duration.zero;

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
                // 빠지는 블록도 같은 목록에 섞어 그린다. 키로 추적되므로 판에서
                // 이 목록으로 옮겨와도 같은 위젯으로 남아 이어서 미끄러진다.
                for (final (block, isFalling) in [
                  for (final block in board.blocks) (block, false),
                  for (final block in fallingBlocks) (block, true),
                ])
                  AnimatedPositioned(
                    // 같은 블록으로 추적되려면 안정적인 키가 있어야 한다.
                    // 키가 없으면 목록 순서가 바뀔 때 블록끼리 정체가 뒤바뀐다.
                    key: ValueKey(block.id),
                    duration: slide,
                    curve: Curves.easeOut,
                    left: margin + block.position.col * cell,
                    top: margin + block.position.row * cell,
                    width: cell,
                    height: cell,
                    // 축소·페이드는 **항상 걸어둔다.** 빠지는 순간에만 감싸면
                    // 위젯이 새로 생겨 시작값부터 그려지고, 애니메이션 없이 사라진다.
                    child: AnimatedScale(
                      scale: isFalling ? 0.1 : 1,
                      duration: whole,
                      curve: _fallCurve,
                      child: AnimatedOpacity(
                        opacity: isFalling ? 0 : 1,
                        duration: whole,
                        curve: _fallCurve,
                        child: BlockTile(type: block.type, size: cell),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
