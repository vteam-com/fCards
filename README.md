# VTeam Cards

A Flutter-based multiplayer card game application featuring multiple game modes and a comprehensive score keeping system.

## Features

### 🎮 Game Modes

- **9 Card Golf Game** (Classic French Cards)
  - 2 to 8 players
  - 3x3 card grid layout
  - 1 or 2 decks of cards
  - Match cards within rows and columns to reduce score

- **MiniPut Golf Game**
  - 2 to 8 players
  - 2x2 card grid layout
  - Simplified version of Golf game

- **SkyJo Game**
  - 2 to 8 players
  - 4x3 card grid layout (12 cards)
  - Custom card deck with unique scoring
  - 3-of-a-kind sets are discarded during play

- **Custom Game Mode**
  - Flexible configuration options

### 📝 Score Keeper

- Dedicated score tracking system for 9 Card Golf games
- Support for multiple players and rounds
- Keyboard input for efficient score entry
- Persistent score storage using shared preferences
- Visual indicators for winners (king crown) and losers
- Auto-add rounds functionality
- Player management with rename and delete options

### 🎯 Core Features

- **Drag and drop card interface**
- **Multiplayer support** with real-time Firebase integration
- **Game history tracking**
- **Player status management**
- **Offline play capability**
- **Cross-platform support** (Web, iOS, Android, macOS, Windows)
- **Splash screen** with professional branding
- **Responsive design** for various screen sizes
- **URL-based game joining** for easy invitations
- **Structured logging** for debugging and monitoring

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

### 📊 Score Keeper System

- Dedicated mode for tracking Scores
- Keyboard-based input for quick score entry
- Automatic round management
- Player statistics and winner identification
- Persistent data storage across app sessions

### Game Variants

#### French Cards (9 Card Golf)

- 3x3 grid (9 cards per player)
- Matches within rows and columns reduce score
- Matched set cards are not counted in final score
- 2 cards revealed at startup

#### MiniPut

- 2x2 grid (4 cards per player)
- Matches within rows and columns reduce score
- Simplified version of Golf game
- 1 card revealed at startup

#### SkyJo

- 4x3 grid (12 cards per player)
- 3-of-a-kind sets are discarded during play
- 2 cards revealed at startup
- Active scoring system

#### Custom

- Flexible configuration
- Customizable reveal counts and grid sizes

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

### Firebase configuration

1. Set up your **own Firebase project** (this repository ships with placeholder credentials only).
1. From the project root run:

   ```bash
   flutterfire configure --out=lib/models/app/firebase_options.dart
   ```

   Follow the prompts to select your Firebase project and platforms; this regenerates `lib/models/app/firebase_options.dart` with your real Firebase credentials and overwrites the placeholder content so the repository can compile. The `--out` flag guarantees the generated file lands in `lib/models/app/firebase_options.dart`, which is gitignored so personal credentials are never committed. Consult `lib/models/app/firebase_options.example.dart` for a committed reference implementation that shows the structure the CLI emits.
1. `tool/check.sh` expects `lib/models/app/firebase_options.dart` to exist without the placeholder tokens, so rerun `flutterfire configure --out=lib/models/app/firebase_options.dart` anytime you switch Firebase projects or update platforms before running the checks.
1. Protect data access through Firebase Security Rules (e.g., `database.rules.json`) rather than relying on config secrecy—every app should enforce the rules that match its authorization model.

## Project Structure

```dart
lib/
├── main.dart                 # App entry point and routing
├── models/                   # Data models and business logic
│   ├── app/                 # App-level services and configuration
│   │   ├── app_theme.dart       # App theming and styling
│   │   ├── auth_service.dart     # Firebase authentication
│   │   ├── constants_layout.dart # Sizing and layout constants
│   │   ├── constants_animation.dart # Animation/Visual constants
│   │   └── constants_card_value.dart # Card scoring and values
│   ├── card/                # Card-related logic
│   ├── game/                # Game state and backend logic
│   └── player/              # Player data models
├── screens/                  # UI screens
│   ├── main_menu.dart       # Main navigation menu
│   ├── game/                # Game-related screens and constants
│   └── keepscore/           # Score keeper screens
├── widgets/                  # Reusable UI components
│   ├── buttons/            # Glassmorphic button system (MyButton)
│   ├── cards/              # Card display components
│   ├── player/             # Player interface components
│   └── helpers/             # Generic helpers (Dialog, Keyboard, Screen)
└── utils/                   # Shared utility functions (Logger)
```

### Key Components

- **Firebase Integration**: Real-time multiplayer functionality via `backend_model.dart`.
- **Glassmorphic UI**: High-fidelity "Casino Table Top" theme using custom `MyButton` widgets.
- **Fibonacci Design System**: All layout values are snapped to the Fibonacci sequence for visual harmony.
- **Custom Keyboard**: Optimized numeric input for game scoring.
- **Responsive Design**: Intelligent layout switching for Phone, Tablet, and Desktop breakpoints.
- **State Management**: Mixed approach using `setState` for UI and `StreamBuilder` for real-time data.

## Deployment

### 🚀 CI/CD Pipeline (GitHub Actions)

The Cards app uses an automated CI/CD pipeline via GitHub Actions for continuous integration and deployment. This ensures code quality and reliable deployments.

#### Pipeline Overview

The workflow consists of two main jobs:

1. **Build and Test** (`build-and-test`)
   - ✅ Code formatting and linting
   - ✅ Automatic code fixes
   - ✅ Static analysis and type checking
   - ✅ Unit tests execution
   - ✅ Code quality analysis with fcheck
   - ✅ Flutter web build generation
   - ✅ Artifact upload for deployment

