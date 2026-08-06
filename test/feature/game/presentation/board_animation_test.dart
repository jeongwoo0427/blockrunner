import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/theme/data/light_theme.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/block_tile.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 연출은 "끝난 뒤" 를 봐서는 검증되지 않는다. 어차피 도착 좌표는 같다.
/// **중간 프레임을 직접 재는 것**만이 미끄러졌는지, 순간이동했는지를 가른다.
void main() {
  /// 첫 블록이 플레이어, 나머지는 일반 블록인 6×6 빈 판.
  BoardState boardWith(List<Position> positions) => BoardState(
    rowCount: 6,
    colCount: 6,
    floors: List.generate(
      6,
      (_) => List.filled(6, FloorType.empty),
      growable: false,
    ),
    blocks: [
      for (var i = 0; i < positions.length; i++)
        Block(
          id: i,
          type: i == 0 ? BlockType.player : BlockType.normal,
          position: positions[i],
        ),
    ],
  );

  Widget app(
    BoardState board, {
    List<Block> falling = const [],
    bool animating = false,
    bool disableAnimations = false,
  }) => MaterialApp(
    theme: lightTheme,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: Scaffold(
          body: BoardView(
            board: board,
            fallingBlocks: falling,
            isAnimating: animating,
          ),
        ),
      ),
    ),
  );

  double centerX(WidgetTester tester, int index) =>
      tester.getRect(find.byType(BlockTile).at(index)).center.dx;

  const half = Duration(milliseconds: 75);

  testWidgets('블록이 순간이동하지 않고 중간 지점을 지난다', (tester) async {
    final before = boardWith(const [Position(0, 0)]);
    final after = boardWith(const [Position(0, 5)]);

    await tester.pumpWidget(app(before));
    final start = centerX(tester, 0);

    await tester.pumpWidget(app(after, animating: true));
    expect(centerX(tester, 0), start, reason: '첫 프레임은 아직 출발점이다');

    await tester.pump(half);
    final middle = centerX(tester, 0);
    expect(middle, greaterThan(start));

    await tester.pump(AppConstants.moveAnimationDuration);
    final end = centerX(tester, 0);
    expect(middle, lessThan(end), reason: '중간 프레임이 도착점이면 순간이동한 것이다');
  });

  testWidgets('이동 거리가 달라도 같은 비율로 움직여 동시에 도착한다', (tester) async {
    // 플레이어는 5칸, 일반 블록은 2칸 — 거리 비례라면 도착 시점이 어긋난다.
    final before = boardWith(const [Position(0, 0), Position(5, 0)]);
    final after = boardWith(const [Position(0, 5), Position(5, 2)]);

    await tester.pumpWidget(app(before));
    final playerStart = centerX(tester, 0);
    final blockStart = centerX(tester, 1);

    await tester.pumpWidget(app(after, animating: true));
    await tester.pump(half);

    final playerNow = centerX(tester, 0);
    final blockNow = centerX(tester, 1);

    await tester.pump(AppConstants.moveAnimationDuration);
    final playerEnd = centerX(tester, 0);
    final blockEnd = centerX(tester, 1);

    final playerProgress =
        (playerNow - playerStart) / (playerEnd - playerStart);
    final blockProgress = (blockNow - blockStart) / (blockEnd - blockStart);

    expect(playerProgress, greaterThan(0));
    expect(playerProgress, lessThan(1));
    expect(
      blockProgress,
      closeTo(playerProgress, 0.001),
      reason: '진행 비율이 다르면 두 블록의 도착 시점이 어긋난다',
    );
  });

  testWidgets('슬라이드가 끝난 뒤에야 낙하 연출이 시작된다', (tester) async {
    final before = boardWith(const [Position(0, 0)]);
    // 빠진 블록은 판에서 지워지고 fallingBlocks 로 넘어간다.
    final after = boardWith(const []);
    final falling = [
      const Block(id: 0, type: BlockType.player, position: Position(0, 3)),
    ];

    await tester.pumpWidget(app(before));
    final fullWidth = tester.getRect(find.byType(BlockTile)).width;

    await tester.pumpWidget(app(after, falling: falling, animating: true));

    await tester.pump(half);
    expect(
      tester.getRect(find.byType(BlockTile)).width,
      closeTo(fullWidth, 0.01),
      reason: '미끄러지는 동안 줄어들면 낙하가 슬라이드보다 먼저 시작된 것이다',
    );

    // 슬라이드가 끝나는 시점까지는 아직 원래 크기다.
    await tester.pump(half);
    expect(tester.getRect(find.byType(BlockTile)).width, closeTo(fullWidth, 1));

    // 그 뒤부터 줄어든다.
    await tester.pump(AppConstants.fallAnimationDuration);
    expect(
      tester.getRect(find.byType(BlockTile)).width,
      lessThan(fullWidth * 0.5),
    );
  });

  testWidgets('빠지는 블록도 블랙홀까지 미끄러진 뒤 사라진다', (tester) async {
    final before = boardWith(const [Position(0, 0)]);
    final after = boardWith(const []);
    final falling = [
      const Block(id: 0, type: BlockType.player, position: Position(0, 3)),
    ];

    await tester.pumpWidget(app(before));
    final start = centerX(tester, 0);

    await tester.pumpWidget(app(after, falling: falling, animating: true));
    await tester.pump(half);

    expect(
      centerX(tester, 0),
      greaterThan(start),
      reason: '제자리에서 사라지면 어느 블랙홀에 빠졌는지 알 수 없다',
    );
  });

  testWidgets('애니메이션을 끈 환경에서는 즉시 도착한다', (tester) async {
    final before = boardWith(const [Position(0, 0)]);
    final after = boardWith(const [Position(0, 5)]);

    await tester.pumpWidget(app(before, disableAnimations: true));
    final start = centerX(tester, 0);

    await tester.pumpWidget(
      app(after, animating: true, disableAnimations: true),
    );
    final now = centerX(tester, 0);

    expect(now, greaterThan(start));
    // 한 프레임 만에 도착해 있어야 한다.
    await tester.pump(AppConstants.moveWithFallDuration);
    expect(centerX(tester, 0), closeTo(now, 0.01));
  });

  testWidgets('다시하기는 연출 없이 즉시 반영된다', (tester) async {
    final moved = boardWith(const [Position(0, 5)]);
    final initial = boardWith(const [Position(0, 0)]);

    await tester.pumpWidget(app(moved));
    final from = centerX(tester, 0);

    // 다시하기는 isAnimating 을 세우지 않은 채 좌표만 되돌린다(기획서 §7).
    await tester.pumpWidget(app(initial));
    final now = centerX(tester, 0);

    expect(now, lessThan(from));
    await tester.pump(AppConstants.moveAnimationDuration);
    expect(centerX(tester, 0), closeTo(now, 0.01), reason: '되감기 연출이 재생되면 안 된다');
  });
}
