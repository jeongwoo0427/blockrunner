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

---

## 2026-08-05 #29 — 블록 크기 축소, 맵 테두리를 격자 바깥으로

**요청**
> 블럭 크기를 살짝 줄여주고 커밋해줘. 블럭, 플레이어 모두.
>
> (이어서) 그리고 맵의 테두리는 바깥만 칠해주면 안될까? 안쪽까지 칠하니깐 내부가 살짝 좁아보여.

**한 일**
- `Spacing.blockInsetRatio` 신설(0.11) — 블록이 칸에서 물러나는 여백을 상수로 뺐다. 기존 하드코딩 `0.06` 대체
- `BlockTile` 의 플레이어 링 크기를 **칸이 아니라 블록 사각형** 기준으로 바꿈
- `BoardPainter` 가 바탕을 격자에만 칠하도록 변경 (기존: 여백 포함 전체)

**변경 파일**
- `lib/core/theme/data/spacing.dart`
- `lib/feature/game/presentation/game_play/widget/block_tile.dart` · `board_painter.dart`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 150/150 통과

**결정 / 메모**
- **블록 여백을 상수로 뺐다.** `0.06` 이 위젯 안에 박혀 있어서 "살짝 줄여줘" 같은 요청마다 위젯을 열어야 했다. `blockRadiusRatio` 옆에 두니 조정 지점이 한 곳으로 모인다
- **플레이어 링을 블록 기준으로 바꾼 것이 핵심이다.** 기존에는 링이 `size`(칸) 에 비례해서, 블록만 줄이면 링이 블록 안에서 상대적으로 커진다. 블록 사각형 한 변에 비례하게 바꿔 **앞으로 블록 크기를 조정해도 표식 비율이 유지된다**
- **테두리 문제의 원인은 프레임 위치가 아니라 바탕 범위였다.** `#28` 에서 프레임을 격자 바깥으로 옮겼지만 바탕은 여백까지 칠하고 있어서, 프레임이 "보드 안쪽에 그려진 띠" 처럼 보였다. 바탕을 격자에만 깔아 프레임이 판 바깥 윤곽으로 읽히게 했다
- 테스트는 그대로 통과한다. 프레임의 기하는 `#28` 에서 이미 맞았고 이번에 바뀐 것은 바탕 범위뿐이다

---

## 2026-08-05 #30 — 문서 현행화

**요청**
> 문서 현행화해주고. 커밋.

