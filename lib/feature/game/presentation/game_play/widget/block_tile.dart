import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:flutter/material.dart';

/// 격자 한 칸을 차지하는 블록.
class BlockTile extends StatelessWidget {
  const BlockTile({super.key, required this.type, required this.size});

  final BlockType type;

  /// 셀 한 변의 길이. 모서리 둥글기와 안쪽 표식 크기가 여기에 비례한다.
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.boardColors;
    final isPlayer = type == BlockType.player;
    // 실제로 칠해지는 사각형의 한 변. 안쪽 표식은 칸이 아니라 여기에 비례해야
    // 블록 크기를 조정해도 표식 비율이 그대로 유지된다.
    final tile = size * (1 - 2 * Spacing.blockInsetRatio);

    return Padding(
      padding: EdgeInsets.all(size * Spacing.blockInsetRatio),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isPlayer ? colors.playerBlock : colors.normalBlock,
          borderRadius: BorderRadius.circular(size * Spacing.blockRadiusRatio),
        ),
        // 플레이어를 색만으로 구분하면 색각 이상에서 일반 블록과 뒤섞인다.
        // 안쪽 링을 넣어 형태로도 구분되게 한다.
        child: isPlayer
            ? Center(
                child: SizedBox.square(
                  dimension: tile * 0.39,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.background,
                        width: tile * 0.09,
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
