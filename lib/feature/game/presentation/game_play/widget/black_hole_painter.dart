import 'dart:math';

import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:flutter/material.dart';

/// 블랙홀만 그린다 (12-ui-polish §5.2).
///
/// **`BoardPainter` 에서 떼어낸 이유는 회전 때문이다.** 블랙홀은 끝나지 않고
/// 계속 도는데, 한 페인터에 두면 바닥 · 격자 · 벽까지 매 프레임 다시 그려진다.
/// 나눠 두면 다시 그려지는 것은 블랙홀뿐이다.
class BlackHolePainter extends CustomPainter {
  const BlackHolePainter({
    required this.board,
    required this.colors,
    required this.cell,
    required this.origin,
    required this.turns,
  });

  final BoardState board;
  final BoardColors colors;
  final double cell;
  final Offset origin;

  /// 회전량. 0 → 1 이 한 바퀴다.
  final double turns;

  /// 소용돌이 팔 개수. 둘이면 대칭이라 회전이 눈에 잘 들어온다.
  static const int _armCount = 2;

  /// 팔 하나가 중심까지 감기며 도는 바퀴 수.
  static const double _armTurns = 0.75;

  static const int _armSegments = 36;

  @override
  void paint(Canvas canvas, Size size) {
    for (var row = 0; row < board.rowCount; row++) {
      for (var col = 0; col < board.colCount; col++) {
        if (board.floors[row][col] != FloorType.blackHole) continue;
        _paintOne(canvas, _cellRect(row, col));
      }
    }
  }

  void _paintOne(Canvas canvas, Rect cellRect) {
    final center = cellRect.center;
    final radius = cellRect.width / 2 * 0.92;

    // 가장자리는 연하고 중심으로 갈수록 어두워진다. 마지막 정거장을 완전한
    // 검정으로 두어 "빛도 못 빠져나오는" 중심이 생긴다.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF000000),
            const Color(0xFF000000),
            colors.blackHole,
            colors.blackHole.withValues(alpha: 0.55),
            colors.blackHole.withValues(alpha: 0),
          ],
          stops: const [0, 0.22, 0.55, 0.82, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    _paintArms(canvas, center, radius);
  }

  /// 중심으로 감겨 들어가는 나선 팔.
  ///
  /// 바깥일수록 옅게 그린다 — 안쪽은 이미 검정이라 팔이 보이지 않고, 보이는
  /// 것은 사건의 지평선 바깥에서 끌려 들어가는 물질뿐이다.
  void _paintArms(Canvas canvas, Offset center, double radius) {
    final base = turns * 2 * pi;

    for (var arm = 0; arm < _armCount; arm++) {
      final offset = base + arm * 2 * pi / _armCount;

      for (var i = 0; i < _armSegments; i++) {
        final from = i / _armSegments;
        final to = (i + 1) / _armSegments;

        // 바깥(t=1)에서 안쪽(t=0)으로 감긴다.
        final path = Path()
          ..moveTo(
            center.dx + _spiralX(from, offset) * radius,
            center.dy + _spiralY(from, offset) * radius,
          )
          ..lineTo(
            center.dx + _spiralX(to, offset) * radius,
            center.dy + _spiralY(to, offset) * radius,
          );

        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.16 * from)
            ..strokeWidth = radius * 0.10 * from
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        );
      }
    }
  }

  double _angleAt(double t, double offset) => offset + t * _armTurns * 2 * pi;

  double _spiralX(double t, double offset) => cos(_angleAt(t, offset)) * t;

  double _spiralY(double t, double offset) => sin(_angleAt(t, offset)) * t;

  Rect _cellRect(int row, int col) => Rect.fromLTWH(
    origin.dx + col * cell,
    origin.dy + row * cell,
    cell,
    cell,
  );

  @override
  bool shouldRepaint(BlackHolePainter oldDelegate) =>
      oldDelegate.turns != turns ||
      oldDelegate.board != board ||
      oldDelegate.colors != colors ||
      oldDelegate.cell != cell ||
      oldDelegate.origin != origin;
}
