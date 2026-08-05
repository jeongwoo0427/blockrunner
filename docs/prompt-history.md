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
