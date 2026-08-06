import 'package:blockrunner/core/i18n/app_strings_scope.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/core/widget/game_button.dart';
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
    final strings = context.strings;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
      // **`Row` 가 아니라 `Wrap` 이다.** 한 줄에 안 들어가면 두 줄로 접힌다.
      //
      // 넘치는 경우가 실제로 있다 — 프랑스어 `Recommencer` 는 한국어 `다시하기`
      // 의 세 배 폭이고, 접근성 글꼴을 키우면 어느 언어든 넘친다. 말줄임으로
      // 처리하지 않는 이유는 **글자가 잘리면 안 되기 때문이다**(10-responsive
      // 완료 기준). 접히면 읽을 수는 있다.
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: Spacing.sm,
        runSpacing: Spacing.xs,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$moveCount', style: AppTextStyles.counter),
              const SizedBox(width: Spacing.sm),
              Text(
                strings.hudMinMovesLabel(minMoves),
                style: AppTextStyles.counterLabel,
              ),
            ],
          ),
          GameButton(
            label: strings.reset,
            onPressed: onReset,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }
}
