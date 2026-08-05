import 'package:blockrunner/feature/level/domain/entity/level.dart';

/// 레벨 데이터 공급.
///
/// 서버가 없으므로 datasource 계층을 두지 않는다. 구현체가 상수를 직접 보유한다
/// (docs/architecture.md §3).
abstract class LevelRepository {
  List<Level> getAllLevels();

  /// 없는 번호면 throw 한다.
  Level getLevel(int number);

  int get levelCount;
}
