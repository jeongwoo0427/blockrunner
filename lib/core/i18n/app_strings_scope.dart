import 'package:blockrunner/core/i18n/app_strings.dart';
import 'package:flutter/widgets.dart';

/// 현재 언어의 문구를 위젯 트리에 내려보낸다.
///
/// **Riverpod 이 아니라 `InheritedWidget` 인 이유**: Screen 은 Riverpod 을
/// 모른다는 규약(architecture.md §5)을 지키면서도 문구를 써야 한다. 문자열
/// 수십 개를 `State` 에 실어 `LevelCard` · `GameHud` · 오버레이까지 생성자로
/// 관통시키면 규약을 지키느라 화면이 무너진다.
///
/// 값은 `main.dart` 가 `appStringsProvider` 를 구독해 넣는다 — 언어가 바뀌면
/// 여기 값이 바뀌고 아래가 전부 다시 그려진다.
class AppStringsScope extends InheritedWidget {
  const AppStringsScope({
    super.key,
    required this.strings,
    required super.child,
  });

  final AppStrings strings;

  static AppStrings of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppStringsScope>();
    assert(scope != null, 'AppStringsScope 가 위젯 트리에 없다');
    return scope!.strings;
  }

  @override
  bool updateShouldNotify(AppStringsScope oldWidget) =>
      strings != oldWidget.strings;
}

extension AppStringsContext on BuildContext {
  /// 이 화면에서 쓸 문구. `context.strings.reset` 처럼 쓴다.
  AppStrings get strings => AppStringsScope.of(this);
}
