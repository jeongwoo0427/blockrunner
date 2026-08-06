import 'package:blockrunner/feature/level/domain/entity/level.dart';

/// 레벨 선택 화면이 Root 로 올려보내는 요청.
///
/// 둘 다 Notifier 의 상태를 바꾸지 않는다 — 네비게이션과 안내는 Root 의 일이다
/// (docs/architecture.md §5).
sealed class LevelSelectScreenEvent {}

class LevelSelected extends LevelSelectScreenEvent {
  LevelSelected(this.level);

  final Level level;
}

/// 잠긴 레벨을 눌렀다. 이동하지 않고 왜 못 가는지만 알린다.
class LockedLevelSelected extends LevelSelectScreenEvent {
  LockedLevelSelected(this.level);

  final Level level;
}

/// 설정을 열겠다. 다이얼로그를 띄우는 것은 Root 의 일이다.
class SettingsRequested extends LevelSelectScreenEvent {}

/// 진행도 초기화가 확정됐다. **이것만 Notifier 가 처리한다** — 저장소를
/// 건드리고 화면을 다시 읽어야 하기 때문이다 (12-ui-polish §3).
class ProgressResetConfirmed extends LevelSelectScreenEvent {}
