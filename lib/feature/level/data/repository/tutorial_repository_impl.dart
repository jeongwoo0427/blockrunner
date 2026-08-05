import 'package:blockrunner/feature/level/domain/repository/tutorial_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialRepositoryImpl implements TutorialRepository {
  TutorialRepositoryImpl({required this._preferences});

  /// datasource 계층을 두지 않으므로 SharedPreferences 를 직접 받는다
  /// (docs/architecture.md §3).
  final SharedPreferences _preferences;

  static String _key(int levelNumber) => 'tutorial_seen_$levelNumber';

  @override
  bool hasSeen(int levelNumber) =>
      _preferences.getBool(_key(levelNumber)) ?? false;

  @override
  Future<void> markSeen(int levelNumber) =>
      _preferences.setBool(_key(levelNumber), true);
}
