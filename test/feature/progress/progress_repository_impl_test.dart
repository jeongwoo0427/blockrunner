import 'dart:convert';

import 'package:blockrunner/feature/progress/data/repository/progress_repository_impl.dart';
import 'package:blockrunner/feature/progress/domain/entity/level_progress.dart';
import 'package:blockrunner/feature/progress/domain/repository/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProgressRepository repository;

  Future<void> boot([Map<String, Object> preferences = const {}]) async {
    SharedPreferences.setMockInitialValues(preferences);
    repository = ProgressRepositoryImpl(
      preferences: await SharedPreferences.getInstance(),
    );
  }

  /// 저장 형식을 테스트가 알아야 손상 케이스를 만들 수 있다.
  String key(int levelNumber) => 'progress_v1_level_$levelNumber';
  String record({int moves = 2, int stars = 3}) =>
      jsonEncode({'bestMoveCount': moves, 'stars': stars});

  setUp(boot);

  test('아무것도 클리어하지 않았으면 비어 있고 1레벨만 열려 있다', () {
    expect(repository.getAllProgress(), isEmpty);
    expect(repository.getProgress(1), isNull);
    expect(repository.highestUnlockedLevel, 1);
  });

  test('저장한 진행도를 그대로 읽는다', () async {
    const progress = LevelProgress(levelNumber: 3, bestMoveCount: 4, stars: 2);

    await repository.saveProgress(progress);

    expect(repository.getProgress(3), progress);
    expect(repository.getAllProgress(), {3: progress});
  });

  test('앱을 다시 켜도 남아 있다', () async {
    await repository.saveProgress(
      const LevelProgress(levelNumber: 2, bestMoveCount: 5, stars: 1),
    );

    // 같은 저장소를 보는 새 인스턴스 = 앱 재실행.
    final reopened = ProgressRepositoryImpl(
      preferences: await SharedPreferences.getInstance(),
    );

    expect(reopened.getProgress(2)?.bestMoveCount, 5);
    expect(reopened.highestUnlockedLevel, 3);
  });

  test('N 을 클리어하면 N+1 이 열린다', () async {
    await repository.saveProgress(
      const LevelProgress(levelNumber: 1, bestMoveCount: 1, stars: 3),
    );
    expect(repository.highestUnlockedLevel, 2);

    await repository.saveProgress(
      const LevelProgress(levelNumber: 4, bestMoveCount: 6, stars: 1),
    );
    expect(repository.highestUnlockedLevel, 5, reason: '가장 높은 클리어 레벨을 따라간다');
  });

  group('손상된 데이터는 버리고 미클리어로 본다', () {
    // 저장 형식이 바뀌었거나 값이 깨졌다고 앱이 켜지지 않으면 안 된다.
    final broken = {
      'JSON 이 아님': 'not json at all',
      'JSON 이지만 객체가 아님': '[1, 2, 3]',
      '필드 누락': '{"stars": 3}',
      '타입이 다름': '{"bestMoveCount": "many", "stars": 3}',
      '별점 범위 밖': '{"bestMoveCount": 3, "stars": 9}',
      '음수 이동 횟수': '{"bestMoveCount": -1, "stars": 2}',
    };

    broken.forEach((label, raw) {
      test(label, () async {
        await boot({key(2): raw});

        expect(repository.getProgress(2), isNull);
        expect(repository.getAllProgress(), isEmpty);
        expect(repository.highestUnlockedLevel, 1);
      });
    });

    test('한 레벨이 깨져도 나머지는 살아남는다', () async {
      // 레벨 하나당 키 하나로 나눠 담는 이유가 이것이다.
      await boot({key(1): record(moves: 1), key(2): 'garbage'});

      expect(repository.getProgress(1), isNotNull);
      expect(repository.getProgress(2), isNull);
      expect(repository.getAllProgress().keys, [1]);
    });
  });

  test('진행도가 아닌 키는 건드리지 않는다', () async {
    // 튜토리얼 플래그가 같은 저장소에 있다 (기획서 §6.1).
    await boot({'tutorial_seen_1': true, key(1): record()});

    expect(repository.getAllProgress().keys, [1]);

    await repository.clearAll();
    final preferences = await SharedPreferences.getInstance();

    expect(repository.getAllProgress(), isEmpty);
    expect(
      preferences.getBool('tutorial_seen_1'),
      isTrue,
      reason: '진행도 초기화가 튜토리얼 기록까지 지우면 안 된다',
    );
  });

  test('접두사가 같아도 번호가 아니면 무시한다', () async {
    await boot({'${key(1)}_extra': record(), 'progress_v1_level_abc': record()});

    expect(repository.getAllProgress(), isEmpty);
  });
}
