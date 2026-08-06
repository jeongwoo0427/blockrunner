import 'dart:async';

import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/i18n/app_strings_scope.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/core/widget/game_icon_button.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
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
import 'package:blockrunner/feature/level/domain/entity/level.dart';
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

class _GamePlayScreenState extends State<GamePlayScreen>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode(debugLabel: 'GamePlayKeyboard');

  /// 레벨이 바뀔 때 몸통이 밀려 넘어가는 연출.
  ///
  /// **`late final ... = AnimationController(...)` 으로 두면 안 된다.** 한 번도
  /// 쓰이지 않은 채 화면이 사라지면 `dispose` 가 그때 처음 만들면서
  /// `vsync: this` 가 이미 떨어져 나간 트리를 뒤져 터진다.
  late final AnimationController _levelSlide;

  /// 방금 전 레벨의 몸통. 넘어가는 동안만 들고 있다.
  Widget? _outgoingBody;

  /// 마지막으로 그린 몸통 — 레벨이 바뀌면 이것이 [_outgoingBody] 가 된다.
  Widget? _lastBody;

  /// 스와이프 시작부터 누적한 이동량. `onPanEnd` 는 총 이동량을 주지 않는다.
  Offset _panDelta = Offset.zero;

  /// 연출이 끝나는 시점을 재는 타이머.
  ///
  /// 슬라이드는 `AnimatedPositioned` 가 알아서 하므로 `AnimationController` 가
  /// 필요 없지만, **언제 끝났는지 Notifier 에 알려줄 무언가**는 필요하다.
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _levelSlide = AnimationController(
      vsync: this,
      duration: AppConstants.levelSlideDuration,
    );
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _levelSlide.dispose();
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

    _startLevelSlideIfNeeded(oldWidget);

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

  /// 레벨이 바뀌었으면 몸통을 밀어 넘긴다.
  ///
  /// 라우터가 **같은 페이지를 재사용**하므로(`router.dart`) 여기서 새 레벨을
  /// `didUpdateWidget` 으로 받는다 — 페이지가 통째로 갈리면 이 자리에
  /// 이전 화면이 남아 있지 않다.
  void _startLevelSlideIfNeeded(GamePlayScreen oldWidget) {
    final before = oldWidget.state.level?.number;
    final after = widget.state.level?.number;
    if (before == null || after == null || before == after) return;

    final outgoing = _lastBody;
    if (outgoing == null || MediaQuery.disableAnimationsOf(context)) return;

    _outgoingBody = outgoing;
    _levelSlide.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _outgoingBody = null);
    });
  }

  /// 판정은 이동 직후 확정되지만 **보여주는 것은 연출이 끝난 뒤다**(기획서 §7).
  /// 미끄러지는 도중에 띄우면 무엇 때문에 끝났는지 가려진다.
  bool _showsResult(GamePlayScreenState state) =>
      (state.isCleared || state.isPlayerLost) && !state.isAnimating;

  void _startAnimationTimer() {
    _animationTimer?.cancel();

    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _animationSpan();

    _animationTimer = Timer(duration, () {
      _animationTimer = null;
      if (mounted) widget.onEvent(AnimationCompleted());
    });
  }

  /// 이번 연출이 끝나는 데 걸리는 시간.
  ///
  /// **플레이어가 빨려 들어가면 훨씬 길다** (12-ui-polish §5.3). 판이 끝나는
  /// 순간이라 연출을 다 보여준 뒤에 결과를 띄운다. 일반 블록만 빠졌다면
  /// 게임이 계속되므로 짧게 끝낸다 — 한 수마다 2초를 기다리면 답답해진다.
  Duration _animationSpan() {
    final falling = widget.state.fallingBlocks;
    if (falling.isEmpty) return AppConstants.moveAnimationDuration;

    return falling.any((block) => block.type == BlockType.player)
        ? AppConstants.moveWithPlayerFallDuration
        : AppConstants.moveWithFallDuration;
  }

  /// 판과 HUD — **레벨이 바뀔 때 이것만 밀려 넘어간다** (13-game-feel 이후).
  ///
  /// AppBar 와 오버레이는 제자리에 둔다. 화면 전체가 밀리면 레벨 선택에서
  /// 들어올 때와 구분이 안 되고, 같은 판을 계속 보고 있다는 감각이 끊긴다.
  Widget _buildBody(
    GamePlayScreenState state,
    BoardState board,
    Level level,
  ) {
    return LayoutBuilder(
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
                  bump: state.bump,
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
    );
  }

  /// 넘어가는 중이면 이전 몸통과 함께 겹쳐 그린다.
  ///
  /// **`PageView` 를 쓰지 않는다.** 손으로 밀어서 레벨을 옮길 수 있으면
  /// 판 위의 스와이프가 이동인지 페이지 넘김인지 갈리지 않는다.
  Widget _bodyLayer(Widget body) {
    _lastBody = body;
    final outgoing = _outgoingBody;
    if (outgoing == null) return body;

    return LayoutBuilder(
      builder: (context, constraints) => AnimatedBuilder(
        animation: _levelSlide,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_levelSlide.value);
          final width = constraints.maxWidth;

          return Stack(
            children: [
              Transform.translate(
                offset: Offset(-width * t, 0),
                child: outgoing,
              ),
              Transform.translate(
                offset: Offset(width * (1 - t), 0),
                child: body,
              ),
            ],
          );
        },
      ),
    );
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
    final strings = context.strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          level == null
              ? strings.levelFallbackTitle
              : strings.levelTitle(level.number),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(Spacing.sm),
          child: GameIconButton(
            icon: Icons.arrow_back,
            onPressed: () => widget.onEvent(BackToLevelSelectRequested()),
            tooltip: strings.backToLevelSelect,
          ),
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
                _bodyLayer(_buildBody(state, board, level)),
                if (state.showsTutorial && level.hasTutorial)
                  Positioned.fill(
                    child: TutorialOverlay(
                      title: strings.levelName(level.number),
                      body: strings.levelTutorial(level.number),
                      demo: level.demo,
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
          '${context.strings.levelLoadFailed}\n${message ?? ''}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
