import 'package:blockrunner/feature/level/domain/repository/level_repository.dart';
import 'package:blockrunner/feature/level/domain/repository/tutorial_repository.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases/get_all_levels_usecase.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases/get_level_usecase.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases/reset_progress_usecase.dart';
import 'package:blockrunner/feature/progress/domain/entity/level_progress.dart';
import 'package:blockrunner/feature/progress/domain/repository/progress_repository.dart';
import 'package:blockrunner/feature/progress/domain/usecase/progress_usecases/get_all_progress_usecase.dart';
import 'package:blockrunner/feature/progress/domain/usecase/progress_usecases/get_highest_unlocked_level_usecase.dart';

/// Notifier 가 repository 를 직접 부르지 못하게 하는 usecase 묶음
/// (docs/architecture.md §6).
///
/// 레벨 선택 화면이 목록과 진행도를 함께 그리므로 둘 다 여기 모은다.
/// 의존은 **level → progress 한 방향뿐이다** — `progress` 는 어느 feature 도 모른다.
class LevelUsecases {
  const LevelUsecases({
    required this.getAllLevels,
    required this.getLevel,
    required this.getAllProgress,
    required this.getHighestUnlockedLevel,
    required this.resetProgress,
    required this.clearResults,
  });

  /// [clearResults] 는 **스트림만** 받는다.
  ///
  /// `SaveClearResultUsecase` 를 통째로 넘기면 레벨 선택 화면이 저장까지 할 수
  /// 있게 되는데 저장은 플레이 화면의 일이다. 여기서는 구독만 한다.
  /// 새로 만들지 않고 넘겨받는 이유는 `game_usecases.dart` 와 같다 — 스트림이
  /// 갈리면 방출을 영영 받지 못한다.
  factory LevelUsecases.fromRepositories({
    required LevelRepository levelRepository,
    required ProgressRepository progressRepository,
    required TutorialRepository tutorialRepository,
    required Stream<LevelProgress> clearResults,
  }) => LevelUsecases(
    getAllLevels: GetAllLevelsUsecase(repository: levelRepository),
    getLevel: GetLevelUsecase(repository: levelRepository),
    getAllProgress: GetAllProgressUsecase(repository: progressRepository),
    getHighestUnlockedLevel: GetHighestUnlockedLevelUsecase(
      repository: progressRepository,
    ),
    resetProgress: ResetProgressUsecase(
      progressRepository: progressRepository,
      tutorialRepository: tutorialRepository,
    ),
    clearResults: clearResults,
  );

  final GetAllLevelsUsecase getAllLevels;
  final GetLevelUsecase getLevel;

  final GetAllProgressUsecase getAllProgress;
  final GetHighestUnlockedLevelUsecase getHighestUnlockedLevel;

  /// 진행도와 튜토리얼 기록을 함께 지운다 (12-ui-polish §3).
  final ResetProgressUsecase resetProgress;

  /// 플레이 화면에서 레벨을 클리어했다는 알림. 화면을 나갔다 들어오지 않아도
  /// 별점·해금이 갱신되게 한다 (docs/architecture.md §6).
  final Stream<LevelProgress> clearResults;
}
