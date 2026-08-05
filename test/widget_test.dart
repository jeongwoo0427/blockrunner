import 'package:blockrunner/core/di/core_providers.dart';
import 'package:blockrunner/core/router/route_paths.dart';
import 'package:blockrunner/core/router/router.dart';
import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_view.dart';
import 'package:blockrunner/feature/level/presentation/level_select/widget/level_card.dart';
import 'package:blockrunner/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  // router 는 전역 단일 인스턴스라 테스트 간 위치가 남는다. 매번 초기화한다.
  tearDown(() => router.go(RoutePaths.levelSelect));

  Widget bootstrap() => ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const BlockRunnerApp(),
  );

  testWidgets('앱을 켜면 레벨 선택 화면이 뜬다', (tester) async {
    await tester.pumpWidget(bootstrap());
    await tester.pumpAndSettle();

    expect(find.text('레벨 선택'), findsOneWidget);
  });

  testWidgets('레벨 카드를 누르면 쿼리 파라미터로 플레이 화면에 전달된다', (tester) async {
    await tester.pumpWidget(bootstrap());
    await tester.pumpAndSettle();

    // 진행도가 비었으므로 1번만 열려 있다.
    await tester.tap(find.byType(LevelCard).first);
    await tester.pumpAndSettle();

    expect(find.text('레벨 1 · 미끄러지기'), findsOneWidget);
    expect(find.byType(BoardView), findsOneWidget);
  });

  testWidgets('BoardColors 가 라이트/다크 테마 양쪽에 등록되어 있다', (tester) async {
    await tester.pumpWidget(bootstrap());
    await tester.pumpAndSettle();

    final context = tester.element(find.text('레벨 선택'));
    expect(Theme.of(context).extension<BoardColors>(), isNotNull);

    // CustomPainter 가 색을 직접 박지 않고 테마에서 가져올 수 있어야 한다.
    expect(
      context.boardColors.playerBlock,
      isNot(context.boardColors.normalBlock),
    );
  });
}
