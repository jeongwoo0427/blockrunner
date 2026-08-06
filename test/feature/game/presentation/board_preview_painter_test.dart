import 'dart:ui' as ui;

import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:blockrunner/core/theme/data/light_theme.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/domain/entity/wall_edge.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_preview_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 작은 판(레벨 카드 미리보기 · 튜토리얼 데모)이 **경계 벽을 그리는가**.
///
/// **빠져도 조용하다는 것이 이 테스트가 있는 이유다.** 칸 벽과 달리 경계 벽은
/// 칸을 차지하지 않으므로, 안 그리면 판이 깨져 보이는 게 아니라 그냥 벽이
/// 없는 판으로 보인다. 실제로 경계 벽을 가르치는 튜토리얼 데모에서 정작 벽이
/// 안 보이는 상태로 나갔다.
void main() {
  final colors = lightTheme.extension<BoardColors>()!;

  /// 1행 4열 판. [walls] 만 다르게 준다.
  BoardState strip({Set<WallEdge> walls = const {}}) => BoardState(
    rowCount: 1,
    colCount: 4,
    floors: const [
      [FloorType.empty, FloorType.empty, FloorType.goal, FloorType.empty],
    ],
    blocks: const [],
    walls: walls,
  );

  /// 판을 그리는 동안 나간 `drawLine` 들.
  List<(Offset, Offset)> linesOf(BoardState board) {
    final canvas = _RecordingCanvas();

    BoardPreviewPainter(
      board: board,
      colors: colors,
      cell: 20,
      origin: Offset.zero,
    ).paint(canvas, const Size(80, 20));

    return canvas.lines;
  }

  test('경계 벽이 없으면 선도 없다', () {
    // 대조군이 없으면 "무엇이든 그려졌다" 로 통과해 버린다.
    expect(linesOf(strip()), isEmpty);
  });

  test('세로 경계 벽이 두 칸 사이에 그려진다', () {
    final lines = linesOf(
      strip(walls: {WallEdge.between(const Position(0, 1), Direction.right)}),
    );

    expect(lines, hasLength(1));

    final (from, to) = lines.single;
    // (0,1) 의 오른쪽 = x 40. 칸 하나 높이만큼 세로로 긋는다.
    expect(from, const Offset(40, 0));
    expect(to, const Offset(40, 20));
  });

  test('가로 경계 벽은 아래쪽에 가로로 그려진다', () {
    final lines = linesOf(
      strip(walls: {WallEdge.between(const Position(0, 2), Direction.down)}),
    );

    final (from, to) = lines.single;
    expect(from, const Offset(40, 20));
    expect(to, const Offset(60, 20));
  });

  test('벽이 여럿이면 그만큼 그린다', () {
    expect(
      linesOf(
        strip(
          walls: {
            WallEdge.between(const Position(0, 0), Direction.right),
            WallEdge.between(const Position(0, 2), Direction.right),
          },
        ),
      ),
      hasLength(2),
    );
  });
}

/// `drawLine` 만 받아 적는 캔버스.
///
/// 그려진 그림을 픽셀로 비교하는 대신 명령을 본다 — 실패했을 때 "어디에 무엇을
/// 그렸는가" 가 그대로 나와서 고칠 곳을 바로 알 수 있다.
class _RecordingCanvas implements Canvas {
  final List<(Offset, Offset)> lines = [];

  @override
  void drawLine(Offset p1, Offset p2, ui.Paint paint) => lines.add((p1, p2));

  @override
  void noSuchMethod(Invocation invocation) {}
}
