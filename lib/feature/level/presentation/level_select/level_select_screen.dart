import 'package:blockrunner/core/i18n/app_strings_scope.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
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
  });

  final LevelSelectScreenState state;
  final ValueChanged<LevelSelectScreenEvent> onEvent;

  @override
  Widget build(BuildContext context) {
    final failure = state.failure;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.levelSelectTitle),
        actions: [
          IconButton(
            onPressed: () => onEvent(LanguageChangeRequested()),
            icon: const Icon(Icons.language),
            tooltip: context.strings.language,
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
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 160,
                  mainAxisSpacing: Spacing.sm,
                  crossAxisSpacing: Spacing.sm,
                  childAspectRatio: 0.85,
                ),
                itemCount: state.levels.length,
                itemBuilder: (context, index) {
                  final level = state.levels[index];
                  final isUnlocked = state.isUnlocked(level.number);

                  return LevelCard(
                    level: level,
                    progress: state.progressOf(level.number),
                    isUnlocked: isUnlocked,
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
