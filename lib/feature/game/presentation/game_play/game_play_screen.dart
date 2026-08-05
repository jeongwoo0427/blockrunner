import 'dart:async';

import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_event.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_state.dart';
import 'package:blockrunner/feature/game/presentation/game_play/swipe_direction.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_metrics.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_view.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/game_hud.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/result_overlay.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/tutorial_overlay.dart';
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

  /// 연출이 끝나는 시점을 재는 타이머.
  ///
  /// 슬라이드는 `AnimatedPositioned` 가 알아서 하므로 `AnimationController` 가
  /// 필요 없지만, **언제 끝났는지 Notifier 에 알려줄 무언가**는 필요하다.
  Timer? _animationTimer;

  @override
  void dispose() {
    _animationTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  /// 이미 연출 중인 상태로 마운트되는 경우(핫 리로드 등)를 받는다.
  ///
  /// [didUpdateWidget] 만 보면 이때 타이머가 안 걸리고, 완료 통지가 영영 가지
  /// 않아 `isAnimating` 이 남은 채 입력이 죽는다. 되돌릴 방법도 없는 상태다.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.state.isAnimating && _animationTimer == null) {
      _startAnimationTimer();
    }
  }

  @override
  void didUpdateWidget(GamePlayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.state.isAnimating && widget.state.isAnimating) {
      _startAnimationTimer();
    } else if (oldWidget.state.isAnimating && !widget.state.isAnimating) {
      // 다시하기 등으로 연출이 중간에 끊겼다. 늦게 울리면 이미 끝난 판에
      // 완료 통지가 날아간다.
      _animationTimer?.cancel();
      _animationTimer = null;
    }

    // 결과 오버레이가 닫히면 키보드 포커스를 되찾는다. 오버레이 버튼이
    // 포커스를 가져간 채로 두면 방향키가 먹지 않는다.
    if (_showsResult(oldWidget.state) && !_showsResult(widget.state)) {
      _focusNode.requestFocus();
    }
  }

  /// 판정은 이동 직후 확정되지만 **보여주는 것은 연출이 끝난 뒤다**(기획서 §7).
  /// 미끄러지는 도중에 띄우면 무엇 때문에 끝났는지 가려진다.
  bool _showsResult(GamePlayScreenState state) =>
      (state.isCleared || state.isPlayerLost) && !state.isAnimating;

  void _startAnimationTimer() {
    _animationTimer?.cancel();

    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : (widget.state.fallingBlocks.isEmpty
              ? AppConstants.moveAnimationDuration
              : AppConstants.moveWithFallDuration);

    _animationTimer = Timer(duration, () {
      _animationTimer = null;
      if (mounted) widget.onEvent(AnimationCompleted());
    });
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

    // Z(되돌리기)는 잇지 않는다 — 되돌리기를 화면에 두지 않기로 했다(기획서 §5.1).
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

  /// HUD 가 맞출 보드 폭 (기획서 §6.2).
  ///
  /// 보드의 실제 크기는 [BoardView] 가 자기 제약에서 정하지만, `Column` 은
  /// 비유연 자식인 HUD 를 **먼저** 배치하므로 그 결과를 받아볼 수 없다. 그래서
  /// 같은 [BoardMetrics.fit] 을 화면 제약으로 한 번 더 부른다 — 공식이 한 곳에만
  /// 있으니 두 값이 갈리지 않는다.
  ///
  /// 여기 넘기는 높이에는 HUD 자신의 높이가 아직 빠져 있지 않다. **폭이 짧은
  /// 변이면 높이는 결과에 관여하지 않으므로 정확하고**(세로 고정인 모바일과
  /// 대부분의 창이 여기 해당한다), 가로로 납작한 창에서만 HUD 가 보드보다
  /// 조금 넓어진다. 그 경우까지 맞추려면 두 번 배치하는 수밖에 없다.
  double _hudWidth(BoardState board, BoxConstraints constraints) =>
      BoardMetrics.fit(
        board: board,
        available: Size(
          constraints.maxWidth - 2 * Spacing.md,
          constraints.maxHeight - 2 * Spacing.md,
        ),
      ).width;

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
                LayoutBuilder(
                  builder: (context, constraints) => Column(
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
                            child: BoardView(
                              board: board,
                              fallingBlocks: state.fallingBlocks,
                              isAnimating: state.isAnimating,
                            ),
                          ),
                        ),
                      ),
                      // HUD 는 화면 폭이 아니라 **보드 폭**에 맞춘다 (기획서 §6.2).
                      Center(
                        child: SizedBox(
                          width: _hudWidth(board, constraints),
                          child: GameHud(
                            moveCount: state.moveCount,
                            minMoves: level.minMoves,
                            onReset: () => _sendAndRefocus(ResetRequested()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.showsTutorial && level.tutorial != null)
                  Positioned.fill(
                    child: TutorialOverlay(
                      title: level.name ?? '레벨 ${level.number}',
                      body: level.tutorial!,
                      // 조작은 첫 레벨에서만 알려준다.
                      showsControls: level.number == 1,
                      onDismiss: () => _sendAndRefocus(TutorialDismissed()),
                    ),
                  ),
                if (_showsResult(state))
                  Positioned.fill(
                    child: ResultOverlay(
                      isCleared: state.isCleared,
                      moveCount: state.moveCount,
                      minMoves: level.minMoves,
                      stars: level.starsFor(state.moveCount),
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
