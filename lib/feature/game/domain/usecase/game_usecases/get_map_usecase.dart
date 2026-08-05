import 'package:blockrunner/feature/game/domain/entity/game_map.dart';
import 'package:blockrunner/feature/game/domain/repository/map_repository.dart';

class GetMapUsecase {
  const GetMapUsecase({required this._repository});

  final MapRepository _repository;

  /// 대응하는 맵이 없으면 throw 한다. Notifier 가 try/catch 로 받는다.
  GameMap call(int levelNumber) => _repository.getMap(levelNumber);
}
