# SCORE_DETECTION

## Purpose

Define the card-scanning score flow for end-of-round play, where each player presents their 9-card layout, the app evaluates the cards from a photo, and play advances to the next player.

## Primary Use Case

1. Round ends and players reveal cards.
2. Scorekeeper goes to Player 1.
3. Scorekeeper captures a photo of Player 1's 9 cards.
4. App detects cards and displays labels + confidence on the captured image.
5. App computes and displays the player's total score from detected cards.
6. Scorekeeper confirms and records Player 1 score.
7. Scorekeeper moves to Player 2 and repeats.
8. Continue until all players are scored.

## User Flow

### Scan Mode

- Screen shows live camera preview.
- Primary action button: Scan Card.
- On tap, app captures image and runs model inference.

### Review Mode

- Live preview is replaced by the captured image.
- Detection overlay is drawn on top of captured image.
- Overlay label format: card rank + confidence percentage.
- Action button switches to blue secondary button: Score - Add Up Cards.

### Reset to Next Player

- On Score - Add Up Cards tap, app returns to Scan Mode.
- Captured frame is cleared.
- Existing detections are cleared.
- Live camera preview is restored for the next player.

## Implemented Spec (Current)

### Implemented in code

- Capture, detect, and render on frozen captured frame.
- Detection overlay with bounding boxes and confidence percentages.
- Two-button state behavior:
  - Scan Card in live mode.
  - Score - Add Up Cards in review mode.
- Score button returns UI to scanning state for next player.
- Score button computes and saves the active player's score.
- Player flow advances automatically to the next player.
- After last player is scored, the next round is opened and flow wraps to Player 1.
- iOS and macOS scan entry paths are both supported (camera on iOS, gallery picker on macOS).

### Current implementation references

- `lib/screens/game/card_scan_screen.dart`
  - `_capturedImageBytes` controls Scan Mode vs Review Mode.
  - `_buildPreviewWithOverlay()` renders camera or captured image.
  - `_buildScanButton()` switches between Scan Card and Score - Add Up Cards.
  - `_scoreAndAdvance()` computes score, persists it, advances player, and returns to live preview.
  - `_resetToScanMode()` clears review data and returns to live preview.
- `lib/models/app/tflite_service_native.dart`
  - Native TFLite detection pipeline.
- `lib/models/app/tflite_service_web.dart`
  - Web ONNX detection pipeline.
- `lib/models/game/golf_score_model.dart`
  - Round/player score persistence used by scan scoring flow.

## Score Calculation Rules

The game score rules are game-style specific and are not yet finalized in this screen-level flow.

Current status:

- Card detection and review loop are implemented.
- Numeric total is computed from top-confidence detected cards.
- Per-player score is persisted for the active round.
- Player progression is implemented across all players.

## Next Integration Spec

To fully complete scoring per player, add:

1. Game-style-specific rules beyond flat rank summing (for example set/column bonuses).
2. Duplicate-detection conflict resolution (same physical card detected multiple times).
3. Optional manual correction UI before final score submit.
4. Stronger player/session binding when launched from specific game context.
5. Backend sync for multiplayer rooms when online (if required by game mode).

## Acceptance Criteria

1. A scorekeeper can evaluate all players sequentially without leaving the scan screen.
2. Each scan presents a frozen image with labeled detections.
3. Tapping Score - Add Up Cards resets the UI for the next player's scan.
4. The scored value is persisted to the active player/round before moving on.
5. App remains responsive and handles scan errors gracefully.
