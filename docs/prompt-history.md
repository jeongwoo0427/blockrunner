# 프롬프트 기록 (Prompt History)

이 프로젝트에서 AI에게 요청한 내역과 그 결과를 시간순으로 기록한다.
가장 오래된 항목이 위, 새 항목은 아래에 추가한다.

기록 형식:

```
## YYYY-MM-DD #N — 한 줄 제목

**요청**
> 사용자 프롬프트 (요약하지 말고 핵심 그대로)

**한 일**
- 실제로 수행한 작업

**변경 파일**
- `path/to/file` — 무엇이 바뀌었는지

**결정 / 메모**
- 이 요청에서 내린 판단, 남은 과제, 논의된 트레이드오프
```

---

## 2026-08-05 #1 — 초기 커밋

**요청**
> 여기 새로 생성한 프로젝트인데, 이거 내 깃에 최초 커밋 올려주면 좋겠어

**한 일**
- `git init` (기본 브랜치 `main`) 후 Flutter 스캐폴드 131개 파일 최초 커밋 (`d918ac1`)
- `gh` CLI가 없고 원격 저장소가 아직 없어 푸시는 사용자가 직접 수행

**변경 파일**
- 저장소 전체 (초기 커밋)

**결정 / 메모**
- `.idea/`, `.dart_tool/`, `.fvm/`, `*.iml` 은 `.gitignore` 대로 제외

---

## 2026-08-05 #2 — CLAUDE.md 작성

**요청**
> CLAUDE.md 작성부터 해줘. (캐퍼시의 바이브코딩 이론 기반 행동 가이드라인 전문 제공)

**한 일**
- 제공받은 가이드라인 4개 섹션을 그대로 반영하고, 하단에 프로젝트 특화 섹션 추가

**변경 파일**
- `CLAUDE.md` — 신규

**결정 / 메모**
- Flutter 버전이 FVM으로 고정(`.fvmrc` → 3.44.8)되어 있어 모든 명령에 `fvm` 접두사 사용을 규칙화
- 검증 기본값: `fvm flutter analyze && fvm flutter test`

---

## 2026-08-05 #3 — docs 폴더 및 프롬프트 기록 체계 도입

**요청**
> 이건 게임으로 만들거거든? flame 이런거 안쓰고, 플러터 네이티브 프레임워크로만 진행하는 게임이야. 그 전에 문서화는 꼼꼼히 해야해서. 일단 docs 폴더 만들고 그 안에 내가 AI프롬프트 작성할 때마다 내역들 남겨주는 문서가 있으면 좋겠어. CLAUDE.md에도 이 점 매번 잊지 않도록 내용 추가해주고

**한 일**
- `docs/prompt-history.md` 신설, 지난 요청 2건을 소급 기록
- `CLAUDE.md`에 "게임 엔진 미사용" 제약과 프롬프트 기록 규칙 추가

**변경 파일**
- `docs/prompt-history.md` — 신규
- `CLAUDE.md` — 프로젝트 섹션에 제약/문서화 규칙 추가

**결정 / 메모**
- 게임 엔진(Flame 등) 사용 금지. 렌더링/게임 루프는 Flutter 기본 프레임워크(`CustomPainter`, `Ticker`/`AnimationController` 등)로 직접 구현
- 기록은 단일 파일 누적 방식. 파일이 길어지면 연/월 단위(`prompt-history-2026-08.md`)로 분리

---

## 2026-08-05 #4 — 커밋

**요청**
> 커밋 해줘

**한 일**
- `CLAUDE.md` 수정분과 `docs/` 신규 파일을 커밋 (`0021a79`)

**변경 파일**
- 없음 (커밋 작업만)

**결정 / 메모**
- 이 항목 자체도 규칙에 따라 기록해야 하므로, 기록을 추가한 뒤 같은 커밋에 amend 하여 합침

---

## 2026-08-05 #5 — 게임 규칙 확정 및 프로젝트 구조 문서화

**요청**
> 자 그 다음은, 이 프로젝트의 구조와 의도먼저 설정할게.
> 1. 이 프로젝트는 간단한 퍼즐 게임이고, 웹, 앱, 데스크탑 모두 호환 가능한 플랫폼이야.
> 2. 프로젝트 구조는 ClearArchitecture(feature first)를 활용하도록 할거고. ../quizlab 쪽 앱보면 di, mvvm, repository패턴 등 기본구조를 갖춘걸 토대로 이 프로젝트에도 적용하면 좋겠어. (api활용은 없고, 맵데이터들은 전부 상수로 선언 예정, datasource계층은 필요 없고 repositoryImpl에서 직접 데이터 가지고 있다가 내보낼 예정)
> 3. tasks라는 폴더 만들어서 앞으로 할 일들에 대해 정리해주는 문서를 기능별로 나눠주면 좋겠어.
> 4. 플랜모드 켜고 이정도까지 먼저 작업 진행하자.
>
> (추가) 6x6이든 8x8이든 다양한 형태의 맵에 벽들이 있고, 블럭들 중에 플레이어 블럭이 있어서 목표지점에 도착하면 레벨이 끝난다. 2048의 아이디어를 혼합해서 우로 이동하면 모든 블럭이 우로 이동하고, 맵 끝이나 벽을 만나면 직전에 멈춘다. 아직 기획단계니깐 개발을 바로 하지 말고 문서화만 꼼꼼하게 하자.

**한 일**
- 플랜모드로 진입해 `../quizlab`(패키지명 `myquiz`) 구조를 조사하고 계획 승인 후 문서만 작성
- 게임 규칙을 질의로 확정: **블록 합체 없음**, 맵 요소 = 벽/일반 블록/목표 지점/구멍, **실패 조건 없음 + 무제한 undo**
- 기획서·아키텍처 규약·기능별 task 문서 11종 작성
- `lib/` 코드는 의도적으로 전혀 건드리지 않음

**변경 파일**
- `docs/game-design.md` — 신규. 게임 규칙 단일 출처
- `docs/architecture.md` — 신규. 폴더 구조·DI/MVVM/repository 규약·네이밍
- `docs/tasks/README.md` + `00`~`10` — 신규. 기능별 할 일 문서 11종
- `CLAUDE.md` — 게임 한 줄 요약, 문서 인덱스, "기획 단계이므로 지시 없이 구현 시작 금지", 아키텍처 요약 추가

**결정 / 메모**
- **클리어는 "정지"했을 때만.** 목표 칸은 통과 가능. 지나가기만 해도 클리어면 같은 행/열에서 밀기만 하면 되어 퍼즐이 성립하지 않음
- **구멍은 정지 지점이 아니라 통과 경로에서 판정.** 멈춰야만 빠지는 규칙이면 구멍이 무해한 장식이 됨
- **이동 처리 순서 = 진행 방향의 앞쪽 블록부터.** 순서를 뒤집으면 블록이 서로를 통과함. 아직 처리 안 된 블록은 장애물로 치지 않음
- **레벨 디자인 원칙:** 목표 칸 네 방향 중 최소 하나에 정지 요소(벽/맵 경계)가 있어야 도달 가능. 파서가 로드 시 검증
- quizlab 대비 의도적 차이를 `architecture.md` §3 표로 명시 — datasource 계층 없음, API 모델·매퍼 없음, Failure 매퍼 체인 축소. quizlab 코드를 참고하다 없는 계층을 따라 만드는 것을 막기 위함
- **task 순서에서 02(이동 엔진)를 04(화면)보다 앞에 둠.** 규칙 버그를 UI로 눈 디버깅하지 않기 위해, Flutter 비의존 순수 Dart로 먼저 테스트에 고정
- 레벨 데이터는 JSON 에셋이 아니라 ASCII 문자열 상수로 확정 — 컴파일 타임 검사, diff 가독성, 육안 검증 가능
- 별점 경계값, 블록 렌더링 방식(CustomPainter vs 위젯 하이브리드) 등은 각 task 문서의 "열린 질문"에 보류로 기록

