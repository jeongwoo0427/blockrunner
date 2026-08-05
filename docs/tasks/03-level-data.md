# 03. 레벨 데이터

## 목표

레벨을 ASCII 상수로 정의하고, 파서와 `LevelRepository`를 통해 도메인 엔티티로 공급한다.

## 선행 조건

- [01-domain-model.md](01-domain-model.md)
- 표기법: [../game-design.md](../game-design.md) §9

## 작업

### 1. 레벨 상수

`lib/feature/level/data/level_blueprints.dart`

```dart
/// 레벨 원본 데이터. 사람이 읽고 쓸 수 있도록 ASCII 로 적는다.
/// 기호: . 빈칸  # 벽  O 일반블록  @ 플레이어  G 목표  X 구멍
const List<LevelBlueprint> kLevelBlueprints = [
  LevelBlueprint(
    number: 1,
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
  ...
];
```

`LevelBlueprint`는 data 계층의 원본 표현이다. 도메인 `Level`과 분리한다.

### 2. 파서

`lib/feature/level/data/level_parser.dart` — `LevelBlueprint → Level`.

**로드 시점에 유효성을 검증하고, 위반하면 throw한다:**

- 모든 행의 길이가 동일한가
- 알 수 없는 기호가 없는가
- 플레이어가 정확히 1개인가
- 목표가 최소 1개인가
- 목표 칸이 도달 가능한가 — 네 방향 중 최소 하나에 정지 요소(벽/맵 경계)가 있는가 (game-design §4.3의 레벨 디자인 원칙)

> 잘못된 레벨은 배포 전에 터져야 한다. 조용히 넘어가면 플레이어가 클리어 불가능한 레벨을 만난다.

`test/`에 "모든 `kLevelBlueprints`가 파싱된다" 테스트를 둔다. 레벨을 추가할 때마다 자동 검증된다.

### 3. Repository

`lib/feature/level/domain/repository/level_repository.dart`

```dart
abstract class LevelRepository {
  List<Level> getAllLevels();
  Level getLevel(int number);
  int get levelCount;
}
```

`lib/feature/level/data/repository/level_repository_impl.dart` — **datasource 없이 상수를 직접 보유한다** ([../architecture.md](../architecture.md) §3).
파싱 결과는 한 번만 계산해 캐시한다.

### 4. Usecase + DI

- `GetAllLevelsUsecase`, `GetLevelUsecase` → `LevelUsecases` 컨테이너
- `lib/feature/level/level_di.dart` — `Data → Domain → Presentation` 배너 순서

### 5. 초기 레벨 세트

튜토리얼 성격으로 개념을 하나씩 도입하는 순서로 만든다.

| 레벨 | 도입 개념 |
|---|---|
| 1 | 미끄러짐 + 맵 경계로 정지 |
| 2 | 벽으로 정지 |
| 3 | 일반 블록을 브레이크로 사용 |
| 4 | 목표를 지나쳐버리는 실패 경험 |
| 5 | 구멍 회피 |
| 6~ | 조합 |

각 레벨의 `minMoves`는 [02-move-engine.md](02-move-engine.md)의 BFS 솔버로 검증한다.

## 완료 기준

- [ ] 최소 6개 레벨이 정의되어 있다
- [ ] 모든 레벨이 파싱되고 유효성 검증을 통과하는 테스트가 있다
- [ ] BFS 솔버로 모든 레벨의 `minMoves`가 실제 최소값과 일치함을 확인했다
- [ ] `LevelRepositoryImpl`에 datasource 계층이 없다
- [ ] `fvm flutter test` 전체 통과

## 열린 질문

- 레벨을 JSON 에셋으로 뺄지 상수로 둘지 — **상수로 확정.** 앱 업데이트 없이 레벨을 추가할 계획이 없고, 상수는 컴파일 타임에 타입 검사를 받는다
- 레벨 이름/테마를 붙일지 (`Level.name`은 nullable로 열어둠)
- 6×6 외 크기(8×8)를 언제 도입할지
