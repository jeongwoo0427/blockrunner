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
  /// 이미 돌려보냈는가. 프레임이 다시 그려져도 두 번 이동하지 않게 한다.
  bool _bounced = false;

  @override
  Widget build(BuildContext context) {
    final provider = gamePlayScreenNotifierProvider(widget.levelNumber);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    // **잠긴 레벨은 열지 않는다** (기획서 §5.3). 주소로 직접 들어오는 길이
    // 웹에 열려 있어서 여기서 한 번 더 막는다. 빌드 도중에는 이동할 수 없어
    // 프레임 뒤로 미룬다 — 그동안 화면에는 판이 아니라 로딩만 있다.
    if (state.isLocked && !_bounced) {
      _bounced = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(RoutePaths.levelSelect);
      });
    }

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
