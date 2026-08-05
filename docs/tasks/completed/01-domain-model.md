# 01. 도메인 모델

> **상태: 완료** (2026-08-05)

## 목표

게임 규칙을 표현할 엔티티를 정의한다. **Flutter를 import하지 않는 순수 Dart.**

## 선행 조건

- [00-foundation.md](00-foundation.md)
- 규칙은 [../../game-design.md](../../game-design.md) §2, §3 을 따른다

## 작업

`lib/feature/game/domain/entity/` 에 아래를 정의한다.

### `direction.dart`

```dart
enum Direction { up, down, left, right }
```

행/열 델타(`(dRow, dCol)`)를 주는 확장 또는 필드를 함께 둔다.

### `position.dart`

`final int row, col`. `==`/`hashCode` 필수 — Set·Map 키로 쓴다.
`Position translate(Direction d)` 제공.

### `cell.dart`

바닥 종류. **내용물과 분리한다** (game-design §2.2).

```dart
enum FloorType { empty, wall, goal, hole }
```

### `block.dart`

이동하는 것.

```dart
enum BlockType { player, normal }

class Block {
  final int id;           // 애니메이션에서 같은 블록을 추적하기 위한 안정적 식별자
  final BlockType type;
  final Position position;
}
```

> `id`가 필요한 이유: 이동 전/후 보드를 비교해 "어느 블록이 어디서 어디로 갔는지" 알아야 애니메이션을 그릴 수 있다. 위치만으로는 추적이 불가능하다.

### `board_state.dart`

한 시점의 판 전체.

```dart
class BoardState {
  final int rowCount, colCount;
  final List<List<FloorType>> floors;   // 불변, 레벨 내내 동일
  final List<Block> blocks;             // 이동마다 새로 만든다
}
```

편의 메서드: `Block? blockAt(Position)`, `FloorType floorAt(Position)`, `bool contains(Position)`, `Block get player`, `bool get hasPlayer`, `bool get isCleared`.

`isCleared` = 플레이어가 존재하고 그 위치의 바닥이 `goal`.

### `level.dart`

```dart
class Level {
  final int number;
  final String? name;
  final BoardState initialBoard;
  final int minMoves;      // 별점 기준
}
```

### `move_result.dart`

이동 1회의 결과. 애니메이션이 필요로 하는 정보를 전부 담는다.

```dart
class MoveResult {
  final BoardState board;              // 이동 후 상태
  final bool moved;                    // false면 무효 입력
  final Map<int, Position> from;       // blockId → 출발 위치
  final Map<int, Position> to;         // blockId → 도착 위치
  final List<int> fellIntoHole;        // 사라진 blockId
}
```

## 완료 기준

- [x] `lib/feature/game/domain/` 아래 어떤 파일에도 `package:flutter` import가 없다
- [x] `Position`·`Block`·`BoardState`가 `==`/`hashCode`를 손으로 구현했다 (equatable 미사용)
- [x] `copyWith`의 nullable 필드가 `T? Function()?` 패턴을 따른다 — **해당 없음.** 이번 엔티티 중 nullable 필드를 가진 `copyWith`가 생기지 않았다 (아래 "결정 사항" 참고)
- [x] `fvm flutter analyze` 경고 0 — `No issues found!`

## 열린 질문

- `floors`를 `List<List<FloorType>>` 대신 1차원 `List<FloorType>` + 인덱스 계산으로 둘지 — 보드가 작아(최대 8×8=64) 성능 차이는 없으므로 가독성 좋은 쪽을 택한다
  → **2차원 유지로 확정.** `floors[row][col]`이 기획서의 격자 표기와 그대로 대응한다
- `BoardState`를 불변으로 둘 것은 확정. 이동마다 새 인스턴스를 만드는 비용은 이 크기에서 무시할 만하고, undo 스택이 그냥 `List<BoardState>`가 되는 이점이 크다

## 실제 결과

**생성된 파일**

```
lib/feature/game/domain/entity/
├── direction.dart      enum Direction (rowDelta / colDelta)
├── position.dart       Position(row, col) + translate
├── cell.dart           enum FloorType { empty, wall, goal, hole }
├── block.dart          enum BlockType + Block(id, type, position) + moveTo
├── board_state.dart    BoardState + 조회 메서드 + withBlocks
├── level.dart          Level(number, name?, initialBoard, minMoves)
└── move_result.dart    MoveResult(board, moved, from, to, fellIntoHole)

test/feature/game/domain/entity/entity_test.dart   10건
```

