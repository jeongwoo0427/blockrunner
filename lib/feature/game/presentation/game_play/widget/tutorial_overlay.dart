import 'package:blockrunner/core/i18n/app_strings_scope.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/core/widget/game_button.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/overlay_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 그 레벨에서 처음 나오는 규칙을 알려주는 오버레이 (기획서 §6.1).
///
/// **레이아웃을 차지하지 않는다.** 보드 아래 한 줄로 두면 사라질 때 판이 갑자기
/// 커져 시선이 흔들린다. 판 위에 겹치면 나타나고 사라져도 레이아웃이 그대로다.
///
/// 배경을 완전히 덮지 않는 것도 의도다 — "이 판에 블랙홀이 있다" 는 말로만
/// 설명하는 것보다 가리키며 설명하는 편이 낫다. [OverlayCard] 를 써도 두 성질은
/// 그대로다.
class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({
    super.key,
    required this.title,
    required this.body,
    required this.showsControls,
    required this.onDismiss,
  });

  /// 레벨 이름. 무엇을 배우는 판인지 한 마디로 알려준다.
  final String title;

  /// `Level.tutorial` 문구.
  final String body;

  /// 조작 방법도 함께 알려줄지. 첫 레벨에서만 참이다.
  ///
  /// 레벨 데이터가 아니라 화면이 담당한다 — 플랫폼마다 문구가 달라야 하는데
  /// 레벨 상수는 하나뿐이기 때문이다.
  final bool showsControls;

  final VoidCallback onDismiss;

  static bool get _isTouch => switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.fuchsia => true,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OverlayCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.md),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          if (showsControls) ...[
            const SizedBox(height: Spacing.md),
            _ControlLine(isTouch: _isTouch),
          ],
          const SizedBox(height: Spacing.lg),
          GameButton(
            label: context.strings.start,
            onPressed: onDismiss,
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}

class _ControlLine extends StatelessWidget {
  const _ControlLine({required this.isTouch});

  final bool isTouch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(Spacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isTouch ? Icons.swipe : Icons.keyboard,
              size: 18,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: Spacing.sm),
            Flexible(
              child: Text(
                isTouch
                    ? context.strings.swipeHint
                    : context.strings.keyboardHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
