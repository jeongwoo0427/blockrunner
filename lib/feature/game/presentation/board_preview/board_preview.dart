import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/game_di.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_metrics.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_preview_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 레벨 카드 안에 그 레벨의 판을 작게 그린다 (12-ui-polish §2).
///
/// **`game` 이 소유한다.** 레벨 선택 화면은 `level` 에 있고 판은 `game` 이
/// 가지므로, 화면이 이것을 직접 만들면 `level → game` 순환이 된다. 화면은
/// 위젯을 만들지 않고 **함수로 받으며 조립은 라우터가 한다.**
///
/// [BoardView] 를 재사용하지 않는다 — 미리보기는 움직이지 않으므로 블록 위젯도
/// 회전 컨트롤러도 필요 없고, 카드 7장마다 그것을 얹으면 목록이 무거워진다.
class BoardPreview extends ConsumerWidget {
  const BoardPreview({
    super.key,
    required this.levelNumber,
    this.isSilhouette = false,
  });

  final int levelNumber;

  /// 잠긴 레벨은 판 모양이 곧 스포일러라 실루엣으로만 보여준다.
  final bool isSilhouette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BoardState board;
    try {
      board = ref.read(gameUsecasesProvider).getMap(levelNumber).initialBoard;
    } catch (_) {
      // 목록에 있는데 맵이 없는 경우는 테스트가 막고 있다. 그래도 카드 하나
      // 때문에 목록 전체가 죽으면 안 되므로 빈 자리로 둔다.
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final metrics = BoardMetrics.fit(
            board: board,
            available: constraints.biggest,
          );

          return Center(
            child: SizedBox(
              width: metrics.width,
              height: metrics.height,
              child: CustomPaint(
                painter: BoardPreviewPainter(
                  board: board,
                  colors: context.boardColors,
                  cell: metrics.cell,
                  origin: metrics.origin,
                  isSilhouette: isSilhouette,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
