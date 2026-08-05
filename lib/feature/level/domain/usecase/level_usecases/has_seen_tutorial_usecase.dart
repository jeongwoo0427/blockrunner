import 'package:blockrunner/feature/level/domain/repository/tutorial_repository.dart';

class HasSeenTutorialUsecase {
  const HasSeenTutorialUsecase({required this._repository});

  final TutorialRepository _repository;

  bool call(int levelNumber) => _repository.hasSeen(levelNumber);
}
