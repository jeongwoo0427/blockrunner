import 'package:blockrunner/feature/progress/domain/entity/level_progress.dart';
import 'package:blockrunner/feature/progress/domain/repository/progress_repository.dart';

class GetAllProgressUsecase {
  const GetAllProgressUsecase({required this._repository});

  final ProgressRepository _repository;

  Map<int, LevelProgress> call() => _repository.getAllProgress();
}
