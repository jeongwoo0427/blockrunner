import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/core/error/failure_code.dart';
import 'package:blockrunner/core/theme/data/light_theme.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_event.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_state.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/block_tile.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/tutorial_overlay.dart';
import 'package:blockrunner/feature/game/data/map_blueprints.dart';
import 'package:blockrunner/feature/game/data/map_parser.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_view.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:blockrunner/feature/level/domain/entity/level.dart';
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
    bool showsTutorial = false,
    int moveCount = 0,
    Level? level,
  }) => GamePlayScreenState(
    level: level ?? level1,
    showsTutorial: showsTutorial,
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
  });

  group('튜토리얼 오버레이 (기획서 §6.1)', () {
    testWidgets('showsTutorial 이면 레벨 이름과 안내가 뜬다', (tester) async {
      await pumpScreen(tester, stateOf(showsTutorial: true));

      expect(find.byType(TutorialOverlay), findsOneWidget);
      expect(find.text(level1.name!), findsOneWidget);
      expect(find.textContaining('미끄러진다'), findsOneWidget);
      expect(find.text('시작'), findsOneWidget);
    });

    testWidgets('평소에는 뜨지 않는다', (tester) async {
      await pumpScreen(tester, stateOf());

      expect(find.byType(TutorialOverlay), findsNothing);
    });

    testWidgets('레이아웃을 차지하지 않는다 — 보드 크기가 그대로다', (tester) async {
      await pumpScreen(tester, stateOf(showsTutorial: true));
      final withOverlay = tester.getSize(find.byType(BoardView));

      await pumpScreen(tester, stateOf());
      final without = tester.getSize(find.byType(BoardView));

      expect(withOverlay, without, reason: '오버레이가 사라져도 판이 튀면 안 된다');
    });

    testWidgets('시작을 누르면 TutorialDismissed 를 올려보낸다', (tester) async {
      final events = await pumpScreen(tester, stateOf(showsTutorial: true));

      await tester.tap(find.text('시작'));

      expect(events.single, isA<TutorialDismissed>());
    });

    testWidgets('안내가 없는 레벨은 오버레이를 그리지 않는다', (tester) async {
      final plain = kLevels.firstWhere((level) => !level.hasTutorial);
      await pumpScreen(tester, stateOf(level: plain, showsTutorial: true));

      expect(find.byType(TutorialOverlay), findsNothing);
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