---

## 2026-08-05 #6 — 커밋

**요청**
> 커밋 해줘

**한 일**
- #5에서 작성한 기획/아키텍처/task 문서 13개와 `CLAUDE.md` 수정분을 커밋

**변경 파일**
- 없음 (커밋 작업만)

**결정 / 메모**
- #4와 동일하게, 이 기록 항목을 추가한 뒤 같은 커밋에 amend 하여 합침

---

## 2026-08-05 #7 — README 작성

**요청**
> 프로젝트의 간단한 설명과 실행 방법등을 최상위 README.md에 작성해줘 의도, 구조 및 기술, 설치 및 실행방법.

**한 일**
- Flutter 기본 스캐폴드 README를 프로젝트 README로 교체
- 구성: 게임 소개(6×6 예시 보드 포함) → 설계 의도 → 기술 스택 · 아키텍처 → 설치/실행/검증/빌드 → 문서 인덱스 → 개발 순서
- `fvm --version`(4.0.5)과 `fvm flutter --version`(3.44.8)으로 실행 명령 검증

**변경 파일**
- `README.md` — 전면 교체

**결정 / 메모**
- 상단에 **"현재 기획 단계"** 경고를 명시. 지금 클론해서 실행하면 카운터 예제가 뜨므로, 이를 적지 않으면 README가 사실과 다른 인상을 준다
- 예정 패키지(riverpod / go_router / shared_preferences)는 아직 `pubspec.yaml`에 없으므로 스택 표에 "(예정)"으로 표기
- 설계 의도를 "무엇을"이 아니라 **"왜 그렇게 정했는지"** 중심으로 작성 — 정지 판정, 실패 없음, 구멍 규칙 세 가지
- 상세 규칙은 중복 서술하지 않고 `docs/` 문서로 링크. README와 기획서가 따로 노는 것을 막기 위함

---

## 2026-08-05 #8 — 커밋

**요청**
> 커밋 해줘

**한 일**
- #7의 `README.md` 교체분을 커밋

**변경 파일**
- 없음 (커밋 작업만)

**결정 / 메모**
- #4 · #6과 동일하게 기록 항목 추가 후 amend

---

## 2026-08-05 #9 — 00-foundation 구현

**요청**
> 00-foundation 진행해줘. 완료되면 tasks/completed/폴더 만들어서 거기로 이동시켜주고

**한 일**
- `flutter_riverpod: 3.0.3`(고정) · `go_router: ^14.6.1` · `shared_preferences: ^2.5.3` 추가
- `lib/core/` 골격 13개 파일 생성 (config · di · error · extension · router · theme · usecase)
- `lib/main.dart` 를 카운터 예제에서 `ProviderScope` + `MaterialApp.router` 로 교체
- 두 라우트에 자리표시자 화면 연결 (`/level-select`, `/game-play?level=N`)
- `test/widget_test.dart` 를 스모크 테스트 3종으로 교체
- `docs/tasks/completed/` 신설 후 `00-foundation.md` 를 `git mv`, 실제 결과·결정 사항 추가 기록
- 구현이 시작되었으므로 `README.md` · `CLAUDE.md` 의 "기획 단계" 서술 갱신

**변경 파일**
- `pubspec.yaml` / `pubspec.lock` — 패키지 3종
- `lib/` — 신규 15개 파일, `main.dart` 교체
- `test/widget_test.dart` — 교체
- `docs/tasks/completed/00-foundation.md` — 이동 + 완료 기록
- `docs/tasks/README.md` — 상태 ✅, 완료 시 `completed/` 이동 규칙 명시
- `docs/tasks/01-domain-model.md` · `09-progress.md` — 링크 경로 수정
- `README.md` — 상태 배너, 스택 표에서 "(예정)" 제거
- `CLAUDE.md` — "기획 단계" → 현재 상태, task 완료 절차 명시

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 3/3 통과
- `fvm flutter build web` 성공, `fvm flutter build macos --debug` 성공 + 앱 기동 확인

**결정 / 메모**
- **보드 색만 직접 지정하고 나머지 UI 색은 파생.** 플레이어 색을 seed 로 `ColorScheme.fromSeed` 에 넘겼다. 보드가 화면의 주인공이므로 UI 색이 보드를 따라오는 방향이 맞다 (task 문서의 열린 질문 해소)
- **`BoardColors` 를 `ThemeExtension` 으로.** `CustomPainter` 는 `BuildContext` 없이 그리므로 색을 하드코딩하기 쉽고, 그러면 다크모드에서 손댈 수 없게 된다. 위젯 테스트에 등록 검증을 넣어 회귀를 막았다
- `AppTextStyles.counter` 에 `tabularFigures` — 이동 횟수 9→10 에서 글자 폭이 변해 HUD 가 흔들리는 것 방지
- 라우터의 레벨 번호 파싱 실패 시 **1번 폴백**. 잘못된 URL 로 앱이 죽지 않게 한다
- 두 화면은 자리표시자 `StatelessWidget`. Root/Screen/Notifier 일습은 `04` · `08` 에서 만든다 — 지금 만들면 다음 task 의 범위를 미리 먹는다
- 스크린샷 캡처는 화면 기록 권한이 없어 실패. 대신 macOS 앱 기동(pid 확인) + 위젯 테스트로 화면 진입·라우팅을 검증했다
- **task 완료 절차를 `CLAUDE.md` 에 명문화** — 체크박스 · 결과 기록 · `completed/` 이동 · 링크 수정 · 인덱스 갱신. 앞으로 매 task 마다 반복될 절차다

---

## 2026-08-05 #10 — 세션 인수인계 안내를 CLAUDE.md 에 추가

**요청**
> CLAUDE.md에다가 만약 지금의 너가 아니라 다른 세션의 클로드랑 내가 대화할때 지금처럼 흐름을 유지할 수 있도록 안내하는 글이 있으면 좋겠다.

**한 일**
- `CLAUDE.md` 에 새 세션이 맥락을 이어받기 위한 4개 절 추가
  - **Starting a session** — 읽을 문서 4종의 순서와 각각에서 얻을 것. `prompt-history.md` 최근 3~4개 항목을 읽으라고 명시
  - **The working rhythm** — 한 요청에 한 task, 구조적 작업은 플랜모드, 설계 결정은 추측 대신 질문, 매 요청 기록, 검증 후 보고, 커밋은 요청 시에만
  - **Language** — 대화·문서·주석은 한국어, 커밋 메시지는 영어
  - **Logging every request** / **Finishing a task** — 기존 규칙을 절차로 구체화
