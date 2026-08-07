import 'package:blockrunner/feature/game/domain/repository/map_repository.dart';
import 'package:blockrunner/feature/game/domain/usecase/game_usecases/apply_move_usecase.dart';
import 'package:blockrunner/feature/game/domain/usecase/game_usecases/get_map_usecase.dart';
import 'package:blockrunner/feature/level/domain/repository/level_repository.dart';
import 'package:blockrunner/feature/level/domain/repository/tutorial_repository.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases/get_all_levels_usecase.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases/get_level_usecase.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases/has_seen_tutorial_usecase.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases/mark_tutorial_seen_usecase.dart';
import 'package:blockrunner/feature/progress/domain/repository/progress_repository.dart';
import 'package:blockrunner/feature/progress/domain/usecase/progress_usecases/get_highest_unlocked_level_usecase.dart';
import 'package:blockrunner/feature/progress/domain/usecase/progress_usecases/save_clear_result_usecase.dart';

/// 플레이 화면이 쓰는 usecase 묶음 (docs/architecture.md §6).
///
/// 판은 game 이, 레벨 메타데이터(이름 · 최소 이동 횟수)는 level 이, 클리어 기록은
/// progress 가 소유한다. 의존은 **game → level · game → progress → level** 로
/// 흐르며 되돌아오는 간선이 없다 — level 은 판도 진행도도 모른다.
class GameUsecases {
  const GameUsecases({
    required this.getMap,
    required this.getLevel,
    required this.getAllLevels,
    required this.applyMove,
    required this.hasSeenTutorial,
    required this.markTutorialSeen,
    required this.getHighestUnlockedLevel,
    required this.saveClearResult,
  });

  /// [saveClearResult] 만 **이미 만들어진 인스턴스로** 받는다.
  ///
  /// 그것이 스트림을 들고 있어서다. 여기서 새로 만들면 `progress` 쪽 컨테이너와
  /// 서로 다른 스트림을 갖게 되고, 레벨 선택 화면이 구독해도 플레이 화면의
  /// 방출을 영원히 받지 못한다. 조용히 어긋나는 종류의 버그다.
  factory GameUsecases.fromRepositories({
    required MapRepository mapRepository,
    required LevelRepository levelRepository,
    required TutorialRepository tutorialRepository,
    required ProgressRepository progressRepository,
    required SaveClearResultUsecase saveClearResult,
  }) => GameUsecases(
    getMap: GetMapUsecase(repository: mapRepository),
    getLevel: GetLevelUsecase(repository: levelRepository),
    getAllLevels: GetAllLevelsUsecase(repository: levelRepository),
    applyMove: const ApplyMoveUsecase(),
    hasSeenTutorial: HasSeenTutorialUsecase(repository: tutorialRepository),
    markTutorialSeen: MarkTutorialSeenUsecase(repository: tutorialRepository),
    getHighestUnlockedLevel: GetHighestUnlockedLevelUsecase(
      repository: progressRepository,
    ),
    saveClearResult: saveClearResult,
  );

  final GetMapUsecase getMap;

  final GetLevelUsecase getLevel;

  /// "다음 레벨이 있는가" 를 판정하는 데 쓴다.
  final GetAllLevelsUsecase getAllLevels;

  final ApplyMoveUsecase applyMove;

  final HasSeenTutorialUsecase hasSeenTutorial;
  final MarkTutorialSeenUsecase markTutorialSeen;

  /// **잠긴 레벨을 열지 못하게 막는 데 쓴다** (기획서 §5.3). 웹에서는 주소로
  /// 레벨 번호를 직접 칠 수 있어, 화면으로 들어오는 길만 막아서는 부족하다.
  final GetHighestUnlockedLevelUsecase getHighestUnlockedLevel;

  /// 클리어 기록을 저장하고 흘려보낸다. **인스턴스를 공유한다** — 위 factory 주석 참고.
  final SaveClearResultUsecase saveClearResult;
}
