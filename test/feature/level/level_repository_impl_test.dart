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
    expect(level.minMoves, 2);
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
