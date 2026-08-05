import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/feature/level/domain/entity/level.dart';
import 'package:blockrunner/feature/progress/domain/entity/level_progress.dart';
import 'package:flutter/foundation.dart';

@immutable
class LevelSelectScreenState {
  const LevelSelectScreenState({
    this.levels = const [],
    this.progress = const {},
    this.highestUnlockedLevel = 1,
    this.failure,
  });

  final List<Level> levels;

  /// 레벨 번호 → 진행도. **클리어하지 않은 레벨은 키가 없다.**
  final Map<int, LevelProgress> progress;

  /// 플레이할 수 있는 가장 높은 레벨 번호 (기획서 §5.3).
  final int highestUnlockedLevel;

  final Failure? failure;

  /// 1번은 항상 열려 있다 — 저장소가 비어도 `highestUnlockedLevel` 이 1이다.
  bool isUnlocked(int levelNumber) => levelNumber <= highestUnlockedLevel;

  LevelProgress? progressOf(int levelNumber) => progress[levelNumber];

  LevelSelectScreenState copyWith({
    List<Level>? levels,
    Map<int, LevelProgress>? progress,
    int? highestUnlockedLevel,
    Failure? Function()? failure,
  }) {
    return LevelSelectScreenState(
      levels: levels ?? this.levels,
      progress: progress ?? this.progress,
      highestUnlockedLevel: highestUnlockedLevel ?? this.highestUnlockedLevel,
      failure: failure != null ? failure() : this.failure,
    );
  }
}
