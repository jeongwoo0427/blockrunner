# 06. 이동 애니메이션

## 목표

블록이 순간이동하지 않고 미끄러져 보이게 한다. 이 게임의 손맛은 거의 전부 여기서 나온다.

## 선행 조건

- [04-game-screen.md](04-game-screen.md)
- 요구사항: [../game-design.md](../game-design.md) §7
- **선결 사항:** 04의 열린 질문 — 블록을 `CustomPainter`로 그릴지 위젯으로 얹을지

## 작업

### 1. 렌더링 방식 확정

두 안 중 하나를 고른다.

| | `CustomPainter`에서 보간 | 위젯 + `AnimatedPositioned` |
|---|---|---|
| 장점 | 그리기 코드가 한 곳, 성능 예측 쉬움 | 애니메이션 코드가 거의 안 필요 |
| 단점 | 보간을 직접 짜야 함 | 위젯 트리가 커지고 페인터와 좌표계를 이중 관리 |

보드 크기가 최대 64칸이라 어느 쪽이든 성능 문제는 없다.
**권장: 바닥·벽·격자는 `CustomPainter`, 움직이는 블록만 그 위에 위젯으로 얹는 하이브리드.** 블록 수가 적고, 구멍 낙하 같은 개별 연출을 붙이기 쉽다.

### 2. 애니메이션 구동

`AnimationController`(`SingleTickerProviderStateMixin`)를 **Screen의 State**에 둔다. Notifier는 애니메이션을 모른다 — 도메인 상태만 갖는다.

흐름:

```
MoveRequested
  → Notifier가 MoveResult 계산, state.isAnimating = true, board = 새 상태
  → Screen이 didUpdateWidget에서 board 변경을 감지, controller.forward(from: 0)
  → 진행률 t 로 from → to 사이를 보간해 그린다
  → 완료 시 onEvent(AnimationCompleted) → isAnimating = false
```

**모든 블록이 동시에 출발하고 동시에 도착한다.** 이동 거리가 달라도 소요 시간은 같다 (game-design §7). 거리 비례로 하면 턴 리듬이 흐트러진다.

### 3. 파라미터

`core/config/app_constants.dart`에 모은다.

- 지속 시간 120~180ms (기본 150ms)
- 커브 `Curves.easeOut` 계열
- 실제 값은 손으로 플레이해보고 조정한다. 문서의 값은 출발점일 뿐이다.

### 4. 구멍 낙하 연출

슬라이드가 끝난 **직후** 별도 단계로 재생한다. 축소 + 페이드, 100~150ms.
플레이어가 빠진 경우 연출이 끝난 뒤 되돌리기 유도 UI를 띄운다.

### 5. undo / reset 시의 애니메이션

- **undo**: 역방향 슬라이드로 되돌리면 예쁘지만 구현이 복잡하다. v1은 **즉시 반영(애니메이션 없음)** 으로 하고, 여유가 되면 짧은 페이드만 넣는다.
- **reset**: 즉시 반영.

### 6. 접근성

`MediaQuery.disableAnimationsOf(context)`(또는 `MediaQuery.of(context).disableAnimations`)가 참이면 애니메이션을 건너뛰고 즉시 반영한다. 스킵해도 게임 로직은 동일해야 한다.

## 완료 기준

- [ ] 블록이 미끄러지는 것이 보이고, 서로 겹치거나 통과하지 않는다
- [ ] 이동 거리가 다른 블록들이 동시에 출발·도착한다
- [ ] 구멍에 빠지는 연출이 슬라이드 이후 재생된다
- [ ] 애니메이션 중 입력이 무시되고, 완료 후 정상 동작한다
- [ ] 애니메이션 비활성 설정에서 게임이 정상 진행된다
- [ ] 웹에서 프레임 드랍이 없다 (`-d chrome`에서 육안 확인)

## 열린 질문

- 벽에 부딪힐 때 짧은 바운스/셰이크를 넣을지 — 손맛에 크게 기여할 수 있으나 이동 거리별로 도착 시점이 같아야 한다는 제약과 충돌하지 않는지 확인 필요
- 무효 입력(아무것도 안 움직임)일 때 보드를 살짝 흔들어 피드백을 줄지
