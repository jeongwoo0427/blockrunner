# BlockRunner

격자 위에서 **모든 블록이 한꺼번에 미끄러지는** 퍼즐 게임입니다.
웹 · 모바일 · 데스크탑을 **하나의 Flutter 코드베이스**로 지원합니다.

25개 레벨 · 5개 언어 · 게임 엔진 없이 순수 Flutter · **전 과정 AI 페어 프로그래밍**

### ▶ [blockrunner.izvillain.com](https://blockrunner.izvillain.com) 에서 바로 해보실 수 있습니다

설치도 빌드도 없이 브라우저에서 곧바로 실행됩니다. 아래 [실행하기](#실행하기)는 직접 빌드해
보시려는 경우입니다.

---

## 어떤 게임인가요

방향을 한 번 입력하면 플레이어 블록과 모든 일반 블록이 **동시에** 그 방향으로 끝까지 미끄러집니다.
벽 · 맵 경계 · 다른 블록을 만나면 그 직전에 멈춥니다.
**플레이어 블록을 목표 지점에 정확히 멈춰 세우면 클리어입니다.**

```
       0  1  2  3  4  5              1수: ↓          2수: →
   0 | .  .  .  .  .  .
   1 | .  @  .  .  .  .          @ 가 O 에 막혀      @ 가 벽에 막혀
   2 | .  O  .  .  .  .          (4,1) 에 정지       목표 칸에 정지
   3 | .  .  .  .  .  .                              → 클리어
   4 | .  .  G  #  .  .
   5 | .  .  .  .  .  .          @ 플레이어  O 블록  # 벽  G 목표  X 블랙홀
```

2048의 "전체 슬라이드" 조작에 소코반식 "목표 도달" 승리 조건을 결합했습니다.
2048과 달리 **블록은 합쳐지지 않습니다.**

### 조작

| | |
|---|---|
| PC · 노트북 | **방향키** 또는 **WASD**, 마우스로 판을 끌어도 됩니다 |
| 스마트폰 · 태블릿 | 판 위를 **스와이프** |
| 다시하기 | 화면의 다시하기 버튼 또는 **`R`** |
| 다음 레벨 | 클리어 후 **`Enter`** |

**되돌리기는 없습니다.** 블랙홀에 빠지면 다시하기뿐입니다 — 그래서 블랙홀이 실제 위협이 됩니다.

---

## 실행하기

**그냥 해보시려면 [blockrunner.izvillain.com](https://blockrunner.izvillain.com) 이 가장 빠릅니다.**
직접 빌드해 보시려면 아래 두 방법 중 하나를 고르시면 됩니다 — **Flutter 를 몰라도, 설치하지
않아도 됩니다.**

### 방법 1. Docker — 준비물이 Docker 하나뿐 (권장)

Flutter 설치가 필요 없습니다. 컨테이너 **안에서** 알아서 내려받아 빌드합니다.

**준비물**: [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Mac · Windows · Linux 공통, 설치 후 실행해 두세요)

내려받은 저장소 폴더에서:

```bash
docker compose up -d --build
```

브라우저에서 **http://localhost:7001** 을 열면 게임이 뜹니다.

> ⏱ **첫 실행은 10분 안팎 걸립니다.** 컨테이너가 Flutter SDK 를 통째로 내려받아 빌드하기 때문입니다.
> 진행 상황을 보고 싶으시면 `-d` 를 빼고 `docker compose up --build` 로 실행하세요.
> 두 번째부터는 즉시 뜹니다.

끝낼 때는 `docker compose down` 입니다.

### 방법 2. Flutter 로 직접 실행 — 모든 플랫폼

기기(맥 앱 · 윈도우 앱 · 안드로이드 · iOS)로 직접 띄워 보시려면 이쪽입니다.

**준비물**: Flutter **3.44.8**

<details>
<summary>Flutter 가 없다면 (클릭)</summary>

버전이 저장소에 고정되어 있어서(`.fvmrc`), 버전 관리 도구인 [FVM](https://fvm.app) 을 쓰는 것이 가장 간단합니다.

```bash
# macOS
brew tap leoafarias/fvm && brew install fvm

# Windows
choco install fvm

fvm install        # 저장소에 지정된 3.44.8 을 내려받습니다
```

FVM 없이 [Flutter 를 직접 설치](https://docs.flutter.dev/get-started/install)하셔도 됩니다.
그 경우 아래 명령에서 앞의 `fvm` 만 빼시면 됩니다.

</details>

```bash
fvm flutter pub get     # 의존성 내려받기 (한 번만)
```

| 어디서 볼까 | 명령 | 참고 |
|---|---|---|
| **웹 브라우저** (가장 쉬움) | `fvm flutter run -d web-server --web-port=8080` | → http://localhost:8080 |
| **macOS 앱** | `fvm flutter run -d macos` | Xcode 가 필요합니다 |
| **Windows 앱** | `fvm flutter run -d windows` | Visual Studio (C++ 데스크탑 워크로드)가 필요합니다 |
| **Linux 앱** | `fvm flutter run -d linux` | |
| **안드로이드 폰** | `fvm flutter run` | USB 로 연결하거나 에뮬레이터를 켜 두세요 |
| **아이폰** | `fvm flutter run` | Xcode 와 서명 설정이 필요합니다 |

기기가 잡히는지 먼저 확인하시려면 `fvm flutter devices` 입니다.
안드로이드 폰에 설치 파일로 넣고 싶으시면 `fvm flutter build apk` 을 쓰세요.

> 💡 **웹은 `-d chrome` 을 쓰지 마세요.** 매번 빈 임시 브라우저로 열려서 언어 · 별점 · 해금이
> 저장되지 않는 것처럼 보입니다. 위 표의 `web-server` 명령으로 띄우고 평소 쓰시는 브라우저로 열면 됩니다.

### 코드 검사와 테스트

```bash
fvm flutter analyze     # 정적 분석
fvm flutter test        # 44개 파일 · 580여 건
```

Flutter 를 설치하지 않으셨다면 Docker 로도 돌릴 수 있습니다.

```bash
docker build --target build-env -t blockrunner-build .
docker run --rm blockrunner-build sh -c "cd /app && flutter analyze && flutter test"
```

---

## 기술

| | |
|---|---|
| 프레임워크 | Flutter **3.44.8** / Dart `^3.12.2` |
| 상태관리 · DI | `flutter_riverpod` 3.0.3 |
| 라우팅 | `go_router` ^14.6.1 |
| 로컬 저장 | `shared_preferences` ^2.5.3 |
| 렌더링 · 연출 | `CustomPainter` + 암시적 애니메이션 |
| 다국어 | 직접 구현 (ko · en · ja · zh · fr) |

**의존성이 셋뿐입니다.** 쓰지 **않기로** 한 것들이 이 프로젝트의 성격을 더 잘 보여줍니다.

- **게임 엔진(Flame 등) 없음** — 격자 퍼즐에 물리 엔진은 필요 없고, 엔진을 얹으면 레이아웃 ·
  라우팅 · 상태관리가 Flutter 쪽과 이중화됩니다.
- **다국어 라이브러리 없음** — 문구를 추상 클래스의 **멤버**로 선언해서, 번역을 빠뜨리면
  런타임 빈 문자열이 아니라 **컴파일 에러**가 납니다.
- **코드 생성 없음** — freezed · build_runner 를 쓰지 않습니다. 엔티티는 손으로 씁니다.

### 아키텍처

Clean Architecture · **feature-first** 입니다. 의존은 한 방향으로만 흐르고 **되돌아오는 간선이 없습니다.**

```
lib/
├── core/            DI · 라우팅 · 테마 · 다국어 · 공용 위젯
└── feature/
    ├── game/        판 모델 · 맵 데이터 · 이동 규칙 엔진 · 보드 렌더링 · 플레이 화면
    ├── level/       레벨 메타데이터 · 레벨 선택 화면
    ├── progress/    클리어 · 별점 · 최고 기록 저장
    ├── settings/    언어 · 진행도 초기화
    └── splash/      시작 화면

game → level → progress → (없음)
```

화면 하나는 `Root`(상태 구독 · 화면 이동) / `Screen`(그리기만) / `Notifier`(ViewModel) /
`State` / `Event` 로 나뉘고, 호출은 `Notifier → Usecase → Repository` 로 흐릅니다.
서버가 없으므로 datasource 계층을 두지 않았고, 맵은 전부 상수입니다.

**`level` 은 판을 모르고 `progress` 는 아무것도 모릅니다.** 맵을 `Level` 에 품게 하면 곧바로
순환이 생깁니다 — 실제로 두 번 겪고 두 번 끊었으며, 지금은 **테스트가 그 간선을 지킵니다.**

규약 전문은 [`docs/architecture.md`](docs/architecture.md) 에 있습니다.

---

## 개발 방식 — AI 페어 프로그래밍

**코드는 전부 Claude Code 가 썼습니다.** 사람은 규칙과 제품 결정을 내리고 에이전트가 구현합니다.
Andrej Karpathy 가 이름 붙인 *바이브 코딩* 이지만, 이 프로젝트가 실제로 푼 문제는 따로 있습니다 —
**세션마다 컨텍스트가 초기화되는데 어떻게 일관된 코드베이스를 쌓는가** 입니다.

답은 **저장소를 기억으로 쓰는 것**이었습니다.

| | |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | 매 세션 자동으로 읽히는 **상시 컨텍스트**입니다. 행동 규칙과 이미 내린 결정, 그리고 *그 이유*를 담습니다 |
| [`docs/tasks/`](docs/tasks/README.md) | 기능을 **작업 문서 15종**으로 쪼갰습니다. 한 요청에 한 작업만 하고, 끝나면 결과를 적어 `completed/` 로 옮깁니다 |
| [`docs/game-design.md`](docs/game-design.md) | **게임 규칙의 단일 출처**입니다. 규칙이 바뀌면 코드보다 **먼저** 이 문서를 고칩니다 |
| [`docs/prompt-history.md`](docs/prompt-history.md) | 요청 **100여 건**의 전문과 결정 근거입니다. diff 로는 복원할 수 없는 "왜" 가 남습니다 |

**규칙은 문서만이 아니라 테스트가 강제합니다.** 코드 7,800줄에 테스트 7,800줄로 거의 1:1 입니다.

- 이동 엔진은 Flutter 를 import 하지 않는 순수 Dart 라 화면 없이 전부 검증됩니다.
- **레벨 설계까지 검사합니다.** 완전 탐색으로 *막다른 판이 없는지*(되돌리기가 없으므로 한 번
  잘못 밀어 못 깨게 되면 화면은 아무 말도 하지 않습니다), *모든 벽과 블록이 최소 이동 횟수를
  바꾸는지*(아니면 장식입니다)를 봅니다. **맵은 손으로 그리지 않고 무작위 탐색으로 만들어
  이 검사를 통과한 것만 남깁니다.**
- 레이아웃도 5개 언어 × 3개 창 크기 × 글꼴 배율 ×2 로 렌더링해 **넘치면 실패**시킵니다.

---

## 문서

| 문서 | 내용 |
|---|---|
| [`docs/game-design.md`](docs/game-design.md) | 게임 규칙의 단일 출처. 이동 알고리즘 · 맵 요소 · 별점 |
| [`docs/architecture.md`](docs/architecture.md) | 폴더 구조 · DI · MVVM · 네이밍 규약 |
| [`docs/tasks/`](docs/tasks/README.md) | 작업 문서 15종과 진행 현황표 |
| [`docs/prompt-history.md`](docs/prompt-history.md) | AI 작업 요청 내역과 결정 근거 |
| [`docs/deployment.md`](docs/deployment.md) | Docker · nginx 배포와 함정 |
| [`CLAUDE.md`](CLAUDE.md) | AI 코딩 에이전트용 행동 규칙 |
