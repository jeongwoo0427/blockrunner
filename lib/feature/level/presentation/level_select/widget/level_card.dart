import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/feature/level/domain/entity/level.dart';
import 'package:blockrunner/feature/progress/domain/entity/level_progress.dart';
import 'package:flutter/material.dart';

/// 레벨 하나를 나타내는 카드.
///
/// **잠긴 카드도 누를 수 있게 둔다.** 아예 못 누르게 하면 왜 안 되는지 알 수 없다.
/// 눌리되 이동하지 않고 안내만 띄운다 (`08-level-select` §5).
class LevelCard extends StatelessWidget {
  const LevelCard({
    super.key,
    required this.level,
    required this.progress,
    required this.isUnlocked,
    required this.onTap,
  });

  final Level level;

  /// 클리어한 적이 없으면 `null`.
  final LevelProgress? progress;

  final bool isUnlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = this.progress;

    return Card(
      // 잠긴 카드는 눌리는 느낌만 남기고 가라앉힌다.
      color: isUnlocked ? null : theme.colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: isUnlocked ? 1 : 0.45,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isUnlocked)
                  Icon(
                    Icons.lock_rounded,
                    size: 28,
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                else
                  Text(
                    '${level.number}',
                    style: theme.textTheme.headlineSmall,
                  ),
                const SizedBox(height: Spacing.xs),
                // 잠긴 레벨은 이름도 가린다 — 앞으로 무엇이 나오는지가 스포일러다.
                Text(
                  isUnlocked ? (level.name ?? '레벨 ${level.number}') : '잠김',
                  style: theme.textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isUnlocked) ...[
                  const SizedBox(height: Spacing.xs),
                  _Stars(count: progress?.stars ?? 0),
                  Text(
                    // 미클리어면 목표를, 클리어했으면 자기 기록을 보여준다.
                    progress == null
                        ? '최소 ${level.minMoves}수'
                        : '${progress.bestMoveCount}수',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 별 세 개 중 [count] 개를 채운다. 미클리어(0개)면 전부 빈 별이다.
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
            size: 16,
            color: i <= count
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
      ],
    );
  }
}
