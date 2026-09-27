# Implementation Plan: Player Leaderboard

## Goal

Rank players by the games they played, in both play modes:

- **Online card games** (9 Cards, Skyjo, MiniPut, Custom) — recorded automatically at Game Over.
- **Score Keeper** sheets — recorded when the host picks *Save result & new game*.

Two scopes:

- **Global** — every player with a Firebase account id (Google, Apple or anonymous).
- **Table** — everyone who played at one room / score sheet, including name-only players.

Stats per player: games played, wins, win rate, best score, average score.
Lowest score wins; ties for the lowest score all count as wins.
Best / average are only shown when filtered to a single game style, because
scores from different styles are not comparable.

## Firebase data model

```text
table_results/{tableKey}/{gameId}      full result, source of the table board
  table_name, style, ended_at
  players/{index}: { name, uid, score, winner }

leaderboard/{style}/{uid}              running totals, source of the global board
  name, avatar_url, games_played, wins, total_score, best_score, last_played
  (style = all | frenchCards9 | skyjo | miniPut | custom | scoreKeeper)

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

## Deploy

`firebase deploy --only database` is required for the new rules and index.
