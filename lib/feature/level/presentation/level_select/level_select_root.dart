import 'package:blockrunner/core/i18n/app_strings_scope.dart';
import 'package:blockrunner/core/router/route_paths.dart';
import 'package:blockrunner/feature/level/level_di.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen_event.dart';
import 'package:blockrunner/feature/settings/presentation/language_picker/language_picker_dialog.dart';
import 'package:blockrunner/feature/settings/settings_di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 상태 구독과 네비게이션만 한다 (docs/architecture.md §5).
class LevelSelectRoot extends ConsumerStatefulWidget {
  const LevelSelectRoot({super.key});

  @override
  ConsumerState<LevelSelectRoot> createState() => _LevelSelectRootState();
}

class _LevelSelectRootState extends ConsumerState<LevelSelectRoot> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(levelSelectScreenNotifierProvider);

    return LevelSelectScreen(
      state: state,
      onEvent: (event) {
        switch (event) {
          case LevelSelected():
            // push 라 뒤로가기로 목록에 돌아온다. 그때 별점과 해금은
            // 클리어 알림 스트림이 이미 갱신해 뒀다.
            context.push(
              '${RoutePaths.gamePlay}'
              '?${RoutePaths.levelQueryKey}=${event.level.number}',
            );
          case LockedLevelSelected():
            _showLocked(event.level.number);
          case LanguageChangeRequested():
            _pickLanguage();
        }
      },
    );
  }

  /// 언어를 고르게 하고 고른 것을 반영한다.
  ///
  /// 다이얼로그는 `settings` feature 소유다 — 언어는 이 화면의 상태가 아니다.
  Future<void> _pickLanguage() async {
    final notifier = ref.read(localeNotifierProvider.notifier);
    final picked = await LanguagePickerDialog.show(
      context,
      ref.read(localeNotifierProvider),
    );

    if (picked != null) await notifier.change(picked);
  }

  void _showLocked(int levelNumber) {
    final messenger = ScaffoldMessenger.of(context);

    // 연달아 누르면 쌓여서 화면을 덮는다. 이전 것을 치우고 하나만 띄운다.
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(context.strings.unlockHint(levelNumber - 1)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
