import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:flutter/material.dart';

/// 고정된 것만 그린다 — 배경 · 바닥(목표 · 구멍) · 격자선 · 벽.
///
/// 움직이는 블록은 이 위에 위젯으로 얹는다. 그래야 `06-animation` 에서
/// 슬라이드와 낙하 연출을 위젯 애니메이션으로 처리할 수 있다.
class BoardPainter extends CustomPainter {
  const BoardPainter({required this.board, required this.colors});

  final BoardState board;

  /// 색은 전부 여기서 꺼낸다. 페인터 안에 `Color(0xFF...)` 를 박지 않는다.
  final BoardColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / board.colCount;

    canvas.drawRect(Offset.zero & size, Paint()..color = colors.background);

    _paintFloors(canvas, cell);
    _paintGridLines(canvas, size, cell);
    _paintCellWalls(canvas, cell);
    _paintEdgeWalls(canvas, cell);
    _paintOuterFrame(canvas, size, cell);
  }

  void _paintFloors(Canvas canvas, double cell) {
    final goalPaint = Paint()..color = colors.goal;
    final holePaint = Paint()..color = colors.hole;

    for (var row = 0; row < board.rowCount; row++) {
      for (var col = 0; col < board.colCount; col++) {
        final floor = board.floors[row][col];
        if (floor != FloorType.goal && floor != FloorType.hole) continue;

        final rect = _cellRect(row, col, cell);
        if (floor == FloorType.goal) {
          // 목표는 통과 가능한 바닥이므로 칸을 꽉 채우지 않고 테두리 링으로 둔다.
          // 블록이 그 위에 서도 목표였다는 사실이 보여야 한다.
          canvas.drawRect(rect, goalPaint..style = PaintingStyle.fill);
          canvas.drawRect(
            rect.deflate(cell * 0.12),
            Paint()
              ..color = colors.background
              ..style = PaintingStyle.fill,
          );
        } else {
          canvas.drawOval(rect.deflate(cell * 0.08), holePaint);
        }
      }
    }
  }

  void _paintGridLines(Canvas canvas, Size size, double cell) {
    final paint = Paint()
      ..color = colors.gridLine
      ..strokeWidth = Spacing.gridLineWidth;

    for (var col = 1; col < board.colCount; col++) {
      final x = col * cell;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var row = 1; row < board.rowCount; row++) {
      final y = row * cell;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  /// 칸 벽 — 칸을 통째로 채운다. 여기엔 아무것도 설 수 없다.
  void _paintCellWalls(Canvas canvas, double cell) {
    final paint = Paint()..color = colors.wall;

    for (var row = 0; row < board.rowCount; row++) {
      for (var col = 0; col < board.colCount; col++) {
        if (board.floors[row][col] != FloorType.wall) continue;
        canvas.drawRect(_cellRect(row, col, cell), paint);
      }
    }
  }

  /// 경계 벽 — 칸 사이에 굵은 선. 양쪽 칸은 살아 있다.
  void _paintEdgeWalls(Canvas canvas, double cell) {
    final paint = _wallStroke(cell);

    for (final wall in board.walls) {
      final rect = _cellRect(wall.position.row, wall.position.col, cell);
      final (from, to) = switch (wall.direction) {
        Direction.right => (rect.topRight, rect.bottomRight),
        Direction.down => (rect.bottomLeft, rect.bottomRight),
        // WallEdge 는 right/down 으로 정규화된다.
        Direction.left || Direction.up => (rect.topLeft, rect.topLeft),
      };
      canvas.drawLine(from, to, paint);
    }
  }

  /// 맵 경계도 벽이다(기획서 §2.2). 경계 벽과 같은 두께·색으로 그려야
  /// "판이 벽으로 둘러싸여 있다"가 화면에서도 읽힌다.
  void _paintOuterFrame(Canvas canvas, Size size, double cell) {
    final stroke = _wallStroke(cell);
    final inset = stroke.strokeWidth / 2;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height).deflate(inset),
      stroke..style = PaintingStyle.stroke,
    );
  }

  Paint _wallStroke(double cell) => Paint()
    ..color = colors.wall
    ..strokeWidth = cell * Spacing.wallWidthRatio
    ..strokeCap = StrokeCap.square;

  Rect _cellRect(int row, int col, double cell) =>
      Rect.fromLTWH(col * cell, row * cell, cell, cell);

  @override
  bool shouldRepaint(BoardPainter oldDelegate) =>
      oldDelegate.board != board || oldDelegate.colors != colors;
}
