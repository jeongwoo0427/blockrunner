import 'package:blockrunner/core/i18n/app_strings_scope.dart';
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
    required this.stars,
    required this.hasNextLevel,
    required this.onReset,
    required this.onNextLevel,
    required this.onBackToLevelSelect,
  });

  /// `false` 면 플레이어가 구멍에 빠진 상태다.
  final bool isCleared;

  final int moveCount;
  final int minMoves;

  /// 이번 판의 별점 1~3 (기획서 §5.2). 소실 상태에서는 쓰이지 않는다.
  final int stars;

  final bool hasNextLevel;

  final VoidCallback onReset;
  final VoidCallback onNextLevel;
  final VoidCallback onBackToLevelSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.strings;

    return ColoredBox(
      color: theme.colorScheme.surface.withValues(alpha: 0.82),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isCleared ? strings.cleared : strings.fellIntoHole,
                style: theme.textTheme.headlineSmall,
              ),
              if (isCleared) ...[
                const SizedBox(height: Spacing.md),
                _Stars(count: stars),
              ],
              const SizedBox(height: Spacing.sm),
              Text(
                // 되돌리기가 없으므로 구멍에 빠지면 처음부터다 (기획서 §3.5).
                isCleared
                    ? strings.clearedSummary(moveCount, minMoves)
                    : strings.retryHint,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: Spacing.lg),
              Wrap(
                spacing: Spacing.sm,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: onBackToLevelSelect,
                    child: Text(strings.backToList),
                  ),
                  OutlinedButton(onPressed: onReset, child: Text(strings.reset)),
                  if (isCleared && hasNextLevel)
                    FilledButton(
                      onPressed: onNextLevel,
                      child: Text(strings.nextLevel),
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

/// 별 세 개 중 [count] 개를 채운다. 빈 별도 그려야 "몇 개 중 몇 개" 가 읽힌다.
class _Stars extends StatelessWidget {
  const _Stars({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 3; i++)
          Icon(
            i <= count ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 36,
            color: i <= count
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
      ],
    );
  }
}
