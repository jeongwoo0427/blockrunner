# 00. 기반 구축 (Foundation)

## 목표

패키지를 추가하고 `lib/core/` 골격과 앱 부트스트랩을 세워, 이후 모든 feature가 얹힐 바닥을 만든다.

## 선행 조건

없음.

## 작업

### 1. 패키지 추가

`pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: 3.0.3     # 정확히 고정 (^ 없음)
  go_router: ^14.6.1
  shared_preferences: ^2.5.3
```

게임 엔진은 추가하지 않는다.

### 2. 플랫폼 확인

스캐폴드에 android / ios / macos / linux / windows / web 이 모두 생성되어 있다.
`fvm flutter run -d chrome`, `-d macos` 가 기본 앱으로 뜨는지만 확인한다. 지금 단계에서 아이콘·스플래시·번들 ID는 건드리지 않는다.

### 3. `core/` 골격

```
lib/core/
├── config/app_constants.dart      앱 이름, 애니메이션 duration 등 매직넘버 집합
├── di/core_providers.dart         sharedPreferencesProvider (UnimplementedError + override)
├── error/failure.dart             abstract Failure + fromError
├── error/failure_code.dart        enum FailureCode
├── extension/notifier_mixin.dart  NotifierStreamMixin (quizlab에서 그대로)
├── router/route_paths.dart        abstract class RoutePaths
├── router/router.dart             final GoRouter router
├── theme/base_theme.dart          + data/{light,dark}_theme.dart, data/spacing.dart, data/text_styles.dart
└── usecase/base_stream_usecase.dart
```

`Failure`는 quizlab 구조를 따르되 **Dio·소셜로그인 매퍼 체인은 가져오지 않는다.** `ClientFailure` 하나면 충분하다.

### 4. 앱 부트스트랩

`lib/main.dart`를 카운터 예제에서 교체한다.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const BlockRunnerApp(),
    ),
  );
}
```

`BlockRunnerApp`은 `MaterialApp.router(routerConfig: router, theme: ..., darkTheme: ...)`.

라우트는 일단 두 개만 선언하고 빈 화면을 붙여둔다 — `/level-select`, `/game-play`.

### 5. 테마

색상은 게임 보드에 쓸 팔레트를 먼저 정한다: 배경 / 격자선 / 벽 / 일반 블록 / 플레이어 블록 / 목표 / 구멍.
`data/light_theme.dart`·`dark_theme.dart` 양쪽에 정의하고, 게임 전용 색은 `ThemeExtension`으로 노출해 `CustomPainter`에서 꺼내 쓴다.

> 하드코딩된 `Color(0xFF...)`가 `CustomPainter` 안에 박히면 다크모드에서 손댈 수 없게 된다. 처음부터 테마로 뺀다.

## 완료 기준

- [ ] `fvm flutter pub get` 성공
- [ ] `fvm flutter analyze` 경고 0
- [ ] `fvm flutter run -d chrome` 과 데스크탑 1종에서 앱이 뜨고, `/level-select` 빈 화면이 보인다
- [ ] `lib/main.dart`에 카운터 예제 코드가 남아있지 않다
- [ ] 기본 위젯 테스트(`test/widget_test.dart`)가 새 앱에 맞게 수정되어 통과한다

## 열린 질문

- 색 팔레트를 직접 정할지, Material 3 `ColorScheme.fromSeed`로 파생시킬지 — 보드가 화면의 주인공이라 직접 정하는 쪽이 나아 보인다
- 앱 아이콘·스플래시는 언제 할지 (별도 task로 뺄 후보)
