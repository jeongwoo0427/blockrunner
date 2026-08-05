import 'package:blockrunner/core/router/route_paths.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_root.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_root.dart';
import 'package:go_router/go_router.dart';

/// 전역 라우터. 모든 GoRoute 는 *Root 위젯을 만든다.
final GoRouter router = GoRouter(
  initialLocation: RoutePaths.levelSelect,
  routes: [
    GoRoute(
      path: RoutePaths.levelSelect,
      builder: (context, state) => const LevelSelectRoot(),
    ),
    GoRoute(
      path: RoutePaths.gamePlay,
      builder: (context, state) {
        // 잘못된 값이 와도 1번 레벨로 폴백한다. 라우팅 단계에서 터뜨리지 않는다.
        final raw = state.uri.queryParameters[RoutePaths.levelQueryKey];
        final levelNumber = int.tryParse(raw ?? '') ?? 1;
        return GamePlayRoot(levelNumber: levelNumber);
      },
    ),
  ],
);
