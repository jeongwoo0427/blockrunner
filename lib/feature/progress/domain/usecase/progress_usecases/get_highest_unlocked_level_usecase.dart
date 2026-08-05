import 'package:blockrunner/feature/progress/domain/repository/progress_repository.dart';

class GetHighestUnlockedLevelUsecase {
  const GetHighestUnlockedLevelUsecase({required this._repository});

  final ProgressRepository _repository;

  int call() => _repository.highestUnlockedLevel;
}
