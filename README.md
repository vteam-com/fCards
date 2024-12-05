# Card games

A Flutter Base Multiplayer Card Game.

## Features

- 9 Card Golf Game
  - 2 to 4 players
  - 1 or 2 deck of card
- 12 Card Skyjo Game
  - 2 to 8 players
  - Custom card deck
- Drag and drop cards

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
