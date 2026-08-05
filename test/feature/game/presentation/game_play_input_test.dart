import 'package:blockrunner/core/theme/data/light_theme.dart';
import 'package:blockrunner/feature/game/data/map_blueprints.dart';
import 'package:blockrunner/feature/game/data/map_parser.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_event.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_state.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_view.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 세 입력 경로(키보드 · 스와이프 · 화면 버튼)가 전부 `MoveRequested` 하나로
/// 수렴하는지, 그리고 판이 끝난 상태에서 막히는지 본다.
void main() {
  final level1 = kLevels.first;
  final map1 = const MapParser().parse(kMapBlueprints.first);

  Future<List<GamePlayScreenEvent>> pump(
    WidgetTester tester, {
    bool isCleared = false,
    bool isPlayerLost = false,
  }) async {
    final events = <GamePlayScreenEvent>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: GamePlayScreen(
          state: GamePlayScreenState(
            level: level1,
            map: map1,
            board: map1.initialBoard,
            isCleared: isCleared,
            isPlayerLost: isPlayerLost,
          ),
          onEvent: events.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

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
}
