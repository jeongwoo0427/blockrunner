# BlockRunner — 아키텍처 규약

> 인접 프로젝트 `../quizlab`(패키지명 `myquiz`)의 관례를 기반으로, API가 없는 오프라인 게임에 맞게 조정한 것이다.
> 판단이 갈릴 때는 quizlab의 실제 코드를 참고한다.

작성일: 2026-08-05 · 상태: **v1 확정**

---

## 1. 원칙

Clean Architecture, **feature-first**. 의존 방향은 항상 안쪽(도메인)을 향한다.

```
presentation  →  domain  ←  data
```

- `domain`은 아무것도 import하지 않는다 (Flutter조차). 순수 Dart.
- `presentation`은 `data`를 알지 못한다. 추상 타입만 주입받는다.
- `data`는 `domain`의 인터페이스를 구현한다.

---

## 2. 폴더 구조

디렉터리 이름은 **단수형**이다 (`feature/`, `entity/`, `usecase/` — quizlab 관례).

```
lib/
├── main.dart
├── core/
│   ├── config/      app_constants.dart
│   ├── di/          core_providers.dart          ← 전역 provider만
│   ├── error/       failure.dart, failure_code.dart
│   ├── extension/   notifier_mixin.dart
│   ├── i18n/        app_locale.dart, app_strings.dart, strings_{ko,en,ja,zh,fr}.dart,
│   │                strings_catalog.dart, app_strings_scope.dart        ← §14
│   ├── router/      router.dart, route_paths.dart
│   ├── theme/       base_theme.dart, board_colors.dart,
│   │                data/{light,dark}_theme.dart, data/spacing.dart, data/text_styles.dart
│   ├── usecase/     base_stream_usecase.dart
│   └── widget/      여러 feature가 공유하는 위젯 (game_button.dart 등)
└── feature/
    ├── game/        판 모델 · 맵 데이터 · 이동 규칙 엔진 · 보드 렌더링 · 플레이 화면
    ├── level/       레벨 메타데이터(번호 · 최소 이동 횟수 · 튜토리얼 데모) · 레벨 선택 화면
    │                · 안내를 봤는지 여부
    ├── progress/    클리어 여부 · 별점 · 최소 이동 기록 저장
    ├── settings/    언어 선택과 저장
    └── splash/      첫 화면. 판도 레벨도 모른다
```

### feature 의존 방향 — **순환 금지**

```
game → level          최소 이동 횟수 · 안내 유무를 표시하려고
game → progress       클리어 기록을 저장하려고
level → progress      레벨 선택 화면이 별점 · 해금을 그리려고
level → settings      레벨 선택 화면에서 언어를 고르므로
progress → (없음)     progress 는 어느 feature 도 모른다
settings → (없음)     settings 도 어느 feature 도 모른다
splash   → (없음)     스플래시는 판도 레벨도 모른다 — 사각형 몇 개를 직접 그린다
```

**`level` 이 `game` 을 모르는 것은 소스 스캔 테스트가 지킨다** (`test/feature/level/no_game_dependency_test.dart`). 레벨 카드의 미니 보드가 세 번째 유혹이었고, 위젯을 `Widget Function(...)` 으로 받아 **라우터가 조립하는 것**으로 피했다 — 라우터는 원래 모든 feature 를 아는 자리다.

**`progress` 가 아무것도 모르는 것이 이 배치의 핵심이다.** 한때 `SaveClearResultUsecase` 가
별점 계산을 위해 `Level` 을 받아 `progress → level` 이 있었는데, 레벨 선택 화면이 생기면서
`level → progress` 가 필요해져 순환이 됐다. usecase 가 `Level` 대신 **번호와 별점 값**을 받게
바꿔 끊었다 — 별점 공식은 여전히 `Level.starsFor` 한 곳에만 있고 호출부가 그것을 불러 넘긴다.

**`level` 도 `game` 을 모른다.** 레벨 선택 화면에 필요한 것은 번호 · 이름 · 별점뿐이고 판은 전혀 필요 없다. 그래서 판(`BoardState` · `Block` · `Position` …)과 맵 데이터는 전부 `game` 이 소유하고, `level` 은 메타데이터만 갖는다.

