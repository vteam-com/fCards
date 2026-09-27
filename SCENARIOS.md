# SCENARIOS

This document lists the user-facing scenarios implemented in the app, described from the player's perspective and focused on benefits.

## 1) Tables

A table is one game type (Golf 9 Cards or Skyjo) played by an exact group of players. It gets a friendly two-word name (for example **LUCKY OTTER**) that anyone can rename. A different group, or the same group playing the other game, is a different table.

Benefit to me: each group has its own place, history, and leaderboard, which I can find again by name or just by playing with the same people.

## 2) Start A Table (Virtual Cards)

As a player, I tap **Start a Table**, choose the game type, then either reopen one of my tables of that type (listed with their players) or start a **New Table** with a proposed name I can change.

Benefit to me: replaying with my usual group takes two taps, and a new group never has to invent a unique name.

## 3) Lobby

As a player in the lobby, I see the table name, the game, and who has joined; I can add players or remove them. While the group changes, the lobby tells me whether this exact group already has a table (and shows its name) or will get a new one. **Start Game** is enabled once enough players are in.

Benefit to me: the game is always recorded at the right table, even if someone joins at the last minute.

## 4) Join A Table (Virtual Cards)

As a player, I open **Join a Game** and either type the table's name or pick it from the tables opened recently.

Benefit to me: I can find my friends' table without a code.

## 5) Shareable Invite Link

As a player on the web, I can share a link (`?lobby=…`) from the lobby or the game that opens the lobby directly.

Benefit to me: inviting friends is one tap instead of explaining which table to pick.

## 6) Score Sheet (Physical Cards)

As a player with real cards, I tap **Start a Score Sheet**, choose the game type, then gather who is playing: the screen shows a QR code that players scan to join the sheet from their phones (they appear in the list as they join), and I can still type names for anyone without the app. I'm already in the list. The app finds our table for that game from exactly those players, or creates a new one, and opens the sheet there. I can also continue a sheet in progress. The sheet shows the table that matches the current players and lets me rename it.

Benefit to me: in-person games land on the same tables and leaderboards as online ones.

## 7) Close A Game

As the host of a score sheet, I close the game from **New Game → Close Game & Save Result**. I confirm the final standings and the single winner (breaking a tie by tapping the winner). Everyone at the table sees who won, and the result is saved to the table of exactly those players.

Benefit to me: every game ends with one clear, agreed winner.

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

## 12) Leaderboards

As a player, every finished game (virtual or physical cards) is saved to its table. The **Leaderboard** ranks players globally (filtered by game type) or per table, with games played, wins, win rate, and best/average score; my own stats and rank are in my profile.

Benefit to me: I can track long-term bragging rights, overall and at each table.

## 13) Player Status Signals

As a player, I can set a quick status (for example: thinking, BRB, feeling good).

Benefit to me: I can communicate my current state without chat overhead.

## 14) Score Keeper

As a player, I can use the score sheet to track rounds and totals for a physical-card game of Golf 9 Cards or Skyjo; lowest total wins.

Benefit to me: I can run in-person games while still using the app for score management.

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
