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

  /// 파싱은 한 번만 한다. 상수 데이터라 결과가 바뀌지 않는다.
  List<GameMap>? _cache;

  List<GameMap> get _maps =>
      _cache ??= _blueprints.map(_parser.parse).toList(growable: false);

  @override
  List<GameMap> getAllMaps() => _maps;

  @override
  GameMap getMap(int levelNumber) {
    for (final map in _maps) {
      if (map.levelNumber == levelNumber) return map;
    }
    throw ClientFailure(
      code: FailureCode.mapNotFound,
      stackTrace: StackTrace.current,
      debugMessage: '레벨 $levelNumber 의 맵이 없다',
    );
  }
}
