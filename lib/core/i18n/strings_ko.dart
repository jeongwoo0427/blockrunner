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
      '별점과 최고 기록이 모두 사라집니다. 되돌릴 수 없습니다.';

  @override
  String get resetProgressDone => '진행도를 초기화했습니다';

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
  String get levelListLoadFailed => '레벨 목록을 불러오지 못했습니다.';

  @override
  String get locked => '잠김';

  @override
  String minMovesLabel(int minMoves) => '최소 $minMoves수';

  @override
  String movesLabel(int moves) => '$moves수';

  @override
  String unlockHint(int requiredLevel) => '$requiredLevel번 레벨을 클리어하면 열립니다';

  @override
  String get levelLoadFailed => '레벨을 불러오지 못했습니다.';

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
  String get fellIntoBlackHole => '블랙홀에 빠졌습니다';

  @override
  String get retryHint => '처음부터 다시 해보세요';

  @override
  String clearedSummary(int moves, int minMoves) => '$moves수 / 최소 $minMoves수';

  @override
  String get backToList => '목록으로';

  @override
  String get nextLevel => '다음 레벨';

  @override
  String get start => '시작';

  @override
  String get swipeHint => '쓸어넘겨 블록을 미세요';

  @override
  String get keyboardHint => '방향키나 WASD 로 블록을 미세요';

  @override
  Map<int, String> get levelNames => const {
    1: '미끄러지기',
    2: '두 번 꺾기',
    3: '블록 브레이크',
    4: '칸 벽',
    5: '경계 벽',
    6: '벽과 블록',
    7: '두 가지 벽',
    8: '좁은 문',
    9: '갈림길',
    10: '발판',
    11: '벽뿐인 길',
    12: '맞물린 블록',
    13: '깊은 통로',
    14: '세 가지 요소',
    15: '좁은 길',
    16: '통로와 동료',
    17: '마지막 연습',
    18: '블랙홀',
    19: '하나씩 버리기',
    20: '끊어진 길',
    21: '길 치우기',
    22: '두 개의 심연',
    23: '길을 비우다',
    24: '먼 길',
    25: '마지막 관문',
  };

  @override
  Map<int, String> get levelTutorials => const {
    1:
        '블록은 벽이나 판 끝에 닿을 때까지 미끄러집니다.\n'
        '플레이어를 목표 칸에 정확히 멈춰 세우면 클리어입니다.',
    3:
        '방향을 입력하면 모든 블록이 함께 미끄러집니다.\n'
        '다른 블록도 플레이어를 멈춰 세우는 브레이크가 됩니다.',
    5:
        '칸 사이의 굵은 선이 경계 벽입니다.\n'
        '통행만 막을 뿐, 벽 양쪽 칸에는 모두 설 수 있습니다.',
    18:
        '블랙홀은 지나가기만 해도 블록을 삼킵니다.\n'
        '멈추는 자리가 아니라 지나는 길을 살펴야 합니다.',
  };
}
