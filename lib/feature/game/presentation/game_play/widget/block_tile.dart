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

    return Padding(
      padding: EdgeInsets.all(size * 0.06),
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
                  dimension: size * 0.34,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.background,
                        width: size * 0.08,
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
