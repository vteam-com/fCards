# Implementation Plan: Player Leaderboard

## Goal

Rank players by the games they played, in both play modes:

Two games — **9 Cards** (`frenchCards9`) and **Skyjo** — each played in one of two modes:

- **Remote**: online card game, one device per player — recorded automatically at Game Over.
- **Local**: real cards at one table, the Score Keeper sheet (9 Cards) — recorded when the
  host confirms *Close Game* with its single winner.

Two scopes:

- **Global** — every player with a Firebase account id (Google, Apple or anonymous).
- **Table** — everyone who played at one room / score sheet, including name-only players.

Stats per player: games played, wins, win rate, best score, average score.
Lowest score wins; ties for the lowest score all count as wins.
Every board is a single game type (9 Cards by default), so best / average
scores are always comparable. There is no "all games" board.

## Firebase data model

```text
table_results/{tableKey}/{gameId}      full result, source of the table board
  table_name, style, mode (remote | local), ended_at
  players/{index}: { name, uid, score, winner }

leaderboard/{style}/{uid}              running totals, source of the global board
  name, avatar_url, games_played, wins, total_score, best_score, last_played
  (style = frenchCards9 | skyjo — every board is one game type, 9 Cards by default)

leaderboard_games/{uid}/{gameId}       create-only marker so a game counts once
leaderboard_tables/{uid}/{tableKey}    tables a player has results at
  table_name, last_played
```

- `gameId` = `{tableKey}_{gameStartedAt}` for card games, `{tableKey}_{endedAt}` for Score Keeper.
- Card games: `gameStartedAt` is now part of the synced room JSON so every device
  derives the same id. Each device records its own signed-in player's uid; the
  create-only marker keeps repeated Game Over events from double counting.
- Score Keeper: the device that saves the result records totals for every
  participant with an account id (manual columns stay table-only).

## Code

| File | Change |
| --- | --- |
| `lib/models/game/game_result.dart` | `GameResult` / `GameResultPlayer` value types + (de)serialization |
| `lib/models/game/leaderboard_entry.dart` | `LeaderboardEntry`, ranking and table aggregation |
| `lib/models/game/leaderboard_service.dart` | Firebase reads/writes |
| `lib/models/game/game_model.dart` | Sync `gameStartedAt` |
| `lib/screens/game/game_over_dialog.dart` | Record card game results |
| `lib/screens/keepscore/golf_score_screen.dart` | *Save result & new game* action |
| `lib/screens/leaderboard/leaderboard_screen.dart` | New `/leaderboard` screen |
| `lib/widgets/helpers/avatar_profile_dialog.dart` | *My stats* section + Leaderboard button |
| `lib/screens/welcome/welcome_screen.dart` | Leaderboard entry on the play-mode step |
| `database.rules.json` | Rules + `.indexOn` for the new nodes |
| `lib/l10n/*.arb` | New strings |
| `test/models/leaderboard_test.dart` | Unit tests for results and aggregation |

## Out of scope

- Past `history/{room}` wins are not imported (they only stored the winner's
  name). The app no longer reads or writes `history`.
- Server-side validation of submitted scores (the app's rules already let any
  signed-in player write game state).

## Tables (unified)

Concepts:

- **Game type**: 9 Cards (`frenchCards9`) or Skyjo (`skyjo`) — fixed per table.
- **Cards**: `physical` (real cards, Score Keeper sheet) or `virtual` (app deals) — per game.
- **Table**: a game type + an exact set of players, with an auto-generated,
  editable two-word name (e.g. `BLUE OTTER`). A different group is a different table.

```text
tables/{tableId}                 tableId = "{gameType}|{PLAYER}|{PLAYER}…" (sorted, upper-case)
  name, game_type, players[], created_at, last_played
lobbies/{lobbyId}                a group getting ready, before its table is known
  name (proposed / reopened table name), game_type, cards, table_id?, created_at
rooms/{lobbyId}                  live virtual-card game (invitees + game state)
score_sessions/{lobbyId}         live shared physical-card sheet
player_tables/{uid}/{tableId}    last_played — "My tables"
table_results/{tableId}/{gameId} results (gains `cards`)
```

- Because the table id is derived from type + players, finding a table by its
  players is a direct read, and concurrent devices can't create duplicates
  (create-if-absent transaction).
- **Virtual**: Start → game type → reopen one of my tables of that type, or a new
  table (proposed name, editable) → lobby. The table is resolved at *Start Game*
  from the final players; the lobby's name becomes the table name when the group is new.
- **Physical**: Start score sheet → game type → enter the players → the table for
  exactly those players and that game is found, or created → sheet. If the players
  change on the sheet, the table is resolved again at *Close Game*. The sheet header shows the
  table that matches the current players live.
- **Find again**: by name (join search, leaderboard), or by players + type (automatic).
- **Rename**: from the lobby, the score sheet, or the leaderboard table board;
  names are unique among tables.

## Deploy

`firebase deploy --only database` is required for the new rules and index.
