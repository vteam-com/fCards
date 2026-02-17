// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'VTeam Cards';

  @override
  String get cardsTitle => 'Cards';

  @override
  String get welcomeTitle => 'VTeam Cards';

  @override
  String get startNewGame => 'Start a New Game';

  @override
  String get joinExistingGame => 'Join an Existing Game';

  @override
  String get scoreKeeper => 'Score Keeper';

  @override
  String get account => 'Account';

  @override
  String get signedIn => 'Signed in';

  @override
  String get playingAsGuest => 'Playing as Guest';

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signingOut => 'Signing out...';

  @override
  String get signOut => 'Sign out';

  @override
  String get googleSignInFailed => 'Google sign-in failed.';

  @override
  String get signOutFailed => 'Sign out failed.';

  @override
  String get startGameWizardTitle => 'Start Game';

  @override
  String get joinGameTitle => 'Join Game';

  @override
  String get cardGamesTitle => 'Card Games';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get startGame => 'Start Game';

  @override
  String get whatTypeOfGame => 'What type of game?';

  @override
  String get pickTableOrCreate => 'Pick a table or create a new one';

  @override
  String get tapExistingTable => 'Tap an existing table to continue';

  @override
  String get noExistingTables =>
      'No existing tables found. Create a new one to continue.';

  @override
  String get createNewTable => 'Create New Table';

  @override
  String get createTableHelp =>
      'Create a table.\nIf it already exists, you can join it.';

  @override
  String get table => 'Table';

  @override
  String get enterTableName =>
      'Enter a table name to check if it already exists.';

  @override
  String get thisTableAlreadyHasPlayers =>
      'This table already has players. You can join it instead of creating a new table.';

  @override
  String get joinThisTable => 'Join This Table';

  @override
  String get whoAreYou => 'Who Are You?\nSelect above ⬆ or join below ⬇';

  @override
  String get join => 'Join';

  @override
  String get pleaseEnterYourName => 'Please enter your name above ⬆';

  @override
  String get waitingForPlayers => 'Waiting for players to join';

  @override
  String get joinGame => 'Join Game';

  @override
  String get gameRules => 'Game Rules';

  @override
  String get selectTableToJoin => 'Select a Table to Join';

  @override
  String get useSearchBox => 'Use the search box to quickly find a table';

  @override
  String joiningTable(String table) {
    return 'Joining Table: $table';
  }

  @override
  String get enterYourName => 'Enter Your Name';

  @override
  String get yourName => 'Your Name';

  @override
  String get joinTable => 'Join Table';

  @override
  String welcomePlayer(String player) {
    return 'Welcome, $player!';
  }

  @override
  String readyToPlayPlayersAtTable(int count) {
    return 'Ready to play! $count players at table.';
  }

  @override
  String get waitingForMorePlayers => 'Waiting for more players to join...';

  @override
  String tableLabel(String table) {
    return 'Table: $table';
  }

  @override
  String get gameOver => 'Game Over';

  @override
  String get players => 'Players';

  @override
  String get gamesWon => 'Games Won';

  @override
  String get thisGame => 'This Game';

  @override
  String get playAgain => 'Play Again';

  @override
  String get exit => 'Exit';

  @override
  String get golfScoreKeeper => '9 Cards Golf Scorekeeper';

  @override
  String get deleteLastRow => 'Delete Last Row';

  @override
  String confirmDeleteRound(int round) {
    return 'Are you sure you want to delete round $round?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get newGame => 'New Game';

  @override
  String get confirmNewGame =>
      'Are you sure you want to start a new game? All scores will be lost.';

  @override
  String rounds(int count) {
    return '$count Rounds';
  }

  @override
  String errorLoadingScores(String error) {
    return 'Error loading scores: $error';
  }

  @override
  String get golf9Cards => '9 Cards';

  @override
  String get skyJo => 'SkyJo';

  @override
  String get miniPut => 'MiniPut';

  @override
  String get golf9CardsFull => 'Golf 9 Cards';

  @override
  String get miniPutFull => 'MiniPut 4 Cards';

  @override
  String get skyLo => 'Skylo';

  @override
  String columnsByRows(int columns, int rows) {
    return '$columns x $rows';
  }

  @override
  String noTablesFoundMatching(String searchText) {
    return 'No tables found matching \"$searchText\"';
  }

  @override
  String get starting => 'Starting';

  @override
  String get gameOverTitle => 'GAME OVER';

  @override
  String get selectAStatus => 'Select a status';

  @override
  String get last => 'LAST';

  @override
  String get done => 'Done';

  @override
  String get addAnotherPlayer => 'Add another player';

  @override
  String get removeThisPlayer => 'Remove this player';

  @override
  String get removePlayer => 'Remove Player';

  @override
  String removePlayerConfirmation(String playerName) {
    return 'Are you sure you want to remove \"$playerName\"?';
  }

  @override
  String get remove => 'Remove';

  @override
  String get noTablesAvailable => 'No tables available';

  @override
  String get noMatchingTables => 'No matching tables';
}
