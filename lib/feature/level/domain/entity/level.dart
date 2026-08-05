/// 레벨 한 판의 **메타데이터**. 판(맵) 자체는 담지 않는다.
///
/// 맵을 여기 품으면 레벨 목록만 그리면 되는 level feature 가 판 모델 전체를
/// 알아야 하고, game 과 순환 의존이 생긴다. 맵은 game feature 의
/// `GameMap` 이 소유하며 레벨 번호로 이어진다.
class Level {
  const Level({
    required this.number,
    required this.minMoves,
    this.name,
    this.tutorial,
  });

  /// 1부터 시작하는 레벨 번호. 순차 해금과 맵 조회의 키다.
  final int number;

  /// 별점 기준이 되는 최소 이동 횟수.
  ///
  /// 맵에서 파생되는 값이지만 여기 둔다. 레벨 선택 화면이 별점을 그리려면
  /// 이 값이 필요한데, 맵 쪽에 두면 level 이 다시 game 을 알아야 한다.
  /// 실제 맵과 일치하는지는 테스트의 완전 탐색이 검증한다.
  final int minMoves;

  /// 표시용 이름. 없으면 번호만 보여준다.
  final String? name;

  /// 이 레벨에서 처음 나오는 규칙 설명 (기획서 §6.1).
  ///
  /// 그 레벨에 처음 도달했을 때 오버레이로 한 번 보여준다. 없으면 넘어간다.
  /// **조작 방법은 여기 넣지 않는다** — 플랫폼마다 달라야 하는데 이건 상수다.
  final String? tutorial;

  bool get hasTutorial => tutorial != null;
}
