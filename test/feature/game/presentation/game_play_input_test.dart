import 'package:blockrunner/core/widget/overlay_transition.dart';
import 'package:blockrunner/feature/game/data/map_blueprints.dart';
import 'package:blockrunner/feature/game/data/map_parser.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_event.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_state.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_view.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/strings_harness.dart';

/// 세 입력 경로(키보드 · 스와이프 · 화면 버튼)가 전부 `MoveRequested` 하나로
/// 수렴하는지, 그리고 판이 끝난 상태에서 막히는지 본다.
void main() {
  final level1 = kLevels.first;
  final map1 = const MapParser().parse(kMapBlueprints.first);

  Future<List<GamePlayScreenEvent>> pump(
    WidgetTester tester, {
    bool isCleared = false,
    bool isPlayerLost = false,
    bool hasNextLevel = false,
    bool showsTutorial = false,
  }) async {
    final events = <GamePlayScreenEvent>[];

    await tester.pumpWidget(
      withStrings(
        GamePlayScreen(
          state: GamePlayScreenState(
            level: level1,
            map: map1,
            board: map1.initialBoard,
            isCleared: isCleared,
            isPlayerLost: isPlayerLost,
            hasNextLevel: hasNextLevel,
            showsTutorial: showsTutorial,
          ),
          onEvent: events.add,
        ),
      ),
    );

    // **튜토리얼이 뜨면 `pumpAndSettle` 이 끝나지 않는다** — 데모가 끝없이
    // 반복한다. 오버레이 등장만 지나가면 되므로 정해진 시간만 흘린다.
    if (showsTutorial) {
      await tester.pump(overlayEntranceDuration);
    } else {
      await tester.pumpAndSettle();
    }

    return events;
  }

  List<Direction> movesIn(List<GamePlayScreenEvent> events) => events
      .whereType<MoveRequested>()
      .map((event) => event.direction)
      .toList();

  group('키보드', () {
    testWidgets('화면 진입 직후 클릭 없이 방향키가 먹는다', (tester) async {
      final events = await pump(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

      expect(movesIn(events), [Direction.right]);
    });

    testWidgets('네 방향키가 각 방향으로 매핑된다', (tester) async {
      final events = await pump(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

      expect(movesIn(events), [
        Direction.up,
        Direction.down,
        Direction.left,
        Direction.right,
      ]);
    });

    testWidgets('WASD 도 같은 방향으로 매핑된다', (tester) async {
      final events = await pump(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.keyW);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyD);

      expect(movesIn(events), [
        Direction.up,
        Direction.down,
        Direction.left,
        Direction.right,
      ]);
    });

    testWidgets('R 은 다시하기다', (tester) async {
      final events = await pump(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);

      expect(events.single, isA<ResetRequested>());
    });

    testWidgets('매핑되지 않은 키는 무시한다', (tester) async {
      final events = await pump(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyQ);

      expect(events, isEmpty);
    });

    testWidgets('키를 누르고 있어도 한 번만 처리한다', (tester) async {
      final events = await pump(tester);

      // 누름 → 반복 → 뗌. 반복 이벤트를 처리하면 연타가 된다.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);

      expect(movesIn(events), [Direction.right]);
    });
  });

  group('스와이프', () {
    testWidgets('보드를 가로질러 끌면 그 방향으로 이동한다', (tester) async {
      final events = await pump(tester);

      await tester.drag(find.byType(BoardView), const Offset(120, 0));
      await tester.pumpAndSettle();

      expect(movesIn(events), [Direction.right]);
    });

    testWidgets('세로 스와이프도 동작한다', (tester) async {
      final events = await pump(tester);

      await tester.drag(find.byType(BoardView), const Offset(0, -120));
      await tester.pumpAndSettle();

      expect(movesIn(events), [Direction.up]);
    });

    testWidgets('임계값보다 짧게 끌면 무시한다', (tester) async {
      final events = await pump(tester);

      await tester.drag(find.byType(BoardView), const Offset(6, 4));
      await tester.pumpAndSettle();

      expect(events, isEmpty);
    });
  });

  group('입력 게이트', () {
    testWidgets('클리어 상태에서는 어떤 경로로도 이동이 나가지 않는다', (tester) async {
      final events = await pump(tester, isCleared: true);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.drag(find.byType(BoardView), const Offset(120, 0));
      await tester.pumpAndSettle();

      expect(movesIn(events), isEmpty);
    });

    testWidgets('플레이어 소실 상태에서도 막히지만 다시하기는 열려 있다', (tester) async {
      final events = await pump(tester, isPlayerLost: true);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(movesIn(events), isEmpty);

      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      expect(events.whereType<ResetRequested>(), hasLength(1));
    });
  });

  group('확인 키 (Enter · Space)', () {
    testWidgets('결과 카드에서 엔터를 누르면 다음 레벨로 간다', (tester) async {
      // 클리어할 때마다 마우스로 손을 옮기게 되는 것이 불편하다는 요청이다.
      final events = await pump(tester, isCleared: true, hasNextLevel: true);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      // **곧바로 나가지 않는다.** 버튼을 누른 것과 똑같이 카드가 사라지고
      // 배경이 걷힌 뒤에 간다.
      expect(events.whereType<NextLevelRequested>(), isEmpty);
      await tester.pumpAndSettle();

      expect(events.whereType<NextLevelRequested>(), hasLength(1));
    });

    testWidgets('스페이스도 같다', (tester) async {
      final events = await pump(tester, isCleared: true, hasNextLevel: true);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(events.whereType<NextLevelRequested>(), hasLength(1));
    });

    testWidgets('블랙홀에 빠진 카드에서는 다음으로 넘어가지 않고 다시하기가 나간다', (tester) async {
      // **깨지 못한 판에서 넘어갈 수 있으면 안 된다** (기획서 §5.3).
      // 다음 레벨이 있다는 것만 보고 넘겨서 실제로 그렇게 됐던 자리다 —
      // 이 카드에는 "다음" 버튼이 아예 없고 주 동작이 다시하기다.
      final events = await pump(tester, isPlayerLost: true, hasNextLevel: true);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(events.whereType<NextLevelRequested>(), isEmpty);
      expect(events.whereType<ResetRequested>(), hasLength(1));
    });

    testWidgets('마지막 레벨에서는 아무 일도 하지 않는다', (tester) async {
      // "다음" 이 없는 카드다. 확인 키로 레벨 선택까지 나가버리면 되돌릴 수
      // 없는 이동이 손가락에 걸린다.
      final events = await pump(tester, isCleared: true);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      expect(events, isEmpty);
    });

    testWidgets('튜토리얼도 확인 키로 닫힌다', (tester) async {
      // **결과 카드만 이으면 반쪽이다.** 다음 레벨에 튜토리얼이 있으면 곧바로
      // 떠서 다시 마우스로 손이 간다.
      final events = await pump(tester, showsTutorial: true);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      expect(events.whereType<TutorialDismissed>(), hasLength(1));
    });

    testWidgets('판 위에서는 아무 일도 하지 않는다', (tester) async {
      // 카드가 없을 때 확인 키가 무언가를 하면 실수로 눌렀을 때 판이 넘어간다.
      final events = await pump(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);

      expect(events, isEmpty);
    });

    testWidgets('확인 키가 포커스를 뺏기지 않는다', (tester) async {
      // 삼키지 않으면 스페이스가 기본 "버튼 누르기" 로 새어나가 포커스가
      // 떠나고, 그 뒤로는 방향키가 죽는다 — 방향키에서 겪은 그 문제다.
      final events = await pump(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

      expect(movesIn(events), [Direction.right]);
    });
  });
}
