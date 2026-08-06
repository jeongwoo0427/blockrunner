import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:flutter/material.dart';

/// 판 위에 뜨는 카드 (12-ui-polish §6).
///
/// 결과와 튜토리얼이 **같은 것을 쓴다.** 둘은 같은 종류의 레이어 — 판 위에 겹쳐
/// 뜨고 버튼을 누르면 사라진다 — 이라 한쪽만 카드가 되면 오히려 어긋나 보인다.
/// 스크림 · 모서리 · 등장 연출 · 최대 폭이 두 곳에 흩어지면 한쪽만 손댔을 때
/// 조용히 갈라진다.
///
/// **`showDialog` 가 아니다.** Screen 이 Riverpod 도 `showDialog` 도 모르는 채로
/// 남는다는 `04` 의 결정은 그대로이며, 이것은 상태에서 파생되는 레이어다.
/// 다이얼로그처럼 **보이기만** 한다.
class OverlayCard extends StatelessWidget {
  const OverlayCard({super.key, required this.child});

  final Widget child;

  /// 카드가 이보다 넓어지면 글줄이 길어져 읽기 나빠진다.
  static const double _maxWidth = 360;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      // 뒤 판이 비쳐야 무엇 때문에 끝났는지 보인다. 다만 예전처럼 글자를
      // 판 위에 그대로 얹지는 않는다 — 그래서 카드가 필요했다.
      color: theme.colorScheme.scrim.withValues(alpha: 0.46),
      child: Center(
        child: SingleChildScrollView(
          // 글꼴을 키우면 카드가 화면보다 커질 수 있다. 잘라내지 않고 넘긴다.
          padding: const EdgeInsets.all(Spacing.lg),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            tween: Tween(begin: 0.9, end: 1),
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 8,
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Spacing.lg),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  // 내용만큼만 차지한다 — 요청의 핵심이다.
                  child: Column(mainAxisSize: MainAxisSize.min, children: [child]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
