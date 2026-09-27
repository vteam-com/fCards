// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get account => 'Account';

  @override
  String get addAnotherPlayer => 'Add another player';

  @override
  String get appleSignInFailed => 'Apple sign-in failed.';

  @override
  String get apply => 'Apply';

  @override
  String get appTitle => 'VTeam Cards';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String cardCountTooltip(int count) {
    return '$count\\ncards';
  }

  @override
  String get cardsTitle => 'Cards';

  @override
  String get changePlayMode => 'Change how you play';

  @override
  String get chooseTableHint =>
      'Reopen a table to play with the same group, or start a new one.';

  @override
  String get chooseTableTitle => 'Where are you playing?';

  @override
  String get clearScores => 'Clear scores';

  @override
  String get closeGame => 'Close Game';

  @override
  String get closeGameHint =>
      'The winner is saved to the leaderboard and a new game starts.';

  @override
  String get closeGameNeedsScores =>
      'Enter scores for at least 2 players before closing the game.';

  @override
  String get closeGamePickWinner =>
      'Tied for the lowest score. Tap the winner.';

  @override
  String get closeGameTitle => 'Close this game?';

  @override
  String columnsByRows(int columns, int rows) {
    return '$columns x $rows';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String confirmDeleteRound(int round) {
    return 'Are you sure you want to delete round $round?';
  }

  @override
  String get confirmNewGame =>
      'Are you sure you want to start a new game? All scores will be lost.';

  @override
  String get continueSheet => 'Continue Current Sheet';

  @override
  String get corrections => 'Corrections';

  @override
  String get correctionsAll => 'All';

  @override
  String get correctionsApprove => 'Approve';

  @override
  String get correctionsApproved => 'Approved';

  @override
  String get correctionsBackendRequired =>
      'Corrections review requires backend connectivity.';

  @override
  String get correctionsCorrectedValue => 'Corrected value';

  @override
  String get correctionsDecisionSaved => 'Review decision saved';

  @override
  String get correctionsDetectedValue => 'Detected value';

  @override
  String get correctionsNoApproved => 'No approved corrections found.';

  @override
  String get correctionsNoData => 'No corrections found.';

  @override
  String get correctionsNoPending => 'No pending corrections to review.';

  @override
  String get correctionsNoRejected => 'No rejected corrections found.';

  @override
  String get correctionsPending => 'Pending';

  @override
  String get correctionsReject => 'Reject';

  @override
  String get correctionsRejected => 'Rejected';

  @override
  String get correctionsReviewerOnly =>
      'Only users in the reviewer group can access this screen.';

  @override
  String get correctionsReviewStatus => 'Review status';

  @override
  String get correctionsSubmittedAt => 'Submitted';

  @override
  String get correctionsSubmittedBy => 'Submitted by';

  @override
  String get correctionsTitle => 'Training Corrections';

  @override
  String get correctionsWebOnly =>
      'Corrections review is currently available on web.';

  @override
  String get deleteLastRow => 'Delete Last Row';

  @override
  String get discardOrSwap => 'Discard →\nor\n↓ swap';

  @override
  String get done => 'Done';

  @override
  String get drawCardHere => 'Draw\na card\nhere\n→';

  @override
  String get editInitials => 'Edit initials';

  @override
  String get editPlayers => 'Edit players';

  @override
  String get email => 'Email';

  @override
  String errorLoadingScores(String error) {
    return 'Error loading scores: $error';
  }

  @override
  String get exit => 'Exit';

  @override
  String finalRoundYouHaveToBeat(String turnText, String attacker) {
    return 'Final Round. $turnText. You have to beat $attacker';
  }

  @override
  String get findTableByName => 'Find a table by name';

  @override
  String get firebaseId => 'Firebase ID';

  @override
  String get flipOpenOneHiddenCard => '↓ Flip open one of your hidden cards ↓';

  @override
  String get fullName => 'Full Name';

  @override
  String get gameClosed => 'Game Closed';

  @override
  String gameClosedWinner(String name) {
    return '$name wins!';
  }

  @override
  String get gameOver => 'Game Over';

  @override
  String get gameOverTitle => 'GAME OVER';

  @override
  String get gameRules => 'Game Rules';

  @override
  String get gamesWon => 'Games Won';

  @override
  String get golf9Cards => '9 Cards';

  @override
  String get golf9CardsFull => 'Golf 9 Cards';

  @override
  String get googleSignInFailed => 'Google sign-in failed.';

  @override
  String get identityChangeableLater => 'You can change this later';

  @override
  String get identityFirstSubtitle => 'Others see this name at the table.';

  @override
  String get identityFirstTitle => 'Who are you?';

  @override
  String get identityHostHint => 'You\'re the host.';

  @override
  String get identityJoinHint => 'You have a link or table name.';

  @override
  String get identitySignInWithApple => 'Sign in with Apple';

  @override
  String get identitySignInWithGoogle => 'Sign in with Google';

  @override
  String get info => 'Info';

  @override
  String get instructionsFrenchCards9 =>
      '- Aim for the lowest score.\n- Choose a card from either the Deck or Discard pile.\n- Swap the chosen card with a card in your 3x3 grid, or discard it and flip over one of your face-down cards.\n- Three cards of the same rank in a row or column score zero.\n- The first player to reveal all nine cards challenges others, claiming the lowest score.\n- If someone else has an equal or lower score, the challenger doubles their points!\n- Players are eliminated after busting 100 points.\n\n\nLearn more [Wikipedia](https://en.wikipedia.org/wiki/Golf_(card_game))';

  @override
  String get instructionsSkyjo =>
      '- Aim for the lowest score.\n- Choose a card from either the Deck or Discard pile.\n- Swap the chosen card with a card in your 4x3 grid, or discard it and flip over one of your face-down cards.\n- When 3 cards of the same rank are lined up in a column they are moved to the discard pile.\n- The first player to reveal all their cards challenges others, claiming the lowest score.\n\n\nLearn more [Skyjo](https://www.geekyhobbies.com/how-to-play-skyjo-card-game-rules-and-instructions/)';

  @override
  String get invitePlayerWithQr => 'Invite a player with QR';

  @override
  String itsPlayersTurn(String player) {
    return 'It\'s $player\'s turn';
  }

  @override
  String itsYourTurn(String player) {
    return 'It\'s your turn $player';
  }

  @override
  String get join => 'Join';

  @override
  String get joinExistingGame => 'Join a Game';

  @override
  String get joinGameTitle => 'Join Game';

  @override
  String get joinScoreSheet => 'Join a Score Sheet';

  @override
  String get joinScoreSheetHint => 'Scan the QR code or enter the table name';

  @override
  String get joinScoreSheetPrompt =>
      'Scan the host\'s QR code with your camera, or enter the table name shown on their score sheet.';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => '🇬🇧\nEN';

  @override
  String get languageFrench => '🇫🇷\nFR';

  @override
  String get languagePortuguesePortugal => '🇵🇹\nPT';

  @override
  String get languageSpanish => '🇪🇸\nES';

  @override
  String get last => 'LAST';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String leaderboardAverage(String score) {
    return 'Avg $score';
  }

  @override
  String leaderboardBest(int score) {
    return 'Best $score';
  }

  @override
  String get leaderboardChooseTable => 'Choose a Table';

  @override
  String get leaderboardEmpty =>
      'No games recorded yet. Finish a game to get on the board.';

  @override
  String leaderboardGamesPlayed(int count) {
    return '$count played';
  }

  @override
  String get leaderboardGlobal => 'Global';

  @override
  String get leaderboardHint => 'See who wins the most';

  @override
  String get leaderboardMyStats => 'My Stats';

  @override
  String get leaderboardNoStats => 'Finish a game to start your stats.';

  @override
  String get leaderboardNoTables =>
      'Your tables show up here after you finish a game.';

  @override
  String leaderboardRank(int rank) {
    return 'Rank #$rank';
  }

  @override
  String get leaderboardTables => 'My Tables';

  @override
  String leaderboardWinRate(int percent) {
    return '$percent% won';
  }

  @override
  String get leaderboardWins => 'Wins';

  @override
  String get lobbyAddPlayer => 'Add a player';

  @override
  String get newGame => 'New Game';

  @override
  String get newTable => 'New Table';

  @override
  String get newTableForThisGroup =>
      'New table for this group. Its name is yours to change.';

  @override
  String get next => 'Next';

  @override
  String get noCardsAvailableToDraw => 'No cards available to draw!';

  @override
  String get noOne => 'No one';

  @override
  String get noOpenTables => 'No open tables right now.';

  @override
  String get noTablesYet => 'You have no tables for this game yet.';

  @override
  String get notAllowed => 'Not allowed!';

  @override
  String get notYourTurn => 'It\'s not your turn!';

  @override
  String get orHereLeft => '\nor\nhere\n←';

  @override
  String get playAgain => 'Play Again';

  @override
  String get player => 'Player';

  @override
  String playerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players',
      one: '1 player',
    );
    return '$_temp0';
  }

  @override
  String get playerName => 'Player Initials';

  @override
  String get players => 'Players';

  @override
  String playerWonTimesAtTable(String player, int count, String table) {
    return '$player won $count times at table $table';
  }

  @override
  String get playInPerson => 'Play in Person';

  @override
  String get playInPersonDescription =>
      'Play with real cards. One person keeps score, or everyone updates the same score sheet.';

  @override
  String get playInPersonHint => 'Real cards, the app keeps score';

  @override
  String get playModeHint => 'One player starts, everyone else joins.';

  @override
  String get playModeTitle => 'How are you playing?';

  @override
  String get playOnline => 'Play Online';

  @override
  String get playOnlineDescription =>
      'Everyone sees virtual cards on their own device. Scores are counted for you.';

  @override
  String get playOnlineHint => 'Virtual cards, automatic scoring';

  @override
  String readyToPlayPlayersAtTable(int count) {
    return 'Ready to play! $count players at table.';
  }

  @override
  String get remove => 'Remove';

  @override
  String get removePlayer => 'Remove Player';

  @override
  String removePlayerConfirmation(String playerName) {
    return 'Are you sure you want to remove \"$playerName\"?';
  }

  @override
  String get removeThisPlayer => 'Remove this player';

  @override
  String rounds(int count) {
    return '$count Rounds';
  }

  @override
  String get save => 'Save';

  @override
  String get saveResultAndNewGame => 'Close Game & Save Result';

  @override
  String get scanCameraError => 'Camera error: ';

  @override
  String get scanCard => 'Count Cards';

  @override
  String get scanCardHint => 'Total a hand with the camera';

  @override
  String get scanCardTitle => 'Count Cards';

  @override
  String get scanCorrectCardValueTitle => 'Correct Card Value';

  @override
  String get scanCorrectionRequiresSignIn =>
      'Sign in with an account to correct card values.';

  @override
  String get scanCorrectionSaved => 'Correction saved for model retraining';

  @override
  String get scanFailedDecode => 'Failed to decode captured image.';

  @override
  String get scanMacosPhotoHint =>
      'On macOS, choose a card photo from your library to scan.';

  @override
  String get scanModelError => 'Could not load model: ';

  @override
  String get scanModelLoading => 'Model is still loading — please wait.';

  @override
  String get scanNoCameraFound => 'No camera found on this device.';

  @override
  String get scanQrToJoin => 'Scan to sign in and join this table.';

  @override
  String get scanRankAce => 'A (1)';

  @override
  String get scanRankAceTitle => 'Ace (1)';

  @override
  String get scanRankJack => 'J (11)';

  @override
  String get scanRankJackTitle => 'Jack (11)';

  @override
  String get scanRankJoker => 'Joker (-2)';

  @override
  String get scanRankKing => 'K (0)';

  @override
  String get scanRankKingTitle => 'King (0)';

  @override
  String get scanRankQueen => 'Q (12)';

  @override
  String get scanRankQueenTitle => 'Queen (12)';

  @override
  String get scanTapToCorrect => 'Tap a card value bubble to correct it';

  @override
  String get scanWebPhotoHint =>
      'Choose a card photo from your device to scan.';

  @override
  String get scoreSheetNotFound => 'No score sheet found for that table name.';

  @override
  String scoreSheetTitle(String game) {
    return '$game Score Sheet';
  }

  @override
  String get selectAStatus => 'Select a status';

  @override
  String get selectTableToJoin => 'Select a Table to Join';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutFailed => 'Sign out failed.';

  @override
  String get skyjo => 'Skyjo';

  @override
  String get startGame => 'Start Game';

  @override
  String get starting => 'Starting';

  @override
  String get startNewGameWithQr => 'Start with QR';

  @override
  String get startScoreSheet => 'Start a Score Sheet';

  @override
  String get startScoreSheetHint => 'Keep score alone or share a QR code';

  @override
  String get startTable => 'Start a Table';

  @override
  String get statusBrb => 'BRB';

  @override
  String get statusFeelingGood => 'Feeling Good!';

  @override
  String get statusOhNo => 'Oh NO!';

  @override
  String get statusThinking => 'Thinking...';

  @override
  String get statusVoila => 'Voila!';

  @override
  String get swapThisWith => 'swap this →\n\nwith ↓';

  @override
  String get table => 'Table';

  @override
  String get tableForThisGroup => 'This group already plays at this table.';

  @override
  String tableLabel(String table) {
    return 'Table: $table';
  }

  @override
  String get tableNameTaken => 'Another table already uses that name.';

  @override
  String get tableNotFound => 'No table found with that name.';

  @override
  String get tableRename => 'Rename Table';

  @override
  String get thisGame => 'This Game';

  @override
  String get typeOfOAuthUsed => 'Type of OAuth used';

  @override
  String get waitForYourTurnSmiley => 'Wait for your turn :)';

  @override
  String get waitingForMorePlayers => 'Waiting for more players to join...';

  @override
  String get waitYourTurn => 'Wait your turn!';

  @override
  String get whatTypeOfGame => 'What type of game?';

  @override
  String get whoIsPlayingHint =>
      'Add everyone at the table. We\'ll find your table for this game, or start a new one.';

  @override
  String get whoIsPlayingQrHint =>
      'Players who scan join this sheet. You can also type names below.';

  @override
  String get whoIsPlayingTitle => 'Who is playing?';

  @override
  String get wizardStepOneOfTwo => 'Step 1 of 2';

  @override
  String get wizardStepTwoOfTwo => 'Step 2 of 2';

  @override
  String get youAreDone => 'You are done.';

  @override
  String get youIndicator => 'YOU>';
}
