import 'dart:ui' as ui;

import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:blockrunner/core/theme/data/light_theme.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/domain/entity/wall_edge.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/block_tile.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_painter.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 눈으로는 "조금 밀린 것 같다" 밖에 말할 수 없어서 직접 잰다.
///
/// 실제로 났던 버그가 둘이다.
/// - 외곽 프레임이 **칸 안쪽을** 파고들어 가장자리 칸만 여백이 비대칭이었다
/// - 경계 벽에 `StrokeCap.square` 를 써서 선이 칸 하나보다 길게 그려졌다
void main() {
  BoardState boardWith(
    List<Position> positions, {
    Set<WallEdge> walls = const {},
  }) {
    final floors = List.generate(
      6,
      (_) => List.filled(6, FloorType.empty),
      growable: false,
    );

    return BoardState(
      rowCount: 6,
      colCount: 6,
      floors: floors,
      walls: walls,
      blocks: [
        for (var i = 0; i < positions.length; i++)
          Block(
            id: i,
            type: i == 0 ? BlockType.player : BlockType.normal,
            position: positions[i],
          ),
      ],
    );
  }

  testWidgets('가장자리를 포함한 모든 칸에서 블록이 칸 정중앙에 온다', (tester) async {
    const cells = [
      Position(0, 0),
      Position(0, 5),
      Position(5, 0),
      Position(5, 5),
      Position(3, 3),
    ];

    tester.view
      ..physicalSize = const Size(600, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: Scaffold(body: BoardView(board: boardWith(cells))),
      ),
    );

    final outer = tester.getRect(
      find.ancestor(
        of: find.byType(CustomPaint),
        matching: find.byType(SizedBox),
      ),
    );
    // 바깥 박스 = 격자 + 프레임 여백 두 겹.
    final cell = outer.width / (6 + 2 * Spacing.wallWidthRatio);
    final margin = cell * Spacing.wallWidthRatio;

    for (var i = 0; i < cells.length; i++) {
      final position = cells[i];
      final expected = Offset(
        outer.left + margin + (position.col + 0.5) * cell,
        outer.top + margin + (position.row + 0.5) * cell,
      );
      final actual = tester.getRect(find.byType(BlockTile).at(i)).center;

      expect(
        (actual - expected).distance,
        lessThan(0.01),
        reason: '$position 의 블록이 칸 중심에서 ${actual - expected} 만큼 밀렸다',
      );
    }
  });

  test('외곽 프레임이 칸 안쪽을 침범하지 않는다', () async {
    // 페인터를 직접 그려 픽셀로 확인한다.
    const side = 620.0;
    const cell = 100.0;
    const margin = cell * Spacing.wallWidthRatio; // 10
    final board = boardWith(const [Position(0, 0)]);

    final image = await _paint(board, side, cell, const Offset(margin, margin));
    final data = await image.toByteData();
    int px(int x, int y) => data!.getUint32((y * image.width + x) * 4);

    final background = px(50, 350);

    // 격자 안쪽 첫 칸의 왼쪽 끝(x = margin) 바로 안은 배경이어야 한다.
    expect(
      px(margin.toInt() + 1, 350),
      background,
      reason: '프레임이 첫 칸 안으로 파고들었다',
    );
    // 프레임 자체는 여백(0 ~ margin)에 있다.
    expect(px(margin.toInt() - 5, 350), isNot(background));
  });

  test('경계 벽의 길이가 칸 하나와 같다', () async {
    const side = 620.0;
    const cell = 100.0;
    const margin = cell * Spacing.wallWidthRatio;
    // (2,2) 와 (2,3) 사이의 세로 벽. y 로 [margin+200, margin+300] 을 덮어야 한다.
    final board = boardWith(
      const [Position(0, 0)],
      walls: {WallEdge.between(const Position(2, 2), Direction.right)},
    );

    final image = await _paint(board, side, cell, const Offset(margin, margin));
    final data = await image.toByteData();
    int px(int x, int y) => data!.getUint32((y * image.width + x) * 4);

    const wallX = margin + 3 * cell; // 벽의 중심 x
    // 같은 x 에 격자선도 세로로 그어져 있으므로 "배경이 아님" 으로는 못 가린다.
    // 벽 한가운데 색을 기준으로 벽 픽셀만 센다.
    final wallColor = px(wallX.toInt(), (margin + 2.5 * cell).toInt());

    // 같은 열의 외곽 프레임(위·아래 끝)도 벽 색이므로, 벽 한가운데에서
    // 위아래로 이어지는 구간만 센다.
    const seed = (margin + 2.5 * cell) ~/ 1;
    var top = seed;
    while (top > 0 && px(wallX.toInt(), top - 1) == wallColor) {
      top--;
    }
    var bottom = seed;
    while (bottom < image.height - 1 &&
        px(wallX.toInt(), bottom + 1) == wallColor) {
      bottom++;
    }

    expect(
      (bottom - top + 1).toDouble(),
      closeTo(cell, 2),
      reason: '벽 길이가 칸 하나(=$cell)와 달라 삐져나온다',
    );
    expect(top.toDouble(), closeTo(margin + 2 * cell, 2));
  });
}

Future<ui.Image> _paint(
  BoardState board,
  double side,
  double cell,
  Offset origin,
) async {
  final recorder = ui.PictureRecorder();
  BoardPainter(
    board: board,
    colors: BoardColors.light,
    cell: cell,
    origin: origin,
  ).paint(Canvas(recorder), Size(side, side));

  return recorder.endRecording().toImage(side.toInt(), side.toInt());
}
