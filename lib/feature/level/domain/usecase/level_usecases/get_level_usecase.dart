import 'package:blockrunner/feature/level/domain/entity/level.dart';
import 'package:blockrunner/feature/level/domain/repository/level_repository.dart';

class GetLevelUsecase {
  const GetLevelUsecase({required this._repository});

  final LevelRepository _repository;

  /// 없는 번호면 throw 한다. Notifier 가 try/catch 로 받는다.
  Level call(int number) => _repository.getLevel(number);
}
