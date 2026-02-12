# Implementation Plan

## Goal
Make "Start a New Game" behave like a wizard:
1. Choose game type (`Golf 9 Cards`, `MiniPut 4 Cards`, `Skylo`)
2. Choose an existing room or create a new room
3. If existing room selected, continue in the existing "Join an Existing Game" wizard
4. If creating a room, continue in the existing create/invite flow

## Steps
1. Add a new `StartGameWizardScreen` with two steps: game type and room decision.
2. Route the main menu "Start a New Game" button to the new wizard.
3. Extend `JoinGameScreen` to accept:
   - preselected room
   - selected game style
   and start from the name step when room is preselected.
4. Extend `StartScreen` to accept initial game style so create-flow keeps the selected mode.
5. Run project checks (`./tool/check.sh`) and fix any issues.
