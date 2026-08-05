/// 실패 원인 분류.
///
/// 이 앱에는 서버가 없으므로 네트워크 관련 코드는 존재하지 않는다.
/// (quizlab 과 의도적으로 다른 점 — docs/architecture.md §3)
enum FailureCode {
  /// 분류되지 않은 오류.
  unknown,

  /// 레벨 데이터가 규격에 맞지 않는다. 배포 전에 잡혀야 하는 오류다.
  invalidLevelData,

  /// 요청한 레벨이 존재하지 않는다.
  levelNotFound,

  /// 로컬 저장소 읽기/쓰기 실패.
  storage,
}
