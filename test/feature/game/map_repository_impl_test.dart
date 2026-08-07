import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/core/error/failure_code.dart';
import 'package:blockrunner/feature/game/data/map_blueprints.dart';
import 'package:blockrunner/feature/game/data/repository/map_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher throwsCode(FailureCode code) => throwsA(
  isA<ClientFailure>().having((failure) => failure.code, 'code', code),
);

void main() {
  test('모든 맵을 번호 순서대로 돌려준다', () {
    final repository = MapRepositoryImpl();

    expect(
      repository.getAllMaps().map((map) => map.levelNumber),
      kMapBlueprints.map((blueprint) => blueprint.levelNumber),
    );
  });

  test('레벨 번호로 맵을 찾는다', () {
    expect(MapRepositoryImpl().getMap(3).levelNumber, 3);
  });

  test('없는 번호는 mapNotFound 로 터진다', () {
    expect(
      () => MapRepositoryImpl().getMap(999),
      throwsCode(FailureCode.mapNotFound),
    );
  });

  test('파싱 결과를 캐시해 매번 다시 만들지 않는다', () {
    final repository = MapRepositoryImpl();

    expect(repository.getMap(1), same(repository.getMap(1)));
    expect(repository.getAllMaps().first, same(repository.getMap(1)));
  });

  test('잘못된 맵 데이터는 접근 시점에 터진다', () {
    final repository = MapRepositoryImpl(
      blueprints: const [
        MapBlueprint(levelNumber: 1, rows: ['@...']),
      ],
    );

    expect(
      () => repository.getAllMaps(),
      throwsCode(FailureCode.invalidMapData),
    );
  });

  test('맵 하나가 잘못돼도 다른 레벨은 열린다', () {
    // 전부 한꺼번에 파싱하면 9번의 오타 하나가 1번까지 막는다. 맵을 고치는
    // 중에 나머지 레벨을 못 켜면 무엇이 잘못됐는지 보이지 않는다.
    final repository = MapRepositoryImpl(
      blueprints: const [
        MapBlueprint(
          levelNumber: 1,
          rows: ['+-+-+', '|@ G|', '+-+-+'],
        ),
        MapBlueprint(levelNumber: 2, rows: ['@...']),
      ],
    );

    expect(repository.getMap(1).levelNumber, 1);
    expect(() => repository.getMap(2), throwsCode(FailureCode.invalidMapData));
  });
}
