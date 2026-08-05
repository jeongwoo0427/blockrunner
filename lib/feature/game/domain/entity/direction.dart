/// 이동 방향. 한 번의 입력이 한 번의 턴이다.
///
/// 행(row)은 아래로 증가하고 열(col)은 오른쪽으로 증가한다.
enum Direction {
  up(rowDelta: -1, colDelta: 0),
  down(rowDelta: 1, colDelta: 0),
  left(rowDelta: 0, colDelta: -1),
  right(rowDelta: 0, colDelta: 1);

  const Direction({required this.rowDelta, required this.colDelta});

  /// 이 방향으로 한 칸 전진할 때의 행 증분.
  final int rowDelta;

  /// 이 방향으로 한 칸 전진할 때의 열 증분.
  final int colDelta;
}
