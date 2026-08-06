import 'package:blockrunner/feature/level/domain/repository/tutorial_repository.dart';
import 'package:blockrunner/feature/progress/domain/repository/progress_repository.dart';

/// 진행도를 처음으로 되돌린다 (12-ui-polish §3).
///
/// **두 저장소를 함께 지운다** — 별점·기록은 `progress`, 튜토리얼 본 기록은
/// `level` 이 갖고 있다. 진행도만 지우면 레벨 1을 다시 깨도 안내가 안 떠서
/// "처음부터" 가 아니다.
///
/// **`settings` 가 아니라 여기 있는 이유**: 지울 것이 `progress` 와 `level` 양쪽에
/// 있는데 `settings` 가 둘을 알면 `level → settings → level` 순환이 된다.
/// `level` 은 이미 `progress` 를 알고 튜토리얼은 자기 것이라 새 간선이 없다.
///
/// **언어 설정은 건드리지 않는다.** 진행도가 아니라 취향이고, 그래서 `09` 에서
/// 저장소 접두사를 갈라 두었다.
class ResetProgressUsecase {
  const ResetProgressUsecase({
    required this._progressRepository,
    required this._tutorialRepository,
  });

  final ProgressRepository _progressRepository;
  final TutorialRepository _tutorialRepository;

  Future<void> call() async {
    await _progressRepository.clearAll();
    await _tutorialRepository.clearAll();
  }
}
