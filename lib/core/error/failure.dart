import 'package:blockrunner/core/error/failure_code.dart';

/// 앱 전역 실패 타입.
///
/// Either/Result 래퍼를 쓰지 않는다. 계층은 그냥 throw 하고
/// Notifier 가 try/catch 로 받아 state 에 담는다. (docs/architecture.md §8)
abstract class Failure implements Exception {
  final FailureCode code;
  final Object? originalError;
  final StackTrace stackTrace;

  /// 사용자에게 보여주지 않는 개발자용 설명.
  final String? debugMessage;

  const Failure({
    required this.code,
    required this.stackTrace,
    this.originalError,
    this.debugMessage,
  });

  /// 임의의 에러를 Failure 로 변환한다.
  ///
  /// quizlab 은 Dio → 소셜로그인 → 클라이언트 순의 매퍼 체인을 두지만
  /// 이 앱에는 네트워크가 없어 클라이언트 실패만 존재한다.
  static Failure fromError(Object error, StackTrace stackTrace) {
    if (error is Failure) return error;
    return ClientFailure(
      code: FailureCode.unknown,
      originalError: error,
      stackTrace: stackTrace,
      debugMessage: error.toString(),
    );
  }

  @override
  String toString() =>
      'Failure(code: $code, debugMessage: $debugMessage, originalError: $originalError)';
}

/// 클라이언트 내부에서 발생한 실패.
class ClientFailure extends Failure {
  const ClientFailure({
    required super.code,
    required super.stackTrace,
    super.originalError,
    super.debugMessage,
  });
}
