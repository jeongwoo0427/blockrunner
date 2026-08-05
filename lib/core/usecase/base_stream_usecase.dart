import 'dart:async';

/// 상태를 변경하는 usecase 가 결과를 흘려보내기 위한 믹스인.
///
/// 여러 화면이 같은 데이터를 보고 있을 때, 한 화면의 변경을 다른 화면이
/// 즉시 반영하기 위한 수단이다. 관심 있는 Notifier 가 build() 에서
/// NotifierStreamMixin.listenStream 으로 구독한다.
///
/// 예: 플레이 화면에서 레벨을 클리어하면 SaveClearResultUsecase 가 결과를
/// 흘리고, 레벨 선택 화면이 이를 받아 해금·별점을 갱신한다. 화면을 나갔다
/// 들어와야 갱신되는 문제를 없앤다.
abstract mixin class BaseStreamUsecase<R> {
  final _streamController = StreamController<R>.broadcast();

  Stream<R> get stream => _streamController.stream;

  void yieldData(R data) => _streamController.add(data);

  void dispose() => _streamController.close();
}
