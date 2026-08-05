import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/di/core_providers.dart';
import 'package:blockrunner/core/i18n/app_strings_scope.dart';
import 'package:blockrunner/core/router/router.dart';
import 'package:blockrunner/core/theme/data/dark_theme.dart';
import 'package:blockrunner/core/theme/data/light_theme.dart';
import 'package:blockrunner/feature/settings/settings_di.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 세로 고정 (기획서 §6.2). 모바일에만 걸리는 설정이고 웹·데스크탑에서는
  // 조용히 무시된다 — 창 크기를 강제할 수 없으므로 거기서는 넓은 창에서도
  // 깨지지 않는 것으로 대신한다.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // SharedPreferences 는 비동기로만 얻을 수 있으므로 부팅 시 한 번 읽어
  // provider 에 주입한다. 이후 읽기는 전부 동기다.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const BlockRunnerApp(),
    ),
  );
}

class BlockRunnerApp extends ConsumerWidget {
  const BlockRunnerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 언어가 바뀌면 Scope 의 값이 바뀌고 그 아래가 전부 다시 그려진다.
    // 이것이 "다국어 상태를 선언해두고 쓴다" 의 실체다 (11-i18n §4).
    return AppStringsScope(
      strings: ref.watch(appStringsProvider),
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        routerConfig: router,
      ),
    );
  }
}
