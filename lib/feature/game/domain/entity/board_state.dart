import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/domain/entity/wall_edge.dart';

/// 한 시점의 판 전체. 불변이며, 이동할 때마다 새 인스턴스를 만든다.
///
/// 되돌리기 스택이 그냥 `List<BoardState>` 가 되는 것이 불변으로 두는 이유다.
/// 최대 8×8 크기에서 인스턴스 생성 비용은 무시할 만하다.
class BoardState {
  BoardState({
    required this.rowCount,
    required this.colCount,
    required this.floors,
    required this.blocks,
    this.walls = const {},
  }) : assert(
         floors.length == rowCount &&
             floors.every((row) => row.length == colCount),
         'floors 의 크기가 ${rowCount}x$colCount 와 일치하지 않는다',
       );

  final int rowCount;
  final int colCount;

  /// `floors[row][col]`. 레벨 내내 동일한 인스턴스를 공유하므로 **수정하면 안 된다.**
  final List<List<FloorType>> floors;

  /// 이동 가능한 블록 전체. 순서에는 의미가 없다.
  final List<Block> blocks;

  /// 칸 사이를 막는 벽. 바닥과 마찬가지로 레벨 내내 바뀌지 않는다.
  /// [WallEdge] 가 정규화되어 있으므로 양쪽 칸 어디서 물어도 같은 벽을 가리킨다.
  final Set<WallEdge> walls;

  /// [from] 에서 [direction] 쪽으로 나가는 길이 경계 벽에 막혀 있는가.
  bool hasWallBetween(Position from, Direction direction) =>
      walls.contains(WallEdge.between(from, direction));

  bool contains(Position position) =>
      position.row >= 0 &&
      position.row < rowCount &&
      position.col >= 0 &&
      position.col < colCount;

  /// 맵 밖은 벽과 동일하게 취급하므로 [FloorType.wall] 을 돌려준다.
  FloorType floorAt(Position position) =>
      contains(position) ? floors[position.row][position.col] : FloorType.wall;

  Block? blockAt(Position position) {
    for (final block in blocks) {
      if (block.position == position) return block;
    }
    return null;
  }

  /// 플레이어 블록. 구멍에 빠져 사라졌다면 `null`.
  Block? get player {
    for (final block in blocks) {
      if (block.isPlayer) return block;
    }
    return null;
  }

  bool get hasPlayer => player != null;

  /// 플레이어가 살아있고, 그 칸의 바닥이 목표이면 클리어다.
  ///
  /// 이 판정은 이동이 **완전히 끝난 뒤에만** 의미가 있다. 목표 칸을 지나가는
  /// 중간 상태에 대해 물으면 참이 되지만, 이동 중에는 이 값을 보지 않는다.
  bool get isCleared {
    final player = this.player;
    return player != null && floorAt(player.position) == FloorType.goal;
  }

  /// 바닥과 벽은 그대로 두고 블록만 교체한 새 보드.
  BoardState withBlocks(List<Block> blocks) => BoardState(
    rowCount: rowCount,
    colCount: colCount,
    floors: floors,
    blocks: blocks,
    walls: walls,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BoardState) return false;
    if (other.rowCount != rowCount || other.colCount != colCount) return false;
    if (!_sameFloors(other.floors)) return false;
    if (other.walls.length != walls.length ||
        !other.walls.containsAll(walls)) {
      return false;
    }
    return other.blocks.toSet().containsAll(blocks) &&
        other.blocks.length == blocks.length;
  }

  bool _sameFloors(List<List<FloorType>> other) {
    for (var row = 0; row < rowCount; row++) {
      for (var col = 0; col < colCount; col++) {
        if (other[row][col] != floors[row][col]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    rowCount,
    colCount,
    Object.hashAll(floors.map(Object.hashAll)),
    // 블록 순서는 의미가 없다. 이동 엔진이 처리 순서대로 정렬해 내놓으므로
    // 같은 판이 다른 순서로 표현될 수 있고, 순서에 민감하면 비교가 깨진다.
    Object.hashAllUnordered(blocks),
    Object.hashAllUnordered(walls),
  );
}
