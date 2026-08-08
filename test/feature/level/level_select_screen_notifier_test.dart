import 'package:blockrunner/core/di/core_providers.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/game_di.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_event.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:blockrunner/feature/level/level_di.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

  Future<void> boot([Map<String, Object> preferences = const {}]) async {
    SharedPreferences.setMockInitialValues({
      // 튜토리얼이 떠 있으면 이동이 막힌다 (기획서 §6.1).
      for (final level in kLevels) 'tutorial_seen_v2_${level.number}': true,
      ...preferences,
    });
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  }

  setUp(boot);
  tearDown(() => container.dispose());

  LevelSelectScreenState read() =>
      container.read(levelSelectScreenNotifierProvider);

  test('레벨 전부를 싣는다', () {
    expect(
      read().levels.map((level) => level.number),
      kLevels.map((l) => l.number),
    );
    expect(read().failure, isNull);
  });

  test('진행도가 없으면 1번만 열려 있다', () {
    final state = read();

    expect(state.highestUnlockedLevel, 1);
    expect(state.isUnlocked(1), isTrue);
    expect(state.isUnlocked(2), isFalse);
    expect(state.progressOf(1), isNull);
  });

  test('저장된 진행도가 해금과 별점에 반영된다', () async {
    await boot({
      'progress_v2_level_1': '{"bestMoveCount": 1, "stars": 3}',
      'progress_v2_level_2': '{"bestMoveCount": 5, "stars": 1}',
    });
    final state = read();

    expect(state.highestUnlockedLevel, 3);
    expect(state.isUnlocked(3), isTrue);
    expect(state.isUnlocked(4), isFalse);
    expect(state.progressOf(2)?.stars, 1);
    expect(state.progressOf(2)?.bestMoveCount, 5);
  });

  test('클리어하면 화면 재진입 없이 별점과 해금이 갱신된다', () async {
    // 이 테스트가 스트림 구독(architecture.md §6)의 존재 이유다.
    // 구독이 끊기면 화면을 나갔다 들어와야만 갱신된다.
    expect(read().isUnlocked(2), isFalse);
    expect(read().progressOf(1), isNull);

    // 같은 컨테이너에서 레벨 1 을 클리어한다 — 화면을 다시 만들지 않는다.
    final gameNotifier = container.read(
      gamePlayScreenNotifierProvider(1).notifier,
    );
    await gameNotifier.onEvent(MoveRequested(Direction.right));
    await gameNotifier.onEvent(AnimationCompleted());
    await gameNotifier.onEvent(MoveRequested(Direction.down));

    // 스트림 방출이 한 바퀴 돌 틈을 준다.
    await Future<void>.delayed(Duration.zero);

    final state = read();
    expect(state.progressOf(1)?.stars, 3, reason: '최소 수로 풀었으므로 ★★★');
    expect(state.isUnlocked(2), isTrue, reason: '2번이 열려야 한다');
  });

  test('클리어 알림이 오면 그 레벨만이 아니라 해금 상태도 다시 읽는다', () async {
    final gameNotifier = container.read(
      gamePlayScreenNotifierProvider(1).notifier,
    );
    await gameNotifier.onEvent(MoveRequested(Direction.right));
    await gameNotifier.onEvent(AnimationCompleted());
    await gameNotifier.onEvent(MoveRequested(Direction.down));
    await Future<void>.delayed(Duration.zero);

    // 알림이 준 LevelProgress 만 끼워넣었다면 highestUnlockedLevel 은
    // 그대로 1 이었을 것이다.
    expect(read().highestUnlockedLevel, 2);
  });
}
