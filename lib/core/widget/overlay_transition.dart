/// 판 위에 뜨는 것들이 공유하는 등장 연출 (13-game-feel §4).
///
/// **`core` 에 있는 이유**: `OverlayCard`(game)와 설정·언어 다이얼로그(settings)가
/// 같은 커브를 써야 한다. `game` 에 두면 `settings → game` 이 생기는데
/// `game → level → settings` 가 이미 있어 **순환이 된다** — 실제로 그렇게
/// 만들었다가 의존성 테스트에 걸렸다.
library;

import 'package:flutter/material.dart';

/// 튀어나오는 데 걸리는 시간.
///
/// `elasticOut` 은 되튕기는 구간이 있어 짧으면 그 구간이 보이지 않는다.
/// 예전 180ms 에서는 사실상 그냥 커지기만 했다.
const Duration overlayEntranceDuration = Duration(milliseconds: 520);

/// 사라지는 데 걸리는 시간.
///
/// **들어올 때보다 짧다.** 나가는 것을 오래 보고 있을 이유가 없고, 다음 화면이
/// 늦게 오면 눌린 반응이 굼떠 보인다.
const Duration overlayExitDuration = Duration(milliseconds: 340);

/// 배경과 카드가 갈리는 지점.
///
/// **배경이 먼저 깔리고 카드가 나중에 뜬다. 나갈 때는 반대다** — 카드가 먼저
/// 사라지고 배경이 뒤따라 걷힌다. 한꺼번에 사라지면 판이 갑자기 튀어나온다.
const double overlayScrimSplit = 0.45;

/// 배경(스크림)이 짙어지고 옅어지는 구간.
///
/// **배경에는 배율을 걸지 않는다.** 화면 전체를 덮는 것이 줄어들면 덮개가
/// 아니라 또 하나의 카드처럼 보인다.
Animation<double> overlayScrimAnimation(Animation<double> parent) =>
    CurvedAnimation(
      parent: parent,
      curve: const Interval(0, overlayScrimSplit),
      reverseCurve: const Interval(0, overlayScrimSplit),
    );

/// 카드가 뜨고 지는 구간. 배경이 자리를 잡은 뒤에 시작한다.
Animation<double> overlayCardAnimation(Animation<double> parent) =>
    CurvedAnimation(
      parent: parent,
      curve: const Interval(overlayScrimSplit, 1, curve: overlayEnterCurve),
      reverseCurve: const Interval(
        overlayScrimSplit,
        1,
        curve: overlayExitCurve,
      ),
    );

/// 들어올 때의 곡선. 1을 한 번 넘겼다 돌아온다.
const Curve overlayEnterCurve = Curves.elasticOut;

/// 나갈 때의 곡선. 되튕김 없이 깔끔하게 줄어든다.
const Curve overlayExitCurve = Curves.easeIn;

/// 배경(스크림)의 페이드에 붙는 키.
///
/// **타입으로는 찾을 수 없다.** `AnimatedScale` · `AnimatedOpacity` 가 안쪽에서
/// 같은 위젯을 만들어 트리에 열 개 넘게 있다 — 실제로 엉뚱한 것을 잡았다.
const Key overlayScrimKey = Key('overlay-scrim');

/// 카드의 배율에 붙는 키.
const Key overlayCardKey = Key('overlay-card');

/// 카드를 키우는 `Transform` 에 붙는 키.
///
/// 테스트가 이것을 집는다 — 위젯 트리에 `Transform` 이 여럿이라 위치로
/// 찾으면 엉뚱한 것을 잡는다(실제로 그랬다).
const Key overlayScaleKey = Key('overlay-scale');

/// 시작 배율. 1까지 오면서 `elasticOut` 이 한 번 넘겼다 돌아온다.
const double overlayStartScale = 0.82;

/// [t] (0~1) 에서의 카드 배율. [t] 에는 이미 곡선이 적용돼 있다.
double overlayScaleAt(double t) =>
    overlayStartScale + (1 - overlayStartScale) * t;

/// `showGeneralDialog` 가 쓸 등장 연출.
///
/// `OverlayCard` 와 **같은 곡선을 쓰게 하려고** 여기 둔다 — 두 곳에 흩어지면
/// 한쪽만 손댔을 때 등장 방식이 갈린다.
Widget buildOverlayTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, _) => buildOverlayScale(
      animation.value,
      curve: overlayEnterCurve,
      child: child,
    ),
  );
}

/// 판 위에 뜨는 것이 커지고 옅어지는 한 프레임.
///
/// **들어올 때와 나갈 때가 이 함수를 공유한다.** 곡선만 갈린다 — 나눠 두면
/// 한쪽만 손댔을 때 등장과 퇴장이 서로 다른 물건처럼 보인다.
Widget buildOverlayScale(
  double t, {
  required Curve curve,
  required Widget child,
}) {
  final eased = curve.transform(t.clamp(0.0, 1.0));

  return Opacity(
    opacity: t.clamp(0.0, 1.0),
    child: Transform.scale(
      key: overlayScaleKey,
      scale: overlayScaleAt(eased),
      child: child,
    ),
  );
}
