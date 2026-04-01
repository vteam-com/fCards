# SCENARIOS

This document lists the user-facing scenarios implemented in the app, described from the player's perspective and focused on benefits.

## 1) Start A New Game (Wizard)
As a player, I can tap **Start a New Game**, choose the game type (Golf 9 Cards, MiniPut, Skyjo), and then choose whether to create a table or join an existing one.

Benefit to me: I can set up the exact game style I want before inviting or joining others.

## 2) Create New Table
As a player, I start by tapping **Start a New Game**, then create a table by entering a table name in the create flow.

Expected flow:
1. From Welcome, I tap **Start a New Game**.
2. I choose a game type.
3. I choose **Create New Table**.
4. The next screen is only for **Enter name of the new table**.
5. The app checks whether that table already exists.
6. If it already exists, I am asked to either **Join This Table** or enter a different table name.
7. The **Continue** button stays disabled until the entered table name is unique/new.
8. After Continue, I enter my player name, become the first player, and create the table.
9. Once enough players are in the table, I can start the game.

Benefit to me: I can quickly open a fresh table for my group while avoiding accidental duplicate tables.

## 3) Join Existing Table From Start Wizard
As a player, I can pick an existing table directly from the start wizard and continue into the join flow with the selected game type.

Benefit to me: I avoid re-entering the table name and join active tables faster.

## 4) Join Existing Game (Dedicated Join Flow)
As a player, I can open **Join an Existing Game**, search/filter tables, select one, enter my name, and join.

Benefit to me: I can find active games quickly and get into a room with minimal steps.

## 5) Wait Room / Pre-Game Lobby
As a player in a table, I can see who is already in the room and wait until minimum players are present before starting.

Benefit to me: I can coordinate with friends in one place and start only when everyone is ready.

## 6) Shareable Invite Link
As a player, I can share a link from setup/game screens so others can join my table with room/game context.

Benefit to me: inviting friends is one tap instead of manually explaining room details.

## 7) Deep-Link Entry
As a player opening a shared URL containing game parameters (`mode`, `room`, `players`), I am redirected into the game setup flow with those values prefilled.

Benefit to me: shared links drop me into the right context immediately.

## 8) Real-Time Multiplayer Sync
As a player, I see room and game updates synced live through Firebase (players joining, state changes, turns, etc.).

Benefit to me: everyone sees the same state without manual refresh loops.

## 9) Turn-Based Card Play (Main Game)
As a player, I can play turn-based card actions with clear prompts:
- draw from deck or discard,
- swap or discard,
- reveal hidden cards,
- continue until final round/game over.

Benefit to me: the UI guides legal moves and reduces rule confusion.

## 10) Drag-And-Drop Card Interaction
As a player, I can drag/drop cards for swaps and interact directly with piles/cards.

Benefit to me: gameplay feels faster and more intuitive than form-based actions.

## 11) Final Round + Game Over Summary
As a player, I get final-round behavior, then a game-over summary showing players, this-game score, and wins count, with options to play again or exit.

Benefit to me: I can close a round cleanly and immediately continue if the group wants another game.

## 12) Table Win History Tracking
As a player, my wins are recorded per table and shown in history (including per-player historical wins in that table).

Benefit to me: I can track long-term bragging rights at each table.

## 13) Player Status Signals
As a player, I can set a quick status (for example: thinking, BRB, feeling good).

Benefit to me: I can communicate my current state without chat overhead.

## 14) Score Keeper (9-Card Golf)
As a player, I can use the dedicated scorekeeper to track rounds and totals independently from the live card room.

Benefit to me: I can run in-person or manual games while still using the app for score management.

## 15) Score Keeper Fast Input
As a player, I can tap a score cell and enter/update values using the on-screen keypad or physical keyboard.

Benefit to me: score entry is fast during live play.

## 16) Score Keeper Rounds & Players Management
As a player, I can:
- add/remove rounds,
- add/remove players,
- rename players,
- see ranking indicators (leader crown, last place marker),
- start a new score sheet with confirmation.

Benefit to me: I can adapt scoring as participants change across rounds.

## 17) Persistent Score Data
As a player, my scorekeeper data is saved locally and restored when I reopen the app.

Benefit to me: I do not lose ongoing score sessions.

## 18) Account Modes (Guest + Google Sign-In)
As a player, I can play as guest by default, optionally sign in with Google, and sign out later.

Benefit to me: I can start instantly, with optional account identity when I want it.

## 19) Language Switching (EN/FR)
As a player, I can switch app language between English and French from the in-app language picker.

Benefit to me: I can play in the language I prefer.

## 20) Offline-Capable Development/Play Mode
As a player/developer, the app supports an offline mode path with fallback behavior when backend is unavailable.

Benefit to me: I can continue using/testing core flows without depending on network/backend uptime.

## 21) Cross-Platform Access
As a player, I can use the app on web, mobile, and desktop platforms.

Benefit to me: my group can join from different devices without changing apps.
