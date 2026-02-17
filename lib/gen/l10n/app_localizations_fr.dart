// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'VTeam Cards';

  @override
  String get cardsTitle => 'Cards';

  @override
  String get welcomeTitle => 'VTeam Cards';

  @override
  String get startNewGame => 'Démarrer une nouvelle partie';

  @override
  String get joinExistingGame => 'Rejoindre une partie';

  @override
  String get scoreKeeper => 'Carnet de scores';

  @override
  String get account => 'Compte';

  @override
  String get signedIn => 'Connecté';

  @override
  String get playingAsGuest => 'Jouer en invité';

  @override
  String get notSignedIn => 'Non connecté';

  @override
  String get signingIn => 'Connexion...';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get signingOut => 'Déconnexion...';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get googleSignInFailed => 'Échec de la connexion Google.';

  @override
  String get signOutFailed => 'Échec de la déconnexion.';

  @override
  String get startGameWizardTitle => 'Démarrer';

  @override
  String get joinGameTitle => 'Rejoindre';

  @override
  String get cardGamesTitle => 'Jeux de cartes';

  @override
  String get next => 'Suivant';

  @override
  String get back => 'Retour';

  @override
  String get startGame => 'Démarrer la partie';

  @override
  String get whatTypeOfGame => 'Quel type de jeu ?';

  @override
  String get pickTableOrCreate => 'Choisissez une table ou créez-en une';

  @override
  String get tapExistingTable => 'Touchez une table existante pour continuer';

  @override
  String get noExistingTables =>
      'Aucune table trouvée. Créez-en une pour continuer.';

  @override
  String get createNewTable => 'Créer une table';

  @override
  String get createTableHelp =>
      'Créez une table.\nSi elle existe déjà, vous pourrez la rejoindre.';

  @override
  String get table => 'Table';

  @override
  String get enterTableName =>
      'Entrez un nom de table pour vérifier si elle existe.';

  @override
  String get thisTableAlreadyHasPlayers =>
      'Cette table a déjà des joueurs. Vous pouvez la rejoindre au lieu d\'en créer une nouvelle.';

  @override
  String get joinThisTable => 'Rejoindre cette table';

  @override
  String get whoAreYou =>
      'Qui êtes-vous ?\nSélectionnez ci-dessus ⬆ ou rejoignez ci-dessous ⬇';

  @override
  String get join => 'Rejoindre';

  @override
  String get pleaseEnterYourName => 'Veuillez saisir votre nom ci-dessus ⬆';

  @override
  String get waitingForPlayers => 'En attente de joueurs';

  @override
  String get joinGame => 'Rejoindre la partie';

  @override
  String get gameRules => 'Règles du jeu';

  @override
  String get selectTableToJoin => 'Sélectionnez une table';

  @override
  String get useSearchBox =>
      'Utilisez la recherche pour trouver rapidement une table';

  @override
  String joiningTable(String table) {
    return 'Table : $table';
  }

  @override
  String get enterYourName => 'Entrez votre nom';

  @override
  String get yourName => 'Votre nom';

  @override
  String get joinTable => 'Rejoindre la table';

  @override
  String welcomePlayer(String player) {
    return 'Bienvenue, $player !';
  }

  @override
  String readyToPlayPlayersAtTable(int count) {
    return 'Prêt à jouer ! $count joueurs à la table.';
  }

  @override
  String get waitingForMorePlayers => 'En attente d\'autres joueurs...';

  @override
  String tableLabel(String table) {
    return 'Table : $table';
  }

  @override
  String get gameOver => 'Fin de partie';

  @override
  String get players => 'Joueurs';

  @override
  String get gamesWon => 'Parties gagnées';

  @override
  String get thisGame => 'Cette partie';

  @override
  String get playAgain => 'Rejouer';

  @override
  String get exit => 'Quitter';

  @override
  String get golfScoreKeeper => 'Carnet de scores 9 Cartes Golf';

  @override
  String get deleteLastRow => 'Supprimer la dernière ligne';

  @override
  String confirmDeleteRound(int round) {
    return 'Êtes-vous sûr de vouloir supprimer le tour $round ?';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get newGame => 'Nouvelle partie';

  @override
  String get confirmNewGame =>
      'Êtes-vous sûr de vouloir commencer une nouvelle partie ? Tous les scores seront perdus.';

  @override
  String rounds(int count) {
    return '$count Tours';
  }

  @override
  String errorLoadingScores(String error) {
    return 'Erreur lors du chargement des scores : $error';
  }

  @override
  String get golf9Cards => '9 Cartes';

  @override
  String get skyJo => 'SkyJo';

  @override
  String get miniPut => 'MiniPut';

  @override
  String get golf9CardsFull => 'Golf 9 Cartes';

  @override
  String get miniPutFull => 'MiniPut 4 Cartes';

  @override
  String get skyLo => 'Skylo';

  @override
  String columnsByRows(int columns, int rows) {
    return '$columns x $rows';
  }

  @override
  String noTablesFoundMatching(String searchText) {
    return 'Aucune table trouvée pour \"$searchText\"';
  }

  @override
  String get starting => 'Démarrage';

  @override
  String get gameOverTitle => 'FIN DE PARTIE';

  @override
  String get selectAStatus => 'Sélectionnez un statut';

  @override
  String get last => 'DERNIER';

  @override
  String get done => 'Valider';

  @override
  String get addAnotherPlayer => 'Ajouter un autre joueur';

  @override
  String get removeThisPlayer => 'Supprimer ce joueur';

  @override
  String get removePlayer => 'Supprimer le joueur';

  @override
  String removePlayerConfirmation(String playerName) {
    return 'Êtes-vous sûr de vouloir supprimer \"$playerName\" ?';
  }

  @override
  String get remove => 'Supprimer';

  @override
  String get noTablesAvailable => 'Aucune table disponible';

  @override
  String get noMatchingTables => 'Aucune table correspondante';
}
