import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/core/i18n/app_strings_scope.dart';
import 'package:blockrunner/core/widget/overlay_transition.dart';
import 'package:flutter/material.dart';

/// 언어를 고르는 다이얼로그.
///
/// **설정 화면을 따로 세우지 않는다** (11-i18n §5). 설정 항목이 언어 하나뿐이라
/// 화면 하나를 만들 근거가 없다.
///
/// Riverpod 을 모른다 — 고른 값을 `pop` 으로 돌려주고, 저장은 띄운 쪽이 한다.
class LanguagePickerDialog extends StatelessWidget {
  const LanguagePickerDialog({super.key, required this.current});

  final AppLocale current;

  /// 고른 언어를 돌려준다. 그냥 닫으면 `null`.
  static Future<AppLocale?> show(BuildContext context, AppLocale current) =>
      showGeneralDialog<AppLocale>(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(
          context,
        ).modalBarrierDismissLabel,
        barrierColor: Colors.black54,
        // `OverlayCard` 와 같은 등장 연출을 쓴다 (13-game-feel §4).
        transitionDuration: overlayEntranceDuration,
        transitionBuilder: buildOverlayTransition,
        pageBuilder: (context, _, _) => LanguagePickerDialog(current: current),
      );

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(context.strings.language),
      children: [
        for (final locale in AppLocale.values)
          ListTile(
            selected: locale == current,
            // 이름은 **그 언어로** 적는다 — 읽을 수 없는 언어로 적힌 목록에서
            // 자기 언어를 찾을 수는 없다.
            title: Text(locale.nativeName),
            trailing: locale == current ? const Icon(Icons.check) : null,
            onTap: () => Navigator.of(context).pop(locale),
          ),
      ],
    );
  }
}
