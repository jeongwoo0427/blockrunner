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
      '星と自己ベストがすべて消える。元に戻せない。';

  @override
  String get resetProgressDone => '進行状況をリセットした';

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
  String get levelListLoadFailed => 'レベル一覧を読み込めなかった。';

  @override
  String get locked => 'ロック中';

  @override
  String minMovesLabel(int minMoves) => '最少$minMoves手';

  @override
  String movesLabel(int moves) => '$moves手';

  @override
  String unlockHint(int requiredLevel) => 'レベル$requiredLevelをクリアすると開く';

  @override
  String get levelLoadFailed => 'レベルを読み込めなかった。';

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
  String get fellIntoBlackHole => 'ブラックホールに落ちた';

  @override
  String get retryHint => '最初からやり直そう';

  @override
  String clearedSummary(int moves, int minMoves) => '$moves手 / 最少$minMoves手';

  @override
  String get backToList => '一覧へ';

  @override
  String get nextLevel => '次のレベル';

  @override
  String get start => 'はじめる';

  @override
  String get swipeHint => 'スワイプでブロックを動かす';

  @override
  String get keyboardHint => '矢印キーかWASDでブロックを動かす';

  @override
  Map<int, String> get levelNames => const {
    1: 'すべる',
    2: '二度の方向',
    3: 'ブロック止め',
    4: '壁に寄せて',
    5: '見えない段差',
    6: '壁とブロック',
    7: '二重の壁',
    8: '狭い門',
    9: '分かれ道',
    10: '壁だけで',
    11: 'かみ合う',
    12: '三つの要素',
    13: '細い道',
    14: '総仕上げ',
    15: 'ブラックホール',
    16: '途切れた道',
    17: '道を空ける',
    18: '二つの深淵',
    19: '長い道',
    20: '最後の関門',
  };

  @override
  Map<int, String> get levelTutorials => const {
    1:
        'ブロックは壁か盤の端に当たるまで滑り続ける。\n'
        'プレイヤーをゴールのマスにぴたりと止めればクリアだ。',
    3:
        '方向を入力すると、すべてのブロックが一緒に滑る。\n'
        '他のブロックもプレイヤーを止める壁になる。',
    5:
        'マスとマスの間の太い線は境界壁だ。\n'
        '通行を遮るだけで、両側のマスには止まれる。',
    15:
        'ブラックホールは通り過ぎるだけでブロックを飲み込む。\n'
        '止まる場所ではなく、通る道を見よう。',
  };
}
