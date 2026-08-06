import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/core/extension/notifier_mixin.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases.dart';
import 'package:blockrunner/feature/level/level_di.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen_event.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LevelSelectScreenNotifier extends Notifier<LevelSelectScreenState>
    with NotifierStreamMixin<LevelSelectScreenState> {
  LevelUsecases get _usecases => ref.read(levelUsecasesProvider);

  @override
  LevelSelectScreenState build() {
    // 플레이 화면에서 클리어하면 여기로 알림이 온다. 이것이 없으면 화면을
    // 나갔다 들어와야 별점과 해금이 갱신된다 (docs/architecture.md §6).
    listenStream(_usecases.clearResults, (_) => _reload());

    return _load();
  }

  LevelSelectScreenState _load() {
    try {
      return LevelSelectScreenState(
        levels: _usecases.getAllLevels(),
        progress: _usecases.getAllProgress(),
        highestUnlockedLevel: _usecases.getHighestUnlockedLevel(),
      );
    } catch (error, stackTrace) {
      return LevelSelectScreenState(
        failure: Failure.fromError(error, stackTrace),
      );
    }
  }

  /// 알림이 준 값만 끼워넣지 않고 저장소를 다시 읽는다.
  ///
  /// 한 번의 클리어가 그 레벨의 별점만이 아니라 **해금 상태까지** 바꾸고,
  /// 저장소가 이미 그 계산을 갖고 있다. 여기서 다시 계산하면 규칙이 두 곳에 생긴다.
  void _reload() => state = _load();

  // ignore: use_setters_to_change_properties
  Future<void> onEvent(LevelSelectScreenEvent event) async {
    switch (event) {
      case LevelSelected():
      case LockedLevelSelected():
      case SettingsRequested():
        break; // 네비게이션 · 안내 · 다이얼로그는 Root 가 처리한다
      case ProgressResetConfirmed():
        await _usecases.resetProgress();
        _reload();
    }
  }
}
