import 'package:blockrunner/core/i18n/app_strings_scope.dart';
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
    this.preview,
  });

  final Level level;

  /// 그 레벨의 판을 작게 그린 위젯 (12-ui-polish §2).
  ///
  /// **여기서 만들지 않고 받는다.** 판은 `game` 이 소유하는데 이 화면은
  /// `level` 에 있어서, 직접 만들면 `#22` 에서 끊었던 순환이 되살아난다.
  /// 조립은 두 feature 를 다 아는 라우터가 한다.
  final Widget? preview;

  /// 클리어한 적이 없으면 `null`.
  final LevelProgress? progress;

  final bool isUnlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.strings;
    final progress = this.progress;
    final medal = _medalColor(theme, progress?.stars ?? 0);

    return Card(
      // 잠긴 카드는 눌리는 느낌만 남기고 가라앉힌다.
      color: isUnlocked ? null : theme.colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      // 별을 많이 딸수록 테두리가 올라간다. 목록을 훑을 때 성취가 색으로 읽힌다.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.md),
        side: medal == null
            ? BorderSide.none
            : BorderSide(color: medal, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: isUnlocked ? 1 : 0.45,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (preview != null)
                  Expanded(child: preview!)
                else if (!isUnlocked)
                  Icon(
                    Icons.lock_rounded,
                    size: 28,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                const SizedBox(height: Spacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${level.number}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    // 잠긴 레벨은 이름도 가린다 — 앞으로 무엇이 나오는지가 스포일러다.
                    //
                    // **두 줄까지 준다.** 한 줄로 묶으면 영어 `Hidden Ledge`,
                    // 프랑스어 `Rebord caché` 가 카드 폭에서 잘린다.
                    Flexible(
                      child: Text(
                        isUnlocked
                            ? strings.levelName(level.number)
                            : strings.locked,
                        style: theme.textTheme.labelMedium,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (isUnlocked) ...[
                  const SizedBox(height: Spacing.xs),
                  _Stars(count: progress?.stars ?? 0),
                  Text(
                    // 미클리어면 목표를, 클리어했으면 자기 기록을 보여준다.
                    progress == null
                        ? strings.minMovesLabel(level.minMoves)
                        : strings.movesLabel(progress.bestMoveCount),
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

  /// 별 개수에 따른 테두리 색. 미클리어면 테두리를 두지 않는다.
  ///
  /// 금·은·동을 그대로 쓰면 다크 테마에서 탁해지므로 테마 색에서 뽑는다.
  Color? _medalColor(ThemeData theme, int stars) => switch (stars) {
    3 => theme.colorScheme.tertiary,
    2 => theme.colorScheme.primary,
    1 => theme.colorScheme.outline,
    _ => null,
  };
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
