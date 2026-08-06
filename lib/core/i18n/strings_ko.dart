import 'package:blockrunner/core/i18n/app_strings.dart';

/// 한국어 — 원본이자 기본 언어.
class StringsKo extends AppStrings {
  const StringsKo();

  @override
  String get settings => '설정';

  @override
  String get resetProgress => '진행도 초기화';

  @override
  String get resetProgressWarning =>
      '별점과 최고 기록이 모두 사라진다. 되돌릴 수 없다.';

  @override
  String get resetProgressDone => '진행도를 초기화했다';

  @override
  String get cancel => '취소';

  @override
  String get version => '버전';

  @override
  String get language => '언어';

  @override
  String get reset => '다시하기';

  @override
  String get levelSelectTitle => '레벨 선택';

  @override
  String get levelListLoadFailed => '레벨 목록을 불러오지 못했다.';

  @override
  String get locked => '잠김';

  @override
  String minMovesLabel(int minMoves) => '최소 $minMoves수';

  @override
  String movesLabel(int moves) => '$moves수';

  @override
  String unlockHint(int requiredLevel) => '$requiredLevel번 레벨을 클리어하면 열린다';

  @override
  String get levelLoadFailed => '레벨을 불러오지 못했다.';

  @override
  String get backToLevelSelect => '레벨 선택으로';

  @override
  String get levelFallbackTitle => '레벨';

  @override
  String levelTitle(int number) => '레벨 $number · ${levelName(number)}';

  @override
  String hudMinMovesLabel(int minMoves) => '/ 최소 $minMoves수';

  @override
  String get cleared => '클리어!';

  @override
  String get fellIntoBlackHole => '블랙홀에 빠졌다';

  @override
  String get retryHint => '처음부터 다시 해보자';

  @override
  String clearedSummary(int moves, int minMoves) => '$moves수 / 최소 $minMoves수';

  @override
  String get backToList => '목록으로';

  @override
  String get nextLevel => '다음 레벨';

  @override
  String get start => '시작';

  @override
  String get swipeHint => '쓸어넘겨 블록을 민다';

  @override
  String get keyboardHint => '방향키나 WASD 로 블록을 민다';

  @override
  Map<int, String> get levelNames => const {
    1: '미끄러지기',
    2: '두 번의 방향',
    3: '블록을 밟고',
    4: '벽에 기대어',
    5: '보이지 않는 턱',
    6: '벽과 블록',
    7: '두 겹의 벽',
    8: '좁은 문',
    9: '갈림길',
    10: '벽만으로',
    11: '맞물리다',
    12: '셋이 모이다',
    13: '좁은 길',
    14: '마지막 준비',
    15: '블랙홀',
    16: '끊어진 길',
    17: '길을 치우다',
    18: '두 개의 심연',
    19: '먼 길',
    20: '마지막 관문',
  };

  @override
  Map<int, String> get levelTutorials => const {
    1:
        '블록은 벽이나 판 끝에 닿을 때까지 미끄러진다.\n'
        '플레이어를 목표 칸에 정확히 멈춰 세우면 클리어다.',
    3:
        '방향을 입력하면 모든 블록이 함께 미끄러진다.\n'
        '다른 블록도 플레이어를 멈춰 세우는 브레이크가 된다.',
    5:
        '칸 사이의 굵은 선은 경계 벽이다.\n'
        '통행만 막을 뿐, 벽 양쪽 칸에는 모두 설 수 있다.',
    15:
        '블랙홀은 지나가기만 해도 블록을 삼킨다.\n'
        '멈추는 자리가 아니라 지나는 길을 살펴야 한다.',
  };
}
