import 'package:blockrunner/core/i18n/app_strings.dart';

/// 영어.
///
/// 복수형은 여기서 분기한다 — 한국어에는 없는 구분이라 공통 서식으로는
/// 표현할 수 없다. 이것이 문구를 값이 아니라 함수로 둔 이유다.
class StringsEn extends AppStrings {
  const StringsEn();

  @override
  String get settings => 'Settings';

  @override
  String get resetProgress => 'Reset progress';

  @override
  String get resetProgressWarning =>
      'All stars and best scores will be lost. This cannot be undone.';

  @override
  String get resetProgressDone => 'Progress reset';

  @override
  String get cancel => 'Cancel';

  @override
  String get version => 'Version';

  @override
  String get language => 'Language';

  @override
  String get reset => 'Restart';

  @override
  String get levelSelectTitle => 'Levels';

  @override
  String get levelListLoadFailed => 'Could not load the level list.';

  @override
  String get locked => 'Locked';

  @override
  String minMovesLabel(int minMoves) => 'Min $minMoves';

  @override
  String movesLabel(int moves) => moves == 1 ? '1 move' : '$moves moves';

  @override
  String unlockHint(int requiredLevel) =>
      'Clear level $requiredLevel to unlock this one';

  @override
  String get levelLoadFailed => 'Could not load the level.';

  @override
  String get backToLevelSelect => 'Back to levels';

  @override
  String get levelFallbackTitle => 'Level';

  @override
  String levelTitle(int number) => 'Level $number · ${levelName(number)}';

  @override
  String hudMinMovesLabel(int minMoves) => '/ min $minMoves';

  @override
  String get cleared => 'Cleared!';

  @override
  String get fellIntoBlackHole => 'Fell into a black hole';

  @override
  String get retryHint => 'Start over and try again';

  @override
  String clearedSummary(int moves, int minMoves) =>
      '${movesLabel(moves)} / min $minMoves';

  @override
  String get backToList => 'Levels';

  @override
  String get nextLevel => 'Next level';

  @override
  String get start => 'Start';

  @override
  String get swipeHint => 'Swipe to push the blocks';

  @override
  String get keyboardHint => 'Arrow keys or WASD to push the blocks';

  /// **카드 라벨에는 길이 예산이 있다** (10-responsive). 좁은 폰에서 카드
  /// 폭이 120px 안팎까지 줄어드는데, 거기서 두 줄에 들어가야 한다.
  /// 테스트가 잘림을 검사하므로 길게 쓰면 바로 실패한다.
  @override
  Map<int, String> get levelNames => const {
    1: 'Sliding',
    2: 'Two Turns',
    3: 'Block Brake',
    4: 'Hidden Ledge',
    5: 'Double Walls',
    6: 'Narrow Gate',
    7: 'The Fork',
    8: 'Footing',
    9: 'Walls Only',
    10: 'Deep Shaft',
    11: 'Tight Path',
    12: 'Rehearsal',
    13: 'Black Hole',
    14: 'One by One',
    15: 'Severed',
    16: 'Clear the Way',
    17: 'Twin Abyss',
    18: 'Make Room',
    19: 'The Long Way',
    20: 'Last Gate',
  };

  @override
  Map<int, String> get levelTutorials => const {
    1:
        'Blocks slide until they hit a wall or the edge of the board.\n'
        'Stop the player exactly on the goal tile to clear the level.',
    3:
        'One input slides every block at once.\n'
        'Other blocks can bring the player to a stop too.',
    4:
        'The thick line between two tiles is a partition.\n'
        'It blocks passage only — both tiles are still usable.',
    13:
        'A black hole swallows any block that merely passes over it.\n'
        'Watch the path, not just the landing tile.',
  };
}
