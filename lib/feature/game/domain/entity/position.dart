import 'package:blockrunner/feature/game/domain/entity/direction.dart';

/// 격자 위의 한 칸을 가리키는 좌표.
///
/// 인자는 **항상 `(행, 열)` 순서**다. 기획서의 트레이스 표기(`(4,1)`)와 같다.
/// `Set` · `Map` 의 키로 쓰이므로 `==` / `hashCode` 를 갖는다.
class Position {
  const Position(this.row, this.col);

  final int row;
  final int col;

  /// [direction] 방향으로 한 칸 이동한 좌표. 맵 범위 검사는 하지 않는다.
  Position translate(Direction direction) =>
      Position(row + direction.rowDelta, col + direction.colDelta);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '($row, $col)';
}
