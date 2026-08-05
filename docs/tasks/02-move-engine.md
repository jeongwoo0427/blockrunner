# 02. 이동 규칙 엔진

> **이 프로젝트에서 가장 중요한 작업이다.** 게임의 재미와 버그가 전부 여기 들어있다.
> UI 없이 단위 테스트만으로 완전히 검증 가능해야 한다.

## 목표

방향 입력을 받아 다음 보드 상태를 계산하는 **순수 함수**를 구현하고, 테스트로 규칙을 고정한다.

## 선행 조건

- [01-domain-model.md](01-domain-model.md)
- 규칙 원문: [../game-design.md](../game-design.md) §3, 검증용 트레이스: §4

## 작업

### 1. 엔진

`lib/feature/game/domain/usecase/game_usecases/apply_move_usecase.dart`

```dart
class ApplyMoveUsecase {
  MoveResult call(BoardState board, Direction direction);
}
```

의존성 없음(repository도 받지 않음). 순수 계산이다.

알고리즘은 game-design §3.2 그대로:

1. 이동 방향 기준 **가장 앞쪽 블록부터** 정렬
   - `→` 열 내림차순 · `←` 열 오름차순 · `↓` 행 내림차순 · `↑` 행 오름차순
2. 각 블록을 한 칸씩 전진
   - 맵 밖 / 벽 / **이미 정착한** 블록 → 현재 칸에 정착
   - 진입한 칸의 바닥이 구멍 → 제거 (정착 아님)
   - 그 외 → 계속
3. 아무 블록도 움직이지 않았으면 `moved: false`

**놓치기 쉬운 두 지점:**
- 장애물 판정은 "정착 완료된 블록"만 대상으로 한다. 아직 처리 안 된 블록은 어차피 같은 방향으로 비켜나므로 막지 않는다.
- 구멍은 **정지 지점이 아니라 통과 경로**에서 판정한다. 지나가기만 해도 빠진다.

### 2. 테스트

`test/feature/game/apply_move_usecase_test.dart`

ASCII 맵으로 케이스를 쓰고 결과도 ASCII로 비교하는 헬퍼를 먼저 만든다. 그래야 테스트가 읽힌다.

```dart
expectMove(
  before: ['@O...G'],
  direction: Direction.right,
  after:    ['....@O'],
);
```

**필수 케이스:**

| 분류 | 케이스 |
|---|---|
| 기본 | 빈 판에서 맵 끝까지 미끄러짐 (4방향 각각) |
| 벽 | 벽 직전에 정지 / 벽에 붙어 있어 못 움직임 |
| 블록 | 블록 뒤에 줄서기 / 정렬 순서 검증 (game-design §4.1 트레이스 그대로) |
| 목표 | 목표 칸 통과 후 더 감 (클리어 아님) / 목표 칸에 정지 (클리어) |
| 구멍 | 지나가다 빠짐 (§4.2 트레이스) / 플레이어가 빠짐 → `hasPlayer == false` |
| 무효 | 전 블록이 이미 그 방향 끝 → `moved == false` |
| 회귀 | game-design §4.3 6×6 레벨 2수 클리어 전체 |
| 경계 | 1×1, 1행 보드, 블록 없이 플레이어만 |

`MoveResult.from`/`to`/`fellIntoHole`이 정확한지도 검증한다 — 애니메이션이 이 값에 의존한다.

### 3. 최소 이동 횟수 검증 (선택)

레벨 데이터의 `minMoves`가 진짜 최소인지 확인하는 BFS 솔버를 **테스트 전용 유틸**로 두면 유용하다. 상태 공간이 작아(블록 배치의 경우의 수) 완전 탐색이 가능하다.

`lib/`에는 넣지 않는다. `test/` 아래 헬퍼로만 둔다. → [03-level-data.md](03-level-data.md)에서 활용.

## 완료 기준

- [ ] `ApplyMoveUsecase`가 `package:flutter`를 import하지 않는다
- [ ] game-design §4의 트레이스 3개가 전부 테스트로 존재하고 통과한다
- [ ] 위 표의 8개 분류가 모두 커버된다
- [ ] `fvm flutter test` 전체 통과
- [ ] 엔진 코드에 `print`/디버그 잔재 없음

## 열린 질문

- 합체 규칙을 나중에 넣을 수 있도록 "블록이 서로 만났을 때의 처리"를 별도 함수로 분리해둘지. 지금 추상화하면 YAGNI지만, 만나는 지점 한 곳만 함수로 빼두는 정도는 비용이 없다
- `MoveResult.from`을 `Map` 대신 `List<BlockMove>` 레코드로 둘지 — 애니메이션 구현(06)에서 어느 쪽이 편한지 보고 정한다
