# Card Pickup from Deck - Codebase Analysis

## Summary

Card picking from the deck is triggered through a **tap gesture handler** on the `CardPileWidget`. The mechanism is straightforward but has one potential issue worth noting.

---

## How Card Pickup is Triggered

### 1. **Primary Trigger: GestureDetector.onTap**

**File**: [lib/widgets/cards/card_pile_widget.dart](lib/widgets/cards/card_pile_widget.dart#L77)

```dart
GestureDetector(
  onTap: onDraw,  // Line 77
  child: Stack(...)
)
```

The `CardPileWidget` wraps its card pile in a `GestureDetector` with an `onTap` handler that directly calls the `onDraw` callback (a `VoidCallback?`).

### 2. **onDraw Callback Implementations**

The `onDraw` callback is passed into `CardPileWidget` from parent widgets and has multiple implementations:

#### Implementation A: Call `selectTopCardOfDeck` (Lines 120, 136, 187)

**File**: [lib/widgets/player/player_zone_cta_widget.dart](lib/widgets/player/player_zone_cta_widget.dart#L120-L139)

```dart
// Draw pile (Main deck)
CardPileWidget(
  cards: gameModel.deck.cardsDeckPile,
  // ...
  onDraw: () => gameModel.selectTopCardOfDeck(
    context,
    fromDiscardPile: false,
    notYourTurnMessage: localizations.notYourTurn,
    noCardsAvailableMessage: localizations.noCardsAvailableToDraw,
  ),
),

// Discard pile
CardPileWidget(
  cards: gameModel.deck.cardsDeckDiscarded,
  // ...
  onDraw: () => gameModel.selectTopCardOfDeck(
    context,
    fromDiscardPile: true,
    notYourTurnMessage: localizations.notYourTurn,
    noCardsAvailableMessage: localizations.noCardsAvailableToDraw,
  ),
),
```

#### Implementation B: Custom Logic (Line 232)

**File**: [lib/widgets/player/player_zone_cta_widget.dart](lib/widgets/player/player_zone_cta_widget.dart#L232-L239)

```dart
CardPileWidget(
  cards: gameModel.deck.cardsDeckDiscarded,
  scale: ConstLayout.scaleTiny,
  onDraw: () {
    // Player has discarded the top deck revealed card
    // They now have to turn over one of their hidden cards
    gameModel.deck.cardsDeckDiscarded.add(
      gameModel.deck.cardsDeckPile.removeLast(),
    );
    gameModel.gameState = GameStates.revealOneHiddenCard;
  },
  // ...
),
```

### 3. **selectTopCardOfDeck Method**

**File**: [lib/models/game/game_model.dart](lib/models/game/game_model.dart#L401-L420)

```dart
void selectTopCardOfDeck(
  BuildContext context, {
  required bool fromDiscardPile,
  String? notYourTurnMessage,
  String? noCardsAvailableMessage,
}) {
  // Validates it's the player's turn and correct game state
  if (gameState != GameStates.pickCardFromEitherPiles) {
    showTurnNotification(context, resolvedNotYourTurnMessage);
    return;
  }

  // Transitions game state based on which pile
  if (fromDiscardPile && deck.cardsDeckDiscarded.isNotEmpty) {
    gameState = GameStates.swapDiscardedCardWithAnyCardsInHand;
  } else if (!fromDiscardPile && deck.cardsDeckPile.isNotEmpty) {
    gameState = GameStates.swapTopDeckCardWithAnyCardsInHandOrDiscard;
  } else {
    showTurnNotification(context, resolvedNoCardsAvailableMessage);
  }
}
```

---

## Game States Flow

```text
pickCardFromEitherPiles
  ↓ (onTap → selectTopCardOfDeck)
  ├─ From Main Deck → swapTopDeckCardWithAnyCardsInHandOrDiscard
  └─ From Discard → swapDiscardedCardWithAnyCardsInHand
```

---

## Issues Found

### ⚠️ **ISSUE 1: Missing Import for `dragSource` Function**

**Severity**: Low to Medium (Not currently breaking, but poor practice)

**Location**: [lib/widgets/cards/card_pile_widget.dart](lib/widgets/cards/card_pile_widget.dart#L94)

**Problem**:

- `CardPileWidget` calls `dragSource(card)` on line 94 when `isDragSource` is true
- The `dragSource` function is defined in [card_widget.dart](lib/widgets/cards/card_widget.dart#L80) as a top-level function
- `card_pile_widget.dart` **does not explicitly import** `dragSource`
- Only imports `CardWidget` from `card_widget.dart`

**Current Code**:

```dart
// card_pile_widget.dart
import 'package:cards/widgets/cards/card_widget.dart';  // ← only this

// Later in code:
child: isDragSource
    ? dragSource(card)  // ← dragSource not imported!
    : CardWidget(card: card, onDropped: onDragDropped),
```

**Why It Works**: The function is at the package level and likely gets resolved, but it's **not following best practices**.

**Recommendation**: Add explicit import:

```dart
import 'package:cards/widgets/cards/card_widget.dart';  // Also imports dragSource implicitly
```

Or explicitly separate if it moves:

```dart
import 'package:cards/widgets/cards/card_widget.dart' show CardWidget, dragSource;
```

---

### ✅ **ISSUE 2: onDraw Callback Can Be Null**

**Severity**: Low (Properly handled)

**Location**: [lib/widgets/cards/card_pile_widget.dart](lib/widgets/cards/card_pile_widget.dart#L37)

**Status**: This is **NOT an issue** — properly handled.

- `onDraw` is defined as `VoidCallback?` (nullable)
- The `GestureDetector` safely handles null callbacks
- Tests verify this works: `card_pile_widget_test.dart` line 34 tests "handles null onDraw callback"

---

### ✅ **ISSUE 3: Multiple onDraw Implementations - No Conflicts**

**Severity**: None

All three usages of `onDraw` in [player_zone_cta_widget.dart](lib/widgets/player/player_zone_cta_widget.dart) serve different game states:

- Line 120-127: Main deck draw during `pickCardFromEitherPiles`
- Line 136-143: Discard pile draw during `pickCardFromEitherPiles`
- Line 232-239: Discard pile tap during swap state (moves card to discard, transitions state)

Each is contextually appropriate with no conflicts.

---

## Call Chain Summary

```text
User taps CardPileWidget
    ↓
GestureDetector.onTap fires
    ↓
onDraw callback invoked
    ↓
selectTopCardOfDeck() called
    ↓
Validates game state & turn
    ↓
Updates gameState to either:
  - swapTopDeckCardWithAnyCardsInHandOrDiscard (main deck)
  - swapDiscardedCardWithAnyCardsInHand (discard pile)
    ↓
GameModel notifies listeners
    ↓
UI updates to show next action options
```

---

## Files Involved

| File                                                                                             | Role                                           |
| ------------------------------------------------------------------------------------------------ | ---------------------------------------------- |
| [lib/widgets/cards/card_pile_widget.dart](lib/widgets/cards/card_pile_widget.dart)               | Renders card pile with tap gesture             |
| [lib/widgets/player/player_zone_cta_widget.dart](lib/widgets/player/player_zone_cta_widget.dart) | Provides `onDraw` callbacks                    |
| [lib/models/game/game_model.dart](lib/models/game/game_model.dart)                               | `selectTopCardOfDeck()` logic                  |
| [lib/widgets/cards/card_widget.dart](lib/widgets/cards/card_widget.dart)                         | Defines `dragSource()` function (import issue) |

---

## Recent Changes

**Latest commits** (git log):

- `63dd279` - refactor onboarding
- `7cdc886` - version: 1.11.5 - fCheck 1.1.0
- `0e2955c` - fCheck 1.0.9 - fix all hard coded strings
- `f8a31a8` - animate revealing of the swap card

No recent changes directly to deck pickup mechanism itself.

---

## Recommendation

**Fix the missing import** in [card_pile_widget.dart](lib/widgets/cards/card_pile_widget.dart) to explicitly import the `dragSource` function for code clarity and maintainability. This is minor but improves code quality.