**결정 사항**

- **`Position`만 positional 파라미터를 쓴다** (`Position(4, 1)`). 아키텍처 규약(§7)은 named 생성자를 요구하지만, 기획서의 트레이스가 전부 `(행, 열)` 표기이고 테스트에서 좌표가 수십 번 등장한다. `Position(row: 4, col: 1)`은 같은 정보를 두 배 길이로 쓰게 만든다. 순서 혼동을 막기 위해 doc 주석에 "항상 `(행, 열)`"을 명시했다. 나머지 엔티티는 규약대로 named.
- **`copyWith`를 만들지 않았다.** 실제로 필요한 변형은 "블록이 옮겨간다"와 "판의 블록만 교체된다" 둘뿐이라 도메인 언어 그대로 `Block.moveTo(Position)` · `BoardState.withBlocks(List<Block>)`로 뒀다. 쓰이지 않을 범용 `copyWith`를 미리 만들지 않는다.
- **`Block? get player`** — task 문서 초안은 `Block get player` + `hasPlayer`였으나 nullable로 바꿨다. 플레이어는 구멍에 빠져 실제로 사라질 수 있고(기획서 §3.5), 그때 예외를 던지는 게터는 호출부를 불편하게 만든다. `hasPlayer`는 가독성 때문에 남겼다.
- **`floorAt`은 맵 밖에 `FloorType.wall`을 돌려준다.** 기획서 §2.2의 "맵 경계는 벽과 동일하게 취급한다"를 엔티티 수준에서 구현한 것이다. 이동 엔진(`02`)이 "맵 밖" 분기와 "벽" 분기를 따로 쓸 필요가 없어진다.
- **`BoardState`의 동등성은 블록 순서에 둔감하다.** 이동 엔진은 블록을 처리 순서대로 정렬해 내놓으므로 같은 판이 다른 순서로 표현된다. 순서에 민감하면 `02`의 테스트가 규칙과 무관한 이유로 깨진다. `Object.hashAllUnordered`와 집합 비교를 썼다.
- **`MoveResult.to`는 구멍에 빠진 블록의 "사라진 칸"을 담는다.** 낙하 연출(`06`)이 어디서 사라졌는지 알아야 한다.
- `BoardState` 생성자에 `floors` 크기 검증 `assert`를 넣었다. 릴리스 비용이 없고 `03`의 파서 버그를 즉시 잡는다.

## 남은 사항

- 방향별 블록 처리 순서(기획서 §3.2의 정렬 규칙)는 이동 엔진의 관심사이므로 `Direction`에 넣지 않고 `02`로 미뤘다.
- `Level`은 `game/domain/entity/`에 뒀다. `level` feature에서도 참조하게 되는데, 규칙 엔진이 `Level`을 필요로 하므로 game 쪽이 소유자로 맞다고 봤다. `03`에서 재검토 여지 있음.

---

## 정정 (2026-08-05, `05` 착수 전)

**이 문서의 `Level` 관련 서술은 더 이상 유효하지 않다.**

당시 "`Level` 을 `game/domain/entity/` 에 뒀다 … `03` 에서 재검토 여지 있음" 이라고 남겼는데, **`03` 에서 재검토하지 않고 넘어간 것이 `game ⇄ level` 순환 의존을 만들었다.** `Level` 이 `initialBoard` 를 품고 있어 `level` feature 전체가 판 모델을 알아야 했다.

바뀐 내용:

- `Level` → `lib/feature/level/domain/entity/level.dart`, **필드는 `number` · `name` · `minMoves` 뿐**. `initialBoard` 제거
- 판은 `game` 의 새 엔티티 `GameMap(levelNumber, initialBoard)` 가 소유
- 나머지 엔티티(`Position` · `Direction` · `FloorType` · `Block` · `BoardState` · `MoveResult`)는 `game/domain/entity/` 에 그대로

교훈: **"나중에 재검토" 라고 적어둔 것은 실제로 재검토해야 한다.** 그 시점이 `03` 이었고, 놓치는 바람에 화면까지 얹힌 뒤에야 고쳤다.
