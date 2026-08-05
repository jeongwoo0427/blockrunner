import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/core/error/failure_code.dart';
import 'package:blockrunner/feature/level/data/level_blueprints.dart';
import 'package:blockrunner/feature/level/data/repository/level_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('모든 레벨을 번호 순서대로 돌려준다', () {
    final repository = LevelRepositoryImpl();

    expect(repository.levelCount, kLevelBlueprints.length);
    expect(
      repository.getAllLevels().map((level) => level.number),
      kLevelBlueprints.map((blueprint) => blueprint.number),
    );
  });

  test('번호로 레벨을 찾는다', () {
    final repository = LevelRepositoryImpl();

    expect(repository.getLevel(3).number, 3);
  });

  test('없는 번호는 levelNotFound 로 터진다', () {
    final repository = LevelRepositoryImpl();

    expect(
      () => repository.getLevel(999),
      throwsA(
        isA<ClientFailure>().having(
          (failure) => failure.code,
          'code',
          FailureCode.levelNotFound,
        ),
      ),
    );
  });

  test('파싱 결과를 캐시해 매번 다시 만들지 않는다', () {
    final repository = LevelRepositoryImpl();

    expect(repository.getAllLevels(), same(repository.getAllLevels()));
    expect(repository.getLevel(1), same(repository.getLevel(1)));
  });

  test('잘못된 레벨 데이터는 접근 시점에 터진다', () {
    final repository = LevelRepositoryImpl(
      blueprints: const [
        LevelBlueprint(number: 1, minMoves: 1, rows: ['@...']),
      ],
    );

    expect(
      () => repository.getAllLevels(),
      throwsA(
        isA<ClientFailure>().having(
          (failure) => failure.code,
          'code',
          FailureCode.invalidLevelData,
        ),
      ),
    );
  });
}
