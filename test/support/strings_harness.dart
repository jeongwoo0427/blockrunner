import 'package:blockrunner/core/i18n/app_strings.dart';
import 'package:blockrunner/core/i18n/app_strings_scope.dart';
import 'package:blockrunner/core/i18n/strings_ko.dart';
import 'package:blockrunner/core/theme/data/light_theme.dart';
import 'package:flutter/material.dart';

/// 화면을 문구와 함께 띄운다 (11-i18n).
///
/// **`ProviderScope` 는 여전히 씌우지 않는다.** Screen 이 Riverpod 을 건드리면
/// 터져야 한다는 규약(architecture.md §5)은 그대로다 — `AppStringsScope` 는
/// 순수 `InheritedWidget` 이라 그 가드를 무디게 하지 않는다.
///
/// [strings] 를 바꿔 넘기면 그 언어로 그려진다. 언어 전환 테스트가 이걸 쓴다.
Widget withStrings(Widget child, {AppStrings strings = const StringsKo()}) =>
    AppStringsScope(
      strings: strings,
      child: MaterialApp(theme: lightTheme, home: child),
    );
