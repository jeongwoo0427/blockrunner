import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/black_hole_painter.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/block_tile.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_metrics.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_painter.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_state.dart';
import 'package:flutter/material.dart';

/// 슬라이드가 끝난 뒤부터 낙하를 재생한다 (기획서 §7).
///
/// 전체 구간을 슬라이드+낙하로 잡고 앞부분을 [Interval] 로 비워 지연을 만든다.
/// 암시적 애니메이션에는 시작 지연이 없어서, 이렇게 하지 않으려면 타이머를
/// 하나 더 두고 두 단계를 손으로 이어붙여야 한다.
const Curve _fallCurve = Interval(
  AppConstants.fallStartFraction,
  1,
  curve: Curves.easeIn,
);

/// 플레이어 흡입은 훨씬 길어서 지연 비율도 다르다.
const Curve _playerFallCurve = Interval(
  AppConstants.playerFallStartFraction,
  1,
  curve: Curves.easeIn,
);

/// 회전하지 않는 블록에 물려 둘 애니메이션.
///
/// **빠질 때만 `RotationTransition` 을 씌우면 안 된다.** 위젯이 트리에 새로
/// 끼어들면 그 아래 `AnimatedScale` 이 새로 생겨 시작값부터 그려지고, 축소가
/// 아예 재생되지 않는다. 늘 씌워 두고 물리는 애니메이션만 바꾼다.
const Animation<double> _noRotation = AlwaysStoppedAnimation(0);

/// 보드를 그린다.
///
/// 좌표 계산은 [BoardMetrics] 가 한다 — 화면 쪽에서도 보드 폭을 알아야
/// HUD 를 맞출 수 있어(기획서 §6.2) 계산을 여기서 꺼내 두었다.
/// **부모가 준 제약에 스스로 맞춘다.** 밖에서 계산한 크기를 받아 그리면
/// 그 계산이 실제 가용 공간보다 크던 순간 보드가 넘친다.
class BoardView extends StatefulWidget {
  const BoardView({
    super.key,
    required this.board,
    this.fallingBlocks = const [],
    this.isAnimating = false,
    this.bump = const Bump.none(),
  });

  final BoardState board;

  /// 블랙홀로 사라지는 중인 블록. [board] 에는 없지만 연출이 끝날 때까지 그린다.
  final List<Block> fallingBlocks;

  /// 연출을 재생할 것인가.
  ///
  /// **암시적 애니메이션이라 이 플래그가 곧 "이번 변화를 보여줄지" 다.** 다시하기와
  /// 레벨 로드는 이 값이 `false` 인 채로 좌표가 바뀌므로 지속 시간이 0 이 되어
  /// 그대로 튄다 — 즉시 반영해야 한다는 기획서 §7 이 공짜로 지켜진다.
  final bool isAnimating;

