import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/game_map.dart';
import 'package:blockrunner/feature/level/domain/entity/level.dart';
import 'package:flutter/foundation.dart';

@immutable
class GamePlayScreenState {
  const GamePlayScreenState({
    this.level,
    this.map,
    this.board,
    this.moveCount = 0,
    this.isAnimating = false,
    this.isCleared = false,
    this.isPlayerLost = false,
    this.hasNextLevel = false,
    this.showsTutorial = false,
    this.failure,
  });

  /// 레벨 메타데이터 — 이름과 최소 이동 횟수 표시용.
  final Level? level;

  /// 이 레벨의 맵. 다시하기가 되돌아갈 초기 배치를 갖고 있다.
  final GameMap? map;

  /// 현재 판. 로드에 실패하면 null 이다.
  final BoardState? board;

  final int moveCount;

  /// 슬라이드 연출 재생 중. `06-animation` 이 세운다.
  final bool isAnimating;

  final bool isCleared;

  /// 플레이어가 구멍에 빠져 되돌리기 유도 중 (기획서 §3.5).
  final bool isPlayerLost;

  final bool hasNextLevel;

  /// 튜토리얼 오버레이를 띄우고 있는가 (기획서 §6.1).
  ///
  /// 파생값이 아니다 — "이미 봤는지" 는 저장소가 알고, 닫는 것은 사용자다.
  final bool showsTutorial;

  final Failure? failure;

  /// 방향 입력을 받아도 되는 상태인가.
  ///
  /// 연출 중 입력은 큐잉하지 않고 무시하며(기획서 §6), 클리어·소실 상태에서는
  /// 판이 이미 끝났으므로 받지 않는다.
  /// 튜토리얼이 떠 있는 동안에는 입력을 받지 않는다. 오버레이 뒤로 판이
  /// 움직이면 안내를 읽는 동안 판이 바뀐다.
  bool get canMove =>
      board != null &&
      !isAnimating &&
      !isCleared &&
      !isPlayerLost &&
      !showsTutorial;

  GamePlayScreenState copyWith({
    Level? Function()? level,
    GameMap? Function()? map,
    BoardState? Function()? board,
    int? moveCount,
    bool? isAnimating,
    bool? isCleared,
    bool? isPlayerLost,
    bool? hasNextLevel,
    bool? showsTutorial,
    Failure? Function()? failure,
  }) {
    return GamePlayScreenState(
      level: level != null ? level() : this.level,
      map: map != null ? map() : this.map,
      board: board != null ? board() : this.board,
      moveCount: moveCount ?? this.moveCount,
      isAnimating: isAnimating ?? this.isAnimating,
      isCleared: isCleared ?? this.isCleared,
      isPlayerLost: isPlayerLost ?? this.isPlayerLost,
      hasNextLevel: hasNextLevel ?? this.hasNextLevel,
      showsTutorial: showsTutorial ?? this.showsTutorial,
      failure: failure != null ? failure() : this.failure,
    );
  }
}
