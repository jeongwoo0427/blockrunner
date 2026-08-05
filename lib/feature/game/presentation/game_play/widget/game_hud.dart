import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/core/theme/data/text_styles.dart';
import 'package:flutter/material.dart';

/// 이동 횟수와 다시하기.
///
/// **방향 버튼은 두지 않는다** (기획서 §6). 조작은 스와이프 · 방향키 · WASD ·
/// 마우스 드래그로 판 위에서 직접 한다.
///
/// **되돌리기도 두지 않는다** (기획서 §5.1). 화면에 남는 조작은 실수를 되돌리는
/// 안전장치인 다시하기 하나뿐이다.
///
/// **좌우 폭은 스스로 정하지 않는다.** 보드 폭에 맞춰야 하므로(기획서 §6.2)
/// 부모가 폭을 주고, 여기서는 양 끝에 붙이기만 한다. 안쪽에 좌우 여백을 또
/// 두면 보드 끝과 어긋난다.
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
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
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