  /// 마지막 무효 입력 (13-game-feel §7). 세대가 오르면 다시 재생한다.
  final Bump bump;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> with TickerProviderStateMixin {
  /// 블랙홀 회전. **이 프로젝트의 유일한 `AnimationController` 다.**
  ///
  /// 끝나지 않는 애니메이션이라 암시적으로는 표현할 수 없다 — `06-animation`
  /// 에서 정한 방식의 유일한 예외이며, 그래서 페인터를 나눠 두었다
  /// (12-ui-polish §5.2).
  late final AnimationController _swirl = AnimationController(
    vsync: this,
    duration: AppConstants.blackHoleRotationDuration,
  );

  /// 갈 수 없는 방향을 눌렀을 때 판 전체가 밀렸다 돌아온다 (13-game-feel §7).
  ///
  /// 0 → 1 → 0 을 한 번 재생하고 멈춘다. `AnimatedX` 로는 안 된다 —
  /// **같은 방향을 두 번 누르면 목표값이 같아 아무 일도 일어나지 않는다.**
  late final AnimationController _bump = AnimationController(
    vsync: this,
    duration: AppConstants.bumpDuration,
  );

  /// 블록을 삼키느라 판에서는 이미 사라졌지만 아직 그려야 하는 구멍.
  ///
  /// 빠지는 블록이 멈춘 자리가 곧 그 구멍의 자리다(`MoveResult.to`). 낙하가 끝나면
  /// 화면이 `fallingBlocks` 를 비우고, 그때 구멍도 함께 사라진다 — 그것이
  /// "블록이 다 들어간 뒤에 구멍이 사라진다" 의 전부다.
  Set<Position> get _vanishingHoles => {
    for (final block in widget.fallingBlocks) block.position,
  };

  /// 판에 그릴 블랙홀이 하나라도 있는가. 사라지는 중인 것도 센다.
  bool get _hasBlackHole =>
      widget.board.floors.any((row) => row.contains(FloorType.blackHole)) ||
      _isFalling;

  bool get _isFalling => widget.fallingBlocks.isNotEmpty;

  /// 지금 빠지는 블록 중에 플레이어가 있는가.
  ///
  /// 플레이어의 흡입은 훨씬 길어서(2초) 구멍도 그만큼 오래 남아야 한다. 한 수에
  /// 플레이어와 동료가 각자 다른 구멍에 빠지면 긴 쪽에 맞춘다 — 짧은 쪽에 맞추면
  /// 플레이어가 아직 도는데 그 구멍이 먼저 없어진다.
  bool get _playerIsFalling =>
      widget.fallingBlocks.any((block) => block.type == BlockType.player);

  Duration get _fallSpan => _playerIsFalling
      ? AppConstants.moveWithPlayerFallDuration
      : AppConstants.moveWithFallDuration;

  Curve get _currentFallCurve =>
      _playerIsFalling ? _playerFallCurve : _fallCurve;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSwirl();
  }

  @override
  void didUpdateWidget(BoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSwirl();

    // **세대로 비교한다.** 방향만 보면 같은 방향 연타에서 재생되지 않는다.
    if (widget.bump.generation != oldWidget.bump.generation) {
      _playBump();
    }
  }

  void _playBump() {
    if (MediaQuery.disableAnimationsOf(context)) return;
    _bump.forward(from: 0).whenComplete(() {
      if (mounted) _bump.reverse();
    });
  }

  /// 지금 판이 밀려 있어야 할 거리.
  Offset _bumpOffset(double cell) {
    final direction = widget.bump.direction;
    if (direction == null || _bump.value == 0) return Offset.zero;

    final distance =
        cell *
        AppConstants.bumpDistanceRatio *
        Curves.easeOut.transform(_bump.value);

    return switch (direction) {
      Direction.up => Offset(0, -distance),
      Direction.down => Offset(0, distance),
      Direction.left => Offset(-distance, 0),
      Direction.right => Offset(distance, 0),
    };
  }

  @override
  void dispose() {
    _swirl.dispose();
    _bump.dispose();
    super.dispose();
  }

