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
| 08 | [08-level-select.md](completed/08-level-select.md) | 레벨 선택 화면 | ✅ 완료 | 03, 09 |
| 09 | [09-progress.md](completed/09-progress.md) | 진행도 저장 | ✅ 완료 | 00, 07 |
| 10 | [10-responsive.md](completed/10-responsive.md) | 반응형 레이아웃 | ✅ 완료 | 04 |
| 11 | [11-i18n.md](completed/11-i18n.md) | 다국어 (ko·en·ja·zh·fr) | ✅ 완료 | 00, 08 |
| 12 | [12-ui-polish.md](completed/12-ui-polish.md) | UI 디테일 — 스플래시 · 그리드 · 블랙홀 · 다이얼로그 | ✅ 완료 | 10, 11 |
| 13 | [13-game-feel.md](completed/13-game-feel.md) | 게임다운 손맛 — 버튼 · 카드 · 별 연출 · 튜토리얼 데모 · 쫀득거림 | ✅ 완료 | 12 |
| 14 | [14-web-deploy.md](completed/14-web-deploy.md) | 웹 개시 — Docker 이미지 · nginx 서빙 | ✅ 완료 | — |

상태값: `대기` / `진행중` / `완료` / `보류`

## 순서에 대하여

**02(이동 엔진)를 04(화면)보다 먼저 한다.** 이 게임의 난이도는 전부 이동 규칙에 있고, 규칙은 Flutter 없이 단위 테스트로 완전히 검증할 수 있다. UI를 먼저 만들면 규칙 버그를 눈으로 디버깅하게 되므로 순서를 뒤집지 않는다.

04까지 끝나면 05·06·07·10은 서로 독립적이라 순서를 바꿔도 된다.

**12는 안에서 순서가 정해져 있다.** 아홉 단계이고 문서에 이유가 적혀 있다 — 특히 `구멍 → 블랙홀` 이름 변경은 **기획서를 먼저** 고친 뒤 코드를 치환한다. 이름이 문서와 코드에서 갈리는 중간 상태를 만들지 않는다.

**11(다국어)을 10(반응형)보다 먼저 했다.** 순서를 강제하지 않기로 했는데 실제로 뒤집혔고, 덕분에 `10` 의 "긴 문구에서 안 깨지는가" 를 5개 언어로 실제로 확인할 수 있게 됐다.

**07은 06 이후에 하는 편이 낫다.** 되돌리기·다시하기가 연출과 어떻게 맞물릴지가 06에서 정해지기 때문이다 — 둘 다 즉시 반영이고, `isAnimating` 을 세우지 않는 것으로 그렇게 된다.

## 참고 문서

- 게임 규칙: [../game-design.md](../game-design.md)
- 아키텍처 규약: [../architecture.md](../architecture.md)