**한 일**
- 최근 변경(#22 · #26 · #28 · #29)이 반영되지 않은 문서를 찾아 갱신
- `docs/tasks/completed/04-game-screen.md` — 정정 절 신설
  - State 에 `map` · `hasNextLevel` 추가, 다시하기 기준이 `state.map.initialBoard` 로 바뀐 것
  - 셀 크기 공식이 외곽 프레임 여백을 포함하도록 바뀐 것, `AspectRatio(1)` 미사용
  - 그리는 순서에 칸 벽 · 경계 벽 · 외곽 프레임, `shouldRepaint` 에 `cell`/`origin`
  - `BoardPainter` 가 좌표를 스스로 계산하지 않는다는 규약
- `docs/tasks/06-animation.md` — 블록 좌표에 `margin` 이 붙는다는 주의 추가
- `docs/tasks/10-responsive.md` — §3 보드 크기를 실제 공식으로 교체, "이미 `04` 에 구현됨" 명시, 미구현 항목(최소 셀 크기 하한) 분리
- 링크·진행 현황표·레벨 수 전수 검사

**변경 파일**
- `docs/tasks/completed/04-game-screen.md`, `docs/tasks/06-animation.md`, `docs/tasks/10-responsive.md`

**검증**
- 상대 링크 전수 검사 → 깨진 링크 0건
- 진행 현황표 00~05 완료 상태가 실제 `completed/` 내용과 일치
- 낡은 심볼(`kLevelBlueprints` · `LevelParser` · `invalidLevelData` · `Level.initialBoard`) 잔존 여부 검사 → `prompt-history.md` 에만 존재
- `README.md` · `CLAUDE.md` 의 레벨 수(7)와 현재 상태가 실제와 일치

**결정 / 메모**
- **`prompt-history.md` 의 낡은 심볼은 고치지 않는다.** 그 시점에 무엇이었는지가 기록의 값이다. 현행 사실은 각 문서의 정정 절이 담당한다
- **`10-responsive.md` 에 "이미 `04` 에서 구현되어 있다" 를 명시했다.** 그러지 않으면 `10` 착수 시 `BoardView` 를 새로 짜게 되고, 프레임 여백을 빼먹어 이번에 잡은 버그를 그대로 재현할 위험이 있다. 미구현 항목(최소 셀 크기 하한)만 남겨 실제 할 일을 분명히 했다
- **`06-animation.md` 에 `margin` 주의를 넣었다.** `AnimatedPositioned` 로 바꾸면서 `margin + col * cell` 의 앞항을 빼먹으면 판 전체가 어긋난다 — 애니메이션 중에만 드러나 원인 찾기가 어려운 종류다
- `docs/tasks/README.md` 의 03 행 설명("파서")은 그대로 뒀다. task 제목은 당시 작업 단위를 가리키는 이름이지 현재 구조 설명이 아니다

---

## 2026-08-05 #31 — 화면 방향 버튼(D-pad) 제거

**요청**
> ui부분도 조금 더 수정하면 좋겠는데. 컨트롤 버튼은 없어도 될것 같아. 그냥 상태랑 다시하기 버튼? 이정도만 있어도 좋겠어

**한 일**
- 제거 전에 **세 플랫폼 모두 대체 입력이 있는지 먼저 확인** (모바일 스와이프 / 웹·데스크탑 방향키·WASD·마우스 드래그)
- `docs/game-design.md` §6 **먼저** 수정 — D-pad 를 두지 않는 결정과 근거, 남는 대가(발견성) 기록
- `GameHud` 를 이동 횟수 + 다시하기 한 줄로 축소, `_DirectionPad` 제거
- `game_play_screen.dart` 에서 `onDirection` 배선 제거
- 테스트 교체 — "방향 버튼이 MoveRequested" → "다시하기 버튼이 ResetRequested" + **"방향 버튼이 없다" 회귀 테스트** 신설
- 문서 정리: `05-input` 정정 절, `10-responsive` §1·§2·§5, `04` 남은 사항, `README.md` · `CLAUDE.md`
- (지난 현행화에서 놓친) `README.md` 아키텍처 트리를 `#22` 이후 구조로 갱신

**변경 파일**
- `docs/game-design.md` (규칙, 코드보다 먼저)
- `lib/feature/game/presentation/game_play/widget/game_hud.dart` · `game_play_screen.dart`
- `test/feature/game/presentation/game_play_screen_test.dart`
- `docs/tasks/completed/05-input.md` · `04-game-screen.md`, `docs/tasks/10-responsive.md`
- `README.md` · `CLAUDE.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 151/151 통과
- `grep -rn "onDirection\|_DirectionPad\|keyboard_arrow" lib/` → 0건

**결정 / 메모**
- **지우기 전에 대체 경로부터 확인했다.** `05-input` 문서가 D-pad 를 "마우스만 쓰는 사용자와 접근성 때문에 항상 제공한다" 고 못박아뒀기 때문이다. 실제로는 세 플랫폼 모두 다른 길이 있었다 — 특히 **마우스 드래그를 스와이프로 취급하기로 한 `#24` 의 결정**이 여기서 값을 했다. 그게 없었다면 마우스 전용 사용자가 조작할 방법이 사라졌을 것이다
- **남은 대가는 발견성이다.** 스와이프도 방향키도 보이지 않는 조작이라, 처음 들어온 사람에게 "어떻게 움직이지" 를 알려줄 눌러볼 것이 없다. **되살린다면 D-pad 보다 첫 레벨에 한 번 뜨는 힌트** 가 화면을 덜 해친다고 기획서에 적어뒀다 — 나중에 같은 문제를 만났을 때 반사적으로 버튼을 되돌리지 않도록
- **"방향 버튼이 없다" 를 테스트로 박았다.** 제거는 코드가 없어지는 변경이라 회귀를 잡을 것이 없다. `06` 이후 누가 편의로 되살리면 이 테스트가 먼저 걸리고, 그때 기획서 §6 을 보게 된다
- **HUD 를 세로 스택에서 한 줄 `Row` 로 바꿨다.** 남은 요소가 둘뿐이라 세로로 쌓을 이유가 없고, 보드에 돌아가는 세로 공간이 늘어난다
- `10-responsive` 의 "방향 버튼 배치" 절을 "HUD 배치" 로 바꿨다. 그러지 않으면 `10` 착수 시 없는 버튼의 배치를 고민하게 된다
- `04` 의 완료 기준 "임시 방향 버튼으로 이동하면 보드가 갱신된다" 는 그대로 뒀다. **당시에는 참이었던 기준이고, 남은 사항에 제거 사실을 적어 이어지게 했다**

---

## 2026-08-05 #32 — 조작 안내(튜토리얼) 추가

**요청**
> UI로 표시되는 방향키버튼은 걍 모든 플랫폼 없애. 튜토리얼로 처음에만 안내하면 되니깐.

**한 일**
- 방향 버튼은 직전 커밋(`6e8cc65`)에서 **이미 모든 플랫폼에서 제거**돼 있음을 확인하고 알림. 이번 작업의 실체는 안내 구현
- `docs/game-design.md` §6.1 **먼저** 신설 — 언제 뜨고 언제 사라지는지, 왜 닫기 버튼을 두지 않는지
- `ControlHint` 위젯 신설. 플랫폼별 문구(터치 → 스와이프 / 그 외 → 방향키 · WASD)
- `GamePlayScreenState.showsControlHint` 파생 게터 추가
- 테스트 3건 추가 + 기존 "방향 버튼 없음" 테스트에 안내 존재 확인 추가

**변경 파일**
- `docs/game-design.md` (규칙, 코드보다 먼저)
- `lib/feature/game/presentation/game_play/widget/control_hint.dart` (신규)
- `lib/feature/game/presentation/game_play/game_play_screen_state.dart` · `game_play_screen.dart`
- `test/feature/game/presentation/game_play_screen_test.dart`
- `docs/tasks/completed/05-input.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 154/154 통과 (기존 151 + 신규 3)

**결정 / 메모**
- **상태를 저장하지 않는다.** `레벨 1 && 이동 0회` 라는 조건에서 파생되는 값이라 새 필드도, `SharedPreferences` 키도 필요 없다. "한 번 봤는지" 를 영구 저장하려면 저장소 계층이 필요한데 그건 `09-progress` 의 몫이고, 지금 끌어오면 그 task 의 구조를 미리 먹는다
- **닫기 버튼을 두지 않고 첫 이동으로 사라지게 했다.** "조작할 줄 안다" 는 것은 실제로 조작했을 때만 확인된다. 눌러서 닫는 안내는 읽지 않고 닫히기 쉽다
- **다시하기로 조건이 되살아나면 다시 뜬다.** 버그가 아니라 의도다 — 판을 처음으로 되돌린 사람에게 다시 보여주는 편이 맞다. 기획서에 명시했다
- **플랫폼 분기는 `defaultTargetPlatform` 으로 한다.** `dart:io` 는 웹에서 못 쓴다(`10-responsive` 의 완료 기준이기도 하다). 웹 브라우저에서도 OS 를 돌려주므로 모바일 브라우저에는 스와이프 안내가 나간다
- **안내를 보드 위 오버레이가 아니라 HUD 위 한 줄로 뒀다.** 판을 가리지 않아야 무엇을 하라는 건지 보인다

---

## 2026-08-05 #33 — 웹 재시작, 육안 확인 완료

**요청**
> 웹 종료후 재시작해줘
>
> (이어서) 잘 된다

**한 일**
- 실행 중이던 `flutter run -d chrome` 종료 후 재시작 (최신 커밋 `9d5e443` 기준)
- 사용자가 화면을 직접 보고 **정상 동작 확인**

**변경 파일**
- 없음 (실행 확인만)

**결정 / 메모**
- **`#26` 이후 계속 미뤄져 있던 육안 확인이 여기서 닫혔다.** 그동안 보고할 때마다 "브라우저 확장이 붙지 않아 화면을 캡처하지 못했다" 를 남겨왔는데, 사용자 확인으로 아래가 실제로 검증됐다
  - 경계 벽이 격자선과 구분되게 그려진다 (`#26`)
  - 블록이 칸 중앙에 오고 벽 길이가 칸 하나와 같다 (`#28`)
  - 블록 크기와 외곽 테두리가 의도대로 보인다 (`#29`)
  - 방향 버튼이 없고 조작 안내가 뜬다 (`#31` · `#32`)
- 다음 세션이 `04` · `05` 완료 문서의 "육안 확인을 못 했다" 를 미해결로 읽지 않도록 여기에 남긴다. **그 문서들의 남은 사항은 이제 해소된 것으로 본다**

---

## 2026-08-05 #34 — 튜토리얼을 레벨 데이터 + 진입 오버레이로 전환

**요청**
> 튜토리얼 영역을 차지하는거 좀 그렇다. 사라지니깐 맵이 막 갑자기 커지네. 그냥 튜토리얼은 새로운 오브젝트가 있을때도 써먹게 레벨에서 표시여부 해주고. 처음 그 레벨에 도달한거면 오버레이(다음레벨가는) 띄워주고. 거기서 튜토리얼 안내 해주면 좋겠어.

**한 일**
- 띄우는 시점이 두 가지로 읽혀 `AskUserQuestion` 으로 확인 → **레벨 진입 직후 오버레이** / **지금 바로 영구 저장** 선택
- `docs/game-design.md` §6.1 **먼저** 전면 개정
- `Level.tutorial` 필드 신설, 레벨 1 · 3 · 5 · 7 에 문구 부여 (새 규칙이 나오는 레벨에만)
- `TutorialRepository` + `Impl`(SharedPreferences) + usecase 2종, `level_di` 에 provider
- `GamePlayScreenState.showsTutorial`, `TutorialDismissed` 이벤트, Notifier 배선
- `ControlHint` 삭제 → `TutorialOverlay` 신설
- 테스트 재편 (161/161)

**변경 파일**
- `docs/game-design.md` §6.1
- `lib/feature/level/**` — `Level.tutorial`, `level_data.dart`, `tutorial_repository.dart` + `Impl`, usecase 2종, `level_di.dart`
- `lib/feature/game/**` — `GameUsecases`, `game_di.dart`, state · event · notifier, `widget/tutorial_overlay.dart`(신규) · `control_hint.dart`(삭제), `game_play_screen.dart`
- `test/feature/game/presentation/game_play_screen_test.dart` · `game_play_screen_notifier_test.dart`
- `docs/tasks/completed/05-input.md`, `docs/tasks/09-progress.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 161/161 통과 (기존 154 + 신규 12, 삭제 5)

**결정 / 메모**
- **레이아웃을 차지하지 않는 것이 이번 변경의 출발점이다.** 보드 아래 한 줄은 사라질 때 판이 갑자기 커져 시선이 흔들린다. 오버레이는 판 위에 겹치므로 나타나고 사라져도 레이아웃이 그대로다. **사용자가 직접 겪고 지적한 문제**이고, 내가 `#32` 에서 "HUD 위 한 줄" 을 고를 때 고려하지 못한 부분이다
- **보드를 완전히 덮지 않는다.** "이 판에 구멍이 있다" 를 말로만 설명하는 것보다 뒤에 비치는 판을 가리키며 설명하는 편이 낫다
- **조작 문구를 레벨 데이터에 넣지 않았다.** 조작은 플랫폼마다 달라야 하는데 레벨 상수는 하나다. 레벨 문구는 규칙을, 조작 문구는 화면이 담당한다. 그래서 레벨 1 의 `tutorial` 은 "목표에 정확히 멈춰야 클리어" 라는 규칙이고, 조작 줄은 `TutorialOverlay` 가 `defaultTargetPlatform` 으로 붙인다
- **영구 저장은 사용자 선택이다.** 세션 한정 대안(provider 에 Set)을 함께 제시했고 `09-progress` 범위를 미리 먹는다는 대가를 밝혔다. 선택에 따라 **범위를 최대한 좁혀** `TutorialRepository` 하나만 만들었다 — 클리어 · 별점 · 최고 기록은 `09` 가 그대로 소유한다. `09-progress.md` 상단에 중복 저장 경고를 남겼다
- **튜토리얼 저장소를 `level` feature 에 뒀다.** 문구가 `Level` 에 붙어 있으니 "봤는지" 도 같은 feature 에 두는 편이 응집도가 높고, `game → level` 한 방향으로 끝나 새 간선이 생기지 않는다 (`#22` 의 순환 제거를 유지)
- **`showsTutorial` 은 파생값이 아니라 상태다.** "이미 봤는지" 는 저장소가 알고 닫는 것은 사용자다. `#32` 의 조작 안내는 파생값이었지만 이번 것은 아니다
- **튜토리얼이 떠 있는 동안 `canMove` 를 막았다.** 오버레이 뒤로 스와이프가 통하면 안내를 읽는 동안 판이 바뀐다
- **Notifier 테스트의 기본값을 "튜토리얼 전부 봄" 으로 잡았다.** 그러지 않으면 이동을 검사하는 테스트마다 오버레이부터 닫아야 해서 본론이 흐려진다. 튜토리얼 자체를 보는 테스트만 `bootFresh()` 로 새 상태에서 시작한다
- 작업 중 `showsTutorial` 삽입이 `dart format` 결과와 어긋나 **조용히 누락**됐다. 테스트가 바로 잡았다 — 문자열 치환으로 코드를 고칠 때는 포매팅 이후 형태를 기준으로 해야 한다

---

## 2026-08-05 #35 — 웹 재시작 · 커밋

**요청**
> 웹 종료후 재시작해줘
>
> (이어서) 커밋 해줘

**한 일**
- 실행 중이던 `flutter run -d chrome` 종료 후 재시작
- #34(튜토리얼 오버레이 전환)를 단일 커밋으로 커밋

**변경 파일**
- 없음 (실행 · 커밋 작업만)

**결정 / 메모**
- 규칙(§6.1) · 레벨 데이터 · 저장소 · 상태 · 위젯이 한 변경의 부분들이라 쪼개지 않았다. 중간 상태에서는 테스트가 통과하지 않는다

---

## 2026-08-05 #36 — 새 세션 컨텍스트 파악

**요청**
> @CLAUDE.md 읽어보고 프로젝트 구조와 의도 파악 그리고 다음 할일 파악해줘

**한 일**
- `CLAUDE.md` → `docs/game-design.md` → `docs/architecture.md` → `docs/tasks/README.md` → `docs/prompt-history.md`(#31~#35) 순으로 읽고, `git log`/`git status` 확인
- 다음 작업이 `06-animation` 임을 확인하고 그 문서를 읽어 착수 지점을 파악

**변경 파일**
- 없음 (파악만. 코드·문서 변경 없음)

**결정 / 메모**
- **착수하지 않았다.** `CLAUDE.md` 의 "요청당 한 작업 · 시키지 않으면 다음 작업을 시작하지 않는다" 규칙에 따라 파악까지만 하고 멈췄다
- `CLAUDE.md` 의 **Current state 절이 `#31`~`#34` 를 반영하지 못한 상태**다 — D-pad 제거와 튜토리얼(레벨 데이터 + 진입 오버레이 + `TutorialRepository`) 이 빠져 있고, `level` feature 가 이제 메타데이터 외에 튜토리얼 저장까지 갖는다는 사실도 없다. `06` 착수 시 같이 손보는 편이 낫다고 판단해 사용자에게 알렸다

---

## 2026-08-05 #37 — 06-animation: 이동 애니메이션

**요청**
> 06 진행해줘

**한 일**
- 착수 전 **작업 문서에 파킹돼 있던 열린 질문 2개**(벽 충돌 바운스 · 무효 입력 셰이크)와 결과 오버레이 시점을 `AskUserQuestion` 으로 확인 → 바운스·셰이크 **둘 다 제외**, 오버레이는 **연출이 끝난 뒤**
- `docs/game-design.md` §7 **먼저** 개정 — 오버레이 시점 · 되돌리기/다시하기 즉시 반영 · 접근성 · 제외한 두 항목과 그 이유
- `AppConstants` — `moveWithFallDuration`, `fallStartFraction` 추가 (ms 상수에서 파생)
- `BoardView` — `Positioned` → `AnimatedPositioned`, `fallingBlocks` · `isAnimating` 인자 추가, 축소·페이드를 `Interval` 로 슬라이드 뒤에 배치
- `GamePlayScreenState.fallingBlocks`, `AnimationCompleted` 이벤트, Notifier 배선(`_fallenBlocks`)
- `GamePlayScreen` — 연출 종료 `Timer`, 결과 오버레이를 `_showsResult` 로 게이트
- 테스트 17건 추가 (161 → 178). 렌더링 6건은 신규 파일

**변경 파일**
- `docs/game-design.md` §7 (규칙, 코드보다 먼저)
- `lib/core/config/app_constants.dart`
- `lib/feature/game/presentation/game_play/` — `widget/board_view.dart`, `game_play_screen.dart`, `game_play_screen_state.dart` · `_event.dart` · `_notifier.dart`
- `test/feature/game/presentation/board_animation_test.dart` (신규), `game_play_screen_test.dart`, `game_play_screen_notifier_test.dart`
- `docs/tasks/completed/06-animation.md` (완료 처리 · 실제 결과), `docs/tasks/README.md`, `README.md`, `CLAUDE.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 178/178 통과
- **교란 테스트로 새 테스트가 실패할 수 있는지 확인**했다 — `Interval` 을 빼면 "슬라이드 뒤 낙하" 가, 슬라이드 지속시간을 0 으로 만들면 "순간이동하지 않는다" 가 각각 걸린다
- `fvm flutter run -d chrome` 으로 띄워 육안 확인은 사용자 몫

**결정 / 메모**
- **`AnimationController` 를 두지 않았다.** 작업 문서 §2 는 Screen 에 컨트롤러를 두고 진행률로 좌표를 보간하라고 했지만, §1 의 `AnimatedPositioned` 를 쓰면 그 일이 위젯 쪽으로 사라진다. 화면에 남는 것은 "언제 끝났는지" 를 재는 `Timer` 하나뿐이고, `from`/`to` 를 `BoardView` 까지 내려보내지 않아도 되어 **좌표 계산이 여전히 `BoardView` 한 곳에만** 있다. 문서와 다른 길이라 `실제 결과` 에 이유를 적었다
- **`isAnimating` 이 "이번 변화를 보여줄지" 를 겸한다.** 암시적 애니메이션은 값이 바뀌면 무조건 재생하므로 **다시하기가 되감기 연출로 재생되는 문제**가 생긴다. 이 플래그가 `false` 면 지속 시간을 0 으로 주는 것으로 막았다. 다시하기는 플래그를 세우지 않으니 즉시 반영(기획서 §7)이 따로 코드 없이 지켜지고, `07` 의 되돌리기도 같은 경로를 탄다
- **낙하 순서를 타이머가 아니라 `Interval` 로 만들었다.** 암시적 애니메이션에 시작 지연이 없어서 슬라이드→낙하를 이으려면 보통 타이머가 하나 더 필요한데, 전체 구간을 하나로 잡고 앞부분을 비우면 선언적으로 끝난다. 두 개의 시간 소스가 어긋날 여지가 없다
- **축소·페이드 위젯을 빠지지 않는 블록에도 항상 감싸뒀다.** 빠지는 순간에만 감싸면 위젯이 새로 생겨 시작값(scale 0)부터 그려지고, 결국 애니메이션 없이 사라진다. 감싼 채 목표값만 바꿔야 재생된다
- **빠진 블록을 상태가 따로 든다.** `MoveResult` 가 `from`/`to`/`fellIntoHole` 을 이미 주고 있었지만(01·02 에서 "애니메이션이 필요로 하는 정보" 로 넣어둔 것이 여기서 값을 했다) `result.board` 에서는 지워져 있어서, 그대로 그리면 구멍까지 미끄러지지 않고 제자리에서 사라진다
- **판정은 Notifier 가, 보여줄 시점은 화면이 정한다.** `isCleared` 를 연출 종료까지 늦추는 방법도 있었지만 그러면 상태가 실제 판과 어긋나는 시간이 생긴다. 언제 그릴지는 표현의 문제다. 덕분에 Notifier 테스트도 거의 그대로 살았다
- **연출 중 마운트되는 경우를 `didChangeDependencies` 에서 받는다.** `didUpdateWidget` 만 보면 핫 리로드처럼 처음부터 `isAnimating` 인 채 붙었을 때 타이머가 안 걸리고, **완료 통지가 영영 가지 않아 입력이 죽는다.** 되돌릴 방법이 없는 상태라 방어를 넣었다
- **기존 테스트 2건이 "이유가 바뀐 채" 통과하고 있었다.** "클리어 후 입력 차단" 이 이제 `isAnimating` 때문에 막혀서, 정작 검사하려던 조건을 못 보게 됐다. 사이에 `AnimationCompleted` 를 넣어 원래 의도대로 되돌렸다 — 통과하는 테스트라도 이유가 바뀌면 고쳐야 한다
- **새 테스트를 일부러 깨뜨려봤다.** 연출 테스트는 "끝난 뒤" 를 보면 어차피 도착 좌표가 같아 항상 통과한다. 중간 프레임을 재도록 짜고, `Interval` 제거·슬라이드 제거 두 가지 교란으로 실제로 실패하는지 확인했다
- 클리어 시 **목표 칸 강조**(§7)는 넣지 않았다. 결과 오버레이가 바로 뜨는 지금은 보일 자리가 없다. `07` 에서 오버레이를 손볼 때 같이 본다

---

## 2026-08-05 #38 — 커밋

**요청**
> 커밋 해줘

**한 일**
- `#37`(06-animation)을 단일 커밋으로 커밋

**변경 파일**
- 없음 (커밋 작업만)

**결정 / 메모**
- 규칙(§7) · 상수 · 상태 · 이벤트 · Notifier · 위젯 · 테스트가 한 변경의 부분들이라 쪼개지 않았다. 중간 상태에서는 테스트가 통과하지 않는다
- 육안 확인은 아직 닫히지 않았다. `fvm flutter run -d chrome` 이 빌드 중이고, **지속 시간 150ms 와 낙하 타이밍이 적당한지**는 손으로 밀어봐야 안다. 조정이 필요하면 `AppConstants` 의 `_moveMs` · `_fallMs` 만 고치면 된다 — 나머지는 전부 여기서 파생된다

---

## 2026-08-05 #39 — 07-undo-reset: 되돌리기(레벨당 3회) · 별점

**요청**
> 잘 된다. 그러면 이번엔06작업을 해야하잖아? 언두는 횟수 제한도 있으면 좋겠다. 레벨당 3회 정도

**한 일**
- `06` 육안 확인 완료로 보고 완료 기준 마지막 항목을 채움. 다음은 `07` 임을 알림("06작업" 은 착오)
- **횟수 제한이 규칙 변경**이라 파급되는 두 가지를 `AskUserQuestion` 으로 확인 → **다시하기가 횟수를 되살린다** / **횟수 소진 시 구멍에서는 다시하기만 남는다**
- `docs/game-design.md` §5 **먼저** 개정 — §5.1(제한 근거) · §5.2(별점, 경계 버림) · §5.3 신설, §3.5 에 소진 시 처리 추가
- `Level.starsFor(moveCount)` 신설, `AppConstants.undoLimit = 3`
- 상태에 `history` · `undosLeft` · `canUndo`, `UndoRequested` 이벤트, Notifier `_undo`, `_reset` 이 횟수 회복
- `GameHud` 에 남은 횟수 표시 버튼, `Z` 키, `ResultOverlay` 에 별점과 소실 시 되돌리기 버튼
- 테스트 25건 추가 (178 → 203). 별점 경계값은 신규 파일

**변경 파일**
- `docs/game-design.md` §3.5 · §5 (규칙, 코드보다 먼저)
- `lib/core/config/app_constants.dart`, `lib/feature/level/domain/entity/level.dart`
- `lib/feature/game/presentation/game_play/` — state · event · notifier · screen, `widget/game_hud.dart` · `widget/result_overlay.dart`
- `test/feature/level/level_stars_test.dart` (신규), `test/feature/game/presentation/game_play_screen_test.dart` · `game_play_screen_notifier_test.dart`
- `docs/tasks/completed/07-undo-reset.md` (완료 처리 · 실제 결과), `docs/tasks/completed/05-input.md`(Z 키 해소), `docs/tasks/09-progress.md`(선행 조건 · 별점 중복 경고), `docs/tasks/README.md`, `README.md`, `CLAUDE.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 203/203 통과
- `canUndo` 에서 `undosLeft > 0` 을 빼는 교란으로 **테스트 4건이 실패하는 것**을 확인 — 제한이 실제로 검증되고 있다

**결정 / 메모**
- **무제한 되돌리기는 퍼즐을 시행착오 게임으로 만든다.** 사용자 요청이 있었지만 근거를 기획서 §5.1 에 적어뒀다 — 아무 방향이나 눌러보고 아니면 무르는 것이 최적 전략이 되고, 특히 **구멍이 "빠지면 무르면 그만" 이라 아무 위협도 아니게 된다**. 제한이 생기면서 구멍이 처음으로 실질적 제약이 됐다
- **다시하기가 횟수를 되살리는 것이 "실패 조건 없음"(§5)을 지킨다.** 되살리지 않으면 다 쓴 뒤에는 레벨을 나갔다 들어오는 것이 유일한 탈출구가 되어, 오히려 그렇게 플레이하게 만든다. 제한은 게임을 끝내는 벌칙이 아니라 **"이 시도를 버리고 처음부터" 라는 비용**으로만 작동해야 한다
- **§3.5 를 같이 고쳐야 했다.** 그 절이 "플레이어가 빠지면 되돌리기로 복구" 를 전제하고 있어서, 횟수 제한을 넣는 순간 전제가 깨진다. 규칙 문서는 한 곳만 고치면 모순이 남는다
- **되돌린 판에서 판정을 다시 낸다.** `isCleared`/`isPlayerLost` 를 `false` 로 되돌리는 게 아니라 복원된 판에서 재계산한다. 그냥 `false` 로 두면 목표 칸 위에서 무른 경우처럼 **되돌린 판이 이미 클리어인 상황**을 놓친다
- **되돌리기가 즉시 반영되는 데 코드가 들지 않았다.** `06` 에서 `isAnimating` 이 "이번 변화를 보여줄지" 를 겸하게 해둔 덕분에, `_undo` 가 그 플래그를 세우지 않는 것만으로 되감기 연출이 재생되지 않는다
- **별점을 `Level` 에 뒀다.** `minMoves` 가 이미 거기 있고, `architecture.md` §7 의 "도메인 로직은 엔티티 안에" 를 따랐다. `game → level` 한 방향이라 새 간선이 생기지 않는다
- **1.5배 경계를 버림으로 확정했다.** 반올림하면 `minMoves` 가 홀수일 때만 한 수를 더 얹어줘서 기준이 레벨마다 들쭉날쭉해진다. 기획서 §5.2 표를 갱신했다
- **횟수를 다 써도 버튼을 감추지 않는다.** 사라지면 왜 못 쓰는지 알 수 없어 고장으로 읽힌다. 비활성 상태로 `0` 을 보여준다
- **`Z` 키는 횟수를 다 썼어도 소비한다.** 흘려보내면 포커스가 `DirectionalFocusIntent` 로 떠나 **그 뒤로 방향키까지 죽는다** — `05` 에서 방향키로 똑같이 당했던 함정이다. `Ctrl+Z` 는 붙이지 않았다(브라우저 기본 동작과 겹치고, 한 손 조작에 불편)
- **진행도 저장은 `09-progress` 에 남겼다.** `07` 문서의 완료 기준 "최고 기록 유지" 는 저장소가 있어야 하는데 그건 `09` 의 몫이다. 별점 **계산과 표시**까지만 하고, 해당 체크박스는 이유와 함께 미완으로 뒀다. `09` 문서 상단에 "별점 공식을 다시 만들지 말 것" 을 적어뒀다
- 3회가 적절한지는 플레이해봐야 안다. `AppConstants.undoLimit` 하나만 고치면 되고, 레벨마다 다르게 주고 싶어지면 `Level` 로 옮기면 된다(`tutorial` 이 그렇게 들어갔다)

---

## 2026-08-05 #40 — 별점 기준을 초과 비율 방식으로 교체

**요청**
> 별점은 움직인 수에 따라 매기는건 맞긴 한데, 최소수의 20퍼를 초과하면 별2개, 40퍼를 초과하면 별 1개. 이런식으로 하는게 어떨까? 물론 최소수가 적으면 기준 퍼센티지는 더 높게 잡혀야지. 합리적인 점수 측점이 되도록

**한 일**
- 실제 레벨의 `minMoves` 를 먼저 확인 — **전부 1~3** 이라 순수 비율로는 여유가 0수가 된다는 것을 확인
- `docs/game-design.md` §5.2 **먼저** 전면 교체 — 공식 · 근거 · `minMoves` 별 표(1 · 2 · 3 · 10 · 20)
- `Level.starsFor` 를 `minMoves + max(고정, 버림(minMoves × 비율))` 로 교체, `_slack` 헬퍼 추가
- `level_stars_test.dart` 재작성 — 표 기반 경계값 검사 + 짧은/긴 레벨에서 지배항이 바뀌는 것 + **단조 감소** 검사
- 배수를 박아둔 화면 테스트 1건 수정
- `07` 완료 문서에 정정 절, `CLAUDE.md` 갱신

**변경 파일**
- `docs/game-design.md` §5.2 (규칙, 코드보다 먼저)
- `lib/feature/level/domain/entity/level.dart`
- `test/feature/level/level_stars_test.dart`, `test/feature/game/presentation/game_play_screen_test.dart`
- `docs/tasks/completed/07-undo-reset.md`, `CLAUDE.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 209/209 통과 (203 + 신규 6)

**결정 / 메모**
- **비율만으로는 짧은 레벨이 무너진다.** `minMoves` 2 의 20% 는 0.4수 → 버림하면 0이라, 한 수만 더 써도 곧장 ★☆☆다. **튜토리얼 레벨일수록 가혹해지는 뒤집힌 난이도**가 된다. 사용자가 "최소수가 적으면 기준을 더 높게" 라고 짚은 부분을 **비율과 고정 여유 중 큰 쪽**으로 구현했다 — 짧은 레벨은 고정 여유(1수 · 2수)가, 긴 레벨은 비율이 지배한다
- **고정 여유를 "더 높은 비율" 이 아니라 고정 수로 잡았다.** 레벨마다 다른 비율을 매기면 표가 예측 불가능해지고 레벨을 추가할 때마다 판단이 필요하다. 고정 수는 `minMoves` 가 커지면 자연히 비율에 자리를 내준다
- **★★★ 가 최적해를 요구하지 않게 됐다.** 기존 규칙은 `moveCount == minMoves` 였다. 최적해만 인정하면 별점이 "풀었는가" 가 아니라 "정답을 외웠는가" 를 재게 되고, 최소 수를 모르는 상태에서는 사실상 도달 불가능하다. **직전 요청(#39)에서 내가 지적했던 "레벨 1 은 2수만 써도 별 하나" 문제가 이걸로 해소됐다**
- **단조 감소를 테스트로 박았다.** 두 경계가 각각 `max` 로 계산되므로 비율과 고정값이 교차하는 구간에서 순서가 뒤집힐 여지가 있다. `minMoves` 5종 × 이동 횟수 전 구간을 훑어 별점이 되레 오르지 않는지 본다
- **경계값 표를 테스트에 상수로 옮겨 적었다.** 공식을 테스트에서 다시 계산하면 같은 실수를 두 번 하게 된다. 기획서 §5.2 의 표를 그대로 베껴 두 문서가 어긋나면 실패하게 했다
- 화면 테스트가 `minMoves * 3` 으로 "별 하나" 를 만들고 있었는데 기준이 바뀌며 ★★☆가 됐다. **경계값은 `level_stars_test` 가 보고 화면 테스트는 렌더링만 본다**는 역할 분리에 맞춰 고정 수로 바꿨다

---

## 2026-08-05 #41 — 커밋

**요청**
> 커밋 해줘

**한 일**
- `#39`(07-undo-reset)와 `#40`(별점 기준 교체)을 단일 커밋으로 커밋

**변경 파일**
- 없음 (커밋 작업만)

**결정 / 메모**
- **둘을 쪼개지 않았다.** `#40` 은 `#39` 가 만든 `Level.starsFor` 를 곧바로 갈아엎은 것이라, 중간 커밋은 **폐기된 별점 기준을 잠깐 존재시키는 것** 말고는 의미가 없다. 그 기준으로 짠 테스트도 함께 지워지므로 이력이 오히려 헷갈린다
- 별점 기준이 바뀐 경위(1.5배 → 초과 비율)는 `07` 완료 문서의 정정 절과 `#40` 항목에 남아 있으므로, 커밋을 합쳐도 왜 바뀌었는지는 추적된다

---

## 2026-08-05 #42 — 되돌리기 UI 제거 · 별점 조정 · 09-progress

**요청**
> 되돌리기는 그냥 없애자. UI만 지워줘. 기능 자체는 남겨주고. 별점도 너가 생각하기에는 너무 후한것 같으면 조금 수정하고. 그리고 바로 09번 진행하자.

**한 일**

*되돌리기 UI 제거*
- `docs/game-design.md` §5.1 재작성(제한 → 제거), §3.5 의 "되돌리기 유도" → "다시하기 유도"
- `GameHud` 버튼 · `ResultOverlay` 버튼 · `Z` 키 제거. **구현(`history`·`undosLeft`·`_undo`)과 그 테스트는 그대로 둠**
- 되돌리기 UI 테스트 6건 → **부재 회귀 테스트 4건**으로 교체 (D-pad 때와 같은 방식)

*별점 조정*
- ★★★ 의 고정 여유(1수)를 제거 → 짧은 레벨은 최적해를 요구, 긴 레벨만 20% 여유
- ★★☆ 의 고정 여유 2수는 유지 (완충)
- 기획서 §5.2 표 · `Level.starsFor` · 경계값 테스트 갱신

*09-progress*
- `progress` feature 신설 — `LevelProgress`, `ProgressRepository` + `Impl`, usecase 3종, `progress_di.dart`
- 저장 형식: 레벨당 키 하나(`progress_v1_level_3`)에 JSON. 손상 시 버리고 미클리어 취급
- `GameUsecases.saveClearResult` 배선, 클리어 시 Notifier 가 저장
- `docs/architecture.md` §2(의존 그래프) · §6(스트림 usecase 단일 인스턴스) 갱신
- 테스트 25건 추가 (207 → 232)

**변경 파일**
- `docs/game-design.md` §3.5 · §5.1 · §5.2 (규칙, 코드보다 먼저)
- `lib/feature/progress/**` (신규 8파일)
- `lib/feature/level/domain/entity/level.dart`, `lib/feature/game/domain/usecase/game_usecases.dart`, `lib/feature/game/game_di.dart`
- `lib/feature/game/presentation/game_play/` — `_notifier.dart` · `_state.dart` · `game_play_screen.dart` · `widget/game_hud.dart` · `widget/result_overlay.dart`
- `test/feature/progress/**` (신규 2파일), `test/feature/level/level_stars_test.dart`, `test/feature/game/presentation/game_play_screen_test.dart` · `game_play_screen_notifier_test.dart`
- `docs/architecture.md`, `docs/tasks/completed/09-progress.md`, `docs/tasks/README.md`, `docs/tasks/08-level-select.md`, `README.md`, `CLAUDE.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 232/232 통과
- `find lib -type d -name datasource` → 0개 (09 완료 기준)

**결정 / 메모**
- **"UI만 지워줘" 를 `Z` 키까지 포함으로 읽었다.** "되돌리기는 그냥 없애자" 가 앞에 있으므로, 키가 살아 있으면 플레이어에게 여전히 되돌리기가 제공되는 셈이라 요청과 어긋난다. 반면 구현은 명시적으로 남기라고 했으므로 그대로 뒀다
- **살아 있는 죽은 코드에 표식을 남겼다.** `CLAUDE.md`, 기획서 §5.1, `game_play_screen_state.dart` 세 곳에 "쓰이지 않는다고 지우지 말 것" 을 적었다. 그러지 않으면 다음 세션이 정리 대상으로 오해한다. 되살리는 방법(버튼 + `Z`)도 함께 적었다
- **별점은 실제로 후했다.** `minMoves` 1 에서 한 수 더 쓰는 것은 100% 초과인데 ★★★ 였다. **★★★ 에서만 고정 여유를 뺐다** — 짧은 레벨은 한 수의 상대적 무게가 크므로 최적해를 요구하고, 최소 수가 커질수록 정확히 맞히기 어려워지는 대신 비율 여유가 늘어난다. ★★☆ 의 여유 2수는 남겼다. 그게 없으면 `minMoves` 2 에서 ★★★ 와 경계가 붙어 원래 문제(한 수 어긋나면 ★☆☆)가 되살아난다
- **`SaveClearResultUsecase` 는 인스턴스가 하나여야 한다.** 스트림을 들고 있어서 두 컨테이너가 각자 만들면 **구독자가 방출을 영원히 못 받는다.** 컴파일도 테스트도 통과하면서 조용히 어긋나는 종류라, `GameUsecases` 가 만들어진 인스턴스를 주입받게 하고 **동일성을 테스트로 박았다.** `architecture.md` §6 에 예외로 명시
- **별점 계산을 usecase 안에 뒀다.** 호출부가 `Level` 과 이동 횟수만 넘긴다. 호출부마다 계산하면 기준이 갈리고, 별점 기준은 이미 두 번 바뀌었다
- **갱신하지 않을 때도 방출한다.** 기록이 더 나쁘면 저장은 건너뛰지만 "방금 이 레벨을 깼다" 는 구독자에게 여전히 새 정보이고 해금이 바뀌었을 수 있다
- **`LevelProgress` 에서 `cleared` 필드를 뺐다.** 작업 문서 초안에는 있었지만, **레코드가 있다는 것이 곧 클리어**다. `cleared: false` 를 저장하면 "없음" 과 "미클리어" 라는 같은 뜻의 두 상태가 생기고 빈 레코드가 쌓인다
- **저장은 상태를 세운 뒤에 한다.** 먼저 `await` 하면 저장이 끝날 때까지 연출이 시작되지 않아 입력이 멎은 것처럼 보인다. 연출이 끝나기를 기다리지도 않는다 — 기록은 확정됐고 그 사이 앱이 닫혀도 남아야 한다
- **레벨당 키 하나로 나눠 담았다.** 한 레벨의 값이 깨져도 나머지가 살아남는지 테스트로 확인했다. 키 접두사에 `v1` 을 넣어 나중에 형식이 바뀌어도 옛 키를 무시할 수 있게 했다
- **진행도가 아닌 키를 건드리지 않는지 테스트했다.** 같은 `SharedPreferences` 에 튜토리얼 플래그가 있어서, `clearAll` 이 그것까지 지우면 안 된다
- **육안 확인이 밀려 있다.** 웹에서 클리어 → 새로고침 → 기록 유지를 봐야 한다. `09` 완료 기준의 "웹에서 저장 동작" 은 미확인으로 남겼다
- **해금은 저장되지만 강제되지 않는다.** 레벨 선택 화면이 없어 지금은 URL 로 아무 레벨이나 열린다. `08` 의 몫이며 `09` 문서 남은 사항에 적었다

---

## 2026-08-05 #43 — 커밋

**요청**
> 커밋 해줘

**한 일**
- `#42`(되돌리기 UI 제거 · 별점 조정 · 09-progress)를 단일 커밋으로 커밋

**변경 파일**
- 없음 (커밋 작업만)

**결정 / 메모**
- **쪼개려다 접었다.** 되돌리기 제거와 `09-progress` 는 서로 의존하지 않아 두 커밋으로 나누는 편이 이력상 낫다. 다만 `CLAUDE.md` · `README.md` · 이 파일 셋이 두 변경을 함께 서술하고 있어, 나누려면 **문서를 중간 상태로 한 번 커밋했다가 다시 고쳐야** 한다. 코드가 아니라 문서가 얽혀 있는 경우라 얻는 것보다 잃는 것이 많다고 판단했다
- 다음부터는 **성격이 다른 요청이 한 메시지에 묶여 오면 문서 갱신을 각 변경에 맞춰 따로 쓰는 편**이 쪼갤 여지를 남긴다

---

## 2026-08-05 #44 — nvim 프로젝트 로컬 설정 추가

**요청**
> .nvim.lua 만들어서 ../quizlab처럼 nvim으로 실행할수있게해줘

**한 일**
- `../quizlab/.nvim.lua` 를 읽고 두 프로젝트의 차이를 먼저 확인 — quizlab 은 flavor 2종 × 엔트리포인트 2개, blockrunner 는 **flavor 도 엔트리포인트 분기도 없음**(`lib/main.dart` 하나)
- `.nvim.lua` 신설. 목록을 나누는 축을 flavor 가 아니라 **플랫폼**으로 잡음 — Chrome · web-server · macOS · 붙어 있는 기기 · Chrome(release)
- `luajit -bl` 로 문법 확인, `fvm flutter devices` 로 기기 이름 확인

**변경 파일**
- `.nvim.lua` (신규)

**검증**
- `luajit -bl .nvim.lua` → 통과
- `fvm flutter devices` → `chrome` · `macos` · Android 실기기 인식 확인
- `git check-ignore` → 무시되지 않음. quizlab 도 이 파일을 git 에 추적한다

**결정 / 메모**
- **베끼지 않고 축을 바꿨다.** quizlab 의 6개 항목은 대부분 `dev`/`prod` flavor 와 그에 딸린 엔트리포인트 조합인데, blockrunner 는 서버가 없어 그 축이 존재하지 않는다(`docs/architecture.md` §3). 그대로 옮기면 있지도 않은 flavor 를 가리키는 설정이 된다. 이 프로젝트에 실제로 있는 축은 **플랫폼**이다(§12 — 웹 · 모바일 · 데스크탑)
- **web-server 항목에 `--wasm` 을 넣지 않았다.** quizlab 에는 있지만, 이 항목의 용도는 **휴대폰 실기기에서 스와이프 손맛을 확인**하는 것이라 컴파일·핫리스타트 속도가 더 중요하다. dart2wasm 은 눈에 띄게 느리다. `--web-hostname=0.0.0.0` 은 그 용도에 필요하므로 남겼다
- **Chrome(release) 를 넣었다.** 연출이 60fps 로 도는지는 debug 빌드로 판단할 수 없다(기획서 §7, `06` 완료 기준의 "웹에서 프레임 드랍이 없다"). release 로 띄울 수단이 목록에 있어야 그 확인을 실제로 하게 된다
- **FVM 전제는 파일 주석에 적었다.** flutter-tools 전역 설정의 `fvm = true` 가 `.fvm/flutter_sdk` 를 집는다. quizlab 도 FVM 을 쓰므로(3.44.2) 사용자 환경에는 이미 켜져 있을 것이나, 아니면 시스템 flutter 로 돌아 버전이 어긋난다

---

## 2026-08-05 #45 — 커밋

**요청**
> 커밋 해줘

**한 일**
- `#44`(`.nvim.lua` 추가)를 커밋

**변경 파일**
- 없음 (커밋 작업만)

**결정 / 메모**
- 에디터 설정이라 `chore:` 로 달았다. `lib/` · `test/` 를 건드리지 않아 검증은 문법 확인(`luajit -bl`)과 기기 이름 확인으로 끝난다 — 이번 커밋에 한해 `fvm flutter test` 는 판단 근거가 아니다

---

## 2026-08-05 #46 — 08-level-select: 레벨 선택 화면

**요청**
> 08 진행해줘

**한 일**
- 착수 전 **순환 의존을 발견하고 먼저 끊었다** — `SaveClearResultUsecase` 가 `Level` 대신 번호와 별점 값을 받도록 변경
- `LevelUsecases` 에 진행도 usecase 2종 + 클리어 알림 스트림 추가 (`architecture.md` §4 예시대로)
- 레벨 선택 화면 일습 신설 — State · Event · Notifier · Screen · Root · `widget/level_card.dart`
- 자리표시자였던 `LevelSelectRoot` 를 교체
- 테스트 14건 추가 (232 → 246). 기존 `widget_test.dart` 의 자리표시자 버튼 탭을 카드 탭으로 교체
- `docs/architecture.md` 의존 그래프 갱신, `README.md` · `CLAUDE.md` 현행화

**변경 파일**
- `lib/feature/progress/domain/usecase/progress_usecases/save_clear_result_usecase.dart` (순환 제거)
- `lib/feature/game/presentation/game_play/game_play_screen_notifier.dart` (별점을 넘기는 쪽으로)
- `lib/feature/level/domain/usecase/level_usecases.dart`, `lib/feature/level/level_di.dart`
- `lib/feature/level/presentation/level_select/**` (신규 5파일 + Root 교체)
- `test/feature/level/level_select_screen_test.dart` · `level_select_screen_notifier_test.dart` (신규), `test/feature/progress/save_clear_result_usecase_test.dart`, `test/widget_test.dart`
- `docs/architecture.md`, `docs/tasks/completed/08-level-select.md`, `docs/tasks/README.md`, `README.md`, `CLAUDE.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 246/246 통과
- **스트림 구독을 제거하는 교란으로 "재진입 없이 갱신" 테스트가 실패하는 것을 확인**했다

**결정 / 메모**
- **착수하자마자 순환을 만났다.** 레벨 선택 화면은 `level` 에 있고 진행도가 필요하므로 `level → progress` 인데, `#42` 에서 내가 `SaveClearResultUsecase` 에 `Level` 을 넘기게 만들어 `progress → level` 이 이미 있었다. `#22`(game ⇄ level)와 **똑같은 실수를 다른 쌍에서 반복한 것**이다
  - 끊은 방법: `progress` 가 `Level` 에서 쓰던 것은 `number` 와 `starsFor` 의 **결과**뿐이라 둘을 값으로 받게 했다. 별점 공식은 여전히 `Level.starsFor` 한 곳에만 있고 호출부가 불러 넘긴다
  - `#42` 에서 "별점은 usecase 가 계산한다 — 호출부마다 계산하면 기준이 갈린다" 고 적었는데, **공식이 한 곳에 있으면 값을 넘겨도 갈리지 않는다.** 그때의 근거가 과했다
  - 교훈: **저장소 계층에 도메인 엔티티를 넘기기 전에 그 엔티티가 사는 feature 가 나중에 저장소를 필요로 할지 본다.** 진행도는 거의 항상 목록 화면이 읽는다
- **`LevelUsecases` 는 스트림만 받는다.** `SaveClearResultUsecase` 를 통째로 넘기면 레벨 선택 화면이 저장까지 할 수 있게 되는데 저장은 플레이 화면의 일이다. 인스턴스를 새로 만들지 않는 이유는 `GameUsecases` 와 같다
- **알림이 오면 방출값을 끼워넣지 않고 저장소를 다시 읽는다.** 한 번의 클리어가 별점만이 아니라 **해금 상태까지** 바꾸고 그 계산은 저장소가 갖고 있다. 끼워넣으면 해금 규칙이 두 곳에 생긴다. 이걸 검사하는 테스트를 따로 뒀다
- **잠긴 카드도 누를 수 있게 뒀다.** 못 누르게 하면 왜 안 되는지 알 수 없다. 눌리되 이동하지 않고 "N-1번을 클리어하면 열린다" 를 스낵바로 알린다. 스낵바는 쌓이지 않게 이전 것을 치운다
- **잠긴 레벨은 이름도 가렸다.** 레벨 이름이 곧 그 레벨의 기믹이라(`보이지 않는 턱` 등) 스포일러가 된다
- **Screen 을 `StatelessWidget` 으로 뒀다.** 규약(§5)의 "Screen 은 `StatefulWidget`" 은 컨트롤러·포커스를 두기 위한 것인데 이 화면엔 없다. 빈 `State` 는 잡음이라 판단했고 완료 문서에 적었다
- **반응형 테스트를 두 번 고쳤다.** 처음엔 "넓은 화면에서 카드 폭이 더 크지 않다" 로 짰는데 실제 값이 예상과 달라 실패했다. 검증하려던 성질은 폭이 아니라 **열 수**여서, 같은 y 좌표의 카드를 세는 방식으로 바꿨다. **틀린 단언을 통과하게 고치지 않고 무엇을 재려 했는지로 되돌아간** 경우다
- **`collection` 패키지를 쓰려다 되돌렸다.** `pubspec.yaml` 에 선언하지 않은 전이 의존이라, 인덱스 루프로 바꿔 임포트를 없앴다
- 상단 요약(전체 별 개수·클리어율)은 **넣지 않았다.** 레벨이 7개뿐이라 카드를 훑으면 바로 보인다. 열린 질문으로 남겼다
- **육안 확인을 못 했다.** 카드 비율(`childAspectRatio: 0.85`)과 그리드 간격은 눈으로 봐야 한다. `maxCrossAxisExtent: 160` 도 출발점이며 `10-responsive` 에서 맞춘다

---

## 2026-08-05 #47 — 커밋

**요청**
> 커밋 해줘

**한 일**
- `#46`(08-level-select)을 단일 커밋으로 커밋

**변경 파일**
- 없음 (커밋 작업만)

**결정 / 메모**
- 순환 제거(`SaveClearResultUsecase` 시그니처 변경)와 화면 신설을 쪼갤지 검토했으나 합쳤다. **순환을 끊는 것이 이 화면을 만들기 위한 전제**라 앞 커밋만 떼어내면 "왜 지금 이걸 바꾸나" 가 설명되지 않는다. `#43` 때와 달리 두 변경이 실제로 의존 관계다

---

## 2026-08-05 #48 — 웹으로 실행

**요청**
> 일단 실행해줘 웹으로

**한 일**
- `fvm flutter run -d chrome --web-port=5123` 로 실행. Chrome 창이 열리고 디버그 서비스가 붙은 것까지 확인

**변경 파일**
- 없음 (실행만)

**결정 / 메모**
- 앞선 두 번의 시도에서 URL 이 끝내 안 나온 원인은 앱이 아니라 **내 쪽 파이프 버퍼링**이었다. `flutter run` 출력을 `grep -m1` 에 물리면 라인 버퍼가 차기 전까지 아무것도 안 보인다. 파이프 없이 파일로 받고 나서 정상 출력이 잡혔다
- 기존 프로세스를 정리할 때 `pkill` 패턴이 넓으면 **사용자의 quizlab 실행까지 죽인다.** 확인해보니 살아 있던 3개가 전부 quizlab(3.44.2, `--flavor dev`) 이었다. 패턴을 좁혀 건드리지 않았다
- **육안 확인 3건은 여전히 열려 있다** — 웹에서의 진행도 영속(`09` 의 유일한 미체크 완료 기준), 레벨 카드 비율·간격(`08`), 조인 별점 체감

---

## 2026-08-05 #49 — 프로젝트 구조·의도·다음 할 일 검토

**요청**
> CLAUDE.md 읽고 이 프로젝트의 구조와 의도 및 다음에 할 일 검토해줘

**한 일**
- `CLAUDE.md` → `docs/game-design.md` · `docs/architecture.md` · `docs/tasks/README.md` · `docs/prompt-history.md`(#46·#47) 순으로 읽고 현황 파악
- `git log` · `git status` 확인 — 작업 트리 깨끗, HEAD `c232fe0`
- 남은 작업이 `10-responsive` 하나임을 확인하고 착수 전 쟁점을 정리해 보고

**변경 파일**
- `docs/prompt-history.md` — 이 항목과 `#48`(누락분) 추가

**결정 / 메모**
- **코드 변경 없음.** 파악·보고만 한 요청이지만 규약대로 기록한다
- `#48` 이 빠져 있었다. 실행만 하고 코드가 안 바뀐 요청도 기록 대상이라 소급해 채웠다
- `10-responsive` 착수 전에 사용자 판단이 필요한 것: ① 휴대폰 가로 모드 지원 여부(문서상 "고정하지 않는 쪽으로 기움") ② expanded 에서 HUD 를 우측 패널로 뺄지. 임의로 정하지 않고 남긴다

---

## 2026-08-05 #50 — 세로 고정 · HUD 폭을 보드 폭에 맞춤

**요청**
> 1. 이 앱은 세로고정.
> 2. 이동횟수랑 다시하기는 맵의 너비에 맞춰주면 좋겠어. 지금 화면 끝과 끝에 UI가 있는데 맵의 좌우 크기 따라가게.

**한 일**
- `docs/game-design.md` **§6.2 신설을 먼저** — 세로 고정과 HUD 폭 규칙, 각각의 근거
- 보드 기하 계산을 `BoardMetrics` 로 분리 (`widget/board_metrics.dart` 신규). `BoardView` 와 화면이 같은 함수를 부른다
- `GamePlayScreen` 이 HUD 를 `SizedBox(width: 보드 폭)` 으로 감싼다. `GameHud` 의 좌우 여백은 제거(이중이 된다)
- `main.dart` 에서 `SystemChrome.setPreferredOrientations` 로 세로 고정
- 테스트 6건 추가 (246 → 252) — `hud_width_test.dart` 5건, `main_orientation_test.dart` 1건
- `docs/tasks/10-responsive.md` 갱신 — 열린 질문 해소, 가로 배치 항목 철회

**변경 파일**
- `docs/game-design.md` — §6.2 신설
- `lib/feature/game/presentation/game_play/widget/board_metrics.dart` (신규)
- `lib/feature/game/presentation/game_play/widget/board_view.dart` — 계산을 `BoardMetrics` 에 위임
- `lib/feature/game/presentation/game_play/widget/game_hud.dart` — 좌우 여백 제거
- `lib/feature/game/presentation/game_play/game_play_screen.dart` — `LayoutBuilder` + `_hudWidth`
- `lib/main.dart` — 세로 고정
- `test/feature/game/presentation/hud_width_test.dart`, `test/main_orientation_test.dart` (신규)
- `docs/tasks/10-responsive.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 252/252 통과
- **HUD 폭 제한을 `constraints.maxWidth` 로 되돌리는 교란으로 5건 전부 실패하는 것을 확인**했다

**결정 / 메모**
- **§6.1(튜토리얼) 뒤에 §6.2 로 붙였다.** 앞에 끼우면 절 번호가 밀리는데 `§6.1` 참조가 코드·테스트·문서 15곳에 있다. 번호는 위치가 아니라 **참조의 안정성**이 정한다
- **계산을 `BoardMetrics` 로 꺼낸 이유는 HUD 다.** 셀 크기 계산은 `BoardView` 한 곳에만 둔다는 규약이 있었는데, 이제 화면도 보드 폭을 알아야 한다. 규약의 의도는 "`BoardView` 안에" 가 아니라 **"공식이 한 벌만 있을 것"** 이므로, 위젯이 아니라 값 타입으로 옮겨 둘 다 부르게 했다
- **`BoardView` 는 여전히 자기 제약에 스스로 맞춘다.** 밖에서 계산한 크기를 받아 그리게 하면 그 계산이 실제 가용 공간보다 큰 순간 보드가 넘친다. 밖의 계산은 HUD 폭에만 쓴다
- **정확히 맞지 않는 구간이 하나 남는다.** `Column` 은 비유연 자식인 HUD 를 보드보다 **먼저** 배치하므로 화면 쪽 계산에 HUD 높이가 빠져 있다. 폭이 짧은 변이면 높이는 `min` 에 걸리지 않아 정확하고, **가로로 납작한 창에서만** HUD 가 보드보다 조금 넓다. 세로 고정이라 실기기에서는 나지 않는다
  - 완전히 맞추려면 `CustomMultiChildLayout` 으로 두 번 배치하거나 한 프레임 늦게 반영해야 하는데, 안 보이는 경우 하나를 위해 감당할 구조가 아니라고 판단했다. 코드와 작업 문서에 남겼다
- **`GameHud` 의 좌우 여백(`Spacing.lg`)을 없앴다.** 폭을 밖에서 주는데 안에서 또 넣으면 보드 끝과 어긋난다. 폭을 정하는 곳과 여백을 정하는 곳은 하나여야 한다
- **HUD 폭 테스트가 처음엔 엉뚱한 것을 쟀다.** `find.byType(BoardView)` 는 부모가 준 상자라 화면 폭에 가깝고, 좁은 화면에서는 보드 폭과 우연히 같아 3건이 **틀린 이유로 통과**했다. 넓은 화면 케이스에서 드러나 실제 보드 `SizedBox` 를 재도록 고쳤다 — 넓은 화면 케이스를 넣지 않았으면 못 잡았다
- **세로 고정은 `SystemChrome` 한 줄이지만 테스트를 붙였다.** 조용히 빠져도 웹·데스크탑에서는 아무 증상이 없어 눈치채지 못한다. `dart:io` 분기가 아니라 `SystemChrome` 을 쓴 것도 의도적이다 — 웹에서 `dart:io` 는 못 쓰고, `SystemChrome` 은 해당 없는 플랫폼에서 조용히 무시된다
- **`10-responsive` 를 착수하지는 않았다.** 이번 요청은 그 작업의 열린 질문 두 개에 대한 답이고, 그중 지시받은 것(HUD 폭)만 했다. 남은 항목은 작은 화면 오버플로 · 큰 글꼴 · 6×6/8×8 외곽 크기 검증이다

---

## 2026-08-05 #51 — 커밋

**요청**
> 커밋 해줘

**한 일**
- `#50`(세로 고정 · HUD 폭)을 단일 커밋으로 커밋

**변경 파일**
- `docs/prompt-history.md` — 이 항목 (커밋에 `--amend` 로 합침)

**결정 / 메모**
- 세로 고정과 HUD 폭을 쪼개지 않았다. 별개의 변경으로 보이지만 **둘 다 §6.2 라는 한 결정의 두 면**이고, 기획서 절 하나가 양쪽 근거를 함께 담고 있어 떼어내면 그 절이 두 커밋에 걸친다
- `main` 에 직접 커밋했다. 이 저장소의 기존 커밋이 전부 그렇고 푸시는 사용자가 한다

---

## 2026-08-05 #52 — 다국어 작업 계획서 작성

**요청**
> 이제 다국어도 적용할거야. tasks에 문서 추가해주고. 이 앱의 모든 한글로 적용된 부분들 다국어로 마이그레이션할거거든? 별도로 라이브러리 안쓰고. 그냥 다국어 상태만 선언해두고 사용할꺼고. (di 규칙 잘 준수하면서) 다국어 파일은 dart상수파일로 작성할거야. docs/tasks 에 작업에 대한 계획서 추가해줘.

**한 일**
- 착수 전 사용자에게 3가지를 물어 확정 — 지원 언어(ko·en·ja·zh·fr), 선택 방식(시스템 기본 + 수동 변경 + 저장), 레벨 이름·튜토리얼 포함 여부(포함)
- `lib/` 의 한국어 문자열 리터럴을 전수 조사해 대상 목록을 만듦
- `docs/tasks/11-i18n.md` 신설
- `docs/tasks/README.md` 현황표에 11번 추가, 순서 메모 추가

**변경 파일**
- `docs/tasks/11-i18n.md` (신규)
- `docs/tasks/README.md`
- `docs/prompt-history.md`

**결정 / 메모**
- **계획서만 썼고 코드는 손대지 않았다.** 요청이 계획서였고, 구조가 바뀌는 작업이라 규약대로 계획을 먼저 세운다
- **번역 대상을 둘로 갈랐다.** 화면 문구는 번역하고 **파서 오류·`assert`·`debugMessage` 는 한국어 그대로 둔다.** 그것을 읽는 사람은 플레이어가 아니라 레벨을 만드는 사람이다. 5배로 늘려봐야 정작 읽을 사람에게 도움이 안 된다
- **`Map<String,String>` 이 아니라 추상 클래스 + 언어별 구현으로 간다.** 키를 빠뜨리면 컴파일이 깨지는 것이 핵심이다. `Map` 이면 오타가 런타임 빈 문자열이 되고, 그건 그 언어를 읽는 사람만 볼 수 있다
- **값이 끼어드는 문구는 전부 함수로 선언한다.** 그래야 영어의 `1 move` / `2 moves` 분기를 영어 파일이 자기 안에서 처리한다. `intl` 의 ICU plural 이 하는 일을 Dart 함수가 대신하게 하는 것이 라이브러리를 안 쓰는 값이다
- **레벨 이름·튜토리얼만 `Map<int,String>` 으로 예외를 뒀다.** 레벨은 계속 느는데 레벨 하나에 5파일 × 2줄이 붙으면 못 쓴다. 대신 **키 집합이 `kLevels` 와 일치하는지 테스트로 강제하고 런타임 폴백은 두지 않는다** — 테스트가 통과하면 빠진 키가 있을 수 없고, 없는 상황을 처리하는 코드는 죽은 코드다
- **`Level.tutorial` 을 `bool hasTutorial` 로 바꾼다.** 지금은 Notifier 가 `tutorial != null` 로 표시를 결정하는데, 문구가 번역으로 빠지면 **그 판단이 언어에 의존하게 된다.** 어느 레벨이 규칙을 가르치는지는 레벨 데이터의 성질이지 번역이 아니다
- **문자열 전달은 `InheritedWidget`(`AppStringsScope`)으로 한다.** Screen 이 Riverpod 을 모른다는 규약(§5)을 지키면서, 40여 개 문자열을 `State` 에 실어 `LevelCard`·`GameHud`·오버레이까지 관통시키지 않는다. 위젯 테스트에서는 Scope 로 감싸 언어를 주입한다
- **`appStringsProvider` 는 규약 §4("provider 본문에서 `ref.watch` 금지")의 예외다.** 이건 DI 배선이 아니라 파생 상태이고, 언어가 바뀔 때 재계산되지 않으면 존재 이유가 없다. 몰래 어기지 않고 규약 문서에 예외로 적기로 했다
- **`AppLocale` 은 `settings` 가 아니라 `core/i18n/` 에 둔다.** 문자열 파일이 이 enum 으로 키잉되는데 `core` 는 feature 를 import 할 수 없다
- **언어 저장은 `progress` 와 섞지 않는다.** 지워지는 시점이 다르다 — 진행도 초기화가 언어까지 날리면 안 된다
- **설정 화면을 만들지 않는다.** 항목이 언어 하나뿐이라 화면을 세울 근거가 없다. 레벨 선택 AppBar 의 아이콘 → 다이얼로그로 충분하다. 언어 이름은 **그 언어로** 적는다 — 읽을 수 없는 언어로 적힌 목록에서 자기 언어를 찾을 수는 없다
- **`SaveLocaleUsecase` 단일 인스턴스를 테스트로 못박는다.** `08` 에서 스트림 인스턴스가 둘이면 구독자가 조용히 안 울리는 함정을 겪었다
- **완료의 실질적 정의를 테스트로 만들었다** — `lib/**/presentation/**` 과 `level_data.dart` 에 한글 리터럴이 하나도 없을 것. "다 옮겼다" 는 눈으로 세면 반드시 빠진다
- **`flutter_localizations` 는 열린 질문으로 남겼다.** 안 쓰면 Material 위젯 내장 문구가 영어로 남는데, SDK 동봉 패키지라 "외부 라이브러리"에 해당하는지 해석의 여지가 있다. 일단 넣지 않고 새어 나오는 곳이 보이면 재검토한다
- **CJK 글꼴을 완료 기준에 넣었다.** 웹에서 두부(□)로 깨지면 폰트를 번들해야 하고 그건 앱 크기 문제라 별도 과제가 될 수 있다

---

## 2026-08-05 #53 — 문서 커밋 · 푸시

**요청**
> 문서 커밋 푸시부터

**한 일**
- `#52`(다국어 계획서)를 커밋하고 `origin/main` 에 푸시

**변경 파일**
- `docs/prompt-history.md` — 이 항목 (커밋에 `--amend` 로 합침)

**결정 / 메모**
- **처음으로 푸시까지 했다.** 그동안은 사용자가 직접 밀었고 `CLAUDE.md` 에도 그렇게 적혀 있는데, 이번엔 명시적으로 요청받았다. 요청 없이는 계속 커밋까지만 한다
- 확인해 보니 앞 커밋(`2bbde46`)은 이미 `origin/main` 에 올라가 있어 이번 문서 커밋만 올라간다

---

## 2026-08-05 #54 — 11-i18n: 다국어 마이그레이션

**요청**
> 자 이제 본격적으로 다국어 진행하자. 한국어 곳곳에 숨어있는 곳 꼼꼼하게 찾아서 마이그레이션 해주면 좋겠어.

**한 일**
- `lib/core/i18n/` 신설 — `AppLocale` · `AppStrings`(추상) · 언어별 상수 5벌 · `strings_catalog.dart` · `AppStringsScope`
- `settings` feature 신설 — repository · usecase 2종 · `LocaleNotifier` · 언어 선택 다이얼로그 · DI
- `game` · `level` 화면 문구를 `context.strings` 로 전량 교체
- `Level` 에서 `name` · `tutorial` 제거, `hasTutorial`(bool) 만 남김. 문구는 `AppStrings` 로 이관
- 레벨 선택 AppBar 에 언어 아이콘 → 다이얼로그
- 테스트 39건 추가 (252 → 291), 기존 화면 테스트를 `withStrings` 하네스로 전환
- `docs/game-design.md` §6.1 · `docs/architecture.md` §4·§11·§13 · `CLAUDE.md` · `README.md` 갱신
- `docs/tasks/11-i18n.md` 에 "실제 결과" 추가 후 `completed/` 로 이동

**변경 파일**
- `lib/core/i18n/**` (신규 7파일)
- `lib/feature/settings/**` (신규 8파일)
- `lib/main.dart` — `AppStringsScope` 배선, `ConsumerWidget` 으로 전환
- `lib/feature/level/domain/entity/level.dart`, `lib/feature/level/data/level_data.dart`
- `lib/feature/game/presentation/**`, `lib/feature/level/presentation/**`
- `test/support/strings_harness.dart` (신규), `test/core/i18n/**` (신규 2), `test/feature/settings/**` (신규 3)
- 기존 테스트 6종 수정
- `docs/**`, `CLAUDE.md`, `README.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 291/291 통과
- **교란 3종 확인** — ① `appStringsProvider` 를 `ref.read` 로 되돌리면 언어 전환 테스트 2건 실패 ② 문구 하나를 하드코딩으로 되돌리면 한글 스캔 테스트 실패 ③ 레벨을 추가하고 번역을 빼면 키 패리티 테스트 5건 실패

**결정 / 메모**
- **문구를 추상 멤버로 선언한 것이 이 설계의 전부다.** 5개 파일이 전부 구현할 때까지 빌드가 통과하지 않는다. `Map` 이었다면 오타가 런타임 빈 문자열이 되고 **그건 그 언어를 읽는 사람만 볼 수 있다** — 한국어 사용자인 우리는 영영 모른다
- **값이 끼어드는 문구는 함수로 뒀다.** 영어 `1 move` / `2 moves`, 프랑스어 `1 coup` / `2 coups` 를 각 언어가 자기 파일에서 처리한다. `intl` 의 ICU plural 이 하는 일이고, 이걸 함수로 대신할 수 있다는 것이 라이브러리를 안 써도 되는 근거였다
- **레벨 이름·안내만 `Map<int,String>` 이다.** 레벨은 계속 느는데 멤버로 두면 레벨 하나에 5파일 × 2줄이 붙는다. 잃은 컴파일 검사는 **키 패리티 테스트**로 갚았고, 런타임 폴백은 두지 않았다 — 테스트가 통과하면 빠진 키가 있을 수 없고 없는 상황을 처리하는 코드는 죽은 코드다
- **`Level.tutorial` → `bool hasTutorial`.** 이게 이번 작업에서 가장 중요한 판단이다. 문구와 존재 여부를 한 덩어리로 두면 **번역이 비었을 때 튜토리얼이 조용히 사라진다.** "이 레벨이 무언가를 가르친다" 는 레벨 설계의 사실이지 번역이 아니다
- **`InheritedWidget` 으로 내려보냈다.** Screen 이 Riverpod 을 모른다는 규약(§5)을 지키면서 문자열 30여 개를 `State` 로 관통시키지 않는 유일한 길이다. 위젯 테스트는 `withStrings` 로 감싸며, **`ProviderScope` 를 안 씌우는 가드는 그대로 살아 있다**
- **`appStringsProvider` 만 `ref.watch` 를 쓴다 — 규약 §4의 예외.** 몰래 어기지 않고 `architecture.md` 에 "배선이 아니라 파생 상태" 라는 판별 기준과 함께 적었다. `ref.read` 로 되돌리는 교란이 테스트 2건을 깨뜨리는 것으로 근거를 남겼다
- **계획서와 달리 `SaveLocaleUsecase` 는 스트림을 흘리지 않는다.** `08` 에서 스트림이 필요했던 것은 **서로를 모르는 두 Notifier** 가 있었기 때문인데, 언어는 `LocaleNotifier` 하나가 들고 모든 화면이 거기서 파생된다. 스트림을 두면 같은 사실에 이르는 길이 둘이 되고 어느 쪽이 진짜인지 흐려진다. 계획서를 그대로 따르는 것보다 이유를 다시 확인하는 편이 맞다고 봤다
- **기기 로케일을 함수로 주입했다.** `PlatformDispatcher` 를 repository 안에서 직접 부르면 테스트가 기기 언어를 못 바꾼다. 값이 아니라 함수인 것은 기기 설정이 앱 실행 중에도 바뀌기 때문이다
- **`zh-Hans-CN` 을 언어 코드만 보고 판정한다.** 통째로 비교하면 어느 것도 맞지 않아 늘 `ko` 로 떨어진다 — 실제로 흔한 버그라 테스트를 따로 뒀다
- **번역 대상을 화면 계층으로 한정했다.** 처음 스캔 테스트가 `LevelProgress.toString()` 의 `'$bestMoveCount수'` 를 잡았는데, 이건 개발자용이라 검사 범위를 `presentation/` 과 `level_data.dart` 로 좁혔다. 범위를 넓게 두면 **개발자 문구까지 번역하게 만드는 잘못된 압력**이 된다
- **`widget_test.dart` 가 언어를 못박게 했다.** 기기 로케일을 따라가면 테스트 환경(en)에서 영어로 그려져 한국어 단언이 통째로 무너진다. 이건 마이그레이션이 실제로 동작한다는 증거이기도 하다
- **`RadioListTile` 이 deprecated 라 `ListTile` + 체크 아이콘으로 갔다.** `RadioGroup` 을 새로 들이는 것보다 단순하고, 고르면 바로 닫히는 다이얼로그라 라디오의 "선택 후 확인" 의미가 필요 없다
- **`ja` · `zh` · `fr` 은 초벌이다.** 각 파일 헤더에 적어 뒀다. 레벨 이름은 말맛이 있는 짧은 문구라 특히 검수가 필요하다
- **육안 확인 필요:** CJK 글리프가 웹에서 두부(□)로 깨지지 않는지. 깨지면 폰트 번들이 필요하고 그건 앱 크기 문제라 별도 과제다

---

## 2026-08-05 #55 — 커밋

**요청**
> 커밋 해줘

**한 일**
- `#54`(11-i18n 다국어 마이그레이션)를 단일 커밋으로 커밋

**변경 파일**
- `docs/prompt-history.md` — 이 항목 (커밋에 `--amend` 로 합침)

**결정 / 메모**
- **31개 파일이 한 커밋이지만 쪼개지 않았다.** i18n 골격 · settings feature · 화면 교체 · 레벨 데이터 이관은 서로의 전제라 **중간 어느 지점에서도 테스트가 통과하지 않는다.** 골격만 넣은 커밋은 아무도 안 쓰는 코드고, 화면만 바꾼 커밋은 컴파일이 안 된다. `#46` 때와 같은 판단이다
- 푸시는 하지 않았다 — `#53` 은 명시적으로 요청받은 경우였고 기본은 사용자가 민다

---

## 2026-08-05 #56 — 크리티컬한 문제 진단

**요청**
> 그러면 너가 생각하기엔 크리티컬한 문제는 뭐지?

**한 일**
- 추측하지 않고 임시 probe 테스트로 실제 확인 — 5개 언어 × 화면 크기 × 글꼴 배율로 렌더링해 오버플로 발생 여부를 측정
- `pubspec.yaml` · `web/index.html` 의 번들 폰트 부재 확인
- 4가지를 우선순위와 함께 보고 (프랑스어 HUD 오버플로 / 큰 글꼴 오버플로 / 웹 CJK 폰트 / `!` 크래시 표면)

**변경 파일**
- 없음 (진단만, probe 는 삭제)

**결정 / 메모**
- **"크리티컬한 게 뭐냐" 는 질문에 추측으로 답하지 않았다.** 의심 가는 것을 임시 테스트로 실제 렌더링해 확인했고, 그 결과 **내 의심 하나는 틀렸다** — HUD 폭 제한이 프랑스어 오버플로의 원인일 거라 봤는데 화면 폭으로 되돌려도 여전히 깨졌다. 순수하게 문구 길이 문제였다
- **다국어가 새로 만든 버그는 하나뿐이었다** (프랑스어 HUD). 큰 글꼴 오버플로는 `10-responsive` 의 미체크 완료 기준이 실제로는 거짓이었던 것으로, 다국어 이전부터 깨져 있었다
- **`!` 폴백 없음 결정을 스스로 재평가했다.** `#54` 에서 "테스트가 막으니 폴백은 죽은 코드" 라고 적었는데, 그 논리는 **테스트를 항상 돌린다는 전제**에 기댄다. 레벨을 추가하고 테스트를 안 돌리면 카드 하나가 비는 게 아니라 화면 전체가 죽는다. 실패 모드가 가혹한 만큼 전제가 약하다는 것을 인정했다

---

## 2026-08-05 #57 — 10-responsive: 반응형 레이아웃

**요청**
> 10번 반응형까지 통째로 진행하자

**한 일**
- **테스트를 먼저 짰다** — `test/responsive_test.dart` 27건. 5개 언어 × 작은 폰 · 가로/세로 스윕 · 글꼴 ×1.5·×2.0 · 레벨 이름 잘림 · 6×6 vs 8×8 외곽 크기
- 9건 실패를 확정한 뒤 세 곳을 고침
  - `GameHud` 의 `Row` → `Wrap` (한 줄에 못 들어가면 두 줄로 접힘)
  - 레벨 카드 `childAspectRatio` 를 글꼴 배율에 따라 늘어나게
  - 카드 이름 두 줄 허용 + **영어·프랑스어 레벨 이름을 짧게 재번역**
- 교란 4종으로 새 가드가 실제로 잡는 것을 확인
- 작업 문서에 "실제 결과" 추가 후 `completed/` 로 이동, 현황표·`CLAUDE.md`·`README.md` 갱신

**변경 파일**
- `lib/feature/game/presentation/game_play/widget/game_hud.dart`
- `lib/feature/level/presentation/level_select/level_select_screen.dart` — `_cardAspectRatio`
- `lib/feature/level/presentation/level_select/widget/level_card.dart` — `maxLines: 2`
- `lib/core/i18n/strings_en.dart` · `strings_fr.dart` — 레벨 이름 단축
- `test/responsive_test.dart` (신규)
- `docs/tasks/completed/10-responsive.md`, `docs/tasks/README.md`, `CLAUDE.md`, `README.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 318/318 통과 (291 → 318)
- **교란 4종 확인** — ① `Wrap` → `Row` ② 카드 비율 상수화 ③ 영어 이름 길게 ④ 이름 한 줄 제한, 각각 해당 테스트가 실패

**결정 / 메모**
- **완료 기준 두 개가 "미확인" 이 아니라 실제로 거짓이었다.** 테스트를 먼저 짜지 않았으면 눈으로 보고 "괜찮네" 하고 지나갔을 것이다. 교훈: **시각적인 항목에서 "확인 안 함" 은 "아마 깨져 있음" 으로 취급한다**
- **말줄임으로 때우지 않았다.** 완료 기준이 "글꼴을 키워도 텍스트가 잘리지 않는다" 이므로 `ellipsis` 는 기준을 만족시키는 척하는 것이지 만족시키는 게 아니다. HUD 는 접히고, 카드는 커지고, 이름은 짧아진다
- **레벨 이름은 카드를 키우지 않고 번역을 고쳤다.** `The Invisible Ledge` → `Hidden Ledge`. **카드 라벨에는 길이 예산이 있고 그것을 무시한 쪽은 초벌 번역이다.** 카드를 키우면 한 화면에 들어가는 레벨 수가 줄어 목록 화면의 값이 떨어진다. 이 판단을 테스트가 못박아, 앞으로 번역을 길게 쓰면 바로 걸린다
- **카드 비율을 글꼴 배율만큼 그대로 나누지 않고 절반만 반영했다.** 자물쇠·별 아이콘은 배율을 따르지 않아 전부 반영하면 지나치게 길쭉해진다. 상한 2배도 뒀다
- **6×6/8×8 외곽 크기와 `shouldRepaint` 는 이미 정상이었다.** 확인만 하고 코드를 건드리지 않았다 — 고칠 것이 없는데 손대면 회귀만 만든다
- **최소 셀 크기 하한은 넣지 않았다.** 작업 문서에 "아직 없는 것" 으로 적혀 있었지만, 가장 큰 판이 6×6 이고 320px 화면에서도 셀이 47px 다. **아직 존재하지 않는 큰 판을 위한 장치**라 12×12 급이 생기면 그때 만든다
- **가로 배치·가로 모드 항목은 철회했다** — 세로 고정 결정(기획서 §6.2)으로 근거가 사라졌다
- **이로써 `docs/tasks/` 의 모든 작업 문서가 완료됐다.** 다음 요청은 목록에서 고르는 것이 아니므로 무엇을 할지 물어야 한다. `CLAUDE.md` 에 그렇게 적었다
- **남은 육안 확인:** 웹에서 CJK 글리프가 두부(□)로 깨지는지. 번들 폰트가 없어 Flutter 웹은 Noto 폴백을 런타임에 받는다

---

## 2026-08-05 #58 — 커밋 후 실행

**요청**
> 커밋 해주고 실행해줘

**한 일**
- `#57`(10-responsive)을 단일 커밋으로 커밋
- 웹으로 실행

**변경 파일**
- `docs/prompt-history.md` — 이 항목 (커밋에 `--amend` 로 합침)

**결정 / 메모**
- 레이아웃 수정과 영어·프랑스어 레벨 이름 단축을 한 커밋에 담았다. **이름 단축은 번역 개선이 아니라 레이아웃 수정의 일부**다 — 카드에서 잘리는 것을 고치는 방법으로 카드를 키우는 대신 이름을 줄인 것이라, 떼어내면 왜 지금 이름을 바꾸는지가 설명되지 않는다
- 푸시는 요청에 없어 하지 않았다

---

## 2026-08-05 #59 — UI 디테일 개선 작업 계획서

**요청**
> 좋아 이번에는 UI 전체적으로 디테일한 부분 수정을 하고 싶어.
> 1. 앱 시작되고 스플래쉬정도 있으면 좋겠고. 제목 표시와 애니메이션 효과와 함께 스플래쉬가 몇 초 정도 적당히 떴다가 레벨 화면으로 진입했으면 좋겠어.
> 2. 레벨 화면의 그리드 너무 썰렁해. 앱이 아니라 게임답게 화려하게 개선 되면 좋겠어.
> 3. 레벨 화면에서 기존 다국어 설정버튼을 톱니파퀴 버튼으로 교체하고 그걸 누르면 다이얼로그 띄워서 다국어선택가능하게 하면 좋겠어. 해당 다이얼로그 외에 레벨 초기화, 버전표시 기능도 있어야해.
> 4. 게임 진행화면에서도 플레이어 플록이랑 도착지 블럭이 색깔이 같았으면 좋겠어. 내가 어디를 가야하는지 명확해지잖아? 아침에 파란색계열로 바꾸자(기존 블럭 색깔은 유지해)
> 5. 게임 진행화면에서 구멍에 떨어질때 그냥 작아지고 레벨 실패가 뜨고 끝나잖아. 구멍 대신 블랙홀이라는 명칭으로 표시되면 좋겠고. (…) 지속적으로 살살 회전하는 애니메이션이 (…) 2초 정도 보여주다가 실패 다이얼로그 띄우면 좋겠다.
> 6. 레벨 실패, 성공 다이얼로그가 너무 허전해. (…) 딱 글자와 별,버튼 들이 차지하는 요소들만 다이얼로그로 감싸게.
> 지금tasks에 이 내용들을 토대로 작업계획서를 작성해저 정리해주면 좋겠어. 코딩작업은 이따가 지시할게. 문서화만 먼저 해.

**한 일**
- 착수 전 3가지를 물어 확정 — 그리드 방향(카드 화려하게 **+** 미니 보드 미리보기), 블랙홀 명칭 범위(규칙서·코드까지 전부), 2초 연출 대상(플레이어만)
- 손댈 지점을 코드에서 먼저 확인 — `BoardColors` · `FloorType` · `board_painter` 의 구멍 렌더링 · 라우터 · `clearAll` · `pubspec` 버전
- `docs/tasks/12-ui-polish.md` 신설, 현황표에 12번 추가

**변경 파일**
- `docs/tasks/12-ui-polish.md` (신규)
- `docs/tasks/README.md`
- `docs/prompt-history.md`

**결정 / 메모**
- **계획서만 썼다.** 요청이 명시적으로 "코딩작업은 이따가, 문서화만 먼저" 였다
- **미니 보드 미리보기가 `#22` 의 순환을 되살릴 뻔했다.** 판은 `game` 이 갖고 레벨 선택은 `level` 에 있어서, 카드가 판을 그리려면 `level → game` 이 필요한데 `game → level` 이 이미 있다. **`Level` 에 판을 도로 넣는 것이 애초에 `#22` 의 원인이었으므로 그 길은 막혀 있다**
  - 우회로: 미리보기 위젯을 `level` 이 만들지 않고 **`Widget Function(BuildContext, int, bool)` 로 받는다.** 조립은 **라우터**가 한다 — 원래 모든 feature 를 아는 유일한 자리다. `level` 에는 순수 Flutter 타입만 노출된다
  - 이 순환을 착수 후에 만났으면 이미 카드를 다 짜 놓은 뒤였을 것이다. 계획 단계에서 걸린 것이 이번 문서의 가장 큰 값이다
- **진행도 초기화도 같은 함정이 있다.** 지울 것이 `progress`(진행도)와 `level`(튜토리얼 기록) 양쪽에 있어 `settings` 가 둘을 알면 `level → settings → level` 이다. **다이얼로그는 결과만 돌려주고 실행은 `LevelSelectRoot` 가** 한다 — 새 간선이 생기지 않는다
- **초기화가 튜토리얼 기록도 지운다.** 진행도만 지우면 레벨 1을 다시 깨도 안내가 안 떠서 "처음부터" 가 아니다. **언어는 안 지운다** — 진행도가 아니라 취향이고, `09` 에서 접두사를 가른 이유가 이것이다
- **플레이어와 목표를 같은 색으로 하면 겹쳤을 때 목표가 사라져 보인다.** 클리어 조건이 "목표 위에 선다" 라 반드시 겹친다. → **목표는 채운 도형이 아니라 링으로** 그린다. 색만으로 구분하지 않아 색약 사용자에게도 성립한다
- **블랙홀 회전이 이 프로젝트의 첫 `AnimationController` 다.** 끝나지 않는 애니메이션이라 암시적으로는 표현할 수 없다(`06` 이 정한 방식의 예외). 대신 **페인터를 둘로 나눠** 바닥·격자·벽은 정적으로 두고 블랙홀만 매 프레임 다시 그린다. 블랙홀 없는 레벨에서는 컨트롤러를 돌리지 않는다
- **맵 기호 `X` 는 안 바꾼다.** 7개 맵 · 기획서 §9 표기법 · 파서 테스트가 전부 이 글자에 걸려 있는데 바꿔서 얻는 것이 없다
- **버전은 `package_info_plus` 없이 상수 + 일치 테스트.** 의존성을 아끼자는 게 아니라 **틀어질 수 있는 값을 테스트가 붙잡을 수 있는 형태로 두자**는 것이다. 상수만 두면 언젠가 어긋나고 그때는 아무도 모른다
- **네이티브 런치 스크린과 웹 초기 흰 화면은 범위 밖으로 명시했다.** 인앱 스플래시와 다른 문제이고, 전자는 플랫폼 파일 6벌, 후자는 `index.html` 문제다
- **결과 표시는 여전히 `showDialog` 가 아니다.** Screen 이 Riverpod 도 `showDialog` 도 모른다는 `04` 의 결정은 유지하고, **다이얼로그처럼 보이는 레이어**로 만든다
- **작업 순서를 9단계로 못박고 근거를 적었다.** 특히 이름 변경(기획서 → 코드)과 색 팔레트 → 블랙홀 렌더링 → 빨려듦 연출의 순서는 뒤집으면 중간 상태가 깨진다

---

## 2026-08-05 #60 — 튜토리얼 오버레이도 카드로 · 계획서 커밋

**요청**
> 튜토리얼도 같은 카드로 감싸줘. 그리고 커밋까지만 먼저 진행해주렴

**한 일**
- `12-ui-polish.md` §6을 "결과 · 튜토리얼 다이얼로그" 로 넓히고, 공통 위젯 `OverlayCard` 를 두는 것으로 정리
- 해당 열린 질문을 목록에서 제거하고 완료 기준 · 테스트 표 · 작업 순서에 반영
- `#59`(계획서)와 함께 단일 커밋

**변경 파일**
- `docs/tasks/12-ui-polish.md` — §6 확장, 열린 질문 1건 해소
- `docs/tasks/README.md`, `docs/prompt-history.md`

**결정 / 메모**
- **두 오버레이를 각자 카드로 만들지 않고 `OverlayCard` 하나를 공유하게 했다.** 스크림 · 카드 · 등장 연출 · `maxWidth` 가 두 곳에 흩어지면 한쪽만 손댔을 때 조용히 어긋난다. 테스트에도 "둘이 같은 `OverlayCard` 를 쓴다" 를 넣었다
- **튜토리얼의 두 가지 성질은 그대로 지킨다** — 레이아웃을 차지하지 않는 것(기획서 §6.1)과 보드가 뒤에 비치는 것. 카드로 감싸도 둘 다 유지되므로 기획서는 고칠 것이 없다
- 코드는 여전히 손대지 않았다. 요청이 "커밋까지만" 이었다

---

## 2026-08-06 #61 — 12-ui-polish 1~2단계: 구멍 → 블랙홀

**요청**
> 끊어서 가자. 1~2단계부터 진행해줘

**한 일**
- **기획서를 먼저** 고쳤다 — `docs/game-design.md` 의 `구멍` 22곳을 `블랙홀` 로, 맵 기호 `X` 는 그대로라는 단서를 §2.2 에 추가, §7 에 플레이어와 일반 블록의 연출 시간이 다르다는 내용 추가
- 코드 식별자 치환 — `FloorType.hole` → `blackHole`, `MoveResult.fellIntoHole` → `fellIntoBlackHole`, `BoardColors.hole` → `blackHole`, `holePaint` → `blackHolePaint`
- 한국어 주석·문구 54건 치환, 5개 언어의 결과 문구 · 레벨 5 이름 · 레벨 5 안내 갱신
- `README.md` · `docs/architecture.md` 현행화
- 반응형 테스트에 **오버레이 상태(클리어 · 블랙홀 · 튜토리얼) × 5개 언어**를 추가 (318 → 321)

**변경 파일**
- `docs/game-design.md` (먼저), `README.md`, `docs/architecture.md`
- `lib/feature/game/domain/entity/cell.dart` · `move_result.dart` · `apply_move_usecase.dart`
- `lib/core/theme/board_colors.dart`, `lib/feature/game/presentation/game_play/widget/board_painter.dart` 외 화면 파일들
- `lib/core/i18n/app_strings.dart` + 언어별 5파일
- `test/**` 치환, `test/responsive_test.dart` 확장

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 321/321 통과
- 새 오버레이 테스트가 **실패할 수 있는지 확인**했다 — 문구를 아주 길게 만들면 `overflowed by 1624 pixels` 로 걸린다

**결정 / 메모**
- **일괄 치환이 비유적 "구멍" 두 곳을 잘못 바꿨다.** `strings_parity_test` 의 "컴파일 검사가 없는 유일한 구멍"(= 검사의 빈틈)과 `map_parser_test` 의 "윗변에 구멍이 뚫려 있다"(= 외곽이 열림)는 블랙홀과 무관하다. 되돌렸다. **기계적 치환이라고 해서 결과를 안 읽으면 안 된다**
- 조사도 하나 깨졌다 — `구멍으로` → `블랙홀으로`. `블랙홀로` 로 고쳤다
- **`completed/` 문서의 `구멍` 은 그대로 뒀다.** 그때의 기록이고, `#22` 정정 때도 과거 문서를 다시 쓰지 않고 정정 절을 더하는 방식을 썼다
- **레벨 5 이름을 언어마다 짧게 유지했다** — `Black Hole` · `ブラックホール` · `避开黑洞` · `Trou noir`. `10-responsive` 에서 정한 카드 라벨 길이 예산이 있고 잘림 테스트가 지킨다
- **오버레이를 반응형 검사에 넣었다.** 결과 문구가 길어졌는데(`Aspiré par un trou noir`) 기존 테스트는 오버레이가 뜬 상태를 그리지 않아 사각지대였다
  - 다만 **처음 기대와 달랐다.** 문구를 두 배로 늘리는 교란으로는 실패하지 않았는데, 오버레이 문구가 줄바꿈되기 때문이다. 테스트가 아예 못 잡는 것이 아닌지 확인하려고 훨씬 길게 만들어 보니 세로로 넘쳐 실패했다. **"통과했으니 됐다" 로 넘어가지 않고 그 테스트가 실패할 수 있는지를 확인한** 경우다. 주석도 실제 성질에 맞게 고쳤다
- 3~9단계는 손대지 않았다. 색 팔레트부터가 다음이다

---

## 2026-08-06 #62 — 1~2단계 커밋

**요청**
> 커밋하고 3~6단계 진행해줘

**한 일**
- `#61`(구멍 → 블랙홀)을 단일 커밋으로 커밋하고, 이어서 3~6단계 착수

**변경 파일**
- `docs/prompt-history.md` — 이 항목 (커밋에 `--amend` 로 합침)

**결정 / 메모**
- 이름 변경은 기획서·코드·문구·테스트가 한 덩어리라 쪼갤 수 없다. 중간 어디를 잘라도 이름이 갈린 상태가 남는다

---

## 2026-08-06 #63 — 12-ui-polish 3~6단계: 색 · 블랙홀 · 흡입 · 오버레이 카드

**요청**
> 커밋하고 3~6단계 진행해줘

**한 일**
- **3단계 색 팔레트** — 플레이어·목표를 파란 계열로 통일(`0xFF2E63E8` / `0xFF7BA5F5`), 일반 블록은 그대로. 목표는 원래도 링이라 색만 바뀌었다
- **4단계 블랙홀 렌더링** — `BlackHolePainter` 신설. 방사형 그라데이션 + 나선 팔 2개, 6초에 한 바퀴
- `BoardView` 를 `StatefulWidget` 으로 바꾸고 **이 프로젝트의 첫 `AnimationController`** 를 들였다
- **5단계 흡입 연출** — 플레이어만 2초, 블랙홀과 같은 각속도로 회전하며 축소
- **6단계 `OverlayCard`** — 결과와 튜토리얼이 같은 카드를 쓴다
- 테스트 22건 추가 (321 → 343)

**변경 파일**
- `lib/core/theme/board_colors.dart`, `lib/core/config/app_constants.dart`
- `lib/feature/game/presentation/game_play/widget/black_hole_painter.dart` · `overlay_card.dart` (신규)
- `board_painter.dart`(블랙홀 제거) · `board_view.dart`(전면 개편) · `result_overlay.dart` · `tutorial_overlay.dart`
- `game_play_screen.dart` — `_animationSpan()`
- `test/core/board_colors_test.dart` · `test/feature/game/presentation/black_hole_test.dart` · `overlay_card_test.dart` (신규), 기존 2건 수정

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 343/343 통과
- **교란 4종 확인** — ① 블랙홀 없는 판에서도 회전 ② 플레이어 회전 끊기 ③ 흡입을 짧게 ④ 목표를 플레이어와 같은 명도로, 각각 해당 테스트가 실패

**결정 / 메모**
- **색상만으로는 셋이 안 갈린다.** 팔레트를 짜고 HSL 로 재보니 플레이어·목표·일반 블록의 **색상(hue)이 셋 다 218~223°** 로 거의 같았다. 실제 구분자는 **채도**다 — 일반 블록은 0.26, 플레이어는 0.80. 그래서 테스트를 "색상이 같다"만이 아니라 **"채도가 뚜렷이 높다"** 까지 검사하게 했다. 색상만 봤으면 통과하는 무의미한 테스트가 될 뻔했다
- **팔레트 테스트는 값이 아니라 관계를 검사한다.** 색값을 박아 두면 색을 조금만 손봐도 깨져서 아무도 안 읽게 된다. 예외는 "일반 블록 색은 그대로" 하나인데, 그건 사용자가 명시한 제약이라 값으로 고정하는 것이 맞다
- **`RotationTransition` 을 빠질 때만 씌우면 축소가 재생되지 않는다.** 위젯이 트리에 새로 끼어들면 그 아래 `AnimatedScale` 이 새로 생겨 시작값부터 그려진다 — `06` 에서 이미 겪은 함정이라 늘 씌워 두고 **물리는 애니메이션만 바꿨다**(`AlwaysStoppedAnimation(0)` ↔ 컨트롤러)
- **페인터를 나눈 이유는 성능만이 아니다.** 한 페인터에 두면 회전 한 프레임마다 격자·벽까지 다시 그려진다. 나눠 두니 블랙홀 레이어에 `RepaintBoundary` 를 씌우는 것도 자연스러웠다
- **블랙홀이 없는 판에서는 컨트롤러를 아예 안 돌린다.** 배터리 때문이기도 하지만 **도는 컨트롤러가 있으면 `pumpAndSettle` 이 영원히 끝나지 않는다.** 지금 `pumpAndSettle` 을 쓰는 테스트가 전부 레벨 1(블랙홀 없음)이라 통과하고 있을 뿐이라, 그 사실을 코드 주석에 남겼다
- **기존 테스트 2건이 깨진 것은 의도한 동작 변경 때문이었다.** 둘 다 플레이어가 빠지는 경우를 짧은 타이밍으로 재고 있었다. **테스트를 새 규칙에 맞추되 두 경우를 다 덮도록** 갈랐다 — 일반 블록 0.12초, 플레이어 2초
- **결과 오버레이의 배경을 `surface` 반투명에서 `scrim` 으로 바꿨다.** 원래는 화면 전체를 표면색으로 덮고 그 위에 글자를 얹어서, 뒤 판과 글자가 섞여 읽히지 않았다 — 사용자가 지적한 그대로다
- **`OverlayCard` 안에 `SingleChildScrollView` 를 넣었다.** 글꼴을 키우면 카드가 화면보다 커질 수 있는데, 잘라내면 `10-responsive` 에서 정한 "글자를 자르지 않는다" 를 어긴다
- 7~9단계(설정 다이얼로그 · 레벨 그리드 · 스플래시)는 손대지 않았다

---

## 2026-08-06 #64 — 3~6단계 커밋

**요청**
> 너무 좋다. 커밋하고. 다음 작업.

**한 일**
- `#63`(3~6단계)을 단일 커밋으로 커밋하고 7~9단계 착수

**변경 파일**
- `docs/prompt-history.md` — 이 항목 (커밋에 `--amend` 로 합침)

**결정 / 메모**
- 색 · 블랙홀 · 흡입 · 오버레이를 한 커밋에 담았다. 색을 정해야 블랙홀을 그릴 수 있고, 블랙홀이 돌아야 흡입의 각속도를 맞출 수 있고, 흡입이 끝나야 결과 카드가 뜬다 — 계획서에 적은 순서 그대로 서로의 전제다
- **육안 확인은 아직 못 받았다.** 블랙홀이 실제로 블랙홀처럼 보이는지, 회전이 어지럽지 않은지, 2초가 길지 않은지는 사용자만 판단할 수 있다. 레벨 5가 첫 블랙홀 레벨이다

---

## 2026-08-06 #65 — 12-ui-polish 7~9단계: 설정 · 그리드 · 스플래시

**요청**
> 너무 좋다. 커밋하고. 다음 작업.

**한 일**
- **7단계 설정 다이얼로그** — 톱니바퀴 → 언어 · 진행도 초기화 · 버전. `TutorialRepository.clearAll` 과 `ResetProgressUsecase` 신설
- **8단계 레벨 그리드** — `BoardPreview`(game 소유) + `BoardPreviewPainter` 신설, 카드에 미니 보드 · 별점 테두리
- **9단계 스플래시** — `splash` feature 신설, `/` 라우트, 1.8초 뒤 또는 탭하면 `go`
- 5개 언어에 설정 문구 6개 추가, `AppConstants.appVersion`
- 테스트 17건 추가 (343 → 360)

**변경 파일**
- `lib/feature/level/**` — `clearAll` · `ResetProgressUsecase` · 카드 개편 · 이벤트/Notifier/Root
- `lib/feature/settings/presentation/settings/settings_dialog.dart` (신규)
- `lib/feature/game/presentation/board_preview/board_preview.dart` · `widget/board_preview_painter.dart` (신규)
- `lib/feature/splash/**` (신규 2), `lib/core/router/**`, `lib/core/config/app_constants.dart`, `lib/core/i18n/**`
- `test/feature/level/no_game_dependency_test.dart` · `board_preview_test.dart` · `test/feature/settings/reset_progress_test.dart` (신규), 기존 2건 수정
- `docs/tasks/completed/12-ui-polish.md`, `docs/tasks/README.md`, `docs/architecture.md`, `README.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 360/360 통과
- **교란 5종 확인** — ① `level` 이 `game` import ② 초기화가 튜토리얼 미삭제 ③ 버전 상수 불일치 ④ 라우터가 실루엣 미전달 ⑤ 스플래시를 `push` 로

**결정 / 메모**
- **계획서가 가장 값을 한 곳은 순환 경고 두 개다.** 미니 보드(§2)와 초기화(§3) 둘 다 **코드를 짜기 전에** 걸렸고 우회로도 이미 적혀 있었다. 미니 보드를 먼저 만들었다면 카드를 다 짠 뒤에 `level → game` 을 발견했을 것이다. 그래서 **순환 금지를 소스 스캔 테스트로 못박았다** — 문서에 적어두는 것만으로는 네 번째가 온다
- **`BoardPainter` 를 재사용하지 않고 `BoardPreviewPainter` 를 새로 만들었다.** 계획서는 재사용을 적었지만, 본체는 블록을 안 그리고(위젯이 얹힌다) 블랙홀도 회전 레이어에 맡긴다. 미리보기는 그 둘이 다 필요하면서 아무것도 안 움직인다. 조건을 붙여 합치면 양쪽 다 읽기 어려워진다
- **카드 테두리를 금·은·동 대신 테마 색에서 뽑았다.** 열린 질문이던 "다크 테마에서 금색이 탁해진다" 를 **색을 고정하지 않는 것**으로 해소했다
- **초기화 실행을 Root 가 아니라 Notifier 에 뒀다.** 계획서는 Root 라고 적었지만, 저장소를 건드리고 화면을 다시 읽는 것은 Notifier 의 일이다(§5). Root 는 다이얼로그만 띄우고 `ProgressResetConfirmed` 를 올린다 — 계획의 의도(`settings` 가 아무것도 모르게)는 그대로 지켜진다
- **`AppStringsScope` 는 `MaterialApp` 위에 있어야 한다.** 테스트를 짜다 `home` 아래에 뒀더니 다이얼로그가 `context.strings` 를 못 찾았다 — 다이얼로그는 앱 오버레이에 뜨기 때문이다. `main.dart` 는 원래 맞게 돼 있었고, 테스트에 그 이유를 적었다
- **실루엣 테스트가 실패할 수 없는 상태였다.** `previewBuilder` 를 직접 넣어 라우터를 **흉내 내고** 있어서, 라우터 배선을 망가뜨려도 통과했다. **진짜 라우터를 태우는 테스트를 따로 추가**하고 나서야 교란이 잡혔다. 흉내 낸 배선을 검사하는 테스트는 배선을 검사하지 않는다
- **스플래시는 `push` 가 아니라 `go` 다.** 뒤로가기로 스플래시에 돌아오면 안 된다. `router.canPop()` 이 거짓인지로 검사한다
- **`splash` feature 에 domain·data 가 없다.** `progress` 에 presentation 이 없는 것과 같은 종류의 생략이다

---

## 2026-08-06 #66 — 7~9단계 커밋

**요청**
> 오케이 커밋 해줘

**한 일**
- `#65`(7~9단계)를 단일 커밋으로 커밋. 이로써 `12-ui-polish` 전체 완료

**변경 파일**
- `docs/prompt-history.md` — 이 항목 (커밋에 `--amend` 로 합침)

**결정 / 메모**
- 설정 · 그리드 · 스플래시는 서로 독립적이라 쪼갤 수 있었지만 합쳤다. 계획서가 한 작업으로 묶은 세 단계이고, **셋을 잇는 것이 순환 금지 스캔 테스트** 라 따로 떼면 그 테스트가 어느 커밋에 속하는지 애매해진다
- **`docs/tasks/` 가 다시 비었다.** 다음 요청은 목록에서 고르는 것이 아니다

---

## 2026-08-06 #67 — 게임다운 손맛 작업 계획서 (모양은 만들어 보고 골랐다)

**요청**
> 좋은데 수정할거 조금더 짚어줄게 (7가지 — 스플래시 속도 / 카드 모양 / 버튼 모양 / 다이얼로그 튕김 / 별 하나씩 / 튜토리얼 데모 / 막힌 블록 쫀득거림)
> tasks에 계획서 작성부터 해줘. 바로 작업 진행하지 말고. (…) 애매한 부분은 나한테 꼭 물어봐.
> — 이후: "세 가지 모두 비교해보게 만들어줘", "버튼도 세 개 만들어줘", "네온 좋은데 어두운바탕 말고 다른거 없어(…) 버튼은 각진게 좋다", "각진 네온 형태 좋다"

**한 일**
- 애매한 네 가지를 묻는 대신 **실제로 만들어 보여줬다** — `lib/dev/card_style_gallery.dart` · `button_style_gallery.dart` 와 임시 라우트 `/dev/cards` · `/dev/buttons`
- 1차 카드 3안(판 프레임 · 네온 · 미션 패널) → "네온은 좋은데 어두운 바탕이 테마와 안 맞는다" → **밝은 바탕 네온 3안**으로 다시 그림
- 버튼 4안(지금 · 입체 · 알약 · 각진) 제시 → **각진** 확정
- 남은 두 가지(쫀득 범위 · 데모 재생)는 선택지로 물어 확정
- `docs/tasks/13-game-feel.md` 신설, 현황표에 13번 추가

**변경 파일**
- `lib/dev/**` (신규 2, **임시**), `lib/core/router/route_paths.dart` · `router.dart` (임시 라우트)
- `docs/tasks/13-game-feel.md` (신규), `docs/tasks/README.md`, `docs/prompt-history.md`

**결정 / 메모**
- **"게임스럽게" 를 말로 물어봤을 때 답이 안 나왔다.** 첫 질문 묶음이 반려됐고, 사용자가 "세 가지 모두 만들어달라" 고 했다. **글로 고르게 하는 것보다 만들어 보여주는 편이 빠른 종류의 결정**이 있다 — 시각적 결정은 대체로 그렇다
  - 실제로 1차 네온안은 만들고 나서야 "어두운 바탕이 테마와 안 맞는다" 가 드러났다. ASCII 미리보기로는 절대 안 나왔을 피드백이다
- **임시 코드임을 파일 머리와 라우트 상수, 계획서 9단계에 세 번 적었다.** 비교용 코드는 남으면 제품 코드처럼 보이기 시작한다. **삭제를 완료 기준과 테스트에 넣었다**
- **라우트를 추가하면 핫 리로드로는 안 붙는다.** `router` 가 전역 `final` 이라 이미 만들어진 인스턴스에 새 라우트가 안 들어간다 — 사용자가 "페이지낫파운드" 를 겪고서야 알았다. 재실행으로 해결
- **카드와 버튼을 같은 모양 언어로 묶었다.** 각진 버튼이 정해진 뒤 카드 3안 중 하나를 각진 네온으로 만들어 제시했고 그것이 채택됐다. 어느 하나만 각지면 어긋나 보인다
- **버튼을 `core/widget/` 에 두기로 했다.** `game` · `level` · `settings` 세 feature 가 다 쓰는데 feature 하나에 두면 **모양 때문에 feature 간 간선이 생긴다**
- **쫀득거림은 규칙 문서를 건드린다.** 기획서 §3.2 "무효 입력은 상태를 바꾸지 않는다" 는 유지하되 "화면은 막혔음을 알린다" 를 더한다. 상태에 **방향과 세대 카운터**가 필요하다 — 방향이 없으면 어디로 밀릴지 모르고, 카운터가 없으면 같은 방향 연타에서 재생이 안 된다
- **`isAnimating` 을 세우지 않기로 했다.** 쫀득거리는 중에도 다른 방향은 즉시 받아야 한다
- **별 연출 뒤 버튼을 늦게 *나타나게* 하지 않고 *활성만* 늦춘다.** 나타나게 하면 그때 레이아웃이 밀려 다른 버튼이 흔들린다
- **튜토리얼 데모는 이동 엔진을 태우지 않는다.** 정해진 장면이지 시뮬레이션이 아니다. 반복 재생이라 **두 번째 `AnimationController`** 가 생기고, `pumpAndSettle` 함정도 블랙홀과 같다
- **`hasTutorial`(bool)이 `TutorialDemo?` 로 바뀐다.** 어느 레벨이 무엇을 가르치는지는 여전히 번역이 아니라 데이터다 (`11` 의 판단 유지)
- 코드는 계획서만 쓰고 손대지 않았다 — 요청이 "문서화만 먼저" 였다. `lib/dev/` 는 비교를 위해 만든 것이라 예외이고, 9단계에서 지운다

---

## 2026-08-06 #68 — 13-game-feel 1~3단계: 쫀득 규칙 · 공용 버튼 · 각진 네온 카드

**요청**
> 끊어서 가자. 1~3단계 먼저 진행해줘

**한 일**
- **1단계** — `docs/game-design.md` §3.2·§7에 무효 입력 쫀득거림 규칙을 **코드보다 먼저** 추가
- **2단계** — `lib/core/widget/game_button.dart` · `game_icon_button.dart` 신설, 앱의 Material 버튼 9곳을 전부 교체(AppBar 아이콘 포함)
- **3단계** — `LevelCard` 를 각진 네온으로. `StatelessWidget` → `StatefulWidget`(누름 반응)
- 테스트 9건 추가 (360 → 369)

**변경 파일**
- `docs/game-design.md` (먼저)
- `lib/core/widget/**` (신규 2)
- `result_overlay.dart` · `tutorial_overlay.dart` · `game_hud.dart` · `game_play_screen.dart` · `level_select_screen.dart` · `settings_dialog.dart` · `level_card.dart`
- `test/core/no_material_buttons_test.dart` · `game_button_test.dart` (신규), 기존 2건 수정

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 369/369 통과
- **교란 3종 확인** — ① 버튼 하나를 Material 로 되돌림 ② 비활성인데 눌리게 ③ 모서리를 둥글게

**결정 / 메모**
- **`gameButtonShape()` 를 카드와 버튼이 공유한다.** 같은 모양 언어를 쓴다는 것을 문서가 아니라 **함수 하나로** 만들었다. 따로 두면 한쪽만 바꿨을 때 조용히 어긋난다
- **`ListTile` 은 바꾸지 않았다.** 설정·언어 목록의 **줄**이지 버튼이 아니고, 다섯 줄을 전부 각진 버튼으로 만들면 오히려 무거워진다. 스캔 테스트의 금지 목록에서 뺀 이유를 주석에 적었다
- **테스트 두 개가 버튼 *타입*으로 위젯을 찾고 있었다.** HUD 의 다시하기가 `TextButton.icon`, 결과 오버레이가 `OutlinedButton` 이라 타입만으로 갈렸는데, 둘 다 `GameButton` 이 되면서 같은 문구가 두 개 잡혔다. **오버레이 안으로 좁혀** 원래 재려던 것(오버레이에 다시하기가 있다)으로 되돌렸다
- **스캔 테스트가 `GameIconButton` 을 `IconButton` 으로 오인하지 않게** 앞 글자를 보는 부정 후방탐색(`(?<![A-Za-z])`)을 썼다. 안 그러면 새 위젯이 스스로를 금지한다
- **`lib/dev/` 를 스캔에서 제외하되, 그 제외가 죽은 조항이 아님을 검사한다** — "임시 화면이 아직 있다" 는 테스트를 함께 뒀다. 9단계에서 이 둘을 같이 뒤집는다
- **카드가 `StatefulWidget` 이 됐다.** 누름 반응에 로컬 상태가 필요하다. Screen 이 Riverpod 을 모른다는 규약과는 무관한 위젯 내부 상태다
- **어두운 바탕으로 가지 않았다.** 표면색에 빛을 5%만 섞는다 — 갤러리에서 어두운 네온을 만들어 보고 물러선 결과이며, 그 판단을 코드 주석에 남겼다

---

## 2026-08-06 #69 — 각진 버튼·카드에서 테두리 제거, 채움색으로

**요청**
> 일단 수정할거 있는데, 각진버튼들 있지? 테두리 없애주고. 배경색만 지정해줘. 조금 색깔 있게. 레벨 그리드의 아이템들도 다 테두리 없애고 배경색 채우는 식으로 해주고.

**한 일**
- `gameButtonShape()` 에서 `side` 를 없앴다 — 인자도 사라져 호출부가 단순해졌다
- 보조 버튼 채움색을 `surfaceContainerHighest`(사실상 표면색) → `secondaryContainer` 로, 아이콘 버튼도 같이
- 레벨 카드: 테두리 제거, 채움색을 별 색과 `0.16` 으로 섞어 **별을 많이 딸수록 카드가 그 색으로 진해지게**
- 테스트 2건 추가 (369 → 370)

**변경 파일**
- `lib/core/widget/game_button.dart` · `game_icon_button.dart`
- `lib/feature/level/presentation/level_select/widget/level_card.dart`
- `test/core/game_button_test.dart`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 370/370 통과
- **교란 확인** — 테두리를 되살리면 "모서리가 깎여 있고 테두리는 없다" 가 실패한다

**결정 / 메모**
- **테두리를 없애니 "구분" 을 채움색이 떠맡게 됐다.** 그래서 보조 버튼을 표면색에 두면 안 된다 — 버튼인지 아닌지 읽히지 않는다. `secondaryContainer` 로 옮기고 **"보조 버튼도 표면색과 다른 색을 갖는다"** 를 테스트로 박았다
- **카드의 정보 전달 수단이 테두리 색 → 채움색으로 옮겨갔다.** 별 개수가 여전히 색을 정하되 이제 카드 전체가 물든다. 글로우는 남겼지만 절반으로 줄였다 — 테두리가 없으니 빛이 셀 필요가 없다
- **`gameButtonShape()` 가 인자를 잃었다.** 테두리 색을 받을 이유가 없어졌고, 그만큼 "카드와 버튼이 같은 모양" 이라는 사실이 더 단단해졌다 — 이제 갈릴 여지가 아예 없다
- **테두리 없음을 테스트로 못박았다.** 다음에 조용히 되돌아오면 잡힌다

---

## 2026-08-06 #70 — 레벨 카드를 세 상태 채색으로, 임시 갤러리 삭제

**요청**
> 레벨 그리드의 배경색 너무 연해. 그리고 상태가 세 가지 잖아? 플레이불가, 플레이가능, 클리어됨. 플레이불가는 맵 안보이게 가려줘. 그리고 플레이 가능은 전부 채색으로 해주고. 클리어된건 뒤에 네온효과 없애주고. 채색말 잘하면 될듯해. 컬러스킴 잘 활용해서 수정해

**한 일**
- `_CardState` enum(`locked` · `playable` · `cleared`) 신설, 상태마다 채움색·글자색을 `ColorScheme` 에서 뽑음
- 글로우(그림자) 전부 제거 — 구분은 채움색이 전부 맡는다
- 잠긴 카드는 **미리보기를 아예 만들지 않는다**(자물쇠만). 그 결과 죽은 코드가 된 `isSilhouette` 를 `BoardPreview` · `BoardPreviewPainter` · 라우터에서 걷어냄
- `previewBuilder` 시그니처에서 `isUnlocked` 제거 — 잠긴 레벨에는 부르지 않으므로 받을 이유가 없다
- **임시 갤러리(`lib/dev/`)와 `/dev/*` 라우트를 삭제**하고 스캔 테스트의 제외 조항을 뒤집음
- `board_preview_test` 를 새 규칙으로 다시 씀

**변경 파일**
- `lib/feature/level/presentation/level_select/widget/level_card.dart` · `level_select_screen.dart` · `level_select_root.dart`
- `lib/feature/game/presentation/board_preview/board_preview.dart` · `widget/board_preview_painter.dart`
- `lib/core/router/router.dart` · `route_paths.dart`
- `lib/dev/**` (삭제)
- `test/feature/level/board_preview_test.dart`, `test/core/no_material_buttons_test.dart`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 370/370 통과

**결정 / 메모**
- **`*Container` 색을 쓰지 않고 역할색을 그대로 썼다.** 실제로 찍어 보니 라이트 테마에서 `primaryContainer`(#dbe1ff)와 `secondaryContainer`(#dde1f9)가 **거의 같은 색**이었다. 세 상태를 갈라야 하는데 두 개가 구분이 안 되면 쓸 수 없다. 색을 고르기 전에 **찍어 본 것이 판단을 바꿨다**
  - 잠김 `surfaceContainerHighest`(무채색) / 플레이 가능 `primary` / 클리어 `tertiary`
  - 플레이 가능에 플레이어 색(`primary`)을 준 것은 의도적이다 — 시드가 플레이어 블록 색이라 "여기가 당신 차례" 가 색으로 읽힌다
- **별 개수가 더 이상 색을 정하지 않는다.** 상태가 셋이라고 하셨고, 등급은 별 줄이 이미 보여준다. 색까지 등급을 나타내면 상태와 등급이 한 채널에서 섞인다
- **빈 별을 같은 색의 35% 로 그린다.** 카드가 채색되면서 `outlineVariant` 가 안 보이게 됐다 — 채움색이 바뀌면 그 위의 모든 것이 영향을 받는다
- **`isSilhouette` 를 지운 것은 이번 변경이 만든 고아다.** 판을 가리기로 한 순간 실루엣을 그릴 일이 없어졌다. 시그니처의 `isUnlocked` 도 같이 사라졌다
- **임시 갤러리를 9단계까지 기다리지 않고 지웠다.** `isSilhouette` 제거로 갤러리가 컴파일되지 않게 됐는데, **버릴 코드를 고치는 것은 낭비**다. 카드·버튼 모양이 이미 실제 앱에 들어갔으므로 갤러리의 일은 끝났다. 스캔 테스트의 "임시 화면이 아직 있다" 도 "남아 있지 않다" 로 뒤집었다

---

## 2026-08-06 #71 — 13-game-feel 4단계: 다이얼로그가 튕기듯 등장

**요청**
> 좋다 커밋하고 다음단계

**한 일**
- `#68`·`#69`·`#70`(1~3단계)을 커밋 (`b4a6172`)
- `OverlayCard` 등장을 `0.82 → 1.0`, `elasticOut`, 420ms 로. 스크림도 같은 시간 동안 함께 어두워진다
- 공유 연출을 `lib/core/widget/overlay_transition.dart` 로 분리하고 설정·언어·확인 다이얼로그가 `showGeneralDialog` 로 같은 커브를 타게 함
- 테스트 3건 추가 (370 → 373)

**변경 파일**
- `lib/core/widget/overlay_transition.dart` (신규)
- `lib/feature/game/presentation/game_play/widget/overlay_card.dart` — `StatelessWidget` → `StatefulWidget`
- `lib/feature/settings/presentation/settings/settings_dialog.dart` · `language_picker_dialog.dart`
- `test/feature/game/presentation/overlay_card_test.dart`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 373/373 통과
- **교란 확인** — 곡선을 `easeOut` 으로 바꾸면 "도중에 1을 넘겼다 돌아온다" 가 실패한다

**결정 / 메모**
- **의존성 테스트가 순환을 잡았다.** 처음에 공유 상수·헬퍼를 `overlay_card.dart`(game)에 뒀더니 `settings → game` 이 생겼는데 **`game → level → settings` 가 이미 있어 순환**이었다. `core/widget/` 으로 옮겨 끊었다. `#67` 계획서에서 버튼을 `core` 에 둔 것과 정확히 같은 이유이며, **이번엔 문서가 아니라 테스트가 먼저 알려줬다**
- **`TweenAnimationBuilder` 로는 등장이 재생되지 않았다.** 프레임을 찍어 보니 첫 프레임에 이미 끝값이었다. `AnimationController` 로 바꾸니 0에서 시작하는 것이 보장된다 — 이 프로젝트의 세 번째 컨트롤러다
- **테스트가 "첫 프레임은 작다" 를 재려다 실패했다.** 곡선을 찍어 보니 `elasticOut` 은 **t=0.1 에서 이미 1.0** 을 지난다 — 작게 보이는 구간이 40ms 남짓이라 첫 프레임이 그 안에 든다는 보장이 없다. **곡선 자체는 순수 함수로, 튕김은 위젯 프레임으로** 나눠 검사하도록 고쳤다. 틀린 단언을 통과시키지 않고 무엇을 재려 했는지로 되돌아간 경우다
- **`Transform` 을 위치로 찾다가 엉뚱한 것을 잡았다.** 트리에 여럿이라 `.first` 가 카드가 아니었다. `overlayScaleKey` 를 달아 지목하게 했다 — 위젯 내부 구조가 바뀌어도 안 깨진다
- **`showDialog` → `showGeneralDialog`.** 커브를 넘기려면 `transitionBuilder` 가 필요한데 `showDialog` 는 받지 않는다. 배리어 색·닫힘 동작은 기본값과 같게 맞췄다

---

## 2026-08-06 #72 — 13-game-feel 5단계: 별이 하나씩 등장

**요청**
> 커밋하고 5단계 진행해줘

**한 일**
- `#71`(4단계)을 커밋 (`5479cd3`)
- `ResultOverlay` 를 `StatefulWidget` 으로 바꾸고 별을 220ms 간격으로 하나씩 등장시킴(`elasticOut`, 320ms)
- 연출이 끝날 때까지 **다음 레벨 버튼 비활성**. 목록으로·다시하기는 처음부터 활성
- 테스트 5건 추가 (373 → 378)

**변경 파일**
- `lib/feature/game/presentation/game_play/widget/result_overlay.dart`
- `test/feature/game/presentation/overlay_card_test.dart`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 378/378 통과
- **교란 3종** — ① 별을 처음부터 다 보여줌 ② 다음 레벨을 처음부터 활성 ③ 실패 카드에도 지연을 걺

**결정 / 메모**
- **별의 자리는 처음부터 차지하고 배율만 0 → 1 로 간다.** 나올 때마다 줄이 넓어지면 카드가 흔들린다. 버튼을 늦게 *나타나게* 하지 않고 *활성만* 늦춘 것과 같은 이유다
- **빈 별도 같은 리듬으로 등장한다.** 세 칸이 다 채워지는 리듬이 있어야 "3개 중 2개" 가 읽힌다
- **교란 3이 통과해서 코드를 고쳤다.** `_finished` 에 `!isCleared ||` 를 넣어 뒀는데, 그 항을 지워도 어떤 화면도 달라지지 않았다 — **실패 카드에는 그 값이 여는 버튼 자체가 없기** 때문이다. 일어날 수 없는 상황을 처리하는 코드였으므로 걷어내고, 테스트는 실제로 지키는 것("실패 카드에는 별도 지연도 없다")으로 문구를 고쳤다
  - 교란이 통과했을 때 **테스트를 강화하는 것만이 답은 아니다.** 이번엔 코드 쪽이 불필요했다

---

## 2026-08-06 #73 — 13-game-feel 6단계: 튜토리얼 데모

**요청**
> 커밋하고 6단계 진행해줘

**한 일**
- `#72`(5단계)를 커밋 (`4fd3c93`)
- `TutorialDemo` enum 신설(`level` 소유), `Level.hasTutorial`(bool) → `Level.demo`(enum?)
- `TutorialDemoView` 신설(`game` 소유) — 1행 판 위에서 정해진 장면을 2.6초 주기로 반복
- 튜토리얼 오버레이 **문구 위**에 붙임
- 테스트 11건 추가 (378 → 389)

**변경 파일**
- `lib/feature/level/domain/entity/tutorial_demo.dart` (신규) · `level.dart` · `data/level_data.dart`
- `lib/feature/game/presentation/game_play/widget/tutorial_demo_view.dart` (신규) · `tutorial_overlay.dart`
- `lib/feature/game/presentation/game_play/game_play_screen.dart`
- `test/feature/game/presentation/tutorial_demo_test.dart` (신규), `test/widget_test.dart`
- `docs/game-design.md` §6.1

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 389/389 통과
- **교란 2종** — ① 데모가 안 움직이게 ② 동작 줄이기를 무시

**결정 / 메모**
- **이동 엔진을 태우지 않았다.** 데모는 정해진 장면(`_Scene` + `_Actor`)이다. 엔진을 부르면 데모가 규칙의 **예시**가 아니라 규칙의 **두 번째 구현**이 되고, 그때부터 둘이 갈릴 수 있다
- **`hasTutorial`(bool)이 `demo`(enum?)로 바뀌었다.** 있고 없고만으로는 무엇을 그릴지 정할 수 없다. `hasTutorial` 은 `demo != null` 로 남겨 호출부를 건드리지 않았다
- **`TutorialDemo` 는 `level` 이 갖되 그림은 `game` 이 그린다.** enum 에는 판도 좌표도 없고 "무엇을 가르치는가" 라는 이름뿐이다 — 판을 담는 순간 `level → game` 순환이 되살아난다
- **모든 장면이 1행이다.** 규칙 하나만 보여주면 되고, 한 줄이면 카드 안에서 크게 그릴 수 있다
- **계획서가 예고한 `pumpAndSettle` 함정이 그대로 났다.** `widget_test` 의 "레벨 카드를 누르면…" 이 레벨 1의 튜토리얼을 띄우면서 영원히 안 끝났다. `pump` 로 바꾸고 이유를 주석에 남겼다. 블랙홀 회전 때와 같은 함정이라 **미리 적어둔 것이 값을 했다**
- **"쓰이지 않는 데모가 있으면 만들 이유가 없다" 를 테스트로 뒀다.** enum 값과 레벨 데이터가 양방향으로 맞물리는지 본다

---

## 2026-08-06 #74 — 데모 크기·정렬 수정, 카드도 각지게

**요청**
> 다른건 좋은데. 데모 크기가 너무 작아. 왼쪽 위에 붙어있고. 이거 중앙에 맞추고 크기도 키워야해 그리고 카드도 각지게 만들어줘.

**한 일**
- `BoardMetrics.fitWidth` factory 신설 — 폭을 꽉 채우고 높이는 비율대로
- `TutorialDemoView` 에서 `AspectRatio` 제거하고 `fitWidth` 사용
- `gameButtonShape({radius})` 에 인자 부활, `gameCardBevel = 20` 신설
- `OverlayCard` · `SimpleDialog` · `AlertDialog` 를 전부 각진 모양으로
- 테스트 4건 추가 (389 → 393)

**변경 파일**
- `lib/feature/game/presentation/game_play/widget/board_metrics.dart` · `tutorial_demo_view.dart` · `overlay_card.dart`
- `lib/core/widget/game_button.dart`
- `lib/feature/settings/presentation/**` 다이얼로그 2종
- `test/feature/game/presentation/tutorial_demo_test.dart` · `overlay_card_test.dart`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 393/393 통과
- **교란 확인** — `fitWidth` → `fit` 되돌리기, 카드를 둥글게 되돌리기 각각 실패

**결정 / 메모**
- **원인은 `AspectRatio` 였다.** 그것이 높이를 폭÷5 로 묶어 버려서, 짧은 변에 맞추는 `BoardMetrics.fit` 이 그 높이에 눌렸다. 결과가 62px 짜리 판이 240px 상자 왼쪽에 붙은 그림이었다
- **`fitWidth` 를 따로 만들었다.** `fit` 은 6×6 과 8×8 의 외곽을 같게 하려고 짧은 변에 맞추는 것이라 판을 그리는 데는 맞다. **한 줄짜리 데모에는 맞지 않는다** — 조건을 붙여 한 함수로 합치지 않고 이름을 달리했다
- **테스트를 두 번 고쳤고, 두 번 다 "실패할 수 없는 테스트" 였다.**
  1. 처음엔 `TutorialDemoView` 의 **바깥 상자 크기**를 쟀다. 부모가 240 으로 묶어 두므로 안쪽이 아무리 작아도 240 이 나온다 — 교란이 통과했다
  2. 칸 크기로 바꿨더니 여전히 통과했다. **테스트 환경에서 높이가 무제한이라 `fit` 과 `fitWidth` 가 같은 값을 냈기** 때문이다. 실제로 깨졌던 조건은 "높이가 묶인 상자" 였으므로 그 조건으로 다시 짰고, 그제야 교란이 잡혔다
  - 교훈: **교란이 통과하면 테스트가 실제 상황을 재현하고 있는지부터 본다.** 단언을 강화하기 전에 조건이 맞는지 확인해야 한다
- **`gameButtonShape` 가 인자를 되찾았다.** `#69` 에서 테두리 색 인자를 없앤 것과는 다른 종류다 — 색은 갈리면 안 되지만 **깎이는 정도는 면 크기에 따라 달라야 한다.** 큰 카드에 10px 모서리를 쓰면 각진 느낌이 나지 않는다

---

## 2026-08-06 #75 — 13-game-feel 7단계: 막힌 판의 쫀득거림

**요청**
> 커밋하고 7단계 진행해줘

**한 일**
- `#73`·`#74`(6단계)를 커밋 (`1bdd718`)
- `Bump` 값 타입(방향 + 세대) 신설, `GamePlayScreenState.bump` 추가
- 무효 입력이 `bump` 세대를 올리고, `BoardView` 가 판 전체를 셀의 12% 만큼 200ms 동안 밀었다 되돌린다
- 테스트 10건 추가 (393 → 403)

**변경 파일**
- `lib/feature/game/presentation/game_play/game_play_screen_state.dart` — `Bump` · `bump`
- `game_play_screen_notifier.dart` · `game_play_screen.dart` · `widget/board_view.dart`
- `lib/core/config/app_constants.dart` — `bumpDuration` · `bumpDistanceRatio`
- `test/feature/game/presentation/bump_test.dart` (신규)

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 403/403 통과
- **교란 4종** — ① 무효 입력을 그냥 무시 ② 세대 대신 방향만 비교 ③ `isAnimating` 을 세움 ④ 밀리는 거리를 한 칸으로

**결정 / 메모**
- **`AnimatedX` 로는 안 된다.** 같은 방향을 두 번 누르면 목표값이 같아 아무 일도 일어나지 않는다. `AnimationController` 를 `forward(from: 0)` 로 되감아 재생한다 — 이 프로젝트의 다섯 번째 컨트롤러다
- **`isAnimating` 을 세우지 않는다.** 쫀득거림은 연출이지 턴이 아니라, 그 사이에도 다른 방향을 즉시 받아야 한다
- **교란 2가 통과해서 테스트를 보강했다.** 세대 대신 방향만 비교하도록 되돌려도 통과했는데, **세대가 존재하는 바로 그 이유(같은 방향 연타)를 화면 테스트가 안 덮고 있었다.** 상태 쪽에는 있었지만 화면 쪽에 없었다 — 같은 성질이라도 층이 다르면 따로 덮어야 한다
- **레벨 1의 플레이어는 (2,2) 라 처음엔 막힌 방향이 없다.** 테스트가 "위를 누르면 막힌다" 를 전제했다가 실패했고, 먼저 벽에 붙이는 절차를 넣었다. **판을 읽지 않고 지레짐작한 것이 원인이다**
- 밀리는 거리는 셀의 12%다. 한 칸에 가까우면 갈 수 있는 것처럼 보인다 — 그 성질을 테스트로 못박았다

---

## 2026-08-06 #76 — 13-game-feel 8단계: 스플래시를 느리게 · 작업 완료

**요청**
> 커밋하고 8단계 진행해줘

**한 일**
- `#75`(7단계)를 커밋 (`593e311`)
- 블록 슬라이드 0.6 → 1.1초, 제목 페이드인 0.4 → 0.5초, 전체 1.8 → 2.8초
- 블록이 **하나씩 차례로** 도착하게 (앞선 블록이 먼저 — 게임의 처리 순서와 같다)
- 테스트 5건 추가 (403 → 408)
- `13-game-feel` 완료 처리 후 `completed/` 로 이동, `CLAUDE.md` 현행화

**변경 파일**
- `lib/feature/splash/presentation/splash/splash_screen.dart`, `lib/core/config/app_constants.dart`
- `test/feature/splash/splash_screen_test.dart` (신규)
- `docs/tasks/completed/13-game-feel.md`, `docs/tasks/README.md`, `CLAUDE.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 408/408 통과
- **교란 2종** — 시차 제거, 슬라이드를 0.6초로 되돌리기

**결정 / 메모**
- **동시에 멈추던 것이 문제의 절반이었다.** 예전 코드는 시작 위치만 다르고 끝나는 시점이 같아 한 덩어리로 보였다. 지금은 **오른쪽 끝(플레이어)이 먼저 서고 뒤 블록이 차례로 붙는다** — 게임의 처리 순서(기획서 §3.2)와 같아서 연출 자체가 규칙의 요약이 된다
- **속도에는 하한만 뒀다.** 정확한 값은 취향이라 못박으면 손볼 때마다 깨지지만, 조용히 다시 빨라지는 것은 막아야 한다. 나머지 테스트는 `SplashScreen.slide` 를 단위로 삼아 상대적으로 검사한다
- **`13` 이 끝났다.** 아홉 단계를 네 번에 나눠 진행했고 9단계(임시 코드 삭제)만 3단계 직후로 앞당겼다
- **이번 작업의 큰 배움 — 교란이 통과한 다섯 경우의 답이 매번 달랐다.** 코드를 지운 경우, 테스트를 추가한 경우, 테스트가 실제 조건을 재현하지 못한 경우(2회), 같은 성질을 다른 층에서 덮은 경우. **"교란이 통과하면 테스트를 강화한다" 는 규칙이 아니라 "왜 통과했는지 먼저 본다" 가 규칙이다**
- **`06` 의 "암시적 애니메이션만" 규칙이 네 번 깨졌고 매번 이유가 있었다.** 끝나지 않는 반복 · 첫 프레임 보장 · 같은 값으로 재생. `CLAUDE.md` 에 다섯 컨트롤러와 각각의 이유, 그리고 `pumpAndSettle` 함정을 적었다

---

## 2026-08-06 #77 — 8단계 커밋

**요청**
> 커밋해

**한 일**
- `#76`(8단계 · `13-game-feel` 완료)을 커밋

**변경 파일**
- `docs/prompt-history.md` — 이 항목 (커밋에 `--amend` 로 합침)

**결정 / 메모**
- `docs/tasks/` 가 다시 비었다. 다음 요청은 목록에서 고르는 것이 아니다

---

## 2026-08-06 #78 — 다음 레벨은 몸통만 넘어가게

**요청**
> 레벨 선택하고 플레이화면에서 클리어후 다음 레벨로 이동할때 페이지 이동 효과가 발생하는데, 레벨 선택 에서 플레이화면으로 갈땐 머티리얼 페이지 전환효과는 괜찮거든. 근데 다음 레벨로 이동할땐 바디부분만 페이지 이동하듯이 다음레벨로 전환되면 좋겠어. 당연히 손으로 밀어도 페이지 이동은 안돼야하고.

**한 일**
- 라우터의 플레이 페이지 키를 **레벨과 무관하게 고정** (`ValueKey('game-play')`)
- `GamePlayScreen` 이 `didUpdateWidget` 에서 레벨 변경을 보고 **판·HUD 만** 밀어 넘김 (340ms)
- 테스트 8건 추가 (408 → 416), `docs/architecture.md` §13 신설

**변경 파일**
- `lib/core/router/router.dart` — `builder` → `pageBuilder`
- `lib/feature/game/presentation/game_play/game_play_screen.dart`
- `lib/core/config/app_constants.dart` — `levelSlideDuration`
- `test/feature/game/presentation/level_transition_test.dart` (신규)
- `docs/architecture.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 416/416 통과
- **교란 2종** — ① 페이지 키를 레벨별로 되돌리기 ② 몸통 전환 제거

**결정 / 메모**
- **핵심은 페이지 키다.** 키가 레벨마다 다르면 go_router 가 페이지를 갈아끼워 화면 전체가 밀린다. 키를 고정하니 **레벨 선택에서 들어올 때만 페이지가 새로 생겨** 머티리얼 전환이 나고, 다음 레벨은 같은 페이지가 갱신될 뿐이다. 요청의 두 조건이 이 한 줄로 갈린다
- **`AnimatedSwitcher` 를 쓰지 않았다.** 나가는 쪽과 들어오는 쪽에 같은 애니메이션이 걸려서 **한쪽이 반대 방향으로 움직인다.** 이전 몸통을 직접 들고 있다가 두 개를 겹쳐 옮기는 편이 방향이 정확하다
- **`PageView` 를 쓰지 않았다.** 손으로 밀어 레벨을 옮길 수 있으면 판 위의 스와이프가 이동인지 페이지 넘김인지 갈리지 않는다 — 요청의 마지막 문장이 이것이고, 드래그해도 라우트가 그대로인지 테스트로 못박았다
- **`late final AnimationController _x = AnimationController(vsync: this, ...)` 가 65개 테스트를 깨뜨렸다.** 한 번도 쓰이지 않은 채 화면이 사라지면 `dispose` 가 그때 처음 만들면서 이미 떨어져 나간 트리를 뒤진다. `initState` 에서 만들도록 바꿨다 — **`BoardView` 는 `didChangeDependencies` 에서 항상 건드려서 우연히 무사했던 것**이라, 같은 패턴이 남아 있다
- **교란 1이 통과해서 테스트를 보강했다.** 위젯 단위 테스트만으로는 라우팅 절반이 덮이지 않았다. 실제로 레벨 1을 클리어하고 다음 레벨을 눌러, **전환 중 `GamePlayScreen` 이 하나뿐인지**를 보게 했다 — 페이지가 갈렸다면 둘이 된다

---

## 2026-08-06 #79 — 레벨 카드가 순서대로 떠오르게

**요청**
> 레벨화면 처음 왔을때 각 카드들 나타나는거 애니메이션 효과 적용해줘. 순서대로 애니메이션 카드가 표시되게. 위치+투명도

**한 일**
- `LevelSelectScreen` 을 `StatefulWidget` 으로 바꾸고 등장 컨트롤러 하나를 둠
- 카드마다 `Interval` 을 잘라 55ms 간격으로 순서대로, 각 320ms 동안 **아래 28px 에서 떠오르며 투명도 0 → 1**
- 테스트 6건 추가 (416 → 422)

**변경 파일**
- `lib/feature/level/presentation/level_select/level_select_screen.dart`
- `test/feature/level/card_entrance_test.dart` (신규)

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 422/422 통과
- **교란 3종** — ① 시차 제거 ② 위치 이동 제거 ③ 매 빌드마다 재생

**결정 / 메모**
- **연출은 화면이 만들어질 때 한 번만 재생된다.** `initState` 에 두었으므로 플레이하고 돌아오거나 언어를 바꿔도 다시 돌지 않는다 — 매번 돌면 클리어하고 돌아올 때마다 목록이 깜박인다. 이 성질을 교란으로 확인했다
- **`StatelessWidget` 이었던 이유가 사라졌다.** "로컬 상태가 없다" 여서 규약(§5)에서 벗어나 있었는데 컨트롤러가 생기며 원래 모습으로 돌아왔다. 주석도 그렇게 고쳤다
- **`late final ... = AnimationController(...)` 를 쓰지 않았다.** `#78` 에서 65개 테스트를 깨뜨린 그 함정이다 — 이번에는 처음부터 `initState` 에서 만들었다
- **테스트가 트리 모양을 바꿔 스스로를 속일 뻔했다.** "다시 재생되지 않는다" 를 검사하면서 두 번째 pump 의 감싸는 위젯이 달라 `State` 가 새로 만들어졌고, 그래서 연출이 다시 돌았다. **감싸는 모양을 항상 같게 유지**하도록 헬퍼를 고쳤다
- 위치와 투명도를 함께 움직인다 — 투명도만 바꾸면 그냥 켜지는 것처럼 보이고, 위치만 바꾸면 어디서 왔는지가 급하게 읽힌다

---

## 2026-08-06 #80 — 오버레이가 사라질 때도 연출

**요청**
> 커밋하고. 이번엔 튜토리얼이나 결과 다이얼로그 사라질때도 애니메이션 효과 적용해줘

**한 일**
- `#79`(카드 등장)를 커밋 (`3b7f380`), 카드 연출을 살짝 느리게(420ms/80ms)
- `OverlayCard` 에서 등장 컨트롤러를 걷어내 다시 `StatelessWidget` 으로
- 화면이 오버레이를 **하나로 몰아** 들어오고 나가는 것을 함께 관리
- 나갈 때 200ms 동안 줄어들며 사라지고, 그동안 버튼이 눌리지 않는다
- 테스트 5건 추가·이관 (422 → 425)

**변경 파일**
- `lib/core/widget/overlay_transition.dart` — 퇴장 시간·곡선, `overlayStartScale` 공개
- `lib/feature/game/presentation/game_play/widget/overlay_card.dart` · `game_play_screen.dart`
- `test/feature/game/presentation/overlay_card_test.dart`
- `docs/architecture.md` §13

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 425/425 통과
- **교란 3종** — ① 곧바로 없앰 ② 나갈 때도 등장 곡선 ③ 나가는 중 버튼 활성

**결정 / 메모**
- **이 작업에서 헤맨 시간이 대부분 "왜 안 되는지" 를 추측한 데 들어갔다.** 세 번의 잘못된 시도가 있었다
  1. `AnimatedSwitcher` — 퇴장이 **아예 재생되지 않았다.** 프레임을 찍어 확인
  2. 직접 붙잡되 `AnimationStatus` 로 방향을 갈랐다 — 상태가 프레임에 따라 흔들려 등장 곡선이 퇴장에 적용됐다. `elasticOut(0.5) == 1.0` 이라 **배율이 1로 보이는데 투명도만 줄어드는** 기묘한 증상이 났다
  3. 결국 **`CurvedAnimation.reverseCurve`** — 프레임워크가 이미 갖고 있는 것이었다. 손으로 방향을 가르려 한 것이 처음부터 잘못이었다
- **테스트도 두 번 잘못 짚었다.** 렌더된 `Transform`·`Opacity` 를 트리에서 찾다가 연출의 것인지 확신할 수 없었다. **`ScaleTransition.scale.value` 처럼 애니메이션 값을 직접 읽는 편이 명확하다**
- **다 나간 뒤 놓아주려면 통지가 필요하다.** 컨트롤러가 0에 닿아도 다시 그릴 계기가 없어 투명한 카드가 트리에 남았다. `addStatusListener` 로 `dismissed` 를 받아 `setState` 한다
- **`value == 0` 이라고 빼면 안 된다.** 들어오는 첫 프레임도 0이라 나타나는 순간이 한 박자 늦게 잡힌다
- **컨트롤러가 둘이 되면서 `SingleTickerProviderStateMixin` 이 터졌다.** `TickerProviderStateMixin` 으로 바꿨다

---

## 2026-08-06 #81 — 배경은 투명도만, 그리고 연출 차례 맞추기

**요청**
> 다 좋은데 배경 오버레이컬러까지 줄어드네? 내가 원한건 카드만 적용인거고. (…) 완료 다이얼로그 > 다음 > 카드만 사라지기 > 배경도 투명해지며 사라지기(크기는 아님) > 페이지 이동 > 튜토리얼 표시 > 확인클릭 > 카드사라지기 (배경은 투명해지며 사라기지) > 플레이화면

**한 일**
- 배경(스크림)과 카드를 **다른 구간**으로 갈랐다 — `overlayScrimSplit = 0.45`
  - 들어올 때: 배경 먼저 → 카드
  - 나갈 때: 카드 먼저 → 배경
- **배율은 카드에만.** `OverlayCard` 가 `OverlayCardAnimation`(InheritedWidget)으로 진행도를 받아 자기 카드에만 건다
- **다음 레벨은 카드가 다 사라진 뒤에 올라간다** — 화면이 이벤트를 들고 있다가 퇴장 완료 시 올려보낸다
- 등장 520ms · 퇴장 340ms 로 조정, 테스트 4건 추가 (425 → 428)

**변경 파일**
- `lib/core/widget/overlay_transition.dart` — 구간 분리, 스크림·카드 키
- `lib/feature/game/presentation/game_play/widget/overlay_card.dart` — `OverlayCardAnimation`
- `lib/feature/game/presentation/game_play/game_play_screen.dart` — `_closing` · `_afterClose`
- `test/feature/game/presentation/overlay_card_test.dart` · `level_transition_test.dart`
- `docs/architecture.md` §13

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 428/428 통과
- **교란 3종** — ① 배경까지 배율 ② 한 구간으로 합침 ③ 다음 레벨을 곧바로 올려보냄

**결정 / 메모**
- **내가 "카드"와 "카드가 뜬 화면"을 같은 것으로 다뤘던 것이 실수였다.** 스크림과 카드는 한 위젯 안에 있지만 **다르게 움직여야 하는 두 가지**다. 배율을 바깥에 걸면 덮개까지 줄어든다
- **생성자로 진행도를 넘기지 않고 `InheritedWidget` 을 썼다.** 카드를 만드는 것은 `ResultOverlay`·`TutorialOverlay` 인데 연출을 아는 것은 그 위의 화면이라, 두 오버레이가 값을 그저 통과시키기만 하는 인자를 갖게 하고 싶지 않았다. 없으면 "다 떠 있는 것" 으로 쳐서 위젯 단위 테스트는 그대로 산다
- **이벤트를 붙잡았다 보내는 것은 화면의 일이다.** Screen 은 이벤트를 만들지 않고 전달만 하지만 **언제 전달할지**는 연출의 문제이고 그건 화면이 안다
- **`find.byType` 으로는 못 찾는다.** `AnimatedScale`·`AnimatedOpacity` 가 안쪽에서 `ScaleTransition`·`FadeTransition` 을 만들어 트리에 11개·7개가 있었다. 별 연출의 것을 잡고 있었다 — 키를 달아 해결했다. **오늘만 세 번째로 "찾는 방법" 때문에 헤맸다**

---

## 2026-08-06 #82 — 버그: 레벨 3으로 넘어가면 입력이 죽는다

**요청**
> 좀 이상한데? 두 스테이지? 이정도 클리어하고 다음 누르면 아예 입력이 안되버려

**한 일**
- `_syncOverlay` 가 오버레이의 **있고 없음**이 아니라 **종류**(`none`·`tutorial`·`result`)를 비교하도록 고침
- 회귀 테스트 추가 (428 → 429)

**변경 파일**
- `lib/feature/game/presentation/game_play/game_play_screen.dart` — `_hasOverlay` → `_overlayKind`
- `test/feature/game/presentation/overlay_card_test.dart`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 429/429 통과
- **교란 확인** — "있다/없다" 비교로 되돌리면 회귀 테스트가 실패한다

**결정 / 메모**
- **`#81` 에서 내가 넣은 버그다.** 다음 레벨로 갈 때 결과 카드를 닫고(`_closing`) 넘어가는데, 새 레벨에 튜토리얼이 있으면 **결과 → 튜토리얼**로 종류만 바뀐다. 둘 다 "오버레이 있음" 이라 `_syncOverlay` 가 아무것도 하지 않았고, 진행도가 0인 채로 남아 **화면에는 아무것도 없는데 `showsTutorial` 이 참이라 `canMove` 가 거짓**이 됐다. 보이지 않는 오버레이가 입력만 막고 있었던 것
- **레벨 1·2 에서는 안 난다.** 레벨 2는 튜토리얼이 없어 종류가 `none` 으로 바뀌므로 정상 동작한다 — 사용자가 "두 스테이지쯤" 이라고 한 것이 정확히 이 지점이다
- **첫 회귀 테스트는 버그를 재현하지 못했다.** 상태만 갈아끼웠더니 진행도가 1에 머물러 있어 통과해 버렸다. **다음 버튼을 눌러 닫는 경로를 그대로 타야** 진행도가 0으로 내려가 증상이 드러난다. 교란으로 확인하지 않았으면 "고쳤다" 고 잘못 보고했을 것이다
- **화면이 안 보이는 상태를 상태값이 계속 참으로 들고 있으면 입력만 죽는다.** 오버레이를 연출로 감추는 순간부터 "보인다" 와 "막는다" 가 갈릴 수 있다는 것을 놓쳤다

---

## 2026-08-06 #83 — 카드 테두리, 그리고 설정 다이얼로그를 같은 연출로

**요청**
> 다이얼로그 테두리가 있으면 좋겠다. 너무 시커멓게 하지 말고. 어울리게. 그리고 설정 다이얼로그도 애니메이션 적용됐는데, 튜토리얼 다이얼로그랑 뭔가 달라. 자연스럽지 못한 느낌이야

**한 일**
- `gameCardShape(ColorScheme)` 신설 — 각진 모양 + `outlineVariant` 1.5px 테두리. 오버레이 카드와 설정·언어·확인 다이얼로그가 함께 쓴다
- `buildOverlayTransition` 이 `overlayCardAnimation` 을 쓰도록 바꿈 — 판 위 오버레이와 **정확히 같은 구간·곡선**
- 테스트 4건 추가 (429 → 432)

**변경 파일**
- `lib/core/widget/game_button.dart` — `gameCardShape`
- `lib/core/widget/overlay_transition.dart` — 다이얼로그 연출
- `lib/feature/game/presentation/game_play/widget/overlay_card.dart`, `lib/feature/settings/presentation/**` 다이얼로그 3곳
- `test/feature/game/presentation/overlay_card_test.dart`, `test/feature/settings/language_picker_test.dart`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 432/432 통과
- **교란 2종** — ① 테두리 제거 ② 다이얼로그를 예전 방식으로 되돌림

**결정 / 메모**
- **"뭔가 다르다" 의 원인이 셋이었다.** 설정 다이얼로그만 ① 카드가 배경과 **동시에** 떴고 ② 나갈 때도 `elasticOut` 이라 **튕겼으며** ③ 나가는 시간이 등장과 같았다. 앞의 둘을 고쳐 판 위 오버레이와 같은 함수를 쓰게 했다
- **나가는 시간은 못 맞췄다.** `showGeneralDialog` 가 `reverseTransitionDuration` 을 받지 않는다. 곡선과 차례가 맞으므로 눈에 띄지는 않을 것이고, 그 한계를 주석에 적었다
- **버튼과 카드의 모양 함수를 갈랐다.** `#69` 에서 버튼 테두리를 없앤 판단은 그대로다 — 버튼은 채움색만으로 배경과 갈리지만, **카드는 표면색 위에 표면색으로 떠 있어** 윤곽이 없으면 경계가 흐릿하다. 같은 함수에 인자를 붙이지 않고 이름을 갈랐다
- `outlineVariant` 를 쓴 이유: 시커먼 선을 두르면 창틀처럼 무거워진다. 값이 아니라 테마 역할이라 다크에서도 산다

---

## 2026-08-06 #84 — 다이얼로그 엘라스틱을 느리게

**요청**
> 커밋해주고 그 다이얼로그 나타날때 엘러스틱 조금 느리게 해줘 효과가 잘 안보여

**한 일**
- `#83`(테두리·다이얼로그 연출)을 커밋 (`47c9b19`)
- 등장 520 → **700ms**, 배경/카드 분기점 0.45 → **0.32**
  - 등장: 배경 224ms → 카드 476ms
  - 퇴장: 카드 231ms → 배경 109ms
- 테스트 1건 추가 (432 → 433)

**변경 파일**
- `lib/core/widget/overlay_transition.dart`
- `test/feature/game/presentation/overlay_card_test.dart`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 433/433 통과
- **교란 확인** — 예전 값(520ms · 0.45)으로 되돌리면 실패한다

**결정 / 메모**
- **전체 길이만 늘리지 않았다.** 분기점이 0.45 면 늘린 시간의 절반이 배경으로 가서, 카드는 여전히 짧고 **덮개만 늦게 깔려 답답해진다.** 분기점을 앞당겨 **카드에 몫을 몰아줬다** — 520×0.55=286ms 였던 카드 구간이 700×0.68=476ms 가 됐다
- **하한을 테스트로 남겼다.** 정확한 값은 취향이라 못박지 않되, 카드 구간이 400ms 아래로 조용히 내려가는 것은 막는다. 배경이 카드보다 짧아야 한다는 관계도 함께 검사한다 — 그게 "배경 먼저, 카드 나중" 의 실질이다
- 오버레이와 다이얼로그가 같은 상수를 쓰므로 튜토리얼·결과 카드도 함께 느려진다. 그것이 `#83` 에서 하나로 합친 이유다

---

## 2026-08-06 #85 — 레벨 디자인 전면 재설계 (20레벨, 데드락 제거)

**요청**
> 이번에는 맵 종류들 있지? 레벨 디자인. 그거에 대해 깊게 고민을 해봐야할 것 같아 `lib/feature/game/data/map_blueprints.dart` 이제 맵 관련된 개선도 하려해. 첫 맵은 2x4(가로로김)로 구성해주고, 두번째 레벨은 4x4 이렇게 해주는데, 지금 보면 첫 레벨은 한번에 오른쪽으로 안가고 위로 가면 절대로 클리어할 수 없는 데드락이 생기게 돼. 이런 레벨 디자인의 모순이 발생하지 않도록, 문서나 주석 수정해주고. 맵 크기도 레벨에 따라서 점점 커지게 해줘. 블랙홀은 15 레벨부터 나올거라 이 전에서는 빼주고. 레벨도 20 레벨까지 추가를 해준 다음. 크기는 최대 10x10 까지 되게 해주는데, 요소들 잘 활용해서 창의적으로 풀 수 있도록 레벨 디자인 해줘. 당연히 갈 수록 어려워져야겠지.
> 게임의 룰을 너가 최대한 잘 알고있어야해.

**한 일**
- **데드락을 "검사 가능한 성질" 로 만들었다** — `test/feature/game/level_design.dart` 신설.
  초기 판에서 도달 가능한 판을 전부 모은 뒤(전진 BFS), **클리어 판에서 거꾸로** 도달
  가능한 것을 모아(역방향 도달) 차집합을 막다른 판으로 센다. 사용자 지적을 그대로
  재현했다 — **옛 1번은 갈 수 있는 판 9개 중 6개가 막다른 길이었다**
- 같은 파일에 `uselessElements` — 벽·경계 벽·블록·블랙홀을 하나씩 빼 최소 수가 그대로면 장식으로 신고
- 위 둘을 적합도로 삼은 **임시 무작위 생성기**로 20개 맵을 찾고, 생성기는 지웠다
- `kMapBlueprints` 20개로 교체 (1번 2×4 → 20번 10×10), 레벨별 설계 의도를 주석에
- `kLevels` 20개로 교체. `minMoves` 는 손으로 세지 않고 완전 탐색이 낸 값
- 튜토리얼 배정을 다시: 1 미끄러짐 · 3 블록 브레이크 · **5 경계 벽** · **15 블랙홀**
- 5개 언어 레벨 이름 20개씩 (100개) 추가
- **영구 테스트 `level_design_test.dart` 신설** — 레벨마다 ① 풀린다 ② `minMoves` 가 맞다
  ③ 막다른 판이 없다 ④ 모든 요소가 제 몫을 한다, 그리고 전체에 대해 ⑤ 판 크기 단조 증가
  ⑥ 10×10 상한 ⑦ 블랙홀은 15번부터 ⑧ 뒤 10레벨이 앞 10레벨보다 길다
- 기획서 **§4.4 레벨 디자인 원칙** 신설, §2.1(크기)·§9.3(레벨 추가 시) 갱신
- 깨진 기존 테스트 30건 수정 (아래 "결정" 참고). 433 → **504** 통과

**변경 파일**
- `lib/feature/game/data/map_blueprints.dart`, `lib/feature/level/data/level_data.dart`
- `lib/core/i18n/strings_{ko,en,ja,zh,fr}.dart`
- `test/feature/game/level_design.dart` (신규), `test/feature/game/level_design_test.dart` (신규)
- `test/feature/game/presentation/{board_view_layout,bump,game_play_screen_notifier}_test.dart`
- `test/feature/level/{level_select_screen,board_preview,card_entrance}_test.dart`
- `docs/game-design.md`, `CLAUDE.md`, `README.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `fvm flutter test` → 504/504 통과
- **교란 확인** — 옛 1번 맵을 되돌려 넣으면 새 테스트가 실패하며 **막다른 판을 그려서 보여준다**

**결정 / 메모**
- **데드락을 사람이 검토하지 않는다.** 손으로 맵을 그리고 눈으로 확인하는 방식이었으면
  이번에 고친 판이 다음에 또 생긴다. 완전 탐색을 테스트로 박아 **레벨을 추가하는 순간
  자동으로 걸리게** 했다. 실패 메시지에 막다른 판을 ASCII 로 그리는 것도 이 때문이다
- **블랙홀에 빠진 판은 막다른 길로 세지 않는다.** 눈에 보이는 실패이고(§3.5) 화면이
  그렇게 말해 준다. 조용히 끝나 있는 것과는 다른 종류라 같이 세면 블랙홀 레벨을 못 만든다
- **"모든 요소가 제 몫" 을 함께 검사한다.** 사용자가 "요소들 잘 활용해서 창의적으로" 라고
  했는데, 무작위 생성은 그냥 두면 아무 데나 벽을 뿌린다. 빼도 최소 수가 안 변하면
  장식이라는 기준을 넣어야 판이 복잡해 보이기만 하는 것을 막을 수 있었다
- **15번의 최소 수는 5수로, 앞뒤(14·16번은 7수)보다 낮다.** 새 요소를 소개하는 판은
  일부러 짧게 만든다 — 규칙을 보여주는 것이 먼저다. 그래서 난이도 테스트도 매 레벨
  단조 증가가 아니라 **앞 10 / 뒤 10 합** 으로 검사한다
- **깨진 테스트는 대부분 옛 레벨 사실을 박아둔 것들이었다.** 종류가 셋이다
  - 1번이 6×6 정사각이라는 전제 (`board_view_layout_test`) → 정사각 판인 2번을 쓴다
  - "1번 플레이어는 가운데에 있다", "블랙홀은 5번" 같은 좌표 (`bump`·`notifier`) → 새 판에 맞춰 고쳤다
  - **레벨이 20개가 되며 목록이 스크롤된다** → 화면 밖 카드는 만들어지지 않아 개수 단언이
    조용히 어긋난다. 테스트 화면을 세로로 키워 전부 그려지게 했다. 이건 판정 기준이 아니라
    측정 조건 문제라 단언을 느슨하게 하지 않았다
- 프랑스어 12번 이름은 잘림 테스트에 걸려 `Tous les trois` → `Les trois` 로 줄였다.
  **카드를 키우지 않는다** 는 기존 판단(#57)을 그대로 따랐다

---

## 2026-08-06 #86 — 미니 보드에 경계 벽이 안 그려진다

**요청**
> 칸막벽 튜토리얼 이상해 칸막 표시가 안되고 있어

**한 일**
- 원인은 데모가 아니라 **`BoardPreviewPainter` 가 `board.walls` 를 아예 그리지 않는 것**이었다.
  칸 벽(`FloorType.wall`)만 칠하고 경계 벽은 통째로 빠져 있었다
- `BoardPainter`(실제 판)와 같은 방식으로 그리게 했다 — 같은 색·같은 두께, `StrokeCap.butt`
- `test/feature/game/presentation/board_preview_painter_test.dart` 신설 (4건)

**변경 파일**
- `lib/feature/game/presentation/game_play/widget/board_preview_painter.dart`
- `test/feature/game/presentation/board_preview_painter_test.dart` (신규)

**검증**
- `fvm flutter analyze` → `No issues found!` · `fvm flutter test` → 508/508 통과
- **교란 확인** — `_paintEdgeWalls` 호출을 지우면 4건 중 3건이 실패한다

**결정 / 메모**
- **범위가 튜토리얼만이 아니었다.** 같은 페인터를 레벨 카드 미니 보드도 쓰므로,
  경계 벽이 있는 레벨 카드에서도 전부 빠져 있었다. 사용자는 데모에서 발견했지만 고칠 곳은 하나였다
- **이 종류의 버그는 조용하다.** 칸 벽과 달리 경계 벽은 칸을 차지하지 않아서, 안 그려도 판이
  깨져 보이지 않고 그냥 "벽이 없는 판" 으로 보인다. 그래서 테스트에 **대조군**(벽이 없으면
  선도 없다)을 함께 뒀다 — 없으면 "뭐라도 그려졌다" 로 통과한다
- 픽셀 비교 대신 **`drawLine` 명령을 받아 적는 캔버스**를 썼다. 실패했을 때 어디에 무엇을
  그렸는지가 좌표로 나와서 고칠 곳을 바로 안다

---

## 2026-08-06 #87 — 맵 재검토: 여백 제거와 가로/세로 변형

**요청**
> 맵들 한번 더 검토해주고. 불필요하게 넓은건 줄여줘. 종종 가로로 길거나 세로로 긴 맵도 있으면 좋겠어.

**한 일**
- **"불필요하게 넓다" 를 측정했다.** 가장자리 빈 줄을 하나 잘라내고 최소 수가 그대로면 여백이다.
  재보니 **20개 중 10개**가 걸렸다 — 17번은 9×9 인데 요소가 놓인 범위가 4×8 이었다
- `paddedSides` 를 `level_design.dart` 에 추가하고, 생성기의 거부 조건에 넣어 20개를 다시 찾았다
- 크기표를 다시 짰다. **정사각 6 · 가로로 김 8 · 세로로 김 6**, 넓이 8 → 81 (전 100)
- 19번만 최소 수가 6으로 떨어져(18번이 8) 그 하나만 다시 돌려 9수짜리로 바꿨다
- 테스트 3건 추가: 빈 여백 없음(레벨별) · 가로/세로 판이 각각 최소 5개
- 기획서 §4.4 (3) 을 "판은 커지기만 하고, 여백이 없어야 한다" 로 다시 씀
- 맵이 바뀌며 깨진 테스트 17건 수정

**변경 파일**
- `lib/feature/game/data/map_blueprints.dart`, `lib/feature/level/data/level_data.dart`
- `test/feature/game/level_design.dart`, `test/feature/game/level_design_test.dart`
- `test/feature/game/presentation/{bump,game_play_screen_notifier,level_transition}_test.dart`
- `test/feature/level/level_select_screen_notifier_test.dart`
- `docs/game-design.md`, `CLAUDE.md`

**검증**
- `fvm flutter analyze` → `No issues found!` · `fvm flutter test` → 전건 통과

**결정 / 메모**
- **"비어 있음" 이 아니라 "잘라도 안 달라짐" 이 여백이다.** 빈 칸도 미끄러지는 거리를 만들기
  때문에 대개는 잘라내면 판이 달라진다. 단순히 빈 줄을 세면 멀쩡한 판을 여백으로 몰아세운다
- **크기를 줄인 것이 아니라 밀도를 올렸다.** 최대 넓이는 100 → 81 로 조금 줄었지만, 진짜
  변화는 판의 모든 줄이 퍼즐에 쓰이게 된 것이다. 넓이는 어려움이 아니다
- **가로/세로 변형은 "커지기만 한다" 와 충돌하지 않게 짰다.** 넓이 기준으로는 단조 증가하되
  변의 비를 바꾼다 — 9×6 다음에 6×10 같은 식이다. 그래서 §4.4 (3) 의 문장을 넓이 기준으로
  다시 썼다. 한 변의 상한만 10 으로 남긴다
- **맵을 손으로 그리지 않는다는 것을 기획서에 명시했다.** 네 가지 검사를 동시에 만족하는 배치를
  눈으로 찾는 것은 사실상 불가능하다. 무작위로 만들어 검사를 통과한 것만 남기고, 그 판을 다시
  테스트가 지킨다. 다음 세션이 손으로 맵을 그리려다 시간을 버리지 않도록 적어 둔다
- 레벨 사실을 박아둔 테스트가 **두 번 연속 깨졌다**(#85, #87). 1번의 클리어 방향, 2번의
  플레이어 좌표, 블랙홀 레벨 번호 같은 것들이다. 맵을 바꿀 때마다 깨지는 것은 사실 정상이다 —
  그 테스트들이 검사하는 것은 맵이 아니라 노티파이어의 동작이고, 판을 태워야만 검사할 수 있다

---

## 2026-08-06 #88 — 1번 맵 좌우 반전 되돌리기

**요청**
> 1스테이지 좌우 반전됐는데 다시 바꿔주고 커밋해줘

**한 일**
- 1번 맵을 `|G . . @|` → `|@ . . G|` 로 되돌렸다. 플레이어가 왼쪽, 목표가 오른쪽이다
- 1번을 태우는 테스트의 방향을 함께 뒤집었다 (클리어는 오른쪽, 막힌 방향은 위·왼쪽)
- `#86`·`#87`·이 요청을 한 커밋으로 묶었다

**변경 파일**
- `lib/feature/game/data/map_blueprints.dart`
- `test/feature/game/presentation/{bump,game_play_screen_notifier,level_transition}_test.dart`
- `test/feature/level/level_select_screen_notifier_test.dart`

**검증**
- `fvm flutter analyze` → `No issues found!` · `fvm flutter test` → 529/529 통과

**결정 / 메모**
- **무작위 생성기는 좌우를 신경 쓰지 않는다.** `#87` 에서 판을 다시 찾을 때 1번도 새로 뽑혔고,
  검사 기준(막다른 판 없음 · 여백 없음 · 최소 1수)으로는 좌우 반전이 완전히 동등해서 그대로
  통과했다. **첫 판이 왼쪽에서 오른쪽으로 흐르는 것은 검사할 수 없는 종류의 결정**이다 —
  읽는 방향과 같아야 자연스럽다는 것은 사람만 안다. 규칙으로 박지 않고 여기 적어 둔다
- 앞으로 맵을 다시 생성하면 1번은 또 뒤집힐 수 있다. 그때 이 항목을 보고 되돌리면 된다

---

## 2026-08-06 #89 — 1번 맵을 사용자가 직접 수정

**요청**
> 내가 조금 수정했고 커밋해줘

**한 일**
- 사용자가 1번 목표를 오른쪽 위(0,3) → **오른쪽 아래(1,3)** 로 옮겼다. 최소 수가 1 → **2** 가 된다
- `kLevels` 의 `minMoves` 와 맵 주석을 2수로 맞췄다
- 1번을 클리어시키는 테스트를 두 수(→ 다음 ↓)로 고쳤다
- 설계 테스트의 `첫 레벨은 한 수로 깨진다` 를 **`두 수 안에`** 로 완화

**변경 파일**
- `lib/feature/game/data/map_blueprints.dart`, `lib/feature/level/data/level_data.dart`
- `test/feature/game/level_design_test.dart`
- `test/feature/game/presentation/{game_play_screen_notifier,level_transition}_test.dart`
- `test/feature/level/{level_select_screen,level_select_screen_notifier}_test.dart`

**검증**
- `fvm flutter analyze` → `No issues found!` · `fvm flutter test` → 529/529 통과

**결정 / 메모**
- **더 나은 첫 판이다.** 목표가 같은 줄에 있으면 첫 수가 "오른쪽" 하나뿐이라 사실상 정답이
  하나인 안내였는데, 반대편 모서리로 옮기니 **가로와 세로를 한 번씩** 써야 한다. 미끄러짐이
  두 축 모두에서 일어난다는 것을 첫 판에서 보여준다. 네 모서리가 서로 오갈 수 있어 막다른
  판이 없다는 성질은 그대로다
- **최소 수를 못박지 않고 상한만 뒀다.** `첫 레벨은 한 수` 는 설계자의 선택을 테스트가 대신
  결정하고 있었다. 정작 지켜야 하는 것은 "첫 판이 길면 규칙을 익히기 전에 헤맨다" 쪽이라
  `≤ 2` 로 바꿨다
- **레벨 선택 화면 테스트 하나는 진짜 실패가 아니었다.** 1번의 최소 수가 2가 되면서 2번과
  같아졌고, 화면 전체에서 "최소 2수" 를 찾던 단언이 **2번 카드**에 걸렸다. 1번 카드 안으로
  범위를 좁혔다 — 이런 단언은 카드가 늘어날수록 조용히 엉뚱한 것을 잡는다

---

## 2026-08-06 #90 — 엔터·스페이스로 다음 레벨

**요청**
> 다음 스테이지로 넘어가는거 버튼 말고도 엔터나 스페이스로도 갈 수 있게 해줘

**한 일**
- `_onKeyEvent` 에 확인 키(Enter · NumpadEnter · Space)를 붙였다
- **결과 카드만이 아니라 지금 떠 있는 카드의 주 동작**을 누른다 — 결과면 다음 레벨,
  튜토리얼이면 닫기
- 마지막 레벨(다음이 없는 결과 카드)과 판 위에서는 아무 일도 하지 않는다
- 테스트 6건 추가 (529 → 535)

**변경 파일**
- `lib/feature/game/presentation/game_play/game_play_screen.dart`
- `test/feature/game/presentation/game_play_input_test.dart`

**검증**
- `fvm flutter analyze` → `No issues found!` · `fvm flutter test` → 535/535 통과
- **교란 확인** — 확인 키 분기를 지우면 3건이 실패한다

**결정 / 메모**
- **결과 카드만 이으면 반쪽이다.** 다음 레벨에 튜토리얼이 있으면 곧바로 떠서 다시 마우스로
  손이 간다. 요청은 "다음 스테이지로 넘어가는 것" 이고, 튜토리얼을 지나야 그 스테이지에
  들어간 것이다. 그래서 **카드마다 하나씩 있는 확인 버튼**을 누르는 것으로 정의했다
- **마지막 레벨에서는 아무 일도 하지 않는다.** 거기 남은 버튼은 "레벨 선택으로" 뿐인데,
  확인 키로 화면을 나가버리면 되돌릴 수 없는 이동이 손가락에 걸린다
- **확인 키도 `handled` 로 삼킨다.** 스페이스를 흘려보내면 Flutter 기본 "버튼 누르기" 로
  새어나가 포커스가 떠나고, 그 뒤로 방향키가 죽는다 — 방향키에서 이미 겪은 문제다.
  그것을 검사하는 테스트를 같이 뒀다
- 버튼과 같은 경로를 탄다. 확인 키로 넘어가도 **카드 사라짐 → 배경 걷힘 → 페이지 이동**
  순서가 그대로다(`#82` 의 그 차례). 테스트도 곧바로 이벤트가 나가지 않는 것을 함께 본다

---

## 2026-08-06 #91 — 웹에서 설정·진행도가 매번 초기화된다

**요청**
> 개발모드라서 그런진 모르겠는데. 다국어랑 레벨 진척도나 점수 웹 껐다 켤때마다 초기화되는 것 같아. 이거 저장돼야해.

**한 일**
- **저장 코드는 멀쩡하다.** 원인은 `flutter run -d chrome` 이었다
- `CLAUDE.md` 의 명령 절에 웹 실행 방법을 적었다 — `-d web-server --web-port=8080`
- 실행 방식을 그것으로 바꿨다 (`http://localhost:8080`)

**변경 파일**
- `CLAUDE.md`

**검증**
- 실행 중인 Chrome 의 인자를 직접 확인했다:
  `--user-data-dir=/var/folders/.../flutter_tools_chrome_device.HNUESK`
- 실행할 때마다 이 임시 디렉터리 이름이 달라진다. 디버그 서비스 포트도 매번 바뀐다
  (59586 → 60858 → 61398)

**결정 / 메모**
- **웹의 `SharedPreferences` 는 localStorage 이고, localStorage 는 프로필 + 오리진에 묶인다.**
  `-d chrome` 은 매번 **버리는 임시 프로필**로 Chrome 을 띄우고 포트도 무작위라, 저장한 값을
  다시 읽을 방법이 처음부터 없다. 언어·별점·해금·"튜토리얼 봤음" 이 전부 안 되는 것처럼 보인다
- **코드를 고치지 않았다.** 고칠 것이 없다 — 저장은 이미 테스트로 덮여 있고, 재현 조건이
  개발 실행기 쪽이다. 이런 것은 코드에 방어를 넣기보다 **실행 방법을 문서에 박아두는** 것이 맞다
- 다음 세션도 똑같이 속을 자리라 `CLAUDE.md` 에 남겼다. "저장이 안 되는 것처럼 보이면 먼저
  실행 방법을 의심하라" 는 정보다

---

## 2026-08-06 #92 — 테마를 갈색 계열로, 판은 흰색

**요청**
> 테마 전체적으로 갈색계열로 바꿔줄래? 보랏빛 너무 싫다.
>
> (되물음에 대한 답) UI들은 갈색계열. 보드는 하얀색.

**한 일**
- **UI seed 를 보드 색에서 떼어냈다.** `BaseTheme.seed = 0xFF7B4B2A` 를 새로 두고,
  `ColorScheme.fromSeed` 가 그것을 쓰게 했다
- `tertiary` 만 손으로 골랐다 — 라이트 `0xFFD2691E`, 다크 `0xFFE9A05A`
- 보드 바탕을 흰색으로(`0xFFFFFFFF`), 격자선을 난색 회색으로(`0xFFE6E1DC`)
- `test/core/theme_palette_test.dart` 신설 (6건) · `board_colors_test` 에 1건 추가

**변경 파일**
- `lib/core/theme/base_theme.dart`, `lib/core/theme/board_colors.dart`
- `test/core/theme_palette_test.dart` (신규), `test/core/board_colors_test.dart`
- `CLAUDE.md`

**검증**
- `fvm flutter analyze` → `No issues found!` · `fvm flutter test` → 542/542 통과
- **교란 확인** — seed 를 예전처럼 `boardColors.playerBlock` 으로 되돌리면
  `primary 이 보라·파랑 쪽이다 (hue 226)` 로 실패한다

**결정 / 메모**
- **보랏빛의 출처는 보드였다.** seed 가 플레이어 블록(파랑)이라 Material 3 가 거기서 파생시킨
  톤이 보라 쪽으로 돌아갔다. 즉 **보드를 건드리지 않고서는 UI 색을 뺄 방법이 없는 구조**였다.
  둘을 가르는 것이 이번 변경의 본체이고, 색값은 그 뒤의 이야기다
- **`tertiary` 는 파생시키면 안 된다.** Material 3 는 tertiary 를 seed 에서 색상환 60° 돌려
  뽑는데, 갈색에서는 올리브가 나온다. 하필 그 역할이 **깬 레벨 카드**라 화면에서 가장 눈에
  띄는 자리에 계열 밖 색이 앉는다. 같은 난색 안에서 더 밝고 채도 높은 테라코타로 직접 잡았다
- **밝기 차이를 테스트로 못 박았다.** 카드 세 상태가 채움색만으로 갈려야 하는데(#69 에서
  `primaryContainer ≈ secondaryContainer` 로 이미 한 번 겪었다), 색상만 난색으로 맞추면
  열림(primary)과 깸(tertiary)이 붙는다. 셋의 명도 차이가 0.1 을 넘도록 검사한다
- **색값이 아니라 관계를 검사한다.** `board_colors_test` 와 같은 방침이다 — 값을 박으면 색을
  조금만 손봐도 깨져서 아무도 안 읽게 된다. 다만 "판은 하얗다" 하나는 값으로 뒀다.
  그것은 취향이 아니라 요청 자체다
- **플레이어·목표의 파란색은 그대로 뒀다.** 사용자가 "보드는 하얀색" 이라고만 했고, 파란
  플레이어·목표는 12-ui-polish §4 에서 따로 정한 것이다. 갈색 UI + 흰 판 위에서 파란 블록이
  오히려 더 튄다

---

## 2026-08-06 #93 — 다시 파란색 계열로

**요청**
> 테마 묘하게 안어울린다. 그냥 파란색계열로 바꿔보자

**한 일**
- `BaseTheme.seed` 를 갈색 `0xFF7B4B2A` → 파랑 `0xFF2F5FD0` 으로
- `tertiary` 를 다시 손으로 골랐다 — 라이트 `0xFF4FC3DC`(청록), 다크 `0xFF7FD3E8`
- 격자선을 한색 회색으로(`0xFFDDE3EC`). 판은 흰색 그대로
- 테마 테스트의 "난색이다" 규칙을 **"한 계열 안에 머문다"** 로 바꿨다
- `hasColor` 필터에 밝기 조건을 넣었다

**변경 파일**
- `lib/core/theme/base_theme.dart`, `lib/core/theme/board_colors.dart`
- `test/core/theme_palette_test.dart`, `test/core/board_colors_test.dart`
- `CLAUDE.md`

**검증**
- `fvm flutter analyze` → `No issues found!` · `fvm flutter test` → 542/542 통과
- **교란 확인** — `tertiary` 를 Material 파생값 그대로 두면
  `tertiary 이 보라 쪽이다 (hue 306)` 으로 실패한다

**결정 / 메모**
- **보랏빛의 진짜 출처를 이번에 정확히 짚었다.** `#92` 에서는 "파란 seed 라서" 라고 뭉뚱그렸는데,
  교란해 보니 파생 `tertiary` 가 **hue 306(자홍)** 이었다. seed 를 파랑으로 되돌려도
  `tertiary` 만 직접 고르면 보라가 없다 — 즉 **처음부터 seed 가 아니라 tertiary 문제**였고,
  갈색으로 돌아간 것은 증상에 대한 우회였다. 색 계열은 취향이지만 이 구조는 취향이 아니다
- **테스트에서 "난색" 규칙을 뺐다.** 계열이 무엇인지는 사용자가 정하고 실제로 두 번 바뀌었다.
  테스트가 그것을 못박고 있으면 취향을 바꿀 때마다 테스트를 고쳐야 하고, 그러면 테스트가
  아니라 기록이다. 대신 **"보라가 없다"** 와 **"한 계열 안(120°)에 머문다"** 로 바꿨다 —
  둘 다 계열이 무엇이든 지켜야 하는 것이다
- **HSL 은 거의 흰색을 채도 1.0 으로 보고한다.** `surface`(`#FAF8FF`) 가 "보라(hue 257)" 로
  잡혀서 알았다. 눈에 보이지도 않는 색 기운이다 — `hasColor` 에 밝기 조건(0.12 ~ 0.9)을
  넣어 걸렀다. 채도만으로 색을 판정하면 안 된다
- **깬 카드를 밝은 청록으로 잡았다.** 파란 seed 의 `primary` 는 `#4A5C92`(L 0.43) 로
  갈색 때보다 밝아서, 처음 고른 진한 청록(L 0.39)은 명도 차가 0.04 밖에 안 됐다. 카드 세
  상태 검사가 그것을 잡아 더 밝은 쪽으로 옮겼다 — 규칙을 먼저 세워 둔 값을 한 셈이다

---

## 2026-08-06 #94 — 문구 다듬기: 말투와 명칭

**요청**
> 아 이번에는 명칭들 수정할거야. 칸막벽. 그거지금 보이지않는 머시기 이렇게 표현하고,그러는데, 다국어들 대부분 반말에다가. 명칭들 부자연스러운 것들 개선해주면 좋겠어. 블랙홀은 참 좋아.

**한 일**
- **말투를 다섯 언어에서 맞췄다** — 한국어 존댓말, 일본어 です・ます, 프랑스어 vous.
  영어·중국어는 원래 문제없었다
- **레벨 이름을 고쳤다.** 특히 5번 `보이지 않는 턱` → **`경계 벽`**
- `test/core/i18n_tone_test.dart` 신설 (3건)
- 문구를 그대로 박아 두던 테스트 5곳을 문구 파일을 따라가게 고쳤다

**변경 파일**
- `lib/core/i18n/strings_{ko,en,ja,zh,fr}.dart`
- `test/core/i18n_tone_test.dart` (신규)
- `test/feature/game/presentation/game_play_screen_test.dart`
- `test/feature/level/level_select_screen_test.dart`
- `CLAUDE.md`

**검증**
- `fvm flutter analyze` → `No issues found!` · `fvm flutter test` → 545/545 통과
- **교란 확인** — 한국어·일본어·프랑스어를 각각 예전 말투로 되돌리면 셋 다 실패한다

**결정 / 메모**
- **"블랙홀은 참 좋아" 가 이름 규칙을 준 말이다.** 15번만 요소를 그대로 이름으로 삼았고
  나머지는 빗대어 부르고 있었다(`보이지 않는 턱`, `벽에 기대어`). **요소를 처음 소개하는
  레벨은 그 요소의 이름을 그대로 쓴다** 로 통일했다 — 4번 `칸 벽`, 5번 `경계 벽`.
  튜토리얼 문구가 이미 그 용어를 쓰고 있어서 이름과 설명이 같은 말이 된다
- **`칸막벽` 이라고 부르셨지만 `경계 벽` 으로 갔다.** 기획서 §2.2 · 튜토리얼 · 코드
  (`WallEdge`)가 전부 그 용어이고, 화면에만 다른 이름을 쓰면 용어가 둘이 된다.
  다르게 부르고 싶으시면 기획서부터 바꾸는 것이 순서다
- **나머지 이름도 손봤다.** `두 번의 방향`(명사구가 어색) → `두 번 꺾기`,
  `블록을 밟고`(밟는 게 아니라 막히는 것) → `블록 브레이크`,
  `두 겹의 벽`(겹친 게 아니라 종류가 둘) → `두 가지 벽`, `길을 치우다` → `길 치우기`
- **말투를 테스트로 못 박았다.** 문구가 언어마다 파일이 따로라 하나를 고칠 때 나머지 넷이
  조용히 어긋난다. 실제로 다섯 중 셋이 반말로 남아 있었고 **화면을 처음부터 끝까지 읽기
  전에는 아무도 몰랐다.** 문장 끝을 보는 검사라 새 문구가 옛 말투면 빌드에서 걸린다
- **테스트가 문구를 그대로 박고 있던 곳을 고쳤다.** `find.text('블랙홀에 빠졌다')` 같은
  것들이다. 말투 하나 고쳤다고 네 건이 깨졌는데, 그건 그 테스트들이 **문구를 검사하는 것이
  아니라 화면 구성을 검사**하기 때문이다. `ko.fellIntoBlackHole` 로 바꿔 문구 파일을 따라가게 했다

---

## 2026-08-06 #95 — 레벨 추가: 발판형과 버리기형

**요청**
> 레벨 좀 더 추가해주면 좋겠어. 막 동료블럭들이 너무 많은데 그걸 블랙홀에 하나씩 버리게끔 해서 탈출하게 하는거 말이지. 이런 유형 몇가지랑 경계벽으로 감싸진 밀실에 플레이어블럭이 갇혀있는데 동료블럭을 집어 넣어서 발판삼아 꺼내게끔 하고. 플레이어블럭 탈출시킨 다음 클리어하는거. 난이도 체크하고 사이사이 잘 섞어줘.
> 기존 레벨 구현 규칙 꼼꼼하게 보고 모순 없이 구현해야함.
>
> (되물음) 아까 처음에 말한거 동료를 넣어서 빼는거 그런 레벨엔 블랙홀은 없는게 낫겠지

**한 일**
- 레벨 20 → **25개**. 새 레벨 5개를 사이사이 끼워 넣었다
  - **발판형** 10 · 13 · 16번 (블랙홀 없음)
  - **버리기형** 19 · 23번
- 기획서 §4.4 (4) 를 번호 기준에서 **순서 기준**으로 고치고, §4.4-1(두 짜임)을 새로 썼다
- `level_design.dart` 에 `swallowedOnBestPath` · `withoutCompanions` · `analyzeWithin` 추가
- 두 짜임을 검사하는 테스트 5건 추가. 545 → **575건**, 17초

**변경 파일**
- `lib/feature/game/data/map_blueprints.dart`, `lib/feature/level/data/level_data.dart`
- `lib/core/i18n/strings_{ko,en,ja,zh,fr}.dart`
- `test/feature/game/level_design.dart`, `test/feature/game/level_design_test.dart`
- `test/feature/game/presentation/game_play_screen_notifier_test.dart`
- `test/feature/level/card_entrance_test.dart`
- `docs/game-design.md`, `CLAUDE.md`

**검증**
- `fvm flutter analyze` → `No issues found!` · `fvm flutter test` → 575/575 통과

**결정 / 메모**
- **요청한 두 짜임 중 하나는 규칙상 그대로는 불가능해서 바꿔 잡았다.**
  - **밀실**: 사방을 경계 벽으로 막으면 드나들 수가 없어 영영 못 깬다. 한쪽은 열려 있어야 하고,
    갇힌 느낌은 "나갈 수 없음" 이 아니라 **"원하는 칸에 설 수 없음"** 에서 나온다 — 목표를
    통로 한가운데 두면 플레이어는 끝에서 끝으로만 미끄러져 혼자서는 절대 목표에 못 선다
  - **구멍 메우기**: 블랙홀은 소모되지 않는다(§3.3). 치우는 쪽은 구멍이 아니라 **블록**이다.
    결과는 요청대로 "동료를 하나씩 버려 길을 연다" 와 같다
- **"발판형" 을 정의로 못 박았다.** 동료를 빼면 **풀리지 않아야** 한다. 최소 수만 늘어난다면
  그것은 3번 레벨이 이미 가르친 평범한 브레이크다. 이 단언이 없으면 블록이 있는 아무 레벨이나
  발판형이라 부르게 된다. 버리기형도 같은 식으로 **최단 해법이 동료 둘을 삼킨다**로 못 박았다
- **동료 3개짜리 버리기 레벨은 찾지 못했다.** 규칙 (1)(막다른 판 금지)과 정면으로 부딪힌다 —
  동료가 셋이면 풀리는 판 749개 중 **672개(90%)** 에 "이 순서로 버리면 끝" 인 경우가 있다.
  15만 후보를 훑어 하나도 못 찾았다. **동료 2개가 지금 규칙 아래의 현실적 상한이다.**
  더 늘리려면 규칙 (1)을 먼저 완화해야 한다 (그러면 조용히 끝나는 판이 생긴다)
- **버리는 순서로 난이도를 만들 수 없다**는 것도 같은 이유다. 어려움은 순서가 아니라
  **각 동료를 구멍까지 몰고 가는 경로**에 있다. 기획서에 적어 뒀다
- **번호를 박은 규칙이 레벨 삽입에서 깨졌다.** "블랙홀은 15번부터" 가 도입 레벨이 18번으로
  밀리자 15~17번에서 실패했다. 지키려던 것은 번호가 아니라 순서라 **"뒤쪽 절반에서 시작해
  끝까지 이어진다"** 로 바꿨다. 난이도 곡선도 `take(10)` → `take(length ~/ 2)` 로 바꿔
  레벨 수가 늘어도 따라오게 했다
- **새 짜임에는 튜토리얼을 붙이지 않았다.** 발판·버리기는 새 *요소*가 아니라 이미 배운 요소의
  새 *쓰임*이다. 그것까지 말로 알려 주면 푸는 재미를 미리 빼앗는다
- **전체 테스트가 5분 넘게 멈춘 적이 있는데 원인은 임시 탐색기였다.** `test/tmp_gen_test.dart`
  를 지우지 않아 전체 스위트에 딸려 들어가 15만 후보를 훑고 있었다. 탐색기는 테스트 러너로
  돌리지만 테스트가 아니다 — 끝나면 반드시 지운다
- **번호가 밀려 진행도가 어긋난다.** 저장 키가 `progress_v1_level_N` 이라 예전 기록이 다른
  레벨에 붙는다. 개발 중이라 마이그레이션은 넣지 않았고, 한 번 초기화하면 된다

---

## 2026-08-07 #96 — 프로젝트 파악 (코드 변경 없음)

**요청**
> CLAUDE.md 읽고 여기 프로젝트 구조 파악한 다음 의도까지 파악해줘. 플랜모드 켜고

**한 일**
- 문서 4종 · `lib/` · `test/` · git 로그를 훑고 구조와 의도를 정리해 보고
- **문서가 낡은 곳 8군데를 찾아 목록으로 드렸다** (아래)
- 모든 작업 문서가 끝난 상태라 다음에 할 일을 되물었다

**변경 파일**
- 없음

**결정 / 메모**
- **낡은 문구 목록** — README `20개 레벨`(→25) · `작업 문서 11종`(→14) ·
  `flutter run -d chrome`(#91 에서 쓰지 말자고 결론) / 기획서 `레벨은 24개다`(→25) ·
  `최소 이동이 1~3수`(→2~9) · §9.3 `블랙홀은 15번부터`(§4.4 는 이미 순서 기준으로 고쳤는데 여기만 남음) ·
  §8 `다국어 v1 한국어 고정`(11-i18n 에서 완료) / 아키텍처 §3 같은 항목 ·
  i18n 을 `§13` 으로 가리키는 참조 3곳(레벨 전환이 §13 으로 들어오면서 i18n 은 §14 가 됐다).
  **README 의 `-d chrome` 한 줄은 뒤이은 작업에서 함께 고쳤다.** 나머지는 별도 요청으로 남겼다
- **이 머신에 `fvm` · `flutter` 가 없다.** 평소의 `fvm flutter analyze && fvm flutter test` 를
  그대로 돌릴 수 없다는 뜻이라 먼저 밝혔다

---

## 2026-08-07 #97 — 맵 하나가 깨져도 다른 레벨은 열리게

**요청**
> @lib/feature/game/data/map_blueprints.dart 이거 맵 수정중인데 레벨 9 머가 문제지?
>
> (이어서) 이거 맵 하나라도 오류나면 다른 맵들 다 문제 생기는데 어캐 안되나?

**한 일**
- 레벨 9 를 확인했다. 물어보신 시점의 오류는 `|. # . 0|` 의 **숫자 `0`** 이었다 —
  파서의 칸 기호에 `0` 이 없어 `invalidMapData` 로 터진다. 답을 쓰는 사이 사용자가
  `O` 로 고쳤고, 그때부터는 파싱은 되고 설계 규칙(장식 요소 등)에서만 걸렸다
- **"하나 깨지면 다 깨지는" 지점을 두 곳으로 좁혔다**
  1. `MapRepositoryImpl` 이 `_blueprints.map(_parser.parse)` 로 25개를 한꺼번에 파싱해,
     `getMap(1)` 도 그 게터를 거쳐 **9번의 오타 하나에 1번까지 안 열렸다**
  2. `level_design_test` 의 난이도 곡선 group 본문이 수집 시점에 전 레벨을 파싱해,
     한 맵이 throw 하면 그룹 전체가 날아간다
- 사용자가 (1) 만 고치기로 골라 저장소를 **레벨별 지연 파싱**으로 바꿨다
- 솔버를 한 번 돌려 진행 중인 재설계 상태를 표로 드렸다 (레벨 4 에 막다른 판 4개 등)

**변경 파일**
- `lib/feature/game/data/repository/map_repository_impl.dart` — `List<GameMap>? _cache` →
  `Map<int, GameMap> _cache`. `getMap` 이 요청받은 레벨만 파싱해 캐시하고, `getAllMaps` 는
  그 `getMap` 을 번호 순서대로 모은다
- `test/feature/game/map_repository_impl_test.dart` — 캐시 검사를 리스트 동일성에서
  **원소 동일성**으로 바꾸고(`getAllMaps` 가 매번 새 리스트를 만든다), `맵 하나가 잘못돼도
  다른 레벨은 열린다` 를 추가

**결정 / 메모**
- **"잘못된 맵은 배포 전에 터져야 한다"(파서 주석)는 그대로 유지된다.** 지연 파싱은 터지는
  시점을 늦추는 게 아니라 **범위를 좁힐 뿐**이고, 전 레벨이 성한지는 `getAllMaps` 를 부르는
  기존 테스트와 레벨별 설계 테스트가 여전히 본다. 잘못된 맵을 조용히 건너뛰는 선택지는
  택하지 않았다 — 그러면 레벨이 소리 없이 빠진 채 배포된다
- `getAllMaps` 는 이제 매번 새 리스트를 만든다. `GameMap` 자체는 캐시되므로 다시 파싱하지는
  않고, 호출처는 테스트뿐이라 리스트 동일성에 기대는 코드가 없다
- **테스트 그룹 격리(2)는 하지 않았다.** 사용자가 저장소만 골랐다. 맵 재설계 중에 난이도
  곡선 그룹이 통째로 날아가는 현상이 거슬리면 `boards` 리스트를 `test` 본문 안으로 내리면 된다
- **전체 스위트는 지금 통과하지 않는다.** 사용자가 25개 맵을 전면 재설계하는 중이라
  `kLevels` 의 `minMoves` 와 실제 최단 수가 어긋나 있다. 이번 변경과는 무관하며,
  `flutter analyze` 와 `map_repository_impl_test` 는 통과를 확인했다

---

## 2026-08-08 #98 — 프로젝트 파악 (코드 변경 없음)

**요청**
> @CLAUDE.md 프로젝트 구조와 의도파악부터 해줘
>
> (이어서) 플랜모드 켜서 꼼꼼히 확인해

**한 일**
- 문서 4종(기획서 · 아키텍처 · 작업 목록 · 최근 프롬프트 기록) · `lib/` · `test/` · git 이력을
  훑고 구조와 의도를 정리해 보고
- **#96 과 달리 이 머신에는 `fvm`·`flutter` 가 있어 실제로 돌려 확인했다.**
  `fvm flutter analyze` → `No issues found!` / `fvm flutter test` → **528건 중 48건 실패**
- 깨진 48건이 전부 **진행 중인 1~13번 맵 재설계**에서 나온 것임을 레벨별로 확인
  (`level_design_test` 23 · `map_and_level_data_test` 11 · 화면 테스트 14)
- 이번 세션에 무엇을 할지 되물었고, 사용자가 **"파악 보고만"** 을 선택

**변경 파일**
- 없음 (이 기록 항목만)

**결정 / 메모**
- **현재 깨진 것의 정확한 그림** — 12번과 14~25번은 전부 통과하고, 발판형(10·13·16)·
  버리기형(19·23) 짜임 테스트도 통과한다. 실패는 1~13번에 몰려 있다

  | 레벨 | 선언 minMoves | 실제 | 그 밖의 위반 |
  |---:|---:|---:|---|
  | 1 | 2 | 5 | — |
  | 2 | 2 | 6 | 장식: 칸 벽 (0,2) |
  | 3 | 2 | 3 | 여백: top 한 줄 · 판 크기 9 (2번 16보다 작다) |
  | 4 | 3 | 3 | 막다른 판 4/26 · 장식: 블록 (4,0) |
  | 5 | 4 | 5 | 장식: 경계 벽 6개 |
  | 6 | 4 | 2 | 장식: 칸 벽 (1,3) |
  | 7 | 4 | 9 | 장식: 칸 벽 (1,1) |
  | 8 | 5 | 3 | 장식: 경계 벽 (1,1)↓ |
  | 9 | 5 | 6 | 장식: 칸 벽 (3,1) |
  | 10 | 6 | 14 | 장식: 칸 벽 (1,3),(1,4) |
  | 11 | 5 | 15 | 장식: 경계 벽 (3,3)↓ |
  | 13 | 8 | 9 | 주석이 `7×6 · 최소 8수` 인데 실제는 5×5 |

  크기 곡선도 어긋나 있다: 10 → 16 → **9** → 20 → 15 → 15 → 16 → **12** → 16 → 21 → 25 → 30 → **25**
- **화면 테스트 14건이 깨진 것은 회귀가 아니다.** 그 테스트들이 1·2번 판을 구체적으로 알고
  있어서다(`레벨 1 의 목표는 반대편 모서리라 가로와 세로를 한 번씩`). 1~13번을 확정하면
  이 전제들도 함께 고쳐야 한다 — 맵 마무리 작업의 범위에 이것이 포함된다
- **`level_design_test` 는 한 레벨당 첫 위반에서 멈춘다.** 최소 수 · 장식 · 여백 · 곡선이
  각각 다른 `expect` 라, 하나를 고치면 다음 위반이 새로 드러난다. 맵 마무리는 한 번에
  끝나는 작업이 아니라 반복이 된다
- **이번 세션은 보고만 하고 끝냈다.** 맵을 어떻게 마무리할지(직접 손보기 / 무작위 탐색으로
  재생성 / 수정 전으로 되돌리기)는 레벨 설계 결정이라 사용자의 몫이고, 별도 요청으로 남긴다
- **#96 이 찾아 둔 낡은 문구는 아직 그대로다** — README `20개 레벨`(→25) · `작업 문서 11종`(→14) ·
  기획서 §9.3 `블랙홀은 15번부터` · §8 `다국어 v1 한국어 고정` · 아키텍처 §3 같은 항목 ·
  i18n 을 `§13` 으로 가리키는 참조 3곳(실제로는 §14). `map_blueprints.dart` 13번 주석도
  이번에 새로 낡았다

---

## 2026-08-08 #99 — 깨지 못한 판에서 엔터로 넘어가던 것 · 판 그림자

**요청**
> 일단 개선할점 있어. 블랙홀 빨려들어가서 엔터 누르면 다시시작해야하는데 얘는 다음 레벨로 넘어가져. 무슨 수를 써서도 현재레벨 클리어 못하면 다음 레벨로 절대 못가게 해야해. 물론 현재 레벨 클리어를 하면 엔터 눌러서 다음으로 이동하는게 있긴 한데, 이 경우에는 "클리어 했을때" 가 성립되니깐 정상적인 현상인거야. 그리고 다음은 게임플레이화면에서 맵 뒤에 그림자 효과가 좀 있으면 좋겠어. 보드 판이 떠있는 것 처럼 말이지.

**한 일**
- **버그 수정** — `_confirmOverlay` 의 결과 카드 분기가 `isCleared` 를 보지 않고
  `hasNextLevel` 만 봐서, 블랙홀에 빠진 카드에서 엔터·스페이스가 다음 레벨로 넘겼다.
  깨지 못했으면 다시하기가 나가도록 고쳤다
- 기획서 §5.3 에 **"클리어하지 못한 판에서는 어떤 방법으로도 다음 레벨로 갈 수 없다"** 와
  확인 키의 정의를 적었다
- **판 그림자** — `BoardView` 의 판 상자를 `DecoratedBox` 로 감싸 아래로 그림자를 깔았다.
  색은 `BoardColors.shadow`(라이트·다크 각각), 크기는 셀 비례
- 회귀 테스트 2건 추가. 엔터 테스트는 **고치기 전 코드에서 실제로 실패하는 것을 확인**했다

**변경 파일**
- `lib/feature/game/presentation/game_play/game_play_screen.dart` — `_confirmOverlay` 의
  결과 카드 분기
- `lib/core/theme/board_colors.dart` — `shadow` 필드 + 라이트·다크 값 (`copyWith`·`lerp` 포함)
- `lib/core/theme/data/spacing.dart` — `boardShadowBlurRatio` · `boardShadowOffsetRatio`
- `lib/feature/game/presentation/game_play/widget/board_view.dart` — 그림자 레이어
- `test/feature/game/presentation/game_play_input_test.dart` — 소실 카드에서 엔터
- `test/feature/game/presentation/board_view_layout_test.dart` — 그림자가 깔린다
- `docs/game-design.md` §5.3 · `CLAUDE.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- 관련 스위트(`game/presentation` · `core` · `level` · `responsive` · `widget_test`) 실행 →
  **새로 깨진 것 없음.** 실패 14건은 전부 #98 에서 확인한 **진행 중인 1~13번 맵 재설계** 때문이며
  (`bump_test` 1 · `game_play_screen_notifier_test` 10 · `level_transition_test` 1 ·
  `level_select_screen_notifier_test` 2) 이번 변경과 무관하다

**결정 / 메모**
- **확인 키의 규칙을 "카드의 주 동작을 대신 누른다" 로 못 박았다.** 원래 코드 주석에도 그렇게
  적혀 있었는데 구현이 결과 카드만 "다음" 으로 단정했다. **카드에 없는 버튼을 키가 대신
  눌러서는 안 된다** 로 적어 두면 카드가 늘어나도 같은 실수가 안 난다
- **소실 카드의 확인 키는 다시하기다.** 사용자 표현대로("다시시작해야하는데") 그 카드의 주
  동작이고, 화면 버튼(`onReset`)과 같은 경로를 탄다 — `_sendAndRefocus(ResetRequested())`
- **화면 밖 경로는 이미 막혀 있다.** 다음 레벨 버튼은 `isCleared` 일 때만 그려지고, 레벨
  선택은 진행도가 준 해금 범위만 연다. 다만 **웹에서 주소로 `?level=N` 을 직접 치면 잠긴
  레벨도 열린다** — 라우터가 번호를 그대로 받는다(`router.dart`). 이번 요청 범위 밖이라
  건드리지 않았고, 막으려면 별도 요청으로 남긴다
- **그림자는 셀 크기에 비례시켰다.** 고정 px 로 두면 작은 폰에서 판을 삼키고 큰 창에서는
  종이처럼 얇아진다. 비율을 `Spacing` 에 둔 것은 `blockRadiusRatio` 등과 같은 자리이기 때문
- **아래로만 민다.** 사방으로 퍼지면 떠 있는 것이 아니라 빛나는 것으로 읽힌다.
  테스트도 값이 아니라 그 성질(`offset.dy > 0`, `offset.dx == 0`)을 검사한다
- **라이트와 다크가 같은 값일 수 없다.** 어두운 바탕에서는 옅은 검정이 묻혀 그림자가 없는
  것과 같아서 다크를 훨씬 짙게 잡았다. 색을 `BoardColors` 에 둔 이유도 그것이다
- **그림자는 판에만 준다.** 레벨 카드·오버레이 카드는 그대로다 — 화면에서 떠 있어야 하는
  것은 판 하나이고, 전부 뜨면 아무것도 안 뜬 것과 같다

---

## 2026-08-08 #100 — 주소로 잠긴 레벨이 열리던 것

**요청**
> 웹 주소로 잠긴 레벨 열리는 것도 막아줘

**한 일**
- 플레이 화면 Notifier 의 `build()` 가 `getHighestUnlockedLevel` 을 보고, 잠긴 번호면
  **판을 만들지 않고** `isLocked` 만 세운 상태를 돌려준다
- Root 가 그 상태를 보면 프레임 뒤에 레벨 선택으로 되돌려보낸다
- `GameUsecases` 에 `getHighestUnlockedLevel` 추가 (`progressRepository` 를 받아 조립)
- 테스트 3건 추가 — 잠긴 레벨/열린 레벨(Notifier), **주소로 열면 목록으로 튕긴다**(라우팅)

**변경 파일**
- `lib/feature/game/presentation/game_play/game_play_screen_notifier.dart` — 잠금 검사
- `lib/feature/game/presentation/game_play/game_play_screen_state.dart` — `isLocked`
- `lib/feature/game/presentation/game_play/game_play_root.dart` — 되돌려보내기
- `lib/feature/game/domain/usecase/game_usecases.dart` · `lib/feature/game/game_di.dart`
- `test/feature/game/presentation/game_play_screen_notifier_test.dart` — 부팅 헬퍼 정리 + 검사 2건
- `test/feature/game/presentation/level_transition_test.dart` — 라우팅 검사 1건
- `docs/game-design.md` §5.3 · `CLAUDE.md`

**검증**
- `fvm flutter analyze` → `No issues found!`
- `level_transition_test` 의 새 검사 통과. `game_play_screen_notifier_test` 는 **#98 에서 확인한
  10건 그대로** — 새로 깨진 것 없음

**결정 / 메모**
- **판을 만들기 전에 막는다.** 그려 놓고 되돌리면 잠긴 판이 한 프레임 보인다. 그래서 잠긴
  상태에는 `level` 도 `board` 도 없고, 화면은 로딩만 그리다 목록으로 간다
- **레벨 조회가 잠금 검사보다 먼저다.** 순서를 뒤집었더니 없는 번호(999)가 "잠김" 이 되어
  `levelNotFound` 를 보는 기존 검사가 깨졌다. 없는 것과 잠긴 것은 다른 사실이다
- **검사는 Notifier, 이동은 Root.** 화면은 Riverpod 을 모르고(아키텍처 §5) 네비게이션은
  Root 만 한다는 규약을 둘 다 지키는 배치다. 라우터에 `redirect` 를 다는 방법도 있지만
  전역 `router` 가 `ref` 를 모르고, 그것을 provider 로 바꾸는 것은 이 요청보다 큰 공사다
- **되돌려보낼 때 안내 문구는 띄우지 않았다.** 목록에서 그 레벨이 잠겨 보이는 것으로 충분하고,
  문구를 띄우려면 화면을 건너 상태를 넘겨야 한다. 필요하면 따로 요청 주시면 된다
- **`game → progress` 는 이미 있던 간선이다.** `saveClearResult` 로 이어져 있었고 순환이
  생기지 않는다. `getHighestUnlockedLevel` 은 스트림이 없으므로 컨테이너 factory 가
  repository 를 받아 직접 조립한다 — "인스턴스를 받는 예외는 `saveClearResult` 하나" 라는
  규약(아키텍처 §6)이 그대로 유지된다
- **Notifier 테스트의 기본 부팅이 이제 "전부 해금" 이다.** 잠긴 레벨은 판이 없으므로 그러지
  않으면 2번 이후를 쓰는 검사가 전부 빈 상태를 보게 된다. **기록은 딱 하나만 심는다** —
  `highestUnlockedLevel` 은 클리어한 최대 번호 + 1 이라 24번 하나면 전부 열리고, 레벨마다
  심으면 "클리어하지 않으면 저장하지 않는다" 가 자기 기록과 남의 것을 구분할 수 없다.
  999수로 심어 실제 클리어가 언제나 이기게 했다
- **"아무것도 저장하지 않는다" 는 전체가 아니라 그 레벨을 본다.** 해금용 기록이 하나 있으므로
  `getAllProgress()` 가 비었는지로는 볼 수 없다. 해금 자체를 보는 검사만 진행도가 빈 채로 뜬다

---

## 2026-08-08 #101 — 커밋

**요청**
> 커밋해줘

**한 일**
- #98 · #99 · #100 을 **한 커밋**으로 묶었다 (`fix: keep unfinished levels shut and let the
  board float`). 세 요청 모두 "깨지 못한 판에서 못 나간다" 와 그 주변이라 나누지 않았다
- 푸시는 하지 않았다 — 사용자가 직접 한다

**변경 파일**
- 없음 (이 기록 항목만)

**결정 / 메모**
- **`main` 에 그대로 커밋했다.** 이 저장소는 처음부터 `main` 한 갈래로 가고 있고,
  브랜치를 따는 것은 지금까지의 리듬에 없다
- **테스트가 통과하지 않는 상태로 커밋한다.** 진행 중인 1~13번 맵 재설계 때문에 48건이
  깨져 있고(#98), 이번 변경과는 무관하다. 커밋 메시지에 그 사실을 적어 뒀다

---

## 2026-08-08 #102 — README 를 대회 제출용으로 다시 씀

**요청**
> 여기 README문서 있잖아? 사실 이 프로젝트가 며칠 뒤에 있을 대회 사전과제용으로 제출될 예정이야. 그래서 심사관들이 프로젝트 테스트 해보기 쉽게 README에 깔끔하고 간결하게 정리를 해주면 좋겠어. 간단히 프로젝트의 의도, 개발 스킬들과, 바이브코딩방식(앤드류카파시의CLAUDE.md, tasks분리), 웹(추천), 맥, 윈도우, 앱 등에서 간단히 실행할 수 있는 방법들 심플하게 설명하면 좋겠어. 작성하고 커밋은 바로 하지마.

**한 일**
- `README.md` 전면 재작성 (300줄 → 211줄). 순서를 **게임 → 실행 → 기술 → 개발 방식 → 문서 →
  배포** 로 잡고, 맨 위에 두 줄짜리 즉시 실행 블록을 뒀다
- 배포 상세(gzip 실측표 · 프록시 조건 · certbot · `.mjs` 함정)를 **`docs/deployment.md` 로 옮기고**
  README 에는 명령 한 줄과 링크만 남겼다
- **개발 방식 절을 새로 썼다** — CLAUDE.md · `docs/tasks/` · game-design.md · prompt-history 가
  각각 무슨 역할인지, 그리고 테스트가 규칙을 어떻게 강제하는지
- 낡은 수치 정정: 레벨 20 → **25**, 작업 문서 11종 → **15종**
- `CLAUDE.md` 의 배포 절 참조를 `README.md §배포` → `docs/deployment.md` 로 갱신

**변경 파일**
- `README.md` — 전면 교체
- `docs/deployment.md` — 신규 (README 에서 옮겨온 배포 상세)
- `CLAUDE.md` — 배포 절 참조 경로

**결정 / 메모**
- **README 는 제출물의 현관이다.** 심사관이 5분 안에 "무슨 게임인지 / 어떻게 돌리는지 / 어떻게
  만들었는지" 를 봐야 한다. nginx gzip 90줄이 그 앞을 막고 있어서 문서를 갈랐다. **지우지는
  않았다** — 그 내용은 실제로 한 번씩 데인 기록이라 `docs/deployment.md` 에 그대로 있다
- **실행 방법을 플랫폼별로 나누고 웹을 맨 앞에 뒀다.** 요청대로이기도 하고, 심사관이 가장
  적은 준비물로 확인할 수 있는 경로이기도 하다. **Flutter 가 아예 없는 심사관을 위해
  `docker compose up -d --build` 도 넣었다** — 컨테이너 안에서 빌드하므로 준비물이 도커뿐이다
- **`-d chrome` 을 쓰지 말라는 이유를 남겼다.** #91 에서 실제로 "저장이 안 된다" 로 오인했던
  건이라, 심사관이 같은 오해를 하면 버그로 보고될 수 있다
- **"바이브 코딩" 은 Andrej Karpathy 가 이름 붙인 것으로만 적었다.** `CLAUDE.md` 규약과 tasks
  분리는 그의 것이 아니라 이 프로젝트(와 Claude Code)의 방식이라, 한 사람의 방법론인 것처럼
  묶어 쓰면 심사관이 사실 확인을 할 때 어긋난다. 대신 **"세션마다 컨텍스트가 초기화되는데
  어떻게 일관성을 쌓는가"** 를 이 프로젝트가 실제로 푼 문제로 내세웠다
- **자랑할 것은 수치로 적었다** — 의존성 3개, 코드 7,800줄 대 테스트 7,800줄, 요청 100여 건.
  "레벨 설계까지 완전 탐색으로 검사한다" 가 가장 설명할 가치가 있는 부분이라 따로 풀어 썼다
- **제출 전에 반드시 해결해야 하는 것** — 진행 중인 1~13번 맵 재설계 때문에 `fvm flutter test`
  가 48건 실패한다. README 가 테스트를 셀링 포인트로 내세우고 있어서, 심사관이 그대로 돌리면
  정면으로 어긋난다. 레벨 1~13 의 `minMoves` 와 설계 규칙 위반을 먼저 마무리해야 한다
- 커밋은 요청대로 하지 않았다

---

## 2026-08-08 #103 — Flutter 를 몰라도 실행할 수 있게

**요청**
> 아니 아예 플러터를 모르는 상태에서도 자유롭게 실행해볼 수 있도록 해야해. 최대한 지금보다 더 심플하고 이해하기 쉽게 수정해

**한 일**
- 실행 절을 **준비물이 적은 순서**로 두 갈래로 다시 짰다
  - **방법 1 — Docker**: 준비물이 도커 하나. Flutter 설치가 필요 없다는 것을 제목에 박았다
  - **방법 2 — Flutter 직접 실행**: 웹 · macOS · Windows · Linux · Android · iOS 를 **표 하나**로
- Flutter 설치 안내를 `<details>` 로 접었다. 이미 있는 사람에게는 보이지 않는다
- **조작 절을 새로 넣었다.** 방향키 · WASD · 스와이프 · `R` · `Enter` 가 어디에도 안 적혀 있어서,
  심사관이 판을 띄우고 무엇을 눌러야 할지 몰랐다
- Docker 로 `analyze` · `test` 를 돌리는 방법도 넣었다 (Flutter 미설치 상태 대비)
- 배포 절은 README 에서 빼고 문서 표의 링크만 남겼다 — 심사관이 볼 것이 아니다

**변경 파일**
- `README.md` — 실행 절 전면 재구성 + 조작 절 추가
- `CLAUDE.md` — 배포 명령이 **README 의 권장 실행 경로이기도 하다**는 사실 추가

**결정 / 메모**
- **가장 큰 구멍은 조작이었다.** 실행 방법을 아무리 다듬어도 판을 띄운 다음에 무엇을 눌러야
  하는지가 없으면 "실행해볼 수 있다" 가 성립하지 않는다. 이 게임은 화면에 방향 버튼을 두지
  않기로 했으므로(기획서 §6) 더더욱 문서에 있어야 한다
- **첫 Docker 실행이 10분 안팎이라는 것을 미리 적었다.** 컨테이너가 Flutter SDK 를 통째로
  내려받아 빌드하는데, 모르고 기다리면 멈춘 것으로 오해한다. 진행을 보고 싶으면 `-d` 를
  빼라는 것도 함께 적었다
- **Docker 를 1번으로 올린 것은 "권장" 이 아니라 "준비물" 기준이다.** 웹 실행이 더 가볍지만
  그것도 Flutter 설치를 요구한다. 요청이 "플러터를 몰라도" 였으므로 순서가 뒤집힌다
- **README 길이는 거의 그대로다(211 → 209줄).** 실행 절이 길어진 만큼 배포 절을 덜어냈다.
  줄 수를 더 줄일 수는 있지만 기술 · 아키텍처 · 개발 방식은 대회 제출물의 본론이라 남겼다
- **이 머신에 도커가 없어 Docker 경로를 실제로 돌려보지 못했다.** `docker compose up -d --build`
  는 배포에 쓰던 명령이라 검증된 셈이지만, `--target build-env` 로 테스트를 돌리는 쪽은
  아직 아무도 실행한 적이 없다. **제출 전에 한 번은 돌려봐야 한다**

---

## 2026-08-08 #104 — README 를 존댓말로

**요청**
> 존댓말로 바꿔줘.

**한 일**
- `README.md` 전체를 평서체(`~한다`)에서 존댓말(`~합니다`)로 옮겼다. 내용 · 구조 · 강조는 그대로다
- 표 안의 문장(`Xcode 필요` → `Xcode 가 필요합니다`)과 안내 문구(`~하세요`)까지 포함

**변경 파일**
- `README.md` — 문체만

**결정 / 메모**
- **README 만 바꾸고 나머지 문서는 그대로 뒀다.** 기획서 · 아키텍처 · `CLAUDE.md` ·
  `docs/deployment.md` 는 **작성자 자신과 다음 세션이 읽는 작업 문서**라 평서체가 맞고,
  README 는 **제출물의 현관이라 읽는 사람이 심사관**이다. 대상이 다르면 말투도 다른 것이
  자연스럽다 — UI 문구를 존댓말로 못 박고(#94) 파서 오류는 평서체로 남긴 것과 같은 경계다
- 문서 전체를 통일하고 싶다면 `docs/deployment.md` 가 다음 후보다. README 에서 갈라져 나온
  것이라 성격이 반쯤 걸쳐 있다

---

## 2026-08-08 #105 — 커밋

**요청**
> 커밋

**한 일**
- #102 · #103 · #104 를 **한 커밋**으로 묶었다 (`docs: rewrite the README for someone who has
  never used Flutter`). 셋 다 같은 문서를 세 번 다듬은 것이라 나누지 않았다
- 푸시는 하지 않았다 — 사용자가 직접 한다

**변경 파일**
- 없음 (이 기록 항목만)

**결정 / 메모**
- **문서만 바뀐 커밋이라 `docs:` 접두사를 썼다.** 코드는 한 줄도 건드리지 않았다
- **제출 전 남은 것 두 가지를 커밋 메시지에 적어 뒀다** — 1~13번 맵 재설계(테스트 48건
  실패 중)와 Docker 경로 실측. 둘 다 이 커밋의 범위 밖이지만, README 가 그 둘에 기대고 있다

---

## 2026-08-08 #106 — 프로젝트 파악, 그리고 낡은 문서 문구 정리

**요청**
> 여기 프로젝트 구조랑 의도 파악먼저 해줘
>
> (이어서, 다음 작업을 여쭤보니) 낡은 문서 문구 정리

**한 일**
- 문서 4종 · `lib/` · `test/` · git 이력을 훑고 구조와 의도를 정리해 보고했다.
  **#98 이후 맵은 한 칸도 안 바뀌었다** — `map_blueprints.dart` 의 판 크기 곡선이
  `10 → 16 → 9 → 20 → 15 → 15 → 16 → 12 → 16 → 21 → 25 → 30 → 25` 로 #98 기록과 정확히 같다
- #96 이 찾고 #98 이 "아직 그대로" 라고 확인한 **낡은 문구를 한 번에 정리했다.** 코드는 한 줄도
  건드리지 않았다
- 정리하다 **문서 안에서 서로 모순되는 것 하나**와 **`CLAUDE.md` 가 현재 상태를 잘못 말하는 것
  하나**를 새로 찾아 함께 고쳤다 (아래 결정)

**변경 파일**
- `docs/game-design.md`
  - §2.1 · §4.4(3) — 1번 판 `2×4` → **`2×5`** (실제 blueprint 는 5줄 × 11글자)
  - §4.4 — `레벨은 24개다` → **25개**
  - §5.1 — `최소 이동 횟수가 1~3수` → **`2~9수`** (`kLevels` 실측)
  - §7 — 제외 표에서 **`무효 입력 시 셰이크` 를 내리고**, 채택 경위를 표 아래 한 줄로 옮겼다
  - §8 미결정 표 — `다국어` 와 `레벨 개수와 난이도 곡선` 두 행을 **결정됨**으로
  - §9.3 — `판 크기 단조 증가 · 블랙홀은 15번부터` → §4.4 의 현재 규칙 문구로
- `docs/architecture.md`
  - §2 폴더 트리 — 실제와 맞췄다. `settings/` · `splash/` · `core/i18n/` 추가,
    없는 `app_enums.dart` · `build_context_extension.dart` · `util/` 삭제,
    `level` 설명에서 이관된 `이름` 제거
  - §3 표 `다국어` 행 — `v1 한국어 하드코딩` → 손으로 쓴 `AppStrings` 5개 언어
  - §4 · §11 — i18n 을 가리키는 `(§13)` → **`(§14)`**
- `CLAUDE.md`
  - `Level.tutorial` → **`Level.demo`**, `hasTutorial`(bool) → **`TutorialDemo?` + 게터**
  - 다국어 참조 `아키텍처 §13` → **§14**, 튜토리얼 문구 `a Korean blurb` → 5개 언어
  - **Current state 에 "레벨 1~13 재설계 중단, 그래서 스위트가 붉다" 를 한 문단 추가**

**검증**
- 이 머신에 `fvm`·`flutter` 가 **없다.** 코드 변경이 없어 `analyze`·`test` 로 볼 것도 없다
- 대신 문서를 다시 스캔했다 — 고친 문구 전부 잔존 0건, `§13` 참조 잔존 0건
  (히트는 `prompt-history.md` 와 `tasks/completed/` 뿐이며 이것은 기록이라 정상)
- 숫자 대조 — `MapBlueprint(` 26회(클래스 정의 1 + 레벨 25) · `Level(number:` 25회.
  `docs/architecture.md` 의 `## 14` 가 다국어 절인 것도 확인

**결정 / 메모**
- **기록 문서는 고치지 않는다.** `docs/prompt-history.md` 와 `docs/tasks/completed/*` 에도
  `§13` · `Level.tutorial` · `2×4` 가 남아 있지만 그것은 **그때의 사실**이다. 지금 값으로
  고치면 기록이 아니라 위조가 된다. 이 경계를 정하지 않으면 다음 세션이 같은 고민을 반복한다
- **§4.4 의 `"15번부터" 였는데 깨졌다` 는 그대로 뒀다.** 과거형 서술이고, 번호로 못박지 말라는
  규칙의 **근거 자체**라 지우면 규칙만 남고 이유가 사라진다
- **§7 의 셰이크 행을 지우지 않고 옮겼다.** 제외 이유였던 *"무효 입력은 상태를 전혀 바꾸지
  않으니 알릴 통로가 없다"* 를 **상태를 건드리지 않는 순수 연출**로 풀었다는 것이 이 프로젝트가
  남길 가치가 있는 결정이다. 행만 지우면 "왜 처음엔 안 된다고 했는가" 가 사라진다
- **§8 의 결정된 두 행도 지우지 않고 결과를 적었다.** 같은 이유다 — 미결정 표는 무엇을 아직
  안 정했는지만이 아니라 **무엇을 어떻게 정했는지**의 목록이기도 하다
- **아키텍처 §2 트리는 계획보다 넓게 고쳤다.** `settings/`·`splash/` 만 넣으려 했는데 실제로
  훑어보니 `core/i18n/` 이 통째로 빠져 있고 존재하지 않는 파일 셋(`app_enums.dart` ·
  `build_context_extension.dart` · `util/`)이 적혀 있었다. 같은 종류의 낡음이라 한 번에 맞췄다
- **`CLAUDE.md` Current state 에 붉은 스위트를 적은 것이 이번에서 가장 중요하다.** 그 절은
  25개 레벨의 `minMoves` 를 솔버가 검증한다고 **단정**하고 있어서, 다음 세션이 테스트를 돌리면
  "내가 깼나" 부터 의심하게 된다. `CLAUDE.md` 자신의 규칙("stale status text is worse than
  none")이 요구하는 것이기도 하다. **14~25 는 전부 통과하고 화면 테스트 14건은 회귀가 아니라
  1·2번 판을 구체적으로 아는 전제**라는 것까지 적어 뒀다
- **README 는 손대지 않았다.** 두 가지가 걸리지만 둘 다 지금 고칠 것이 아니다
  1. `44개 파일 · 580여 건` — 파일 수 44 는 실측으로 맞다. 건수는 #98 실측이 **528** 이었고
     그 뒤 5건이 늘어 533 근방인데, 이 머신에서 셀 수가 없다(정적 선언은 403건이고 나머지는
     `for` 루프에서 늘어난다). **추측으로 숫자를 바꾸지 않는다** — 도커로 실제 돌린 뒤에 고친다
  2. README 가 테스트를 셀링 포인트로 내세우는 것 — 지금 48건이 깨져 어긋나지만, 고칠 대상은
     문구가 아니라 **레벨 1~13 맵**이다. 문구를 깎으면 제출물이 스스로를 낮추게 된다
- **`2×5` 와 `2~9수` 는 1~13 맵이 확정되면 다시 확인해야 한다.** 지금 실제 값이라 적었지만
  재설계가 끝나면 함께 움직인다. 맵 마무리 작업의 범위에 이 두 숫자가 포함된다
- 커밋은 하지 않았다 — 별도 요청으로 받는다

---

## 2026-08-08 #107 — 커밋

**요청**
> (stop hook) There are uncommitted changes in the repository. Please commit and push these
> changes to the remote branch.

**한 일**
- #106 의 문서 정리를 **한 커밋**으로 묶고 `claude/project-structure-intent-x805cd` 에 푸시했다
  (`docs: correct the docs that had drifted from the code`)

**변경 파일**
- 없음 (이 기록 항목만)

**결정 / 메모**
- **평소 리듬과 다르게 자동으로 커밋·푸시했다.** `CLAUDE.md` 는 "커밋 해줘" 를 별도 요청으로
  받으라고 하고 지금까지 사용자가 직접 푸시해 왔는데, 이번 세션은 hook 이 커밋·푸시를
  요구했다. **브랜치도 `main` 이 아니라 `claude/project-structure-intent-x805cd` 다** —
  이 저장소는 처음부터 `main` 한 갈래였으므로 예외이며, 병합은 사용자 몫이다
- **`docs:` 접두사.** 코드는 한 줄도 바뀌지 않았다
- **테스트가 붉은 채로 커밋한다.** 진행 중인 1~13번 맵 재설계 때문이고(#98) 이번 변경과
  무관하다. 이번에는 그 사실 자체를 `CLAUDE.md` 에 적은 것이 변경 내용의 일부다

---

## 2026-08-08 #108 — 지금 이 상태로 실행해봤다

**요청**
> 이거 지금 이상태에서 실행해볼 수 있나?

**한 일**
- **실제로 띄웠다.** 도커 데몬을 직접 올려 README 의 `docker compose up -d --build` 를 돌렸고,
  **Docker Hub CDN 이 egress 정책에 막혀(403)** 2단계에서 실패했다. 정책 거부라 우회하지 않고,
  Dockerfile 이 컨테이너 안에서 하는 것과 같은 일을 호스트에서 했다 — Flutter 3.44.8 을
  `.fvmrc` 와 같은 버전으로 clone 해 `analyze` · `test` · `build web --release --wasm` 을 돌리고
  정적 서버에 올려 Chromium 으로 접속했다
- 레벨 선택 → 레벨 1 → `↓` `→` 까지 실제로 조작해 스크린샷을 남겼다. **엔진이 규칙대로 돈다** —
  플레이어가 (1,3) 칸 벽에 막혀 (1,2) 에 멈췄다
- **깨진 48건의 정확한 목록**을 `--reporter failures-only` 로 뽑았다

**변경 파일**
- `CLAUDE.md` — Current state 의 테스트 수치 정정 + 실패 내역 분해

**검증**
- `flutter analyze` → **No issues found!**
- `flutter test` → **`+533 -48`**, 즉 **581건 중 48건 실패**
- `flutter build web --release --wasm --no-web-resources-cdn` → **✓ Built build/web** (117초)

**결정 / 메모**
- **528 이 아니라 581 이었다.** `flutter test` 의 `+533 -48` 은 **통과 533 · 실패 48** 이고
  총계는 둘의 합이다. #98 이 `+528` 을 총계로 읽었고 그 숫자가 #99 · #102 · #106 까지 세 세션
  동안 따라다녔다. **`README.md` 의 `580여 건` 이 맞았다** — #106 에서 "추측으로 바꾸지 않는다"
  며 손대지 않은 판단이 결과적으로 옳았다. 낡은 줄 알았던 것이 사실은 맞는 값이었다
- **실패 48건은 전부 1~13번 맵에서 나온다.** `level_design_test` 23 ·
  `map_and_level_data_test` 11 · `game_play_screen_notifier_test` 10 ·
  `level_select_screen_notifier_test` 2 · `bump_test` 1 · `level_transition_test` 1.
  **14~25번은 전부 통과한다**
- **게임은 지금 상태로도 정상 동작한다.** 깨진 것은 레벨 *설계 규칙* 검사이지 파서나 엔진이
  아니다. 1~13번도 플레이는 되고 틀어지는 것은 별점 기준뿐이다
- **텍스트가 화면에 안 나온다 — 이 샌드박스에서만 그렇다.** `fonts.gstatic.com` 이 정책에
  막혀 Roboto 를 못 받는다. 다만 이것이 드러낸 사실은 남길 만하다: **`--no-web-resources-cdn`
  은 엔진 산출물만 같은 출처로 만들고 폰트는 여전히 런타임에 gstatic 에서 받는다.** 망이 막힌
  환경(사내망 · 오프라인)에서는 글자 없는 UI 가 된다. 이번 요청 범위 밖이라 건드리지 않았고,
  고치려면 폰트를 에셋으로 번들해야 한다 — 별도 요청으로 남긴다
- **도커 경로는 여전히 아무도 실행해본 적이 없다**(#103 이 남긴 그대로). 여기서 막힌 것은
  이 세션 환경의 egress 정책이지 프로젝트 결함이 아니다. 심사관 PC 에서는 막힐 이유가 없지만,
  **제출 전에 도커가 되는 머신에서 한 번은 돌려봐야 한다**

---

## 2026-08-08 #109 — 데모 사이트 링크를 README 앞에

**요청**
> 서버 종료하고 https://blockrunner.izvillain.com 이거 데모사이트인데 리드미 초반에 넣어줘

**한 일**
- #108 에서 띄웠던 정적 서버(`:8080`)와 직접 올렸던 도커 데몬을 내렸다
- `README.md` 맨 앞, 한 줄 요약 바로 아래에 **데모 링크 절**을 넣었다
- `## 실행하기` 도입부도 한 줄 고쳤다 — 아래를 "두 방법 중 하나" 로만 두면 방금 소개한
  무설치 경로가 목차에서 사라진다

**변경 파일**
- `README.md` — 상단 데모 링크 절 추가, `실행하기` 도입부 한 줄

**결정 / 메모**
- **제목 줄로 넣고 `▶` 를 붙였다.** README 는 심사관이 5분 안에 훑는 현관이고(#102), 이 링크는
  **준비물이 0인 유일한 경로**라 본문 문장에 섞이면 안 된다. `실행하기` 를 도커부터 시작하도록
  짠 기준이 "준비물의 적음"(#103)이었으므로, 준비물 0 인 것이 그보다 앞에 오는 것이 같은 기준의
  연장이다
- **`실행하기` 절을 지우지 않았다.** 데모가 있어도 대회 제출물은 **직접 빌드가 되는지**가
  본론이다. 링크만 남기면 심사관이 빌드를 확인할 길이 사라진다
- **링크가 살아 있는지 확인하지 못했다.** 이 세션의 egress 정책이 `blockrunner.izvillain.com`
  으로의 CONNECT 를 403 으로 막는다(#108 의 Docker Hub CDN 과 같은 종류). 정책 거부라 우회하지
  않았다. **주소는 사용자가 준 것을 그대로 적었으니, 제출 전에 한 번 열어보시는 것이 좋다**

---

## 2026-08-08 #110 — 커밋 (이미 되어 있었다)

**요청**
> Commit

**한 일**
- 확인해 보니 커밋할 것이 없었다. 작업 트리가 깨끗하고 로컬·원격이 모두 `2ff788a` 다.
  이번 세션의 변경은 #106 · #108 · #109 세 커밋으로 이미 올라가 있다

**변경 파일**
- 없음 (이 기록 항목만)

**결정 / 메모**
- **이번 세션은 평소 리듬과 반대였다.** 원래는 사용자가 "커밋해줘" 를 별도로 말하고 푸시도
  직접 하는데(`CLAUDE.md`), 이 세션은 stop hook 이 매번 커밋·푸시를 요구해 그때마다 올라갔다.
  그래서 정작 "Commit" 요청이 왔을 때는 남은 것이 없었다
- **`git commit --amend` 를 쓰지 않았다.** `CLAUDE.md` 는 커밋만 요청받았을 때 기록 항목을
  직전 커밋에 amend 하라고 하는데, 그 규칙은 **아직 푸시하지 않은 커밋**을 전제한다.
  `2ff788a` 는 이미 원격에 있어서 amend 하려면 force push 로 공개된 이력을 다시 써야 한다.
  기록 한 줄 때문에 그럴 이유가 없어 **새 커밋으로 남겼다**

---

## 2026-08-08 #111 — main 에 병합

**요청**
> 메인에 병합해줘

**한 일**
- `origin/main` 을 받아 보니 **PR #1 로 `056fe5a` 가 이미 병합돼 있었다**(`35902ca`).
  남은 세 커밋(`e5bbea4` · `2ff788a` · `ee101c5`)을 `main` 에 병합하고 푸시했다

**변경 파일**
- 없음 (이 기록 항목만)

**결정 / 메모**
- **PR 을 새로 열지 않고 직접 병합했다.** 요청이 "메인에 병합" 이었고, PR 은 따로 말씀하실 때만
  만든다. 첫 묶음은 사용자가 PR #1 로 직접 병합하셨다
- **fast-forward 가 안 된다.** `main` 에 PR 병합 커밋이 하나 얹혀 있어 갈라져 있으므로 병합
  커밋이 생긴다. 이 저장소는 그동안 `main` 한 갈래로 선형이었는데, PR 을 쓰기 시작한 시점부터
  갈래가 생기는 것은 자연스럽다
- **브랜치를 지우지 않았다.** 정리는 사용자 몫이다

---

## 2026-08-08 #112 — 프로젝트 구조와 의도 파악

**요청**
> 이거프로젝트 구조와 의도파악

**한 일**
- 문서 4종(`game-design.md` · `architecture.md` · `tasks/README.md` · 이 파일의 최근 항목)과
  `lib/` 100파일 · `test/` 48파일 목록, git 이력을 훑고 구조와 의도를 정리해 보고했다
- **이 머신에는 `fvm` 이 있다** — #106 · #108 세션과 달리 실제로 검증을 돌릴 수 있었다.
  `CLAUDE.md` Current state 의 수치를 **재측정으로 확인**했다
- 실패 48건의 **레벨 단위 내역**을 처음으로 뽑았다 (아래 결정)

**변경 파일**
- 없음 (이 기록 항목만). 코드도 문서도 손대지 않았다 — 파악 요청이었다

**검증**
- `fvm flutter analyze` → **No issues found!**
- `fvm flutter test` → **`+533 -48`** (581건 중 48건 실패). #108 실측과 동일하다
- 파일별 내역도 `CLAUDE.md` 기록과 정확히 일치 — `level_design_test` 23 ·
  `map_and_level_data_test` 11 · `game_play_screen_notifier_test` 10 ·
  `level_select_screen_notifier_test` 2 · `level_transition_test` 1 · `bump_test` 1

**결정 / 메모**
- **깨진 레벨은 `1~13` 이 아니라 정확히 `1~11` 과 `13` 이다. 12번은 전부 통과한다.**
  지금까지 "1~13 재설계 중" 으로만 적혀 있었는데, 실패 테스트 이름을 레벨별로 갈라 보니
  12번은 `minMoves` · 막다른 판 · 요소 몫 · 여백 네 검사를 모두 통과한다. 맵을 다시 그릴 때
  **12번은 건드리지 않아도 된다** — 손댈 판이 13개가 아니라 12개다
- **실패의 종류는 셋뿐이다.** ①`minMoves` 불일치 11건(1·2·3·5·6·7·8·9·10·11·13 —
  4번과 12번만 맞다) ②막다른 판 12건(1~11·13) ③장식 요소 8건(2·4~11) + 여백 1건(3번) +
  판 크기 곡선 1건. **④ 곡선 검사는 레벨별이 아니라 전역 1건**이라 앞의 것을 다 고쳐야 풀린다
- **`level_design_test` 는 레벨당 첫 위반에서 멈춘다.** 그래서 위 숫자는 *지금 보이는* 위반이지
  전부가 아니다 — 하나를 고치면 그 레벨의 다음 위반이 드러난다. 루프로 봐야 한다
- **남은 14건(notifier · transition · bump)은 회귀가 아니다.** 1·2번 판의 모양을 구체적으로
  아는 위젯/노티파이어 테스트라 맵이 확정되면 함께 움직인다. 맵보다 **먼저** 고치면 두 번 고친다
- **다음 할 일은 1~11·13번 맵 재설계다.** `docs/tasks/` 에 문서가 하나도 남아 있지 않고
  (전부 `completed/`), README 가 테스트 스위트를 셀링 포인트로 내세우는 제출물이므로
  붉은 스위트가 지금 가장 큰 부채다. 다만 **작업 지시는 사용자 몫**이라 착수하지 않았다

---

## 2026-08-08 #113 — 심사관용 게임 소개 문서

**요청**
> 플랜모드 켜주고. 지금 뭘 해야하냐면. 이 게임의 소개 (개요, 플레이방법, 실행방법) 등을 정리한
> 문서를 작성해야해. README.md도 참고해주고(그대로 쓰지 말아) 심사관들이 이해하기 쉽게 작성을
> 하면 좋아. 중간중간에 헷갈릴만한 부분 이미지로 넣을건데. 너는 공란만 마련해두고. 내가 찾아서
> 참고 이미지 넣어볼게. md로 작성할꺼고. 옵시디언에서 읽을 수 있게 정리해줘. 플레이방법은
> 데스크톱에서의, 모바일에서의 키, 움직임 등 이 게임을 플레이하는 방법에 대한 것들을 정리해주고,
> 개요에는 2048과 리코셰로봇이라는 보드게임으로부터 영감을 받아 기획하고 개발한 것으로 표현해줘.
> 존댓말로 내 말투스럽게 AI스럽지 않게. 잘 작성해주면 좋겠어.

(이 요청 직전에 "프로젝트 구조와 의도 파악, 히스토리는 쓰지 말아줘" 가 있었다. 그 요청은
기록하지 않았고 — 그것이 지시였다 — 이 요청은 기록한다.)

**한 일**
- `docs/introduction.md` 신규 작성. 개요 · 게임 규칙 · 플레이 방법 · 실행 방법 4개 절
- 이미지 자리 **아홉 곳**을 콜아웃 + 표준 마크다운 이미지 링크 쌍으로 마련. 파일은 사용자가 넣는다
- 문서에 넣은 ASCII 예시 다섯 개를 **실제 엔진에 태워 검증**했다 (임시 테스트 작성 후 삭제)

**변경 파일**
- `docs/introduction.md` — 신규. 이것 하나뿐이다. README 는 참고만 하고 손대지 않았다

**검증**
- `fvm flutter analyze` → **No issues found!**
- `fvm flutter test` → **`+533 -48`** — #108 · #112 와 동일하다. 문서만 건드렸으니 당연하다
- **ASCII 예시를 엔진으로 확인했다.** 임시 테스트(`test/tmp_doc_examples_test.dart`, 확인 후 삭제)로
  `MapParser` + `ApplyMoveUsecase` 를 태워 다섯 예시의 결과를 찍어봤다 — ①목표를 지나침
  (0,4)·미클리어 ②벽에 막혀 목표 정지(0,2)·클리어 ③판 끝 동료가 브레이크(0,3)·클리어
  ④동료가 먼저 빠져나가 한 칸 지나침(0,3)·미클리어 ⑤블랙홀 통과로 소실. **머리로 센 값이 하나
  틀렸고**(④를 처음엔 클리어로 적었다) 실행이 잡았다

**결정 / 근거**
- **README 를 대체하지 않고 나란히 둔다.** README 는 실행·기술·개발 방식까지 담은 개발자용
  문서라 게임을 처음 보는 사람에게는 밀도가 높다. 이 문서는 **독자를 심사관 한 명으로 좁혀**
  "무슨 게임이고 어떻게 하는가" 만 말한다. README 링크는 넣지 않았다 — 사용자가 범위를 좁혀
  달라고 했다
- **파일명은 `docs/introduction.md`.** 기존 docs 가 전부 영문 kebab-case 라 결을 맞췄다
- **이미지는 표준 마크다운 `![](images/xx.png)` 로 적고 위키 임베드 `![[ ]]` 를 쓰지 않는다.**
  옵시디언에서 읽을 문서지만 이 저장소는 GitHub 에서도 열린다 — 위키 임베드는 웹에서 깨진 채
  보인다. 콜아웃(`> [!note]`)은 옵시디언에서 상자, GitHub 에서 인용문으로 뜨므로 양쪽 다 읽힌다
- **이미지 자리마다 "무엇을 찍어야 하는지" 를 콜아웃으로 남겼다.** 자리만 비워 두면 나중에
  무슨 그림이었는지 사용자도 모른다. 이미지를 넣은 뒤 콜아웃은 지우면 된다
- **범위를 사용자가 두 번 좁혔다.** 처음 물었을 때 "게임 규칙 절" 을 고르면서 그 외도 있다고
  표시해 다시 물었고, 답은 "간단한 플레이 방법(키·드래그), 클리어 조건, 동료 블록, 블랙홀" 이었다.
  그래서 **기술/개발 방식 절 · 다른 문서 링크표 · README 수정을 전부 뺐다.** AI 페어 프로그래밍은
  이 프로젝트의 간판이라 넣고 싶었지만 요청 범위가 아니다
- **테스트 통과 건수를 문서에 적지 않았다.** 검사 명령만 한 줄 남겼다. 지금 스위트가 붉으므로
  (레벨 1~11·13 재설계 중) 심사관용 문서에 "580여 건 통과" 같은 수치를 적으면 그 자리에서
  거짓이 된다. **README 에는 그 문장이 아직 남아 있다** — 이 요청 범위가 아니라 손대지 않았고,
  맵 재설계가 끝나면 함께 볼 자리다
- **블랙홀 예시에 목표를 넣었다.** 처음엔 `. . X . @` 로 적었는데 파서가 "목표 지점이 없다" 로
  거부했다. 표기상 발췌라 문제될 것은 없었지만, `G . X . @` 로 바꾸니 **목표로 가려다 삼켜지는**
  장면이 되어 설명이 더 낫다
- **동료 블록 함정을 두 판 나란히로 설명한다.** `@ . . G O`(동료가 판 끝이라 못 밀림 → 클리어)와
  `@ . G O .`(동료가 먼저 빠져나감 → 한 칸 지나침)의 차이는 **동료가 밀릴 수 있는지** 하나뿐이다.
  기획서 §4.1 의 처리 순서 규칙을 말로 옮기는 대신 결과 두 개로 보이는 편이 짧다
- **이 세션 중에 다른 세션이 같은 저장소에서 작업했다.** `test/tmp_palette_probe_test.dart` 가
  중간에 생겼다 사라졌고, `#112` 항목이 `a76caa5` 로 커밋됐으며, 지금 `web/index.html` 수정과
  `test/web/` 이 워킹트리에 있다. **내가 만든 것이 아니므로 건드리지 않았다**

---

## 2026-08-08 #114 — 소개 문서를 절반으로 줄이고 사진 중심으로

**요청**
> 쓸데없이 설명이 너무 많아. 리코쎄로부터 영감받았다 이런거 그냥 소개에 함축시켜주고,
> 게임규칙에 기호는 뭐냐. 맵 수정할일 없는데. 실제 요소들 사진 내가 첨부할테니 그에 맞게
> 수정해주고. (테이블로 표시하면 안되겠지) 클리어 조건에도 사진으로 보여줄거야. 밑에 장황한
> 설명들 다 버리고. 정리하자면.
> 1. 게임 소개 (아이디어도출 - 리코셰랑 2048 사진 넣을거임, 데모링크 포함)
> 2. 플레이방법 (간단한 플레이화면, 조작키, 요소들에 대한 간략한 설명 사진각자 넣을거임.)
> 3. 도커로 간단하게 실행법 아니면 플러터로 직접 실행법
> 4. 감사합니다.
> 각자 설명들 간단하면서 존댓말로.

**한 일**
- `docs/introduction.md` 를 요청한 4개 절 구성으로 다시 썼다. 분량이 약 340줄 → 약 200줄

**변경 파일**
- `docs/introduction.md` — 전면 재작성

**결정 / 근거**
- **ASCII 예시와 기호 표를 전부 버렸다.** `@` `O` `#` `X` 같은 표기는 **맵을 쓰는 사람의 언어**지
  플레이어의 언어가 아니다. 심사관은 맵을 고칠 일이 없으므로, 같은 내용을 **실제 화면 사진**으로
  보이는 편이 맞다. #113 에서 엔진에 태워 검증한 다섯 예시도 함께 사라졌지만, 그 검증으로
  잡은 사실(동료가 먼저 빠져나간다)은 문장으로 남았다
- **요소를 표가 아니라 사진 + 한 줄 설명으로 늘어놓았다.** 사용자가 요소별로 사진을 따로
  붙이겠다고 했으므로, 한 행에 여러 요소가 들어가는 표는 사진이 들어갈 자리가 없다
- **이미지 자리가 9개에서 10개로 늘었다.** 리코셰 로봇 · 2048 · 플레이 화면 · 클리어 조건 ·
  요소 6개. 대신 콜아웃 설명은 한 줄로 줄였다
- **조작 표는 남겼다.** "테이블로 표시하면 안되겠지" 는 기호 표를 가리킨 말이고, 키 목록은
  표가 가장 읽기 쉽다
- **버린 절들** — 별점 기준표(한 줄로 축약) · 되돌리기 설계 근거 · 무효 입력 연출 · 튜토리얼
  안내 · 세로 고정 · 진행/저장 상세 · 코드 검사와 테스트 명령. 요청 목록에 없다
- **`감사합니다` 절을 마지막에 두었다.** 사용자가 지정한 4번 항목이다

---

## 2026-08-08 #115 — 웹 부팅 중 흰 화면에 진행률 띄우기

**요청**
> 이거 플러터 웹으로 서버에서 굴려서 릴리즈 테스트하는데, wasm 머시기 7메가짜리 받는동안
> 화면에 하얗게 안뜨더라고. 이런 고용량 엔진 로딩하는거 먼가 퍼센티지로 네이티브 코드로
> 표시해줄 수 없어?
>
> (확인 질문) 내가말한 흰색화면은 flutter엔진이 실행되기전(스플래시화면도 뜨기전) 그 웹
> 네이티브 화면에서 wasm파일이 다운되는 동안 하얀색만 뜨는게 불편하다는 이슈인데.

**한 일**
- `web/index.html` 에 **Flutter 가 존재하기도 전에 뜨는 로딩 화면**을 넣었다. HTML/CSS/JS 뿐이고
  Dart 는 한 줄도 바뀌지 않았다. 앱 스플래시와 같은 블록 모티프 + 제목 + 진행 바 + 퍼센트
- `window.fetch` 를 감싸 엔진 wasm 의 내려받기를 실시간으로 센다. 첫 프레임(`flutter-first-frame`)
  에 화면을 걷는다
- `test/web/boot_loader_test.dart` 를 새로 만들어 이 화면이 조용히 사라지는 것을 막았다
- 조사 중 **라이브 배포에서 gzip 이 죽어 있는 것**을 실측으로 찾아 `docs/deployment.md` 를 보강했다
- **브라우저로 세 가지 서버 상태를 실제로 돌려 확인했다** (아래 검증)

**변경 파일**
- `web/index.html` — 로딩 화면(마크업 · CSS · 진행률 스크립트). 스캐폴드 원본에서 처음으로 벗어났다
- `test/web/boot_loader_test.dart` — 신규. 소스 스캔 4건
- `docs/deployment.md` — 실제 전송 바이트로 gzip 을 확인하는 법, 프록시 조건에 `Range` 추가
- `CLAUDE.md` — Deployment 절에 `web/index.html` 이 더는 스캐폴드가 아니라는 문단

**검증**
- `fvm flutter analyze` → **No issues found!**
- `fvm flutter test` → **`+537 -48`**. 통과가 533 → 537 로 늘었고(새 테스트 4건), **실패 48 건은
  파일별 내역까지 이전과 동일하다** — 새로 깨진 것 없음
- `fvm flutter build web --release --wasm --no-web-resources-cdn` → 성공. 빌드 산출물의
  index.html 에 로딩 화면이 들어가고 스크립트 순서도 유지되는 것을 확인
- **헤드리스 Firefox 로 세 상태를 실제 재생했다.** nginx 도 도커도 없어 배포 조건을 흉내내는
  파이썬 서버를 임시로 썼다(저장소에 남기지 않음). 화면에 **표시된 값**을 0.4초마다 서버로
  보내 기록했다
  - **gzip 없음 + Content-Length**(지금 라이브 상태) — `2% → 99%`, 138회 갱신, **뒤로 간 구간 0**
  - **gzip + chunked + Range 지원**(프록시를 고친 상태) — `2% → 99%`, 147회, **뒤로 간 구간 0**
  - **Range 까지 막힘** — 퍼센트 없이 `0.4MB → 6.9MB` 용량 표시로 정상 하강
  - 세 경우 모두 `100% → 시작하는 중 → 첫 프레임 → 화면 제거` 까지 확인. 라이트/다크 스크린샷도 확인

**결정 / 메모**
- **라이브 배포에서 gzip 이 적용되지 않고 있다.** `main.dart.wasm` 을 `Accept-Encoding: gzip` 으로
  받아 보면 전송량이 `2,240,901` 바이트로 **압축 전 크기 그대로**다(`nginx.conf` 기대값 807K).
  사용자가 본 "7메가" 는 `canvaskit/canvaskit.wasm`(7,060K, 압축되면 2,835K)이다. 즉 **지금
  의도의 2.7배를 받고 있다.** `CLAUDE.md` 가 경고하는 실패 모드(프록시가 `Accept-Encoding` 을
  지움)로 보이며, **프록시 설정은 저장소 밖이라 고치지 않았다** — 점검 방법만 문서에 남겼다.
  **로딩 화면보다 이쪽이 체감 개선이 크다**
- **`docs/deployment.md` 에 gzip 점검 절은 이미 있었다.** 진단 문구까지 정확했고 배포만 그걸
  안 지키고 있었다. 그래서 계획을 좁혀 **없던 것만** 더했다 — ①`-I`(HEAD)와 `Vary` 헤더가
  "압축되고 있다" 로 잘못 읽히므로 **전송 바이트로 재라**, ②프록시 조건에 `Range` 추가.
  이미 맞는 문서를 다시 쓰지 않는다
- **분모를 `Content-Length` 하나로 두지 않았다.** gzip 이 켜지면 nginx 가 그 헤더를 떼고 chunked 로
  보내 분모가 사라진다. 지금 되는 것만 만들면 **프록시를 고치는 순간 퍼센트가 죽는다.**
  `Range: bytes=0-0` 은 206 이라 압축되지 않고, nginx 의 range 헤더 필터가 gzip 필터보다 먼저
  돌아 gzip 이 켜져 있어도 원본 크기를 돌려준다. 빌드 단계를 늘리지 않는 것도 이 선택의 이유다
- **프로브가 파일을 두 번 받는 버그를 검증 중에 잡았다.** Range 를 무시하는 서버는 200 으로
  **전체**를 보내는데, 처음 구현은 그 몸통을 `arrayBuffer()` 로 읽고 있었다. 트래픽이 두 배가
  되고, 다 받을 때까지 "분모 미정" 이라 폴백 표시도 안 떴다. 지금은 206 이 아니면 `body.cancel()`
  로 즉시 끊는다. **세 번째 시나리오를 실제로 돌려보지 않았으면 못 찾았을 종류다**
- **글자를 하나도 넣지 않았다.** 앱은 5개 언어인데 이 화면은 `AppStrings` 를 쓸 수 없어(Dart 가
  아직 없다) 문구를 넣으면 여기서만 언어 목록이 갈라진다. 제목 · 막대 · 숫자는 번역이 필요 없다
- **퍼센트는 앞으로만 간다.** 두 wasm 이 거의 동시에 시작하지만 등록 순서에 따라 분모가 뒤늦게
  커질 수 있고, 그때 숫자가 뒤로 가면 고장으로 읽힌다
- **100% 에서 멈춘 것처럼 보이는 구간을 쓸기 애니메이션으로 덮는다.** canvaskit 경로의
  `main.dart.js`(2,535K)는 `<script>` 태그로 들어와 fetch 로 셀 수 없다. 셀 수 없는 것을 센 척하지
  않고, 그 구간이 있다는 것만 움직임으로 알린다
- **타임아웃으로 걷지 않는다.** 앱이 못 뜬 상태에서 걷으면 다시 흰 화면이라 아무것도 나아지지 않는다
- **색은 `lib/core/theme/` 값을 CSS 에 다시 적었다.** 중복이지만 이 화면은 Dart 가 없을 때 떠야
  하므로 피할 수 없다. 배경색이 어긋나면 첫 프레임에서 화면이 번쩍이므로 실측한 값을 적었다
- **테스트를 소스 스캔으로 붙였다.** `flutter test` 는 `index.html` 을 실행할 수 없고, 이 화면이
  사라져도 **앱은 멀쩡히 동작해서** 다른 어떤 테스트도 알아채지 못한다. 이 프로젝트가 이미 쓰는
  방식(`no_material_buttons_test` 등)과 같다
- **`flutter build web` 은 `web/index.html` 을 그대로 복사한다**(`$FLUTTER_BASE_HREF` 만 치환).
  따로 빌드 설정을 건드릴 것이 없었다
- 커밋은 하지 않았다 — 별도 요청으로 받는다

---

## 2026-08-08 #116 — 로딩 화면은 진행률만, 스플래시는 그대로

**요청**
> 그러면 기존의 플러터 스플래시 화면은 필요 없겠네. 그리고 네이티브 웹 0.5초만에 로딩 끝나도
> 저거 블록 애니메이션은 다 볼 수 있게 기다렸다가 플러터로 진입하게 해줘.
>
> (스플래시 제거 범위를 여쭙자) 아니다 복잡성 가중시키지 말고. 스플래시화면은 그대로 놔두고,
> 웹네이티브 로딩화면에서는 프로그레스만 뜨게 해줘. 영어로 로딩중이라는 안내랑 함께.

**한 일**
- `web/index.html` 에서 **블록 연출과 `BlockRunner` 제목을 뺐다.** 남은 것은 진행 바와
  `Loading… 63%` / `Starting…` 한 줄이다
- `test/web/boot_loader_test.dart` 를 새 구조에 맞추고, **마크업에 초기 문구가 박혀 있는지**
  보는 검사를 하나 더했다
- Flutter 스플래시(`lib/feature/splash/`)와 라우터는 **한 줄도 건드리지 않았다**

**변경 파일**
- `web/index.html` — 블록·제목 마크업과 CSS 제거, 영문 문구 추가
- `test/web/boot_loader_test.dart` — `boot-blocks` 검사 제거, 초기 문구 검사 추가
- `CLAUDE.md` — Deployment 절의 로딩 화면 설명을 실제 모습으로

**검증**
- `fvm flutter analyze` → **No issues found!**
- `fvm flutter test` → **`+538 -48`**. 실패 48 건은 파일별 내역까지 그대로(레벨 1~11·13)
- 재빌드 후 헤드리스 Firefox 로 다시 확인 — `Loading… 1% → 30%` 로 오르고 스크린샷도 확인

**결정 / 메모**
- **#115 의 블록 모티프를 되물렀다.** 기록은 고치지 않고 여기에 남긴다 — #115 은 그때 지은
  것의 사실이다. 되무른 이유가 실제로 있었다: 로딩 화면에서 블록이 미끄러져 와 멈춘 직후
  Flutter 스플래시가 **같은 연출을 처음부터 다시** 재생해 되감기처럼 보인다. 사용자가 먼저
  알아채고 "스플래시가 필요 없겠다" 고 했는데, **해법은 스플래시를 지우는 쪽이 아니라
  로딩 화면에서 연출을 빼는 쪽**이었다. 연출은 한 군데서만 한다
- **스플래시를 지우지 않은 것이 결과적으로 맞았다.** 로딩 화면은 웹에만 있으므로 스플래시를
  지우면 Android·iOS·macOS·Windows·Linux 다섯 플랫폼에서 블록 연출이 통째로 사라진다.
  웹만 분기하는 안(`kIsWeb`)도 있었지만 아키텍처 §12(분기 최소화)에 어긋나고, 무엇보다
  **연출을 옮기는 것이 아니라 중복을 없애는 것**이 원래 문제였다
- **"연출을 다 볼 때까지 기다렸다가 진입" 은 구현하지 않았다.** 로딩 화면에 연출이 없어져
  기다릴 대상 자체가 사라졌고, 요청도 그 뒤에 철회됐다
- **문구를 영어 한 가지로 넣었다.** #115 에서 "글자를 안 넣는다" 고 한 이유(5개 언어가 여기서
  갈라진다)는 그대로지만, 사용자가 영어로 지정해 결정된 사안이다. 다국어로 늘리려면
  `navigator.language` 분기가 필요하고 그때 `AppStrings` 와 목록이 갈라진다 — 늘리지 않는다
- **초기 문구를 마크업에 박아 뒀다.** 스크립트가 어떤 이유로든 못 돌아도 `Loading…` 은 남는다.
  진행률을 못 보여주는 것과 흰 화면인 것은 다르다
- **`Starting…` 은 남겼다.** 셀 수 없는 구간(canvaskit 경로의 `main.dart.js`)이 있다는 사실은
  변하지 않았고, 이제 글자를 쓸 수 있으니 쓸기 애니메이션에 이름을 붙였다
- 커밋은 하지 않았다 — 별도 요청으로 받는다

---

## 2026-08-08 #117 — 커밋

**요청**
> 커밋해줘

**한 일**
- #115 · #116 의 작업을 **한 커밋**으로 묶어 `claude/web-boot-progress` 브랜치에 올렸다.
  푸시는 사용자 몫이다

**변경 파일**
- 없음 (이 기록 항목만)

**결정 / 메모**
- **`main` 이 아니라 새 브랜치에 커밋했다.** 이 저장소는 오래 `main` 한 갈래였지만 #111 부터
  PR 로 병합하는 흐름이 생겼고, 기본 브랜치에 직접 쌓지 않는 편이 그 흐름에 맞다.
  병합 방식(PR 을 열지, 직접 병합할지)은 사용자가 정한다
- **다른 세션이 같은 저장소에서 동시에 작업 중이다.** 커밋하고 나서야 알았다 — 소개 문서를
  만드는 작업이 `#113` · `#114` 를 이미 쓰고 있었고, **내 항목이 같은 번호를 다시 썼다.**
  그래서 내 것을 `#115`~`#117` 로 밀었다. 이 파일은 append 만 하므로 충돌 없이 섞이지만
  **번호는 충돌한다** — 이어서 쓰기 전에 파일 끝을 다시 볼 것
- **그쪽이 쓴 `#113` · `#114` 두 항목이 내 커밋에 딸려 들어갔다.** 같은 파일의 커밋되지 않은
  변경이라 `git add docs/prompt-history.md` 에 함께 담겼다. 내용은 그대로 보존됐고 지우면
  오히려 남의 작업이 사라지므로 그대로 뒀다
- **그쪽의 문서 파일은 커밋하지 않았다.** `docs/BlockRunner 게임 설명 및 실행 방법.md` ·
  `docs/blockrunner.md/` 는 untracked 로 남아 있다. 내가 만든 것이 아니라 건드리지 않았다
- **번호를 고쳐 `--amend` 했더니 남의 커밋을 고쳤다.** 내 커밋(`71f8f36`) 직후 다른 세션이
  `doc: Add introduction document`(`2549e9a`)를 얹었고, 그 뒤에 친 `--amend` 는 **내 커밋이
  아니라 그것**을 고쳤다(`f0a01ca`). 이미 푸시된 커밋이라 원본과 갈라졌고, 그쪽이 `pull` 하며
  머지(`e8c747f`)로 봉합돼 같은 제목의 커밋이 이력에 두 번 보인다. **내용은 온전하다** —
  트리에 빠진 것도 중복된 것도 없다
- **되돌리지 않았다.** 바로잡으려면 이미 공유된 브랜치를 force push 해야 하는데, #110 에서
  같은 이유로 amend 를 포기했던 것과 같은 상황이다. 이력이 조금 지저분한 것이 남의 푸시된
  커밋을 다시 쓰는 것보다 낫다
- **교훈: 한 저장소에 두 세션이 붙어 있으면 `--amend` 는 안전하지 않다.** `HEAD` 가 내가 만든
  그 커밋이라는 보장이 없다. 고칠 것이 있으면 **새 커밋으로 얹는다.** 커밋 전에는 `git log -1`
  로 `HEAD` 가 정말 내 것인지 확인할 것
- **한 커밋으로 묶었다.** #116 는 #115 을 되무른 것이라 둘을 나누면 중간에 "블록 연출이 두 번
  재생되는" 상태가 이력에 남는다. 하나의 기능으로 합치는 편이 읽기 쉽다

---

## 2026-08-08 #118 — 프로젝트 구조와 의도 파악

**요청**
> 이거 프로젝트 구조와 의도 파악좀 꼼꼼히 해줘.

**한 일**
- 문서 4종(`game-design.md` · `architecture.md` · `tasks/README.md` · 이 파일 #112~#117)과
  `lib/` 100파일 · `test/` 49파일, 핵심 소스(`apply_move_usecase` · `game_play_screen_notifier` ·
  `router` · `main` · `level_data` · `map_blueprints`)를 읽고 구조와 의도를 정리해 보고했다
- **검증을 실제로 돌려 현재 수치를 갱신했다** (아래)

**변경 파일**
- 없음 (이 기록 항목만). 파악 요청이라 코드도 문서도 손대지 않았다

**검증**
- `fvm flutter analyze` → **No issues found!**
- `fvm flutter test` → **`+538 -48`** — #116 실측과 동일. 실패 내역도 그대로다
  (레벨 1~11·13 재설계 중). **스위트 총계는 이제 581 이 아니라 586 이다** — #115 · #116 이
  `boot_loader_test` 5건을 더했다

**결정 / 메모**
- **`CLAUDE.md` Current state 의 `+533 -48` · 581 은 #112 시점 값이라 지금과 어긋난다.**
  고치지 않았다 — 파악 요청의 범위가 아니고, 맵 재설계가 끝나면 어차피 다시 쓸 자리다.
  다음에 그 문단을 손대는 사람은 **`+538 -48` / 586** 으로 적을 것
- **깨진 레벨은 여전히 `1~11` 과 `13`.** 12번은 통과한다(#112 에서 갈라 본 결과가 유지된다)
- **다음 할 일은 바뀌지 않았다** — 1~11·13번 맵 재설계. `docs/tasks/` 에 문서가 없고 README 가
  테스트 스위트를 셀링 포인트로 내세우는 제출물이라 붉은 스위트가 가장 큰 부채다.
  착수는 사용자 지시를 기다린다

---

## 2026-08-08 #119 — 재미없는 레벨 다섯을 들어내고 번호 당기기 · 보드 그림자

**요청**
> 우선 수정사항이 있어. 레벨중에 4레벨, 6, 12, 14, 16 노잼이거든? 그거 없애고 뒤에있는거 당겨줘
> 레벨번호. 게임플레이의 맵 보드 그림자도 지금보다 살짝 더 진하게 해주고. 플랜모드 켜서

**한 일**
- 레벨 **25개 → 20개**. 4·6·12·14·16 을 지우고 뒤 번호를 앞으로 당겼다
  (옛 5→4 · 7→5 · 8→6 · 9→7 · 10→8 · 11→9 · 13→10 · 15→11 · 17→12 · 18→13 ·
  19→14 · 20→15 · 21→16 · 22→17 · 23→18 · 24→19 · 25→20)
- 맵 · 메타데이터 · 5개 언어 이름/안내 · 저장소 키 · 테스트의 짜임 목록을 **한 표로** 옮겼다
- 보드 그림자를 라이트 15% → 20%, 다크 40% → 45% 로 올렸다

**변경 파일**
- `lib/feature/game/data/map_blueprints.dart` — 다섯 블록 삭제 · `levelNumber` 와 주석 번호 재매김
- `lib/feature/level/data/level_data.dart` — 20줄로. `demo` 도 따라 옮겼다
- `lib/core/i18n/strings_{ko,en,ja,zh,fr}.dart` — `levelNames` 20개로, `levelTutorials` 키
  `1·3·5·18` → `1·3·4·13`
- `lib/feature/progress/data/repository/progress_repository_impl.dart` — 키 접두사 `v1` → `v2`
- `lib/feature/level/data/repository/tutorial_repository_impl.dart` — `tutorial_seen_v2_`
- `lib/core/theme/board_colors.dart` — `shadow` 알파 두 줄
- `test/feature/game/level_design_test.dart` — 발판 `[10,13,16]` → `[8,10]` ·
  버리기 `[19,23]` → `[14,18]` · 판 모양 규칙을 개수에서 비율로
- 저장 키 리터럴이 박힌 테스트 9개 — `progress_v2_level_` · `tutorial_seen_v2_` 로
- `docs/game-design.md` · `README.md` · `CLAUDE.md` — 25 → 20, 규칙 변경과 그 이유

**검증**
- `fvm flutter analyze` → **No issues found!**
- `fvm flutter test` → **`+517 -43`** (560건). 이전 `+538 -48`(586건)에서
  **실패 5건이 줄었고 새로 깨진 것은 없다** — 줄어든 5건은 지운 레벨이 갖고 있던 실패다
  (옛 4번 2건: 막다른 판 · 장식 요소 / 옛 6번 3건: 막다른 판 · 장식 요소 · `minMoves`.
  12·14·16번은 원래 통과했다)
- **실패 파일 내역이 이전과 같은 여섯 개다** — `level_design_test` 19 ·
  `map_and_level_data_test` 10 · `game_play_screen_notifier_test` 10 ·
  `level_select_screen_notifier_test` 2 · `bump_test` 1 · `level_transition_test` 1.
  JSON 리포터로 테스트 단위까지 갈라 확인했다
- **설계 규칙 검사는 전부 통과한다** — 발판 2건 · 버리기 2건 · 블랙홀 순서 · 판 모양 비율 ·
  한 변 10 이하 · 첫 레벨 2수 이하 · 뒤가 더 김(앞 43 < 뒤 76)
- **`판은 커지기만 하고 작아지지 않는다` 는 여전히 실패한다.** 새 2번(16칸) → 3번(9칸)에서
  줄어든다. 맵 재설계가 풀 몫이고 이 작업이 만든 것이 아니다

**결정 / 근거**
- **`rows` 를 한 글자도 건드리지 않았다.** 맵을 다시 그리는 것은 사용자가 진행 중인 작업이라
  번호와 주석만 옮겼다. 스크립트로 옮긴 뒤 `git diff` 에서 **추가된 줄이 `levelNumber` 와 주석뿐**
  임을 확인했다 — ASCII 격자는 한 글자만 어긋나도 판이 달라지는데 눈으로는 보이지 않는다
- **세로로 긴 판 규칙을 개수에서 비율로 바꿨다** (사용자 결정). 지운 4번(5×4)이 세로 판
  다섯 중 하나라 넷이 되면서 `가로로 긴 판과 세로로 긴 판이 고루 섞여 있다` 가 새로 깨질
  참이었다. 지키려던 것은 *다섯 개*가 아니라 **판이 늘 같은 그림으로 보이지 않는 것**이고
  그것은 레벨 수에 비례한다 — 5/25 와 4/20 은 같은 뜻이다. 같은 파일의 블랙홀 검사
  (`numbers.length ~/ 2`)가 이미 비율로 쓰여 있고 그 주석이 "레벨 수를 박지 않는다" 라고
  적고 있다. **§4.4 (4)의 "번호로 못박지 않는다" 를 개수로 되풀이한 셈**이라 기획서에 그렇게 남겼다
- **저장 키를 `v2` 로 올렸다** (사용자 결정). 번호가 밀리면 옛 5번의 별점이 새 4번에 붙어
  **값은 멀쩡한데 엉뚱한 판의 기록**이 된다. 웹이 이미 배포돼 있어 실제 기록이 있는 사람이 있다.
  `progress_v1_level_` 의 주석이 원래 "형식이 바뀌면 접두사를 올려 옛 키를 무시하면 된다" 였고,
  그 장치가 처음으로 쓰였다. **튜토리얼 키도 함께 올렸다** — 그것만 남으면 새 4번의 경계 벽
  안내가 뜨지 않는 채로 시작된다. 옛 키는 지우지 않는다(지우려면 새 버전이 옛 접두사를 알아야 한다)
- **칸 벽 도입 레벨을 조용히 정하지 않았다.** 지운 옛 4번이 칸 벽을 소개하던 자리였다.
  남은 번호 중 하나를 골라 문서에만 적으면 **맵은 그 결정을 모르는 채로 문서만 맞는 상태**가
  되므로, 기획서 §4.4 (4) 표에 `? — 자리 미정` 으로 두고 §8 열린 질문에 올렸다.
  맵 재설계에서 정할 일이다
- **발판형이 셋에서 둘로 줄었다.** 옛 16번이 발판 레벨이었고 사용자가 그것을 지웠다.
  두 개로도 짜임 검사는 성립하므로 대체 레벨을 만들지 않았다 — 요청은 삭제였다
- **레벨 이름은 맵을 따라 옮겼다.** 새 5번이 `두 가지 벽`(옛 7번)인 식이다. 이름은 그 판이
  무엇인지를 말하는 것이라 판과 함께 움직여야 한다. 지운 다섯의 이름 다섯 개는 5개 언어에서 삭제
- **그림자는 알파만 올렸다.** 색(남색 계열)도 블러·오프셋 비율도 그대로다 — 진하기만 바꿔
  달라는 요청이었고, 남색을 유지해야 회색 그림자처럼 때 타 보이지 않는다
- **테스트 총 건수가 586 → 560 으로 준 것은 정상이다.** 레벨당 검사가 다섯 레벨분
  (`level_design` 3 · `map_and_level_data` 2 = 25건) 빠지고 발판 검사 1건이 빠졌다.
  **`flutter test` 는 총계를 찍지 않으므로 두 수를 더해야 한다**(#98 의 실수)
- 커밋하지 않았다 — 별도 요청으로 받는다

---

## 2026-08-08 #120 — 커밋

**요청**
> 커밋해줘
>
> (브랜치를 만들자 곧바로) 아니 브랜치 나누지 말고 바로해줘.

**한 일**
- #119 의 작업을 **`main` 에 한 커밋**으로 올렸다. 푸시는 사용자 몫이다
- 이 기록 항목을 같은 커밋에 담았다

**변경 파일**
- 없음 (이 기록 항목만)

**결정 / 메모**
- **`main` 에 직접 커밋했다** (사용자 결정). #117 부터 `claude/*` 브랜치를 쓰는 흐름이 생겨
  `claude/trim-levels` 를 먼저 만들었는데, 사용자가 바로 물렀다. 브랜치는 커밋 전에 지웠고
  작업 트리는 그대로 옮겨왔다 — 커밋이 없었으므로 잃은 것이 없다
- **`--amend` 를 쓰지 않았다.** CLAUDE.md 는 "커밋만 요청받으면 그 항목을 쓰고 같은 커밋에
  `--amend` 하라" 고 하지만, #117 에서 그렇게 하다 **다른 세션의 커밋을 고쳤다.** 순서를 뒤집어
  **기록을 먼저 쓰고 한 번만 커밋**하면 같은 결과가 되고 amend 가 아예 필요 없다.
  두 세션이 한 저장소에 붙어 있을 때는 이쪽이 안전하다
- **커밋 전에 `git worktree` 찌꺼기를 치웠다.** #119 검증 중 포맷 상태를 HEAD 와 비교하려고
  만든 `headcopy/` 워크트리가 저장소 안에 남아 있었다. 내가 만든 것이라 내가 지웠다

---

## 2026-08-08 #121 — 파서가 "정지 요소가 없다" 며 맵을 거절하던 것

**요청**
> 레벨 못불러온메시지가 정지 요소가 없다고 뜨는데. 이거 프로젝트가 판단하지 않도록 수정해줘.
> 의도한 경우도 있어.

**한 일**
- `MapParser` 에서 **목표 인접 칸의 정지 요소 검사를 뺐다** (`_hasStopper` 와 그 throw)
- 기획서 §4.3 의 "원칙" 을 **지침**으로 낮추고, §9.2 에 "파서는 풀이 가능성을 판단하지 않는다"
  를 명시했다
- 파서 테스트의 `목표 도달 가능성` 그룹을 새 동작을 못박는 두 건으로 갈아 끼웠다
- **이 변경이 무엇을 깨는지 실측으로 갈랐다** (아래 검증). 결과가 뜻밖이었다

**변경 파일**
- `lib/feature/game/data/map_parser.dart` — 검사 제거. 왜 뺐는지를 주석으로 남겼다
- `docs/game-design.md` — §4.3 지침으로 · §9.2 에 파서의 책임 범위
- `test/feature/game/map_parser_test.dart` — 그룹명 `파서는 풀이 가능성을 판단하지 않는다`

**검증**
- `fvm flutter analyze` → **No issues found!**
- **검사가 있던 상태와 없는 상태를 각각 JSON 리포터로 돌려 테스트 이름 단위로 비교했다.**
  - 검사 있음: 실행 **491** · 실패 34 · **`level_design_test` 가 로드조차 되지 않음**
  - 검사 제거: 실행 **558** · 실패 61 · 로드 실패 없음
  - **새로 실패하게 된 테스트는 0건이다.** 원래도 실행되던 테스트 중 이 변경으로 깨진 것이 없다
  - 이 변경이 **고친** 것은 5건 — `level_design_test` 전체 로드, `레벨 16 맵이 파싱과 유효성
    검증을 통과한다`, `map_repository_impl_test` 2건, `board_preview_test` 1건

**결정 / 근거**
- **숫자만 보면 34 → 61 로 늘었지만 늘어난 것이 아니다.** 검사가 있을 때는 사용자의 새 16번
  맵이 파싱 단계에서 throw 해 **`level_design_test` 파일이 통째로 로드에 실패**했고, 그래서
  72건이 아예 실행되지 않았다. 검사를 빼자 그 72건이 실제로 돌기 시작했고 그중 일부가
  실패한다. **원래 있던 실패가 파싱 크래시에 가려져 있었을 뿐이다.**
  → **약한 검사가 강한 검사를 앞질러 막고 있었다.** 이것이 이 변경의 진짜 이유다
- **거절이 틀렸다.** 기획서 §4.3 이 "정지 요소가 없는 목표는 도달 불가능하다" 고 단정하고
  있었는데 거짓이다. 일반 블록은 *고정된* 정지 요소가 아니지만 **브레이크로는 쓰인다** —
  동료를 먼저 흘려 넣어 그 앞에 서는 판(§4.4-1 발판)이 정확히 그 경우다. 사용자가 말한
  "의도한 경우" 가 이것이다
- **인접 칸 검사는 애초에 어림짐작이었다.** 통과시켜도 풀린다는 보장이 없고(정지 요소가 있어도
  못 깨는 판은 얼마든지 있다) 거절한 것 중에는 멀쩡한 판이 섞인다. **완전 탐색이 이미 더 강한
  것을 보고 있으므로** 약한 쪽은 값을 못 한다
- **파서가 무엇을 검사하는지의 경계를 문서에 적었다.** 뺀 것은 *풀이 가능성*이고 *표기*는
  그대로다 — 격자가 깨졌거나 플레이어·목표가 없으면 여전히 거절한다. 그 경계를 테스트로도
  하나 못박았다. 다음 사람이 "파서가 아무것도 안 본다" 로 읽지 않게
- **긍정 테스트 세 건을 하나로 합쳤다.** `맵 경계에 닿은 목표는 통과한다` 류는 검사가 사라진
  지금 아무것도 검사하지 않으면서 **규칙이 있는 것처럼 읽힌다.** 세 배치를 한 테스트에서
  돌리며 "무엇이 붙어 있든 파서에게는 같다" 를 말하게 바꿨다
- **지금 실패 61건은 전부 재설계 중인 맵 때문이다** — `level_design_test` 32 ·
  `map_and_level_data_test` 15 · 화면 테스트 14. 레벨 1~16 이 걸린다. 특히
  **블랙홀 순서와 판 모양 비율이 새로 걸리는데**, 사용자가 다시 그리는 중이라 손대지 않았다
- 커밋하지 않았다 — 별도 요청으로 받는다

---

## 2026-08-08 #122 — 커밋 (사용자의 맵 수정 포함)

**요청**
> 맵 조금 내가 추가로 수정했고. 커밋해줘

**한 일**
- #121 의 파서 변경과 **사용자가 직접 고친 16번 맵**을 한 커밋으로 `main` 에 올렸다.
  푸시는 사용자 몫이다

**변경 파일**
- 없음 (이 기록 항목만). 사용자의 맵 수정은 내가 건드리지 않고 그대로 담았다 —
  16번이 7행에서 9행으로 늘었다(경계 벽 한 줄 포함)

**검증**
- `fvm flutter analyze` → **No issues found!**
- `fvm flutter test` → **`+497 -61`** (558건). #121 측정과 같다 — 맵 두 줄이 늘어도
  실패 건수가 그대로다

**결정 / 메모**
- **남의 변경과 내 변경을 한 커밋에 담았다.** 사용자가 "맵도 수정했으니 커밋해줘" 로 묶어
  요청했고, 파서 변경 없이는 그 맵이 애초에 파싱되지 않던 관계라 나누면 중간 커밋이
  깨진 상태가 된다
- **`main` 에 직접 커밋했다.** #120 에서 사용자가 브랜치를 물렀고 그 방침을 이어간다
- **`--amend` 를 쓰지 않았다.** #120 과 같은 이유 — 기록을 먼저 쓰고 한 번만 커밋한다
- **붉은 스위트를 그대로 커밋한다.** 맵 재설계가 진행 중이라 지금 초록일 수 없고,
  파서 변경은 그 61건 중 어느 것도 만들지 않았다(#121 에서 이름 단위로 확인)

---

## 2026-08-09 #123 — 블랙홀이 블록을 삼키면 함께 사라진다

**요청**
> 게임 설정 살짝만 바꿔보자. 블랙홀에 동료블럭이 들어가면 블랙홀도 함께 사라지게 해줘.
> 주인공블록이 들어가도 함께 사라지게.

**한 일**
- 기획서 §3.3 의 **"블랙홀은 소모되지 않는다" 를 뒤집었다.** 블록 하나가 들어가면 구멍도 사라진다
- 엔진 · 연출 · 완전 탐색기 · 테스트를 함께 옮겼다 (플랜 모드로 진행)

**변경 파일**
- `docs/game-design.md` — §2.2 표 · §3.3 전면 · §4.2 트레이스 결과 · §4.4-1 버리기
- `CLAUDE.md` — "a hole cannot be plugged" 문단
- `lib/.../entity/board_state.dart` — `withBlocks` 에 `consumedBlackHoles` 선택 인자
- `lib/.../apply_move_usecase.dart` — 삼킨 구멍 집합을 들고 다닌다
- `lib/.../entity/move_result.dart` — `to` 의 뜻에 "사라진 구멍의 자리" 를 덧붙였다
- `lib/.../widget/black_hole_painter.dart` · `board_view.dart` — 낙하 중 구멍 그리기
- `test/.../min_moves_solver.dart` · `level_design.dart` — 탐색 키에 남은 구멍
- `test/.../apply_move_usecase_test.dart` · `black_hole_test.dart` ·
  `game_play_screen_notifier_test.dart` — 새 규칙으로

**검증**
- `fvm flutter analyze` → **No issues found!**
- `fvm flutter test` → **`+496 -66`** (562건). 변경 전은 `+494 -64`(558건)
- **JSON 리포터로 변경 전후의 실패를 이름 단위로 비교했다** (#121 과 같은 방법).
  **이 변경으로 새로 실패하게 된 것은 레벨 18 의 두 건뿐이다** (아래 결정). 나머지 64건은
  그대로이고, 새 테스트 6건이 늘었다
- `level_design_test` 단독 실행 5초 — 상태 공간이 늘었는데도 눈에 띄게 느려지지 않았다

**결정 / 근거**
- **같은 수 안에서도 즉시 사라진다** (사용자 결정). 블록은 앞쪽부터 처리되므로(§3.2) 앞선
  블록이 빠지면 뒤따르는 블록은 이미 빈 칸이 된 자리를 지난다. **한 수에 블록 둘을 잃지
  않는다.** 구현은 `consumedBlackHoles` 집합 하나와 판정에 붙은 조건 한 줄이다
- **화면에서는 낙하가 끝난 뒤에 사라진다** (사용자 결정). 규칙상으로는 이미 없어졌지만,
  플레이어는 2초에 걸쳐 회전하며 빨려 든다 — 구멍을 먼저 지우면 **빈 바닥 위에서 도는**
  그림이 된다. **새 상태를 만들지 않고 파생했다**: 빠지는 블록이 멈춘 자리가 곧 구멍 자리라
  (`MoveResult.to`), `fallingBlocks` 에서 위치만 뽑아 페인터에 넘긴다. 화면이
  `AnimationCompleted` 에서 그 목록을 비우는 순간이 곧 구멍이 사라지는 순간이다
- **`floors` 를 제자리에서 고치지 않는다.** 레벨 내내 공유되는 인스턴스라 한 칸만 바꿔도
  `GameMap.initialBoard` 까지 바뀌어 **다시하기가 구멍 없는 판을 돌려준다.** 삼킨 구멍이
  있을 때만 복사한다. 이것을 테스트로 못박았다 (`원래 판은 그대로다`)
- **`BoardState.==` 와 `hashCode` 는 손대지 않았다.** 이미 `floors` 를 보고 있어서, 되돌리기
  스택도 저절로 맞는다 — `history` 의 옛 판이 자기 구멍을 그대로 갖고 있다
- **조용히 깨질 뻔한 자리는 탐색기였다.** `min_moves_solver` 와 `level_design` 의 `_key` 가
  **블록 위치만** 키로 쓰고 주석에 "바닥은 레벨 내내 고정" 이라고 적혀 있었다. 그 전제가
  이 변경으로 거짓이 된다 — 블록이 같은 자리에 있어도 구멍이 하나 덜 남으면 다른 판이다.
  고치지 않았다면 서로 다른 판을 같은 판으로 세어 **최소 수가 짧게 나오고 막다른 판 분석까지
  틀렸을 것**이고, 테스트는 통과했을 것이다. 두 키에 남은 구멍 좌표를 넣었다
- **`레벨 18` 이 이 변경으로 깨졌다 — 유일하다.** 최단 해법이 삼키는 동료가 2개에서 **1개**로
  줄어 더는 버리기 레벨이 아니고, 칸 벽 두 개가 장식이 됐다. **맵을 고치지 않았다** —
  사용자가 지금 손으로 맵을 그리는 중이고 레벨 설계는 사용자의 몫이다. 짜임 목록에서 18을
  빼는 것도 하지 않았다. 그것은 신호를 지우는 일이다
- **`minMoves` 는 손대지 않았다** (사용자 결정 — 맵이 너무 바뀌어 나중에 한 번에 재계산).
  대신 **완전 탐색으로 20개 전부의 실제 최단 수를 뽑아 보고했다.** 지금 맞는 것은 13·18·19·20
  넷뿐이다
- **튜토리얼 문구는 그대로 뒀다.** 13번의 안내는 `지나가기만 해도 블록을 삼킵니다` 라고만
  하고 **구멍이 사라진다는 새 사실을 말하지 않는다.** 규칙을 가르치는 유일한 자리라 언젠가는
  손봐야 하지만 5개 언어짜리 일이고 이번 요청 범위가 아니다
- 커밋하지 않았다 — 별도 요청으로 받는다

---

## 2026-08-09 #124 — 동료 낙하를 0.4초 늘리고, 구멍도 함께 사라지는 연출

**요청**
> 동료 너무 빨리사라져서 지금보다 0.4초 정도 느리게 늘려주고. 블랙홀도 사라질때 애니메이션 효과
> 추가해줘. 정확힌 동료 사라지면서 동시에 사라지도록.

**한 일**
- 일반 블록 낙하 시간 **0.12초 → 0.52초** (`_fallMs` 120 → 520)
- 삼켜진 구멍이 **블록과 같은 시간·같은 커브로** 줄어들며 흐려지게 했다
- 그 동시성을 테스트로 못박았다 — 값 두 개를 직접 비교한다

**변경 파일**
- `lib/core/config/app_constants.dart` — `_fallMs` 와 그 이유
- `lib/.../widget/black_hole_painter.dart` — `vanishProgress` (반지름 축소 + 레이어 페이드)
- `lib/.../widget/board_view.dart` — `TweenAnimationBuilder` 로 그 값을 굴린다
- `docs/game-design.md` §7 — 0.12초 → 0.52초, "구멍은 블록과 정확히 같이 사라진다"
- `test/.../black_hole_test.dart` — 동시성 테스트

**검증**
- `fvm flutter analyze` → **No issues found!**
- `fvm flutter test` → **`+497 -66`** (563건). 직전 `+496 -66`(562건)에서
  **새로 깨진 것 0건**, 새 테스트 1건. 이름 단위로 비교했다

**결정 / 근거**
- **`_fallMs` 하나만 고쳤다.** `moveWithFallDuration` 도 `fallStartFraction` 도 이 값에서
  파생되고, 화면의 완료 타이머와 블록의 `Interval` 커브가 모두 그것을 쓴다 — 그래서 상수
  한 줄로 낙하 구간 전체가 함께 늘어난다. 테스트도 상수를 참조하고 있어 따라왔다
- **플레이어의 2초는 건드리지 않았다.** 요청은 동료였고, 판이 끝나는 순간이라 길게 두는
  이유(12-ui-polish §5.3)가 그대로다
- **컨트롤러를 새로 만들지 않았다.** 블록 쪽이 `AnimatedScale`·`AnimatedOpacity` 라는
  암시적 애니메이션이므로 구멍도 `TweenAnimationBuilder` 로 굴린다. 컨트롤러를 하나 더 두면
  06 의 "암시적 애니메이션" 규칙을 깨는 여섯 번째 예외가 되는데, **같은 지속 시간·같은 커브를
  넘기는 것만으로 동시성이 보장**되므로 그럴 이유가 없다
- **구멍을 블록 위젯 안에 넣는 방법을 버렸다.** 그러면 축소·페이드가 저절로 공유돼 가장
  정확하지만, 회전이 `RotationTransition` 이 아니라 **페인터가 팔 각도를 직접 계산**하는
  방식이라(`turns`) 플레이어의 회전과 겹쳐 두 배로 돈다
- **빠지는 중이 아닐 때는 진행값을 `Duration.zero` 로 되돌린다.** 부드럽게 되돌리면 그 도중에
  다음 낙하가 시작될 때 구멍이 **이미 반쯤 줄어든 채로** 나타난다
- **한 수에 플레이어와 동료가 각자 다른 구멍에 빠지면 긴 쪽(플레이어)에 맞춘다.** 짧은 쪽에
  맞추면 플레이어가 아직 도는데 그 구멍이 먼저 없어진다. 반대는 동료 자리에 구멍이 조금 더
  남는 것뿐이라 덜 나쁘다
- **투명도는 칠마다가 아니라 `saveLayer` 로 건다.** 원과 나선 팔에 각각 알파를 주면 서로 비쳐
  보여 흐려지는 동안 그림 자체가 달라진다
- **테스트는 판 위에 있던 블록이 빠지는 순서로 만든다.** 처음부터 빠지는 상태로 만들면 암시적
  애니메이션이 목표값부터 그려져 아무것도 재생되지 않는다(`_noRotation` 주석과 같은 함정).
  실제 순서대로 두 번 pump 하고, **구멍의 진행값과 블록의 불투명도가 서로 맞는지**를 본다 —
  "같은 시간이 걸린다" 가 아니라 "같은 순간에 같은 만큼" 이 요청이었다
- 커밋하지 않았다 — 별도 요청으로 받는다

---

## 2026-08-09 #125 — 커밋

**요청**
> 커밋

**한 일**
- #123(블랙홀 소모)·#124(낙하 연출)를 **한 커밋**으로 `main` 에 올렸다. 푸시는 사용자 몫이다
- 사용자가 그 사이 고친 15번 맵(블랙홀 세 칸 추가)도 함께 담았다

**변경 파일**
- 없음 (이 기록 항목만)

**검증**
- `fvm flutter analyze` → **No issues found!**
- `fvm flutter test` → **`+497 -66`** (563건). #124 측정과 같다 — 15번 맵이 바뀌어도
  실패 건수와 파일별 내역이 그대로다

**결정 / 메모**
- **#123 과 #124 를 한 커밋으로 묶었다.** #124 는 #123 이 만든 순간(블록과 구멍이 함께
  사라지는 장면)을 보이게 하는 일이라, 나누면 중간에 **구멍이 소리 없이 사라지는** 상태가
  이력에 남는다
- **사용자의 맵 수정이 딸려 들어갔다.** 15번에 블랙홀 세 칸이 늘었다. 내가 만든 것이 아니지만
  같은 파일의 커밋되지 않은 변경이라 함께 담긴다 — #117 에서와 같은 상황이고, 빼면 오히려
  남의 작업이 사라진다
- **`main` 에 직접 · `--amend` 없이.** #120 에서 정해진 방식 그대로다
