import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/i18n/app_locale.dart';
import 'package:blockrunner/core/i18n/app_strings_scope.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:flutter/material.dart';

/// 다이얼로그가 닫히며 돌려주는 요청.
///
/// **초기화를 여기서 실행하지 않는다** (12-ui-polish §3). 지울 것이
/// `progress` 와 `level` 양쪽에 있어 `settings` 가 둘을 알면
/// `level → settings → level` 순환이 된다. 띄운 쪽이 실행한다.
enum SettingsResult { languageChanged, resetProgress }

/// 설정 다이얼로그 — 언어 · 진행도 초기화 · 버전.
///
/// **설정 화면을 따로 세우지 않는다.** 항목이 이것뿐이라 화면 하나를 만들
/// 근거가 없다.
class SettingsDialog extends StatelessWidget {
  const SettingsDialog({
    super.key,
    required this.current,
    required this.onPickLanguage,
  });

  /// 지금 언어. 항목 오른쪽에 그 언어의 이름으로 보여준다.
  final AppLocale current;

  /// 언어 선택을 띄우고 골랐는지를 돌려준다. 저장은 띄운 쪽의 일이다.
  final Future<bool> Function() onPickLanguage;

  static Future<SettingsResult?> show(
    BuildContext context, {
    required AppLocale current,
    required Future<bool> Function() onPickLanguage,
  }) => showDialog<SettingsResult>(
    context: context,
    builder: (context) =>
        SettingsDialog(current: current, onPickLanguage: onPickLanguage),
  );

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return SimpleDialog(
      title: Text(strings.settings),
      children: [
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(strings.language),
          trailing: Text(current.nativeName),
          onTap: () async {
            final navigator = Navigator.of(context);
            final picked = await onPickLanguage();
            if (picked) navigator.pop(SettingsResult.languageChanged);
          },
        ),
        ListTile(
          leading: const Icon(Icons.restart_alt),
          title: Text(strings.resetProgress),
          onTap: () => Navigator.of(context).pop(SettingsResult.resetProgress),
        ),
        const Divider(height: Spacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(strings.version, style: Theme.of(context).textTheme.bodySmall),
              Text(
                AppConstants.appVersion,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
      ],
    );
  }
}

/// 초기화 전에 한 번 더 묻는다. 되돌릴 수 없다.
Future<bool> confirmResetProgress(BuildContext context) async {
  final strings = context.strings;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(strings.resetProgress),
      content: Text(strings.resetProgressWarning),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(strings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(strings.resetProgress),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}
