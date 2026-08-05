# 07. 되돌리기 · 다시하기 · 클리어 처리

## 목표

무제한 되돌리기, 다시하기, 이동 횟수 집계, 클리어 판정과 결과 표시를 완성한다.

## 선행 조건

- [04-game-screen.md](completed/04-game-screen.md)
- 규칙: [../game-design.md](../game-design.md) §5

## 작업

### 1. undo 스택

`BoardState`가 불변이므로 스택은 단순하다.

```dart
final List<BoardState> history;   // 이동 전 상태들
```

- `MoveRequested`가 **실제로 이동을 일으켰을 때만** 현재 보드를 push한다. 무효 입력은 쌓지 않는다.
- `UndoRequested` → pop해서 복원, `moveCount--`
- `history.isEmpty`면 undo 버튼 비활성
- 제한 없음. 8×8 보드 상태 수백 개는 메모리에 부담이 없다.

`state.copyWith`로 리스트를 갈아끼울 때 **새 리스트를 만든다.** 기존 리스트를 `add`로 변형하면 불변 규약이 깨지고 undo가 조용히 망가진다.

### 2. reset

`level.initialBoard`로 되돌리고 `moveCount = 0`, `history` 비움, `isCleared`·`isPlayerLost` 해제.
클리어한 뒤에도 다시하기가 가능해야 한다 (더 적은 수로 재도전).

### 3. 이동 횟수

- 유효 이동에서만 증가
- undo에서 감소 (음수가 되지 않도록)
- reset에서 0

### 4. 플레이어 소실 상태

`!board.hasPlayer` → `isPlayerLost = true`.

- 방향 입력을 받지 않는다
- 되돌리기 / 다시하기 버튼을 강조해 보여준다
- **게임 오버 화면을 띄우지 않는다** — 실패 조건이 없는 게임이다 (game-design §3.5)

### 5. 클리어 처리

이동 후 `board.isCleared`이면:

1. `isCleared = true`
2. 별점 계산 (game-design §5 표)
3. `SaveClearResultUsecase` 호출 — 진행도 저장 + `yieldData()`로 스트림 방출 ([09-progress.md](09-progress.md))
4. 결과 오버레이: 별점, 이동 횟수, 최소 이동 횟수, `[다시하기] [레벨 선택] [다음 레벨]`

**최고 기록만 갱신한다.** 두 번째 플레이가 더 나쁘면 기존 기록을 유지한다.

별점 경계값(1.5배의 반올림/버림)을 여기서 확정하고 game-design §5 표를 갱신한다.

### 6. 버튼 UI

`widget/game_hud.dart`에 `[↶ 되돌리기] [↺ 다시하기]` + 이동 횟수 표시.
키보드 단축키 `Z` / `R` 은 [05-input.md](05-input.md)에서 연결.

## 완료 기준

- [ ] 여러 번 이동 후 연속 undo로 초기 상태까지 정확히 되돌아간다
- [ ] 무효 입력이 undo 스택과 이동 횟수에 영향을 주지 않는다
- [ ] 구멍에 빠진 뒤 undo로 복구된다
- [ ] 클리어 후에도 다시하기로 재도전할 수 있다
- [ ] 별점이 game-design §5 표대로 계산된다 (경계값 단위 테스트 포함)
- [ ] 재도전에서 기록이 나빠져도 최고 기록이 유지된다
- [ ] `fvm flutter test` 통과

## 열린 질문

- undo 횟수를 통계로 보여줄지 (별점에 반영하지는 않음)
- 클리어 후 자동으로 다음 레벨로 넘어갈지, 항상 사용자가 누르게 할지
