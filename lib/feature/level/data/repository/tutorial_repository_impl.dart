import 'package:blockrunner/feature/level/domain/repository/tutorial_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialRepositoryImpl implements TutorialRepository {
  TutorialRepositoryImpl({required this._preferences});

  /// datasource 계층을 두지 않으므로 SharedPreferences 를 직접 받는다
  /// (docs/architecture.md §3).
  final SharedPreferences _preferences;

  /// **진행도와 같이 버전을 올린다.** 레벨 번호가 밀리면(25 → 20개) "봤음" 표시도
  /// 엉뚱한 레벨에 붙어, 새 4번의 경계 벽 안내가 뜨지 않는 채로 시작된다.
  static const String _prefix = 'tutorial_seen_v2_';

  static String _key(int levelNumber) => '$_prefix$levelNumber';

  @override
  bool hasSeen(int levelNumber) =>
      _preferences.getBool(_key(levelNumber)) ?? false;

  @override
  Future<void> markSeen(int levelNumber) =>
      _preferences.setBool(_key(levelNumber), true);

  /// **접두사가 붙은 키만 지운다.** 진행도와 언어 설정은 남아야 한다
  /// — 언어는 진행도가 아니라 취향이다 (12-ui-polish §3).
  @override
  Future<void> clearAll() async {
    final keys = _preferences
        .getKeys()
        .where((key) => key.startsWith(_prefix))
        .toList();

    for (final key in keys) {
      await _preferences.remove(key);
    }
  }
}
