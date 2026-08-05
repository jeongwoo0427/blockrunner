import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream 을 listen 하고, provider 가 dispose 될 때 자동으로 구독을 취소한다.
///
/// BaseStreamUsecase 가 흘리는 변경 알림을 받는 쪽에서 쓴다.
mixin NotifierStreamMixin<T> on Notifier<T> {
  void listenStream<S>(Stream<S> stream, void Function(S) onData) {
    final subscription = stream.listen(onData);
    ref.onDispose(subscription.cancel);
  }
}
