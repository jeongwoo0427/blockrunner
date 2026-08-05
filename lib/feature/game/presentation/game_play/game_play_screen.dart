import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_event.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_state.dart';
import 'package:blockrunner/feature/game/presentation/game_play/swipe_direction.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_view.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/control_hint.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/game_hud.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/result_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 그리기만 한다. **Riverpod 을 모른다** (docs/architecture.md §5).
class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({super.key, required this.state, required this.onEvent});

  final GamePlayScreenState state;
  final ValueChanged<GamePlayScreenEvent> onEvent;

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'GamePlayKeyboard');

  /// 스와이프 시작부터 누적한 이동량. `onPanEnd` 는 총 이동량을 주지 않는다.
  Offset _panDelta = Offset.zero;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GamePlayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 결과 오버레이가 닫히면 키보드 포커스를 되찾는다. 오버레이 버튼이
    // 포커스를 가져간 채로 두면 방향키가 먹지 않는다.
    final wasBlocked =
        oldWidget.state.isCleared || oldWidget.state.isPlayerLost;
    final isBlocked = widget.state.isCleared || widget.state.isPlayerLost;
    if (wasBlocked && !isBlocked) _focusNode.requestFocus();
  }

  /// 모든 입력 경로가 지나는 한 곳.
  ///
  /// 연출 중이거나 판이 끝난 상태의 입력은 **버린다. 큐잉하지 않는다**
  /// (기획서 §6). 연타로 상태가 꼬이는 것을 막는다.
  void _requestMove(Direction direction) {
    if (!widget.state.canMove) return;
    widget.onEvent(MoveRequested(direction));
  }

  /// 화면 버튼을 누르면 그 버튼이 포커스를 가져가 방향키가 죽는다.
  /// 버튼은 계속 Tab 으로 접근 가능하게 두되, 조작 뒤에는 포커스를 되돌린다.
  void _sendAndRefocus(GamePlayScreenEvent event) {
    widget.onEvent(event);
    _focusNode.requestFocus();
  }

  /// 처리한 키는 **반드시 `handled` 로 소비한다.**
  ///
  /// 그냥 흘려보내면 방향키가 Flutter 기본 포커스 이동(`DirectionalFocusIntent`)
  /// 까지 타서 포커스가 AppBar 버튼 등으로 떠나고, 그 뒤로는 방향키가 먹지 않는다.
  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    // KeyRepeatEvent 를 처리하면 키를 누르고 있을 때 연타된다.
    if (event is! KeyDownEvent) {
      // 눌렀던 키의 반복·뗌도 같이 삼켜야 포커스가 흔들리지 않는다.
      return _isHandledKey(event.logicalKey)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    final direction = _directionForKey(event.logicalKey);
    if (direction != null) {
      _requestMove(direction);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyR) {
      widget.onEvent(ResetRequested());
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  bool _isHandledKey(LogicalKeyboardKey key) =>
      _directionForKey(key) != null || key == LogicalKeyboardKey.keyR;

  Direction? _directionForKey(LogicalKeyboardKey key) => switch (key) {
    LogicalKeyboardKey.arrowUp || LogicalKeyboardKey.keyW => Direction.up,
    LogicalKeyboardKey.arrowDown || LogicalKeyboardKey.keyS => Direction.down,
    LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.keyA => Direction.left,
    LogicalKeyboardKey.arrowRight || LogicalKeyboardKey.keyD => Direction.right,
    _ => null,
  };

  void _onPanStart(DragStartDetails _) => _panDelta = Offset.zero;

  void _onPanUpdate(DragUpdateDetails details) => _panDelta += details.delta;

  void _onPanEnd(DragEndDetails _) {
    final direction = directionFromSwipe(_panDelta);
    if (direction != null) _requestMove(direction);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final level = state.level;
    final board = state.board;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          level == null
              ? '레벨'
              : '레벨 ${level.number}${level.name == null ? '' : ' · ${level.name}'}',
        ),
        leading: IconButton(
          onPressed: () => widget.onEvent(BackToLevelSelectRequested()),
          icon: const Icon(Icons.arrow_back),
          tooltip: '레벨 선택으로',
        ),
      ),
      body: SafeArea(
        child: switch ((state.failure, board, level)) {
          (final failure?, _, _) => _ErrorBody(message: failure.debugMessage),
          (_, final board?, final level?) => Focus(
            focusNode: _focusNode,
            // 진입 즉시 포커스를 잡는다. 안 그러면 웹에서 화면을 한 번
            // 클릭하기 전까지 방향키가 먹지 않고, 사용자는 이유를 모른다.
            autofocus: true,
            onKeyEvent: _onKeyEvent,
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onPanStart: _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        // 빈 공간에서 시작한 스와이프도 받아야 한다.
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(Spacing.md),
                          child: BoardView(board: board),
                        ),
                      ),
                    ),
                    if (state.showsControlHint) ...[
                      const ControlHint(),
                      const SizedBox(height: Spacing.sm),
                    ],
                    GameHud(
                      moveCount: state.moveCount,
                      minMoves: level.minMoves,
                      onReset: () => _sendAndRefocus(ResetRequested()),
                    ),
                  ],
                ),
                if (state.isCleared || state.isPlayerLost)
                  Positioned.fill(
                    child: ResultOverlay(
                      isCleared: state.isCleared,
                      moveCount: state.moveCount,
                      minMoves: level.minMoves,
                      hasNextLevel: state.hasNextLevel,
                      onReset: () => _sendAndRefocus(ResetRequested()),
                      onNextLevel: () => widget.onEvent(NextLevelRequested()),
                      onBackToLevelSelect: () =>
                          widget.onEvent(BackToLevelSelectRequested()),
                    ),
                  ),
              ],
            ),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Text(
          '레벨을 불러오지 못했다.\n${message ?? ''}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