  /// **블랙홀이 없는 판에서는 아예 돌리지 않는다.**
  ///
  /// 배터리 때문이기도 하지만, 도는 컨트롤러가 있으면 `pumpAndSettle` 이 영원히
  /// 끝나지 않는다. 블랙홀이 있는 레벨을 그렇게 검사하려 들면 멈추므로
  /// `pump` 를 쓸 것.
  void _syncSwirl() {
    final shouldRun = _hasBlackHole && !MediaQuery.disableAnimationsOf(context);

    if (shouldRun && !_swirl.isAnimating) {
      _swirl.repeat();
    } else if (!shouldRun && _swirl.isAnimating) {
      _swirl.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final board = widget.board;
    // OS 의 "동작 줄이기" 를 켠 사용자에게는 연출을 건너뛴다. 게임 진행은 같다.
    final animates =
        widget.isAnimating && !MediaQuery.disableAnimationsOf(context);
    final slide = animates ? AppConstants.moveAnimationDuration : Duration.zero;
    final colors = context.boardColors;

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final metrics = BoardMetrics.fit(
            board: board,
            available: constraints.biggest,
          );

          return AnimatedBuilder(
            animation: _bump,
            builder: (context, child) => Transform.translate(
              offset: _bumpOffset(metrics.cell),
              child: child,
            ),
            // 판이 화면 위에 **떠 있어 보이게** 한다. 판 자체는 외곽 프레임까지
            // 이 상자를 꽉 채워 불투명하므로, 그림자는 판 밖으로만 삐져나온다.
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: metrics.cell * Spacing.boardShadowBlurRatio,
                    offset: Offset(
                      0,
                      metrics.cell * Spacing.boardShadowOffsetRatio,
                    ),
                  ),
                ],
              ),
              child: SizedBox(
                width: metrics.width,
                height: metrics.height,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: BoardPainter(
                          board: board,
                          colors: colors,
                          cell: metrics.cell,
                          origin: metrics.origin,
                        ),
                      ),
                    ),
                    // 회전하는 것만 따로 그린다. 이 레이어만 매 프레임 갱신된다.
                    if (_hasBlackHole)
                      Positioned.fill(
                        child: RepaintBoundary(
                          // 삼켜진 구멍은 블록과 **같은 시간·같은 커브**로 사라진다.
                          // 블록 쪽은 `AnimatedScale`·`AnimatedOpacity` 라 여기서도
                          // 암시적으로 굴린다 — 컨트롤러를 하나 더 두지 않는다.
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end: _isFalling ? 1 : 0,
                            ),
                            // 빠지는 중이 아니면 **즉시** 0 으로 돌린다. 되돌아가는
                            // 도중에 다음 낙하가 시작되면 구멍이 이미 반쯤 줄어든
                            // 채로 나타난다.
                            duration: _isFalling && animates
                                ? _fallSpan
                                : Duration.zero,
                            curve: _currentFallCurve,
                            builder: (context, vanish, _) => AnimatedBuilder(
                              animation: _swirl,
                              builder: (context, _) => CustomPaint(
                                painter: BlackHolePainter(
                                  board: board,
                                  colors: colors,
                                  cell: metrics.cell,
                                  origin: metrics.origin,
                                  turns: _swirl.value,
                                  vanishing: _vanishingHoles,
                                  vanishProgress: vanish,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // 빠지는 블록도 같은 목록에 섞어 그린다. 키로 추적되므로 판에서
                    // 이 목록으로 옮겨와도 같은 위젯으로 남아 이어서 미끄러진다.
                    for (final (block, isFalling) in [
                      for (final block in board.blocks) (block, false),
                      for (final block in widget.fallingBlocks) (block, true),
                    ])
                      _blockTile(
                        block: block,
                        isFalling: isFalling,
                        animates: animates,
                        slide: slide,
                        metrics: metrics,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _blockTile({
    required Block block,
    required bool isFalling,
    required bool animates,
    required Duration slide,
    required BoardMetrics metrics,
  }) {
    // 플레이어만 블랙홀에 끌려 들어가는 긴 연출을 받는다 (12-ui-polish §5.3).
    final isPlayerFalling = isFalling && block.type == BlockType.player;
    final span = isPlayerFalling
        ? AppConstants.moveWithPlayerFallDuration
        : AppConstants.moveWithFallDuration;
    final whole = animates ? span : Duration.zero;
    final curve = isPlayerFalling ? _playerFallCurve : _fallCurve;

    return AnimatedPositioned(
      // 같은 블록으로 추적되려면 안정적인 키가 있어야 한다.
      // 키가 없으면 목록 순서가 바뀔 때 블록끼리 정체가 뒤바뀐다.
      key: ValueKey(block.id),
      duration: slide,
      curve: Curves.easeOut,
      left: metrics.margin + block.position.col * metrics.cell,
      top: metrics.margin + block.position.row * metrics.cell,
      width: metrics.cell,
      height: metrics.cell,
      // 블랙홀과 **같은 각속도로** 돈다. 어긋나면 빨려 들어가는 것으로 보이지
      // 않고 그냥 따로 도는 두 물체가 된다.
      child: RotationTransition(
        turns: isPlayerFalling ? _swirl : _noRotation,
        // 축소·페이드는 **항상 걸어둔다.** 빠지는 순간에만 감싸면
        // 위젯이 새로 생겨 시작값부터 그려지고, 애니메이션 없이 사라진다.
        child: AnimatedScale(
          scale: isFalling ? 0.1 : 1,
          duration: whole,
          curve: curve,
          child: AnimatedOpacity(
            opacity: isFalling ? 0 : 1,
            duration: whole,
            curve: curve,
            child: BlockTile(type: block.type, size: metrics.cell),
          ),
        ),
      ),
    );
  }
}
