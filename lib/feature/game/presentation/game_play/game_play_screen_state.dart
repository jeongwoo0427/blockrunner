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

  final Failure? failure;

  /// 방향 입력을 받아도 되는 상태인가.
  ///
  /// 연출 중 입력은 큐잉하지 않고 무시하며(기획서 §6), 클리어·소실 상태에서는
  /// 판이 이미 끝났으므로 받지 않는다.
  bool get canMove =>
      board != null && !isAnimating && !isCleared && !isPlayerLost;

  /// 조작 안내를 띄울 때인가 (기획서 §6.1).
  ///
  /// 저장하지 않는다 — `첫 레벨 && 아직 한 수도 두지 않음` 에서 그때그때
  /// 파생될 뿐이라 별도 상태도 저장소도 필요 없고, 첫 이동에 저절로 사라진다.
  bool get showsControlHint => level?.number == 1 && moveCount == 0;

  GamePlayScreenState copyWith({
    Level? Function()? level,
    GameMap? Function()? map,
    BoardState? Function()? board,
    int? moveCount,
    bool? isAnimating,
    bool? isCleared,
    bool? isPlayerLost,
    bool? hasNextLevel,
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
      failure: failure != null ? failure() : this.failure,
    );
  }
}
