import 'package:blockrunner/main.dart' as app;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱은 **세로로 고정된다** (기획서 §6.2).
///
/// 한 줄짜리 SDK 호출이지만 조용히 빠지면 아무도 모르고, 되레 나중에 "가로도
/// 되게 해달라" 는 요청이 왔을 때 왜 세로였는지가 남지 않는다.
void main() {
  testWidgets('부팅할 때 세로 방향만 허용한다', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await app.main();
    await tester.pump();

    final call = calls.singleWhere(
      (call) => call.method == 'SystemChrome.setPreferredOrientations',
    );

    expect(call.arguments, [
      'DeviceOrientation.portraitUp',
      'DeviceOrientation.portraitDown',
    ]);
  });
}
