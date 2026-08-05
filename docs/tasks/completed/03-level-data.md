# 03. 레벨 데이터

> **상태: 완료** (2026-08-05)

## 목표

레벨을 ASCII 상수로 정의하고, 파서와 `LevelRepository`를 통해 도메인 엔티티로 공급한다.

## 선행 조건

- [01-domain-model.md](01-domain-model.md)
- 표기법: [../../game-design.md](../../game-design.md) §9

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

`lib/feature/level/data/repository/level_repository_impl.dart` — **datasource 없이 상수를 직접 보유한다** ([../../architecture.md](../../architecture.md) §3).
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

각 레벨의 `minMoves`는 [02-move-engine.md](02-move-engine.md)의 남은 사항대로, BFS 솔버를 이 작업에서 만들어 검증한다.

## 완료 기준

- [x] 최소 6개 레벨이 정의되어 있다 — 6개
- [x] 모든 레벨이 파싱되고 유효성 검증을 통과하는 테스트가 있다
- [x] BFS 솔버로 모든 레벨의 `minMoves`가 실제 최소값과 일치함을 확인했다
- [x] `LevelRepositoryImpl`에 datasource 계층이 없다
- [x] `fvm flutter test` 전체 통과 — 74/74

## 열린 질문

- 레벨을 JSON 에셋으로 뺄지 상수로 둘지 — **상수로 확정.** 앱 업데이트 없이 레벨을 추가할 계획이 없고, 상수는 컴파일 타임에 타입 검사를 받는다
- 레벨 이름/테마를 붙일지 (`Level.name`은 nullable로 열어둠)
  → **붙이기로 확정.** 6개 레벨 전부에 한국어 이름을 넣었다(`미끄러지기`, `벽에 기대어`, …). 각 레벨이 무슨 개념을 가르치는지가 이름에 드러나야 레벨 목록(`08`)이 읽힌다. `nullable` 은 그대로 두어 이름 없는 레벨도 허용한다
- 6×6 외 크기(8×8)를 언제 도입할지
  → **v1 초기 세트는 전부 6×6.** 엔진·파서는 이미 `N×M` 을 지원하고 파서 테스트가 2행 판·비정사각 판을 다룬다. 큰 판은 개념이 다 나온 뒤(7번 이후) 도입하는 것이 맞다

## 실제 결과

**생성된 파일**

```
lib/feature/level/
├── level_di.dart                                       Data / Domain 배너
├── data/
│   ├── level_blueprints.dart                           LevelBlueprint + kLevelBlueprints 6개
│   ├── level_parser.dart                               ASCII → Level + 유효성 검증
│   └── repository/level_repository_impl.dart           상수 직접 보유 · 파싱 결과 캐시
└── domain/
    ├── repository/level_repository.dart
    └── usecase/
        ├── level_usecases.dart                         컨테이너
        └── level_usecases/{get_all_levels,get_level}_usecase.dart

test/feature/level/
├── level_solver.dart                                   BFS 완전 탐색 (테스트 전용)
├── level_parser_test.dart                              11건
├── level_blueprints_test.dart                          14건 (레벨당 2건 자동 생성)
└── level_repository_impl_test.dart                     5건
```

**레벨 세트** — 전부 6×6, `minMoves` 는 BFS 완전 탐색으로 검증됨

| # | 이름 | minMoves | 도입 개념 |
|---|---|:---:|---|
| 1 | 미끄러지기 | 1 | 미끄러짐 + 맵 경계로 정지 |
| 2 | 벽에 기대어 | 2 | 벽으로 정지 |
| 3 | 블록을 밟고 | 2 | 일반 블록을 브레이크로 (기획서 §4.3 레벨) |
| 4 | 지나쳐버리다 | 3 | 목표를 지나쳐버리는 실패 경험 |
| 5 | 구멍을 피해 | 3 | 구멍 회피 |
| 6 | 순서가 있다 | 2 | 조합 — 브레이크 + 구멍이 순서를 강제 |

**결정 사항**

