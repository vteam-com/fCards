# Onboarding Flow

This document describes how a player moves from opening the app to sitting at a playable table.

![Onboarding Flow](onboarding_flow.svg)

## Maintenance Rule

When onboarding logic changes, update `onboarding_flow.svg` in the same commit so the diagram always reflects the real code.

---

## Design Principles

- **Identity first.** The app learns who you are before asking anything else.
- **Google sign-in required** for creating or joining a table (no anonymous access to rooms).
- **One job per step.** Each screen asks for exactly one decision.
- **No dead ends.** If a table name already exists, the app immediately offers to join it instead.
- **Unified Start + Join screen.** A single `JoinGameScreen` handles both paths; `canCreateTable` controls what is shown.

---

## Step 0 — Welcome Screen (`/`)

The app resolves identity before showing any game choices.

| State            | What happens                             |
| ---------------- | ---------------------------------------- |
| App is loading   | Spinner while checking stored identity   |
| Google signed in | Skip picker → go straight to choice step |
| Not signed in    | Show **Sign in with Google** button      |

After signing in the user lands on the **choice step**: two large buttons — **Start a Table** and **Join a Table**.

The avatar button (top-right) always lets the user set two-letter initials for in-game display, regardless of which auth method they used.

---

## Path A — Start a Table (`/start`)

Route: `JoinGameScreen(canCreateTable: true)`

### Step 0 — Table Picker (with Create New)

- Lists all available tables from Firebase.
- A **"Create New Table"** button appears at the top (only in this flow).
- If the user picks an **existing table** → skip to Name Entry (Step 2).
- If the user taps **Create New Table** → go to Game Type (Step 1).

### Step 1 — Select Game Type *(Create-new path only)*

- Choose: Golf 9 Cards · Skyjo · MiniPut 4
- Each option shows a card-layout mini-preview.
- **Next** → navigates to `CreateTableNameScreen` (`/create-table`).

### CreateTableNameScreen (`/create-table`)

- User types a table name (auto-uppercased).
- While typing, the app checks Firebase for conflicts.
- **Name is unique** → Continue button enabled.
- **Name already exists** → "That table already exists" message + **Join This Table** shortcut.
- On continue, the creator is **auto-joined** using their Google display name, then pushed to the waiting room.

### Step 2 — Name Entry *(existing-table path only)*

- User types their player name (shown as uppercase at the table).
- **Join Table** → joins the Firebase room and advances.

### Step 3 — Waiting Room

- Live player list (Firebase stream).
- Host sees persistent invite actions until enough players are present.
- **CTA when count < minimum:** "Waiting for more players" (disabled).
- **CTA when count ≥ minimum:** **Start Game** → launches `GameScreen`.

---

## Path B — Join a Table (`/join`)

Route: `JoinGameScreen(canCreateTable: false)`

### Step 0 — Table Picker (search only)

- Same table list as the Start flow; no "Create New Table" button.
- User selects a table or types its name.

### Step 2 — Name Entry

- User types their player name.
- **Join Table** → joins the Firebase room and advances.

### Step 3 — Waiting Room (Joiners)

- Same as the host waiting room.
- Non-host players see "Waiting for host to start".
- When a host starts the game the screen transitions automatically.

---

## Path C — Deep Link (`/game`)

A shared URL (e.g. `?room=LIONS&gameType=golf9`) opens the app directly into `StartScreen(joinMode: false)` with the room pre-populated, bypassing the welcome and join screens.

---

## Avatar & Initials

Accessible from the avatar button on any screen's app bar.

- **Google users** — display name or photo shown; can set a custom two-letter shortcode for in-game representation via **Edit Initials**.
- The initials dialog pre-populates from the Google display name (e.g. "Jean-Paul" → "JP") if no custom value has been saved yet.
- Initials are stored locally (shared preferences) and survive app restarts.

---

## Firebase Security

| Operation                        | Required       |
| -------------------------------- | -------------- |
| Read room list                   | `auth != null` |
| Read room data                   | `auth != null` |
| Write to invitees (join a room)  | `auth != null` |
| Write game state (cards, scores) | `auth != null` |
| Read/write game history          | `auth != null` |

All table operations require Firebase Authentication. Anonymous access to room data is not allowed.

---

## Core Decision Logic

1. **Authenticated?**
   - No → show Google sign-in gate; proceed only after sign-in.
   - Yes → show Start / Join choice.
2. **Table name conflict?** *(Create-new path only)*
   - Yes → offer "Join This Table" shortcut; block continue.
   - No → enable continue.
3. **Enough players?**
   - No → keep waiting; host can share the invite link.
   - Yes → **Start Game** enabled.
