import 'package:blockrunner/feature/progress/domain/entity/level_progress.dart';

/// 진행도 저장소. **읽기는 동기, 쓰기는 비동기다.**
///
/// `SharedPreferences` 가 값을 메모리에 캐시하므로 읽기를 `Future` 로 감쌀
/// 이유가 없다. 화면이 로딩 상태 없이 즉시 그릴 수 있다.
abstract class ProgressRepository {
  /// 레벨 번호 → 진행도. 클리어하지 않은 레벨은 **키 자체가 없다.**
  Map<int, LevelProgress> getAllProgress();

  LevelProgress? getProgress(int levelNumber);

  Future<void> saveProgress(LevelProgress progress);

  /// 플레이할 수 있는 가장 높은 레벨 번호 (기획서 §5.3).
  /// 아무것도 클리어하지 않았으면 1이다.
  int get highestUnlockedLevel;

  /// 개발·테스트용. 화면에는 노출하지 않는다.
  Future<void> clearAll();
}
