import 'package:flutter/material.dart';

/// 플레이 화면 — 자리표시자.
///
/// 실제 구현은 docs/tasks/04-game-screen.md 에서 ConsumerStatefulWidget 으로
/// 교체한다. 지금은 라우팅 인자가 제대로 넘어오는지 확인하는 용도다.
class GamePlayRoot extends StatelessWidget {
  final int levelNumber;

  const GamePlayRoot({super.key, required this.levelNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('레벨 $levelNumber')),
      body: Center(child: Text('플레이 화면 (미구현) — level=$levelNumber')),
    );
  }
}
