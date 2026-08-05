/// 실패 원인 분류.
///
/// 이 앱에는 서버가 없으므로 네트워크 관련 코드는 존재하지 않는다.
/// (quizlab 과 의도적으로 다른 점 — docs/architecture.md §3)
enum FailureCode {
  /// 분류되지 않은 오류.
  unknown,

  /// 맵 데이터가 규격에 맞지 않는다. 배포 전에 잡혀야 하는 오류다.
  invalidMapData,

  /// 요청한 레벨 메타데이터가 존재하지 않는다.
  levelNotFound,

  /// 레벨 번호에 대응하는 맵이 없다. 두 상수 목록이 어긋났다는 뜻이다.
  mapNotFound,

  /// 로컬 저장소 읽기/쓰기 실패.
  storage,
}
