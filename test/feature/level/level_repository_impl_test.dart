import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/core/error/failure_code.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:blockrunner/feature/level/data/repository/level_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('모든 레벨을 번호 순서대로 돌려준다', () {
    final repository = LevelRepositoryImpl();

    expect(repository.levelCount, kLevels.length);
    expect(
      repository.getAllLevels().map((level) => level.number),
      kLevels.map((level) => level.number),
    );
  });

  test('번호로 레벨을 찾는다', () {
    final level = LevelRepositoryImpl().getLevel(3);

    expect(level.number, 3);
    expect(level.hasTutorial, isTrue);
    // **최단 수를 숫자로 박지 않는다.** 맵을 고칠 때마다 이 테스트까지 끌려온다.
    // 선언값이 실제 맵과 맞는지는 `map_and_level_data_test` 가 완전 탐색으로 본다.
    expect(level.minMoves, kLevels[2].minMoves);
  });

  test('없는 번호는 levelNotFound 로 터진다', () {
    expect(
      () => LevelRepositoryImpl().getLevel(999),
      throwsA(
        isA<ClientFailure>().having(
          (failure) => failure.code,
          'code',
          FailureCode.levelNotFound,
        ),
      ),
    );
  });
}