> **한때 순환이 있었다.** `Level` 이 `initialBoard` 를 품고 있어서 `level` 이 판 모델 전체를 알아야 했고, 동시에 `game` 은 레벨 조회 때문에 `level` 을 알아야 했다. 개념을 **`Level`(메타데이터) / `GameMap`(판)** 으로 쪼개 끊었다. 두 상수 목록은 **레벨 번호로만** 이어지며, 어긋나면 테스트가 잡는다.

`minMoves` 는 맵에서 파생되는 값이지만 **`Level` 쪽에 둔다.** 맵에 두면 레벨 선택 화면이 별점을 그리려고 `game` 을 알아야 해서 순환이 되살아난다.

### feature 내부 템플릿

```
lib/feature/<name>/
├── <name>_di.dart                            ← DI. feature 루트에 한 파일
├── domain/
│   ├── entity/<entity>.dart
│   ├── repository/<name>_repository.dart     ← 추상 인터페이스
│   └── usecase/
│       ├── <name>_usecases.dart              ← Usecase 컨테이너
│       └── <name>_usecases/*_usecase.dart    ← usecase 1개당 1파일
├── data/
│   └── repository/<name>_repository_impl.dart
└── presentation/<screen_name>/
    ├── <screen>_root.dart                    ConsumerStatefulWidget
    ├── <screen>_screen.dart                  StatefulWidget (dumb)
    ├── <screen>_screen_notifier.dart         Notifier<State> = ViewModel
    ├── <screen>_screen_state.dart            @immutable + copyWith
    ├── <screen>_screen_event.dart            sealed class
    └── widget/                               해당 화면 전용 위젯
```

화면에 종속되지 않는 앱 전역 상태는 `presentation/notifier/<subject>_notifier.dart`에 둔다.
화면이 없는 feature는 `presentation/`을 통째로 생략한다.

---

## 3. quizlab과 의도적으로 다른 점

**이 표가 이 문서에서 가장 중요하다.** quizlab 코드를 참고하다 보면 여기 없는 계층을 무심코 따라 만들기 쉽다.

| 항목 | quizlab | blockrunner | 이유 |
|---|---|---|---|
| **datasource 계층** | `data/datasource/remote`·`local` | **없음** | 서버가 없다. `RepositoryImpl`이 상수 데이터를 직접 보유한다 |
| **API 모델 + 매퍼** | `*_api_model.dart` | **없음** | 직렬화할 외부 스키마가 없다. 도메인 엔티티만 쓴다 |
| Dio / 네트워크 | 있음 | 없음 | — |
| Failure 매퍼 체인 | Dio → 소셜 → 클라이언트 | 클라이언트 전용으로 축소 | 네트워크 에러가 존재하지 않는다 |
| 페이지네이션 | `PaginationResponse<T>` | 없음 | 레벨 목록은 전량 메모리 상수 |
| 다국어 | ARB 코드젠 | **손으로 쓴 `AppStrings` 5개 언어** (§14) | 텍스트 양이 적어 코드젠도 패키지도 값을 못 한다. 추상 멤버라 키를 빠뜨리면 컴파일이 깨진다 |
| Firebase / Sentry | 있음 | 없음 | — |

`RepositoryImpl`이 데이터를 직접 갖는 형태는 이렇게 생긴다:

```dart
class MapRepositoryImpl implements MapRepository {
  // 맵 데이터는 상수. 별도 datasource를 두지 않는다.
  MapRepositoryImpl({this._blueprints = kMapBlueprints, this._parser = const MapParser()});

  // 파싱은 첫 접근에 한 번만 하고 캐시한다.
  List<GameMap> get _maps => _cache ??= _blueprints.map(_parser.parse).toList();

  @override
  GameMap getMap(int levelNumber) => ...;
}
```

`progress` feature처럼 `SharedPreferences`를 쓰는 경우에도 **local datasource를 만들지 않고** `RepositoryImpl`이 `SharedPreferences`를 직접 주입받는다.

---

## 4. DI — Riverpod 순수 provider

