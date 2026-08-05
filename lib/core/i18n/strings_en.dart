import 'package:blockrunner/core/i18n/app_strings.dart';

/// 영어.
///
/// 복수형은 여기서 분기한다 — 한국어에는 없는 구분이라 공통 서식으로는
/// 표현할 수 없다. 이것이 문구를 값이 아니라 함수로 둔 이유다.
class StringsEn extends AppStrings {
  const StringsEn();

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
  String get fellIntoHole => 'Fell into a hole';

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

  @override
  Map<int, String> get levelNames => const {
    1: 'Sliding',
    2: 'Against the Wall',
    3: 'Block by Block',
    4: 'Overshoot',
    5: 'Mind the Hole',
    6: 'Order Matters',
    7: 'The Invisible Ledge',
  };

  @override
  Map<int, String> get levelTutorials => const {
    1:
        'Blocks slide until they hit a wall or the edge of the board.\n'
        'Stop the player exactly on the goal tile to clear the level.',
    3:
        'One input slides every block at once.\n'
        'Other blocks can bring the player to a stop too.',
    5:
        'A hole swallows any block that merely passes over it.\n'
        'Watch the path, not just the landing tile.',
    7:
        'The thick line between two tiles is an edge wall.\n'
        'It blocks passage only — both tiles are still usable.',
  };
}