- 아래쪽에 있던 "Always log the prompt" 절 제거 (새 "Logging every request" 절과 중복)

**변경 파일**
- `CLAUDE.md`

**결정 / 메모**
- **"the repo is the memory"** 를 전제로 서술했다. 새 세션은 이전 대화를 모르므로, 지시가 아니라 *어디를 읽으면 맥락이 복원되는지*를 알려주는 것이 핵심이다
- `prompt-history.md` 를 읽기 목록에 넣은 것이 이번 추가의 요점. 나머지 세 문서는 "현재 상태"만 알려주지만, 이 파일만이 **결정의 근거와 궤적**을 담고 있다. diff 로는 복원되지 않는 정보다
- 커밋 요청 시 기록 항목 추가 후 `--amend` 하는 관례도 명문화. 지금까지 #4 · #6 · #8 에서 반복해온 방식이다
- 완료 절차에 "`README.md` 나 CLAUDE.md 의 Current state 가 거짓이 되면 같은 작업에서 고칠 것" 항목 추가 — #9 에서 실제로 발생했던 일이다

---

## 2026-08-05 #11 — 커밋 (분리)

**요청**
> 따로따로 커밋

**한 일**
- #9(00-foundation 구현)와 #10(세션 인수인계 안내)을 각각 별도 커밋으로 분리

**변경 파일**
- 없음 (커밋 작업만)

**결정 / 메모**
- `CLAUDE.md` 와 `docs/prompt-history.md` 가 두 작업의 변경을 모두 담고 있어 단순 파일 단위 스테이징으로는 분리가 불가능했다. 최종본을 임시 보관 → #9 시점 상태로 되돌려 커밋 1 → 최종본 복원 후 커밋 2 순으로 처리
- `git add -p` 같은 대화형 스테이징은 이 환경에서 쓸 수 없어 파일 재구성 방식을 택했다
- 교훈: 성격이 다른 작업을 연달아 하면 공용 문서에서 커밋이 얽힌다. 커밋을 나눌 가능성이 있으면 작업 단위로 먼저 커밋해두는 편이 낫다


## 2026-08-05 #12 — 웹으로 실행 확인

**요청**
> 한번 실행해볼까? 잘 켜지는지. 웹으로 실행 해줘

**한 일**
- `fvm flutter devices` 로 Chrome(web-javascript) 사용 가능 확인
- `fvm flutter run -d chrome` 백그라운드 기동 → 디버그 서비스 연결 성공, dev server 포트 `56139`

**변경 파일**
- 없음 (실행 확인만)

**결정 / 메모**
- 실행 로그상 `Launching lib/main.dart on Chrome in debug mode...` → 디버그 서비스 연결까지 정상. 컴파일 에러 없이 기동됐다
- 화면 렌더링의 시각적 확인은 하지 않았다. 진입 화면(`/level-select`)과 라우팅은 `test/widget_test.dart` 3건으로 이미 검증돼 있어 중복이라 판단
- 이 프로세스는 세션 동안 살아있다. 필요 없으면 종료해도 무방하다

---

## 2026-08-05 #13 — 프로젝트 맥락 파악 (신규 세션)

**요청**
> CLAUDE.md 읽고 이 프로젝트의 의도와 구조 그리고 다음 할일 파악해줘

**한 일**
- `CLAUDE.md` · `README.md` · `docs/tasks/README.md` · `completed/00-foundation.md` · `docs/prompt-history.md` 최근 항목 · `docs/tasks/01-domain-model.md` 통독
- `git log` / `git status` 확인 — 커밋 7개, 워킹트리 클린
- 현재 상태와 다음 task(`01-domain-model`)를 사용자에게 정리해 보고

