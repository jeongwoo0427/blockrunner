import 'package:blockrunner/core/error/failure.dart';
import 'package:blockrunner/core/error/failure_code.dart';
import 'package:blockrunner/core/i18n/strings_ko.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen_event.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen_state.dart';
import 'package:blockrunner/feature/level/presentation/level_select/widget/level_card.dart';
import 'package:blockrunner/feature/progress/domain/entity/level_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/strings_harness.dart';

/// **ProviderScope 로 감싸지 않는다.** Screen 이 Riverpod 을 건드리면 여기서
/// 바로 터진다 — "Screen 은 dumb" 규약의 실질적 가드다.
Future<List<LevelSelectScreenEvent>> pumpScreen(
  WidgetTester tester,
  LevelSelectScreenState state, {
  Size size = const Size(600, 2400),
}) async {
  // **전부 그려질 만큼 높은 화면을 쓴다.** 레벨이 20개가 되면서 목록이
  // 스크롤되고, 화면 밖 카드는 아예 만들어지지 않는다 — 개수를 세는 단언이
  // 조용히 어긋난다.
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final events = <LevelSelectScreenEvent>[];

  await tester.pumpWidget(
    withStrings(LevelSelectScreen(state: state, onEvent: events.add)),
  );

  return events;
}

void main() {
  const ko = StringsKo();

  LevelSelectScreenState stateOf({
    int highestUnlockedLevel = 1,
    Map<int, LevelProgress> progress = const {},
  }) => LevelSelectScreenState(
    levels: kLevels,
    progress: progress,
    highestUnlockedLevel: highestUnlockedLevel,
  );

  testWidgets('레벨 수만큼 카드를 그린다', (tester) async {
    await pumpScreen(tester, stateOf());

    expect(find.byType(LevelCard), findsNWidgets(kLevels.length));
  });

  testWidgets('잠긴 레벨은 자물쇠로 구분되고 이름이 가려진다', (tester) async {
    await pumpScreen(tester, stateOf());

    // 1번만 열려 있다.
    expect(find.byIcon(Icons.lock_rounded), findsNWidgets(kLevels.length - 1));
    expect(find.text(ko.levelName(1)), findsOneWidget);
    // 앞으로 무엇이 나오는지는 스포일러다.
    expect(find.text(ko.levelName(2)), findsNothing);
  });

  testWidgets('해금된 레벨은 자물쇠가 없다', (tester) async {
    await pumpScreen(tester, stateOf(highestUnlockedLevel: kLevels.length));

    expect(find.byIcon(Icons.lock_rounded), findsNothing);
  });

  testWidgets('미클리어 레벨은 빈 별과 최소 수를 보여준다', (tester) async {
    await pumpScreen(tester, stateOf());

    expect(find.text(ko.minMovesLabel(kLevels.first.minMoves)), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNothing);
  });

  testWidgets('클리어한 레벨은 별점과 자기 기록을 보여준다', (tester) async {
    await pumpScreen(
      tester,
      stateOf(
        highestUnlockedLevel: 2,
        progress: const {
          1: LevelProgress(levelNumber: 1, bestMoveCount: 3, stars: 2),
        },
      ),
    );

    expect(find.byIcon(Icons.star_rounded), findsNWidgets(2));
    expect(find.text(ko.movesLabel(3)), findsOneWidget);
    // 클리어했으면 목표가 아니라 자기 기록이 보여야 한다.
    //
    // **1번 카드 안에서만 찾는다.** 화면 전체를 뒤지면 최소 수가 같은 다른
    // 레벨의 카드에 걸려서, 1번이 제대로 그려져도 실패한다.
    expect(
      find.descendant(
        of: find.byType(LevelCard).first,
        matching: find.text(ko.minMovesLabel(kLevels.first.minMoves)),
      ),
      findsNothing,
    );
  });

  testWidgets('열린 레벨을 누르면 LevelSelected 를 올려보낸다', (tester) async {
    final events = await pumpScreen(tester, stateOf());

    await tester.tap(find.byType(LevelCard).first);

    expect(events.single, isA<LevelSelected>());
    expect((events.single as LevelSelected).level.number, 1);
  });

  testWidgets('잠긴 레벨도 눌리되 LockedLevelSelected 가 나간다', (tester) async {
    // 아예 못 누르게 하면 왜 안 되는지 알 수 없다.
    final events = await pumpScreen(tester, stateOf());

    await tester.tap(find.byType(LevelCard).at(1));

    expect(events.single, isA<LockedLevelSelected>());
    expect((events.single as LockedLevelSelected).level.number, 2);
  });

  testWidgets('로드에 실패하면 에러를 보여준다', (tester) async {
    await pumpScreen(
      tester,
      LevelSelectScreenState(
        failure: ClientFailure(
          code: FailureCode.levelNotFound,
          stackTrace: StackTrace.current,
          debugMessage: '레벨 데이터가 없다',
        ),
      ),
    );

    expect(find.textContaining('레벨 목록을 불러오지 못했다'), findsOneWidget);
    expect(find.byType(LevelCard), findsNothing);
  });

  testWidgets('화면이 넓어지면 열이 늘어난다', (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;

    /// 첫 줄에 놓인 카드 수 = 열 수. 같은 y 에 있는 것들을 센다.
    Future<int> columnsAt(double width) async {
      await pumpScreen(tester, stateOf(), size: Size(width, 900));

      final cards = find.byType(LevelCard);
      final firstRowTop = tester.getTopLeft(cards.first).dy;
      var columns = 0;

      for (var i = 0; i < tester.widgetList(cards).length; i++) {
        if (tester.getTopLeft(cards.at(i)).dy == firstRowTop) columns++;
      }

      return columns;
    }

    // 열 수를 박지 않고 카드 최대 폭만 정했으므로 (10-responsive),
    // 넓어지면 카드가 커지는 게 아니라 열이 늘어난다.
    expect(await columnsAt(1200), greaterThan(await columnsAt(400)));
  });
}
