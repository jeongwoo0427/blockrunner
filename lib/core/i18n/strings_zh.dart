import 'package:blockrunner/core/i18n/app_strings.dart';

/// 중국어 간체.
///
/// **원어민 검수를 받지 않은 초벌이다** (11-i18n 열린 질문).
/// 번체는 별개 언어로 두지 않고 여기 묶여 있다.
class StringsZh extends AppStrings {
  const StringsZh();

  @override
  String get settings => '设置';

  @override
  String get resetProgress => '重置进度';

  @override
  String get resetProgressWarning =>
      '星星和最佳记录都会消失，且无法撤销。';

  @override
  String get resetProgressDone => '已重置进度';

  @override
  String get cancel => '取消';

  @override
  String get version => '版本';

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
    2: '两次转向',
    3: '方块刹车',
    4: '靠墙停下',
    5: '隐形门槛',
    6: '墙与方块',
    7: '双重墙',
    8: '窄门',
    9: '岔路',
    10: '垫脚',
    11: '只有墙',
    12: '相互咬合',
    13: '深井',
    14: '三者齐聚',
    15: '窄道',
    16: '两块垫脚',
    17: '总复习',
    18: '黑洞',
    19: '逐个丢弃',
    20: '断路',
    21: '清出通路',
    22: '双重深渊',
    23: '腾出通路',
    24: '长路',
    25: '最后关卡',
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
        '格与格之间的粗线是隔断墙。\n'
        '它只挡住通行，两侧的格子都能停。',
    18:
        '黑洞只要经过就会吞掉方块。\n'
        '要看的是路线，而不是落点。',
  };
}
