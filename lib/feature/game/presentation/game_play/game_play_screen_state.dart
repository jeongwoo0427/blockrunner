import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
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
    this.history = const [],
    this.undosLeft = AppConstants.undoLimit,
    this.isAnimating = false,
    this.fallingBlocks = const [],
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

  /// 되돌리기 스택 — **이동 직전의 판들**. 마지막 원소가 한 수 전이다.
  ///
  /// [BoardState] 가 불변이라 그냥 쌓아두면 된다. 갈아끼울 때는 **새 리스트를
  /// 만든다** — 기존 리스트를 변형하면 불변 규약이 깨져 되돌리기가 조용히 망가진다.
  ///
  /// **되돌리기는 화면에 붙어 있지 않다** (기획서 §5.1). 구현과 테스트는 그대로
  /// 살아 있고 진입점만 없다 — 쓰이지 않는다고 지우지 말 것. 되살리려면
  /// `GameHud` 에 버튼을, `_onKeyEvent` 에 `Z` 를 다시 이으면 된다.
  final List<BoardState> history;

  /// 남은 되돌리기 횟수 (기획서 §5.1). 다시하기가 이 값을 되살린다.
  final int undosLeft;

  /// 되돌릴 수 있는가 — 되돌릴 판이 있고, 횟수가 남았고, 연출 중이 아니어야 한다.
  bool get canUndo => history.isNotEmpty && undosLeft > 0 && !isAnimating;

  /// 슬라이드 연출 재생 중. 이동을 적용할 때 세우고, 화면이 연출을 다 재생한 뒤
  /// [AnimationCompleted] 를 올려보내면 내린다.
  final bool isAnimating;

  /// 이번 이동에서 블랙홀에 빠진 블록들. 위치는 **빠진 블랙홀 칸**이다.
  ///
  /// [board] 에는 이미 없다. 그래도 들고 있는 이유는 낙하 연출 때문이다 —
  /// 판에서 지워버리면 미끄러지다 말고 순간 소멸한다. 연출이 끝나면 비운다.
  final List<Block> fallingBlocks;

  final bool isCleared;

  /// 플레이어가 블랙홀에 빠져 되돌리기 유도 중 (기획서 §3.5).
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
    List<BoardState>? history,
    int? undosLeft,
    bool? isAnimating,
    List<Block>? fallingBlocks,
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
      history: history ?? this.history,
      undosLeft: undosLeft ?? this.undosLeft,
      isAnimating: isAnimating ?? this.isAnimating,
      fallingBlocks: fallingBlocks ?? this.fallingBlocks,
      isCleared: isCleared ?? this.isCleared,
      isPlayerLost: isPlayerLost ?? this.isPlayerLost,
      hasNextLevel: hasNextLevel ?? this.hasNextLevel,
      showsTutorial: showsTutorial ?? this.showsTutorial,
      failure: failure != null ? failure() : this.failure,
    );
  }
}
