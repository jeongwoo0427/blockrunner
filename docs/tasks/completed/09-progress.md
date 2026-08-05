# 09. 진행도 저장

## 목표

클리어 여부, 최고 별점, 최소 이동 기록을 로컬에 저장하고 읽는다. 계정·서버 동기화는 없다.

## 선행 조건

- [00-foundation.md](completed/00-foundation.md) (`sharedPreferencesProvider`)
- [07-undo-reset.md](completed/07-undo-reset.md)

> **별점 계산은 이미 있다.** `Level.starsFor(moveCount)` 가 기획서 §5.2 표를
> 구현하고 경계값 테스트(`test/feature/level/level_stars_test.dart`)까지 붙어 있다.
> 결과 오버레이도 그 값을 이미 그린다. **이 작업이 할 일은 저장과 갱신 규칙**
> — 최고 기록만 남기기, 해금 판정, `SaveClearResultUsecase` 의 스트림 방출이다.
> 별점 공식을 다시 만들지 말 것.

> **먼저 읽을 것:** 저장소를 쓰는 코드가 이미 하나 있다. `level` feature 의
> `TutorialRepository` 가 "어느 레벨의 튜토리얼을 봤는지" 를 `SharedPreferences` 에
> 직접 담는다(기획서 §6.1). 튜토리얼 문구가 `Level` 에 붙어 있어 거기 뒀다.
> **클리어 여부 · 별점 · 최고 기록은 이 작업이 소유한다.** 튜토리얼 플래그를 이쪽으로
> 옮길지는 판단에 맡기되, 두 곳에서 같은 것을 저장하지는 말 것.

## 작업

### 1. 엔티티

`lib/feature/progress/domain/entity/level_progress.dart`

```dart
class LevelProgress {
  final int levelNumber;
  final bool cleared;
  final int bestMoveCount;   // 미클리어면 의미 없음
  final int stars;           // 0~3
}
```

### 2. Repository

`lib/feature/progress/domain/repository/progress_repository.dart`

```dart
abstract class ProgressRepository {
  Map<int, LevelProgress> getAllProgress();
  LevelProgress? getProgress(int levelNumber);
  Future<void> saveProgress(LevelProgress progress);
  int get highestUnlockedLevel;
  Future<void> clearAll();      // 개발/테스트용
}
```

### 3. 구현 — datasource 없이

`lib/feature/progress/data/repository/progress_repository_impl.dart`

`SharedPreferences`를 **생성자로 직접 주입받는다.** local datasource 계층을 만들지 않는다 ([../architecture.md](../architecture.md) §3).

```dart
class ProgressRepositoryImpl implements ProgressRepository {
  final SharedPreferences _prefs;
  ProgressRepositoryImpl({required SharedPreferences prefs}) : _prefs = prefs;
  ...
}
```

**저장 형식:** 레벨 하나당 키 하나(`progress_level_3`)에 JSON 문자열. 전체를 한 키에 몰아넣지 않는다 — 부분 저장이 되고, 한 레벨의 데이터가 깨져도 나머지가 살아남는다.

**읽기는 동기, 쓰기는 비동기.** `SharedPreferences`는 값을 메모리에 캐시하므로 읽기를 `Future`로 감쌀 이유가 없다. UI가 로딩 상태 없이 즉시 그릴 수 있다.

### 4. 손상 데이터 처리

파싱에 실패한 항목은 **버리고 미클리어로 취급한다.** throw하지 않는다.

> 저장 형식이 바뀌었거나 데이터가 깨졌다고 앱이 켜지지 않으면 안 된다. 진행도는 잃어도 되는 데이터다.

### 5. Usecase

- `GetAllProgressUsecase`, `GetHighestUnlockedLevelUsecase`
- `SaveClearResultUsecase extends BaseStreamUsecase<LevelProgress>` — 저장 후 `yieldData()`
  - **기존 기록보다 나쁘면 갱신하지 않는다** (이동 횟수가 더 적을 때만 갱신)
  - 이 방출을 레벨 선택 화면이 구독한다 ([08-level-select.md](08-level-select.md))

컨테이너 `ProgressUsecases` + `lib/feature/progress/progress_di.dart`.

### 6. 화면 없음

이 feature에는 `presentation/`이 없다. 다른 feature가 usecase로만 쓴다.

## 완료 기준

