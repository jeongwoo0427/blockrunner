import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/core/widget/game_button.dart';
import 'package:blockrunner/core/widget/overlay_transition.dart';
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
///
/// **연출을 언제 시작할지는 여기서 모른다.** 사라진 뒤에도 잠시 트리에 남아
/// 있어야 하는데 그것을 아는 것은 띄운 쪽이다. 대신 **어디에 걸지는 여기서
/// 안다** — 배율은 카드에만 걸리고 배경은 투명도만 바뀐다. 화면이
/// [OverlayCardAnimation] 으로 진행도를 내려준다.
class OverlayCard extends StatelessWidget {
  const OverlayCard({super.key, required this.child});

  final Widget child;

  /// 카드가 이보다 넓어지면 글줄이 길어져 읽기 나빠진다.
  static const double _maxWidth = 360;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = OverlayCardAnimation.of(context);

    return ColoredBox(
      // 뒤 판이 비쳐야 무엇 때문에 끝났는지 보인다. 다만 예전처럼 글자를
      // 판 위에 그대로 얹지는 않는다 — 그래서 카드가 필요했다.
      color: theme.colorScheme.scrim.withValues(alpha: 0.46),
      child: Center(
        child: SingleChildScrollView(
          // 글꼴을 키우면 카드가 화면보다 커질 수 있다. 잘라내지 않고 넘긴다.
          padding: const EdgeInsets.all(Spacing.lg),
          // **배율은 카드에만.** 배경까지 줄어들면 덮개가 아니라 또 하나의
          // 카드처럼 보인다.
          child: FadeTransition(
            opacity: card,
            child: ScaleTransition(
              key: overlayCardKey,
              scale: Tween<double>(
                begin: overlayStartScale,
                end: 1,
              ).animate(card),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxWidth),
                child: Card(
              margin: EdgeInsets.zero,
              elevation: 8,
              color: theme.colorScheme.surface,
              // 버튼·레벨 카드와 같은 모양 언어를 쓴다.
              shape: gameCardShape(theme.colorScheme),
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.lg),
                    // 내용만큼만 차지한다 — 요청의 핵심이다.
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [child],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 카드가 뜨고 지는 진행도를 [OverlayCard] 에 내려준다.
///
/// 생성자로 넘기지 않는 이유: 카드를 만드는 것은 `ResultOverlay` ·
/// `TutorialOverlay` 인데 **연출을 아는 것은 그 위의 화면**이다. 두 오버레이가
/// 값을 그저 통과시키기만 하는 인자를 갖게 하고 싶지 않았다.
class OverlayCardAnimation extends InheritedWidget {
  const OverlayCardAnimation({
    super.key,
    required this.animation,
    required super.child,
  });

  final Animation<double> animation;

  /// 없으면 **다 떠 있는 것으로 친다** — 위젯을 따로 띄워 보는 테스트에서
  /// 연출을 신경 쓰지 않아도 된다.
  static Animation<double> of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<OverlayCardAnimation>()
          ?.animation ??
      kAlwaysCompleteAnimation;

  @override
  bool updateShouldNotify(OverlayCardAnimation oldWidget) =>
      animation != oldWidget.animation;
}
