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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'VTeam Cards'**
  String get appTitle;

  /// No description provided for @cardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cardsTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'VTeam Cards'**
  String get welcomeTitle;

  /// No description provided for @startNewGame.
  ///
  /// In en, this message translates to:
  /// **'Start a New Game'**
  String get startNewGame;

  /// No description provided for @joinExistingGame.
  ///
  /// In en, this message translates to:
  /// **'Join an Existing Game'**
  String get joinExistingGame;

  /// No description provided for @scoreKeeper.
  ///
  /// In en, this message translates to:
  /// **'Score Keeper'**
  String get scoreKeeper;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedIn;

  /// No description provided for @playingAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Playing as Guest'**
  String get playingAsGuest;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signingOut.
  ///
  /// In en, this message translates to:
  /// **'Signing out...'**
  String get signingOut;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed.'**
  String get googleSignInFailed;

  /// No description provided for @signOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed.'**
  String get signOutFailed;

  /// No description provided for @startGameWizardTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGameWizardTitle;

  /// No description provided for @joinGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Game'**
  String get joinGameTitle;

  /// No description provided for @cardGamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Games'**
  String get cardGamesTitle;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// No description provided for @whatTypeOfGame.
  ///
  /// In en, this message translates to:
  /// **'What type of game?'**
  String get whatTypeOfGame;

  /// No description provided for @pickTableOrCreate.
  ///
  /// In en, this message translates to:
  /// **'Pick a table or create a new one'**
  String get pickTableOrCreate;

  /// No description provided for @tapExistingTable.
  ///
  /// In en, this message translates to:
  /// **'Tap an existing table to continue'**
  String get tapExistingTable;

  /// No description provided for @noExistingTables.
  ///
  /// In en, this message translates to:
  /// **'No existing tables found. Create a new one to continue.'**
  String get noExistingTables;

  /// No description provided for @createNewTable.
  ///
  /// In en, this message translates to:
  /// **'Create New Table'**
  String get createNewTable;

  /// No description provided for @createTableHelp.
  ///
  /// In en, this message translates to:
  /// **'Create a table.\nIf it already exists, you can join it.'**
  String get createTableHelp;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// No description provided for @enterTableName.
  ///
  /// In en, this message translates to:
  /// **'Enter a table name to check if it already exists.'**
  String get enterTableName;

  /// No description provided for @thisTableAlreadyHasPlayers.
  ///
  /// In en, this message translates to:
  /// **'This table already has players. You can join it instead of creating a new table.'**
  String get thisTableAlreadyHasPlayers;

  /// No description provided for @joinThisTable.
  ///
  /// In en, this message translates to:
  /// **'Join This Table'**
  String get joinThisTable;

  /// No description provided for @whoAreYou.
  ///
  /// In en, this message translates to:
  /// **'Who Are You?\nSelect above ⬆ or join below ⬇'**
  String get whoAreYou;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @pleaseEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name above ⬆'**
  String get pleaseEnterYourName;

  /// No description provided for @waitingForPlayers.
  ///
  /// In en, this message translates to:
  /// **'Waiting for players to join'**
  String get waitingForPlayers;

  /// No description provided for @joinGame.
  ///
  /// In en, this message translates to:
  /// **'Join Game'**
  String get joinGame;

  /// No description provided for @gameRules.
  ///
  /// In en, this message translates to:
  /// **'Game Rules'**
  String get gameRules;

  /// No description provided for @selectTableToJoin.
  ///
  /// In en, this message translates to:
  /// **'Select a Table to Join'**
  String get selectTableToJoin;

  /// No description provided for @useSearchBox.
  ///
  /// In en, this message translates to:
  /// **'Use the search box to quickly find a table'**
  String get useSearchBox;

  /// No description provided for @joiningTable.
  ///
  /// In en, this message translates to:
  /// **'Joining Table: {table}'**
  String joiningTable(String table);

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Name'**
  String get enterYourName;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @joinTable.
  ///
  /// In en, this message translates to:
  /// **'Join Table'**
  String get joinTable;

  /// No description provided for @welcomePlayer.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {player}!'**
  String welcomePlayer(String player);

  /// No description provided for @readyToPlayPlayersAtTable.
  ///
  /// In en, this message translates to:
  /// **'Ready to play! {count} players at table.'**
  String readyToPlayPlayersAtTable(int count);

  /// No description provided for @waitingForMorePlayers.
  ///
  /// In en, this message translates to:
  /// **'Waiting for more players to join...'**
  String get waitingForMorePlayers;

  /// No description provided for @tableLabel.
  ///
  /// In en, this message translates to:
  /// **'Table: {table}'**
  String tableLabel(String table);

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @gamesWon.
  ///
  /// In en, this message translates to:
  /// **'Games Won'**
  String get gamesWon;

  /// No description provided for @thisGame.
  ///
  /// In en, this message translates to:
  /// **'This Game'**
  String get thisGame;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @golfScoreKeeper.
  ///
  /// In en, this message translates to:
  /// **'9 Cards Golf Scorekeeper'**
  String get golfScoreKeeper;

  /// No description provided for @deleteLastRow.
  ///
  /// In en, this message translates to:
  /// **'Delete Last Row'**
  String get deleteLastRow;

  /// No description provided for @confirmDeleteRound.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete round {round}?'**
  String confirmDeleteRound(int round);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// No description provided for @confirmNewGame.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to start a new game? All scores will be lost.'**
  String get confirmNewGame;

  /// No description provided for @rounds.
  ///
  /// In en, this message translates to:
  /// **'{count} Rounds'**
  String rounds(int count);

  /// No description provided for @errorLoadingScores.
  ///
  /// In en, this message translates to:
  /// **'Error loading scores: {error}'**
  String errorLoadingScores(String error);

  /// No description provided for @golf9Cards.
  ///
  /// In en, this message translates to:
  /// **'9 Cards'**
  String get golf9Cards;

  /// No description provided for @skyJo.
  ///
  /// In en, this message translates to:
  /// **'SkyJo'**
  String get skyJo;

  /// No description provided for @miniPut.
  ///
  /// In en, this message translates to:
  /// **'MiniPut'**
  String get miniPut;

  /// No description provided for @golf9CardsFull.
  ///
  /// In en, this message translates to:
  /// **'Golf 9 Cards'**
  String get golf9CardsFull;

  /// No description provided for @miniPutFull.
  ///
  /// In en, this message translates to:
  /// **'MiniPut 4 Cards'**
  String get miniPutFull;

  /// No description provided for @skyLo.
  ///
  /// In en, this message translates to:
  /// **'Skylo'**
  String get skyLo;

  /// No description provided for @columnsByRows.
  ///
  /// In en, this message translates to:
  /// **'{columns} x {rows}'**
  String columnsByRows(int columns, int rows);

  /// No description provided for @noTablesFoundMatching.
  ///
  /// In en, this message translates to:
  /// **'No tables found matching \"{searchText}\"'**
  String noTablesFoundMatching(String searchText);

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'Starting'**
  String get starting;

  /// No description provided for @gameOverTitle.
  ///
  /// In en, this message translates to:
  /// **'GAME OVER'**
  String get gameOverTitle;

  /// No description provided for @selectAStatus.
  ///
  /// In en, this message translates to:
  /// **'Select a status'**
  String get selectAStatus;

  /// No description provided for @last.
  ///
  /// In en, this message translates to:
  /// **'LAST'**
  String get last;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @addAnotherPlayer.
  ///
  /// In en, this message translates to:
  /// **'Add another player'**
  String get addAnotherPlayer;

  /// No description provided for @removeThisPlayer.
  ///
  /// In en, this message translates to:
  /// **'Remove this player'**
  String get removeThisPlayer;

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

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @noTablesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tables available'**
  String get noTablesAvailable;

  /// No description provided for @noMatchingTables.
  ///
  /// In en, this message translates to:
  /// **'No matching tables'**
  String get noMatchingTables;
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
