import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/core/error/failure_code.dart';
import 'package:blockrunner/core/theme/data/light_theme.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_event.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_state.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/block_tile.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/control_hint.dart';
import 'package:blockrunner/feature/game/data/map_blueprints.dart';
import 'package:blockrunner/feature/game/data/map_parser.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **ProviderScope 로 감싸지 않는다.** Screen 이 Riverpod 을 건드리면 여기서
/// 바로 터진다 — "Screen 은 dumb" 규약의 실질적 가드다.
Future<List<GamePlayScreenEvent>> pumpScreen(
  WidgetTester tester,
  GamePlayScreenState state,
) async {
  final events = <GamePlayScreenEvent>[];

  await tester.pumpWidget(
    MaterialApp(
      theme: lightTheme,
      home: GamePlayScreen(state: state, onEvent: events.add),
    ),
  );

  return events;
}

void main() {
  final level1 = kLevels.first;
  final map1 = const MapParser().parse(kMapBlueprints.first);

  GamePlayScreenState stateOf({
    bool isCleared = false,
    bool isPlayerLost = false,
    bool hasNextLevel = true,
    int moveCount = 0,
  }) => GamePlayScreenState(
    level: level1,
    map: map1,
    board: map1.initialBoard,
    moveCount: moveCount,
    isCleared: isCleared,
    isPlayerLost: isPlayerLost,
    hasNextLevel: hasNextLevel,
  );

  testWidgets('보드의 블록 수만큼 타일이 그려진다', (tester) async {
    await pumpScreen(tester, stateOf());

    expect(
      find.byType(BlockTile),
      findsNWidgets(map1.initialBoard.blocks.length),
    );
    expect(find.text('레벨 1 · ${level1.name}'), findsOneWidget);
  });

  testWidgets('평소에는 결과 오버레이가 뜨지 않는다', (tester) async {
    await pumpScreen(tester, stateOf());

    expect(find.text('클리어!'), findsNothing);
    expect(find.text('구멍에 빠졌다'), findsNothing);
  });

  testWidgets('클리어하면 이동 횟수와 함께 결과가 뜬다', (tester) async {
    await pumpScreen(tester, stateOf(isCleared: true, moveCount: 3));

    expect(find.text('클리어!'), findsOneWidget);
    expect(find.text('3수 / 최소 ${level1.minMoves}수'), findsOneWidget);
    expect(find.text('다음 레벨'), findsOneWidget);
  });

  testWidgets('마지막 레벨이면 다음 레벨 버튼이 없다', (tester) async {
    await pumpScreen(tester, stateOf(isCleared: true, hasNextLevel: false));

    expect(find.text('클리어!'), findsOneWidget);
    expect(find.text('다음 레벨'), findsNothing);
  });

  testWidgets('플레이어가 빠지면 다시하기를 유도한다', (tester) async {
    await pumpScreen(tester, stateOf(isPlayerLost: true));

    expect(find.text('구멍에 빠졌다'), findsOneWidget);
    // HUD 의 것과 오버레이의 것, 둘 다 있어야 한다.
    expect(find.text('다시하기'), findsNWidgets(2));
    expect(find.text('다음 레벨'), findsNothing);
  });

  testWidgets('다시하기 버튼이 ResetRequested 를 올려보낸다', (tester) async {
    final events = await pumpScreen(tester, stateOf());

    await tester.tap(find.text('다시하기'));

    expect(events.single, isA<ResetRequested>());
  });

  testWidgets('화면 방향 버튼은 어느 플랫폼에도 두지 않는다 (기획서 §6)', (tester) async {
    await pumpScreen(tester, stateOf());

    for (final label in ['위', '아래', '왼쪽', '오른쪽']) {
      expect(find.byTooltip(label), findsNothing);
    }
    expect(find.byType(ControlHint), findsOneWidget, reason: '대신 조작 안내가 뜬다');
  });

  group('조작 안내 (기획서 §6.1)', () {
    testWidgets('레벨 1 을 아직 한 수도 두지 않았으면 뜬다', (tester) async {
      await pumpScreen(tester, stateOf());

      expect(find.byType(ControlHint), findsOneWidget);
    });

    testWidgets('첫 이동을 하면 사라진다 — 닫기 버튼이 없다', (tester) async {
      await pumpScreen(tester, stateOf(moveCount: 1));

      expect(find.byType(ControlHint), findsNothing);
    });

    testWidgets('첫 레벨이 아니면 뜨지 않는다', (tester) async {
      final later = kLevels.firstWhere((level) => level.number == 3);
      await pumpScreen(
        tester,
        GamePlayScreenState(level: later, map: map1, board: map1.initialBoard),
      );

      expect(find.byType(ControlHint), findsNothing);
    });
  });

  testWidgets('레벨도 실패도 없으면 로딩을 보여준다', (tester) async {
    await pumpScreen(tester, const GamePlayScreenState());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('레벨 로드에 실패하면 에러를 보여준다', (tester) async {
    await pumpScreen(
      tester,
      GamePlayScreenState(
        failure: ClientFailure(
          code: FailureCode.levelNotFound,
          stackTrace: StackTrace.current,
          debugMessage: '레벨 99 이 없다',
        ),
      ),
    );

    expect(find.textContaining('레벨을 불러오지 못했다'), findsOneWidget);
    expect(find.textContaining('레벨 99 이 없다'), findsOneWidget);
    expect(find.byType(BlockTile), findsNothing);
  });
}
