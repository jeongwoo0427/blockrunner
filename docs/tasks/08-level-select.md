# 08. 레벨 선택 화면

## 목표

레벨 목록을 보여주고, 해금 상태와 별점을 표시하고, 플레이 화면으로 진입시킨다. 앱의 첫 화면이다.

## 선행 조건

- [03-level-data.md](completed/03-level-data.md), [09-progress.md](completed/09-progress.md)

## 작업

### 1. 화면 파일 일습

`lib/feature/level/presentation/level_select/` — Root / Screen / Notifier / State / Event 규약대로.

### 2. 표시 내용

레벨 카드 그리드. 각 카드에:

- 레벨 번호
- 해금 여부 (잠김이면 자물쇠 + 비활성)
- 별점 ★★☆ (미클리어면 빈 별)
- 최고 기록 이동 횟수

### 3. 해금 규칙

레벨 N을 클리어하면 N+1이 열린다 (game-design §5). 1번은 항상 열려 있다.

### 4. 클리어 결과 실시간 반영

플레이 화면에서 클리어하고 돌아왔을 때 **화면을 다시 만들지 않아도** 별점·해금이 갱신되어야 한다.

`SaveClearResultUsecase`가 `BaseStreamUsecase`를 상속해 흘리는 스트림을 이 화면의 Notifier가 `build()`에서 `listenStream(...)`으로 구독한다 ([../architecture.md](../architecture.md) §6).

> 이것이 quizlab에서 가져온 스트림 usecase 패턴을 쓰는 이유다. 화면을 나갔다 들어와야 갱신되는 문제를 없앤다.

### 5. 라우팅

- `RoutePaths.levelSelect = '/level-select'` — 앱 `initialLocation`
- 카드 탭 → `context.push('${RoutePaths.gamePlay}?level=$n')`
- 잠긴 레벨은 탭해도 이동하지 않는다 (스낵바 등으로 짧게 안내)

### 6. 레이아웃

`GridView` + `SliverGridDelegateWithMaxCrossAxisExtent`로 화면 폭에 따라 열 수가 자동 조정되게 한다 — 모바일 3열, 데스크탑/웹 6열 이상. 자세한 것은 [10-responsive.md](10-responsive.md).

## 완료 기준

- [ ] 앱을 켜면 레벨 선택 화면이 뜬다
- [ ] 잠긴 레벨이 시각적으로 구분되고 진입이 막힌다
- [ ] 레벨을 클리어하고 돌아오면 화면 재진입 없이 별점·해금이 갱신된다
- [ ] 앱을 껐다 켜도 상태가 유지된다
- [ ] 모바일 폭과 데스크탑 폭에서 그리드가 적절히 배치된다
- [ ] `level_select_screen.dart`에 Riverpod import가 없다

## 열린 질문

- 레벨을 챕터/월드로 묶을지 — 레벨 수가 20개를 넘으면 필요해진다. v1은 단일 목록
- 전체 별 개수, 클리어율 같은 요약 표시를 상단에 둘지
- 잠금 없이 전부 열어둘지 — 퍼즐 게임에서는 막힌 레벨을 건너뛰고 싶어하는 수요가 있다. v1은 순차 해금으로 가되 이탈이 관찰되면 재검토
