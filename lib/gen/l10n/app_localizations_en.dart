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
  String cardCountTooltip(int count) {
    return '$count\\ncards';
  }

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
  String get skyjo => 'Skyjo';

  @override
  String get miniPut => 'MiniPut';

  @override
  String get golf9CardsFull => 'Golf 9 Cards';

  @override
  String get miniPutFull => 'MiniPut 4 Cards';

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
  String get noOne => 'No one';

  @override
  String get notYourTurn => 'It\'s not your turn!';

  @override
  String get noCardsAvailableToDraw => 'No cards available to draw!';

  @override
  String get waitYourTurn => 'Wait your turn!';

  @override
  String get notAllowed => 'Not allowed!';

  @override
  String itsYourTurn(String player) {
    return 'It\'s your turn $player';
  }

  @override
  String itsPlayersTurn(String player) {
    return 'It\'s $player\'s turn';
  }

  @override
  String finalRoundYouHaveToBeat(String turnText, String attacker) {
    return 'Final Round. $turnText. You have to beat $attacker';
  }

  @override
  String get youAreDone => 'You are done.';

  @override
  String get waitForYourTurnSmiley => 'Wait for your turn :)';

  @override
  String get flipOpenOneHiddenCard => '↓ Flip open one of your hidden cards ↓';

  @override
  String get drawCardHere => 'Draw\na card\nhere\n→';

  @override
  String get orHereLeft => '\nor\nhere\n←';

  @override
  String get swapThisWith => 'swap this →\n\nwith ↓';

  @override
  String get discardOrSwap => 'Discard →\nor\n↓ swap';

  @override
  String get statusFeelingGood => 'Feeling Good!';

  @override
  String get statusBrb => 'BRB';

  @override
  String get statusThinking => 'Thinking...';

  @override
  String get statusVoila => 'Voila!';

  @override
  String get statusOhNo => 'Oh NO!';

  @override
  String nameForPlayerNumber(int number) {
    return 'Name for Player #$number';
  }

  @override
  String get playerName => 'Player Name';

  @override
  String get youIndicator => 'YOU>';

  @override
  String playerWonTimesAtTable(String player, int count, String table) {
    return '$player won $count times at table $table';
  }

  @override
  String get instructionsFrenchCards9 =>
      '- Aim for the lowest score.\n- Choose a card from either the Deck or Discard pile.\n- Swap the chosen card with a card in your 3x3 grid, or discard it and flip over one of your face-down cards.\n- Three cards of the same rank in a row or column score zero.\n- The first player to reveal all nine cards challenges others, claiming the lowest score.\n- If someone else has an equal or lower score, the challenger doubles their points!\n- Players are eliminated after busting 100 points.\n\n\nLearn more [Wikipedia](https://en.wikipedia.org/wiki/Golf_(card_game))';

  @override
  String get instructionsSkyjo =>
      '- Aim for the lowest score.\n- Choose a card from either the Deck or Discard pile.\n- Swap the chosen card with a card in your 4x3 grid, or discard it and flip over one of your face-down cards.\n- When 3 cards of the same rank are lined up in a column they are moved to the discard pile.\n- The first player to reveal all their cards challenges others, claiming the lowest score.\n\n\nLearn more [Skyjo](https://www.geekyhobbies.com/how-to-play-skyjo-card-game-rules-and-instructions/)';

  @override
  String get instructionsMiniPut =>
      '- Aim for the lowest score.\n- Choose a card from either the Deck or Discard pile.\n- Swap the chosen card with a card in your 2x2 grid, or discard it and flip over one of your face-down cards.\n- Three cards of the same rank in a row or column score zero.\n- The first player to reveal all nine cards challenges others, claiming the lowest score.\n- If someone else has an equal or lower score, the challenger doubles their points!\n- Players are eliminated after busting 100 points.\n\n\nLearn more [Wikipedia](https://en.wikipedia.org/wiki/Golf_(card_game))';

  @override
  String get instructionsCustom => 'Custom rules';

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
