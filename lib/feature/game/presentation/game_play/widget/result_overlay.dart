import 'dart:async';

import 'package:blockrunner/core/i18n/app_strings_scope.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/core/widget/game_button.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/overlay_card.dart';
import 'package:flutter/material.dart';

/// 클리어 · 플레이어 소실 결과를 보드 위에 얹는 레이어.
///
/// 감싸는 것은 [OverlayCard] 가 한다 — 여기는 **내용만** 담는다.
class ResultOverlay extends StatefulWidget {
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

  /// `false` 면 플레이어가 블랙홀에 빠진 상태다.
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
  State<ResultOverlay> createState() => _ResultOverlayState();
}

class _ResultOverlayState extends State<ResultOverlay> {
  /// 지금까지 등장한 별 개수. 0부터 3까지 하나씩 올라간다.
  int _shown = 0;

  Timer? _timer;

  /// 별 하나가 튀어나오는 데 걸리는 시간.
  static const Duration _pop = Duration(milliseconds: 320);

  /// 다음 별이 나오기까지의 간격.
  static const Duration _gap = Duration(milliseconds: 220);

  /// 별 연출이 다 끝났는가. **다음 레벨 버튼이 이때 열린다** (13-game-feel §5).
  ///
  /// 실패 카드는 따로 보지 않는다 — 거기엔 이 값이 여는 버튼 자체가 없다.
  /// `!isCleared` 를 넣어 봤지만 어떤 화면도 달라지지 않아 걷어냈다.
  bool get _finished => _shown >= 3;

  @override
  void initState() {
    super.initState();
    if (widget.isCleared) _scheduleNextStar();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// **얻은 별만이 아니라 세 칸을 모두 채운다.** 빈 별도 같은 리듬으로 나와야
  /// "3개 중 2개" 가 읽힌다.
  void _scheduleNextStar() {
    _timer = Timer(_gap, () {
      if (!mounted) return;
      setState(() => _shown++);
      if (_shown < 3) _scheduleNextStar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.strings;
    final isCleared = widget.isCleared;

    return OverlayCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isCleared ? strings.cleared : strings.fellIntoBlackHole,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (isCleared) ...[
            const SizedBox(height: Spacing.md),
            _Stars(count: widget.stars, shown: _shown, pop: _pop),
          ],
          const SizedBox(height: Spacing.sm),
          Text(
            // 되돌리기가 없으므로 블랙홀에 빠지면 처음부터다 (기획서 §3.5).
            isCleared
                ? strings.clearedSummary(widget.moveCount, widget.minMoves)
                : strings.retryHint,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.lg),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            alignment: WrapAlignment.center,
            children: [
              // **목록으로·다시하기는 처음부터 열려 있다.** 별을 다 보지 않고
              // 나갈 자유는 남긴다.
              GameButton(
                label: strings.backToList,
                onPressed: widget.onBackToLevelSelect,
              ),
              GameButton(label: strings.reset, onPressed: widget.onReset),
              if (isCleared && widget.hasNextLevel)
                GameButton(
                  label: strings.nextLevel,
                  // **자리는 처음부터 잡아두고 활성만 늦춘다.** 늦게 나타나게
                  // 하면 그때 레이아웃이 밀려 다른 버튼이 흔들린다.
                  onPressed: _finished ? widget.onNextLevel : null,
                  isPrimary: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 별 세 개 중 [count] 개를 채운다. 빈 별도 그려야 "몇 개 중 몇 개" 가 읽힌다.
///
/// [shown] 개까지만 그린다 — 하나씩 튀어나오는 연출 (13-game-feel §5).
class _Stars extends StatelessWidget {
  const _Stars({
    required this.count,
    required this.shown,
    required this.pop,
  });

  final int count;
  final int shown;
  final Duration pop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 3; i++)
          // **자리는 처음부터 차지한다.** 별이 나올 때마다 줄이 넓어지면
          // 카드가 흔들린다. 배율만 0 에서 1로 간다.
          AnimatedScale(
            scale: i <= shown ? 1 : 0,
            duration: pop,
            // 튀어나오는 느낌 — 카드 등장과 같은 언어다.
            curve: Curves.elasticOut,
            child: Icon(
              i <= count ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 36,
              color: i <= count
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
            ),
          ),
      ],
    );
  }
}
