import 'package:blockrunner/core/i18n/app_strings.dart';

/// 일본어.
///
/// **원어민 검수를 받지 않은 초벌이다** (11-i18n 열린 질문).
class StringsJa extends AppStrings {
  const StringsJa();

  @override
  String get settings => '設定';

  @override
  String get resetProgress => '進行状況をリセット';

  @override
  String get resetProgressWarning =>
      '星と自己ベストがすべて消えます。元に戻せません。';

  @override
  String get resetProgressDone => '進行状況をリセットしました';

  @override
  String get cancel => 'キャンセル';

  @override
  String get version => 'バージョン';

  @override
  String get language => '言語';

  @override
  String get reset => 'やり直す';

  @override
  String get levelSelectTitle => 'レベル選択';

  @override
  String get levelListLoadFailed => 'レベル一覧を読み込めませんでした。';

  @override
  String get locked => 'ロック中';

  @override
  String minMovesLabel(int minMoves) => '最少$minMoves手';

  @override
  String movesLabel(int moves) => '$moves手';

  @override
  String unlockHint(int requiredLevel) => 'レベル$requiredLevelをクリアすると開きます';

  @override
  String get levelLoadFailed => 'レベルを読み込めませんでした。';

  @override
  String get backToLevelSelect => 'レベル選択へ';

  @override
  String get levelFallbackTitle => 'レベル';

  @override
  String levelTitle(int number) => 'レベル$number · ${levelName(number)}';

  @override
  String hudMinMovesLabel(int minMoves) => '/ 最少$minMoves手';

  @override
  String get cleared => 'クリア！';

  @override
  String get fellIntoBlackHole => 'ブラックホールに落ちました';

  @override
  String get retryHint => '最初からやり直しましょう';

  @override
  String clearedSummary(int moves, int minMoves) => '$moves手 / 最少$minMoves手';

  @override
  String get backToList => '一覧へ';

  @override
  String get nextLevel => '次のレベル';

  @override
  String get start => 'はじめる';

  @override
  String get swipeHint => 'スワイプでブロックを動かします';

  @override
  String get keyboardHint => '矢印キーかWASDでブロックを動かします';

  @override
  Map<int, String> get levelNames => const {
    1: 'すべる',
    2: '二回曲がる',
    3: 'ブロック止め',
    4: 'マスの壁',
    5: '境界の壁',
    6: '壁とブロック',
    7: '二種類の壁',
    8: '狭い門',
    9: '分かれ道',
    10: '足場',
    11: '壁だけの道',
    12: 'かみ合う',
    13: '深い通路',
    14: '三つの要素',
    15: '細い道',
    16: '二つの足場',
    17: '最後の練習',
    18: 'ブラックホール',
    19: '一つずつ捨てる',
    20: '途切れた道',
    21: '道を空ける',
    22: '二つの深淵',
    23: '押し出す',
    24: '長い道',
    25: '最後の関門',
  };

  @override
  Map<int, String> get levelTutorials => const {
    1:
        'ブロックは壁か盤の端に当たるまで滑り続けます。\n'
        'プレイヤーをゴールのマスにぴたりと止めればクリアです。',
    3:
        '方向を入力すると、すべてのブロックが一緒に滑ります。\n'
        '他のブロックもプレイヤーを止める壁になります。',
    5:
        'マスとマスの間の太い線が境界の壁です。\n'
        '通行を遮るだけで、両側のマスには止まれます。',
    18:
        'ブラックホールは通り過ぎるだけでブロックを飲み込みます。\n'
        '止まる場所ではなく、通る道を見ましょう。',
  };
}
