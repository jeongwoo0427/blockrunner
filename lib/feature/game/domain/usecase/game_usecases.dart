import 'package:blockrunner/feature/game/domain/repository/map_repository.dart';
import 'package:blockrunner/feature/game/domain/usecase/game_usecases/apply_move_usecase.dart';
import 'package:blockrunner/feature/game/domain/usecase/game_usecases/get_map_usecase.dart';
import 'package:blockrunner/feature/level/domain/repository/level_repository.dart';
import 'package:blockrunner/feature/level/domain/repository/tutorial_repository.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases/get_all_levels_usecase.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases/get_level_usecase.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases/has_seen_tutorial_usecase.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases/mark_tutorial_seen_usecase.dart';

/// 플레이 화면이 쓰는 usecase 묶음 (docs/architecture.md §6).
///
/// 판은 game 이, 레벨 메타데이터(이름 · 최소 이동 횟수)는 level 이 소유한다.
/// 의존은 **game → level 한 방향뿐이다** — level 은 판을 모른다.
class GameUsecases {
  const GameUsecases({
    required this.getMap,
    required this.getLevel,
    required this.getAllLevels,
    required this.applyMove,
    required this.hasSeenTutorial,
    required this.markTutorialSeen,
  });

  factory GameUsecases.fromRepositories({
    required MapRepository mapRepository,
    required LevelRepository levelRepository,
    required TutorialRepository tutorialRepository,
  }) => GameUsecases(
    getMap: GetMapUsecase(repository: mapRepository),
    getLevel: GetLevelUsecase(repository: levelRepository),
    getAllLevels: GetAllLevelsUsecase(repository: levelRepository),
    applyMove: const ApplyMoveUsecase(),
    hasSeenTutorial: HasSeenTutorialUsecase(repository: tutorialRepository),
    markTutorialSeen: MarkTutorialSeenUsecase(repository: tutorialRepository),
  );

  final GetMapUsecase getMap;

  final GetLevelUsecase getLevel;

  /// "다음 레벨이 있는가" 를 판정하는 데 쓴다.
  final GetAllLevelsUsecase getAllLevels;

  final ApplyMoveUsecase applyMove;

  final HasSeenTutorialUsecase hasSeenTutorial;
  final MarkTutorialSeenUsecase markTutorialSeen;
}
