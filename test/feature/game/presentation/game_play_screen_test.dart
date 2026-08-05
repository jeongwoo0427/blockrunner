import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/core/error/failure_code.dart';
import 'package:blockrunner/core/theme/data/light_theme.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
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
import 'package:flutter/services.dart';
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
    bool isAnimating = false,
    List<Block> fallingBlocks = const [],
    int moveCount = 0,
    int undosLeft = AppConstants.undoLimit,
    bool hasHistory = false,
    Level? level,
  }) => GamePlayScreenState(
    level: level ?? level1,
    showsTutorial: showsTutorial,
    map: map1,
    board: map1.initialBoard,
    // canUndo 는 되돌릴 판이 있어야 참이다.
    history: hasHistory ? [map1.initialBoard] : const [],
    undosLeft: undosLeft,
    moveCount: moveCount,
    isAnimating: isAnimating,
    fallingBlocks: fallingBlocks,
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

  group('되돌리기는 화면에 없다 (기획서 §5.1)', () {
    // 구현(history · undosLeft · _undo)은 살아 있고 **진입점만 없다.**
    // 편의로 되살리면 이 테스트가 먼저 걸리고, 그때 기획서 §5.1 을 보게 된다.

    testWidgets('되돌릴 판이 있어도 버튼이 없다', (tester) async {
      await pumpScreen(tester, stateOf(hasHistory: true, undosLeft: 3));

      expect(find.textContaining('되돌리기'), findsNothing);
      expect(find.byIcon(Icons.undo), findsNothing);
    });

    testWidgets('구멍에 빠진 오버레이에도 없다', (tester) async {
      await pumpScreen(
        tester,
        stateOf(isPlayerLost: true, hasHistory: true, undosLeft: 3),
      );

      expect(find.textContaining('되돌리기'), findsNothing);
      expect(find.textContaining('처음부터 다시'), findsOneWidget);
    });

    testWidgets('Z 키도 잇지 않는다', (tester) async {
      final events = await pumpScreen(tester, stateOf(hasHistory: true));

      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);

      expect(events, isEmpty);
    });

    testWidgets('Z 를 눌러도 방향키가 죽지 않는다', (tester) async {
      // 매핑하지 않은 키는 흘려보내는데, 그때 포커스가 떠나면
      // 그 뒤로 방향키까지 먹지 않는다 (05 에서 겪은 함정).
      final events = await pumpScreen(tester, stateOf());

      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

      expect(events.single, isA<MoveRequested>());
    });
  });

  group('결과 오버레이 (기획서 §5.2 · §3.5)', () {
    testWidgets('클리어하면 별점이 보인다', (tester) async {
      // 최소 수로 풀면 별 셋 — 채운 별 3, 빈 별 0.
      await pumpScreen(
        tester,
        stateOf(isCleared: true, moveCount: level1.minMoves),
      );

      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      expect(find.byIcon(Icons.star_outline_rounded), findsNothing);
    });

    testWidgets('수가 많으면 별이 줄고 빈 별로 채워진다', (tester) async {
      // 경계값은 level_stars_test 가 본다. 여기서는 "적게 채워지고 나머지가
      // 빈 별로 남는가" 만 보므로 어느 기준으로도 ★☆☆인 수를 쓴다.
      await pumpScreen(tester, stateOf(isCleared: true, moveCount: 30));

      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(2));
    });

    testWidgets('구멍에 빠지면 별점을 보여주지 않는다', (tester) async {
      await pumpScreen(tester, stateOf(isPlayerLost: true));

      expect(find.byIcon(Icons.star_rounded), findsNothing);
    });

    testWidgets('구멍에 빠지면 다시하기만 남는다 (기획서 §3.5)', (tester) async {
      await pumpScreen(tester, stateOf(isPlayerLost: true, hasHistory: true));

      // 다시하기는 항상 열려 있어야 게임이 끝나지 않는다.
      expect(find.widgetWithText(OutlinedButton, '다시하기'), findsOneWidget);
      expect(find.text('다음 레벨'), findsNothing);
    });
  });

  group('연출 (기획서 §7)', () {
    /// 같은 `events` 로 여러 번 다시 그린다 — `didUpdateWidget` 을 태워야 한다.
    Future<void> Function(GamePlayScreenState) rebuilder(
      WidgetTester tester,
      List<GamePlayScreenEvent> events,
    ) =>
        (state) => tester.pumpWidget(
          MaterialApp(
            theme: lightTheme,
            home: GamePlayScreen(state: state, onEvent: events.add),
          ),
        );

    testWidgets('연출이 끝나면 AnimationCompleted 를 올려보낸다', (tester) async {
      final events = <GamePlayScreenEvent>[];
      final pump = rebuilder(tester, events);

      await pump(stateOf());
      await pump(stateOf(isAnimating: true));
      expect(events, isEmpty, reason: '아직 재생 중이다');

      await tester.pump(AppConstants.moveAnimationDuration);
      expect(events.single, isA<AnimationCompleted>());
    });

    testWidgets('낙하가 있으면 그것까지 끝난 뒤에 통지한다', (tester) async {
      final events = <GamePlayScreenEvent>[];
      final pump = rebuilder(tester, events);

      await pump(stateOf());
      await pump(
        stateOf(
          isAnimating: true,
          // 빠진 블록은 판에서 지워지므로 판에 없는 id 여야 한다.
          fallingBlocks: const [
            Block(id: 99, type: BlockType.player, position: Position(0, 3)),
          ],
        ),
      );

      await tester.pump(AppConstants.moveAnimationDuration);
      expect(events, isEmpty, reason: '슬라이드만 끝났고 낙하가 남아 있다');

      await tester.pump(AppConstants.fallAnimationDuration);
      expect(events.single, isA<AnimationCompleted>());
    });

    testWidgets('연출이 끊기면 완료 통지가 나가지 않는다', (tester) async {
      final events = <GamePlayScreenEvent>[];
      final pump = rebuilder(tester, events);

      await pump(stateOf());
      await pump(stateOf(isAnimating: true));
      // 재생 도중 다시하기 — Notifier 가 isAnimating 을 내린다.
      await pump(stateOf());

      await tester.pump(AppConstants.moveWithFallDuration);
      expect(events, isEmpty, reason: '이미 끝난 판에 완료 통지가 날아가면 안 된다');
    });

    testWidgets('결과 오버레이는 연출이 끝난 뒤에 뜬다', (tester) async {
      final events = <GamePlayScreenEvent>[];
      final pump = rebuilder(tester, events);

      await pump(stateOf());
      await pump(stateOf(isCleared: true, isAnimating: true));

      expect(
        find.text('클리어!'),
        findsNothing,
        reason: '목표 칸으로 미끄러지는 장면을 오버레이가 덮으면 안 된다',
      );

      await tester.pump(AppConstants.moveAnimationDuration);
      await pump(stateOf(isCleared: true));
      expect(find.text('클리어!'), findsOneWidget);
    });

    testWidgets('연출 중 마운트돼도 완료 통지가 나간다', (tester) async {
      // 핫 리로드처럼 처음부터 isAnimating 인 채로 붙는 경우.
      // 통지가 안 나가면 입력이 영영 죽는다.
      final events = await pumpScreen(tester, stateOf(isAnimating: true));

      await tester.pump(AppConstants.moveAnimationDuration);
      expect(events.single, isA<AnimationCompleted>());
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
