# 05. 크로스플랫폼 입력

## 목표

모바일·웹·데스크탑에서 각각 자연스러운 방식으로 4방향 입력을 받는다. 게임 로직은 건드리지 않는다 — 전부 `MoveRequested(Direction)` 하나로 수렴시킨다.

## 선행 조건

- [04-game-screen.md](04-game-screen.md)
- 요구사항: [../game-design.md](../game-design.md) §6

## 작업

### 1. 스와이프 (모바일 · 터치)

`GestureDetector`의 `onPanEnd` 또는 `onPanUpdate`로 판정한다.

- 최소 이동 거리 임계값을 둔다 (예: 24 logical px). 그보다 짧으면 탭으로 보고 무시.
- 가로 성분과 세로 성분 중 **절대값이 큰 쪽**으로 방향을 결정한다.
- 대각선 스와이프를 4방향으로 강제 매핑하는 셈이므로, 두 성분이 비슷할 때의 동작을 테스트한다.

### 2. 키보드 (웹 · 데스크탑)

`Focus` + `KeyboardListener`(또는 `Shortcuts`/`Actions`).

| 키 | 방향 |
|---|---|
| `ArrowUp` / `W` | 위 |
| `ArrowDown` / `S` | 아래 |
| `ArrowLeft` / `A` | 왼쪽 |
| `ArrowRight` / `D` | 오른쪽 |
| `Z` / `Ctrl+Z` | 되돌리기 |
| `R` | 다시하기 |

**화면 진입 시 자동으로 포커스를 잡아야 한다.** 안 그러면 웹에서 키가 안 먹고, 사용자는 이유를 모른다. 다이얼로그가 닫힌 뒤 포커스를 되찾는 것도 확인한다.

`KeyDownEvent`만 처리한다. `KeyRepeatEvent`를 처리하면 키를 누르고 있을 때 연타된다 — 애니메이션 중 입력 무시 규칙과 겹쳐 동작이 어색해지므로 명시적으로 거른다.

### 3. 화면 방향 버튼

세 플랫폼 공통 보조 수단. 마우스만 쓰는 사용자와 접근성 때문에 항상 제공한다.
십자(D-pad) 배치, 보드 아래 또는 옆(가로 레이아웃일 때).

### 4. 입력 게이트

모든 입력 경로가 한 곳을 지나게 한다.

```dart
void _requestMove(Direction d) {
  if (state.isAnimating || state.isCleared || state.isPlayerLost) return;
  onEvent(MoveRequested(d));
}
```

**입력을 큐잉하지 않는다** (game-design §6). 애니메이션 중 들어온 입력은 버린다.

## 완료 기준

- [ ] 모바일 에뮬레이터에서 스와이프 4방향이 동작한다
- [ ] `-d chrome`에서 페이지 로드 직후 클릭 없이 방향키가 먹는다
- [ ] 데스크탑 빌드에서 방향키·WASD·Z·R이 동작한다
- [ ] 화면 방향 버튼이 세 플랫폼 모두에서 동작한다
- [ ] 애니메이션 중 연타해도 보드가 꼬이지 않는다
- [ ] 스와이프 방향 판정 로직에 단위 테스트가 있다 (delta → Direction 순수 함수로 분리해둘 것)

## 열린 질문

- 마우스 드래그를 스와이프로 취급할지 — `GestureDetector`는 기본적으로 마우스 드래그도 pan으로 받는다. 켜두는 쪽이 웹에서 자연스러워 보이나, 방향 버튼과 중복이라 사용자 반응을 보고 정한다
- 게임패드 지원 — v1 제외
- 방향 버튼을 항상 보일지, 터치 기기에서는 숨길지 — [10-responsive.md](10-responsive.md)와 함께 결정
