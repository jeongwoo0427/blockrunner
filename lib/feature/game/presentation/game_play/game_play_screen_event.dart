import 'package:blockrunner/feature/game/domain/entity/direction.dart';

/// 플레이 화면이 Root 로 올려보내는 요청.
///
/// 되돌리기는 `07-undo-reset`, 연출 완료 통지는 `06-animation` 에서 추가한다.
/// 레벨 로드는 Notifier 의 `build()` 가 하므로 이벤트로 두지 않는다.
sealed class GamePlayScreenEvent {}

class MoveRequested extends GamePlayScreenEvent {
  MoveRequested(this.direction);

  final Direction direction;
}

class ResetRequested extends GamePlayScreenEvent {}

/// 튜토리얼 오버레이의 "시작" — 이 레벨은 봤다고 기록한다.
class TutorialDismissed extends GamePlayScreenEvent {}

/// 네비게이션은 Root 가 처리한다. Notifier 는 관여하지 않는다.
class NextLevelRequested extends GamePlayScreenEvent {}

class BackToLevelSelectRequested extends GamePlayScreenEvent {}
