import 'package:blockrunner/core/i18n/app_strings_scope.dart';
import 'package:blockrunner/core/router/route_paths.dart';
import 'package:blockrunner/feature/level/level_di.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen_event.dart';
import 'package:blockrunner/feature/settings/presentation/language_picker/language_picker_dialog.dart';
import 'package:blockrunner/feature/settings/presentation/settings/settings_dialog.dart';
import 'package:blockrunner/feature/settings/settings_di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 상태 구독과 네비게이션만 한다 (docs/architecture.md §5).
class LevelSelectRoot extends ConsumerStatefulWidget {
  const LevelSelectRoot({super.key, this.previewBuilder});

  /// 미니 보드 생성기. 라우터가 넣어 준다 (12-ui-polish §2).
  final Widget Function(BuildContext, int levelNumber, bool isUnlocked)?
  previewBuilder;

  @override
  ConsumerState<LevelSelectRoot> createState() => _LevelSelectRootState();
}

class _LevelSelectRootState extends ConsumerState<LevelSelectRoot> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(levelSelectScreenNotifierProvider);

    return LevelSelectScreen(
      state: state,
      previewBuilder: widget.previewBuilder,
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
          case SettingsRequested():
            _openSettings();
          case ProgressResetConfirmed():
            break; // Notifier 가 처리한다
        }
      },
    );
  }

  /// 설정을 연다. 다이얼로그는 `settings` feature 소유다.
  ///
  /// **초기화 실행은 여기서 한다** (12-ui-polish §3). 지울 것이 `progress` 와
  /// `level` 양쪽에 있어 `settings` 가 둘을 알면 순환이 되기 때문이다.
  Future<void> _openSettings() async {
    final result = await SettingsDialog.show(
      context,
      current: ref.read(localeNotifierProvider),
      onPickLanguage: _pickLanguage,
    );

    if (result != SettingsResult.resetProgress) return;
    if (!mounted) return;

    // 되돌릴 수 없으므로 한 번 더 묻는다.
    if (!await confirmResetProgress(context)) return;
    if (!mounted) return;

    await ref
        .read(levelSelectScreenNotifierProvider.notifier)
        .onEvent(ProgressResetConfirmed());

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(context.strings.resetProgressDone),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 언어를 고르게 하고 고른 것을 반영한다. 골랐으면 `true`.
  Future<bool> _pickLanguage() async {
    final notifier = ref.read(localeNotifierProvider.notifier);
    final picked = await LanguagePickerDialog.show(
      context,
      ref.read(localeNotifierProvider),
    );

    if (picked == null) return false;

    await notifier.change(picked);
    return true;
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
