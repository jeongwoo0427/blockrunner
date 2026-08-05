import 'package:blockrunner/feature/level/domain/entity/level.dart';
import 'package:blockrunner/feature/progress/data/repository/progress_repository_impl.dart';
import 'package:blockrunner/feature/progress/domain/entity/level_progress.dart';
import 'package:blockrunner/feature/progress/domain/repository/progress_repository.dart';
import 'package:blockrunner/feature/progress/domain/usecase/progress_usecases/save_clear_result_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProgressRepository repository;
  late SaveClearResultUsecase saveClearResult;

  // minMoves 4 → ★★★ 4수, ★★☆ 5~6수, ★☆☆ 7수 이상 (기획서 §5.2).
  const level = Level(number: 3, minMoves: 4);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = ProgressRepositoryImpl(
      preferences: await SharedPreferences.getInstance(),
    );
    saveClearResult = SaveClearResultUsecase(repository: repository);
  });

  tearDown(() => saveClearResult.dispose());

  test('처음 클리어하면 별점과 함께 저장된다', () async {
    final saved = await saveClearResult(level: level, moveCount: 6);

    expect(saved.bestMoveCount, 6);
    expect(saved.stars, 2);
    expect(repository.getProgress(3), saved);
  });

  test('별점은 usecase 가 계산한다 — 호출부가 넘기지 않는다', () async {
    final perfect = await saveClearResult(level: level, moveCount: 4);

    expect(perfect.stars, 3, reason: '최소 수로 풀면 ★★★');
  });

  test('더 나은 기록이면 갱신한다', () async {
    await saveClearResult(level: level, moveCount: 7);

    final better = await saveClearResult(level: level, moveCount: 4);

    expect(better.bestMoveCount, 4);
    expect(better.stars, 3);
    expect(repository.getProgress(3)?.bestMoveCount, 4);
  });

  test('더 나쁜 기록이면 최고 기록을 유지한다', () async {
    await saveClearResult(level: level, moveCount: 4);

    final worse = await saveClearResult(level: level, moveCount: 9);

    expect(worse.bestMoveCount, 4, reason: '재도전이 나빠도 기록은 남는다');
    expect(worse.stars, 3);
    expect(repository.getProgress(3)?.bestMoveCount, 4);
  });

  test('같은 기록은 갱신하지 않는다', () async {
    await saveClearResult(level: level, moveCount: 5);
    final same = await saveClearResult(level: level, moveCount: 5);

    expect(same.bestMoveCount, 5);
  });

  test('저장한 결과를 스트림으로 흘린다', () async {
    // 레벨 선택 화면이 이걸 구독해 해금과 별점을 갱신한다 (08).
    final emitted = <LevelProgress>[];
    final subscription = saveClearResult.stream.listen(emitted.add);
    addTearDown(subscription.cancel);

    await saveClearResult(level: level, moveCount: 6);
    await saveClearResult(level: level, moveCount: 4);
    await Future<void>.delayed(Duration.zero);

    expect(emitted.map((progress) => progress.bestMoveCount), [6, 4]);
  });

  test('갱신하지 않을 때도 방출한다', () async {
    await saveClearResult(level: level, moveCount: 4);

    final emitted = <LevelProgress>[];
    final subscription = saveClearResult.stream.listen(emitted.add);
    addTearDown(subscription.cancel);

    // 기록은 안 바뀌어도 "방금 이 레벨을 깼다" 는 구독자에게 새 정보다.
    await saveClearResult(level: level, moveCount: 9);
    await Future<void>.delayed(Duration.zero);

    expect(emitted, hasLength(1));
    expect(emitted.single.bestMoveCount, 4);
  });
}
