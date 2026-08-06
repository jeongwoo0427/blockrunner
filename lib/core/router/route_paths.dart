/// 라우트 경로 상수. URL 은 kebab-case, 상수명은 camelCase.
abstract class RoutePaths {
  /// 앱 시작 화면. 잠깐 머물다 레벨 선택으로 넘어간다.
  static const String splash = '/';

  static const String levelSelect = '/level-select';

  /// 플레이 화면. 레벨 번호는 쿼리 파라미터로 넘긴다 — /game-play?level=3
  static const String gamePlay = '/game-play';

  /// gamePlay 의 레벨 번호 쿼리 키
  static const String levelQueryKey = 'level';
}
