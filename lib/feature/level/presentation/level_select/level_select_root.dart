import 'package:blockrunner/core/router/route_paths.dart';
import 'package:blockrunner/core/theme/data/spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 레벨 선택 화면 — 자리표시자.
///
/// 실제 구현은 docs/tasks/08-level-select.md 에서 Root/Screen/Notifier
/// 일습으로 교체한다. 지금은 라우팅과 테마가 붙는지 확인하는 용도다.
class LevelSelectRoot extends StatelessWidget {
  const LevelSelectRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('레벨 선택')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('레벨 선택 화면 (미구현)'),
            const SizedBox(height: Spacing.md),
            FilledButton(
              onPressed: () => context.push(
                '${RoutePaths.gamePlay}?${RoutePaths.levelQueryKey}=1',
              ),
              child: const Text('레벨 1 열기'),
            ),
          ],
        ),
      ),
    );
  }
}
