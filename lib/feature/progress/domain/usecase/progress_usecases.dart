import 'package:blockrunner/feature/progress/domain/repository/progress_repository.dart';
import 'package:blockrunner/feature/progress/domain/usecase/progress_usecases/get_all_progress_usecase.dart';
import 'package:blockrunner/feature/progress/domain/usecase/progress_usecases/get_highest_unlocked_level_usecase.dart';
import 'package:blockrunner/feature/progress/domain/usecase/progress_usecases/save_clear_result_usecase.dart';

/// 진행도 usecase 묶음 (docs/architecture.md §6).
class ProgressUsecases {
  const ProgressUsecases({
    required this.getAllProgress,
    required this.getHighestUnlockedLevel,
    required this.saveClearResult,
  });

  factory ProgressUsecases.fromRepositories({
    required ProgressRepository progressRepository,
  }) => ProgressUsecases(
    getAllProgress: GetAllProgressUsecase(repository: progressRepository),
    getHighestUnlockedLevel: GetHighestUnlockedLevelUsecase(
      repository: progressRepository,
    ),
    saveClearResult: SaveClearResultUsecase(repository: progressRepository),
  );

  final GetAllProgressUsecase getAllProgress;
  final GetHighestUnlockedLevelUsecase getHighestUnlockedLevel;

  /// 스트림을 흘리므로 **단일 인스턴스여야 한다.** provider 가 그것을 보장한다.
  final SaveClearResultUsecase saveClearResult;
}
