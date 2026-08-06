/// 화면에 뜨는 모든 문구 (11-i18n).
///
/// **추상 멤버로 선언한다. `Map<String, String>` 을 쓰지 않는다.** 키를 빠뜨리면
/// 컴파일이 깨져야 하기 때문이다. Map 이면 오타가 런타임 빈 문자열이 되고,
/// 그건 그 언어를 읽는 사람만 볼 수 있다.
///
/// **값이 끼어드는 문구는 값이 아니라 함수다.** 그래야 영어의 `1 move` /
/// `2 moves` 같은 복수형 분기를 영어 파일이 자기 안에서 처리한다 — `intl` 의
/// ICU plural 이 하는 일을 Dart 함수가 대신하는 것이 라이브러리를 안 쓰고 얻는
/// 값이다.
///
/// **파서 오류 · `assert` · `debugMessage` 는 여기 없다.** 그것을 읽는 사람은
/// 플레이어가 아니라 레벨을 만드는 사람이라 한국어로 남긴다.
abstract class AppStrings {
  const AppStrings();

  /// 언어 선택 다이얼로그 제목.
  String get language;

  /// 다시하기.
  String get reset;

  // ── 레벨 선택 ──────────────────────────────────────────────────────────

  String get levelSelectTitle;

  String get levelListLoadFailed;

  /// 잠긴 카드의 이름 자리. 레벨 이름은 스포일러라 가린다.
  String get locked;

  /// 아직 못 깬 레벨의 목표 — "최소 3수".
  String minMovesLabel(int minMoves);

  /// 자기 기록 — "3수".
  String movesLabel(int moves);

  /// 잠긴 레벨을 눌렀을 때. [requiredLevel] 을 깨면 열린다.
  String unlockHint(int requiredLevel);

  // ── 플레이 ────────────────────────────────────────────────────────────

  String get levelLoadFailed;

  /// 뒤로가기 툴팁.
  String get backToLevelSelect;

  /// 레벨을 아직 못 읽었을 때의 제목.
  String get levelFallbackTitle;

  /// "레벨 3 · 블록을 밟고". 이름은 [levelName] 에서 가져온다.
  String levelTitle(int number);

  /// HUD 의 이동 횟수 옆에 붙는 목표 — "/ 최소 2수".
  String hudMinMovesLabel(int minMoves);

  // ── 결과 ──────────────────────────────────────────────────────────────

  String get cleared;

  String get fellIntoBlackHole;

  /// 되돌리기가 없으므로 블랙홀에 빠지면 처음부터다 (기획서 §3.5).
  String get retryHint;

  /// "3수 / 최소 2수".
  String clearedSummary(int moves, int minMoves);

  String get backToList;

  String get nextLevel;

  // ── 튜토리얼 ──────────────────────────────────────────────────────────

  String get start;

  String get swipeHint;

  String get keyboardHint;

  // ── 레벨 데이터 ───────────────────────────────────────────────────────

  /// 레벨 번호 → 이름.
  ///
  /// **여기만 `Map` 이다.** 레벨은 계속 늘어나는데 레벨마다 추상 멤버를 두면
  /// 레벨 하나 추가에 5개 파일 × 2줄이 붙는다. 컴파일 검사를 잃는 대신
  /// **키 집합이 `kLevels` 와 일치하는지 테스트가 검사한다.**
  Map<int, String> get levelNames;

  /// 레벨 번호 → 처음 나오는 규칙 설명 (기획서 §6.1).
  ///
  /// 안내가 붙지 않는 레벨은 키가 없다. 어느 레벨이 안내를 갖는지는
  /// **번역이 아니라 레벨 데이터의 성질**이라 `Level.hasTutorial` 이 정하고,
  /// 여기 있는 것은 그 문구뿐이다.
  Map<int, String> get levelTutorials;

  /// 런타임 폴백을 두지 않는다 — 키 패리티 테스트가 통과하면 없을 수 없고,
  /// 없는 상황을 처리하는 코드는 죽은 코드다.
  String levelName(int number) => levelNames[number]!;

  String levelTutorial(int number) => levelTutorials[number]!;
}
