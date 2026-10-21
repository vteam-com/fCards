# CHANGELOG

## 1.14.3

- Wizard Back and Next buttons shrink to fit narrow screens instead of running off the edge
- Web: serve the app's entry files with no-cache so a new release loads without a hard refresh

## 1.14.2

- Handle backend downtime gracefully: every Firebase request and stream is bounded, one timeout trips a circuit breaker that fails fast for 34 seconds, and every screen shows a "Can't reach the game server" banner with a Retry button instead of an endless spinner
- Move to a new Realtime Database instance after the original one stopped answering; rules target the named instance
- Fix room rules so a lobby can save its invitees before a game is dealt (was rejected as permission denied)
- Upgrade Firebase to firebase_core 5, firebase_auth 7 and firebase_database 13; vendor google_sign_in_ios with GoogleSignIn-iOS 10 so Swift Package Manager resolves (see packages/google_sign_in_ios/VTEAM_PATCH.md)
- Replace the tflite_flutter git dependency with tflite_core from pub.dev (the package was renamed)
- Select the TFLite web fallback by js_interop so wasm dry runs no longer flag dart:ffi
- Deploy script releases Hosting only; database rules keep their own script
- Auto-select the first cell of the next row on the score sheet
- Faster startup
- fcheck 1.5.1

## 1.14.1

- Continue a game in progress
- Card counting button inside the digit pad

## 1.14.0

- New onboarding and a guided Start / Join table flow with QR code invitations
- Leaderboard: global and per-table rankings, player stats in the profile dialog
- Scores synced live across players on a shared score sheet
- Player editing: long press to rename, better initials entry, bottom sheet with grabber
- Avatar widget; Corrections menu moved to the profile dialog; version shown on the welcome screen
- Minimum iOS and macOS version 26

## 1.13.5

- Add Spanish and Portuguese (Portugal) localization support
- toolbar improvements
- remove package_info_plus

## 1.13.2

- Simplify multiplayer onboarding into a guided two-step "Start a Table" wizard
- Better SignIn/Avatar

## 1.13.1

- Secure Firebase Realtime Database rules with least-privilege access controls
- fCheck version 1.4.1
- Enforce strict fcheck scoring in CI (`--strict`) so only 100% clean checks pass

## 1.13.0

- Add Tests
- More training samples for AI Card Counting
- Align project documentation with implementation paths and symbols
- Fix architecture references in AGENTS guide (constants/logger/dialog helper naming)
- Fix README project tree reference for welcome screen entry file

## 1.12.5

- Refactor player edit dialog action buttons and improve layout constraints
- Player initial input using virtual keyboard

## 1.12.4

- Display preview of the card being corrected
- CI/CD NodeJS 24

## 1.12.3

- Improve correction card layout
- CI/CD node.js v24

## 1.12.2

- Require Google sign-in before users can correct detected card values
- Reject anonymous correction sample submissions so retraining data stays attributable
- Improve UX for AI correction of card value

## 1.12.1

- No more iOS cocoaPods
- fCheck 1.3.4 - score 100%
- Refactor the start game screen into smaller focused source files

## 1.12.0

- Add card scan / score camera feature with visual indication for zero-scored cells
- Detect playing cards via on-device ML model
- Add web-based card scanning support
- Refactor card scan overlay and screen for clarity and maintainability
- Upgrade Android Gradle and Kotlin versions

## 1.11.7

- Refactor start flow after game type selection to offer:
  - Join Existing Table
  - Create New Table
- Add dedicated "Create New Table" name-entry screen with:
  - uniqueness check before continue
  - disabled continue until a new table name is provided
  - join shortcut when table already exists
- Improve create-table flow copy in English and French
- Update user scenarios documentation for the new onboarding/create-table UX
- Update packages
- fCheck 1.1.2

## 1.11.6

- fCheck 1.1.1

## 1.11.5

- fCheck 1.1.0
- No longer generating the "graph.svg"

## 1.11.4

- fCheck 1.0.9

## 1.11.3

- Animated reveal of swapped card
  
## 1.11.2

- Fix typo in game type selection (Sky'l'o → Skyjo)

## 1.11.1

- UI: Remove the progress numbering steps

## 1.11.0

- Localize hardcoded strings across the app:
  - Start game wizard screen: grid dimensions display
  - Table widget: empty state and search messages
  - Player zone CTA: game state messages
  - Status picker: status selection prompt
  - Player header: rank badges and player management dialogs

## 1.10.8

- Add DartDoc comments across core game, player, helper, and auth components
- Update `fcheck` tooling to `0.9.10` and enable full issue listing in `tool/check.sh`

## 1.10.7

- Move to Wizard onboarding

## 1.10.6

- Animated background

## 1.10.5

- Fix button colors for consistent UI styling

## 1.10.4

- Fix bug where game would not end
- fCheck clean
  - Remove code duplication
  - Refactor themed MyButton to use shared base widget
  - Standardize button style across app (Main Menu, Dialogs, Player Header)
  - All numbers are now Fibonacci numbers

## 1.10.3

- Fix dead code and unused parameters flagged by fCheck 0.9.1
- Update fCheck tooling to 0.9.1

## 1.10.2

- Add Gmail OAuth authentication
- Standardize UI styling and reduce constants usage
- Fix score selection border
- Clean up screen helper formatting

## 1.9.8

- fix more "magic numbers"

## 1.9.7

- Improve UX for "Join a Game"

## 1.9.6

- CI/CD

## 1.9.5

- Add CI/CD workflow for Flutter web validation and build
- Ensure fcheck is automatically updated in check.sh script

## 1.9.4

- Add comprehensive logging with different levels (debug, info, warning, error)
- Add test silencing to prevent log output clutter during test execution
- Improve debugging capabilities with timestamps and stack traces

## 1.9.3

- Fix macOS build issues
- Remove font scale feature
- Fix magic numbers throughout codebase
- Improve AppBar with green styling
- Remove dead code and circular dependencies

## 1.9.0

- Add splash screen
- Font scaling feature (later removed)
- Fullscreen toggle feature (later removed)
- Upgrade to Dart 3.9.2
- Fix URL launch functionality
- Refactor folder and file names
- Split into 3 entry screens

## 1.8.4

- Support scores in the 10,000 range
- KeepScore improvements:
  - Better PlayersHeader as ElevatedButtons
  - Improved rename player functionality
  - Better UX for scrolling rounds
  - Enhanced layout and buttons
  - Keyboard input support
  - Auto-add rounds functionality
- Card score improvements
- King crown and loser indicators
- Better keyboard handling

## 1.7.4

- KeepScore feature implementation
- Generic keyboard support
- Player management improvements
- Score persistence
- Round management with confirmation dialogs

## 1.7.3

- Bug fix for counting same rank cards
- Add documentation
- Upgrade packages

## 1.7.2

- Column headers in GameOver dialog
- Display app version using package_info_plus
  
## 1.7.1

- Display the cards set in the [Game Rules]
  
## 1.7.0

- MiniPut version 2x2
  
## 1.6.0

- Game history

## 1.5.0

- Player Status

## 1.1.0

- Add Skyjo (Giles)

## 1.2.0

- Multiple Rooms

## 1.0.0

- First version
