import 'package:blockrunner/core/i18n/app_strings.dart';

/// 중국어 간체.
///
/// **원어민 검수를 받지 않은 초벌이다** (11-i18n 열린 질문).
/// 번체는 별개 언어로 두지 않고 여기 묶여 있다.
class StringsZh extends AppStrings {
  const StringsZh();

  @override
  String get language => '语言';

  @override
  String get reset => '重来';

  @override
  String get levelSelectTitle => '选择关卡';

  @override
  String get levelListLoadFailed => '无法加载关卡列表。';

  @override
  String get locked => '未解锁';

  @override
  String minMovesLabel(int minMoves) => '最少$minMoves步';

  @override
  String movesLabel(int moves) => '$moves步';

  @override
  String unlockHint(int requiredLevel) => '通关第$requiredLevel关后解锁';

  @override
  String get levelLoadFailed => '无法加载关卡。';

  @override
  String get backToLevelSelect => '返回关卡列表';

  @override
  String get levelFallbackTitle => '关卡';

  @override
  String levelTitle(int number) => '第$number关 · ${levelName(number)}';

  @override
  String hudMinMovesLabel(int minMoves) => '/ 最少$minMoves步';

  @override
  String get cleared => '过关！';

  @override
  String get fellIntoBlackHole => '被黑洞吞噬了';

  @override
  String get retryHint => '从头再来一次吧';

  @override
  String clearedSummary(int moves, int minMoves) => '$moves步 / 最少$minMoves步';

  @override
  String get backToList => '返回列表';

  @override
  String get nextLevel => '下一关';

  @override
  String get start => '开始';

  @override
  String get swipeHint => '滑动来推动方块';

  @override
  String get keyboardHint => '用方向键或 WASD 推动方块';

  @override
  Map<int, String> get levelNames => const {
    1: '滑动',
    2: '靠墙停下',
    3: '借块而停',
    4: '冲过头',
    5: '避开黑洞',
    6: '顺序有别',
    7: '看不见的坎',
  };

  @override
  Map<int, String> get levelTutorials => const {
    1:
        '方块会一直滑到墙壁或棋盘边缘为止。\n'
        '让玩家方块正好停在目标格上即可过关。',
    3:
        '输入一个方向，所有方块会一起滑动。\n'
        '其他方块同样能挡住玩家。',
    5:
        '黑洞只要经过就会吞掉方块。\n'
        '要看的是路线，而不是落点。',
    7:
        '格与格之间的粗线是边界墙。\n'
        '它只挡住通行，两侧的格子都能停。',
  };
}
