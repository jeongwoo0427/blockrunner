import 'package:flutter/material.dart';

/// 게임 보드 전용 색상.
///
/// CustomPainter 는 BuildContext 없이 그리므로, 색을 페인터 안에
/// Color(0xFF...) 로 박아버리기 쉽다. 그러면 다크모드에서 손댈 수 없게 된다.
/// 처음부터 ThemeExtension 으로 빼서 Theme.of(context) 를 통해 넘긴다.
@immutable
class BoardColors extends ThemeExtension<BoardColors> {
  /// 보드 바탕
  final Color background;

  /// 격자선
  final Color gridLine;

  /// 벽 (고정, 통과 불가)
  final Color wall;

  /// 일반 블록 (플레이어와 함께 이동)
  final Color normalBlock;

  /// 플레이어 블록
  final Color playerBlock;

  /// 목표 지점 (바닥 표시)
  final Color goal;

  /// 구멍 (바닥 표시)
  final Color hole;

  const BoardColors({
    required this.background,
    required this.gridLine,
    required this.wall,
    required this.normalBlock,
    required this.playerBlock,
    required this.goal,
    required this.hole,
  });

  static const light = BoardColors(
    background: Color(0xFFECEFF4),
    gridLine: Color(0xFFD3DAE3),
    wall: Color(0xFF4A5568),
    normalBlock: Color(0xFF8598B8),
    playerBlock: Color(0xFFE8703A),
    goal: Color(0xFF3FA796),
    hole: Color(0xFF1E2430),
  );

  static const dark = BoardColors(
    background: Color(0xFF1B1F27),
    gridLine: Color(0xFF2A303C),
    wall: Color(0xFF7C8899),
    normalBlock: Color(0xFF4E5D78),
    playerBlock: Color(0xFFFF8A50),
    goal: Color(0xFF4FC3AC),
    hole: Color(0xFF0B0E14),
  );

  @override
  BoardColors copyWith({
    Color? background,
    Color? gridLine,
    Color? wall,
    Color? normalBlock,
    Color? playerBlock,
    Color? goal,
    Color? hole,
  }) {
    return BoardColors(
      background: background ?? this.background,
      gridLine: gridLine ?? this.gridLine,
      wall: wall ?? this.wall,
      normalBlock: normalBlock ?? this.normalBlock,
      playerBlock: playerBlock ?? this.playerBlock,
      goal: goal ?? this.goal,
      hole: hole ?? this.hole,
    );
  }

  @override
  BoardColors lerp(covariant BoardColors? other, double t) {
    if (other == null) return this;
    return BoardColors(
      background: Color.lerp(background, other.background, t)!,
      gridLine: Color.lerp(gridLine, other.gridLine, t)!,
      wall: Color.lerp(wall, other.wall, t)!,
      normalBlock: Color.lerp(normalBlock, other.normalBlock, t)!,
      playerBlock: Color.lerp(playerBlock, other.playerBlock, t)!,
      goal: Color.lerp(goal, other.goal, t)!,
      hole: Color.lerp(hole, other.hole, t)!,
    );
  }
}

extension BoardColorsX on BuildContext {
  /// 보드 색상 꺼내기. 등록되지 않았다면 라이트 팔레트로 폴백한다.
  BoardColors get boardColors =>
      Theme.of(this).extension<BoardColors>() ?? BoardColors.light;
}
