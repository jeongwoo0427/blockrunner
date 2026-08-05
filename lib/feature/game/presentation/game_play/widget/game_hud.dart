import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/core/theme/data/text_styles.dart';
import 'package:flutter/material.dart';

/// 이동 횟수와 다시하기.
///
/// **방향 버튼은 두지 않는다** (기획서 §6). 조작은 스와이프 · 방향키 · WASD ·
/// 마우스 드래그로 판 위에서 직접 한다. 화면에 남는 조작은 실수를 되돌리는
/// 안전장치인 다시하기 하나뿐이다.
class GameHud extends StatelessWidget {
  const GameHud({
    super.key,
    required this.moveCount,
    required this.minMoves,
    required this.onReset,
  });

  final int moveCount;
  final int minMoves;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$moveCount', style: AppTextStyles.counter),
              const SizedBox(width: Spacing.sm),
              Text('/ 최소 $minMoves수', style: AppTextStyles.counterLabel),
            ],
          ),
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
