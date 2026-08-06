import 'package:blockrunner/core/router/route_paths.dart';
import 'package:blockrunner/feature/game/presentation/board_preview/board_preview.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_root.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_root.dart';
import 'package:blockrunner/feature/splash/presentation/splash/splash_root.dart';
import 'package:go_router/go_router.dart';

/// 전역 라우터. 모든 GoRoute 는 *Root 위젯을 만든다.
final GoRouter router = GoRouter(
  initialLocation: RoutePaths.splash,
  routes: [
    GoRoute(
      path: RoutePaths.splash,
      builder: (context, state) => const SplashRoot(),
    ),
    GoRoute(
      path: RoutePaths.levelSelect,
      // **미니 보드를 여기서 끼워 넣는다** (12-ui-polish §2).
      //
      // 레벨 카드에 판을 그리려면 `game` 이 필요한데 화면은 `level` 에 있고
      // `game → level` 이 이미 있다. 라우터는 원래 모든 feature 를 아는
      // 유일한 자리라, 조립을 여기서 하면 순환이 생기지 않는다.
      builder: (context, state) => LevelSelectRoot(
        previewBuilder: (context, levelNumber) =>
            BoardPreview(levelNumber: levelNumber),
      ),
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