**변경 파일**
- `docs/prompt-history.md` (#12 누락분 + 이 항목)

**결정 / 메모**
- #12(웹 실행 확인)가 기록되지 않은 채 세션이 끊겨 이번에 함께 채웠다. 기록은 작업 종료 시점이 아니라 **보고 직전**에 쓴다는 규칙을 지키지 못하면 이렇게 유실된다
- 코드는 작성하지 않았다. "다음 할 일 파악"까지가 요청 범위이고, `01` 착수는 별도 요청 사항

---

## 2026-08-05 #14 — 01-domain-model 구현

**요청**
> 01 진행해줘

**한 일**
- `lib/feature/game/domain/entity/` 에 순수 Dart 엔티티 7종 작성
  - `direction.dart` — `Direction` (rowDelta / colDelta)
  - `position.dart` — `Position(row, col)` + `translate`
  - `cell.dart` — `FloorType { empty, wall, goal, hole }`
  - `block.dart` — `BlockType` + `Block(id, type, position)` + `moveTo`
  - `board_state.dart` — `BoardState` + `contains` · `floorAt` · `blockAt` · `player` · `hasPlayer` · `isCleared` · `withBlocks`
  - `level.dart` — `Level(number, name?, initialBoard, minMoves)`
  - `move_result.dart` — `MoveResult(board, moved, from, to, fellIntoHole)`
- `test/feature/game/domain/entity/entity_test.dart` 10건 작성
- task 문서에 "실제 결과" 추가 후 `completed/` 로 이동, 링크·현황표·`README.md`·`CLAUDE.md` 상태 갱신

**변경 파일**
- `lib/feature/game/domain/entity/*.dart` (신규 7)
- `test/feature/game/domain/entity/entity_test.dart` (신규)
- `docs/tasks/completed/01-domain-model.md` (이동 + 결과 기록)
- `docs/tasks/README.md` · `02-move-engine.md` · `03-level-data.md` — 링크·상태
- `README.md` · `CLAUDE.md` — 현재 상태

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 13/13 통과 (기존 3 + 신규 10)
- `grep -rn "package:flutter" lib/feature/game/domain/` → 0건

**결정 / 메모**
- **`Position`만 positional 파라미터.** 아키텍처 §7은 named 생성자를 요구하지만, 기획서 트레이스가 전부 `(행, 열)` 표기이고 테스트에 좌표가 수십 번 나온다. `Position(row: 4, col: 1)` 은 같은 정보를 두 배 길이로 쓰게 만든다. 순서 혼동은 doc 주석으로 막았다. 나머지는 규약대로 named
- **`copyWith` 를 만들지 않았다.** 실제 필요한 변형은 "블록이 옮겨간다" · "판의 블록만 교체된다" 둘뿐이라 도메인 언어 그대로 `Block.moveTo` · `BoardState.withBlocks` 로 뒀다. 쓰이지 않을 범용 `copyWith` 를 미리 만들지 않는다 (task 문서의 nullable `copyWith` 체크 항목은 "해당 없음" 처리)
- **`Block? get player` 로 nullable 화.** task 초안은 non-null 게터 + `hasPlayer` 였으나, 플레이어는 구멍에 빠져 실제로 사라진다(기획서 §3.5). 예외를 던지는 게터는 호출부를 불편하게 만든다
- **`floorAt` 은 맵 밖에 `FloorType.wall` 을 돌려준다.** 기획서 §2.2 "맵 경계는 벽과 동일" 을 엔티티 수준에서 구현한 것. 이동 엔진이 "맵 밖" 과 "벽" 분기를 따로 쓸 필요가 없어진다
- **`BoardState` 동등성은 블록 순서에 둔감하게.** 이동 엔진은 블록을 처리 순서대로 정렬해 내놓으므로 같은 판이 다른 순서로 표현된다. 순서에 민감하면 `02` 의 테스트가 규칙과 무관한 이유로 깨진다. `Object.hashAllUnordered` + 집합 비교
- **`MoveResult.to` 는 구멍에 빠진 블록의 "사라진 칸" 을 담는다.** 낙하 연출(`06`)이 어디서 사라졌는지 알아야 한다
- 방향별 블록 처리 순서(기획서 §3.2 정렬 규칙)는 `Direction` 에 넣지 않고 `02` 로 미뤘다. 이동 엔진의 관심사다
- `Level` 을 `game/domain/entity/` 에 뒀다. 규칙 엔진이 `Level` 을 필요로 하므로 game 이 소유자로 맞다고 봤으나, `level` feature 도 참조하게 되므로 `03` 에서 재검토 여지 있음

---

## 2026-08-05 #15 — 커밋

**요청**
> 커밋 해줘

**한 일**
- #14(01-domain-model 구현)를 단일 커밋으로 커밋

**변경 파일**
- 없음 (커밋 작업만)

**결정 / 메모**
- #11 의 교훈대로 이번엔 작업 단위가 하나(`01`)뿐이라 분리 없이 한 커밋으로 처리했다

---

## 2026-08-05 #16 — 02-move-engine 구현

**요청**
> 02 진행해줘

**한 일**
- `lib/feature/game/domain/usecase/game_usecases/apply_move_usecase.dart` — 기획서 §3.2 이동 알고리즘의 순수 함수 구현
- `test/feature/game/board_ascii.dart` — ASCII ↔ `BoardState` 변환 테스트 헬퍼
- `test/feature/game/apply_move_usecase_test.dart` — 31건. task 문서가 요구한 8개 분류(기본·벽·블록·목표·구멍·무효·회귀·경계) 전부 + `MoveResult.from`/`to`/`fellIntoHole` 검증
- task 문서에 "실제 결과" 추가 후 `completed/` 로 이동, 링크·현황표·`README.md`·`CLAUDE.md` 상태 갱신

**변경 파일**
- `lib/feature/game/domain/usecase/game_usecases/apply_move_usecase.dart` (신규)
- `test/feature/game/board_ascii.dart` · `apply_move_usecase_test.dart` (신규)
- `docs/tasks/completed/02-move-engine.md` (이동 + 결과 기록)
- `docs/tasks/README.md` · `03-level-data.md` · `04-game-screen.md` — 링크·상태
- `README.md` · `CLAUDE.md` — 현재 상태

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 44/44 통과 (기존 13 + 신규 31)
- `grep -rn "package:flutter\|print(" lib/feature/game/domain/` → 0건

**결정 / 메모**
- **방향별 정렬을 `switch` 4갈래로 쓰지 않고 스칼라 하나로 통일했다.** `row * rowDelta + col * colDelta` 를 내림차순 정렬하면 `→` 열 내림 · `←` 열 오름 · `↓` 행 내림 · `↑` 행 오름이 전부 나온다. 네 갈래로 쓰면 부호를 뒤집는 실수가 나기 쉽고, 이 스칼라는 "이동 방향으로 얼마나 앞쪽인가"라는 의미가 그대로 드러난다
- **맵 경계 분기를 쓰지 않았다.** `01` 에서 `floorAt` 이 맵 밖에 `wall` 을 돌려주게 해둔 결정이 여기서 값을 했다 — 정지 조건이 `벽 || 정착한 블록` 두 갈래로 끝난다
- **무효 입력이면 입력 보드 인스턴스를 그대로 돌려준다** (`same(board)` 로 테스트). `07` 의 되돌리기 스택에서 같은 판이 쌓이는 실수를 줄인다
- **`from`/`to` 에 움직이지 않은 블록도 담는다.** 애니메이션이 전체 블록을 한 번에 순회할 수 있다
- **열린 질문 1 해소 — "블록이 만나는 지점"을 함수로 분리하지 않기로 확정.** 구현해보니 그 지점은 `occupied.contains(next)` 조건 하나이고, 빼내도 항상 "멈춤"만 돌려주므로 합체 규칙의 확장점이 되지 못한다. 간접 참조만 는다. 합체를 넣게 되면 그때 이 한 줄을 고친다
- **열린 질문 2 는 `06` 으로 이월.** `MoveResult.from` 의 `Map` vs `List<BlockMove>` 는 애니메이션을 실제로 짜보기 전엔 판단 근거가 없다
- **ASCII 헬퍼를 `test/` 에만 뒀다.** 정식 파서는 `03` 이 만든다. 이동 엔진 테스트를 아직 없는 파서에 묶지 않기 위해서다
- **ASCII 로는 클리어를 검증하지 않는다.** 목표 칸 위의 블록은 내용물이 바닥을 가려 `@`/`O` 로 찍히므로, 클리어는 `board.isCleared` 로 따로 단언했다
- **BFS 솔버(작업 §3, 선택)는 만들지 않고 `03` 으로 넘겼다.** 소비처가 `minMoves` 검증인데 검증할 레벨 데이터가 아직 없다. `03-level-data.md` 의 해당 문장도 "이 작업에서 만들어 검증한다"로 고쳐뒀다

---

## 2026-08-05 #17 — 커밋

**요청**
> 커밋 해줘

**한 일**
- #16(02-move-engine 구현)을 단일 커밋으로 커밋

**변경 파일**
- 없음 (커밋 작업만)

**결정 / 메모**
- 작업 단위가 하나(`02`)뿐이라 #15 와 같이 분리 없이 한 커밋으로 처리했다

---

## 2026-08-05 #18 — 03-level-data 구현

**요청**
> 03 진행해줘

**한 일**
- `lib/feature/level/` 전체 구축 — `LevelBlueprint` 상수 6개, ASCII 파서 + 유효성 검증, `LevelRepository`/`Impl`, `GetAllLevelsUsecase`·`GetLevelUsecase` + 컨테이너, `level_di.dart`
- `test/feature/level/level_solver.dart` — BFS 완전 탐색 솔버(테스트 전용). `02` 에서 미뤄둔 항목
- 테스트 30건 — 파서 유효성 11, 레벨 세트 14(레벨당 2건 자동 생성), repository 5
- `docs/architecture.md` §6 에 생성자 규약 갱신
- task 문서에 "실제 결과" 추가 후 `completed/` 로 이동, 링크·현황표·`README.md`·`CLAUDE.md` 갱신

**변경 파일**
- `lib/feature/level/**` (신규 7)
- `test/feature/level/**` (신규 4)
- `docs/architecture.md` — §6 생성자 규약
- `docs/tasks/completed/03-level-data.md` (이동 + 결과 기록)
- `docs/tasks/README.md` · `04-game-screen.md` · `08-level-select.md` · `completed/02-move-engine.md` — 링크·상태
- `README.md` · `CLAUDE.md` — 현재 상태

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 74/74 통과 (기존 44 + 신규 30)
- 6개 레벨 전부 BFS 완전 탐색으로 `minMoves` 일치 확인

**결정 / 메모**
- **`minMoves` 를 손으로 세지 않고 BFS 로 검증하게 만든 것이 이 작업의 핵심이다.** 손으로 센 값이 틀리면 별점 기준이 조용히 어긋나고, 최악의 경우 클리어 불가능한 레벨이 배포된다. `kLevelBlueprints` 를 순회하는 테스트가 레벨을 추가할 때마다 자동으로 따라붙는다
- **솔버는 플레이어가 구멍에 빠진 판을 막다른 길로 친다.** 되돌리기 외에 길이 없으므로 탐색을 이어갈 이유가 없다. 상태 키는 블록 배치만으로 만든다 — 바닥은 레벨 내내 고정이다
- **"목표에 정지 요소가 있는가" 검사는 벽과 맵 경계만 센다.** 일반 블록은 함께 미끄러지므로 정적인 브레이크가 아니다. 이건 값싼 그물이고 진짜 풀이 가능 여부는 BFS 가 본다
- **레벨 4·5는 "먼저 떠오르는 수가 실패하는" 구조로 설계했다.** 4는 목표를 향해 곧장 밀면 지나쳐버리고, 5는 곧장 밀면 구멍에 빠진다. 튜토리얼이 설명 없이 개념을 가르치려면 실패가 즉시 눈에 보여야 한다
- **열린 질문 2 해소 — 레벨 이름을 붙였다.** 각 레벨이 무슨 개념을 가르치는지가 이름에 드러나야 레벨 목록(`08`)이 읽힌다. `Level.name` 은 nullable 로 남겨 이름 없는 레벨도 허용
- **열린 질문 3 해소 — 초기 세트는 전부 6×6.** 엔진·파서는 이미 `N×M` 을 지원하고 파서 테스트가 2행 판·비정사각 판을 다룬다. 큰 판은 개념이 다 나온 뒤(7번 이후)에 도입
- **파싱은 첫 접근에 한 번만 하고 캐시한다.** 잘못된 레벨이 앱 시작이 아니라 첫 접근에서 터지지만, 테스트가 전 레벨을 파싱하므로 배포 전에 잡힌다
- **생성자를 Dart 3 의 private named parameter(`{required this._repository}`)로 썼다.** quizlab 의 `{required X x}) : _x = x` 형태는 `prefer_initializing_formals` 린트에 걸린다. 호출부 이름은 `repository:` 그대로다. quizlab 과 갈리는 지점이라 `docs/architecture.md` §6 에 명문화했다

---

## 2026-08-05 #19 — 커밋

**요청**
> 커밋 해줘

**한 일**
- #18(03-level-data 구현)을 단일 커밋으로 커밋

**변경 파일**
- 없음 (커밋 작업만)

**결정 / 메모**
- 작업 단위가 하나(`03`)뿐이라 분리 없이 한 커밋으로 처리했다

---

## 2026-08-05 #20 — 04-game-screen 구현 (플랜모드)

**요청**
> 04 진행해줘

**한 일**
- 플랜모드로 진입, `AskUserQuestion` 으로 task 문서의 열린 질문 2개를 사용자에게 확인 후 계획 승인받아 구현
- `lib/feature/game/` — `game_di.dart`, `GameUsecases`, 플레이 화면 일습(Root/Screen/Notifier/State/Event), 위젯 5종(`board_view`·`board_painter`·`block_tile`·`game_hud`·`result_overlay`)
- 테스트 23건 — 화면 8, Notifier 10, 레이아웃 5
- `test/widget_test.dart` 의 자리표시자 검사 테스트 수정
- `docs/tasks/06-animation.md` 의 "선결 사항"·"렌더링 방식 확정" 절을 확정된 내용으로 교체
- task 문서 마감 후 `completed/` 이동, 링크·현황표·`README.md`·`CLAUDE.md` 갱신

**변경 파일**
- `lib/feature/game/**` (신규 7, 자리표시자 1 교체)
- `test/feature/game/presentation/**` (신규 3), `test/widget_test.dart`
- `docs/tasks/completed/04-game-screen.md` (이동 + 결과 기록), `docs/tasks/06-animation.md`
- `docs/tasks/README.md` · `05` · `07` · `10` — 링크·상태
- `README.md` · `CLAUDE.md` — 현재 상태

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 97/97 통과 (기존 74 + 신규 23)
- `fvm flutter run -d web-server --web-port 8123` → 빌드·서빙 성공(HTTP 200)
- **육안 확인 실패** — 브라우저 확장이 연결되지 않아 화면을 캡처하지 못했다

**결정 / 메모**
- **열린 질문 1 — 블록 렌더링은 하이브리드로 확정** (사용자 결정). 바닥·격자선·벽은 `BoardPainter`, 움직이는 블록만 `Positioned` + `BlockTile`. `06` 이 `AnimatedPositioned` 로 바꾸는 것만으로 슬라이드를 얻고 구멍 낙하도 블록별로 붙일 수 있다. 대가인 "페인터와 위젯의 좌표계 이중 관리" 는 **셀 크기 계산을 `BoardView` 한 곳에만 두어** 막았다
- **열린 질문 2 — 결과는 화면 내 오버레이 레이어로 확정** (사용자 결정). `showDialog` 는 명령형이라 중복 호출 방지가 필요하고 위젯 테스트가 번거롭다. 상태에서 파생되는 레이어는 Screen 이 dumb 하게 남고 보드가 뒤에 계속 보인다
- **Riverpod 3 에는 `FamilyNotifier` 가 없다.** 3.0 에서 제거됐고 family 의 생성 함수가 `Notifier Function(Arg)` 이라, 레벨 번호를 **Notifier 생성자로** 받는다. `ref.$arg` 는 `@internal` 코드젠 전용이라 쓰지 않았다. 아키텍처 §4 의 provider 표기는 그대로 유효
- **`ResetRequested` 를 04 범위에 넣었다.** 원래 `07` 이지만, 플레이어가 구멍에 빠지면 방향 입력이 막히는데 undo 도 리셋도 없으면 화면이 잠긴다. `UndoRequested` 는 히스토리 스택이 필요하므로 `07` 에 남겼다
- **`LoadLevel` 이벤트는 만들지 않았다.** Notifier 의 `build()` 가 로드하므로 중복이다
- **`Positioned` 에 `ValueKey(block.id)`.** 지금은 불필요하지만 `06` 에서 같은 블록으로 추적되려면 필수다. `01` 에서 `Block.id` 를 만든 이유가 여기서 쓰인다
- **Screen 의 Riverpod 무지를 테스트가 강제한다.** 화면 테스트는 `ProviderScope` 로 감싸지 않으므로 Screen 이 Riverpod 을 건드리는 순간 터진다. 규약을 문서가 아니라 테스트가 지키게 했다
- **"창 크기를 바꿔도 정사각" 을 육안 대신 테스트로 옮겼다.** 4개 화면 크기에서 보드가 정사각인지, `maxBoardExtent` 를 넘지 않는지, 비정사각 판(2×6)에서 셀이 정사각인지 검사한다. 오버플로는 Flutter 가 예외를 던지므로 통과 자체가 "잘리지 않음" 의 검증이다
- **육안 확인을 못 한 것은 이번 작업의 구멍이다.** 배치·상태 전이는 테스트로 덮었지만 색 대비·여백 같은 시각적 완성도는 사람이 봐야 한다. `docs/tasks/completed/04-game-screen.md` 의 "남은 사항" 에 남겼다

---

## 2026-08-05 #21 — 커밋

**요청**
> 커밋 해줘

**한 일**
- #20(04-game-screen 구현)을 단일 커밋으로 커밋

**변경 파일**
- 없음 (커밋 작업만)

**결정 / 메모**
- 작업 단위가 하나(`04`)뿐이라 분리 없이 한 커밋으로 처리했다

---

## 2026-08-05 #22 — 도메인·역할·의존 계층 검토 후 순환 의존 제거

**요청**
> 05 진행하기 전에 레벨 말인데, game기능 안에 엔티티로 있는데. level이라는 기능이있는데도 거기에 둔 이유가 뭐지? 도메인 분리와 역할 분리. 의존성 계층 분리 잘 되고 있는지 꼼꼼하게 검토해줘.
>
> (이어서) 아니 level 엔티티를 level도메인으로 옮겨야되는거 아님?
>
> (이어서) 그냥 level은 그냥 난이도나 이름 정보위주들의 형태를 하고. map이라는 엔티티를 게임에 넣어서 활용하게 하는건 어때?
>
> (이어서) 그렇게 진행해줘

**한 일**
- 의존 그래프를 실제로 추출해 검토 → **`game ⇄ level` 순환 의존 확인**
- 사용자 제안대로 개념을 쪼개 순환 제거
  - `Level` → `level/domain/entity/`, 필드는 `number` · `name` · `minMoves` (판 제거)
  - `GameMap(levelNumber, initialBoard)` 를 game 에 신설
  - `level_blueprints`/`level_parser` → `game/data/map_blueprints.dart` · `map_parser.dart`
  - `MapRepository` + `Impl` + `GetMapUsecase` 신설, `GameUsecases` 에 `getMap` 추가
  - `FailureCode` — `invalidLevelData` → `invalidMapData`, `mapNotFound` 추가
  - `GamePlayScreenState` 에 `map` 추가, 다시하기는 `map.initialBoard` 기준
- 두 상수 목록을 번호로 조인해 검사하는 `map_and_level_data_test.dart` 신설
- `architecture.md` §2 에 **feature 의존 방향(순환 금지)** 절 추가, §3 예시 코드 갱신
- `game-design.md` §9 를 "맵 / 메타데이터 2분할" 로 다시 씀
- `01` · `03` 완료 문서에 정정 절 추가, `CLAUDE.md` 에 규약 명문화

**변경 파일**
- `lib/core/error/failure_code.dart`
- `lib/feature/game/**` — `game_map.dart` · `map_blueprints.dart` · `map_parser.dart` · `map_repository.dart` · `map_repository_impl.dart` · `get_map_usecase.dart` (신규), `game_usecases.dart` · `game_di.dart` · state · notifier (수정)
- `lib/feature/level/**` — `domain/entity/level.dart` · `data/level_data.dart` (신규), repository impl · usecases (수정), `level_blueprints.dart` · `level_parser.dart` (삭제/이동)
- `test/feature/game/**` — `map_parser_test.dart`(이동) · `map_and_level_data_test.dart` · `map_repository_impl_test.dart` (신규), `min_moves_solver.dart`(이동)
- `docs/architecture.md` · `docs/game-design.md` · `docs/tasks/07-undo-reset.md` · `completed/01` · `completed/03` · `CLAUDE.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 101/101 통과 (기존 97 + 신규 4)
- 의존 그래프 재추출 → **`game → level` 3건뿐, `level → game` 0건**

**결정 / 메모**
- **순환의 원인은 `Level` 이 메타데이터와 판을 한 덩어리로 묶고 있었다는 것.** 사용자가 짚었다. `Level` 이 `initialBoard` 를 품으니 레벨 목록만 그리면 되는 `level` 이 판 모델 전체를 알아야 했고, `game` 은 레벨 조회 때문에 `level` 을 알아야 했다
- **`Level` 만 옮기는 것으로는 안 풀린다.** 판을 계속 품고 있으면 방향만 바뀌고 고리는 남는다. **개념을 쪼개야** 풀린다 — 이게 사용자 제안의 핵심이었다
- 내가 먼저 제안했던 `lib/domain/` 공유 커널은 **불필요해졌다.** 판 모델을 쓰는 feature 가 `game` 하나뿐이 되므로 최상위 폴더를 늘릴 이유가 없다. 사용자 안이 더 낫다
- **`minMoves` 는 `Level` 에 둔다.** 맵에서 파생된 값이지만 레벨 선택 화면이 별점을 그리려면 필요한데, 맵에 두면 `level → game` 이 되살아난다
- **`Map` 이라는 이름은 쓰지 않았다.** `dart:core` 의 `Map` 과 충돌해 게임 코드 전역에서 걸린다. `GameMap` 으로 갔다
- **쪼개면서 없던 실패 모드가 생겼다** — 두 상수 목록이 번호로 어긋날 수 있다. `map_and_level_data_test.dart` 가 집합 비교 + 중복 검사 + `minMoves` BFS 대조로 막는다. 레벨을 추가할 때 한쪽만 넣으면 즉시 빨간불
- **`core/router` → feature Root import 는 그대로 둔다.** 전역 단일 라우터 구조상 불가피하고 라우트 2개에 registry 패턴은 과하다. 수용하기로 하고 문서에만 남긴다
- **작업 중 `dart format` 을 `fvm` 없이 돌려 무관한 파일이 대량 리포맷됐다.** `fvm dart format` 으로 되돌리고 남은 3개 파일은 `git checkout` 으로 복원했다. **이 저장소에서 dart 명령은 항상 `fvm` 을 붙인다**
- **ASCII 맵은 `// dart format off` 로 감쌌다.** 포매터가 한 줄로 접으면 맵을 눈으로 검증할 수 없다 — 이 표기를 쓰는 이유 자체가 사라진다

---

## 2026-08-05 #23 — 커밋

**요청**
> 커밋 해줘

**한 일**
- #22(순환 의존 제거 리팩터링)를 단일 커밋으로 커밋

**변경 파일**
- 없음 (커밋 작업만)

**결정 / 메모**
- 검토와 리팩터링이 한 흐름이라 분리하지 않았다. 기능 변경이 없고 101개 테스트가 그대로 통과하는 순수 구조 변경이므로 한 커밋으로 되돌리기 쉬운 편이 낫다

---

## 2026-08-05 #24 — 05-input 구현

**요청**
> 05 진행해줘

**한 일**
- `swipe_direction.dart` — `directionFromSwipe(Offset) → Direction?` 순수 함수 분리
- `game_play_screen.dart` — `Focus`(autofocus, `onKeyEvent`) + `GestureDetector`(pan 누적) + `_requestMove` 입력 게이트
- 키 매핑: `↑↓←→` · `WASD` → 이동, `R` → 다시하기
- 테스트 24건 — 스와이프 판정 12, 화면 입력 12
- task 문서 마감 후 `completed/` 이동, `07` 에 `Z` 인수인계 명시, 링크·현황표·`README.md`·`CLAUDE.md` 갱신

**변경 파일**
- `lib/feature/game/presentation/game_play/swipe_direction.dart` (신규)
- `lib/feature/game/presentation/game_play/game_play_screen.dart`
- `test/feature/game/presentation/{swipe_direction,game_play_input}_test.dart` (신규)
- `docs/tasks/completed/05-input.md` (이동 + 결과 기록), `docs/tasks/07-undo-reset.md`, `docs/tasks/README.md`
- `README.md` · `CLAUDE.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 123/123 통과 (기존 101 + 신규 22)

**결정 / 메모**
- **`KeyboardListener` 로 짰다가 `Focus` + `KeyEventResult.handled` 로 바꿨다.** `KeyboardListener` 는 키 이벤트를 소비하지 않고 위로 흘려보내는데, 그러면 방향키가 Flutter 기본 포커스 이동(`DirectionalFocusIntent`)까지 타서 **한 번 누르면 포커스가 AppBar 버튼으로 떠나고 그 뒤로 방향키가 죽는다.** 실기기에서 겪었으면 원인 찾기 어려웠을 버그다
- **테스트가 이걸 잡았다.** `↑ ↓ ← →` 를 연달아 누르는 테스트에서 `↓` 만 유실됐다. 한 방향만 눌러보는 테스트였으면 통과했을 것이다 — **연속 입력을 검사한 것이 결정적이었다**
- **매핑된 키는 `KeyDownEvent` 가 아니어도 삼킨다.** 반복·뗌 이벤트를 흘려보내면 그것들이 포커스 이동을 일으켜 같은 문제가 재발한다. 동작은 여전히 누름 1회당 1수
- **화면 버튼 조작 후 포커스를 되돌린다.** 버튼이 포커스를 가져가면 방향키가 죽는다. `canRequestFocus: false` 로 막으면 Tab 접근성이 사라지므로, 버튼은 두고 조작 뒤 `requestFocus()` 하는 쪽을 골랐다. 결과 오버레이가 닫힐 때도 `didUpdateWidget` 에서 되찾는다
- **임계값은 우세한 성분에만 적용한다.** 대각선 합성 거리가 임계값을 넘어도 두 성분이 모두 미달이면 무시한다 — 의도한 방향을 알 수 없는 입력을 넘겨짚지 않는다. 두 성분이 같으면 가로가 이기게 고정하고 테스트로 박았다
- **스와이프 누적은 `onPanUpdate` 에서.** `onPanEnd` 는 속도만 주고 총 이동량을 주지 않는다
- **입력 게이트는 `state.canMove` 재사용.** task 문서 예시는 세 플래그를 다시 나열하지만 `04` 의 게터가 같은 판정을 한다. 두 곳에 적으면 언젠가 갈린다
- **`Z`(되돌리기)는 연결하지 않았다.** undo 스택이 `07` 의 몫이라 붙일 대상이 없다. `07-undo-reset.md` 에 "이 작업에서 붙인다" 로 명시해뒀다
- **열린 질문 1 해소 — 마우스 드래그를 스와이프로 취급한다.** `GestureDetector` 기본 동작이고, 끄려면 오히려 코드가 필요하다. 웹에서 자연스럽고 방향 버튼과 중복돼도 해가 없다
- 실기기·실브라우저 확인은 못 했다. 임계값 24가 손에 맞는지는 사람이 만져봐야 한다

---

## 2026-08-05 #25 — 커밋

**요청**
> 커밋 해줘

**한 일**
- #24(05-input 구현)를 단일 커밋으로 커밋

**변경 파일**
- 없음 (커밋 작업만)

**결정 / 메모**
- 작업 단위가 하나(`05`)뿐이라 분리 없이 한 커밋으로 처리했다

---

## 2026-08-05 #26 — 경계 벽 도입, 맵 표기 전면 교체 (플랜모드)

**요청**
> 맵 구조 말인데, map_blueprints.dart 여기에서 벽도 표현 가능한거야? 내가 말한 벽이라는 것은 cell전체를 차지하는게 아닌, 셀과 셀 사이의 선 있잖아? 그걸 벽으로 취급하는거지. 거기로는 블럭이 지나가지 못하고 막히는거고. 그렇게 구성된건지 검토해봐
>
> (이어서) A로 한다면 8x8맵에서 칸벽, 경계벽, 플레이어, 골인, 다른블럭등 모두 어캐 표현하는지 보여줘
>
> (이어서) 칸벽 경계벽 모두 살려서 저렇게 가자 맵이 한 눈에 보이는게 우선이다.

**한 일**
- 검토 결과 **경계 벽은 지원되지 않음**을 확인 — `#` 는 `FloorType.wall`, 즉 칸을 통째로 먹는 벽이었다
- 8×8 예시로 표기 후보 A(격자 표기)를 제시 → 사용자가 칸 벽·경계 벽 **둘 다 유지**, 표기 A 채택 결정
- `docs/game-design.md` **먼저** 수정 (§2.2 벽 2종 · §3.2 정지 조건 · §4.3 디자인 원칙 · §9 표기 전면 교체)
- `WallEdge` 엔티티 신설, `BoardState.walls` + `hasWallBetween`, 엔진 정지 조건 1줄, `MapParser` 격자 파싱으로 전면 교체
- `BoardPainter` 에 경계 벽·외곽 프레임 렌더링, `Spacing.wallWidthRatio` 추가
- 레벨 6개를 새 표기로 이관 + **레벨 7 신설**(경계 벽 도입)
- 테스트 24건 추가/개편

**변경 파일**
- `docs/game-design.md` (규칙, 코드보다 먼저)
- `lib/feature/game/domain/entity/wall_edge.dart` (신규), `board_state.dart`, `apply_move_usecase.dart`
- `lib/feature/game/data/map_parser.dart` (전면 교체), `map_blueprints.dart` (표기 이관 + 레벨 7)
- `lib/feature/game/presentation/game_play/widget/board_painter.dart`, `lib/core/theme/data/spacing.dart`
- `lib/feature/level/data/level_data.dart` (레벨 7 메타데이터)
- `test/feature/game/**` — `board_ascii.dart`(walls 인자), `apply_move_usecase_test.dart`(경계 벽 그룹), `entity_test.dart`(WallEdge), `map_parser_test.dart`(전면 교체), 화면 테스트 리터럴
- `docs/tasks/completed/01·02·03` 정정 절, `CLAUDE.md`, `README.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 147/147 통과 (기존 123 + 신규 24)
- **기존 6개 레벨의 `minMoves` 가 전부 그대로 통과** — 표기 변환이 정확했다는 증거

**결정 / 메모**
- **내 잘못이었다.** 기획 단계(#5)에서 `AskUserQuestion` 선택지가 "벽 (고정, 통과 불가)" 였는데 이 문구는 칸 벽과 경계 벽을 구분하지 못한다. 되묻지 않고 칸 벽으로 확정해 기획서에 못박고 엔진·파서·렌더러·레벨 6개까지 그 전제로 쌓았다. **모호한 선택지를 내가 만들어놓고 그 모호함을 내가 임의로 해소한 것**이 문제다
- **표기 A(격자)를 고른 근거는 사용자가 명시했다 — "맵이 한 눈에 보이는 게 우선".** 6×6 이 6줄에서 13줄로 늘지만, 경계 벽은 칸 사이에 있어서 칸만 나열하는 표기로는 **적을 방법 자체가 없다**
- **표기가 길어진 대가로 검증이 강해졌다.** 격자 구조 자체가 검사 대상이라(홀수 크기 · 교차점 `+` · 자리별 허용 기호 · 외곽 닫힘) 열이 하나 밀리는 오타를 실행 전에 잡는다
- **`WallEdge` 는 `right`/`down` 으로 정규화한다.** 같은 벽이 양쪽에서 다르게 보이는데, 정규화하지 않으면 `Set` 안에 둘로 들어가 **한 방향에서만 막히는** 조용한 버그가 된다. 정규화·양방향 조회를 테스트로 박았다
- **경계 벽은 `next` 가 아니라 "나가는 길"을 본다.** 칸 벽은 다음 칸의 속성이지만 경계 벽은 두 칸 사이에 있다
- **`minMoves` 는 `Level`(메타데이터) 에 그대로 뒀다.** 맵 표기가 바뀌어도 이 배치는 유효하다 — 레벨 선택 화면이 별점을 그리려면 필요하고, 맵에 두면 `level → game` 순환이 되살아난다 (#22)
- **엔진 테스트 31건은 표기를 바꾸지 않았다.** `board_ascii.dart` 의 압축 표기를 유지하고 `walls` 인자만 더했다. 엔진이 검증하는 것은 미끄러짐·정렬 순서·구멍이지 레벨 저작이 아니고, 격자 표기로 옮기면 읽기만 어려워진다. 대신 격자 표기는 `map_parser_test.dart` 가 전담해 검증한다
- **기존 6개 레벨은 판을 바꾸지 않고 표기만 옮겼다.** 그래서 `minMoves` 가 전부 그대로여야 하고, BFS 솔버가 이를 확인했다 — 손으로 옮기는 작업의 안전망이 이미 있었다
- **레벨 7 은 경계 벽 전용 튜토리얼.** 두 경계 벽으로 2수 클리어인데, **두 벽 어느 쪽도 칸을 먹지 않는다**는 것이 교육 포인트다
- **`Map` 이라는 이름은 여전히 안 쓴다.** `dart:core` 충돌 (#22 에서 결정)
- 육안 확인은 못 했다. 경계 벽이 격자선(1px)과 충분히 구분되는지, 외곽 프레임이 표기와 일치해 보이는지는 사람이 봐야 한다

---

## 2026-08-05 #27 — 커밋

**요청**
> 커밋 해줘

**한 일**
- #26(경계 벽 도입 · 맵 표기 교체)을 단일 커밋으로 커밋

**변경 파일**
- 없음 (커밋 작업만)

**결정 / 메모**
- 규칙 · 모델 · 엔진 · 파서 · 렌더러 · 레벨 데이터가 한 변경의 부분들이라 쪼갤 수 없다. 중간 상태에서는 테스트가 통과하지 않는다

---

## 2026-08-05 #28 — 보드 렌더링 정렬 버그 2건 수정

**요청**
> 실행해봐 웹으로
>
> (이어서) 지금 게임의 UI 문제가 뭐냐면 각 칸막벽은 원래 선보다 길이가 초과되어보이고, 플레이어는 셀의 중앙이 아닌 왼쪽 아래로 밀려나서 보여.(왼쪽위에있을땐 정상이지만, 우측하단이나, 좌측하단일땐 플레이어가 중심점에서 살짝 더 벗어남. 이거 수정해주면 좋겠다. (일반블럭도 마찬가지)

**한 일**
- 웹 실행 후 사용자가 렌더링 결함 2건 보고 → **픽셀 측정으로 원인 규명 후 수정**
- `BoardPainter` 가 좌표를 스스로 계산하지 않고 `cell` · `origin` 을 `BoardView` 에서 받도록 변경
- 외곽 프레임을 격자 **바깥 여백**으로 옮김, 경계 벽 캡을 `square` → `butt`
- `block_alignment_test.dart` 신설 — 위젯 좌표 측정 + 페인터 픽셀 측정 3건

**변경 파일**
- `lib/feature/game/presentation/game_play/widget/board_painter.dart` · `board_view.dart`
- `test/feature/game/presentation/block_alignment_test.dart` (신규), `board_view_layout_test.dart`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 150/150 통과 (기존 147 + 신규 3)

**결정 / 메모**
- **원인 1 — 외곽 프레임이 칸 안쪽을 파고들었다.** `#26` 에서 프레임을 `deflate(strokeWidth/2)` 로 그렸더니 셀 크기의 10% 만큼 **첫·마지막 칸 내부**를 덮었다. 그래서 가장자리 칸만 여백이 비대칭이 되고, 블록이 그 칸에서 바깥쪽으로 밀려 보였다. 사용자가 "가장자리로 갈수록 더 벗어난다" 고 한 것이 정확히 이 현상이다
- **원인 2 — 경계 벽에 `StrokeCap.square` 를 썼다.** 캡이 선 양끝을 두께의 절반씩 늘려 칸 하나보다 길게 그려졌다. `StrokeCap.butt` 로 바꾸니 정확히 칸 하나가 됐다 (픽셀 측정: 100px = cell)
- **추측하지 않고 쟀다.** 코드만 봐서는 좌표 계산이 맞아 보였다. 위젯 rect 를 재보니 정확했고, 그래서 페인터를 이미지로 그려 픽셀을 훑었더니 프레임이 `0~9`, `590~599` 를 차지하는 것이 나왔다. **눈으로 "조금 밀린 것 같다" 는 보고를 숫자로 바꾼 것이 해결의 전부였다**
- **프레임은 이제 격자 바깥 여백에 그린다.** `BoardView` 가 `cell = extent / (긴 변 + 2 × 벽 비율)` 로 여백을 미리 확보하고 `origin` 을 넘긴다. 칸은 온전해지고 프레임도 유지된다
- **페인터가 좌표를 스스로 계산하지 않게 했다.** 기존에는 `cell = size.width / colCount` 로 다시 구했는데, 이건 `origin` 도입 전에도 **비정사각 판에서 이미 틀렸다**(세로 셀 크기를 가로에서 유도). `04` 에서 세운 "셀 좌표계는 `BoardView` 한 곳에서만" 규약을 페인터까지 확장한 셈이다
- **회귀 테스트를 픽셀 단위로 남겼다.** 위젯 rect 만으로는 이번 버그가 안 잡힌다 — 블록 박스는 처음부터 정확했고 어긋난 것은 그 위에 칠해진 프레임이었다. 페인터를 이미지로 그려 검사하는 테스트가 있어야 같은 종류의 버그를 다시 잡는다
- 벽 길이 측정에서 외곽 프레임까지 같이 세는 실수를 했다(120px). 벽 중앙에서 이어지는 **연속 구간**만 세도록 고쳤다
