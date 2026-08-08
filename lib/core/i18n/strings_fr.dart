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
  String get retryHint => 'Recommencez depuis le début';

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
  String get swipeHint => 'Balayez pour pousser les blocs';

  @override
  String get keyboardHint => 'Flèches ou WASD pour pousser les blocs';

  @override
  Map<int, String> get levelNames => const {
    1: 'Glisser',
    2: 'Deux virages',
    3: 'Compagnon',
    4: 'Cloison',
    5: 'Deux murs',
    6: 'Porte étroite',
    7: 'Bifurcation',
    8: 'Marchepied',
    9: 'Murs seuls',
    10: 'Le puits',
    11: 'Voie étroite',
    12: 'Dernier essai',
    13: 'Trou noir',
    14: 'Un par un',
    15: 'Voie coupée',
    16: 'Dégager la voie',
    17: 'Double abîme',
    18: 'Faire place',
    19: 'Long chemin',
    20: 'Dernière porte',
  };

  @override
  Map<int, String> get levelTutorials => const {
    1:
        "Les blocs glissent jusqu'à un mur ou au bord du plateau.\n"
        'Arrêtez le joueur exactement sur la case objectif pour réussir.',
    3:
        'Une seule commande fait aussi glisser vos blocs compagnons.\n'
        "Ils servent d'appui pour arrêter le joueur.",
    4:
        'Le trait épais entre deux cases est une cloison.\n'
        'Il bloque le passage, mais les deux cases restent utilisables.',
    13:
        'Un trou noir avale tout bloc qui ne fait que le traverser.\n'
        "Surveillez le trajet, pas seulement la case d'arrivée.",
  };
}
