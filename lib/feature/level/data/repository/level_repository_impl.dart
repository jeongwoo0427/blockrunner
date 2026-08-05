import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/core/error/failure_code.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:blockrunner/feature/level/domain/entity/level.dart';
import 'package:blockrunner/feature/level/domain/repository/level_repository.dart';

class LevelRepositoryImpl implements LevelRepository {
  LevelRepositoryImpl({this._levels = kLevels});

  final List<Level> _levels;

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
