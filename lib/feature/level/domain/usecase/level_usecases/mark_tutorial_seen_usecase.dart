import 'package:blockrunner/feature/level/domain/repository/tutorial_repository.dart';

class MarkTutorialSeenUsecase {
  const MarkTutorialSeenUsecase({required this._repository});

  final TutorialRepository _repository;

  Future<void> call(int levelNumber) => _repository.markSeen(levelNumber);
}
