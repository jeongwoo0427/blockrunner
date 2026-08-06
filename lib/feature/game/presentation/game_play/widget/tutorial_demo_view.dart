import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/domain/entity/wall_edge.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/black_hole_painter.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/block_tile.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_metrics.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_preview_painter.dart';
import 'package:blockrunner/feature/level/domain/entity/tutorial_demo.dart';
import 'package:flutter/material.dart';

/// 튜토리얼 문구 위에서 그 규칙을 **움직여 보여준다** (13-game-feel §6).
///
/// **이동 엔진을 태우지 않는다.** 정해진 장면이지 시뮬레이션이 아니다 — 엔진을
/// 부르면 데모가 규칙의 예시가 아니라 규칙의 두 번째 구현이 된다.
///
/// **자동으로 계속 반복한다.** 누를 것이 없고, 놓쳐도 다시 본다.
class TutorialDemoView extends StatefulWidget {
  const TutorialDemoView({super.key, required this.demo});

  final TutorialDemo demo;

  /// 한 바퀴 — 잠깐 멈춤 · 미끄러짐 · 결과를 보여주는 멈춤.
  static const Duration cycle = Duration(milliseconds: 2600);

  /// 미끄러짐이 시작·종료되는 지점(0~1).
  static const double _slideFrom = 0.18;
  static const double _slideTo = 0.58;

  @override
  State<TutorialDemoView> createState() => _TutorialDemoViewState();
}

class _TutorialDemoViewState extends State<TutorialDemoView>
    with SingleTickerProviderStateMixin {
  /// 이 프로젝트의 네 번째 `AnimationController`.
  ///
  /// **`pumpAndSettle` 이 끝나지 않는다** — 튜토리얼이 뜬 화면을 그 방식으로
  /// 검사하면 멈춘다. 블랙홀 회전과 같은 함정이고 `pump` 를 쓸 것.
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: TutorialDemoView.cycle,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // "동작 줄이기" 를 켠 사용자에게는 결과 장면에서 멈춘 그림을 보여준다.
    if (MediaQuery.disableAnimationsOf(context)) {
      _loop
        ..stop()
        ..value = 1;
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene = _sceneFor(widget.demo);
    final colors = context.boardColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        // **폭을 꽉 채운다.** `fit` 은 짧은 변에 맞추므로 한 줄짜리 판을 주면
        // 높이에 눌려 아주 작아지고 왼쪽에 붙는다.
        final metrics = BoardMetrics.fitWidth(
          board: scene.board,
          width: constraints.maxWidth,
        );

        return SizedBox(
          width: metrics.width,
          height: metrics.height,
          child: AnimatedBuilder(
            animation: _loop,
            builder: (context, _) {
              final t = _loop.value;
              final progress = _slideProgress(t);

              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: BoardPreviewPainter(
                        board: scene.board,
                        colors: colors,
                        cell: metrics.cell,
                        origin: metrics.origin,
                      ),
                    ),
                  ),
                  if (scene.hasBlackHole)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: BlackHolePainter(
                          board: scene.board,
                          colors: colors,
                          cell: metrics.cell,
                          origin: metrics.origin,
                          turns: t,
                        ),
                      ),
                    ),
                  for (final actor in scene.actors)
                    _actorTile(actor, progress, metrics),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// 전체 구간 중 미끄러지는 부분만 0~1 로 편다.
  double _slideProgress(double t) {
    const from = TutorialDemoView._slideFrom;
    const to = TutorialDemoView._slideTo;

    if (t <= from) return 0;
    if (t >= to) return 1;
    return Curves.easeOut.transform((t - from) / (to - from));
  }

  Widget _actorTile(_Actor actor, double progress, BoardMetrics metrics) {
    final col = actor.from.col + (actor.to.col - actor.from.col) * progress;
    final row = actor.from.row + (actor.to.row - actor.from.row) * progress;

    // 빨려 들어가는 블록은 도착과 함께 사라진다.
    final gone = actor.vanishes && progress > 0.92;

    return Positioned(
      left: metrics.margin + col * metrics.cell,
      top: metrics.margin + row * metrics.cell,
      width: metrics.cell,
      height: metrics.cell,
      child: AnimatedScale(
        scale: gone ? 0 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeIn,
        child: BlockTile(type: actor.type, size: metrics.cell),
      ),
    );
  }
}

/// 한 장면 — 판과 그 위에서 움직이는 블록들.
class _Scene {
  const _Scene({required this.board, required this.actors});

  final BoardState board;
  final List<_Actor> actors;

  bool get hasBlackHole =>
      board.floors.any((row) => row.contains(FloorType.blackHole));
}

class _Actor {
  const _Actor({
    required this.type,
    required this.from,
    required this.to,
    this.vanishes = false,
  });

  final BlockType type;
  final Position from;
  final Position to;

  /// 도착과 함께 사라지는가 — 블랙홀에 빨려 들어가는 경우다.
  final bool vanishes;
}

/// 1행 [cols] 열 판. 데모는 전부 한 줄이면 충분하다 — 규칙 하나만 보여준다.
BoardState _strip(
  int cols, {
  Map<int, FloorType> floors = const {},
  Set<WallEdge> walls = const {},
}) => BoardState(
  rowCount: 1,
  colCount: cols,
  floors: [
    [for (var col = 0; col < cols; col++) floors[col] ?? FloorType.empty],
  ],
  blocks: const [],
  walls: walls,
);

_Scene _sceneFor(TutorialDemo demo) => switch (demo) {
  // 벽에 닿을 때까지 미끄러져 목표에 선다.
  TutorialDemo.slide => _Scene(
    board: _strip(5, floors: {4: FloorType.goal}),
    actors: const [
      _Actor(
        type: BlockType.player,
        from: Position(0, 0),
        to: Position(0, 4),
      ),
    ],
  ),

  // 앞 블록이 끝에 서고, 플레이어는 그 앞에 멈춘다.
  TutorialDemo.blockBrake => _Scene(
    board: _strip(5, floors: {3: FloorType.goal}),
    actors: const [
      _Actor(
        type: BlockType.normal,
        from: Position(0, 1),
        to: Position(0, 4),
      ),
      _Actor(
        type: BlockType.player,
        from: Position(0, 0),
        to: Position(0, 3),
      ),
    ],
  ),

  // 지나가기만 해도 빨려 들어간다 — 목표까지 가지 못한다.
  TutorialDemo.blackHole => _Scene(
    board: _strip(5, floors: {2: FloorType.blackHole, 4: FloorType.goal}),
    actors: const [
      _Actor(
        type: BlockType.player,
        from: Position(0, 0),
        to: Position(0, 2),
        vanishes: true,
      ),
    ],
  ),

  // 경계 벽 앞에서 멈춘다. **벽 너머 칸은 멀쩡히 살아 있다.**
  TutorialDemo.edgeWall => _Scene(
    board: _strip(
      5,
      floors: {2: FloorType.goal},
      walls: {WallEdge.between(const Position(0, 2), Direction.right)},
    ),
    actors: const [
      _Actor(
        type: BlockType.player,
        from: Position(0, 0),
        to: Position(0, 2),
      ),
    ],
  ),
};
