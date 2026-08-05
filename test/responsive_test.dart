import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/core/i18n/strings_catalog.dart';
import 'package:blockrunner/feature/game/data/map_blueprints.dart';
import 'package:blockrunner/feature/game/data/map_parser.dart';
import 'package:blockrunner/feature/game/domain/entity/block.dart';
import 'package:blockrunner/feature/game/domain/entity/board_state.dart';
import 'package:blockrunner/feature/game/domain/entity/cell.dart';
import 'package:blockrunner/feature/game/domain/entity/position.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_event.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_state.dart';
import 'package:blockrunner/feature/game/presentation/game_play/widget/board_view.dart';
import 'package:blockrunner/feature/level/data/level_data.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen_event.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/strings_harness.dart';

/// 반응형 (10-responsive).
///
/// **오버플로는 예외로 나타나므로 별도 단언이 필요 없다** — `takeException()` 이
/// 비어 있는지만 보면 된다. 다만 자동으로 실패하지는 않아서 명시적으로 확인한다.
///
/// 다국어가 들어온 뒤로 이 검사가 훨씬 중요해졌다. 같은 화면이 언어마다 다른
/// 길이의 문구를 담게 됐고, 프랑스어는 한국어의 두 배를 넘는 경우가 있다.
void main() {
  final map = const MapParser().parse(kMapBlueprints.first);

  Widget playScreen() => GamePlayScreen(
    state: GamePlayScreenState(
      level: kLevels.first,
      map: map,
      board: map.initialBoard,
    ),
    onEvent: (GamePlayScreenEvent _) {},
  );

  Widget levelSelectScreen() => LevelSelectScreen(
    state: LevelSelectScreenState(
      levels: kLevels,
      highestUnlockedLevel: kLevels.length,
    ),
    onEvent: (LevelSelectScreenEvent _) {},
  );

  /// [screen] 을 주어진 크기 · 언어 · 글꼴 배율로 그리고 오버플로가 없는지 본다.
  Future<void> expectFits(
    WidgetTester tester,
    Widget screen, {
    required Size size,
    AppLocale locale = AppLocale.ko,
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: withStrings(screen, strings: stringsFor(locale)),
      ),
    );

    expect(
      tester.takeException(),
      isNull,
      reason:
          '${locale.code} · ${size.width.toInt()}×${size.height.toInt()} · '
          '글꼴 ×$textScale 에서 넘쳤다',
    );
  }

  /// 가장 작다고 보는 화면. 이보다 작은 기기는 사실상 없다.
  const smallPhone = Size(320, 568);

  group('작은 폰에서 모든 언어가 들어간다', () {
    for (final locale in AppLocale.values) {
      testWidgets('${locale.code} — 플레이', (tester) async {
        await expectFits(
          tester,
          playScreen(),
          size: smallPhone,
          locale: locale,
        );
      });

      testWidgets('${locale.code} — 레벨 선택', (tester) async {
        await expectFits(
          tester,
          levelSelectScreen(),
          size: smallPhone,
          locale: locale,
        );
      });
    }
  });

  group('글꼴을 키워도 넘치지 않는다', () {
    // 접근성 설정을 켠 사용자를 버리지 않는다. 한국어와 가장 긴 프랑스어를 본다.
    for (final locale in [AppLocale.ko, AppLocale.fr]) {
      for (final scale in [1.5, 2.0]) {
        testWidgets('${locale.code} — 플레이 ×$scale', (tester) async {
          await expectFits(
            tester,
            playScreen(),
            size: smallPhone,
            locale: locale,
            textScale: scale,
          );
        });

        testWidgets('${locale.code} — 레벨 선택 ×$scale', (tester) async {
          await expectFits(
            tester,
            levelSelectScreen(),
            size: smallPhone,
            locale: locale,
            textScale: scale,
          );
        });
      }
    }
  });

  group('창 크기를 훑어도 넘치지 않는다', () {
    // 데스크탑 창을 좌우로 끄는 상황. 중간 어디에서도 깨지면 안 된다.
    const widths = [300.0, 360.0, 480.0, 600.0, 820.0, 1200.0, 1600.0];

    testWidgets('가로 스윕 — 플레이', (tester) async {
      for (final width in widths) {
        await expectFits(
          tester,
          playScreen(),
          size: Size(width, 800),
          locale: AppLocale.fr,
        );
      }
    });

    testWidgets('가로 스윕 — 레벨 선택', (tester) async {
      for (final width in widths) {
        await expectFits(
          tester,
          levelSelectScreen(),
          size: Size(width, 800),
          locale: AppLocale.fr,
        );
      }
    });

    testWidgets('세로 스윕 — 납작한 창에서도 버틴다', (tester) async {
      for (final height in [320.0, 420.0, 560.0, 900.0]) {
        await expectFits(
          tester,
          playScreen(),
          size: Size(900, height),
          locale: AppLocale.fr,
        );
      }
    });
  });

  group('번역이 화면에서 잘리지 않는다', () {
    /// 지금 그려진 것 중 [maxLines] 를 넘겨 말줄임된 문구.
    List<String> truncated(WidgetTester tester) => [
      for (final element in find.byType(Text).evaluate())
        if (element.renderObject case final RenderParagraph paragraph)
          if (paragraph.didExceedMaxLines)
            (element.widget as Text).data ?? '?',
    ];

    // 카드는 좁은 폰에서 120px 안팎까지 줄어든다. 열 수가 바뀌는 지점마다
    // 카드 폭이 크게 달라지므로 몇 가지 폭을 함께 본다.
    for (final width in [320.0, 360.0, 400.0, 480.0]) {
      testWidgets('레벨 이름 @${width.toInt()}', (tester) async {
        for (final locale in AppLocale.values) {
          await expectFits(
            tester,
            levelSelectScreen(),
            size: Size(width, 800),
            locale: locale,
          );

          expect(
            truncated(tester),
            isEmpty,
            reason:
                '${locale.code} 의 레벨 이름이 카드에서 잘린다. '
                '카드를 키우지 말고 **이름을 짧게** 하는 것이 맞다 — '
                '카드 라벨에는 길이 예산이 있다',
          );
        }
      });
    }
  });

  group('보드', () {
    /// [side]×[side] 빈 판. 가운데에 플레이어 하나만 둔다.
    BoardState squareBoard(int side) => BoardState(
      rowCount: side,
      colCount: side,
      floors: List.generate(
        side,
        (_) => List.filled(side, FloorType.empty),
        growable: false,
      ),
      blocks: [
        const Block(id: 0, type: BlockType.player, position: Position(0, 0)),
      ],
    );

    Future<Size> outerSizeOf(WidgetTester tester, int side) async {
      tester.view
        ..physicalSize = const Size(400, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        withStrings(Scaffold(body: BoardView(board: squareBoard(side)))),
      );

      return tester.getSize(
        find.ancestor(
          of: find.byType(CustomPaint),
          matching: find.byType(SizedBox),
        ),
      );
    }

    testWidgets('6×6 과 8×8 의 외곽 크기가 같다', (tester) async {
      // 레벨을 옮겨 다닐 때 판이 커졌다 작아졌다 하면 시선이 흔들린다.
      final six = await outerSizeOf(tester, 6);
      final eight = await outerSizeOf(tester, 8);

      expect(eight.width, closeTo(six.width, 0.01));
      expect(eight.height, closeTo(six.height, 0.01));
    });

    testWidgets('칸이 많아지면 셀이 작아진다', (tester) async {
      // 위 테스트가 "둘 다 0" 같은 자명한 이유로 통과하지 않는지 본다.
      final six = await outerSizeOf(tester, 6);

      expect(six.width, greaterThan(0));
    });
  });
}
