import 'package:blockrunner/feature/level/domain/entity/level.dart';
import 'package:blockrunner/feature/level/domain/repository/level_repository.dart';

class GetAllLevelsUsecase {
  const GetAllLevelsUsecase({required this._repository});

  final LevelRepository _repository;

  List<Level> call() => _repository.getAllLevels();
}
