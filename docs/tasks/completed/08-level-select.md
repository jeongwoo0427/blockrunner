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

`GridView` + `SliverGridDelegateWithMaxCrossAxisExtent`로 화면 폭에 따라 열 수가 자동 조정되게 한다 — 모바일 3열, 데스크탑/웹 6열 이상. 자세한 것은 [10-responsive.md](10-responsive.md) — 완료됐고 `maxCrossAxisExtent: 160` 은 그대로 남았다.

## 완료 기준

- [x] 앱을 켜면 레벨 선택 화면이 뜬다
- [x] 잠긴 레벨이 시각적으로 구분되고 진입이 막힌다
- [x] 레벨을 클리어하고 돌아오면 화면 재진입 없이 별점·해금이 갱신된다 — **구독을 제거하는 교란으로 테스트가 실패하는 것까지 확인했다**
- [x] 앱을 껐다 켜도 상태가 유지된다 — 저장은 `09` 가, 읽기는 이 화면이 한다
- [x] 모바일 폭과 데스크탑 폭에서 그리드가 적절히 배치된다 — 폭 400 과 1200 에서 열 수가 늘어나는지 테스트
- [x] `level_select_screen.dart`에 Riverpod import가 없다 — `ProviderScope` 없이 pump 하는 테스트가 가드다

## 열린 질문

- 레벨을 챕터/월드로 묶을지 — 레벨 수가 20개를 넘으면 필요해진다. v1은 단일 목록
- **전체 별 개수, 클리어율 같은 요약 표시를 상단에 둘지 — 여전히 미결정.** 넣지 않았다. 레벨이 7개뿐이라 카드를 훑으면 바로 보이고, 요약은 레벨이 늘어난 뒤에 값이 생긴다
- 잠금 없이 전부 열어둘지 — 퍼즐 게임에서는 막힌 레벨을 건너뛰고 싶어하는 수요가 있다. v1은 순차 해금으로 가되 이탈이 관찰되면 재검토

---

## 실제 결과

### 착수 전에 순환 의존을 끊어야 했다

레벨 선택 화면은 `level` 에 있고 진행도가 필요하므로 **`level → progress`** 다. 그런데 `09` 에서 `SaveClearResultUsecase` 가 별점 계산을 위해 `Level` 을 받게 만들어 **`progress → level`** 이 이미 있었다. 그대로 두면 `#22` 에서 끊었던 것과 같은 순환이다.

`progress` 가 `Level` 에서 쓰던 것은 `number` 와 `starsFor` 의 **결과**뿐이라, 둘을 값으로 받게 바꿔 간선을 끊었다. 별점 공식은 여전히 `Level.starsFor` 한 곳에만 있고 호출부(플레이 화면)가 그것을 불러 넘긴다.

이제 `progress` 는 **어느 feature 도 모른다.** `game → level`, `game → progress`, `level → progress` 세 간선이 모두 한 방향이다.

### `LevelUsecases` 가 스트림만 받는다

`SaveClearResultUsecase` 를 통째로 넘기면 레벨 선택 화면이 저장까지 할 수 있게 되는데 저장은 플레이 화면의 일이다. `Stream<LevelProgress>` 만 받아 구독 전용으로 뒀다. 인스턴스를 새로 만들지 않는 이유는 `GameUsecases` 와 같다 — 스트림이 갈리면 방출을 영영 못 받는다.

### 알림이 오면 저장소를 다시 읽는다

방출된 `LevelProgress` 를 상태에 끼워넣지 않고 `_load()` 를 다시 부른다. 한 번의 클리어가 그 레벨의 별점만이 아니라 **해금 상태까지** 바꾸고, 그 계산은 저장소가 이미 갖고 있다. 끼워넣기만 하면 해금 규칙이 두 곳에 생긴다. 이것을 검사하는 테스트를 따로 뒀다.

### 잠긴 카드도 누를 수 있다

`InkWell` 을 살려두고 이동만 막는다. 아예 못 누르게 하면 **왜 안 되는지 알 수 없다.** 누르면 "N-1번 레벨을 클리어하면 열린다" 를 스낵바로 알린다. 잠긴 레벨은 이름도 가린다 — 앞으로 무엇이 나오는지가 스포일러다.

### Screen 을 `StatelessWidget` 으로 뒀다

규약(`architecture.md` §5)의 "Screen 은 `StatefulWidget`" 은 컨트롤러·포커스 같은 로컬 UI 상태를 두기 위한 것인데 이 화면엔 그럴 것이 없다. 빈 `State` 클래스는 잡음이라 판단했다. `GamePlayScreen` 은 포커스와 드래그 누적을 들고 있어 그대로 `StatefulWidget` 이다.

### 남은 사항

- **육안 확인을 못 했다.** 그리드 간격과 카드 비율(`childAspectRatio: 0.85`)은 눈으로 봐야 한다
- `SliverGridDelegateWithMaxCrossAxisExtent` 의 `maxCrossAxisExtent: 160` 은 출발점이다. `10-responsive` 에서 다른 화면들과 함께 맞춘다
- 상단 요약(전체 별 개수)은 넣지 않았다 — 위 열린 질문 참고
