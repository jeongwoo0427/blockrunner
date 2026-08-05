import 'dart:math';

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

  /// [moveCount] 수로 클리어했을 때의 별점 1~3 (기획서 §5.2).
  ///
  /// [minMoves] 를 20% 이내로 초과하면 ★★★, 40% 이내면 ★★☆다.
  ///
  /// 되돌리기 사용 횟수는 반영하지 않는다 — 되돌리면 이동 횟수가 이미 줄어
  /// 있으므로 이중으로 세는 셈이 된다.
  int starsFor(int moveCount) {
    if (moveCount <= minMoves + _slack(0.2, atLeast: 1)) return 3;
    if (moveCount <= minMoves + _slack(0.4, atLeast: 2)) return 2;
    return 1;
  }

  /// 허용 초과 수. **비율과 고정 하한 중 큰 쪽**이다.
  ///
  /// 비율만 쓰면 짧은 레벨이 무너진다 — [minMoves] 가 2면 20% 는 0.4수라
  /// 버림하면 0이 되어, 한 수만 더 써도 곧장 ★☆☆다. 튜토리얼 레벨일수록
  /// 가혹해지는 뒤집힌 난이도가 된다.
  ///
  /// 버림을 쓰는 이유는 반올림이 [minMoves] 홀수일 때만 한 수를 더 얹어줘서
  /// 기준을 레벨마다 들쭉날쭉하게 만들기 때문이다.
  int _slack(double ratio, {required int atLeast}) =>
      max(atLeast, (minMoves * ratio).floor());
}
