import 'package:blockrunner/core/usecase/base_stream_usecase.dart';
import 'package:blockrunner/feature/progress/domain/entity/level_progress.dart';
import 'package:blockrunner/feature/progress/domain/repository/progress_repository.dart';

/// 클리어 결과를 저장하고, 저장된 진행도를 흘려보낸다.
///
/// 방출은 레벨 선택 화면이 구독한다(`08-level-select`). 화면을 나갔다 들어와야
/// 해금과 별점이 갱신되는 문제를 없앤다.
class SaveClearResultUsecase with BaseStreamUsecase<LevelProgress> {
  SaveClearResultUsecase({required this._repository});

  final ProgressRepository _repository;

  /// **[Level] 이 아니라 값을 받는다.** 별점 공식은 `Level.starsFor` 에 그대로
  /// 있고 호출부가 그것을 불러 넘긴다.
  ///
  /// 여기서 `Level` 을 받으면 `progress → level` 간선이 생기는데, 레벨 선택
  /// 화면이 진행도를 읽어야 해서 `level → progress` 도 필요하다 — 순환이 된다.
  /// `progress` 는 어느 feature 에도 기대지 않는 것이 이 배치의 핵심이다
  /// (docs/architecture.md §2).
  ///
  /// 기존 기록보다 나쁘면 저장하지 않고 기존 것을 그대로 돌려준다.
  Future<LevelProgress> call({
    required int levelNumber,
    required int moveCount,
    required int stars,
  }) async {
    final existing = _repository.getProgress(levelNumber);
    final candidate = LevelProgress(
      levelNumber: levelNumber,
      bestMoveCount: moveCount,
      stars: stars,
    );

    // 재도전이 더 나빠도 최고 기록은 유지한다. 다만 방출은 한다 —
    // 구독자 입장에서는 "이 레벨을 방금 깼다" 는 사실이 여전히 새 정보다.
    final best = candidate.isBetterThan(existing) ? candidate : existing!;
    if (identical(best, candidate)) await _repository.saveProgress(candidate);

    yieldData(best);
    return best;
  }
}
