import 'package:blockrunner/core/i18n/app_strings_scope.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/core/widget/game_button.dart';
import 'package:blockrunner/feature/level/domain/entity/level.dart';
import 'package:blockrunner/feature/progress/domain/entity/level_progress.dart';
import 'package:flutter/material.dart';

/// 레벨 하나를 나타내는 카드.
///
/// **잠긴 카드도 누를 수 있게 둔다.** 아예 못 누르게 하면 왜 안 되는지 알 수 없다.
/// 눌리되 이동하지 않고 안내만 띄운다 (`08-level-select` §5).
class LevelCard extends StatefulWidget {
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
  State<LevelCard> createState() => _LevelCardState();
}

/// 카드가 가질 수 있는 세 가지 상태 (13-game-feel §2).
///
/// **색이 상태를 말한다.** 테두리를 없앤 뒤로 구분은 채움색이 전부 떠맡는다.
/// 별 개수는 별 줄이 따로 보여주므로 색까지 등급을 나타낼 필요는 없다.
enum _CardState {
  /// 아직 못 여는 레벨. 무채색이고 **판을 아예 보여주지 않는다.**
  locked,

  /// 지금 풀 수 있는 레벨. 플레이어 색을 그대로 입어 "여기가 당신 차례" 가 된다.
  playable,

  /// 이미 깬 레벨. 다른 색조로 넘어가 한눈에 갈린다.
  cleared,
}

class _LevelCardState extends State<LevelCard> {
  bool _down = false;

  _CardState get _state {
    if (!widget.isUnlocked) return _CardState.locked;
    return widget.progress == null ? _CardState.playable : _CardState.cleared;
  }

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final strings = context.strings;
    final progress = widget.progress;
    final level = widget.level;

    // 역할색을 그대로 쓴다. `*Container` 는 라이트 테마에서 너무 옅고,
    // primaryContainer 와 secondaryContainer 는 서로 거의 같은 색이라 갈리지 않는다.
    final (fill, ink) = switch (_state) {
      _CardState.locked => (colors.surfaceContainerHighest, colors.onSurfaceVariant),
      _CardState.playable => (colors.primary, colors.onPrimary),
      _CardState.cleared => (colors.tertiary, colors.onTertiary),
    };

    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.95 : 1,
        duration: const Duration(milliseconds: 90),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: _down ? Color.lerp(fill, colors.surface, 0.2) : fill,
            // 버튼과 **같은 모양 언어**를 쓴다. 어느 하나만 각지면 어긋나 보인다.
            shape: gameButtonShape(),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _state == _CardState.locked
                      // **판을 가린다.** 실루엣조차 보여주지 않는다 —
                      // 판 모양이 곧 스포일러다.
                      ? Center(
                          child: Icon(Icons.lock_rounded, size: 32, color: ink),
                        )
                      : (widget.preview ?? const SizedBox.shrink()),
                ),
                const SizedBox(height: Spacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_state != _CardState.locked) ...[
                      Text(
                        '${level.number}',
                        style: theme.textTheme.labelLarge?.copyWith(color: ink),
                      ),
                      const SizedBox(width: Spacing.xs),
                    ],
                    // 잠긴 레벨은 이름도 가린다 — 앞으로 무엇이 나오는지가 스포일러다.
                    //
                    // **두 줄까지 준다.** 한 줄로 묶으면 영어 `Hidden Ledge`,
                    // 프랑스어 `Rebord caché` 가 카드 폭에서 잘린다.
                    Flexible(
                      child: Text(
                        _state == _CardState.locked
                            ? strings.locked
                            : strings.levelName(level.number),
                        style: theme.textTheme.labelMedium?.copyWith(color: ink),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (_state != _CardState.locked) ...[
                  const SizedBox(height: Spacing.xs),
                  _Stars(count: progress?.stars ?? 0, color: ink),
                  Text(
                    // 미클리어면 목표를, 클리어했으면 자기 기록을 보여준다.
                    progress == null
                        ? strings.minMovesLabel(level.minMoves)
                        : strings.movesLabel(progress.bestMoveCount),
                    style: theme.textTheme.bodySmall?.copyWith(color: ink),
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
  const _Stars({required this.count, required this.color});

  final int count;

  /// 카드 채움색 위에서 읽혀야 하므로 글자와 같은 색을 받는다.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 3; i++)
          Icon(
            i <= count ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 16,
            // 빈 별은 같은 색을 옅게 — 세 칸이 있다는 것은 보여야 한다.
            color: i <= count ? color : color.withValues(alpha: 0.35),
          ),
      ],
    );
  }
}
