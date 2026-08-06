import 'package:blockrunner/core/widget/game_button.dart';
import 'package:flutter/material.dart';

/// 아이콘만 있는 버튼 (13-game-feel §3).
///
/// AppBar 의 뒤로가기·설정도 이것으로 바꾼다. **한 화면에서 어떤 버튼만 Material
/// 기본이면 그게 제일 어색하다** — 화면 안쪽 버튼만 바꾸면 위쪽이 남는다.
class GameIconButton extends StatefulWidget {
  const GameIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// 아이콘만으로는 뜻이 전달되지 않는다. 화면 낭독기에도 이것이 쓰인다.
  final String tooltip;

  @override
  State<GameIconButton> createState() => _GameIconButtonState();
}

class _GameIconButtonState extends State<GameIconButton> {
  bool _down = false;

  bool get _enabled => widget.onPressed != null;

  void _set(bool down) {
    if (_enabled && _down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fill = _enabled
        ? colors.secondaryContainer
        : colors.surfaceContainerHigh;
    final ink = _enabled ? colors.onSecondaryContainer : colors.outline;

    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        enabled: _enabled,
        label: widget.tooltip,
        child: GestureDetector(
          onTapDown: (_) => _set(true),
          onTapUp: (_) => _set(false),
          onTapCancel: () => _set(false),
          onTap: widget.onPressed,
          child: AnimatedScale(
            scale: _down ? 0.94 : 1,
            duration: gameButtonPressDuration,
            child: AnimatedContainer(
              duration: gameButtonPressDuration,
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: _down ? Color.lerp(fill, colors.surface, 0.25) : fill,
                shape: gameButtonShape(),
              ),
              child: Icon(widget.icon, size: 20, color: ink),
            ),
          ),
        ),
      ),
    );
  }
}
