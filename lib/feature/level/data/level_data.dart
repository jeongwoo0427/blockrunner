import 'package:blockrunner/feature/level/domain/entity/level.dart';

/// 레벨 메타데이터 상수.
///
/// 파싱할 것이 없으므로 원본 표현(blueprint)과 엔티티를 나누지 않는다.
/// 각 번호에 대응하는 맵은 `lib/feature/game/data/map_blueprints.dart` 에 있고,
/// 두 목록이 어긋나지 않는지는 테스트가 번호로 조인해 검사한다.
///
/// `minMoves` 는 손으로 세지 않는다 — 완전 탐색이 검증한 값이다.
///
/// `tutorial` 은 그 레벨에서 처음 나오는 규칙에만 붙인다. 이미 배운 것을
/// 되풀이하면 읽지 않게 된다. 문구는 `Text` 에 그대로 들어가므로 마크다운을 쓰지 않는다.
const List<Level> kLevels = [
  Level(
    number: 1,
    name: '미끄러지기',
    minMoves: 1,
    tutorial:
        '블록은 벽이나 판 끝에 닿을 때까지 미끄러진다.\n'
        '플레이어를 목표 칸에 정확히 멈춰 세우면 클리어다.',
  ),
  Level(number: 2, name: '벽에 기대어', minMoves: 2),
  Level(
    number: 3,
    name: '블록을 밟고',
    minMoves: 2,
    tutorial:
        '방향을 입력하면 모든 블록이 함께 미끄러진다.\n'
        '다른 블록도 플레이어를 멈춰 세우는 브레이크가 된다.',
  ),
  Level(number: 4, name: '지나쳐버리다', minMoves: 3),
  Level(
    number: 5,
    name: '구멍을 피해',
    minMoves: 3,
    tutorial:
        '구멍은 지나가기만 해도 블록을 삼킨다.\n'
        '멈추는 자리가 아니라 지나는 길을 살펴야 한다.',
  ),
  Level(number: 6, name: '순서가 있다', minMoves: 2),
  Level(
    number: 7,
    name: '보이지 않는 턱',
    minMoves: 2,
    tutorial:
        '칸 사이의 굵은 선은 경계 벽이다.\n'
        '통행만 막을 뿐, 벽 양쪽 칸에는 모두 설 수 있다.',
  ),
];
