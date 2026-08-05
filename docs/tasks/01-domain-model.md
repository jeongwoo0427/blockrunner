# 01. 도메인 모델

## 목표

게임 규칙을 표현할 엔티티를 정의한다. **Flutter를 import하지 않는 순수 Dart.**

## 선행 조건

- [00-foundation.md](completed/00-foundation.md)
- 규칙은 [../game-design.md](../game-design.md) §2, §3 을 따른다

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

- [ ] `lib/feature/game/domain/` 아래 어떤 파일에도 `package:flutter` import가 없다
- [ ] `Position`·`Block`·`BoardState`가 `==`/`hashCode`를 손으로 구현했다 (equatable 미사용)
- [ ] `copyWith`의 nullable 필드가 `T? Function()?` 패턴을 따른다
- [ ] `fvm flutter analyze` 경고 0

## 열린 질문

- `floors`를 `List<List<FloorType>>` 대신 1차원 `List<FloorType>` + 인덱스 계산으로 둘지 — 보드가 작아(최대 8×8=64) 성능 차이는 없으므로 가독성 좋은 쪽을 택한다
- `BoardState`를 불변으로 둘 것은 확정. 이동마다 새 인스턴스를 만드는 비용은 이 크기에서 무시할 만하고, undo 스택이 그냥 `List<BoardState>`가 되는 이점이 크다