`get_it` / `injectable` / `provider` 를 쓰지 않는다. **`flutter_riverpod`의 손으로 쓴 provider가 곧 DI 컨테이너**다 (quizlab과 동일).

### 규칙

- 전역/코어 provider는 `lib/core/di/core_providers.dart`, feature provider는 `lib/feature/<name>/<name>_di.dart`.
- 부팅 시점에만 알 수 있는 값(`SharedPreferences` 등)은 `throw UnimplementedError()`로 선언해두고 `main.dart`의 `ProviderScope(overrides: [...])`에서 주입한다.
- **항상 `Provider<추상타입>(...)`** 으로 등록한다. 구현체 타입이 주입 타입이 되면 안 된다.
- provider 본문에서는 **항상 `ref.read`**, `ref.watch`를 쓰지 않는다.
  - **예외는 파생 상태 provider 하나뿐이다** — `appStringsProvider`(§14). 배선이 아니라 값이 값을 낳는 자리라, `ref.read` 로 두면 처음 언어에 영영 고정된다. 예외를 늘리기 전에 "이것이 DI 배선인가 파생 상태인가" 를 먼저 답한다.
- 파일 안은 `Data → Domain → Presentation` 순서로 배너 주석을 달아 구분한다.

```dart
/// 각 계층별 DI 위한 Providers

/// ----------------------------------------------------------------------------
/// Data
/// ----------------------------------------------------------------------------

final levelRepositoryProvider = Provider<LevelRepository>(
  (ref) => LevelRepositoryImpl(),
);

/// ----------------------------------------------------------------------------
/// Domain
/// ----------------------------------------------------------------------------

final levelUsecasesProvider = Provider(
  (ref) => LevelUsecases.fromRepositories(
    levelRepository: ref.read(levelRepositoryProvider),
    progressRepository: ref.read(progressRepositoryProvider),
  ),
);

/// ----------------------------------------------------------------------------
/// Presentation
/// ----------------------------------------------------------------------------

final levelSelectScreenNotifierProvider =
    NotifierProvider<LevelSelectScreenNotifier, LevelSelectScreenState>(
      () => LevelSelectScreenNotifier(),
    );

/// 레벨 번호로 키잉되는 플레이 화면 — 나갈 때 상태를 버린다
final gamePlayScreenNotifierProvider = NotifierProvider.autoDispose
    .family<GamePlayScreenNotifier, GamePlayScreenState, int>(
      GamePlayScreenNotifier.new,
    );
```

- 오래 유지되는 화면: `NotifierProvider<N, S>(() => N())`
- 일회성 화면·다이얼로그: `.autoDispose`
- 인자로 키잉되는 화면: `.autoDispose.family<N, S, T>(N.new)`

---

## 5. MVVM — Notifier / State / Event

ViewModel은 Riverpod **`Notifier<State>`** 이며 이름은 `*ScreenNotifier`다.
`ChangeNotifier`, Bloc, `AsyncNotifier`, `@riverpod` 코드젠 모두 쓰지 않는다.

### State

`@immutable` 평범한 클래스. `copyWith`에서 **nullable 필드는 `T? Function()?` 패턴**으로 받아 "null로 설정"과 "변경 안 함"을 구분한다.

```dart
@immutable
class GamePlayScreenState {
  final Level? level;
  final BoardState? board;
  final int moveCount;
  final bool isAnimating;
  final bool isCleared;
  final bool isPlayerLost;   // 블랙홀에 빠져 되돌리기 유도 중
  final Failure? failure;

  const GamePlayScreenState({ this.level, ..., this.moveCount = 0 });

  bool get canUndo => ...;

  GamePlayScreenState copyWith({
    Level? Function()? level,        // ← nullable은 Function()? 로
    BoardState? Function()? board,
    int? moveCount,                  // ← non-null은 평범하게
    bool? isAnimating,
    Failure? Function()? failure,
  }) { ... }
}
```

### Event

`sealed class` 하나에 요청 종류를 나열한다.

