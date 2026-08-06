import 'dart:math';
import 'dart:ui';

import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:flutter/foundation.dart';

/// 보드의 화면 기하. **셀 크기를 계산하는 유일한 곳이다.**
///
/// 페인터 · 블록 위젯 · HUD 가 모두 같은 좌표계를 써야 하므로 각자 계산하게
/// 두면 언젠가 어긋난다. 계산은 [BoardMetrics.fit] 하나로 모으고 결과를 넘긴다.
@immutable
class BoardMetrics {
  const BoardMetrics._({
    required this.cell,
    required this.rowCount,
    required this.colCount,
  });

  /// [available] 안에 [board] 를 최대 크기로, 셀은 정사각으로 채워 넣는다.
  factory BoardMetrics.fit({
    required BoardState board,
    required Size available,
  }) {
    final extent = min(
      min(available.width, available.height),
      AppConstants.maxBoardExtent,
    );

    // 격자 바깥에 외곽 프레임이 들어갈 여백을 양쪽으로 한 겹씩 남긴다.
    // 프레임이 칸 안쪽을 파고들면 가장자리 칸만 여백이 비대칭이 되어
    // 블록이 중앙에서 밀려 보인다.
    final longSide = max(board.rowCount, board.colCount);

    return BoardMetrics._(
      cell: extent / (longSide + 2 * Spacing.wallWidthRatio),
      rowCount: board.rowCount,
      colCount: board.colCount,
    );
  }

  /// **가로 폭을 꽉 채운다.** 높이는 판 비율대로 따라온다.
  ///
  /// [BoardMetrics.fit] 은 짧은 변에 맞추므로 1행짜리 가로로 긴 판을 주면
  /// 높이에 눌려 아주 작아진다 — 6×6 과 8×8 의 외곽을 같게 하려고 그렇게
  /// 만든 것이라 판을 그리는 데는 맞지만, **한 줄짜리 튜토리얼 데모에는
  /// 맞지 않는다**(실제로 작고 왼쪽에 붙어 나왔다).
  factory BoardMetrics.fitWidth({
    required BoardState board,
    required double width,
  }) => BoardMetrics._(
    cell: width / (board.colCount + 2 * Spacing.wallWidthRatio),
    rowCount: board.rowCount,
    colCount: board.colCount,
  );

  /// 칸 하나의 한 변.
  final double cell;

  final int rowCount;
  final int colCount;

  /// 격자와 그림 영역 가장자리 사이의 여백. 외곽 프레임이 여기 그려진다.
  double get margin => cell * Spacing.wallWidthRatio;

  /// 격자 원점 — 외곽 프레임 여백만큼 안쪽이다.
  Offset get origin => Offset(margin, margin);

  double get width => cell * colCount + 2 * margin;

  double get height => cell * rowCount + 2 * margin;

  Size get size => Size(width, height);
}
