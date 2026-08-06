import 'package:blockrunner/core/i18n/app_strings_scope.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:blockrunner/core/widget/game_icon_button.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen_event.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen_state.dart';
import 'package:blockrunner/feature/level/presentation/level_select/widget/level_card.dart';
import 'package:flutter/material.dart';

/// 그리기만 한다. **Riverpod 을 모른다** (docs/architecture.md §5).
///
/// 로컬 UI 상태가 없어 `StatefulWidget` 을 쓰지 않는다 — 규약의 "Screen 은
/// StatefulWidget" 은 컨트롤러·포커스를 두기 위한 것이고 여기엔 그럴 것이 없다.
class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({
    super.key,
    required this.state,
    required this.onEvent,
    this.previewBuilder,
  });

  final LevelSelectScreenState state;
  final ValueChanged<LevelSelectScreenEvent> onEvent;

  /// 카드 안에 그릴 미니 보드를 만들어 준다 (12-ui-polish §2).
  ///
  /// **위젯을 받지 판을 받지 않는다.** 판은 `game` 이 소유하는데 이 화면은
  /// `level` 에 있어서, 타입으로라도 새어 들어오면 `#22` 의 순환이 되살아난다.
  /// 여기 보이는 것은 순수 Flutter 타입뿐이고 조립은 라우터가 한다.
  ///
  /// 잠긴 레벨에는 부르지 않는다 — 판을 가리기 때문이다.
  final Widget Function(BuildContext, int levelNumber)? previewBuilder;

  @override
  Widget build(BuildContext context) {
    final failure = state.failure;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.levelSelectTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.all(Spacing.sm),
            child: GameIconButton(
              icon: Icons.settings,
              onPressed: () => onEvent(SettingsRequested()),
              tooltip: context.strings.settings,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: failure != null
            ? _ErrorBody(message: failure.debugMessage)
            : GridView.builder(
                padding: const EdgeInsets.all(Spacing.md),
                // 열 수를 박지 않고 **카드 최대 폭**을 정한다. 모바일에서는
                // 3열 안팎, 넓은 화면에서는 그만큼 더 들어간다 (10-responsive).
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  // 미니 보드가 들어가면서 카드가 커졌다. 폭도 함께 키워야
                  // 판이 알아볼 수 없을 만큼 작아지지 않는다.
                  maxCrossAxisExtent: 180,
                  mainAxisSpacing: Spacing.sm,
                  crossAxisSpacing: Spacing.sm,
                  childAspectRatio: _cardAspectRatio(context),
                ),
                itemCount: state.levels.length,
                itemBuilder: (context, index) {
                  final level = state.levels[index];
                  final isUnlocked = state.isUnlocked(level.number);

                  return LevelCard(
                    level: level,
                    progress: state.progressOf(level.number),
                    isUnlocked: isUnlocked,
                    // **잠긴 레벨은 아예 만들지 않는다** — 판을 가려야 하므로
                    // 그릴 이유가 없다 (13-game-feel §2).
                    preview: isUnlocked
                        ? previewBuilder?.call(context, level.number)
                        : null,
                    onTap: () => onEvent(
                      isUnlocked
                          ? LevelSelected(level)
                          : LockedLevelSelected(level),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// 카드의 가로:세로 비. **글꼴이 커지면 카드도 세로로 길어진다.**
///
/// 비를 상수로 박아 두면 카드 높이가 고정되는데 안의 글자는 커지므로,
/// 접근성 글꼴을 켠 사용자에게는 그냥 넘친다 (실제로 그랬다).
///
/// 아이콘(자물쇠·별)은 배율을 따르지 않으므로 글자 배율만큼 늘릴 필요는 없다.
/// 그래서 배율을 그대로 나누지 않고 절반만 반영하며, 지나치게 길쭉해지지
/// 않도록 상한을 둔다.
double _cardAspectRatio(BuildContext context) {
  const base = 0.72;
  final scale = MediaQuery.textScalerOf(context).scale(100) / 100;
  final growth = (1 + (scale - 1) * 0.5).clamp(1.0, 2.0);

  return base / growth;
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Text(
          '${context.strings.levelListLoadFailed}\n${message ?? ''}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
