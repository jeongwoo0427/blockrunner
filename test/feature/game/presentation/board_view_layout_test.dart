import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/theme/data/light_theme.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/block_tile.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_view.dart';
import 'package:blockrunner/feature/game/data/map_blueprints.dart';
import 'package:blockrunner/feature/game/data/map_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 보드를 [size] 크기의 화면에 그리고, 그려진 보드 영역의 크기를 돌려준다.
///
/// 오버플로가 나면 Flutter 가 예외를 던져 테스트가 실패하므로, "잘리지 않는다"는
/// 별도 단언 없이 통과 자체로 검증된다.
Future<Size> pumpBoard(WidgetTester tester, BoardState board, Size size) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: lightTheme,
      home: Scaffold(body: BoardView(board: board)),
    ),
  );

  return tester.getSize(
    find.ancestor(
      of: find.byType(CustomPaint),
      matching: find.byType(SizedBox),
    ),
  );
}

void main() {
  final board = const MapParser().parse(kMapBlueprints.first).initialBoard;

  const sizes = <String, Size>{
    '작은 폰': Size(320, 568),
    '세로로 긴 화면': Size(400, 900),
    '가로로 넓은 데스크탑': Size(1600, 900),
  };

  sizes.forEach((label, size) {
    testWidgets('$label 에서 6×6 보드가 정사각을 유지한다', (tester) async {
      final rendered = await pumpBoard(tester, board, size);

      expect(
        rendered.width,
        closeTo(rendered.height, 0.01),
        reason: '정사각 격자는 정사각으로 그려져야 한다',
      );
      expect(rendered.width, lessThanOrEqualTo(size.width));
      expect(rendered.height, lessThanOrEqualTo(size.height));
      expect(find.byType(BlockTile), findsNWidgets(board.blocks.length));
    });
  });

  testWidgets('큰 화면에서도 보드가 maxBoardExtent 를 넘지 않는다', (tester) async {
    final rendered = await pumpBoard(tester, board, const Size(2400, 2400));

    expect(rendered.width, lessThanOrEqualTo(AppConstants.maxBoardExtent));
  });

  testWidgets('정사각이 아닌 판도 셀은 정사각이다', (tester) async {
    // 2행 6열. 셀이 정사각이면 그려진 영역은 가로세로 비가 3:1 이어야 한다.
    final wide = const MapParser()
        .parse(
          const MapBlueprint(
            levelNumber: 98,
            rows: [
              '+-+-+-+-+-+-+',
              '|@ . . . . .|',
              '+ + + + + + +',
              '|. . . . . G|',
              '+-+-+-+-+-+-+',
            ],
          ),
        )
        .initialBoard;

    final rendered = await pumpBoard(tester, wide, const Size(600, 600));

    // 그려진 박스에는 외곽 프레임 여백이 양쪽으로 한 겹씩 들어 있다.
    // 셀이 정사각인지 보려면 격자 부분만 떼어내야 한다.
    final cell = rendered.width / (6 + 2 * Spacing.wallWidthRatio);
    final margin = cell * Spacing.wallWidthRatio;
    final grid = Size(
      rendered.width - 2 * margin,
      rendered.height - 2 * margin,
    );

    expect(grid.width / grid.height, closeTo(3, 0.01));
  });
}
