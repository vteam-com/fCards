import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @addAnotherPlayer.
  ///
  /// In en, this message translates to:
  /// **'Add another player'**
  String get addAnotherPlayer;

  /// DO NOT TRANSLATE. This is the official brand name.
  ///
  /// In en, this message translates to:
  /// **'VTeam Cards'**
  String get appTitle;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cardCountTooltip.
  ///
  /// In en, this message translates to:
  /// **'{count}\\ncards'**
  String cardCountTooltip(int count);

  /// No description provided for @cardGamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Games'**
  String get cardGamesTitle;

  /// DO NOT TRANSLATE.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cardsTitle;

  /// No description provided for @columnsByRows.
  ///
  /// In en, this message translates to:
  /// **'{columns} x {rows}'**
  String columnsByRows(int columns, int rows);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmDeleteRound.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete round {round}?'**
  String confirmDeleteRound(int round);

  /// No description provided for @confirmNewGame.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to start a new game? All scores will be lost.'**
  String get confirmNewGame;

  /// No description provided for @corrections.
  ///
  /// In en, this message translates to:
  /// **'Corrections'**
  String get corrections;

  /// No description provided for @correctionsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get correctionsAll;

  /// No description provided for @correctionsApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get correctionsApprove;

  /// No description provided for @correctionsApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get correctionsApproved;

  /// No description provided for @correctionsBackendRequired.
  ///
  /// In en, this message translates to:
  /// **'Corrections review requires backend connectivity.'**
  String get correctionsBackendRequired;

  /// No description provided for @correctionsCorrectedValue.
  ///
  /// In en, this message translates to:
  /// **'Corrected value'**
  String get correctionsCorrectedValue;

  /// No description provided for @correctionsDecisionSaved.
  ///
  /// In en, this message translates to:
  /// **'Review decision saved'**
  String get correctionsDecisionSaved;

  /// No description provided for @correctionsDetectedValue.
  ///
  /// In en, this message translates to:
  /// **'Detected value'**
  String get correctionsDetectedValue;

  /// No description provided for @correctionsNoApproved.
  ///
  /// In en, this message translates to:
  /// **'No approved corrections found.'**
  String get correctionsNoApproved;

  /// No description provided for @correctionsNoData.
  ///
  /// In en, this message translates to:
  /// **'No corrections found.'**
  String get correctionsNoData;

  /// No description provided for @correctionsNoPending.
  ///
  /// In en, this message translates to:
  /// **'No pending corrections to review.'**
  String get correctionsNoPending;

  /// No description provided for @correctionsNoRejected.
  ///
  /// In en, this message translates to:
  /// **'No rejected corrections found.'**
  String get correctionsNoRejected;

  /// No description provided for @correctionsPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get correctionsPending;

  /// No description provided for @correctionsReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get correctionsReject;

  /// No description provided for @correctionsRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get correctionsRejected;

  /// No description provided for @correctionsReviewerOnly.
  ///
  /// In en, this message translates to:
  /// **'Only users in the reviewer group can access this screen.'**
  String get correctionsReviewerOnly;

  /// No description provided for @correctionsReviewStatus.
  ///
  /// In en, this message translates to:
  /// **'Review status'**
  String get correctionsReviewStatus;

  /// No description provided for @correctionsSubmittedAt.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get correctionsSubmittedAt;

  /// No description provided for @correctionsSubmittedBy.
  ///
  /// In en, this message translates to:
  /// **'Submitted by'**
  String get correctionsSubmittedBy;

  /// No description provided for @correctionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Training Corrections'**
  String get correctionsTitle;

  /// No description provided for @correctionsWebOnly.
  ///
  /// In en, this message translates to:
  /// **'Corrections review is currently available on web.'**
  String get correctionsWebOnly;

  /// No description provided for @createNewTable.
  ///
  /// In en, this message translates to:
  /// **'Create New Table'**
  String get createNewTable;

  /// No description provided for @createTableNameHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a simple table name. If it already exists, we\'ll help you join it instead.'**
  String get createTableNameHint;

  /// No description provided for @deleteLastRow.
  ///
  /// In en, this message translates to:
  /// **'Delete Last Row'**
  String get deleteLastRow;

  /// No description provided for @discardOrSwap.
  ///
  /// In en, this message translates to:
  /// **'Discard →\nor\n↓ swap'**
  String get discardOrSwap;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @drawCardHere.
  ///
  /// In en, this message translates to:
  /// **'Draw\na card\nhere\n→'**
  String get drawCardHere;

  /// No description provided for @editInitials.
  ///
  /// In en, this message translates to:
  /// **'Edit initials'**
  String get editInitials;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterTableName.
  ///
  /// In en, this message translates to:
  /// **'Enter name of the new table.'**
  String get enterTableName;

  /// No description provided for @errorLoadingScores.
  ///
  /// In en, this message translates to:
  /// **'Error loading scores: {error}'**
  String errorLoadingScores(String error);

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @finalRoundYouHaveToBeat.
  ///
  /// In en, this message translates to:
  /// **'Final Round. {turnText}. You have to beat {attacker}'**
  String finalRoundYouHaveToBeat(String turnText, String attacker);

  /// No description provided for @flipOpenOneHiddenCard.
  ///
  /// In en, this message translates to:
  /// **'↓ Flip open one of your hidden cards ↓'**
  String get flipOpenOneHiddenCard;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @gameOverTitle.
  ///
  /// In en, this message translates to:
  /// **'GAME OVER'**
  String get gameOverTitle;

  /// No description provided for @gameRules.
  ///
  /// In en, this message translates to:
  /// **'Game Rules'**
  String get gameRules;

  /// No description provided for @gamesWon.
  ///
  /// In en, this message translates to:
  /// **'Games Won'**
  String get gamesWon;

  /// No description provided for @golf9Cards.
  ///
  /// In en, this message translates to:
  /// **'9 Cards'**
  String get golf9Cards;

  /// No description provided for @golf9CardsFull.
  ///
  /// In en, this message translates to:
  /// **'Golf 9 Cards'**
  String get golf9CardsFull;

  /// No description provided for @golfScoreKeeper.
  ///
  /// In en, this message translates to:
  /// **'9 Cards Golf Scorekeeper'**
  String get golfScoreKeeper;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed.'**
  String get googleSignInFailed;

  /// No description provided for @identityChangeableLater.
  ///
  /// In en, this message translates to:
  /// **'You can change this later'**
  String get identityChangeableLater;

  /// No description provided for @identityChooseActionTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want to do?'**
  String get identityChooseActionTitle;

  /// No description provided for @identityFirstSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Others see this name at the table.'**
  String get identityFirstSubtitle;

  /// No description provided for @identityFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get identityFirstTitle;

  /// No description provided for @identityHostHint.
  ///
  /// In en, this message translates to:
  /// **'You\'re the host.'**
  String get identityHostHint;

  /// No description provided for @identityJoinHint.
  ///
  /// In en, this message translates to:
  /// **'You have a link or table name.'**
  String get identityJoinHint;

  /// No description provided for @identitySignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get identitySignInWithGoogle;

  /// No description provided for @instructionsCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom rules'**
  String get instructionsCustom;

  /// No description provided for @instructionsFrenchCards9.
  ///
  /// In en, this message translates to:
  /// **'- Aim for the lowest score.\n- Choose a card from either the Deck or Discard pile.\n- Swap the chosen card with a card in your 3x3 grid, or discard it and flip over one of your face-down cards.\n- Three cards of the same rank in a row or column score zero.\n- The first player to reveal all nine cards challenges others, claiming the lowest score.\n- If someone else has an equal or lower score, the challenger doubles their points!\n- Players are eliminated after busting 100 points.\n\n\nLearn more [Wikipedia](https://en.wikipedia.org/wiki/Golf_(card_game))'**
  String get instructionsFrenchCards9;

  /// No description provided for @instructionsMiniPut.
  ///
  /// In en, this message translates to:
  /// **'- Aim for the lowest score.\n- Choose a card from either the Deck or Discard pile.\n- Swap the chosen card with a card in your 2x2 grid, or discard it and flip over one of your face-down cards.\n- Three cards of the same rank in a row or column score zero.\n- The first player to reveal all nine cards challenges others, claiming the lowest score.\n- If someone else has an equal or lower score, the challenger doubles their points!\n- Players are eliminated after busting 100 points.\n\n\nLearn more [Wikipedia](https://en.wikipedia.org/wiki/Golf_(card_game))'**
  String get instructionsMiniPut;

  /// No description provided for @instructionsSkyjo.
  ///
  /// In en, this message translates to:
  /// **'- Aim for the lowest score.\n- Choose a card from either the Deck or Discard pile.\n- Swap the chosen card with a card in your 4x3 grid, or discard it and flip over one of your face-down cards.\n- When 3 cards of the same rank are lined up in a column they are moved to the discard pile.\n- The first player to reveal all their cards challenges others, claiming the lowest score.\n\n\nLearn more [Skyjo](https://www.geekyhobbies.com/how-to-play-skyjo-card-game-rules-and-instructions/)'**
  String get instructionsSkyjo;

  /// No description provided for @itsPlayersTurn.
  ///
  /// In en, this message translates to:
  /// **'It\'s {player}\'s turn'**
  String itsPlayersTurn(String player);

  /// No description provided for @itsYourTurn.
  ///
  /// In en, this message translates to:
  /// **'It\'s your turn {player}'**
  String itsYourTurn(String player);

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @joinExistingGame.
  ///
  /// In en, this message translates to:
  /// **'Join a Game'**
  String get joinExistingGame;

  /// No description provided for @joinGame.
  ///
  /// In en, this message translates to:
  /// **'Join Game'**
  String get joinGame;

  /// No description provided for @joinGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Game'**
  String get joinGameTitle;

  /// No description provided for @joinTable.
  ///
  /// In en, this message translates to:
  /// **'Join Table'**
  String get joinTable;

  /// No description provided for @joinThisTable.
  ///
  /// In en, this message translates to:
  /// **'Join This Table'**
  String get joinThisTable;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @last.
  ///
  /// In en, this message translates to:
  /// **'LAST'**
  String get last;

  /// DO NOT TRANSLATE.
  ///
  /// In en, this message translates to:
  /// **'MiniPut'**
  String get miniPut;

  /// No description provided for @miniPutFull.
  ///
  /// In en, this message translates to:
  /// **'MiniPut 4 Cards'**
  String get miniPutFull;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @noCardsAvailableToDraw.
  ///
  /// In en, this message translates to:
  /// **'No cards available to draw!'**
  String get noCardsAvailableToDraw;

  /// No description provided for @noMatchingTables.
  ///
  /// In en, this message translates to:
  /// **'No matching tables'**
  String get noMatchingTables;

  /// No description provided for @noOne.
  ///
  /// In en, this message translates to:
  /// **'No one'**
  String get noOne;

  /// No description provided for @noTablesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tables available'**
  String get noTablesAvailable;

  /// No description provided for @noTablesFoundMatching.
  ///
  /// In en, this message translates to:
  /// **'No tables found matching \"{searchText}\"'**
  String noTablesFoundMatching(String searchText);

  /// No description provided for @notAllowed.
  ///
  /// In en, this message translates to:
  /// **'Not allowed!'**
  String get notAllowed;

  /// No description provided for @notYourTurn.
  ///
  /// In en, this message translates to:
  /// **'It\'s not your turn!'**
  String get notYourTurn;

  /// No description provided for @orHereLeft.
  ///
  /// In en, this message translates to:
  /// **'\nor\nhere\n←'**
  String get orHereLeft;

  /// No description provided for @otherTools.
  ///
  /// In en, this message translates to:
  /// **'Other Tools'**
  String get otherTools;

  /// No description provided for @pickTableOrCreateHint.
  ///
  /// In en, this message translates to:
  /// **'Pick an existing table, or create a new one.'**
  String get pickTableOrCreateHint;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @playerName.
  ///
  /// In en, this message translates to:
  /// **'Player Initials'**
  String get playerName;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @playerWonTimesAtTable.
  ///
  /// In en, this message translates to:
  /// **'{player} won {count} times at table {table}'**
  String playerWonTimesAtTable(String player, int count, String table);

  /// No description provided for @pleaseEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name above ⬆'**
  String get pleaseEnterYourName;

  /// No description provided for @readyToPlayPlayersAtTable.
  ///
  /// In en, this message translates to:
  /// **'Ready to play! {count} players at table.'**
  String readyToPlayPlayersAtTable(int count);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removePlayer.
  ///
  /// In en, this message translates to:
  /// **'Remove Player'**
  String get removePlayer;

  /// No description provided for @removePlayerConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"{playerName}\"?'**
  String removePlayerConfirmation(String playerName);

  /// No description provided for @removeThisPlayer.
  ///
  /// In en, this message translates to:
  /// **'Remove this player'**
  String get removeThisPlayer;

  /// No description provided for @rounds.
  ///
  /// In en, this message translates to:
  /// **'{count} Rounds'**
  String rounds(int count);

  /// No description provided for @scanCameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera error: '**
  String get scanCameraError;

  /// No description provided for @scanCard.
  ///
  /// In en, this message translates to:
  /// **'Count Cards'**
  String get scanCard;

  /// No description provided for @scanCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Count Cards'**
  String get scanCardTitle;

  /// No description provided for @scanCorrectCardValueTitle.
  ///
  /// In en, this message translates to:
  /// **'Correct Card Value'**
  String get scanCorrectCardValueTitle;

  /// No description provided for @scanCorrectionRequiresSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google to correct card values.'**
  String get scanCorrectionRequiresSignIn;

  /// No description provided for @scanCorrectionSaved.
  ///
  /// In en, this message translates to:
  /// **'Correction saved for model retraining'**
  String get scanCorrectionSaved;

  /// No description provided for @scanFailedDecode.
  ///
  /// In en, this message translates to:
  /// **'Failed to decode captured image.'**
  String get scanFailedDecode;

  /// No description provided for @scanMacosPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'On macOS, choose a card photo from your library to scan.'**
  String get scanMacosPhotoHint;

  /// No description provided for @scanModelError.
  ///
  /// In en, this message translates to:
  /// **'Could not load model: '**
  String get scanModelError;

  /// No description provided for @scanModelLoading.
  ///
  /// In en, this message translates to:
  /// **'Model is still loading — please wait.'**
  String get scanModelLoading;

  /// No description provided for @scanNoCameraFound.
  ///
  /// In en, this message translates to:
  /// **'No camera found on this device.'**
  String get scanNoCameraFound;

  /// No description provided for @scanRankAce.
  ///
  /// In en, this message translates to:
  /// **'A (1)'**
  String get scanRankAce;

  /// No description provided for @scanRankAceTitle.
  ///
  /// In en, this message translates to:
  /// **'Ace (1)'**
  String get scanRankAceTitle;

  /// No description provided for @scanRankJack.
  ///
  /// In en, this message translates to:
  /// **'J (11)'**
  String get scanRankJack;

  /// No description provided for @scanRankJackTitle.
  ///
  /// In en, this message translates to:
  /// **'Jack (11)'**
  String get scanRankJackTitle;

  /// DO NOT TRANSLATE. Joker is the universal card game term.
  ///
  /// In en, this message translates to:
  /// **'Joker (-2)'**
  String get scanRankJoker;

  /// No description provided for @scanRankKing.
  ///
  /// In en, this message translates to:
  /// **'K (0)'**
  String get scanRankKing;

  /// No description provided for @scanRankKingTitle.
  ///
  /// In en, this message translates to:
  /// **'King (0)'**
  String get scanRankKingTitle;

  /// No description provided for @scanRankQueen.
  ///
  /// In en, this message translates to:
  /// **'Q (12)'**
  String get scanRankQueen;

  /// No description provided for @scanRankQueenTitle.
  ///
  /// In en, this message translates to:
  /// **'Queen (12)'**
  String get scanRankQueenTitle;

  /// No description provided for @scanTapToCorrect.
  ///
  /// In en, this message translates to:
  /// **'Tap a card value bubble to correct it'**
  String get scanTapToCorrect;

  /// No description provided for @scanWebPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a card photo from your device to scan.'**
  String get scanWebPhotoHint;

  /// No description provided for @scoreKeeper.
  ///
  /// In en, this message translates to:
  /// **'Score Keeper'**
  String get scoreKeeper;

  /// No description provided for @selectAStatus.
  ///
  /// In en, this message translates to:
  /// **'Select a status'**
  String get selectAStatus;

  /// No description provided for @selectTableToJoin.
  ///
  /// In en, this message translates to:
  /// **'Select a Table to Join'**
  String get selectTableToJoin;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed.'**
  String get signOutFailed;

  /// DO NOT TRANSLATE. This is the official brand name.
  ///
  /// In en, this message translates to:
  /// **'Skyjo'**
  String get skyjo;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// No description provided for @startGameWizardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the game for this table. We\'ll help you name it next.'**
  String get startGameWizardSubtitle;

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'Starting'**
  String get starting;

  /// No description provided for @startTable.
  ///
  /// In en, this message translates to:
  /// **'Start a Table'**
  String get startTable;

  /// No description provided for @statusBrb.
  ///
  /// In en, this message translates to:
  /// **'BRB'**
  String get statusBrb;

  /// No description provided for @statusFeelingGood.
  ///
  /// In en, this message translates to:
  /// **'Feeling Good!'**
  String get statusFeelingGood;

  /// No description provided for @statusOhNo.
  ///
  /// In en, this message translates to:
  /// **'Oh NO!'**
  String get statusOhNo;

  /// No description provided for @statusThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get statusThinking;

  /// No description provided for @statusVoila.
  ///
  /// In en, this message translates to:
  /// **'Voila!'**
  String get statusVoila;

  /// No description provided for @swapThisWith.
  ///
  /// In en, this message translates to:
  /// **'swap this →\n\nwith ↓'**
  String get swapThisWith;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// No description provided for @tableLabel.
  ///
  /// In en, this message translates to:
  /// **'Table: {table}'**
  String tableLabel(String table);

  /// No description provided for @thisGame.
  ///
  /// In en, this message translates to:
  /// **'This Game'**
  String get thisGame;

  /// No description provided for @thisTableAlreadyHasPlayers.
  ///
  /// In en, this message translates to:
  /// **'This table already exists. Join this table or enter a different name.'**
  String get thisTableAlreadyHasPlayers;

  /// No description provided for @useSearchBox.
  ///
  /// In en, this message translates to:
  /// **'Use the search box to quickly find a table'**
  String get useSearchBox;

  /// No description provided for @waitForYourTurnSmiley.
  ///
  /// In en, this message translates to:
  /// **'Wait for your turn :)'**
  String get waitForYourTurnSmiley;

  /// No description provided for @waitingForMorePlayers.
  ///
  /// In en, this message translates to:
  /// **'Waiting for more players to join...'**
  String get waitingForMorePlayers;

  /// No description provided for @waitingForPlayers.
  ///
  /// In en, this message translates to:
  /// **'Waiting for players to join'**
  String get waitingForPlayers;

  /// No description provided for @waitYourTurn.
  ///
  /// In en, this message translates to:
  /// **'Wait your turn!'**
  String get waitYourTurn;

  /// No description provided for @whatTypeOfGame.
  ///
  /// In en, this message translates to:
  /// **'What type of game?'**
  String get whatTypeOfGame;

  /// No description provided for @whoAreYou.
  ///
  /// In en, this message translates to:
  /// **'Who Are You?\nSelect above ⬆ or join below ⬇'**
  String get whoAreYou;

  /// No description provided for @wizardStepOneOfTwo.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2'**
  String get wizardStepOneOfTwo;

  /// No description provided for @wizardStepTwoOfTwo.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2'**
  String get wizardStepTwoOfTwo;

  /// No description provided for @youAreDone.
  ///
  /// In en, this message translates to:
  /// **'You are done.'**
  String get youAreDone;

  /// No description provided for @youIndicator.
  ///
  /// In en, this message translates to:
  /// **'YOU>'**
  String get youIndicator;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
