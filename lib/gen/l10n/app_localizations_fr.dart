// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get account => 'Compte';

  @override
  String get addAnotherPlayer => 'Ajouter un autre joueur';

  @override
  String get appTitle => 'VTeam Cards';

  @override
  String get back => 'Retour';

  @override
  String get cancel => 'Annuler';

  @override
  String cardCountTooltip(int count) {
    return '$count\ncartes';
  }

  @override
  String get cardGamesTitle => 'Jeux de cartes';

  @override
  String get cardsTitle => 'Cards';

  @override
  String columnsByRows(int columns, int rows) {
    return '$columns x $rows';
  }

  @override
  String get confirm => 'Confirmer';

  @override
  String confirmDeleteRound(int round) {
    return 'Êtes-vous sûr de vouloir supprimer le tour $round ?';
  }

  @override
  String get confirmNewGame =>
      'Êtes-vous sûr de vouloir commencer une nouvelle partie ? Tous les scores seront perdus.';

  @override
  String get createNewTable => 'Créer une table';

  @override
  String get deleteLastRow => 'Supprimer la dernière ligne';

  @override
  String get discardOrSwap => 'Défausser →\nou\n↓ échanger';

  @override
  String get done => 'Valider';

  @override
  String get drawCardHere => 'Piochez\nune carte\nici\n→';

  @override
  String get enterTableName => 'Entrez le nom de la nouvelle table.';

  @override
  String get enterYourName => 'Entrez votre nom';

  @override
  String errorLoadingScores(String error) {
    return 'Erreur lors du chargement des scores : $error';
  }

  @override
  String get exit => 'Quitter';

  @override
  String finalRoundYouHaveToBeat(String turnText, String attacker) {
    return 'Dernier tour. $turnText. Vous devez battre $attacker';
  }

  @override
  String get flipOpenOneHiddenCard => '↓ Retournez une de vos cartes cachées ↓';

  @override
  String get gameOver => 'Fin de partie';

  @override
  String get gameOverTitle => 'FIN DE PARTIE';

  @override
  String get gameRules => 'Règles du jeu';

  @override
  String get gamesWon => 'Parties gagnées';

  @override
  String get golf9Cards => '9 Cartes';

  @override
  String get golf9CardsFull => 'Golf 9 Cartes';

  @override
  String get golfScoreKeeper => 'Carnet de scores 9 Cartes Golf';

  @override
  String get googleSignInFailed => 'Échec de la connexion Google.';

  @override
  String get instructionsCustom => 'Règles personnalisées';

  @override
  String get instructionsFrenchCards9 =>
      '- Visez le score le plus bas.\n- Choisissez une carte depuis le paquet ou la défausse.\n- Échangez la carte choisie avec une carte de votre grille 3x3, ou défaussez-la et retournez une de vos cartes cachées.\n- Trois cartes de même rang sur une ligne ou une colonne valent zéro.\n- Le premier joueur à révéler ses neuf cartes défie les autres et revendique le meilleur score.\n- Si quelqu\'un obtient un score égal ou inférieur, le challenger double ses points !\n- Les joueurs sont éliminés après 100 points.\n\n\nEn savoir plus [Wikipedia](https://en.wikipedia.org/wiki/Golf_(card_game))';

  @override
  String get instructionsMiniPut =>
      '- Visez le score le plus bas.\n- Choisissez une carte depuis le paquet ou la défausse.\n- Échangez la carte choisie avec une carte de votre grille 2x2, ou défaussez-la et retournez une de vos cartes cachées.\n- Trois cartes de même rang sur une ligne ou une colonne valent zéro.\n- Le premier joueur à révéler ses cartes défie les autres et revendique le meilleur score.\n- Si quelqu\'un obtient un score égal ou inférieur, le challenger double ses points !\n- Les joueurs sont éliminés après 100 points.\n\n\nEn savoir plus [Wikipedia](https://en.wikipedia.org/wiki/Golf_(card_game))';

  @override
  String get instructionsSkyjo =>
      '- Visez le score le plus bas.\n- Choisissez une carte depuis le paquet ou la défausse.\n- Échangez la carte choisie avec une carte de votre grille 4x3, ou défaussez-la et retournez une de vos cartes cachées.\n- Quand 3 cartes de même rang sont alignées dans une colonne, elles sont déplacées vers la défausse.\n- Le premier joueur à révéler toutes ses cartes défie les autres et revendique le meilleur score.\n\n\nEn savoir plus [Skyjo](https://www.geekyhobbies.com/how-to-play-skyjo-card-game-rules-and-instructions/)';

  @override
  String itsPlayersTurn(String player) {
    return 'C\'est au tour de $player';
  }

  @override
  String itsYourTurn(String player) {
    return 'C\'est à vous, $player';
  }

  @override
  String get join => 'Rejoindre';

  @override
  String get joinExistingGame => 'Rejoindre une partie';

  @override
  String get joinGame => 'Rejoindre la partie';

  @override
  String get joinGameTitle => 'Rejoindre';

  @override
  String joiningTable(String table) {
    return 'Table : $table';
  }

  @override
  String get joinTable => 'Rejoindre la table';

  @override
  String get joinThisTable => 'Rejoindre cette table';

  @override
  String get last => 'DERNIER';

  @override
  String get miniPut => 'MiniPut';

  @override
  String get miniPutFull => 'MiniPut 4 Cartes';

  @override
  String nameForPlayerNumber(int number) {
    return 'Nom du joueur n°$number';
  }

  @override
  String get newGame => 'Nouvelle partie';

  @override
  String get next => 'Suivant';

  @override
  String get noCardsAvailableToDraw => 'Aucune carte disponible à piocher !';

  @override
  String get noExistingTables =>
      'Aucune table trouvée. Créez-en une pour continuer.';

  @override
  String get noMatchingTables => 'Aucune table correspondante';

  @override
  String get noOne => 'Personne';

  @override
  String get noTablesAvailable => 'Aucune table disponible';

  @override
  String noTablesFoundMatching(String searchText) {
    return 'Aucune table trouvée pour \"$searchText\"';
  }

  @override
  String get notAllowed => 'Action non autorisée !';

  @override
  String get notSignedIn => 'Non connecté';

  @override
  String get notYourTurn => 'Ce n\'est pas votre tour !';

  @override
  String get orHereLeft => '\nou\nici\n←';

  @override
  String get pickTableOrCreate => 'Choisissez une table ou créez-en une';

  @override
  String get playAgain => 'Rejouer';

  @override
  String get playerName => 'Nom du joueur';

  @override
  String get players => 'Joueurs';

  @override
  String playerWonTimesAtTable(String player, int count, String table) {
    return '$player a gagné $count fois à la table $table';
  }

  @override
  String get playingAsGuest => 'Jouer en invité';

  @override
  String get pleaseEnterYourName => 'Veuillez saisir votre nom ci-dessus ⬆';

  @override
  String readyToPlayPlayersAtTable(int count) {
    return 'Prêt à jouer ! $count joueurs à la table.';
  }

  @override
  String get remove => 'Supprimer';

  @override
  String get removePlayer => 'Supprimer le joueur';

  @override
  String removePlayerConfirmation(String playerName) {
    return 'Êtes-vous sûr de vouloir supprimer \"$playerName\" ?';
  }

  @override
  String get removeThisPlayer => 'Supprimer ce joueur';

  @override
  String rounds(int count) {
    return '$count Tours';
  }

  @override
  String get scoreKeeper => 'Carnet de scores';

  @override
  String get selectAStatus => 'Sélectionnez un statut';

  @override
  String get selectTableToJoin => 'Sélectionnez une table';

  @override
  String get signedIn => 'Connecté';

  @override
  String get signingIn => 'Connexion...';

  @override
  String get signingOut => 'Déconnexion...';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signOutFailed => 'Échec de la déconnexion.';

  @override
  String get skyjo => 'Skyjo';

  @override
  String get startGame => 'Démarrer la partie';

  @override
  String get startGameWizardTitle => 'Démarrer';

  @override
  String get starting => 'Démarrage';

  @override
  String get startNewGame => 'Démarrer une nouvelle partie';

  @override
  String get statusBrb => 'Reviens vite';

  @override
  String get statusFeelingGood => 'Ça va !';

  @override
  String get statusOhNo => 'Oh non !';

  @override
  String get statusThinking => 'Je réfléchis...';

  @override
  String get statusVoila => 'Voilà !';

  @override
  String get swapThisWith => 'échanger ceci →\n\navec ↓';

  @override
  String get table => 'Table';

  @override
  String tableLabel(String table) {
    return 'Table : $table';
  }

  @override
  String get tapExistingTable => 'Touchez une table existante pour continuer';

  @override
  String get thisGame => 'Cette partie';

  @override
  String get thisTableAlreadyHasPlayers =>
      'Cette table existe déjà. Rejoignez cette table ou entrez un autre nom.';

  @override
  String get useSearchBox =>
      'Utilisez la recherche pour trouver rapidement une table';

  @override
  String get waitForYourTurnSmiley => 'Attendez votre tour :)';

  @override
  String get waitingForMorePlayers => 'En attente d\'autres joueurs...';

  @override
  String get waitingForPlayers => 'En attente de joueurs';

  @override
  String get waitYourTurn => 'Attendez votre tour !';

  @override
  String welcomePlayer(String player) {
    return 'Bienvenue, $player !';
  }

  @override
  String get whatTypeOfGame => 'Quel type de jeu ?';

  @override
  String get whoAreYou =>
      'Qui êtes-vous ?\nSélectionnez ci-dessus ⬆ ou rejoignez ci-dessous ⬇';

  @override
  String get youAreDone => 'Vous avez terminé.';

  @override
  String get youIndicator => 'VOUS>';

  @override
  String get yourName => 'Votre nom';
}
