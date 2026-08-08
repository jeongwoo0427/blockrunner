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
    3: '仲間ブロック',
    4: '境界の壁',
    5: '二種類の壁',
    6: '狭い門',
    7: '分かれ道',
    8: '足場',
    9: '壁だけの道',
    10: '深い通路',
    11: '細い道',
    12: '最後の練習',
    13: 'ブラックホール',
    14: '一つずつ捨てる',
    15: '途切れた道',
    16: '道を空ける',
    17: '二つの深淵',
    18: '押し出す',
    19: '長い道',
    20: '最後の関門',
  };

  @override
  Map<int, String> get levelTutorials => const {
    1:
        'ブロックは壁か盤の端に当たるまで滑り続けます。\n'
        'プレイヤーをゴールのマスにぴたりと止めればクリアです。',
    3:
        '方向を入力すると、仲間ブロックも一緒に滑ります。\n'
        '仲間ブロックは足場になってプレイヤーを止めます。',
    4:
        'マスとマスの間の太い線が境界の壁です。\n'
        '通行を遮るだけで、両側のマスには止まれます。',
    13:
        'ブラックホールは通り過ぎるだけでブロックを飲み込みます。\n'
        '止まる場所ではなく、通る道を見ましょう。',
  };
}
