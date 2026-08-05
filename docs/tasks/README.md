# 할 일 목록 (Tasks)

기능 단위로 나눈 작업 문서. 각 문서는 **목표 / 선행 조건 / 작업 / 완료 기준 / 열린 질문** 서식을 따른다.

작업을 끝내면 이 표의 상태를 갱신하고, 해당 문서의 완료 기준 체크박스를 채운다.
**완료된 문서는 `completed/` 로 옮긴다.**

## 진행 현황

| # | 문서 | 기능 | 상태 | 선행 |
|---|---|---|:---:|---|
| 00 | [00-foundation.md](completed/00-foundation.md) | 패키지·플랫폼·`core/` 골격 | ✅ 완료 | — |
| 01 | [01-domain-model.md](completed/01-domain-model.md) | 도메인 엔티티 정의 | ✅ 완료 | 00 |
| 02 | [02-move-engine.md](completed/02-move-engine.md) | **이동 규칙 엔진 + 테스트** | ✅ 완료 | 01 |
| 03 | [03-level-data.md](completed/03-level-data.md) | 레벨 상수 데이터 · 파서 · repository | ✅ 완료 | 01 |
| 04 | [04-game-screen.md](completed/04-game-screen.md) | 보드 렌더링 · 플레이 화면 | ✅ 완료 | 02, 03 |
| 05 | [05-input.md](completed/05-input.md) | 크로스플랫폼 입력 | ✅ 완료 | 04 |
| 06 | [06-animation.md](completed/06-animation.md) | 이동 애니메이션 | ✅ 완료 | 04 |
| 07 | [07-undo-reset.md](completed/07-undo-reset.md) | 되돌리기 · 다시하기 · 클리어 처리 | ✅ 완료 | 04 |
| 08 | [08-level-select.md](08-level-select.md) | 레벨 선택 화면 | 대기 | 03, 09 |
| 09 | [09-progress.md](09-progress.md) | 진행도 저장 | 대기 | 00, 07 |
| 10 | [10-responsive.md](10-responsive.md) | 반응형 레이아웃 | 대기 | 04 |

상태값: `대기` / `진행중` / `완료` / `보류`

## 순서에 대하여

**02(이동 엔진)를 04(화면)보다 먼저 한다.** 이 게임의 난이도는 전부 이동 규칙에 있고, 규칙은 Flutter 없이 단위 테스트로 완전히 검증할 수 있다. UI를 먼저 만들면 규칙 버그를 눈으로 디버깅하게 되므로 순서를 뒤집지 않는다.

04까지 끝나면 05·06·07·10은 서로 독립적이라 순서를 바꿔도 된다.

**07은 06 이후에 하는 편이 낫다.** 되돌리기·다시하기가 연출과 어떻게 맞물릴지가 06에서 정해지기 때문이다 — 둘 다 즉시 반영이고, `isAnimating` 을 세우지 않는 것으로 그렇게 된다.

## 참고 문서

- 게임 규칙: [../game-design.md](../game-design.md)
- 아키텍처 규약: [../architecture.md](../architecture.md)
