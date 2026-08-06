import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/theme/data/light_theme.dart';
import 'package:blockrunner/feature/splash/presentation/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 스플래시 연출 (13-game-feel §1).
void main() {
  Future<void> pump(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(theme: lightTheme, home: SplashScreen(onFinished: () {})),
    );
  }

  /// 지금 그려진 블록들의 가로 위치. 왼쪽에서 오른쪽 순서다.
  List<double> blockXs(WidgetTester tester) {
    final tiles = find.byType(Container);
    return [
      for (var i = 0; i < tiles.evaluate().length; i++)
        tester.getTopLeft(tiles.at(i)).dx,
    ];
  }

  test('눈으로 따라갈 만큼 느리다', () {
    // 처음 0.6초였는데 따라가기 전에 끝났다 (13-game-feel §1).
    //
    // **하한만 둔다.** 정확한 값은 취향이라 못박으면 손볼 때마다 깨지지만,
    // 다시 조용히 빨라지는 것은 막아야 한다.
    expect(SplashScreen.slide.inMilliseconds, greaterThanOrEqualTo(1000));

    // 다 보여주기도 전에 넘어가면 늘린 의미가 없다.
    expect(
      SplashScreen.slide.inMilliseconds,
      lessThan(AppConstants.splashDuration.inMilliseconds),
    );
  });

  testWidgets('블록이 왼쪽 밖에서 들어온다', (tester) async {
    await pump(tester);

    final start = blockXs(tester);
    await tester.pump(SplashScreen.slide);
    final end = blockXs(tester);

    expect(start, isNotEmpty);
    for (var i = 0; i < start.length; i++) {
      expect(end[i], greaterThan(start[i]), reason: '$i 번째가 움직이지 않았다');
    }
  });

  testWidgets('하나씩 차례로 도착한다', (tester) async {
    // **동시에 멈추면 한 덩어리로 보인다** — "각자 끝까지 미끄러진다" 가
    // 읽히지 않는다.
    await pump(tester);

    // 앞선 블록(오른쪽 끝 = 플레이어)이 먼저 자리를 잡는 시점.
    await tester.pump(SplashScreen.slide * 0.72);
    final mid = blockXs(tester);

    await tester.pump(SplashScreen.slide);
    final settled = blockXs(tester);

    // 이 시점에 마지막 블록은 이미 제자리, 첫 블록은 아직 오는 중이어야 한다.
    expect(
      (mid.last - settled.last).abs(),
      lessThan(1),
      reason: '앞선 블록은 벌써 서 있어야 한다',
    );
    expect(
      (mid.first - settled.first).abs(),
      greaterThan(1),
      reason: '뒤 블록이 같이 도착하면 하나씩이 아니다',
    );
  });

  testWidgets('결국 한 줄로 정렬된다', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();

    final xs = blockXs(tester);
    final gaps = [
      for (var i = 1; i < xs.length; i++) xs[i] - xs[i - 1],
    ];

    // 간격이 일정해야 "판 위에 늘어선 블록" 으로 보인다.
    for (final gap in gaps) {
      expect(gap, closeTo(gaps.first, 0.5));
    }
  });

  testWidgets('누르면 곧바로 끝난다', (tester) async {
    var finished = 0;
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: SplashScreen(onFinished: () => finished++),
      ),
    );

    // 연출이 길어진 만큼 건너뛰기가 더 중요해졌다.
    await tester.tap(find.byType(SplashScreen));

    expect(finished, 1);
  });
}