```dart
sealed class GamePlayScreenEvent {}

class LoadLevel extends GamePlayScreenEvent {}
class MoveRequested extends GamePlayScreenEvent {
  final Direction direction;
  MoveRequested(this.direction);
}
class UndoRequested extends GamePlayScreenEvent {}
class ResetRequested extends GamePlayScreenEvent {}
class NextLevelRequested extends GamePlayScreenEvent {}
```

### Notifier

`build()`가 초기 상태를 만들고, `onEvent(event)`가 `switch`로 분기한다.
usecase 컨테이너는 `ref.read`로 꺼내는 private getter로 노출한다.

```dart
class GamePlayScreenNotifier extends Notifier<GamePlayScreenState> {
  @override
  GamePlayScreenState build() => const GamePlayScreenState();

  GameUsecases get _usecases => ref.read(gameUsecasesProvider);

  Future<void> onEvent(GamePlayScreenEvent event) async {
    switch (event) {
      case MoveRequested():
        _applyMove(event.direction);
      case UndoRequested():
        _undo();
      case NextLevelRequested():
        break;   // 네비게이션은 Root가 처리한다
      ...
    }
  }
}
```

### View 바인딩 — Root / Screen 2분할

| | Root | Screen |
|---|---|---|
| 타입 | `ConsumerStatefulWidget` | `StatefulWidget` |
| Riverpod | `ref.watch(provider)` / `ref.read(provider.notifier)` | **import 금지** |
| 책임 | 상태 구독, 네비게이션, 다이얼로그, 스낵바 | 그리기, 로컬 UI 상태(컨트롤러·포커스) |
| 입출력 | — | `state`와 `onEvent`를 생성자로 받는다 |

`Consumer`, `context.watch`, `ListenableBuilder`를 쓰지 않는다. Screen은 Riverpod을 모르기 때문에 그대로 위젯 테스트에 태울 수 있다.

```dart
class GamePlayRoot extends ConsumerStatefulWidget {
  final int levelNumber;
  ...
}

class _GamePlayRootState extends ConsumerState<GamePlayRoot> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(gamePlayScreenNotifierProvider(widget.levelNumber).notifier);
    final state = ref.watch(gamePlayScreenNotifierProvider(widget.levelNumber));

    return GamePlayScreen(
      state: state,
      onEvent: (event) async {
        switch (event) {
          case NextLevelRequested():
            context.go('${RoutePaths.gamePlay}?level=${widget.levelNumber + 1}');
          default:
            await notifier.onEvent(event);
        }
      },
    );
  }
}
```

---

## 6. Repository와 Usecase

호출 사슬:

```
Notifier → UsecaseContainer → Usecase → Repository(추상) → RepositoryImpl
```

**Notifier가 repository를 직접 호출하는 것은 금지한다.** 반드시 usecase를 거친다.

- Repository 인터페이스는 `domain/repository/`, 구현은 `data/repository/`.
- `RepositoryImpl`은 생성자 named 파라미터로 의존성을 받아 private 필드에 대입한다.
  Dart 3의 **private named parameter**(`{required this._repository}`)를 쓴다 — 호출부에서는 `repository:`로 그대로 넘긴다.
  quizlab의 `{required X x}) : _x = x` 형태는 `prefer_initializing_formals` 린트에 걸린다.
- Usecase는 `call()`을 정의해 함수처럼 호출한다 → `_usecases.getLevel(3)`.
- 컨테이너는 public final 필드를 `Usecase` 접미사 **없이** 이름 짓고, `factory X.fromRepositories({...})`로 조립한다.

```dart
class GameUsecases {
  final GetLevelUsecase getLevel;
  final ApplyMoveUsecase applyMove;
  final SaveClearResultUsecase saveClearResult;

  GameUsecases({required this.getLevel, required this.applyMove, required this.saveClearResult});

  factory GameUsecases.fromRepositories({
    required LevelRepository levelRepository,
    required ProgressRepository progressRepository,
  }) => GameUsecases(
        getLevel: GetLevelUsecase(repository: levelRepository),
        applyMove: ApplyMoveUsecase(),
        saveClearResult: SaveClearResultUsecase(repository: progressRepository),
      );
}
```

### 상태 변경 usecase는 스트림을 흘린다

