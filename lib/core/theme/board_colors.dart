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

  /// 동료 블록 (플레이어와 함께 이동)
  final Color normalBlock;

  /// 플레이어 블록
  ///
  /// **[goal] 과 같은 색 계열이다** (12-ui-polish §4). "내가 어디로 가야 하는가"
  /// 가 색 하나로 읽혀야 한다.
  final Color playerBlock;

  /// 목표 지점 (바닥 표시)
  ///
  /// [playerBlock] 과 같은 색상이되 **더 밝다.** 플레이어가 목표 칸 위에 서는
  /// 것이 클리어 조건이라 둘은 반드시 겹치는데, 명도까지 같으면 그 순간 목표가
  /// 사라진 것처럼 보인다. 링으로 그리는 것과 함께 이 차이가 둘을 갈라 놓는다.
  final Color goal;

  /// 블랙홀 (바닥 표시)
  final Color blackHole;

  /// 판 아래에 깔리는 그림자. **판이 화면 위에 떠 있어 보이게 한다.**
  ///
  /// 반투명이라 화면 바탕 위에 얹힌다. 라이트와 다크가 같은 값일 수 없다 —
  /// 어두운 바탕에서는 검은 그림자가 보이지 않아 더 짙게 깔아야 한다.
  final Color shadow;

  const BoardColors({
    required this.background,
    required this.gridLine,
    required this.wall,
    required this.normalBlock,
    required this.playerBlock,
    required this.goal,
    required this.blackHole,
    required this.shadow,
  });

  static const light = BoardColors(
    // **판은 하얗다.** 화면 바탕이 옅게 색을 띠므로, 판까지 색이 있으면
    // 배경의 일부처럼 읽힌다. 흰 판이어야 그 위가 퍼즐이라는 것이 갈린다.
    background: Color(0xFFFFFFFF),
    gridLine: Color(0xFFDDE3EC),
    wall: Color(0xFF4A5568),
    normalBlock: Color(0xFF8598B8),
    playerBlock: Color(0xFF2E63E8),
    goal: Color(0xFF7BA5F5),
    blackHole: Color(0xFF1E2430),
    // 순수 검정이 아니라 판·벽과 같은 남색 계열이다. 회색 그림자는 화면에서
    // 때가 탄 것처럼 보인다.
    shadow: Color(0x331E2430),
  );

  static const dark = BoardColors(
    background: Color(0xFF1B1F27),
    gridLine: Color(0xFF2A303C),
    wall: Color(0xFF7C8899),
    normalBlock: Color(0xFF4E5D78),
    playerBlock: Color(0xFF74A2FF),
    goal: Color(0xFF35538F),
    blackHole: Color(0xFF0B0E14),
    // 다크에서는 더 짙다. 옅게 두면 어두운 바탕에 묻혀 그림자가 없는 것과 같다.
    shadow: Color(0x73000000),
  );

  @override
  BoardColors copyWith({
    Color? background,
    Color? gridLine,
    Color? wall,
    Color? normalBlock,
    Color? playerBlock,
    Color? goal,
    Color? blackHole,
    Color? shadow,
  }) {
    return BoardColors(
      background: background ?? this.background,
      gridLine: gridLine ?? this.gridLine,
      wall: wall ?? this.wall,
      normalBlock: normalBlock ?? this.normalBlock,
      playerBlock: playerBlock ?? this.playerBlock,
      goal: goal ?? this.goal,
      blackHole: blackHole ?? this.blackHole,
      shadow: shadow ?? this.shadow,
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
      blackHole: Color.lerp(blackHole, other.blackHole, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension BoardColorsX on BuildContext {
  /// 보드 색상 꺼내기. 등록되지 않았다면 라이트 팔레트로 폴백한다.
  BoardColors get boardColors =>
      Theme.of(this).extension<BoardColors>() ?? BoardColors.light;
}
