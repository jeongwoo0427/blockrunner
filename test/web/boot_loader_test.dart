import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **`web/index.html` 의 부팅 로딩 화면이 살아 있는지 본다.**
///
/// Flutter 는 첫 프레임 전까지 `<body>` 에 아무것도 넣지 않아, 엔진 wasm 을
/// 받는 수 초 동안 화면이 완전히 하얗다. 그 구간을 메우는 것이 이 화면이다.
///
/// `flutter test` 로는 이 파일을 실행할 수 없으므로 **읽어서 검사한다** —
/// `no_material_buttons_test` · `no_hardcoded_korean_test` 와 같은 방식이다.
/// 막으려는 것은 `flutter create` 로 웹 스캐폴드를 다시 만들거나 index.html 을
/// 무심코 손볼 때 로딩 화면이 **조용히** 사라지는 것이다. 사라져도 앱은 정상
/// 동작하므로 다른 어떤 테스트도 알아채지 못한다.
void main() {
  final html = File('web/index.html').readAsStringSync();

  test('로딩 화면 요소가 그대로 있다', () {
    for (final id in ['boot', 'boot-track', 'boot-fill', 'boot-pct']) {
      expect(
        html,
        contains('id="$id"'),
        reason: 'web/index.html 에서 로딩 화면의 #$id 가 사라졌다.',
      );
    }
  });

  test('스크립트가 못 돌아도 안내 문구는 남는다', () {
    // 마크업에 박혀 있어야 자바스크립트가 실패해도 흰 화면이 되지 않는다.
    expect(
      html,
      contains('<div id="boot-pct">Loading…</div>'),
      reason: '초기 문구가 마크업에서 사라졌다.',
    );
  });

  test('진행률 스크립트가 flutter_bootstrap.js 보다 앞에 있다', () {
    final patch = html.indexOf('window.fetch =');
    final bootstrap = html.indexOf('flutter_bootstrap.js"');

    expect(patch, greaterThan(-1), reason: 'fetch 를 감싸는 코드가 없다.');
    expect(bootstrap, greaterThan(-1), reason: 'flutter_bootstrap.js 태그가 없다.');

    // 부트스트랩이 먼저 실행되면 엔진의 첫 fetch 를 놓쳐 진행률이 0 에 멈춘다.
    // 컴파일도 실행도 멀쩡하고 화면만 조용히 잘못되는 종류라 여기서 못박는다.
    expect(
      patch,
      lessThan(bootstrap),
      reason: 'fetch 를 감싸는 스크립트가 flutter_bootstrap.js 뒤로 밀렸다.',
    );
  });

  test('총 크기를 얻는 두 경로가 모두 있다', () {
    // Content-Length 는 gzip 이 켜지면 사라진다(nginx 가 chunked 로 보낸다).
    // 그때 분모를 얻는 길이 Range 프로브 하나뿐이라 둘 다 있어야 한다.
    expect(html, contains('content-length'));
    expect(html, contains('bytes=0-0'));
    expect(html, contains('content-range'));
  });

  test('첫 프레임에 걷힌다', () {
    expect(
      html,
      contains('flutter-first-frame'),
      reason: '걷을 시점이 없으면 로딩 화면이 앱을 영영 가린다.',
    );
  });
}
