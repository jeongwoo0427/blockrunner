import 'package:blockrunner/core/usecase/base_stream_usecase.dart';
import 'package:blockrunner/feature/level/domain/entity/level.dart';
import 'package:blockrunner/feature/progress/domain/entity/level_progress.dart';
import 'package:blockrunner/feature/progress/domain/repository/progress_repository.dart';

/// 클리어 결과를 저장하고, 저장된 진행도를 흘려보낸다.
///
/// 방출은 레벨 선택 화면이 구독한다(`08-level-select`). 화면을 나갔다 들어와야
/// 해금과 별점이 갱신되는 문제를 없앤다.
class SaveClearResultUsecase with BaseStreamUsecase<LevelProgress> {
  SaveClearResultUsecase({required this._repository});

  final ProgressRepository _repository;

  /// **별점은 여기서 계산한다.** 호출부마다 계산하면 기준이 갈린다.
  /// `progress → level` 은 허용된 방향이다(docs/architecture.md §2).
  ///
  /// 기존 기록보다 나쁘면 저장하지 않고 기존 것을 그대로 돌려준다.
  Future<LevelProgress> call({
    required Level level,
    required int moveCount,
  }) async {
    final existing = _repository.getProgress(level.number);
    final candidate = LevelProgress(
      levelNumber: level.number,
      bestMoveCount: moveCount,
      stars: level.starsFor(moveCount),
    );

    // 재도전이 더 나빠도 최고 기록은 유지한다. 다만 방출은 한다 —
    // 구독자 입장에서는 "이 레벨을 방금 깼다" 는 사실이 여전히 새 정보다.
    final best = candidate.isBetterThan(existing) ? candidate : existing!;
    if (identical(best, candidate)) await _repository.saveProgress(candidate);

    yieldData(best);
    return best;
  }
}
