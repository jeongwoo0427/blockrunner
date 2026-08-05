import 'package:blockrunner/core/error/failure_code.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/game_di.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
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
  Future<void> boot({Map<String, Object>? preferences}) async {
    SharedPreferences.setMockInitialValues(
      preferences ??
          {for (final level in kLevels) 'tutorial_seen_${level.number}': true},
    );
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  }

  /// 튜토리얼을 아직 아무것도 보지 않은 상태로 다시 띄운다.
  Future<void> bootFresh() => boot(preferences: const {});

  setUp(() => boot());
  tearDown(() => container.dispose());

  GamePlayScreenState read(int levelNumber) =>
      container.read(gamePlayScreenNotifierProvider(levelNumber));

  Future<void> send(int levelNumber, GamePlayScreenEvent event) => container
      .read(gamePlayScreenNotifierProvider(levelNumber).notifier)
      .onEvent(event);

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

  test('없는 레벨은 throw 하지 않고 failure 로 담긴다', () {
    final state = read(999);

    expect(state.failure?.code, FailureCode.levelNotFound);
    expect(state.board, isNull);
  });

  test('유효한 이동은 보드를 갱신하고 횟수를 센다', () async {
    // 레벨 2 의 첫 수: 아래로 밀면 바닥 벽에 걸려 (4,0) 에 멈춘다.
    await send(2, MoveRequested(Direction.down));
    final state = read(2);

    expect(state.moveCount, 1);
    expect(state.board?.player?.position, const Position(4, 0));
    expect(state.isCleared, isFalse);
  });

  test('무효 입력은 보드도 횟수도 건드리지 않는다', () async {
    final before = read(2);

    // 플레이어가 이미 왼쪽 끝(0,0)에 있고 다른 블록도 없다.
    await send(2, MoveRequested(Direction.left));
    final after = read(2);

    expect(after.board, same(before.board));
    expect(after.moveCount, 0);
  });

  test('목표에 멈추면 클리어가 된다', () async {
    await send(1, MoveRequested(Direction.right));
    final state = read(1);

    expect(state.isCleared, isTrue);
    expect(state.moveCount, 1);
  });

  test('클리어한 뒤에는 이동 입력을 받지 않는다', () async {
    await send(1, MoveRequested(Direction.right));
    await send(1, MoveRequested(Direction.left));

    expect(read(1).moveCount, 1, reason: '클리어 후 입력은 무시되어야 한다');
  });

  test('구멍에 빠지면 소실 상태가 되고 이후 입력이 막힌다', () async {
    // 레벨 5 는 목표를 향해 곧장 밀면 구멍에 빠지도록 만들어져 있다.
    await send(5, MoveRequested(Direction.right));
    final lost = read(5);

    expect(lost.isPlayerLost, isTrue);
    expect(lost.board?.hasPlayer, isFalse);
    expect(lost.isCleared, isFalse);

    await send(5, MoveRequested(Direction.down));
    expect(read(5).moveCount, lost.moveCount, reason: '소실 상태에서는 입력이 막힌다');
  });

  test('다시하기가 초기 배치와 횟수 0 으로 되돌린다', () async {
    await send(5, MoveRequested(Direction.right));
    expect(read(5).isPlayerLost, isTrue);

    await send(5, ResetRequested());
    final state = read(5);

    expect(state.board, state.map?.initialBoard);
    expect(state.moveCount, 0);
    expect(state.isPlayerLost, isFalse);
    expect(state.isCleared, isFalse);
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
      await boot(preferences: {'tutorial_seen_1': true});

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
