import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/usecase/game_usecases.dart';
import 'package:blockrunner/feature/game/game_di.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_event.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GamePlayScreenNotifier extends Notifier<GamePlayScreenState> {
  /// Riverpod 3 는 `FamilyNotifier` 를 없앴고 family 의 생성 함수가
  /// `Notifier Function(Arg)` 이므로, 레벨 번호를 생성자로 받는다.
  GamePlayScreenNotifier(this.levelNumber);

  final int levelNumber;

  GameUsecases get _usecases => ref.read(gameUsecasesProvider);

  @override
  GamePlayScreenState build() {
    try {
      // 메타데이터(level)와 판(map)은 각자의 feature 가 소유하며 번호로 이어진다.
      final level = _usecases.getLevel(levelNumber);
      final map = _usecases.getMap(levelNumber);
      return GamePlayScreenState(
        level: level,
        map: map,
        board: map.initialBoard,
        hasNextLevel: _usecases.getAllLevels().any(
          (other) => other.number == levelNumber + 1,
        ),
      );
    } catch (error, stackTrace) {
      return GamePlayScreenState(failure: Failure.fromError(error, stackTrace));
    }
  }

  Future<void> onEvent(GamePlayScreenEvent event) async {
    switch (event) {
      case MoveRequested():
        _applyMove(event.direction);
      case ResetRequested():
        _reset();
      case NextLevelRequested():
      case BackToLevelSelectRequested():
        break; // 네비게이션은 Root 가 처리한다
    }
  }

  void _applyMove(Direction direction) {
    if (!state.canMove) return;

    final result = _usecases.applyMove(state.board!, direction);
    // 무효 입력은 상태도 이동 횟수도 건드리지 않는다 (기획서 §3.2).
    if (!result.moved) return;

    state = state.copyWith(
      board: () => result.board,
      moveCount: state.moveCount + 1,
      isCleared: result.board.isCleared,
      isPlayerLost: !result.board.hasPlayer,
    );
  }

  void _reset() {
    final map = state.map;
    if (map == null) return;

    state = state.copyWith(
      board: () => map.initialBoard,
      moveCount: 0,
      isCleared: false,
      isPlayerLost: false,
    );
  }
}
