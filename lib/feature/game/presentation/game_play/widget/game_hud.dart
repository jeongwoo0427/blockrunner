import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/core/theme/data/text_styles.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:flutter/material.dart';

/// 이동 횟수와 조작 버튼.
///
/// **방향 버튼은 임시다.** 스와이프·키보드 입력은 `05-input` 에서 붙이고,
/// 그때 이 버튼은 보조 수단으로 남긴다.
class GameHud extends StatelessWidget {
  const GameHud({
    super.key,
    required this.moveCount,
    required this.minMoves,
    required this.onDirection,
    required this.onReset,
  });

  final int moveCount;
  final int minMoves;
  final ValueChanged<Direction> onDirection;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$moveCount', style: AppTextStyles.counter),
              const SizedBox(width: Spacing.sm),
              Text('/ 최소 $minMoves수', style: AppTextStyles.counterLabel),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          _DirectionPad(onDirection: onDirection),
          const SizedBox(height: Spacing.sm),
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh),
            label: const Text('다시하기'),
          ),
        ],
      ),
    );
  }
}

class _DirectionPad extends StatelessWidget {
  const _DirectionPad({required this.onDirection});

  final ValueChanged<Direction> onDirection;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _button(Direction.up, Icons.keyboard_arrow_up, '위'),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _button(Direction.left, Icons.keyboard_arrow_left, '왼쪽'),
            const SizedBox(width: Spacing.xl),
            _button(Direction.right, Icons.keyboard_arrow_right, '오른쪽'),
          ],
        ),
        _button(Direction.down, Icons.keyboard_arrow_down, '아래'),
      ],
    );
  }

  Widget _button(Direction direction, IconData icon, String label) {
    return IconButton.filledTonal(
      onPressed: () => onDirection(direction),
      icon: Icon(icon),
      tooltip: label,
    );
  }
}
