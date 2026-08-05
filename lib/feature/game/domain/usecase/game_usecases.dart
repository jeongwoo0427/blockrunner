import 'package:blockrunner/feature/game/domain/usecase/game_usecases/apply_move_usecase.dart';
import 'package:blockrunner/feature/level/domain/repository/level_repository.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases/get_all_levels_usecase.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases/get_level_usecase.dart';

/// 플레이 화면이 쓰는 usecase 묶음 (docs/architecture.md §6).
///
/// 레벨 조회는 level feature 의 usecase 를 그대로 재사용한다. 같은 동작을
/// game 쪽에 다시 만들 이유가 없다.
class GameUsecases {
  const GameUsecases({
    required this.getLevel,
    required this.getAllLevels,
    required this.applyMove,
  });

  factory GameUsecases.fromRepositories({
    required LevelRepository levelRepository,
  }) => GameUsecases(
    getLevel: GetLevelUsecase(repository: levelRepository),
    getAllLevels: GetAllLevelsUsecase(repository: levelRepository),
    applyMove: const ApplyMoveUsecase(),
  );

  final GetLevelUsecase getLevel;

  /// "다음 레벨이 있는가" 를 판정하는 데 쓴다.
  final GetAllLevelsUsecase getAllLevels;

  final ApplyMoveUsecase applyMove;
}
