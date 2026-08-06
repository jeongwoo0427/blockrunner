import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:flutter/material.dart';

/// **움직이지 않는 것만** 그린다 — 배경 · 목표 · 격자선 · 벽.
///
/// 블랙홀은 계속 회전하므로 [BlackHolePainter] 가 따로 그린다. 한 페인터에
/// 두면 회전 한 프레임마다 격자와 벽까지 전부 다시 그려진다.
///
/// 움직이는 블록은 이 위에 위젯으로 얹는다. 그래야 `06-animation` 에서
/// 슬라이드와 낙하 연출을 위젯 애니메이션으로 처리할 수 있다.
///
/// **좌표를 스스로 계산하지 않는다.** [cell] 과 [origin] 을 `BoardView` 에서
/// 받아 쓴다 — 페인터와 블록 위젯이 각자 계산하면 언젠가 어긋난다.
class BoardPainter extends CustomPainter {
  const BoardPainter({
    required this.board,
    required this.colors,
    required this.cell,
    required this.origin,
  });

  final BoardState board;

  /// 색은 전부 여기서 꺼낸다. 페인터 안에 `Color(0xFF...)` 를 박지 않는다.
  final BoardColors colors;

  /// 칸 한 변의 길이.
  final double cell;

  /// 격자의 좌상단. 외곽 프레임이 들어갈 여백만큼 안쪽이다.
  final Offset origin;

  double get _wallWidth => cell * Spacing.wallWidthRatio;

  Rect get _gridRect => Rect.fromLTWH(
    origin.dx,
    origin.dy,
    cell * board.colCount,
    cell * board.rowCount,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // 바탕은 **격자에만** 깐다. 여백까지 칠하면 프레임이 보드 안쪽에 그려진
    // 띠처럼 보여서 판이 실제보다 좁아 보인다.
    canvas.drawRect(_gridRect, Paint()..color = colors.background);

    _paintFloors(canvas);
    _paintGridLines(canvas);
    _paintCellWalls(canvas);
    _paintEdgeWalls(canvas);
    _paintOuterFrame(canvas);
  }

  void _paintFloors(Canvas canvas) {
    final goalPaint = Paint()..color = colors.goal;

    for (var row = 0; row < board.rowCount; row++) {
      for (var col = 0; col < board.colCount; col++) {
        if (board.floors[row][col] != FloorType.goal) continue;

        // 목표는 통과 가능한 바닥이므로 칸을 꽉 채우지 않고 테두리 링으로 둔다.
        // **플레이어와 같은 색이라 링이어야 한다**(12-ui-polish §4) — 채운
        // 도형이면 플레이어가 그 위에 선 순간 목표가 사라져 보인다.
        final rect = _cellRect(row, col);
        canvas.drawRect(rect, goalPaint..style = PaintingStyle.fill);
        canvas.drawRect(
          rect.deflate(cell * 0.12),
          Paint()
            ..color = colors.background
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  void _paintGridLines(Canvas canvas) {
    final paint = Paint()
      ..color = colors.gridLine
      ..strokeWidth = Spacing.gridLineWidth;
    final grid = _gridRect;

    for (var col = 1; col < board.colCount; col++) {
      final x = grid.left + col * cell;
      canvas.drawLine(Offset(x, grid.top), Offset(x, grid.bottom), paint);
    }
    for (var row = 1; row < board.rowCount; row++) {
      final y = grid.top + row * cell;
      canvas.drawLine(Offset(grid.left, y), Offset(grid.right, y), paint);
    }
  }

  /// 칸 벽 — 칸을 통째로 채운다. 여기엔 아무것도 설 수 없다.
  void _paintCellWalls(Canvas canvas) {
    final paint = Paint()..color = colors.wall;

    for (var row = 0; row < board.rowCount; row++) {
      for (var col = 0; col < board.colCount; col++) {
        if (board.floors[row][col] != FloorType.wall) continue;
        canvas.drawRect(_cellRect(row, col), paint);
      }
    }
  }

  /// 경계 벽 — 칸 사이에 굵은 선. 양쪽 칸은 살아 있다.
  void _paintEdgeWalls(Canvas canvas) {
    final paint = _wallStroke();

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

  /// 맵 경계도 벽이다(기획서 §2.2). 경계 벽과 같은 두께·색으로 그려야
  /// "판이 벽으로 둘러싸여 있다"가 화면에서도 읽힌다.
  ///
  /// **격자 바깥 여백에 그린다.** 칸 안쪽으로 파고들면 가장자리 칸만 여백이
  /// 비대칭이 되어 블록이 중앙에서 밀려 보인다.
  void _paintOuterFrame(Canvas canvas) {
    canvas.drawRect(
      _gridRect.inflate(_wallWidth / 2),
      _wallStroke()..style = PaintingStyle.stroke,
    );
  }

  Paint _wallStroke() => Paint()
    ..color = colors.wall
    ..strokeWidth = _wallWidth
    // square/round 캡은 선 양끝을 두께의 절반씩 늘려 칸 하나보다 길어진다.
    ..strokeCap = StrokeCap.butt;

  Rect _cellRect(int row, int col) => Rect.fromLTWH(
    origin.dx + col * cell,
    origin.dy + row * cell,
    cell,
    cell,
  );

  @override
  bool shouldRepaint(BoardPainter oldDelegate) =>
      oldDelegate.board != board ||
      oldDelegate.colors != colors ||
      oldDelegate.cell != cell ||
      oldDelegate.origin != origin;
}
