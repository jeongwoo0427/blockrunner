import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 부팅 시점에만 얻을 수 있는 의존성.
///
/// main() 에서 ProviderScope(overrides: ...) 로 실제 인스턴스를 주입한다.
/// 주입을 잊으면 조용히 잘못 동작하는 대신 즉시 터지도록 throw 로 둔다.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider 가 override 되지 않았습니다. '
    'main() 의 ProviderScope(overrides: ...) 를 확인하세요.',
  ),
);
