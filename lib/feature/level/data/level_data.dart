import 'package:blockrunner/feature/level/domain/entity/level.dart';

/// 레벨 메타데이터 상수.
///
/// 파싱할 것이 없으므로 원본 표현(blueprint)과 엔티티를 나누지 않는다.
/// 각 번호에 대응하는 맵은 `lib/feature/game/data/map_blueprints.dart` 에 있고,
/// 두 목록이 어긋나지 않는지는 테스트가 번호로 조인해 검사한다.
///
/// `minMoves` 는 손으로 세지 않는다 — 완전 탐색이 검증한 값이다.
const List<Level> kLevels = [
  Level(number: 1, name: '미끄러지기', minMoves: 1),
  Level(number: 2, name: '벽에 기대어', minMoves: 2),
  Level(number: 3, name: '블록을 밟고', minMoves: 2),
  Level(number: 4, name: '지나쳐버리다', minMoves: 3),
  Level(number: 5, name: '구멍을 피해', minMoves: 3),
  Level(number: 6, name: '순서가 있다', minMoves: 2),
  Level(number: 7, name: '보이지 않는 턱', minMoves: 2),
];
