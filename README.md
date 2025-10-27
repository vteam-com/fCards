# Card games

A Flutter Base Multiplayer Card Game.

## Features

- **9 Card Golf Game** (Classic Golf)
  - 2 to 4 players
  - 1 or 2 decks of cards
  - 3x3 card grid layout
- **MiniPut Golf Game**
  - 2 to 8 players
  - 2x2 card grid layout
- **12 Card SkyJo Game**
  - 2 to 8 players
  - Custom card deck
  - 4x3 card grid layout
- **Drag and drop cards**

## Game Mechanics & Scoring Systems

### 🎯 Active Evaluation (SkyJo)
- Cards are physically removed from players' hands during gameplay
- When a player forms sets of 3 cards with the same rank, those cards are discarded
- Player hands change composition throughout the game
- Scoring happens continuously as cards are eliminated

### 🏌️ Passive Scoring (Golf-Style Games)
- Card layout remains unchanged during gameplay
- Scoring calculated based on final revealed card positions
- Matched cards (same rank) don't contribute to final score
- Scoring occurs after all cards are revealed

### Game Variants

#### French Cards (9 Card Golf)
- 3x3 grid (9 cards per player)
- Matches within rows and columns reduce score
- Matched set cards are not counted in final score

#### MiniPut
- 2x2 grid (4 cards per player)
- Matches within rows and columns reduce score
- Simplified version of Golf game

#### SkyJo
- 4x3 grid (12 cards per player)
- 3-of-a-kind sets are discarded during play

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio / VS Code with Flutter extension

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/vteam-com/cards.git
   ```

1. Navigate to the project directory:

   ```bash
   cd cards
   ```

1. Install dependencies:

   ```bash
   flutter pub get
   ```

1. Run the app:

   ```bash
   flutter run
   ```

## Project Structure

- `lib/`: Contains the Dart source code
- `assets/`: Static assets including JSON data and images

## Firebase

- Enable experiments
```firebase experiments:enable webframeworks```

- Edit and update the file ```firebase_options.dart``` with your firebase project details.
- or Run this command to generate new private API for your deployment ```flutterfire configure```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the excellent framework
- Contributors and open-source projects that inspired this app

## Layer Dependency Diagram

![layers.svg](layers.svg)

## Graph Call

install

```dart pub global activate lakos```

```brew install graphviz```

run
```./graph.sh```

![graph.svg](graph.svg)
