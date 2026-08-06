import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:flutter/material.dart';

/// 앱의 모든 글자 버튼 (13-game-feel §3).
///
/// **Material 기본 버튼을 쓰지 않는다.** 모서리를 깎은 모양과 누를 때의
/// 축소·밝아짐은 `ButtonStyle` 로 표현하기 번거롭고, 무엇보다 한 화면에서
/// 어떤 버튼만 Material 기본이면 그게 제일 어색하다.
///
/// **`core` 에 있는 이유**: `game` · `level` · `settings` 가 모두 쓴다.
/// feature 하나에 두면 나머지가 그것을 import 해야 하고, 그 순간 **모양 때문에
/// feature 간 간선이 생긴다.**
///
/// 색과 모서리는 값을 박지 않고 테마에서 뽑는다 — 다크 테마에서도 살아야 한다.
class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = false,
  });

  final String label;

  /// `null` 이면 비활성이다. 별 연출이 끝나기 전의 "다음 레벨" 이 그렇다(§5).
  final VoidCallback? onPressed;

  final IconData? icon;

  /// 그 화면에서 가장 밀고 싶은 하나. 채운 색으로 그린다.
  final bool isPrimary;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _down = false;

  bool get _enabled => widget.onPressed != null;

  void _set(bool down) {
    if (_enabled && _down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // 보조 버튼도 **색이 있다.** 표면색과 같으면 버튼인지 아닌지 읽히지 않는다.
    final fill = switch ((_enabled, widget.isPrimary)) {
      (false, _) => colors.surfaceContainerHigh,
      (true, true) => colors.primary,
      (true, false) => colors.secondaryContainer,
    };
    final ink = switch ((_enabled, widget.isPrimary)) {
      (false, _) => colors.outline,
      (true, true) => colors.onPrimary,
      (true, false) => colors.onSecondaryContainer,
    };

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          duration: gameButtonPressDuration,
          child: AnimatedContainer(
            duration: gameButtonPressDuration,
            decoration: ShapeDecoration(
              // 누르면 안쪽이 표면색 쪽으로 밝아진다.
              color: _down ? Color.lerp(fill, colors.surface, 0.25) : fill,
              shape: gameButtonShape(),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.sm + 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 18, color: ink),
                  const SizedBox(width: Spacing.xs),
                ],
                Flexible(
                  child: Text(
                    widget.label,
                    style: theme.textTheme.labelLarge?.copyWith(color: ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 버튼·카드가 공유하는 깎인 모서리 (13-game-feel §2·§3).
///
/// 카드와 버튼이 **같은 모양 언어**를 써야 한다. 어느 하나만 각지면 어긋나 보인다.
///
/// **테두리를 두지 않는다.** 모양은 깎인 모서리가 만들고, 구분은 채움색이 한다 —
/// 선까지 두르면 요소마다 윤곽선이 겹쳐 화면이 복잡해진다.
///
/// [radius] 는 깎이는 정도다. **면이 커지면 같이 키운다** — 큰 카드에 작은
/// 모서리를 쓰면 각진 느낌이 나지 않고 그냥 사각형으로 보인다.
ShapeBorder gameButtonShape({double radius = 10}) =>
    BeveledRectangleBorder(borderRadius: BorderRadius.circular(radius));

/// 오버레이 카드·다이얼로그가 쓰는 크기.
const double gameCardBevel = 20;

/// 카드·다이얼로그의 모양. **버튼과 달리 테두리가 있다.**
///
/// 버튼은 채움색만으로도 배경과 갈리지만, 카드는 표면색 위에 표면색으로 떠
/// 있어서 윤곽이 없으면 어디까지가 카드인지 흐릿하다.
///
/// 색은 `outlineVariant` — 시커먼 선을 두르면 창틀처럼 무거워진다.
ShapeBorder gameCardShape(ColorScheme colors) => BeveledRectangleBorder(
  borderRadius: BorderRadius.circular(gameCardBevel),
  side: BorderSide(color: colors.outlineVariant, width: 1.5),
);

/// 누를 때의 반응 시간. 길면 눌린 느낌이 아니라 굼뜬 느낌이 된다.
const Duration gameButtonPressDuration = Duration(milliseconds: 80);
