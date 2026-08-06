import 'dart:async';

import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/core/router/route_paths.dart';
import 'package:blockrunner/feature/splash/presentation/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 시간이 지나거나 누르면 레벨 선택으로 넘긴다 (12-ui-polish §1).
///
/// 상태가 없어 `Notifier` 를 두지 않았다 — 이 화면이 아는 것은 "언제 끝나는가"
/// 뿐이고 그건 타이머 하나다.
class SplashRoot extends StatefulWidget {
  const SplashRoot({super.key});

  @override
  State<SplashRoot> createState() => _SplashRootState();
}

class _SplashRootState extends State<SplashRoot> {
  Timer? _timer;

  /// 두 번 넘어가는 것을 막는다 — 타이머가 울리는 순간 누를 수도 있다.
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(AppConstants.splashDuration, _finish);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _finish() {
    if (_finished || !mounted) return;
    _finished = true;
    _timer?.cancel();

    // **`push` 가 아니라 `go` 다.** 뒤로가기로 스플래시에 돌아오면 안 된다.
    context.go(RoutePaths.levelSelect);
  }

  @override
  Widget build(BuildContext context) => SplashScreen(onFinished: _finish);
}
