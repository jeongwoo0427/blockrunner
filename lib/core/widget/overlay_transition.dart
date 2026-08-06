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
const Duration overlayEntranceDuration = Duration(milliseconds: 420);

/// 카드를 키우는 `Transform` 에 붙는 키.
///
/// 테스트가 이것을 집는다 — 위젯 트리에 `Transform` 이 여럿이라 위치로
/// 찾으면 엉뚱한 것을 잡는다(실제로 그랬다).
const Key overlayScaleKey = Key('overlay-scale');

/// 시작 배율. 1까지 오면서 `elasticOut` 이 한 번 넘겼다 돌아온다.
const double _overlayStartScale = 0.82;

/// [t] (0~1) 에서의 카드 배율.
double overlayScaleAt(double t) =>
    _overlayStartScale +
    (1 - _overlayStartScale) * Curves.elasticOut.transform(t);

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
    builder: (context, _) => Opacity(
      opacity: animation.value.clamp(0.0, 1.0),
      child: Transform.scale(
        key: overlayScaleKey,
        scale: overlayScaleAt(animation.value),
        child: child,
      ),
    ),
  );
}
