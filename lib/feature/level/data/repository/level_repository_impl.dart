import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/core/error/failure_code.dart';
import 'package:blockrunner/feature/game/domain/entity/level.dart';
import 'package:blockrunner/feature/level/data/level_blueprints.dart';
import 'package:blockrunner/feature/level/data/level_parser.dart';
import 'package:blockrunner/feature/level/domain/repository/level_repository.dart';

class LevelRepositoryImpl implements LevelRepository {
  LevelRepositoryImpl({
    this._blueprints = kLevelBlueprints,
    this._parser = const LevelParser(),
  });

  final List<LevelBlueprint> _blueprints;
  final LevelParser _parser;

  /// 파싱은 한 번만 한다. 상수 데이터라 결과가 바뀌지 않는다.
  List<Level>? _cache;

  List<Level> get _levels =>
      _cache ??= _blueprints.map(_parser.parse).toList(growable: false);

  @override
  List<Level> getAllLevels() => _levels;

  @override
  Level getLevel(int number) {
    for (final level in _levels) {
      if (level.number == number) return level;
    }
    throw ClientFailure(
      code: FailureCode.levelNotFound,
      stackTrace: StackTrace.current,
      debugMessage: '레벨 $number 이 없다',
    );
  }

  @override
  int get levelCount => _levels.length;
}
