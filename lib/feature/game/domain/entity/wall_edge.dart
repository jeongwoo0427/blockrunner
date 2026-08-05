import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';

/// 이웃한 두 칸 **사이**를 막는 벽 (기획서 §2.2).
///
/// 칸 벽(`FloorType.wall`)과 달리 공간을 소비하지 않는다 — 벽 양쪽 칸 모두에
/// 블록이 설 수 있다.
///
/// 같은 벽이 한쪽에서는 "오른쪽 벽", 반대쪽에서는 "왼쪽 벽"으로 보인다.
/// **`right` / `down` 으로 정규화해서** 두 표현이 같은 값이 되게 한다.
/// 정규화하지 않으면 `Set` 안에 같은 벽이 둘로 들어가고, 한 방향에서만
/// 막히는 조용한 버그가 된다.
class WallEdge {
  const WallEdge._(this.position, this.direction);

  /// [position] 칸의 [direction] 쪽 경계에 있는 벽.
  factory WallEdge.between(Position position, Direction direction) =>
      switch (direction) {
        Direction.right || Direction.down => WallEdge._(position, direction),
        Direction.left => WallEdge._(
          position.translate(Direction.left),
          Direction.right,
        ),
        Direction.up => WallEdge._(
          position.translate(Direction.up),
          Direction.down,
        ),
      };

  /// 정규화된 기준 칸. 벽은 이 칸의 오른쪽 또는 아래쪽에 있다.
  final Position position;

  /// 항상 [Direction.right] 또는 [Direction.down].
  final Direction direction;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WallEdge &&
          other.position == position &&
          other.direction == direction;

  @override
  int get hashCode => Object.hash(position, direction);

  @override
  String toString() => 'WallEdge($position ${direction.name})';
}
