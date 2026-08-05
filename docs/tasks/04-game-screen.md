# 04. 플레이 화면

## 목표

보드를 그리고 게임 상태를 관리하는 플레이 화면 일습을 만든다. 이 시점에는 **애니메이션 없이** 이동이 즉시 반영되어도 된다(06에서 붙인다).

## 선행 조건

- [02-move-engine.md](completed/02-move-engine.md), [03-level-data.md](03-level-data.md)
- 구조 규약: [../architecture.md](../architecture.md) §5

## 작업

### 1. 화면 파일 일습

`lib/feature/game/presentation/game_play/`

| 파일 | 내용 |
|---|---|
| `game_play_root.dart` | `ConsumerStatefulWidget`. `ref.watch`/`ref.read`, 네비게이션, 결과 오버레이 |
| `game_play_screen.dart` | `StatefulWidget`. **Riverpod import 금지.** `state`·`onEvent`만 받는다 |
| `game_play_screen_notifier.dart` | `Notifier<GamePlayScreenState>` |
| `game_play_screen_state.dart` | `@immutable` + `copyWith` |
| `game_play_screen_event.dart` | `sealed class` |
| `widget/board_view.dart` | 보드 위젯 |
| `widget/board_painter.dart` | `CustomPainter` |
| `widget/game_hud.dart` | 레벨 번호, 이동 횟수, 버튼 |

### 2. State

```dart
final Level? level;
final BoardState? board;
final int moveCount;
final bool isAnimating;
final bool isCleared;
final bool isPlayerLost;    // 구멍에 빠져 되돌리기 유도 중
final Failure? failure;
```

### 3. Event

`LoadLevel` / `MoveRequested(Direction)` / `UndoRequested` / `ResetRequested` / `NextLevelRequested` / `BackToLevelSelectRequested`

네비게이션이 필요한 이벤트는 Notifier에서 `break`하고 Root가 처리한다.

### 4. Notifier

- `.autoDispose.family<..., int>` 로 레벨 번호에 키잉 — 화면을 나가면 진행 상태를 버린다
- `build()`에서 레벨을 로드
- `MoveRequested` → `_usecases.applyMove(board, direction)` → `moved == false`면 아무것도 하지 않음
- 이동 후 `board.isCleared` → `isCleared = true` + 진행도 저장 usecase 호출
- 이동 후 `!board.hasPlayer` → `isPlayerLost = true`
- `isAnimating || isCleared || isPlayerLost` 상태에서는 `MoveRequested`를 무시한다

### 5. 렌더링 (`CustomPainter`)

- 보드는 **정사각 유지**. `LayoutBuilder`로 가용 공간의 짧은 변을 잡고 `AspectRatio(1)`.
- 셀 크기 = `min(width, height) / max(rowCount, colCount)`. 격자가 정사각이 아니어도 셀은 정사각이어야 한다.
- 그리는 순서: 배경 → 바닥(목표·구멍) → 격자선 → 벽 → 일반 블록 → 플레이어 블록
- 색은 전부 `ThemeExtension`에서 가져온다. `CustomPainter`에 `Color(0xFF...)`를 박지 않는다.
- `shouldRepaint`는 `board`와 색상 세트만 비교한다.
- 플레이어는 색만이 아니라 **형태로도** 구분되게 한다 (테두리, 아이콘 등) — 색각 접근성.

### 6. 라우팅

`RoutePaths.gamePlay = '/game-play'`, 레벨 번호는 **쿼리 파라미터**로: `/game-play?level=3`.

## 완료 기준

- [ ] 레벨 1이 화면에 정확히 그려진다 (game-design §4.3 초기 배치와 육안 일치)
- [ ] 임시 방향 버튼으로 이동하면 보드가 갱신된다
- [ ] 목표 도달 시 클리어 상태로 전환된다
- [ ] `game_play_screen.dart`에 `flutter_riverpod` import가 없다
- [ ] 창 크기를 바꿔도 보드가 정사각을 유지하고 잘리지 않는다
- [ ] `fvm flutter analyze` 경고 0, `fvm flutter test` 통과

## 열린 질문

- 블록을 `CustomPainter`로 그릴지 위젯(`Positioned` + `AnimatedPositioned`)으로 올릴지 — **애니메이션(06) 구현 난이도가 갈린다.** 바닥·벽은 `CustomPainter`, 움직이는 블록은 위젯으로 얹는 하이브리드가 유력하다. 06 착수 전에 결정할 것
- 결과 오버레이를 다이얼로그로 띄울지 화면 내 레이어로 그릴지
