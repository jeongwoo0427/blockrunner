/// 레벨 원본 데이터. data 계층의 표현이며 도메인 `Level` 과 분리한다.
///
/// 파싱은 [LevelParser] 가 맡는다.
class LevelBlueprint {
  const LevelBlueprint({
    required this.number,
    required this.minMoves,
    required this.rows,
    this.name,
  });

  final int number;

  /// 최소 이동 횟수. 별점 기준이자, 레벨이 의도대로 만들어졌는지의 검증값이다.
  /// `test/feature/level/level_solver.dart` 의 완전 탐색이 이 값을 검증한다.
  final int minMoves;

  /// ASCII 맵. 기호는 기획서 §2.2 를 그대로 쓴다.
  /// `.` 빈칸 · `#` 벽 · `O` 일반블록 · `@` 플레이어 · `G` 목표 · `X` 구멍
  final List<String> rows;

  final String? name;
}

/// 튜토리얼 성격으로 개념을 하나씩 도입하는 순서다.
const List<LevelBlueprint> kLevelBlueprints = [
  // 미끄러짐과 맵 경계. 오른쪽으로 밀면 끝까지 가서 목표에 선다.
  LevelBlueprint(
    number: 1,
    name: '미끄러지기',
    minMoves: 1,
    rows: [
      '......',
      '......',
      '..@..G',
      '......',
      '......',
      '......',
    ],
  ),

  // 벽이 브레이크가 된다. 아래 벽에 걸려 멈춘 뒤, 목표 뒤의 벽에 걸려 목표에 선다.
  LevelBlueprint(
    number: 2,
    name: '벽에 기대어',
    minMoves: 2,
    rows: [
      '@.....',
      '......',
      '......',
      '......',
      '..G#..',
      '#.....',
    ],
  ),

  // 기획서 §4.3 의 레벨. 일반 블록이 플레이어의 브레이크로 쓰인다.
  // O 가 없으면 @ 는 바닥까지 내려가 버린다.
  LevelBlueprint(
    number: 3,
    name: '블록을 밟고',
    minMoves: 2,
    rows: [
      '......',
      '.@....',
      '.O....',
      '......',
      '..G#..',
      '......',
    ],
  ),

  // 지나쳐버리는 경험. 오른쪽으로 밀면 목표를 지나 끝까지 간다.
  // 목표를 멈춰 세울 벽은 아래쪽(3,2)에 있으므로 위에서 내려와야 한다.
  LevelBlueprint(
    number: 4,
    name: '지나쳐버리다',
    minMoves: 3,
    rows: [
      '...#..',
      '......',
      '@.G...',
      '..#...',
      '......',
      '......',
    ],
  ),

  // 구멍 회피. 목표를 향해 곧장 밀면 구멍에 빠진다. 판을 크게 돌아야 한다.
  LevelBlueprint(
    number: 5,
    name: '구멍을 피해',
    minMoves: 3,
    rows: [
      '......',
      '.....#',
      '@.X..G',
      '......',
      '......',
      '......',
    ],
  ),

  // 조합. 3번과 같은 브레이크 구조에 구멍을 더했다.
  // 목표 방향으로 먼저 밀면 구멍에 빠지므로 순서가 강제된다.
  LevelBlueprint(
    number: 6,
    name: '순서가 있다',
    minMoves: 2,
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