`lib/core/usecase/base_stream_usecase.dart` (quizlab에서 그대로 가져옴):

```dart
abstract mixin class BaseStreamUsecase<R> {
  final _streamController = StreamController<R>.broadcast();
  Stream<R> get stream => _streamController.stream;
  void dispose() => _streamController.close();
  void yieldData(R data) => _streamController.add(data);
}
```

레벨 클리어처럼 **다른 화면의 상태에도 영향을 주는 변경**은 `BaseStreamUsecase`를 상속해 `yieldData()`를 호출한다. 관심 있는 notifier가 `build()`에서 `listenStream(...)`으로 구독한다 (`core/extension/notifier_mixin.dart`).

> 예: 플레이 화면에서 레벨을 클리어하면 `SaveClearResultUsecase`가 결과를 흘리고, 레벨 선택 화면의 notifier가 이를 받아 해금/별점을 갱신한다. 화면을 나갔다 들어와야 갱신되는 문제를 없앤다.

**스트림을 가진 usecase는 인스턴스가 하나여야 한다.** 두 컨테이너가 각자 `new` 하면 서로 다른 스트림을 갖게 되어, 구독자가 방출을 영원히 받지 못한다. 컴파일도 테스트도 통과하면서 조용히 어긋나는 종류다.

그래서 `SaveClearResultUsecase`는 `ProgressUsecases`가 소유하고, `GameUsecases`는 **이미 만들어진 인스턴스를 주입받는다.** 컨테이너 factory가 repository만 받는다는 규칙의 유일한 예외이며, `game_di.dart`가 `ref.read(progressUsecasesProvider).saveClearResult`로 넘긴다. 두 컨테이너가 같은 인스턴스를 보는지는 테스트가 확인한다.

---

## 7. 엔티티

**freezed / json_serializable / build_runner / equatable을 쓰지 않는다.** 전부 손으로 쓴다 (quizlab과 동일 — `lib/` 전체에 `part`도 `export`도 없다).

- 생성자는 named 파라미터, 새 인스턴스는 `factory X.create({...})`.
- `copyWith`는 §5의 nullable 패턴을 따른다.
- `operator ==` / `hashCode`는 필요한 필드만 골라 수작업.
- **도메인 로직은 엔티티 안에 둔다** — `board.blockAt(position)`, `level.isSolvedBy(board)` 처럼.

이동 규칙 엔진(`ApplyMoveUsecase` 또는 도메인 순수 함수)은 **Flutter를 import하지 않는 순수 Dart**여야 한다. 위젯 없이 단위 테스트로 전부 검증할 수 있어야 하며, 이것이 이 프로젝트에서 테스트 커버리지가 가장 중요한 부분이다.

---

## 8. 에러 처리

`Either` / `Result` 래퍼를 쓰지 않는다. 계층은 그냥 throw하고, **Notifier가 `try/catch`로 받아 `Failure`를 state에 담는다.**

```dart
try {
  final level = await _usecases.getLevel(levelNumber);
  state = state.copyWith(level: () => level, failure: () => null);
} catch (e, stack) {
  state = state.copyWith(failure: () => Failure.fromError(e, stack));
}
```

- `core/error/failure.dart` — `abstract class Failure implements Exception`, `static Failure fromError(Object, StackTrace)`
- `core/error/failure_code.dart` — `enum FailureCode`
- quizlab의 Dio·소셜로그인 매퍼 체인은 **가져오지 않는다.** 클라이언트 실패만 존재한다 (레벨 파싱 실패, 저장소 접근 실패 등).

---

## 9. 라우팅

`go_router` 전역 단일 인스턴스.

- `core/router/router.dart` — `final GoRouter router = GoRouter(...)`. 모든 `GoRoute`는 `*Root` 위젯을 만든다.
- `core/router/route_paths.dart` — `abstract class RoutePaths { static const gamePlay = '/game-play'; }`. URL은 kebab-case, 상수는 camelCase.
- **인자는 경로 파라미터가 아니라 쿼리 파라미터**로 넘긴다: `context.go('${RoutePaths.gamePlay}?level=3')` → `state.uri.queryParameters['level']`.
- 네비게이션 호출은 **Root에서만** 한다.

