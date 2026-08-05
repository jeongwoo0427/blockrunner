import 'package:blockrunner/feature/game/domain/entity/board_state.dart';

/// 레벨 하나. 상수 데이터로 정의되며 플레이 중에 바뀌지 않는다.
class Level {
  const Level({
    required this.number,
    required this.initialBoard,
    required this.minMoves,
    this.name,
  });

  /// 1부터 시작하는 레벨 번호. 순차 해금의 기준이다.
  final int number;

  /// 표시용 이름. 없으면 번호만 보여준다.
  final String? name;

  final BoardState initialBoard;

  /// 별점 기준이 되는 최소 이동 횟수.
  final int minMoves;
}
