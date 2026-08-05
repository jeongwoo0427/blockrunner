import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/entity/move_result.dart';
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
        // 안내가 붙어 있고 아직 안 본 레벨이면 진입 직후 띄운다 (기획서 §6.1).
        showsTutorial:
            level.hasTutorial && !_usecases.hasSeenTutorial(levelNumber),
      );
    } catch (error, stackTrace) {
      return GamePlayScreenState(failure: Failure.fromError(error, stackTrace));
    }
  }

  Future<void> onEvent(GamePlayScreenEvent event) async {
    switch (event) {
      case MoveRequested():
        _applyMove(event.direction);
      case AnimationCompleted():
        // 다시하기로 연출이 이미 끊겼다면 늦게 도착한 통지다. 무시한다.
        if (!state.isAnimating) return;
        state = state.copyWith(isAnimating: false, fallingBlocks: const []);
      case ResetRequested():
        _reset();
      case TutorialDismissed():
        state = state.copyWith(showsTutorial: false);
        await _usecases.markTutorialSeen(levelNumber);
      case NextLevelRequested():
      case BackToLevelSelectRequested():
        break; // 네비게이션은 Root 가 처리한다
    }
  }

  void _applyMove(Direction direction) {
    if (!state.canMove) return;

    final before = state.board!;
    final result = _usecases.applyMove(before, direction);
    // 무효 입력은 상태도 이동 횟수도 건드리지 않는다 (기획서 §3.2).
    if (!result.moved) return;

    // 클리어·소실 판정은 여기서 확정된다. 결과 오버레이를 **언제 보여줄지**는
    // 화면이 정한다 — 미끄러지는 중에 덮어버리면 안 되기 때문이다(기획서 §7).
    state = state.copyWith(
      board: () => result.board,
      moveCount: state.moveCount + 1,
      isCleared: result.board.isCleared,
      isPlayerLost: !result.board.hasPlayer,
      isAnimating: true,
      fallingBlocks: _fallenBlocks(before, result),
    );
  }

  /// 구멍에 빠진 블록을 **빠진 칸에 놓인 채로** 되살려 돌려준다.
  ///
  /// `result.board` 에서는 이미 지워졌으므로, 이것이 없으면 구멍까지 미끄러지는
  /// 장면 없이 그 자리에서 순간 소멸한다.
  List<Block> _fallenBlocks(BoardState before, MoveResult result) => [
    for (final id in result.fellIntoHole)
      before.blocks
          .firstWhere((block) => block.id == id)
          .moveTo(result.to[id]!),
  ];

  void _reset() {
    final map = state.map;
    if (map == null) return;

    // 다시하기는 즉시 반영이다(기획서 §7). 재생 중이던 연출도 같이 끊는다.
    state = state.copyWith(
      board: () => map.initialBoard,
      moveCount: 0,
      isAnimating: false,
      fallingBlocks: const [],
      isCleared: false,
      isPlayerLost: false,
    );
  }
}
