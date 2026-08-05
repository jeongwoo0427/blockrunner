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

- [ ] 클리어 후 앱을 완전히 종료했다 재실행해도 별점·해금이 유지된다
- [ ] 더 나쁜 기록으로 재클리어해도 최고 기록이 유지된다
- [ ] 저장값을 임의로 훼손해도 앱이 정상 기동한다 (테스트로 확인)
- [ ] 웹(`-d chrome`)에서도 저장이 동작한다 — localStorage 기반
- [ ] `ProgressRepositoryImpl` 단위 테스트 (`SharedPreferences.setMockInitialValues` 사용)
- [ ] `data/datasource/` 디렉터리가 존재하지 않는다

## 열린 질문

- 저장 형식 버전 필드를 지금 넣을지 — 키에 `v1_` 접두사만 붙여두면 나중에 마이그레이션이 쉬워진다. 비용이 없으므로 넣는 쪽으로 기운다
- 설정 화면에서 "진행도 초기화"를 노출할지 (`clearAll`은 만들어두되 UI는 나중에)
- 웹에서 브라우저 저장소를 지우면 진행도가 날아간다 — 안내를 할지, 그냥 둘지
