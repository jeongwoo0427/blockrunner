import 'package:blockrunner/feature/level/domain/entity/level.dart';
import 'package:blockrunner/feature/level/domain/entity/tutorial_demo.dart';

/// 레벨 메타데이터 상수.
///
/// 파싱할 것이 없으므로 원본 표현(blueprint)과 엔티티를 나누지 않는다.
/// 각 번호에 대응하는 맵은 `lib/feature/game/data/map_blueprints.dart` 에 있고,
/// 두 목록이 어긋나지 않는지는 테스트가 번호로 조인해 검사한다.
///
/// `minMoves` 는 손으로 세지 않는다 — 완전 탐색이 검증한 값이다.
///
/// **이름과 안내 문구는 여기 없다** (11-i18n). 언어마다 다르므로
/// `lib/core/i18n/strings_*.dart` 에 있고, 이 목록은 번호로 이어질 뿐이다.
/// `demo` 만 남는다 — 어느 레벨이 **무엇을** 가르치는지는 번역이 아니라
/// 레벨 설계의 문제다. 이미 배운 것을 되풀이하면 읽지 않게 되므로 처음 나오는
/// 규칙에만 붙인다.
const List<Level> kLevels = [
  Level(number: 1, minMoves: 2, demo: TutorialDemo.slide),
  Level(number: 2, minMoves: 2),
  Level(number: 3, minMoves: 2, demo: TutorialDemo.blockBrake),
  Level(number: 4, minMoves: 4, demo: TutorialDemo.edgeWall),
  Level(number: 5, minMoves: 4),
  Level(number: 6, minMoves: 5),
  Level(number: 7, minMoves: 5),
  Level(number: 8, minMoves: 6),
  Level(number: 9, minMoves: 5),
  Level(number: 10, minMoves: 8),
  Level(number: 11, minMoves: 7),
  Level(number: 12, minMoves: 7),
  Level(number: 13, minMoves: 5, demo: TutorialDemo.blackHole),
  Level(number: 14, minMoves: 9),
  Level(number: 15, minMoves: 7),
  Level(number: 16, minMoves: 7),
  Level(number: 17, minMoves: 8),
  Level(number: 18, minMoves: 8),
  Level(number: 19, minMoves: 9),
  Level(number: 20, minMoves: 9),
];
