# BlockRunner

격자 위에서 **모든 블록이 한꺼번에 미끄러지는** 퍼즐 게임.
웹 · 모바일 · 데스크탑을 하나의 Flutter 코드베이스로 지원한다.

> **현재 상태: 플레이 가능.** 7개 튜토리얼 레벨을 스와이프 · 방향키 · WASD · 화면 버튼으로 풀 수 있다.
> 이동 규칙 엔진은 단위 테스트로 고정되어 있고, 각 레벨의 최소 이동 횟수는 완전 탐색 솔버가 검증한다.
> 다만 **애니메이션 · 되돌리기 · 진행도 저장이 아직 없고**(이동이 즉시 반영된다),
> 레벨 선택 화면은 자리표시자다.
> 진행 상황은 [`docs/tasks/README.md`](docs/tasks/README.md) 참고.

---

## 게임 소개

방향을 한 번 입력하면 플레이어 블록과 모든 일반 블록이 **동시에** 그 방향으로 끝까지 미끄러진다.
벽 · 맵 경계 · 다른 블록을 만나면 그 직전에 멈춘다.

**플레이어 블록을 목표 지점에 정확히 멈춰 세우면 클리어.**

```
       0  1  2  3  4  5              1수: ↓          2수: →
   0 | .  .  .  .  .  .
   1 | .  @  .  .  .  .          @ 가 O 에 막혀      @ 가 벽에 막혀
   2 | .  O  .  .  .  .          (4,1) 에 정지       목표 칸에 정지
   3 | .  .  .  .  .  .                              → 클리어
   4 | .  .  G  #  .  .
   5 | .  .  .  .  .  .          @ 플레이어  O 블록  # 칸 벽  G 목표  X 구멍
```

벽은 두 종류다.

- **칸 벽** `#` — 칸 하나를 통째로 차지한다. 지날 수도 설 수도 없다.
- **경계 벽** `|` `-` — 칸 **사이**를 막는다. **양쪽 칸은 멀쩡히 살아 있다.**

경계 벽이 있어야 목표 바로 뒤를 막으면서도 그 칸을 퍼즐에 계속 쓸 수 있다.
칸 벽만으로는 브레이크를 하나 놓을 때마다 칸 하나를 버려야 한다.

2048의 "전체 슬라이드" 조작에 소코반식 "목표 도달" 승리 조건을 결합했다.
2048과 달리 **블록은 합쳐지지 않는다.**

### 설계 의도

- **목표 칸을 지나가는 것만으로는 클리어되지 않는다.** 반드시 그 칸에 *멈춰야* 한다.
  목표와 같은 행/열에서 밀기만 하면 되는 게임은 퍼즐이 아니다.
  벽 · 일반 블록 · 맵 경계는 전부 플레이어를 원하는 지점에 세우기 위한 **브레이크**다.
- **실패가 없다.** 이동 횟수 제한도, 게임 오버 화면도 없다.
  되돌리기가 무제한이고, 도전 욕구는 *최소 이동 횟수 기준 별점*이 만든다.
- **구멍은 지나가기만 해도 빠진다.** 멈춰야만 빠지는 규칙이면 구멍은 무해한 장식이 된다.

전체 규칙과 결정 근거는 [`docs/game-design.md`](docs/game-design.md)에 있다.

---

## 구조 및 기술

### 기술 스택

| | |
|---|---|
| 프레임워크 | Flutter **3.44.8** (FVM으로 고정) / Dart SDK `^3.12.2` |
| 상태관리 · DI | `flutter_riverpod` 3.0.3 |
| 라우팅 | `go_router` ^14.6.1 |
| 로컬 저장 | `shared_preferences` ^2.5.3 |
| 렌더링 | **`CustomPainter` + `AnimationController`** |
| 코드 생성 | 없음 — freezed / json_serializable / build_runner 미사용 |

**게임 엔진(Flame 등)을 쓰지 않는다.** 순수 Flutter 프레임워크로만 구현한다.
격자 퍼즐은 물리 엔진도 스프라이트 배칭도 필요 없고, 엔진을 얹으면 오히려 레이아웃 · 라우팅 · 상태관리가 Flutter 쪽과 이중화된다.

