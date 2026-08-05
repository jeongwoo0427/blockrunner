/// 어느 레벨의 튜토리얼을 이미 봤는지 기억한다 (기획서 §6.1).
///
/// **`09-progress` 와 겹치지 않게 범위를 좁게 잡았다.** 클리어 여부 · 별점 ·
/// 최고 기록은 여기 넣지 않는다. 그건 `progress` feature 가 소유한다.
///
/// 튜토리얼 문구가 `Level` 에 붙어 있으므로 "봤는지" 도 level feature 에 둔다.
/// 이렇게 두면 game 이 알아야 할 것이 `game → level` 한 방향으로 끝난다.
abstract class TutorialRepository {
  bool hasSeen(int levelNumber);

  Future<void> markSeen(int levelNumber);
}
