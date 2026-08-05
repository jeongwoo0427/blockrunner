import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/di/core_providers.dart';
import 'package:blockrunner/core/router/router.dart';
import 'package:blockrunner/core/theme/data/dark_theme.dart';
import 'package:blockrunner/core/theme/data/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class BlockRunnerApp extends StatelessWidget {
  const BlockRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: router,
    );
  }
}
