import 'dart:convert';

import 'package:blockrunner/feature/progress/domain/entity/level_progress.dart';
import 'package:blockrunner/feature/progress/domain/repository/progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl({required this._preferences});

  /// datasource 계층을 두지 않으므로 SharedPreferences 를 직접 받는다
  /// (docs/architecture.md §3).
  final SharedPreferences _preferences;

  /// **레벨 하나당 키 하나.** 전체를 한 키에 몰아넣으면 한 레벨의 값이 깨질 때
  /// 진행도 전체가 날아간다.
  ///
  /// `v1` 은 저장 형식 버전이다. 형식이 바뀌면 접두사를 올려 옛 키를 무시하면
  /// 되므로, 지금 붙여두는 비용이 0인 반면 나중에 없으면 마이그레이션이 지저분해진다.
  static const String _prefix = 'progress_v1_level_';

  static String _key(int levelNumber) => '$_prefix$levelNumber';

  @override
  LevelProgress? getProgress(int levelNumber) =>
      _read(levelNumber, _preferences.getString(_key(levelNumber)));

  @override
  Map<int, LevelProgress> getAllProgress() {
    final progress = <int, LevelProgress>{};

    for (final key in _preferences.getKeys()) {
      if (!key.startsWith(_prefix)) continue;

      final levelNumber = int.tryParse(key.substring(_prefix.length));
      if (levelNumber == null) continue;

      final entry = _read(levelNumber, _preferences.getString(key));
      if (entry != null) progress[levelNumber] = entry;
    }

    return progress;
  }

  @override
  Future<void> saveProgress(LevelProgress progress) => _preferences.setString(
    _key(progress.levelNumber),
    jsonEncode(progress.toJson()),
  );

  @override
  int get highestUnlockedLevel {
    // N 을 클리어하면 N+1 이 열린다 (기획서 §5.3).
    var highest = 0;
    for (final levelNumber in getAllProgress().keys) {
      if (levelNumber > highest) highest = levelNumber;
    }
    return highest + 1;
  }

  @override
  Future<void> clearAll() async {
    // 순회 중에 지우면 안 되므로 키를 먼저 모은다.
    final keys = _preferences
        .getKeys()
        .where((key) => key.startsWith(_prefix))
        .toList();

    for (final key in keys) {
      await _preferences.remove(key);
    }
  }

  /// 손상된 값은 **버리고 미클리어로 취급한다. throw 하지 않는다.**
  ///
  /// 저장 형식이 바뀌었거나 값이 깨졌다고 앱이 켜지지 않으면 안 된다.
  /// 진행도는 잃어도 되는 데이터다.
  LevelProgress? _read(int levelNumber, String? raw) {
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) return null;
      return LevelProgress.fromJson(levelNumber, decoded);
    } on FormatException {
      return null;
    }
  }
}
