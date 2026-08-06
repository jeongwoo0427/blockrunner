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
  ///
  /// **0.6초에서 늘렸다** — 그 속도로는 눈으로 따라가기 전에 끝났고,
  /// `easeOutBack` 의 되튕김도 보이지 않았다 (13-game-feel §1).
  static const Duration slide = Duration(milliseconds: 1100);

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
                duration: const Duration(milliseconds: 500),
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
///
/// **하나씩 차례로 도착한다** (13-game-feel §1). 동시에 멈추면 한 덩어리로
/// 보여서 "각자 끝까지 미끄러진다" 는 규칙이 읽히지 않는다.
///
/// **앞선 블록이 먼저 선다** — 게임의 처리 순서와 같다(기획서 §3.2).
/// 오른쪽 끝이 플레이어이므로 플레이어가 목표에 먼저 도착하고, 뒤 블록들이
/// 그 뒤에 차례로 붙는다.
class _SlidingBlocks extends StatelessWidget {
  const _SlidingBlocks({required this.cell, required this.count});

  final double cell;
  final int count;

  /// 블록 하나가 실제로 미끄러지는 구간의 길이(전체 대비).
  static const double _span = 0.62;

  /// 뒤 블록이 늦게 출발하는 정도.
  static const double _stagger = 0.12;

  /// [index] 번째 블록의 진행도(0~1).
  double _progressFor(int index, double t) {
    // 오른쪽 끝(플레이어)이 0번째로 도착한다.
    final order = count - 1 - index;
    final begin = order * _stagger;
    final end = (begin + _span).clamp(0.0, 1.0);

    if (t <= begin) return 0;
    if (t >= end) return 1;
    // 끝에서 살짝 되튕겨 "부딪혀 멈췄다" 로 읽힌다.
    return Curves.easeOutBack.transform((t - begin) / (end - begin));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.boardColors;

    return TweenAnimationBuilder<double>(
      duration: SplashScreen.slide,
      curve: Curves.linear,
      tween: Tween(begin: 0, end: 1),
      builder: (context, t, _) => Stack(
        children: [
          for (var i = 0; i < count; i++)
            Positioned(
              // 줄 간격을 유지한 채 왼쪽 화면 밖에서 들어온다.
              left:
                  cell * i -
                  cell * (count + 1) * (1 - _progressFor(i, t)),
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
