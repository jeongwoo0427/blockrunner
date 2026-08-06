import 'package:blockrunner/core/i18n/app_strings.dart';

/// 프랑스어.
///
/// **원어민 검수를 받지 않은 초벌이다** (11-i18n 열린 질문).
/// 영어와 마찬가지로 복수형을 자기 안에서 분기한다.
class StringsFr extends AppStrings {
  const StringsFr();

  @override
  String get settings => 'Réglages';

  @override
  String get resetProgress => 'Réinitialiser la progression';

  @override
  String get resetProgressWarning =>
      'Toutes les étoiles et tous les records seront perdus. Action irréversible.';

  @override
  String get resetProgressDone => 'Progression réinitialisée';

  @override
  String get cancel => 'Annuler';

  @override
  String get version => 'Version';

  @override
  String get language => 'Langue';

  @override
  String get reset => 'Recommencer';

  @override
  String get levelSelectTitle => 'Niveaux';

  @override
  String get levelListLoadFailed => 'Impossible de charger la liste des niveaux.';

  @override
  String get locked => 'Verrouillé';

  @override
  String minMovesLabel(int minMoves) => 'Min $minMoves';

  @override
  String movesLabel(int moves) => moves == 1 ? '1 coup' : '$moves coups';

  @override
  String unlockHint(int requiredLevel) =>
      'Termine le niveau $requiredLevel pour débloquer celui-ci';

  @override
  String get levelLoadFailed => 'Impossible de charger le niveau.';

  @override
  String get backToLevelSelect => 'Retour aux niveaux';

  @override
  String get levelFallbackTitle => 'Niveau';

  @override
  String levelTitle(int number) => 'Niveau $number · ${levelName(number)}';

  @override
  String hudMinMovesLabel(int minMoves) => '/ min $minMoves';

  @override
  String get cleared => 'Réussi !';

  @override
  String get fellIntoBlackHole => 'Aspiré par un trou noir';

  @override
  String get retryHint => 'Recommence depuis le début';

  @override
  String clearedSummary(int moves, int minMoves) =>
      '${movesLabel(moves)} / min $minMoves';

  @override
  String get backToList => 'Niveaux';

  @override
  String get nextLevel => 'Niveau suivant';

  @override
  String get start => 'Commencer';

  @override
  String get swipeHint => 'Balaie pour pousser les blocs';

  @override
  String get keyboardHint => 'Flèches ou WASD pour pousser les blocs';

  @override
  Map<int, String> get levelNames => const {
    1: 'Glisser',
    2: 'Le mur',
    3: 'Bloc-frein',
    4: 'Trop loin',
    5: 'Trou noir',
    6: "Dans l'ordre",
    7: 'Rebord caché',
  };

  @override
  Map<int, String> get levelTutorials => const {
    1:
        "Les blocs glissent jusqu'à un mur ou au bord du plateau.\n"
        'Arrête le joueur exactement sur la case objectif pour réussir.',
    3:
        'Une seule commande fait glisser tous les blocs à la fois.\n'
        'Les autres blocs peuvent aussi arrêter le joueur.',
    5:
        'Un trou noir avale tout bloc qui ne fait que le traverser.\n'
        "Surveille le trajet, pas seulement la case d'arrivée.",
    7:
        'Le trait épais entre deux cases est un mur de bordure.\n'
        'Il bloque le passage, mais les deux cases restent utilisables.',
  };
}
