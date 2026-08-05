import 'package:blockrunner/feature/level/domain/repository/level_repository.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases/get_all_levels_usecase.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases/get_level_usecase.dart';

/// Notifier 가 repository 를 직접 부르지 못하게 하는 usecase 묶음
/// (docs/architecture.md §6).
class LevelUsecases {
  const LevelUsecases({required this.getAllLevels, required this.getLevel});

  factory LevelUsecases.fromRepositories({
    required LevelRepository levelRepository,
  }) => LevelUsecases(
    getAllLevels: GetAllLevelsUsecase(repository: levelRepository),
    getLevel: GetLevelUsecase(repository: levelRepository),
  );

  final GetAllLevelsUsecase getAllLevels;
  final GetLevelUsecase getLevel;
}
