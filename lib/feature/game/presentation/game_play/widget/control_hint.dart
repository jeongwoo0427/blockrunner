import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 첫 조작을 알려주는 한 줄 (기획서 §6.1).
///
/// 화면 방향 버튼을 두지 않기로 했으므로 스와이프도 방향키도 보이지 않는
/// 조작이 됐다. 처음 들어온 사람에게 알려줄 것이 필요하다.
///
/// **닫기 버튼을 두지 않는다.** 첫 이동을 하면 사라진다 — 조작할 줄 안다는 것은
/// 실제로 조작했을 때만 확인되고, 눌러서 닫는 안내는 읽지 않고 닫히기 쉽다.
class ControlHint extends StatelessWidget {
  const ControlHint({super.key});

  /// 터치 기기는 스와이프, 그 외는 키보드가 주 입력이다 (기획서 §6).
  static bool get _isTouch => switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia =>
      true,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: DecoratedBox(
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
                _isTouch ? Icons.swipe : Icons.keyboard,
                size: 18,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: Spacing.sm),
              Flexible(
                child: Text(
                  _isTouch ? '쓸어넘겨 블록을 한꺼번에 밀어보자' : '방향키나 WASD 로 블록을 한꺼번에 밀어보자',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
