import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:flutter/material.dart';

/// 카드 안에 들어갈 **작고 움직이지 않는** 판 (12-ui-polish §2).
///
/// `BoardPainter` 를 재사용하지 않는다. 저쪽은 블록을 그리지 않고(위젯이 얹힌다)
/// 블랙홀도 회전 레이어에 맡기는데, 미리보기는 그 둘이 다 필요하면서 아무것도
/// 움직이지 않는다. 조건을 붙여 한 페인터로 합치면 양쪽 다 읽기 어려워진다.
class BoardPreviewPainter extends CustomPainter {
  const BoardPreviewPainter({
    required this.board,
    required this.colors,
    required this.cell,
    required this.origin,
  });

  final BoardState board;
  final BoardColors colors;
  final double cell;
  final Offset origin;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Rect.fromLTWH(
      origin.dx,
      origin.dy,
      cell * board.colCount,
      cell * board.rowCount,
    );
    canvas.drawRect(grid, Paint()..color = colors.background);

    for (var row = 0; row < board.rowCount; row++) {
      for (var col = 0; col < board.colCount; col++) {
        _paintFloor(canvas, board.floors[row][col], _cellRect(row, col));
      }
    }

    for (final block in board.blocks) {
      _paintBlock(canvas, block);
    }


    _paintEdgeWalls(canvas);

    canvas.drawRect(
      grid,
      Paint()
        ..color = colors.wall
        ..strokeWidth = cell * Spacing.wallWidthRatio
        ..style = PaintingStyle.stroke,
    );
  }

  /// 경계 벽 — 칸 사이의 굵은 선.
  ///
  /// **빼먹으면 조용히 틀린다.** 칸 벽과 달리 칸을 차지하지 않으므로, 안 그려도
  /// 판은 멀쩡해 보이고 그저 규칙이 없는 것처럼 보인다. 경계 벽을 가르치는
  /// 튜토리얼 데모에서 정작 벽이 안 보이는 상태가 실제로 그렇게 나왔다.
  void _paintEdgeWalls(Canvas canvas) {
    final paint = Paint()
      ..color = colors.wall
      ..strokeWidth = cell * Spacing.wallWidthRatio
      // 캡이 있으면 선이 칸 하나보다 길어진다 — `BoardPainter` 와 같은 이유.
      ..strokeCap = StrokeCap.butt;

    for (final wall in board.walls) {
      final rect = _cellRect(wall.position.row, wall.position.col);
      final (from, to) = switch (wall.direction) {
        Direction.right => (rect.topRight, rect.bottomRight),
        Direction.down => (rect.bottomLeft, rect.bottomRight),
        // WallEdge 는 right/down 으로 정규화된다.
        Direction.left || Direction.up => (rect.topLeft, rect.topLeft),
      };
      canvas.drawLine(from, to, paint);
    }
  }

  void _paintFloor(Canvas canvas, FloorType floor, Rect rect) {
    switch (floor) {
      case FloorType.empty:
        return;
      case FloorType.wall:
        canvas.drawRect(rect, Paint()..color = colors.wall);
      case FloorType.goal:
        canvas.drawRect(
          rect.deflate(cell * 0.16),
          Paint()
            ..color = colors.goal
            ..strokeWidth = cell * 0.16
            ..style = PaintingStyle.stroke,
        );
      case FloorType.blackHole:
        canvas.drawOval(
          rect.deflate(cell * 0.12),
          Paint()..color = colors.blackHole,
        );
    }
  }

  void _paintBlock(Canvas canvas, Block block) {
    final rect = _cellRect(block.position.row, block.position.col)
        .deflate(cell * Spacing.blockInsetRatio);
    final color = block.type == BlockType.player
        ? colors.playerBlock
        : colors.normalBlock;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        Radius.circular(cell * Spacing.blockRadiusRatio),
      ),
      Paint()..color = color,
    );
  }

  Rect _cellRect(int row, int col) => Rect.fromLTWH(
    origin.dx + col * cell,
    origin.dy + row * cell,
    cell,
    cell,
  );

  @override
  bool shouldRepaint(BoardPreviewPainter oldDelegate) =>
      oldDelegate.board != board ||
      oldDelegate.colors != colors ||
      oldDelegate.cell != cell ||
      oldDelegate.origin != origin;
}