---

## 10. 네이밍

### 파일 (snake_case)

| 역할 | 패턴 | 예시 |
|---|---|---|
| feature DI | `<feature>_di.dart` | `game_di.dart` |
| 엔티티 | `<entity>.dart` (접미사 없음) | `board_state.dart`, `level.dart` |
| Repository 인터페이스 | `<name>_repository.dart` | `level_repository.dart` |
| Repository 구현 | `<name>_repository_impl.dart` | `level_repository_impl.dart` |
| Usecase 컨테이너 | `<feature>_usecases.dart` | `game_usecases.dart` |
| Usecase | `<동사>_<명사>_usecase.dart` | `apply_move_usecase.dart` |
| ViewModel | `<screen>_screen_notifier.dart` | `game_play_screen_notifier.dart` |
| State | `<screen>_screen_state.dart` | |
| Event | `<screen>_screen_event.dart` | |
| Smart 위젯 | `<screen>_root.dart` | `game_play_root.dart` |
| Dumb 위젯 | `<screen>_screen.dart` | `game_play_screen.dart` |
| 전역 notifier | `presentation/notifier/<subject>_notifier.dart` | |

### 클래스

파일명의 UpperCamelCase. 단 다음 관례를 지킨다:

- **`Usecase`** — `c`는 소문자다. `UseCase`가 아니다.
- **`Impl`** 접미사는 구현체에만.

### Provider

top-level `final`, camelCase, `<대상>Provider` 접미사. `...RepositoryProvider`, `...UsecasesProvider`, `...ScreenNotifierProvider`.

### 기타

- **barrel / export 파일을 만들지 않는다.**
- import는 항상 절대경로 `package:blockrunner/...`. 상대경로 금지.
- 주석은 한국어 `///`로, **무엇이 아니라 왜**를 적는다.

---

## 11. 패키지

| 패키지 | 버전 | 용도 |
|---|---|---|
| `flutter_riverpod` | `3.0.3` (정확히 고정) | 상태관리 겸 DI |
| `go_router` | `^14.6.1` | 라우팅 |
| `shared_preferences` | `^2.5.3` | 진행도 · 설정 저장 |

**다국어 패키지를 추가하지 않는다.** `intl` · `flutter_localizations` · `easy_localization` · `slang` 모두 쓰지 않는다 (§14).

**게임 엔진(Flame 등)을 추가하지 않는다.** 렌더링은 `CustomPainter`, 게임 루프/연출은 `AnimationController`, 입력은 `GestureDetector` / `Focus` + `KeyboardListener`로 해결한다.

Flutter 버전은 FVM으로 고정되어 있다 (`.fvmrc` → 3.44.8). 모든 명령에 `fvm` 접두사를 붙인다.

---

## 12. 지원 플랫폼

웹 · Android · iOS · macOS · Windows · Linux. 스캐폴드에 전부 생성되어 있다.

- 플랫폼 분기 코드를 최소화한다. 입력 방식만 분기하고 게임 로직은 완전히 공통이다.
- `dart:io`를 도메인/데이터 계층에서 쓰지 않는다 (웹에서 깨진다).
- 보드는 화면 비율과 무관하게 **정사각을 유지**하고, 남는 공간에 HUD를 배치한다.

---

## 13. 레벨 전환

**플레이 화면의 페이지 키는 레벨과 무관하게 고정이다** (`router.dart`).

- 레벨 선택 → 플레이: 페이지가 **새로 생기므로** 머티리얼 전환이 그대로 난다.
- 다음 레벨: 키가 같아 **페이지가 교체되지 않고 그 자리에서 갱신**된다. 화면 전체가 밀리지 않고, `GamePlayScreen` 이 `didUpdateWidget` 에서 레벨이 바뀐 것을 보고 **판과 HUD 만** 밀어 넘긴다. AppBar 와 오버레이는 제자리에 있다.

