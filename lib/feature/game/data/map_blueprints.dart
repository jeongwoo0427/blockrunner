/// 맵 원본 데이터. data 계층의 표현이며 도메인 `GameMap` 과 분리한다.
///
/// 파싱은 `MapParser` 가 맡는다.
class MapBlueprint {
  const MapBlueprint({required this.levelNumber, required this.rows});

  /// 대응하는 레벨 번호. `kLevels` 와 이 값으로 조인된다.
  final int levelNumber;

  /// ASCII 맵. 기호는 기획서 §2.2 를 그대로 쓴다.
  /// `.` 빈칸 · `#` 벽 · `O` 일반블록 · `@` 플레이어 · `G` 목표 · `X` 구멍
  final List<String> rows;
}

/// 튜토리얼 성격으로 개념을 하나씩 도입하는 순서다.
/// 각 레벨의 이름과 최소 이동 횟수는 `lib/feature/level/data/level_data.dart` 에 있다.
// 맵은 세로로 늘어놓아야 눈으로 검증할 수 있다. 포매터가 한 줄로 접는 것을 막는다.
// dart format off
const List<MapBlueprint> kMapBlueprints = [
  // 1 — 미끄러짐과 맵 경계. 오른쪽으로 밀면 끝까지 가서 목표에 선다.
  MapBlueprint(
    levelNumber: 1,
    rows: [
      '......',
      '......',
      '..@..G',
      '......',
      '......',
      '......',
    ],
  ),

  // 2 — 벽이 브레이크가 된다. 아래 벽에 걸려 멈춘 뒤, 목표 뒤의 벽에 걸려 목표에 선다.
  MapBlueprint(
    levelNumber: 2,
    rows: [
      '@.....',
      '......',
      '......',
      '......',
      '..G#..',
      '#.....',
    ],
  ),

  // 3 — 기획서 §4.3 의 레벨. 일반 블록이 플레이어의 브레이크로 쓰인다.
  //     O 가 없으면 @ 는 바닥까지 내려가 버린다.
  MapBlueprint(
    levelNumber: 3,
    rows: [
      '......',
      '.@....',
      '.O....',
      '......',
      '..G#..',
      '......',
    ],
  ),

  // 4 — 지나쳐버리는 경험. 오른쪽으로 밀면 목표를 지나 끝까지 간다.
  //     목표를 멈춰 세울 벽은 아래쪽(3,2)에 있으므로 위에서 내려와야 한다.
  MapBlueprint(
    levelNumber: 4,
    rows: [
      '...#..',
      '......',
      '@.G...',
      '..#...',
      '......',
      '......',
    ],
  ),

  // 5 — 구멍 회피. 목표를 향해 곧장 밀면 구멍에 빠진다. 판을 크게 돌아야 한다.
  MapBlueprint(
    levelNumber: 5,
    rows: [
      '......',
      '.....#',
      '@.X..G',
      '......',
      '......',
      '......',
    ],
  ),

  // 6 — 조합. 3번과 같은 브레이크 구조에 구멍을 더했다.
  //     목표 방향으로 먼저 밀면 구멍에 빠지므로 순서가 강제된다.
  MapBlueprint(
    levelNumber: 6,
    rows: [
      '......',
      '.@..X.',
      '.O....',
      '......',
      '..G#..',
      '......',
    ],
  ),
];
// dart format on
