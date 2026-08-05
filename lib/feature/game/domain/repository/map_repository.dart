import 'package:blockrunner/feature/game/domain/entity/game_map.dart';

/// 맵 데이터 공급.
///
/// 서버가 없으므로 datasource 계층을 두지 않는다. 구현체가 상수를 직접 보유한다
/// (docs/architecture.md §3).
abstract class MapRepository {
  /// 레벨 번호에 대응하는 맵이 없으면 throw 한다.
  GameMap getMap(int levelNumber);

  List<GameMap> getAllMaps();
}
