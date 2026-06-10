# Input Initials Experience - Feature Specification

## Goal

Provide a fast, game-friendly way to edit a player identity using two initials instead of free-form text, while supporting both touch and physical keyboard workflows.

## Scope

This specification covers the player edit dialog input in the player header flow.

## User-Facing Requirements

### 1) Field Purpose and Label

- The input represents player initials (2 characters max).
- The field label is shown as Player Initials (localized).

### 2) Input Model

- Maximum length: 2 characters.
- Allowed characters: uppercase letters A-Z and digits 0-9.
- Invalid characters are ignored.
- Input is normalized to uppercase.

### 3) Visual Design

- The input is rendered as two OTP/PIN-style slots.
- Slot content must be centered and scale to fit without clipping.
- The active slot is visually highlighted.

### 4) Touch Behavior

- Tapping slot 1 sets slot 1 as active.
- Tapping slot 2 sets slot 2 as active.
- Typing after slot selection updates the active slot position.

### 5) Initial Selection On Open

- When the edit dialog opens, slot 1 is active by default.
- User can start typing immediately without tapping a slot first.

### 6) Auto-Advance

- After entering a character in slot 1, selection automatically moves to slot 2.

### 7) Physical Keyboard Behavior

- Character keys write into the current active slot/cursor position.
- Backspace removes selection or the character before cursor when no selection.
- Enter accepts the change, same as pressing Done.

### 8) Virtual Keyboard Behavior

- The on-screen alpha keyboard remains available.
- Virtual keys update the same two-character model used by physical keyboard input.
- Virtual backspace behaves like physical backspace.
- Virtual input also respects active slot selection and auto-advance.

### 9) Commit Behavior

- Done commits the current initials and closes the dialog.
- Enter performs the same action as Done.
- Add another player and Remove this player actions remain available and unchanged in intent.

### 10) Layout and Responsiveness

- Edit dialog max width is capped at 800 px.
- Text action buttons are capped at 300 px width.
- Bottom actions remain responsive: side-by-side when space allows, wrapped/stacked when constrained.

## Non-Goals

- No support for names longer than two characters in this dialog input.
- No changes to unrelated dialogs or game flows.

## Acceptance Criteria

- User can enter exactly up to two initials using either physical or virtual keyboard.
- Second slot renders correctly when second character is present.
- Tapping each slot changes active selection as expected.
- Enter key submits exactly like Done.
- Slot letters never visually overflow or clip.
- Existing checks pass with no new lint/analyze/test/fcheck regressions.
