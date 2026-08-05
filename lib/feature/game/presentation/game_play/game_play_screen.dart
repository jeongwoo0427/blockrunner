import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_event.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_state.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_view.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/game_hud.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/result_overlay.dart';
import 'package:flutter/material.dart';

/// 그리기만 한다. **Riverpod 을 모른다** (docs/architecture.md §5).
class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({
    super.key,
    required this.state,
    required this.onEvent,
  });

  final GamePlayScreenState state;
  final ValueChanged<GamePlayScreenEvent> onEvent;

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
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
          (_, final board?, final level?) => Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.md),
                      child: BoardView(board: board),
                    ),
                  ),
                  GameHud(
                    moveCount: state.moveCount,
                    minMoves: level.minMoves,
                    onDirection: (direction) =>
                        widget.onEvent(MoveRequested(direction)),
                    onReset: () => widget.onEvent(ResetRequested()),
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
                    onReset: () => widget.onEvent(ResetRequested()),
                    onNextLevel: () => widget.onEvent(NextLevelRequested()),
                    onBackToLevelSelect: () =>
                        widget.onEvent(BackToLevelSelectRequested()),
                  ),
                ),
            ],
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
