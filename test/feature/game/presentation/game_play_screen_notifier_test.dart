import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/error/failure_code.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/game_di.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:blockrunner/feature/progress/domain/repository/progress_repository.dart';
import 'package:blockrunner/feature/progress/progress_di.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_event.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_state.dart';
import 'package:blockrunner/core/di/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

  // 튜토리얼을 본 적 있는지 읽어야 하므로 Notifier 가 저장소를 필요로 한다.
  //
  // 기본은 **전부 본 상태**다. 튜토리얼이 떠 있으면 입력이 막히는데(기획서 §6.1),
  // 이동을 검사하는 테스트들이 매번 그것부터 닫아야 하면 본론이 흐려진다.
  final tutorialsSeen = {
    for (final level in kLevels) 'tutorial_seen_v2_${level.number}': true,
  };
  Future<void> boot({Map<String, Object>? preferences}) async {
    SharedPreferences.setMockInitialValues(preferences ?? tutorialsSeen);
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  }

  /// 모든 레벨을 여는 기록. 잠긴 레벨은 판을 만들지 않으므로(기획서 §5.3)
  /// 이것이 없으면 2번 이후를 쓰는 검사들이 전부 빈 상태를 보게 된다.
  ///
  /// **기록은 딱 하나만 심는다** — `highestUnlockedLevel` 은 클리어한 최대
  /// 번호 + 1 이라 마지막 바로 앞 레벨 하나면 전부 열린다. 레벨마다 심으면
  /// "클리어하지 않으면 저장하지 않는다" 를 보는 검사가 자기 기록과 남의
  /// 것을 구분할 수 없다. 999수는 실제 클리어가 언제나 진다.
  final allUnlocked = {
    'progress_v2_level_${kLevels[kLevels.length - 2].number}':
        '{"bestMoveCount":999,"stars":1}',
  };

  /// 기본 부팅 — 튜토리얼을 다 봤고 모든 레벨이 열려 있다.
  Future<void> bootUnlocked() =>
      boot(preferences: {...tutorialsSeen, ...allUnlocked});

  /// 진행도가 빈 상태 — **1번만 열려 있다.** 해금 자체를 보는 검사용이다.
  Future<void> bootWithoutProgress() => boot(preferences: tutorialsSeen);

  /// 튜토리얼을 아직 아무것도 보지 않은 상태. 판은 열어 둔다 — 여기서 보려는
  /// 것은 안내이지 해금이 아니다.
  Future<void> bootFresh() => boot(preferences: allUnlocked);

  setUp(() => bootUnlocked());
  tearDown(() => container.dispose());

  GamePlayScreenState read(int levelNumber) =>
      container.read(gamePlayScreenNotifierProvider(levelNumber));

  Future<void> send(int levelNumber, GamePlayScreenEvent event) => container
      .read(gamePlayScreenNotifierProvider(levelNumber).notifier)
      .onEvent(event);

  /// 블랙홀이 처음 나오는 레벨. 소실을 보는 검사는 전부 여기서 한다.
  ///
  /// **번호를 여러 곳에 흩어 두지 않는다.** 한때 `18` 이 여기저기 박혀 있었고,
  /// 그 레벨이 지워지자 여섯 건이 한꺼번에 깨졌다.
  const holeLevel = 13;

  /// 마지막 한 수를 남기고 블랙홀 앞까지 간다.
  Future<void> approachHole() async {
    await send(holeLevel, MoveRequested(Direction.up));
    await send(holeLevel, AnimationCompleted());
  }

  /// 플레이어를 블랙홀에 빠뜨린다. **연출은 끝내지 않는다** — 재생 중을 보는
  /// 검사가 있으므로 완료 통지는 부르는 쪽이 필요할 때 보낸다.
  Future<void> fallIntoHole() async {
    await approachHole();
    await send(holeLevel, MoveRequested(Direction.left));
  }

  test('build 가 레벨을 로드한다', () {
    final state = read(1);

    expect(state.level?.number, 1);
    expect(state.board, state.map?.initialBoard);
    expect(state.moveCount, 0);
    expect(state.failure, isNull);
    expect(state.hasNextLevel, isTrue);
  });

  test('마지막 레벨은 hasNextLevel 이 false 다', () {
    // 레벨을 추가해도 따라오도록 번호를 박아두지 않는다.
    expect(read(kLevels.last.number).hasNextLevel, isFalse);
  });

  group('해금 (기획서 §5.3)', () {
    test('잠긴 레벨은 판을 만들지도 않는다', () async {
      // 웹에서는 주소로 레벨 번호를 직접 칠 수 있다. 화면으로 들어오는 길만
      // 막아서는 부족하고, 그려 놓고 되돌리면 잠긴 판이 한 프레임 보인다.
      await bootWithoutProgress();

      final state = read(kLevels.last.number);

      expect(state.isLocked, isTrue);
      expect(state.board, isNull, reason: '잠긴 판은 만들기 전에 막는다');
      expect(state.level, isNull);
      expect(state.failure, isNull, reason: '오류가 아니라 잠긴 것이다');
    });

    test('열려 있는 레벨은 잠기지 않는다', () async {
      await bootWithoutProgress();

      // 1번은 진행도가 없어도 언제나 열려 있다.
      expect(read(1).isLocked, isFalse);
      expect(read(1).board, isNotNull);
    });
  });

  test('없는 레벨은 throw 하지 않고 failure 로 담긴다', () {
    final state = read(999);

    expect(state.failure?.code, FailureCode.levelNotFound);
    expect(state.board, isNull);
  });

  test('유효한 이동은 보드를 갱신하고 횟수를 센다', () async {
    // 레벨 2 의 첫 수: (3,0) 에서 위로 밀면 판 끝에 걸려 (0,0) 에 멈춘다.
    await send(2, MoveRequested(Direction.up));
    final state = read(2);

    expect(state.moveCount, 1);
    expect(state.board?.player?.position, const Position(0, 0));
    expect(state.isCleared, isFalse);
  });

  test('무효 입력은 보드도 횟수도 건드리지 않는다', () async {
    final before = read(1);

    // 레벨 1 의 플레이어는 왼쪽 위 구석에 있어 위로는 못 간다.
    await send(1, MoveRequested(Direction.up));
    final after = read(1);

    expect(after.board, same(before.board));
    expect(after.moveCount, 0);
  });

  test('목표에 멈추면 클리어가 된다', () async {
    // 레벨 1 의 목표는 반대편 모서리라 가로와 세로를 한 번씩 써야 한다.
    await send(1, MoveRequested(Direction.right));
    await send(1, AnimationCompleted());
    await send(1, MoveRequested(Direction.down));
    final state = read(1);

    expect(state.isCleared, isTrue);
    expect(state.moveCount, 2);
  });

  test('클리어한 뒤에는 이동 입력을 받지 않는다', () async {
    await send(1, MoveRequested(Direction.right));
    await send(1, AnimationCompleted());
    await send(1, MoveRequested(Direction.down));
    // 연출을 끝내둔다. 그러지 않으면 isAnimating 때문에 막혀서
    // "클리어라서 막힌다" 를 검사하지 못한다.
    await send(1, AnimationCompleted());

    await send(1, MoveRequested(Direction.left));

    expect(read(1).moveCount, 2, reason: '클리어 후 입력은 무시되어야 한다');
  });

  test('블랙홀에 빠지면 소실 상태가 되고 이후 입력이 막힌다', () async {
    await fallIntoHole();
    await send(holeLevel, AnimationCompleted());
    final lost = read(holeLevel);

    expect(lost.isPlayerLost, isTrue);
    expect(lost.board?.hasPlayer, isFalse);
    expect(lost.isCleared, isFalse);

    await send(holeLevel, MoveRequested(Direction.left));
    expect(
      read(holeLevel).moveCount,
      lost.moveCount,
      reason: '소실 상태에서는 입력이 막힌다',
    );
  });

  test('다시하기가 초기 배치와 횟수 0 으로 되돌린다', () async {
    await fallIntoHole();
    expect(read(holeLevel).isPlayerLost, isTrue);

    await send(holeLevel, ResetRequested());
    final state = read(holeLevel);

    expect(state.board, state.map?.initialBoard);
    expect(state.moveCount, 0);
    expect(state.isPlayerLost, isFalse);
    expect(state.isCleared, isFalse);
  });

  group('연출 상태 (기획서 §7)', () {
    test('이동하면 연출 상태가 되고 그동안 입력이 막힌다', () async {
      await send(2, MoveRequested(Direction.up));
      final state = read(2);

      expect(state.isAnimating, isTrue);
      expect(state.canMove, isFalse, reason: '연출 중 입력은 큐잉하지 않고 버린다');
    });

    test('완료 통지를 받아야 다시 움직일 수 있다', () async {
      await send(2, MoveRequested(Direction.up));
      await send(2, AnimationCompleted());

      expect(read(2).isAnimating, isFalse);
      expect(read(2).canMove, isTrue);

      await send(2, MoveRequested(Direction.right));
      expect(read(2).moveCount, 2);
    });

    test('무효 입력은 연출을 시작하지 않는다', () async {
      // 레벨 1 의 플레이어가 이미 위쪽 끝이라 아무것도 움직이지 않는다.
      await send(1, MoveRequested(Direction.up));

      expect(read(1).isAnimating, isFalse, reason: '판이 안 바뀌면 보여줄 것도 없다');
    });

    test('블랙홀에 빠진 블록은 빠진 칸에 놓인 채 남는다', () async {
      await fallIntoHole();
      final state = read(holeLevel);

      // 판에서는 지워졌지만 연출용으로는 살아 있어야 한다. 그러지 않으면
      // 블랙홀까지 미끄러지는 장면 없이 제자리에서 사라진다.
      expect(state.board?.hasPlayer, isFalse);
      expect(state.fallingBlocks, hasLength(1));

      final fallen = state.fallingBlocks.single;
      expect(fallen.isPlayer, isTrue);
      expect(
        state.map?.initialBoard.floorAt(fallen.position),
        FloorType.blackHole,
        reason: '연출 위치는 출발 칸이 아니라 빠진 블랙홀이어야 한다',
      );
      // 구멍은 블록을 삼키며 이미 사라졌다 (기획서 §3.3). 낙하가 끝날 때까지
      // 그것을 그려 주는 것은 `fallingBlocks` 이고, 판에는 남지 않는다.
      expect(state.board?.floorAt(fallen.position), FloorType.empty);

      await send(holeLevel, AnimationCompleted());
      expect(read(holeLevel).fallingBlocks, isEmpty);
    });

    test('다시하기는 재생 중인 연출을 끊는다', () async {
      await fallIntoHole();
      expect(read(holeLevel).isAnimating, isTrue);

      await send(holeLevel, ResetRequested());
      final state = read(holeLevel);

      expect(state.isAnimating, isFalse, reason: '다시하기는 즉시 반영이다');
      expect(state.fallingBlocks, isEmpty);
    });

    test('끊긴 뒤 늦게 도착한 완료 통지는 무시된다', () async {
      await fallIntoHole();
      await send(holeLevel, ResetRequested());
      // 다시하기 직전에 걸려 있던 타이머가 뒤늦게 울린 상황.
      await send(holeLevel, AnimationCompleted());

      final state = read(holeLevel);
      expect(state.board, state.map?.initialBoard);
      expect(state.moveCount, 0);
    });
  });

  group('진행도 저장 (09-progress)', () {
    ProgressRepository progress() => container.read(progressRepositoryProvider);

    test('클리어하면 기록이 저장된다', () async {
      await send(1, MoveRequested(Direction.right));
      await send(1, AnimationCompleted());
      await send(1, MoveRequested(Direction.down));
      final state = read(1);
      expect(state.isCleared, isTrue);

      final saved = progress().getProgress(1);
      expect(saved, isNotNull);
      expect(saved!.bestMoveCount, state.moveCount);
      expect(saved.stars, state.level!.starsFor(state.moveCount));
    });

    test('클리어하지 않으면 아무것도 저장하지 않는다', () async {
      await send(2, MoveRequested(Direction.up));

      // 판을 열어두려고 심어 둔 기록이 하나 있으므로 전체가 비었는지는 볼 수
      // 없다. **이 레벨의 기록**이 생기지 않았는지를 본다.
      expect(progress().getProgress(2), isNull);
    });

    test('클리어하면 다음 레벨이 열린다', () async {
      // 해금 자체를 보는 검사라 진행도가 비어 있어야 한다.
      await bootWithoutProgress();
      expect(progress().highestUnlockedLevel, 1);

      await send(1, MoveRequested(Direction.right));
      await send(1, AnimationCompleted());
      await send(1, MoveRequested(Direction.down));

      expect(progress().highestUnlockedLevel, 2);
    });

    test('블랙홀에 빠져도 저장하지 않는다', () async {
      await fallIntoHole();
      expect(read(holeLevel).isPlayerLost, isTrue);

      expect(progress().getProgress(holeLevel), isNull);
    });

    test('플레이 화면과 진행도가 같은 usecase 인스턴스를 쓴다', () async {
      // 인스턴스가 갈리면 레벨 선택 화면이 구독해도 방출을 못 받는다.
      // 조용히 어긋나는 종류라 여기서 못 박는다.
      final fromGame = container.read(gameUsecasesProvider).saveClearResult;
      final fromProgress = container
          .read(progressUsecasesProvider)
          .saveClearResult;

      expect(identical(fromGame, fromProgress), isTrue);
    });
  });

  group('되돌리기 (기획서 §5.1)', () {
    /// 이동 하나를 연출까지 끝낸다. 연출 중에는 다음 입력도 되돌리기도 막히므로
    /// 되돌리기를 검사하려면 매번 이걸 거쳐야 한다.
    Future<void> move(int levelNumber, Direction direction) async {
      await send(levelNumber, MoveRequested(direction));
      await send(levelNumber, AnimationCompleted());
    }

    test('연속 되돌리기로 초기 상태까지 정확히 되돌아간다', () async {
      final initial = read(2).board;

      // 레벨 2 에서 클리어하지 않고 지나가는 3수. 빈 4×4 판이라 두 수면
      // 어느 구석이든 닿는데, 목표는 (0,3) 이므로 0열에서 위아래로만 오간다.
      await move(2, Direction.up);
      await move(2, Direction.down);
      await move(2, Direction.up);
      expect(read(2).moveCount, 3, reason: '세 수 모두 실제로 움직여야 하는 판이다');

      for (var i = 0; i < 3; i++) {
        await send(2, UndoRequested());
      }

      final state = read(2);
      expect(state.board, initial);
      expect(state.moveCount, 0);
      expect(state.history, isEmpty);
    });

    test('한 수 무르면 이동 횟수도 하나 줄어든다', () async {
      await move(2, Direction.right);
      final afterMove = read(2).board;

      await send(2, UndoRequested());

      expect(read(2).moveCount, 0);
      expect(read(2).board, isNot(afterMove));
      expect(read(2).undosLeft, AppConstants.undoLimit - 1);
    });

    test('3회를 다 쓰면 더 무를 수 없다', () async {
      // 0열에서 위아래로만 왕복한다. 클리어해버리면 그 뒤 입력이 막혀서
      // 되돌릴 판이 안 쌓인다.
      for (var i = 0; i < 4; i++) {
        await move(2, Direction.up);
        await move(2, Direction.down);
      }

      for (var i = 0; i < AppConstants.undoLimit; i++) {
        await send(2, UndoRequested());
      }
      final exhausted = read(2);

      expect(exhausted.undosLeft, 0);
      expect(exhausted.canUndo, isFalse, reason: '되돌릴 판은 남았지만 횟수가 없다');
      expect(exhausted.history, isNotEmpty);

      await send(2, UndoRequested());
      expect(read(2).board, exhausted.board, reason: '무시돼야 한다');
      expect(read(2).moveCount, exhausted.moveCount);
    });

    test('무효 입력은 되돌리기 스택에 쌓이지 않는다', () async {
      // 레벨 1 의 플레이어가 이미 위쪽 끝이라 아무것도 움직이지 않는다.
      await send(1, MoveRequested(Direction.up));

      expect(read(1).history, isEmpty);
      expect(read(1).canUndo, isFalse);
    });

    test('블랙홀에 빠져도 되돌리기로 복구된다', () async {
      await fallIntoHole();
      // 되돌리기는 연출 중에는 막혀 있다(`canUndo`). 낙하까지 끝내고 무른다.
      await send(holeLevel, AnimationCompleted());
      expect(read(holeLevel).isPlayerLost, isTrue);

      await send(holeLevel, UndoRequested());
      final state = read(holeLevel);

      expect(state.board?.hasPlayer, isTrue);
      expect(state.isPlayerLost, isFalse, reason: '되돌린 판에서 판정을 다시 내야 한다');
      expect(state.canMove, isTrue);
    });

    test('클리어를 무르면 클리어도 풀린다', () async {
      await move(1, Direction.right);
      await move(1, Direction.down);
      expect(read(1).isCleared, isTrue);

      await send(1, UndoRequested());

      expect(read(1).isCleared, isFalse);
      expect(read(1).canMove, isTrue);
    });

    test('다시하기가 되돌리기 횟수를 되살린다', () async {
      await move(2, Direction.right);
      await send(2, UndoRequested());
      expect(read(2).undosLeft, AppConstants.undoLimit - 1);

      await send(2, ResetRequested());
      final state = read(2);

      expect(
        state.undosLeft,
        AppConstants.undoLimit,
        reason: '판을 처음으로 돌렸으면 자원도 처음으로 (기획서 §5.1)',
      );
      expect(state.history, isEmpty);
    });

    test('연출 중에는 무를 수 없다', () async {
      await send(2, MoveRequested(Direction.right));

      expect(read(2).isAnimating, isTrue);
      expect(read(2).canUndo, isFalse);
    });

    test('되돌린 판은 연출 없이 즉시 반영된다', () async {
      await move(2, Direction.right);

      await send(2, UndoRequested());

      expect(read(2).isAnimating, isFalse, reason: '되감기 연출은 재생하지 않는다 (기획서 §7)');
      expect(read(2).fallingBlocks, isEmpty);
    });
  });

  group('튜토리얼 (기획서 §6.1)', () {
    test('안내가 붙은 레벨을 처음 열면 오버레이가 뜨고 입력이 막힌다', () async {
      await bootFresh();
      final state = read(1);

      expect(state.level?.hasTutorial, isTrue);
      expect(state.showsTutorial, isTrue);
      expect(state.canMove, isFalse, reason: '읽는 동안 판이 움직이면 안 된다');
    });

    test('안내가 없는 레벨은 조용히 넘어간다', () async {
      await bootFresh();
      final state = read(2);

      expect(state.level?.hasTutorial, isFalse);
      expect(state.showsTutorial, isFalse);
      expect(state.canMove, isTrue);
    });

    test('이미 본 레벨은 다시 뜨지 않는다', () async {
      await boot(preferences: {'tutorial_seen_v2_1': true});

      expect(read(1).showsTutorial, isFalse);
    });

    test('닫으면 사라지고 기기에 기록된다', () async {
      await bootFresh();

      await send(1, TutorialDismissed());
      expect(read(1).showsTutorial, isFalse);
      expect(read(1).canMove, isTrue);

      // 새 컨테이너 = 앱을 다시 켠 상황. 저장돼 있으면 다시 뜨지 않는다.
      final prefs = await SharedPreferences.getInstance();
      final reopened = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(reopened.dispose);

      expect(
        reopened.read(gamePlayScreenNotifierProvider(1)).showsTutorial,
        isFalse,
      );
    });

    test('튜토리얼이 떠 있는 동안의 이동 입력은 무시된다', () async {
      await bootFresh();

      await send(1, MoveRequested(Direction.right));

      expect(read(1).moveCount, 0);
      expect(read(1).isCleared, isFalse);
    });
  });

  test('네비게이션 이벤트는 상태를 바꾸지 않는다', () async {
    final before = read(1);

    await send(1, NextLevelRequested());
    await send(1, BackToLevelSelectRequested());

    expect(read(1).board, same(before.board));
    expect(read(1).moveCount, 0);
  });
}
