import 'package:blockrunner/feature/game/domain/entity/position.dart';

/// 블록의 종류.
enum BlockType {
  /// 조작 대상. 맵에 정확히 하나.
  player,

  /// 플레이어와 함께 미끄러지는 일반 블록. 서로를, 그리고 플레이어를 막는다.
  normal,
}

/// 격자 위에서 이동하는 것.
class Block {
  const Block({required this.id, required this.type, required this.position});

  /// 레벨이 끝날 때까지 유지되는 안정적 식별자.
  ///
  /// 이동 전후 보드를 비교해 "어느 블록이 어디서 어디로 갔는지" 알아야
  /// 애니메이션을 그릴 수 있다. 위치만으로는 추적할 수 없다.
  final int id;

  final BlockType type;
  final Position position;

  bool get isPlayer => type == BlockType.player;

  /// 같은 블록이 [position] 으로 옮겨간 새 인스턴스.
  Block moveTo(Position position) =>
      Block(id: id, type: type, position: position);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Block &&
          other.id == id &&
          other.type == type &&
          other.position == position;

  @override
  int get hashCode => Object.hash(id, type, position);

  @override
  String toString() => 'Block($id, ${type.name}, $position)';
}