- **BFS 솔버를 `test/` 에만 뒀다** (task 문서 지침대로). `minMoves` 는 손으로 세는 값이라 틀리기 쉽고, 틀리면 별점 기준이 조용히 어긋난다. 레벨을 추가하면 `kLevelBlueprints` 를 순회하는 테스트가 자동으로 따라붙어 파싱·유효성·최소 이동 횟수를 전부 검사한다.
- **솔버는 플레이어가 구멍에 빠진 판을 막다른 길로 친다.** 되돌리기 외에 길이 없으므로 탐색을 이어갈 이유가 없다. 상태 키는 블록 배치만으로 만든다 — 바닥은 레벨 내내 고정이다.
- **"목표에 정지 요소가 있는가" 검사는 벽과 맵 경계만 센다.** 일반 블록은 함께 미끄러지므로 정적인 브레이크가 아니다. 이 검사는 명백히 도달 불가능한 레벨을 걸러내는 값싼 그물이고, 진짜 풀이 가능 여부는 BFS 가 본다.
- **레벨 4·5는 "먼저 떠오르는 수가 실패하는" 구조로 만들었다.** 4는 목표를 향해 곧장 밀면 지나쳐버리고, 5는 곧장 밀면 구멍에 빠진다. 튜토리얼이 개념을 설명 없이 몸으로 가르치려면 실패가 즉시 눈에 보여야 한다.
- **`LevelRepositoryImpl` 은 blueprint 와 parser 를 생성자로 받되 기본값을 상수로 둔다.** DI 는 `LevelRepositoryImpl()` 그대로 쓰고, 테스트만 잘못된 데이터를 주입한다.
- **파싱은 첫 접근 시점에 한 번만 하고 캐시한다.** 상수 데이터라 결과가 바뀌지 않는다. 잘못된 레벨은 앱 시작이 아니라 첫 접근에서 터지는데, 테스트가 전 레벨을 파싱하므로 배포 전에 잡힌다.
- **생성자를 Dart 3의 private named parameter(`{required this._repository}`)로 썼다.** quizlab 의 `{required X x}) : _x = x` 형태는 `prefer_initializing_formals` 린트에 걸린다. 호출부 이름은 `repository:` 그대로다. `docs/architecture.md` §6 에 반영했다.

## 남은 사항

- `level_di.dart` 의 Presentation 절은 배너만 있고 비어 있다. 레벨 선택 화면의 Notifier 는 `08` 에서 붙인다.
- 별점 경계값(기획서 §5의 1.5배 반올림/버림)은 아직 확정하지 않았다. `09-progress` 의 몫이다.

---

## 정정 (2026-08-05, `05` 착수 전)

**이 문서가 서술하는 파일 배치는 더 이상 유효하지 않다.** 레벨 데이터가 맵과 메타데이터로 쪼개졌다.

| 이 문서의 것 | 실제 |
|---|---|
| `level/data/level_blueprints.dart` (`LevelBlueprint`, rows + minMoves) | `game/data/map_blueprints.dart` (`MapBlueprint`, rows) + `level/data/level_data.dart` (`kLevels`, 번호 · 이름 · minMoves) |
| `level/data/level_parser.dart` (`→ Level`) | `game/data/map_parser.dart` (`→ GameMap`) |
| `LevelRepository.getLevel → Level(판 포함)` | `LevelRepository`(메타데이터) + `MapRepository`(판), 둘 다 유지 |
| `FailureCode.invalidLevelData` | `invalidMapData`, `mapNotFound` 추가 |
| `test/feature/level/level_blueprints_test.dart` | `test/feature/game/map_and_level_data_test.dart` — 두 목록을 **번호로 조인**해 검사 |

이유는 `docs/architecture.md` §2 "feature 의존 방향" 에 있다. `Level` 이 판을 품는 한 `level` 이 `game` 을 알아야 하고, `game` 은 레벨 조회 때문에 `level` 을 알아야 해서 순환이 생겼다.

**BFS 솔버로 `minMoves` 를 검증한다는 결정은 그대로 유효하다.** 오히려 쪼개진 뒤 더 중요해졌다 — 이제 맵과 `minMoves` 가 서로 다른 파일에 있으므로, 한쪽만 고치면 조용히 어긋난다. 솔버가 그걸 막는다.