2. **Deploy** (`deploy`) - Runs only on `main`/`master` branches
   - ✅ Firebase configuration setup
   - ✅ Build artifact download
   - ✅ Firebase Hosting deployment
   - ✅ Automatic preview deployments for pull requests

#### Security Architecture

Due to the open-source nature of this project, sensitive configuration files are **NOT** committed to the repository. Instead, they're securely stored as GitHub secrets:

**Required GitHub Secrets:**

| Secret Name                               | Purpose                         | Content                                |
| ----------------------------------------- | ------------------------------- | -------------------------------------- |
| `FIREBASE_JSON`                           | Firebase Hosting configuration  | Base64-encoded `firebase.json`         |
| `FIREBASE_OPTIONS_FILE`                   | Firebase project credentials    | Base64-encoded `firebase_options.dart` |
| `FIREBASE_SERVICE_ACCOUNT_*PROJECT_NAME*` | Firebase deployment permissions | Service account JSON key               |

**Important Note for Forks:**
This repository is open-source and intended for community contributions. If you fork this project:

1. **Create Your Own Firebase Project**: Set up a separate Firebase project for your fork
2. **Update Project References**: Replace `vteam-cards` with your project ID in deployment configurations
3. **Generate Your Own Secrets**: Create new GitHub secrets using your Firebase project credentials
4. **Keep Credentials Private**: Never commit Firebase credentials or service account keys to the repository

**Why This Complexity?**

1. **Security**: Firebase credentials and service account keys contain sensitive information that should never be committed to a public repository
2. **Compliance**: Prevents accidental exposure of production credentials
3. **Flexibility**: Different environments can use different configurations
4. **Access Control**: Only repository maintainers with secret access can deploy
5. **Open Source Friendly**: Allows anyone to fork and deploy using their own Firebase project

**Setting Up Secrets for Your Fork:**

```bash
# Upload firebase.json (base64 encoded)
gh secret set FIREBASE_JSON --body "$(cat firebase.json | base64)"

# Upload firebase_options.dart (base64 encoded)  
gh secret set FIREBASE_OPTIONS_FILE --body "$(cat lib/models/app/firebase_options.dart | base64)"

# Upload Firebase service account key (replace with your project name)
gh secret set FIREBASE_SERVICE_ACCOUNT_YOUR_PROJECT --body "$(cat service-account-key.json | base64)"
```

**Note**: The `vteam-cards` Firebase project is specific to the original repository maintainers and should not be used by forks. Each fork should use its own Firebase project for deployment.

#### Manual Deployment

For local deployments or when CI/CD is not available:

##### Prerequisites firebase

1. **Install Firebase CLI** (if not already installed):

   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:

   ```bash
   firebase login
   ```

##### Initial Firebase Setup (One-time)

If Firebase hasn't been initialized in the project:

1. **Initialize Firebase**:

   ```bash
   firebase init hosting
   ```

   - Select: "Use an existing project"
   - Choose: "vteam-cards"
   - Set region: "us-central1" (default)
   - Answer "No" to GitHub integration (unless desired)

2. **Enable Firebase Web Frameworks** (required for Flutter Web):

   ```bash
   firebase experiments:enable webframeworks
   ```

##### Deployment Process

###### Option 1: Using the Deploy Script (Recommended)**

The project includes an automated deployment script:

```bash
./tool/deploy.sh
```

This script will:

- Clean the project (`flutter clean`)
- Get dependencies (`flutter pub get`)
- Run quality checks (`./tool/check.sh`)
- Build the web app (`flutter build web --release`)
- Deploy to Firebase (`firebase deploy --project vteam-cards`)

###### Option 2: Manual Deployment**

1. **Clean and build**:

   ```bash
   flutter clean
   flutter pub get
   flutter build web --release
   ```

2. **Deploy to Firebase**:

   ```bash
   firebase deploy --project vteam-cards
   ```

#### Deployment URLs

- **Live App**: <https://vteam-cards.web.app>
- **Firebase Console**: <https://console.firebase.google.com/project/vteam-cards/overview>
- **Project ID**: vteam-cards

#### Troubleshooting

**Common Issues:**

1. **"Not in a Firebase app directory"**:
   - Run `firebase init hosting` first
   - Ensure `firebase.json` exists in project root

2. **"Permission denied"**:
   - Ensure you're logged in: `firebase login`
   - Verify you have access to the vteam-cards project

3. **Build failures**:
   - Run `flutter doctor` to check environment
   - Ensure all dependencies are up to date: `flutter pub upgrade`

4. **Firebase CLI outdated**:
   - Update: `npm update -g firebase-tools`

#### Deployment Best Practices

1. **Always run tests before deployment**:

   ```bash
   ./tool/check.sh
   ```

2. **Check the live app** after deployment at <https://vteam-cards.web.app>

3. **Monitor deployment** in Firebase Console for any issues

4. **Keep Firebase CLI updated** for latest features and bug fixes

## Firebase Setup

To enable multiplayer functionality:

1. Enable Firebase experiments:

   ```bash
   firebase experiments:enable webframeworks
   ```

2. Update `firebase_options.dart` with your Firebase project details, or:

   ```bash
   flutterfire configure
   ```

3. The app supports offline play when Firebase is not available.

## Technology Stack

- **Flutter**: Cross-platform UI framework
- **Dart 3.10.8**: Programming language
- **Firebase**: Real-time database and authentication
- **Firebase Auth**: Anonymous user authentication
- **Shared Preferences**: Local data persistence
- **The Splash**: Professional splash screen implementation
- **Logger**: Structured logging system with multiple levels and test silencing

### Development Tools

- **fcheck**: Code quality and magic number detection (automatically updated in check.sh)
- **lakos + graphviz**: Dependency visualization
- **flutter_launcher_icons**: Multi-platform icon generation

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
