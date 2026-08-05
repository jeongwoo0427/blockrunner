import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:flutter/material.dart';

/// 클리어 · 플레이어 소실 결과를 보드 위에 얹는 레이어.
///
/// 다이얼로그가 아니라 상태에서 파생되는 레이어다. Screen 이 Riverpod 도
/// `showDialog` 도 모르는 채로 남고, 보드가 뒤에 계속 보인다.
class ResultOverlay extends StatelessWidget {
  const ResultOverlay({
    super.key,
    required this.isCleared,
    required this.moveCount,
    required this.minMoves,
    required this.hasNextLevel,
    required this.onReset,
    required this.onNextLevel,
    required this.onBackToLevelSelect,
  });

  /// `false` 면 플레이어가 구멍에 빠진 상태다.
  final bool isCleared;

  final int moveCount;
  final int minMoves;
  final bool hasNextLevel;
  final VoidCallback onReset;
  final VoidCallback onNextLevel;
  final VoidCallback onBackToLevelSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surface.withValues(alpha: 0.82),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isCleared ? '클리어!' : '구멍에 빠졌다',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                isCleared ? '$moveCount수 / 최소 $minMoves수' : '다시 시도해 보자',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: Spacing.lg),
              Wrap(
                spacing: Spacing.sm,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: onBackToLevelSelect,
                    child: const Text('목록으로'),
                  ),
                  OutlinedButton(
                    onPressed: onReset,
                    child: const Text('다시하기'),
                  ),
                  if (isCleared && hasNextLevel)
                    FilledButton(
                      onPressed: onNextLevel,
                      child: const Text('다음 레벨'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