**배경과 카드는 따로 움직인다.** 배경(스크림)은 **투명도만** 바뀌고 배율이 걸리지 않는다 — 화면 전체를 덮는 것이 줄어들면 덮개가 아니라 또 하나의 카드처럼 보인다. 순서도 갈라져 있다: 들어올 때는 배경이 먼저 깔리고 카드가 뜨며, 나갈 때는 카드가 먼저 사라지고 배경이 뒤따라 걷힌다.

**다음 레벨은 카드가 다 사라진 뒤에 올라간다.** 화면이 이벤트를 붙잡고 있다가 퇴장이 끝나면 올려보낸다 — 먼저 보내면 사라지는 장면이 페이지 전환에 잘려 나간다. 그래서 전체 차례는 `카드 사라짐 → 배경 걷힘 → 몸통 이동 → 튜토리얼 등장` 이 된다.

**판 위에 뜨는 것은 사라질 때도 연출을 갖는다.** 조건부로 트리에서 빼버리면 재생할 틈이 없으므로, 화면이 마지막 오버레이를 붙잡고 있다가 다 나간 뒤에 놓는다. 방향은 `CurvedAnimation.reverseCurve` 가 가른다 — 들어올 때는 튕기고(`elasticOut`) 나갈 때는 깔끔하게 줄어든다(`easeIn`).

**`PageView` 를 쓰지 않는다.** 손으로 밀어서 레벨을 옮길 수 있으면 판 위의 스와이프가 이동인지 페이지 넘김인지 갈리지 않는다.

---

## 14. 다국어

문자열은 **손으로 쓴 Dart 상수**다. 라이브러리도 코드 생성도 `.arb` 도 없다 (11-i18n).

```
lib/core/i18n/
├── app_locale.dart          지원 언어 enum + 기기 로케일 해석
├── app_strings.dart         추상 클래스 — 문구 목록
├── strings_ko.dart          언어별 구현 (ko · en · ja · zh · fr)
├── strings_catalog.dart     AppLocale → AppStrings
└── app_strings_scope.dart   InheritedWidget + context.strings
```

**규칙**

- **문구는 추상 멤버로 선언한다.** `Map<String, String>` 을 쓰지 않는다 — 키를 빠뜨리면 컴파일이 깨져야 한다. Map 이면 오타가 런타임 빈 문자열이 되고, 그건 그 언어를 읽는 사람만 볼 수 있다.
- **값이 끼어드는 문구는 함수다.** 그래야 영어의 `1 move` / `2 moves` 같은 복수형 분기를 각 언어가 자기 파일 안에서 처리한다.
- **레벨 이름·안내만 `Map<int, String>` 이다.** 레벨은 계속 늘어나므로 멤버로 두면 레벨 하나에 5파일 × 2줄이 붙는다. 잃은 컴파일 검사는 **키 패리티 테스트**가 대신한다.
- **화면은 `context.strings` 로 읽는다.** Riverpod 이 아니라 `InheritedWidget` 인 것은 "Screen 은 Riverpod 을 모른다"(§5)를 지키기 위해서다. 문자열 수십 개를 `State` 에 실어 하위 위젯까지 생성자로 관통시키면 규약을 지키느라 화면이 무너진다.
- **개발자용 문구는 번역하지 않는다.** 파서 오류 · `assert` · `debugMessage` 는 레벨을 만드는 사람이 읽는 것이라 한국어로 남긴다. 이 경계는 `no_hardcoded_korean_test` 가 검사 범위(`presentation/` 와 `level_data.dart`)로 못박고 있다.
- **언어 상태는 `settings` feature 가 소유한다.** `AppLocale` 만 `core/i18n/` 에 있다 — 문자열 파일이 그 enum 으로 키잉되는데 `core` 는 feature 를 import 할 수 없기 때문이다.
- **화면에 붙지 않는 Notifier 가 하나 있다** — `LocaleNotifier`. 이름이 `*ScreenNotifier` 가 아닌 유일한 경우이며(§5의 예외), 언어를 들고 있는 곳이 앱에 하나뿐이어야 하므로 그렇다. 그래서 `SaveLocaleUsecase` 는 **스트림을 흘리지 않는다** — 모든 화면이 이 하나에서 파생되므로 같은 사실에 이르는 길을 둘로 만들 이유가 없다.