### 아키텍처

Clean Architecture, **feature-first**. 의존 방향은 항상 도메인을 향한다.

```
lib/
├── core/            DI · 라우팅 · 테마 · 에러 · 공용 위젯
└── feature/
    ├── game/        플레이 화면 · 보드 렌더링 · 이동 규칙 엔진
    ├── level/       레벨 상수 데이터 · 레벨 선택
    └── progress/    클리어 · 별점 · 최고 기록 저장
```

각 feature는 `domain / data / presentation` 3계층으로 나뉘고, 화면 하나는 다음 파일들로 구성된다.

```
<screen>_root.dart              ConsumerStatefulWidget — 상태 구독, 네비게이션
<screen>_screen.dart            StatefulWidget — 그리기만. Riverpod을 모른다
<screen>_screen_notifier.dart   Notifier<State> = ViewModel
<screen>_screen_state.dart      @immutable + copyWith
<screen>_screen_event.dart      sealed class
widget/                         화면 전용 위젯
```

호출 사슬은 `Notifier → Usecase → Repository(추상) → RepositoryImpl` 이다.

**서버 API가 없으므로 datasource 계층을 두지 않는다.** 맵 데이터는 전부 상수이고, `RepositoryImpl`이 이를 직접 보유한다.

폴더 구조 · 네이밍 · DI 규약 전문은 [`docs/architecture.md`](docs/architecture.md)에 있다.

---

## 설치 및 실행

### 사전 준비

Flutter 버전이 [FVM](https://fvm.app)으로 3.44.8에 고정되어 있다 (`.fvmrc`).

```bash
# FVM 설치 (없다면)
brew tap leoafarias/fvm && brew install fvm

# 저장소에 지정된 Flutter 버전 내려받기
fvm install
```

FVM을 쓰지 않아도 되지만, 그 경우 로컬 Flutter가 3.44.8인지 직접 확인해야 한다.
아래 명령에서 `fvm` 접두사만 빼면 된다.

### 의존성 설치

```bash
fvm flutter pub get
```

### 실행

```bash
fvm flutter devices          # 사용 가능한 기기 확인

fvm flutter run -d chrome    # 웹
fvm flutter run -d macos     # macOS
fvm flutter run              # 연결된 모바일 기기 / 에뮬레이터
```

Windows · Linux · Android · iOS 프로젝트도 모두 생성되어 있다.

### 검증

작업을 끝냈다고 보고하기 전에 아래 두 명령이 통과해야 한다.

```bash
fvm flutter analyze          # analysis_options.yaml (flutter_lints)
fvm flutter test
```

### 빌드

```bash
fvm flutter build web
fvm flutter build apk
fvm flutter build macos
```

---

## 문서

| 문서 | 내용 |
|---|---|
| [`docs/game-design.md`](docs/game-design.md) | **게임 규칙의 단일 출처.** 이동 알고리즘, 맵 요소, 클리어 · 되돌리기 규칙, 검산 트레이스 |
| [`docs/architecture.md`](docs/architecture.md) | 폴더 구조, DI · MVVM · repository 규약, 네이밍 |
| [`docs/tasks/`](docs/tasks/README.md) | 기능별 할 일 문서 11종과 진행 현황표 |
| [`docs/prompt-history.md`](docs/prompt-history.md) | AI 작업 요청 내역과 결정 근거 |
| [`CLAUDE.md`](CLAUDE.md) | AI 코딩 에이전트용 행동 규칙 |

규칙이 바뀌면 코드보다 **먼저** `docs/game-design.md`를 고친다.

---

## 개발 순서

[`docs/tasks/README.md`](docs/tasks/README.md)의 순서를 따른다.

**이동 규칙 엔진(`02`)을 화면(`04`)보다 먼저 만든다.** 이 게임의 난이도는 전부 이동 규칙에 있고,
규칙은 Flutter 없이 순수 Dart 단위 테스트로 완전히 검증할 수 있다.
UI를 먼저 만들면 규칙 버그를 화면으로 눈 디버깅하게 된다.