- [x] 클리어 후 앱을 완전히 종료했다 재실행해도 별점·해금이 유지된다 — **테스트 수준까지.** 새 `ProgressRepositoryImpl` 인스턴스가 같은 저장소를 읽는 것으로 확인했다. 실제 앱 재실행 육안 확인은 아래 "남은 사항"
- [x] 더 나쁜 기록으로 재클리어해도 최고 기록이 유지된다
- [x] 저장값을 임의로 훼손해도 앱이 정상 기동한다 (테스트로 확인)
- [ ] 웹(`-d chrome`)에서도 저장이 동작한다 — **미확인.** 코드상 `SharedPreferences` 웹 구현(localStorage)을 그대로 타므로 플랫폼 분기는 없지만, 눈으로 보지 못했다
- [x] `ProgressRepositoryImpl` 단위 테스트 (`SharedPreferences.setMockInitialValues` 사용)
- [x] `data/datasource/` 디렉터리가 존재하지 않는다 — `find lib -type d -name datasource` → 0개

## 열린 질문 — **해소됨**

- ~~저장 형식 버전 필드~~ → **키 접두사에 `v1` 을 넣었다** (`progress_v1_level_3`). 문서의 기울어진 판단대로다. 형식이 바뀌면 접두사를 올려 옛 키를 무시하면 되고, 지금 붙이는 비용은 0이다
- ~~설정 화면의 "진행도 초기화"~~ → **`clearAll` 은 만들었고 UI 는 노출하지 않았다.** 설정 화면 자체가 없다
- ~~웹 저장소 삭제 안내~~ → **하지 않는다.** 진행도는 잃어도 되는 데이터라는 것이 이 작업의 전제(§4)이고, 안내할 화면도 없다

---

## 실제 결과

### 별점은 `SaveClearResultUsecase` 가 계산한다

호출부(Notifier)가 `Level` 과 이동 횟수만 넘기면 usecase 가 `level.starsFor` 를 불러 채운다. 호출부마다 계산하면 기준이 갈리고, `progress → level` 은 이미 허용된 방향이다.

### 갱신하지 않을 때도 방출한다

기존 기록이 더 좋으면 저장은 건너뛰지만 **스트림에는 흘린다.** 구독자(레벨 선택 화면) 입장에서는 "방금 이 레벨을 깼다" 가 여전히 새 정보이고, 해금 상태가 바뀌었을 수도 있다.

### `SaveClearResultUsecase` 는 인스턴스가 하나다

스트림을 들고 있어서, 두 컨테이너가 각자 만들면 **구독자가 방출을 영원히 못 받는다.** 컴파일도 테스트도 통과하면서 조용히 어긋나는 종류라 `GameUsecases` 가 이미 만들어진 인스턴스를 주입받게 했다. 컨테이너 factory 가 repository 만 받는다는 규칙의 유일한 예외이고, `architecture.md` §6 에 적었다. **두 컨테이너가 같은 인스턴스를 보는지 테스트가 확인한다.**

### 저장 시점은 이동 계산 직후

연출이 끝나기를 기다리지 않는다. 기록은 이미 확정됐고 그 사이에 앱이 닫혀도 남아야 한다. 다만 **상태를 세운 뒤에** 저장한다 — 먼저 기다리면 저장이 끝날 때까지 연출이 시작되지 않아 입력이 멎은 것처럼 보인다.

### `LevelProgress` 에 `cleared` 필드를 두지 않았다

작업 문서의 초안에는 `bool cleared` 가 있었지만, **저장된 레코드가 있다는 것이 곧 클리어했다는 뜻**이다. `cleared: false` 를 적으면 의미 없는 빈 레코드가 쌓이고 "없음" 과 "미클리어" 라는 같은 뜻의 두 상태가 생긴다. `isCleared` 는 항상 `true` 인 게터로 남겼다.

### 남은 사항

- **육안 확인을 못 했다.** 웹에서 클리어 → 새로고침 → 기록 유지를 눈으로 봐야 한다
- 해금은 저장되지만 **강제하는 곳이 없다.** 레벨 선택 화면이 `08` 에서 이 값을 읽어 잠금을 그린다. 지금은 URL 로 아무 레벨이나 열 수 있다
- 튜토리얼 플래그는 `level` feature 에 그대로 뒀다. 문구가 `Level` 에 붙어 있어 응집도가 높고, 진행도와 저장하는 것이 다르다(§6.1 vs §5.3)
