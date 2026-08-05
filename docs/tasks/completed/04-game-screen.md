# 04. 플레이 화면

> **상태: 완료** (2026-08-05)

## 목표

보드를 그리고 게임 상태를 관리하는 플레이 화면 일습을 만든다. 이 시점에는 **애니메이션 없이** 이동이 즉시 반영되어도 된다(06에서 붙인다).

## 선행 조건

- [02-move-engine.md](02-move-engine.md), [03-level-data.md](03-level-data.md)
- 구조 규약: [../../architecture.md](../../architecture.md) §5

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

- [x] 레벨 1이 화면에 정확히 그려진다 — 블록 배치·개수를 위젯 테스트로 검증. **육안 확인은 못 했다**(아래 "남은 사항")
- [x] 임시 방향 버튼으로 이동하면 보드가 갱신된다
- [x] 목표 도달 시 클리어 상태로 전환된다
- [x] `game_play_screen.dart`에 `flutter_riverpod` import가 없다 — `ProviderScope` 없이 pump 하는 테스트가 가드한다
- [x] 창 크기를 바꿔도 보드가 정사각을 유지하고 잘리지 않는다 — 4개 화면 크기에 대한 레이아웃 테스트
- [x] `fvm flutter analyze` 경고 0, `fvm flutter test` 통과 — 97/97

## 열린 질문

- 블록을 `CustomPainter`로 그릴지 위젯(`Positioned` + `AnimatedPositioned`)으로 올릴지 — **애니메이션(06) 구현 난이도가 갈린다.**
  → **하이브리드로 확정** (사용자 결정). 바닥·격자선·벽은 `BoardPainter`, 움직이는 블록만 `Positioned` + `BlockTile` 로 얹는다. `06` 은 `Positioned` 를 `AnimatedPositioned` 로 바꾸는 것으로 슬라이드를 얻고, 구멍 낙하도 블록별 위젯 애니메이션으로 붙일 수 있다. 대가는 페인터와 위젯이 좌표계를 공유해야 한다는 것인데, **셀 크기 계산을 `BoardView` 한 곳에만 두어** 막았다
- 결과 오버레이를 다이얼로그로 띄울지 화면 내 레이어로 그릴지
  → **화면 내 레이어로 확정** (사용자 결정). `state.isCleared`/`isPlayerLost` 에서 선언적으로 파생되므로 Screen 이 `showDialog` 도 Riverpod 도 모르는 채로 남고, 중복 호출 방지 같은 명령형 처리가 필요 없다. 보드가 뒤에 계속 보이는 것도 이 게임에는 이점이다

## 실제 결과

**생성된 파일**

```
lib/feature/game/
├── game_di.dart                                     Data(없음) / Domain / Presentation
├── domain/usecase/game_usecases.dart                getLevel · getAllLevels · applyMove
└── presentation/game_play/
    ├── game_play_root.dart                          자리표시자 → ConsumerStatefulWidget
    ├── game_play_screen.dart                        dumb StatefulWidget
    ├── game_play_screen_notifier.dart
    ├── game_play_screen_state.dart
    ├── game_play_screen_event.dart
    └── widget/{board_view,board_painter,block_tile,game_hud,result_overlay}.dart

test/feature/game/presentation/
├── game_play_screen_test.dart                       8건 (ProviderScope 없이 pump)
├── game_play_screen_notifier_test.dart              10건
└── board_view_layout_test.dart                      5건
```

**결정 사항**

- **Riverpod 3 에는 `FamilyNotifier` 가 없다.** 3.0 에서 제거됐고(`flutter_riverpod-3.0.3/CHANGELOG.md:29`) family 의 생성 함수가 `Notifier Function(Arg)` 이므로, **레벨 번호를 Notifier 생성자로 받는다**(`GamePlayScreenNotifier(this.levelNumber)`). `ref.$arg` 는 `@internal` 코드젠 전용이라 쓰지 않았다. 아키텍처 §4 의 `NotifierProvider.autoDispose.family<N, S, int>(N.new)` 표기는 그대로 유효하다
- **`ResetRequested` 를 이번 범위에 포함했다.** 원래 `07` 의 몫이지만, 플레이어가 구멍에 빠지면 방향 입력이 막히는데(기획서 §3.5) undo 도 리셋도 없으면 화면이 잠긴다. `UndoRequested` 는 히스토리 스택이 필요하므로 `07` 에 남겼다
- **`LoadLevel` 이벤트를 두지 않았다.** Notifier 의 `build()` 가 레벨을 로드하므로 중복이다
- **`Positioned` 에 `ValueKey(block.id)` 를 붙였다.** 지금은 필요 없지만 `06` 에서 `AnimatedPositioned` 로 바꿀 때 같은 블록으로 추적되려면 안정적인 키가 있어야 한다. `01` 에서 `Block.id` 를 만든 이유가 여기서 쓰인다
- **셀 크기 계산은 `BoardView` 에만 있다.** 페인터와 블록 위젯이 각자 계산하면 언젠가 어긋난다
- **목표 칸은 채우지 않고 링으로 그린다.** 블록이 그 위에 서도 "목표였다"는 사실이 보여야 한다
- **플레이어 블록에 안쪽 링을 넣었다.** 색만으로 구분하면 색각 이상에서 일반 블록과 뒤섞인다
- **`Screen` 의 Riverpod 무지를 테스트로 강제했다.** `game_play_screen_test.dart` 는 `ProviderScope` 로 감싸지 않으므로, Screen 이 Riverpod 을 건드리는 순간 테스트가 터진다. 규약을 문서가 아니라 테스트가 지킨다
- **"창 크기를 바꿔도 정사각" 을 육안이 아니라 테스트로 검증했다.** 4개 화면 크기에서 보드 영역의 가로세로가 같은지, `maxBoardExtent` 를 넘지 않는지, 비정사각 판(2×6)에서 셀이 정사각인지를 본다. 오버플로가 나면 Flutter 가 예외를 던지므로 "잘리지 않는다" 는 통과 자체로 검증된다

## 남은 사항

- **육안 확인을 못 했다.** `fvm flutter run -d web-server --web-port 8123` 로 빌드·서빙까지는 성공했으나(HTTP 200), 이 환경에서 브라우저 확장이 연결되지 않아 화면을 캡처하지 못했다. 배치·레이아웃·상태 전이는 위젯 테스트로 대신 검증했지만, **색 대비나 여백 같은 시각적 완성도는 사람이 한 번 봐야 한다**
- 방향 버튼은 임시다. 스와이프·키보드는 `05-input` 에서 붙인다
- 클리어해도 진행도가 저장되지 않는다. `09-progress` 의 몫이다
- `game_di.dart` 의 Data 절은 비어 있다 — game 전용 repository 가 없고 `levelRepositoryProvider` 를 재사용한다
