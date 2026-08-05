import 'package:blockrunner/core/router/route_paths.dart';
import 'package:blockrunner/feature/game/game_di.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 플레이 화면 — 상태 구독과 네비게이션만 맡는다.
class GamePlayRoot extends ConsumerStatefulWidget {
  const GamePlayRoot({super.key, required this.levelNumber});

  final int levelNumber;

  @override
  ConsumerState<GamePlayRoot> createState() => _GamePlayRootState();
}

class _GamePlayRootState extends ConsumerState<GamePlayRoot> {
  @override
  Widget build(BuildContext context) {
    final provider = gamePlayScreenNotifierProvider(widget.levelNumber);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return GamePlayScreen(
      state: state,
      onEvent: (event) {
        switch (event) {
          case NextLevelRequested():
            context.go(
              '${RoutePaths.gamePlay}'
              '?${RoutePaths.levelQueryKey}=${widget.levelNumber + 1}',
            );
          case BackToLevelSelectRequested():
            context.go(RoutePaths.levelSelect);
          default:
            notifier.onEvent(event);
        }
      },
    );
  }
}
