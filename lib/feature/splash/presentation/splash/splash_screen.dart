import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:flutter/material.dart';

/// 앱을 켜면 잠깐 보이는 화면 (12-ui-polish §1).
///
/// **연출이 곧 게임 규칙의 요약이다** — 블록이 미끄러져 와 목표에 멈춘다.
/// 로고를 따로 만들 것 없이 게임 자체가 로고다.
///
/// 그리기만 한다. **Riverpod 을 모른다** (docs/architecture.md §5).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, required this.onFinished});

  /// 연출이 끝났거나 사용자가 건너뛰었다.
  final VoidCallback onFinished;

  /// 블록이 미끄러지는 시간.
  static const Duration _slide = Duration(milliseconds: 600);

  /// 칸 하나의 크기. 화면 폭과 무관하게 고정 — 판이 아니라 로고다.
  static const double _cell = 34;

  static const int _cellCount = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.boardColors;

    return Scaffold(
      // **누르면 즉시 넘어간다.** 두 번째부터는 기다릴 이유가 없다.
      body: GestureDetector(
        onTap: onFinished,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: _cell * _cellCount,
                height: _cell,
                child: _SlidingBlocks(cell: _cell, count: _cellCount),
              ),
              const SizedBox(height: Spacing.xl),
              // 제목은 블록이 자리를 잡은 뒤에 떠오른다.
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                tween: Tween(begin: 0, end: 1),
                builder: (context, value, child) =>
                    Opacity(opacity: value, child: child),
                child: Text(
                  AppConstants.appName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.playerBlock,
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

/// 왼쪽에서 미끄러져 와 목표 칸에 "탁" 멈추는 블록들.
class _SlidingBlocks extends StatelessWidget {
  const _SlidingBlocks({required this.cell, required this.count});

  final double cell;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.boardColors;

    return TweenAnimationBuilder<double>(
      duration: SplashScreen._slide,
      // easeOutBack 이 끝에서 살짝 되튕겨 "부딪혀 멈췄다" 로 읽힌다.
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0, end: 1),
      builder: (context, progress, _) => Stack(
        children: [
          for (var i = 0; i < count; i++)
            Positioned(
              // 뒤에 있는 블록일수록 더 멀리서 온다 — 함께 미끄러지는 규칙 그대로.
              left: cell * i - cell * count * (1 - progress) * (1 + i * 0.35),
              child: _Tile(
                size: cell,
                // 마지막 칸이 목표에 선 플레이어다.
                color: i == count - 1 ? colors.playerBlock : colors.normalBlock,
              ),
            ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(size * Spacing.blockInsetRatio),
      child: Container(
        width: size * (1 - 2 * Spacing.blockInsetRatio),
        height: size * (1 - 2 * Spacing.blockInsetRatio),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size * Spacing.blockRadiusRatio),
        ),
      ),
    );
  }
}
