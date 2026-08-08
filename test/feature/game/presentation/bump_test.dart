import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/di/core_providers.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/game_di.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_event.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_state.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/block_tile.dart';
import 'package:blockrunner/feature/game/data/map_blueprints.dart';
import 'package:blockrunner/feature/game/data/map_parser.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/strings_harness.dart';

/// 갈 수 없는 방향을 눌렀을 때의 쫀득거림 (13-game-feel §7, 기획서 §3.2·§7).
void main() {
  final map = const MapParser().parse(kMapBlueprints.first);

  group('상태', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        for (final level in kLevels) 'tutorial_seen_v2_${level.number}': true,
      });
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    });

    tearDown(() => container.dispose());

    GamePlayScreenState read() =>
        container.read(gamePlayScreenNotifierProvider(1));

    Future<void> move(Direction direction) => container
        .read(gamePlayScreenNotifierProvider(1).notifier)
        .onEvent(MoveRequested(direction));

    // 레벨 1의 플레이어는 왼쪽 위 구석에서 시작한다 — 위·왼쪽은 첫 프레임부터
    // 막혀 있으므로 따로 벽에 붙일 필요가 없다.

    test('무효 입력은 이동 횟수를 올리지 않는다', () async {
      // 기획서 §3.2 — 연출이 생겨도 규칙은 그대로다.
      final pinned = read();

      await move(Direction.up);

      expect(read().moveCount, pinned.moveCount);
      expect(read().board, pinned.board);
    });

    test('막히면 그 방향이 상태에 남는다', () async {
      await move(Direction.up);

      expect(read().bump.direction, Direction.up);
      expect(read().bump.generation, 1);
    });

    test('같은 방향을 두 번 누르면 세대가 오른다', () async {
      // **세대가 없으면 상태가 같아 화면이 다시 재생하지 않는다.**
      await move(Direction.up);
      final first = read().bump;
      await move(Direction.up);

      expect(read().bump.generation, first.generation + 1);
      expect(read().bump, isNot(first));
    });

    test('쫀득거리는 중에도 다른 방향을 받는다', () async {
      // 이것은 연출이지 턴이 아니다 — `isAnimating` 을 세우지 않는 이유다.
      final moves = read().moveCount;

      await move(Direction.up);
      expect(read().isAnimating, isFalse);
      expect(read().canMove, isTrue);

      await move(Direction.right);
      expect(read().moveCount, moves + 1, reason: '유효한 수는 곧바로 먹혀야 한다');
    });

    test('유효한 수는 쫀득거림을 남기지 않는다', () async {
      await move(Direction.down);

      expect(read().bump.generation, 0);
      expect(read().bump.direction, isNull);
    });
  });

  group('화면', () {
    Future<void> pumpWith(WidgetTester tester, Bump bump) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        withStrings(
          GamePlayScreen(
            state: GamePlayScreenState(
              level: kLevels.first,
              map: map,
              board: map.initialBoard,
              bump: bump,
            ),
            onEvent: (GamePlayScreenEvent _) {},
          ),
        ),
      );
    }

    double blockX(WidgetTester tester) =>
        tester.getTopLeft(find.byType(BlockTile).first).dx;

    testWidgets('막히면 그 방향으로 밀렸다 돌아온다', (tester) async {
      await pumpWith(tester, const Bump.none());
      final resting = blockX(tester);

      // 같은 화면에 새 bump 를 주면 재생된다.
      await pumpWith(
        tester,
        const Bump(direction: Direction.right, generation: 1),
      );
      await tester.pump(AppConstants.bumpDuration ~/ 2);

      expect(blockX(tester), greaterThan(resting), reason: '오른쪽으로 밀려야 한다');

      // 갔다 돌아온다 — 판이 옮겨지는 것이 아니다.
      //
      // 레벨 1은 블랙홀도 튜토리얼도 없어 `pumpAndSettle` 이 끝난다.
      await tester.pumpAndSettle();
      expect(blockX(tester), closeTo(resting, 0.5));
    });

    testWidgets('같은 방향을 두 번 눌러도 두 번 재생된다', (tester) async {
      // **세대가 존재하는 이유가 이것이다.** 방향만 비교하면 두 번째 입력이
      // 삼켜져 아무 반응이 없다.
      await pumpWith(tester, const Bump.none());
      final resting = blockX(tester);

      await pumpWith(
        tester,
        const Bump(direction: Direction.right, generation: 1),
      );
      await tester.pumpAndSettle();
      expect(blockX(tester), closeTo(resting, 0.5), reason: '한 번째가 끝났다');

      await pumpWith(
        tester,
        const Bump(direction: Direction.right, generation: 2),
      );
      await tester.pump(AppConstants.bumpDuration ~/ 2);

      expect(blockX(tester), greaterThan(resting), reason: '두 번째도 밀려야 한다');
    });

    testWidgets('방향에 따라 반대로 밀린다', (tester) async {
      await pumpWith(tester, const Bump.none());
      final resting = blockX(tester);

      await pumpWith(
        tester,
        const Bump(direction: Direction.left, generation: 1),
      );
      await tester.pump(AppConstants.bumpDuration ~/ 2);

      expect(blockX(tester), lessThan(resting));
    });

    testWidgets('한 칸을 넘지 않는다', (tester) async {
      // 많이 밀리면 갈 수 있는 것처럼 보인다.
      await pumpWith(tester, const Bump.none());
      final resting = blockX(tester);
      final cell = tester.getSize(find.byType(BlockTile).first).width;

      await pumpWith(
        tester,
        const Bump(direction: Direction.right, generation: 1),
      );
      await tester.pump(AppConstants.bumpDuration ~/ 2);

      expect(blockX(tester) - resting, lessThan(cell / 2));
    });

    testWidgets('동작 줄이기를 켜면 흔들리지 않는다', (tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      Future<void> pumpReduced(Bump bump) => tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: withStrings(
            GamePlayScreen(
              state: GamePlayScreenState(
                level: kLevels.first,
                map: map,
                board: map.initialBoard,
                bump: bump,
              ),
              onEvent: (GamePlayScreenEvent _) {},
            ),
          ),
        ),
      );

      await pumpReduced(const Bump.none());
      final resting = blockX(tester);

      await pumpReduced(const Bump(direction: Direction.right, generation: 1));
      await tester.pump(AppConstants.bumpDuration ~/ 2);

      expect(blockX(tester), resting);
    });
  });
}
