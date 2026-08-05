import 'package:blockrunner/feature/game/domain/entity/direction.dart';

/// 플레이 화면이 Root 로 올려보내는 요청.
///
/// 되돌리기는 `07-undo-reset` 에서 추가한다.
/// 레벨 로드는 Notifier 의 `build()` 가 하므로 이벤트로 두지 않는다.
sealed class GamePlayScreenEvent {}

class MoveRequested extends GamePlayScreenEvent {
  MoveRequested(this.direction);

  final Direction direction;
}

/// 이동 연출이 끝났다. **화면만이 이 시점을 안다** — 연출 길이는 물론이고
/// OS 의 "동작 줄이기" 설정으로 연출을 건너뛰었는지도 화면 쪽 정보다.
/// Notifier 는 타이머를 갖지 않고 이 통지를 기다린다.
class AnimationCompleted extends GamePlayScreenEvent {}

class ResetRequested extends GamePlayScreenEvent {}

/// 튜토리얼 오버레이의 "시작" — 이 레벨은 봤다고 기록한다.
class TutorialDismissed extends GamePlayScreenEvent {}

/// 네비게이션은 Root 가 처리한다. Notifier 는 관여하지 않는다.
class NextLevelRequested extends GamePlayScreenEvent {}

class BackToLevelSelectRequested extends GamePlayScreenEvent {}
