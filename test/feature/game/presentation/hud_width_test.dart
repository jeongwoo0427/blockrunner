import 'package:blockrunner/core/theme/data/light_theme.dart';
import 'package:blockrunner/feature/game/data/map_blueprints.dart';
import 'package:blockrunner/feature/game/data/map_parser.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_event.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_state.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_view.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/game_hud.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// HUD 는 화면 폭이 아니라 **보드 폭**에 맞는다 (기획서 §6.2).
///
/// 이동 횟수와 다시하기가 화면 양 끝에 붙어 있으면 보드와 아무 관계없는 자리에
/// 떠 있는 것처럼 보인다.
void main() {
  final map = const MapParser().parse(kMapBlueprints.first);

  final state = GamePlayScreenState(
    level: kLevels.first,
    map: map,
    board: map.initialBoard,
  );

  /// [size] 화면에 플레이 화면을 그리고 (보드 폭, HUD 폭) 을 돌려준다.
  Future<(double board, double hud)> widthsAt(
    WidgetTester tester,
    Size size,
  ) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: GamePlayScreen(
          state: state,
          onEvent: (GamePlayScreenEvent _) {},
        ),
      ),
    );

    // `BoardView` 위젯 자체는 부모가 준 상자라 화면 폭에 가깝다. 실제로 그려진
    // 보드는 그 안에서 스스로 크기를 정한 `SizedBox` 다.
    final boardBox = find.descendant(
      of: find.byType(BoardView),
      matching: find.ancestor(
        of: find.byType(CustomPaint),
        matching: find.byType(SizedBox),
      ),
    );

    return (
      tester.getSize(boardBox).width,
      tester.getSize(find.byType(GameHud)).width,
    );
  }

  // 세로 고정이므로(기획서 §6.2) 폭이 짧은 변인 경우가 실제로 쓰이는 경우다.
  const sizes = <String, Size>{
    '작은 폰': Size(320, 568),
    '보통 폰': Size(390, 844),
    '세로로 긴 화면': Size(400, 1000),
  };

  sizes.forEach((label, size) {
    testWidgets('$label 에서 HUD 폭이 보드 폭과 같다', (tester) async {
      final (board, hud) = await widthsAt(tester, size);

      expect(hud, closeTo(board, 0.01));
    });
  });

  testWidgets('HUD 가 화면 끝까지 늘어나지 않는다', (tester) async {
    // 이 단언이 이 변경의 요점이다. 예전에는 HUD 가 화면 폭을 그대로 먹었다.
    const size = Size(390, 844);
    final (_, hud) = await widthsAt(tester, size);

    expect(hud, lessThan(size.width));
  });

  testWidgets('보드가 상한에 걸리면 HUD 도 같이 멈춘다', (tester) async {
    // 넓은 창에서 보드는 maxBoardExtent 에서 멈춘다. HUD 만 계속 넓어지면
    // 다시 화면 끝으로 떨어져 나간다.
    final (board, hud) = await widthsAt(tester, const Size(1600, 1200));

    expect(hud, closeTo(board, 0.01));
  });
}
