/// 레벨 하나의 진행도. 클리어하지 않은 레벨은 아예 저장되지 않는다.
///
/// 이동 횟수와 별점을 **둘 다** 담는다. 별점은 이동 횟수에서 파생되지만,
/// 별점 기준이 바뀌어도(§5.2 는 이미 두 번 바뀌었다) 저장된 기록이 그때의
/// 판단을 유지하도록 함께 적어둔다.
class LevelProgress {
  const LevelProgress({
    required this.levelNumber,
    required this.bestMoveCount,
    required this.stars,
  });

  final int levelNumber;

  /// 이 레벨을 푼 가장 적은 이동 횟수.
  final int bestMoveCount;

  /// 그때의 별점 1~3 (기획서 §5.2).
  final int stars;

  /// 저장된 진행도가 있다는 것이 곧 클리어했다는 뜻이다.
  /// 미클리어를 `cleared: false` 로 적어두면 빈 레코드가 쌓이기만 한다.
  bool get isCleared => true;

  /// [other] 보다 나은 기록인가. **이동 횟수가 적을수록 낫다.**
  ///
  /// 별점으로 비교하지 않는다 — 같은 별점 안에서도 더 적은 수가 더 나은
  /// 기록이고, 별점 기준이 바뀌면 비교가 뒤집힐 수 있다.
  bool isBetterThan(LevelProgress? other) =>
      other == null || bestMoveCount < other.bestMoveCount;

  Map<String, Object?> toJson() => {
    'bestMoveCount': bestMoveCount,
    'stars': stars,
  };

  /// 손상된 값이면 `null`. **throw 하지 않는다** — 진행도는 잃어도 되는
  /// 데이터이고, 이것 때문에 앱이 켜지지 않으면 안 된다.
  static LevelProgress? fromJson(int levelNumber, Map<String, Object?> json) {
    final bestMoveCount = json['bestMoveCount'];
    final stars = json['stars'];
    if (bestMoveCount is! int || stars is! int) return null;
    if (bestMoveCount < 0 || stars < 1 || stars > 3) return null;

    return LevelProgress(
      levelNumber: levelNumber,
      bestMoveCount: bestMoveCount,
      stars: stars,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LevelProgress &&
      other.levelNumber == levelNumber &&
      other.bestMoveCount == bestMoveCount &&
      other.stars == stars;

  @override
  int get hashCode => Object.hash(levelNumber, bestMoveCount, stars);

  @override
  String toString() =>
      'LevelProgress($levelNumber, $bestMoveCount수, ★$stars)';
}
