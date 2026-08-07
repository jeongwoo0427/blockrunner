import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/core/error/failure_code.dart';
import 'package:blockrunner/feature/game/data/map_blueprints.dart';
import 'package:blockrunner/feature/game/data/map_parser.dart';
import 'package:blockrunner/feature/game/domain/entity/game_map.dart';
import 'package:blockrunner/feature/game/domain/repository/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  MapRepositoryImpl({
    this._blueprints = kMapBlueprints,
    this._parser = const MapParser(),
  });

  final List<MapBlueprint> _blueprints;
  final MapParser _parser;

  /// 파싱은 **레벨마다** 한 번만 한다. 상수 데이터라 결과가 바뀌지 않는다.
  ///
  /// 한꺼번에 파싱하면 맵 하나의 오타가 모든 레벨을 막는다 — 9번이 잘못돼
  /// 있으면 1번도 열리지 않는다. 맵을 고치는 중에는 그 레벨만 터져야 한다.
  /// 전부 성한지는 [getAllMaps] 를 부르는 테스트가 본다.
  final Map<int, GameMap> _cache = {};

  @override
  List<GameMap> getAllMaps() => [
    for (final blueprint in _blueprints) getMap(blueprint.levelNumber),
  ];

  @override
  GameMap getMap(int levelNumber) {
    final cached = _cache[levelNumber];
    if (cached != null) return cached;

    for (final blueprint in _blueprints) {
      if (blueprint.levelNumber == levelNumber) {
        return _cache[levelNumber] = _parser.parse(blueprint);
      }
    }
    throw ClientFailure(
      code: FailureCode.mapNotFound,
      stackTrace: StackTrace.current,
      debugMessage: '레벨 $levelNumber 의 맵이 없다',
    );
  }
}
