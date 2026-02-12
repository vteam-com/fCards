# Agent Guide for VTeam Cards

Welcome, Agent! This document outlines the rules, guidelines, and philosophical pillars of the VTeam Cards project. Follow these instructions to ensure consistency and quality.

## 🎨 Design Philosophy

### Arcade / Casino Table Top Theme

The visual identity of this app relies heavily on a classic casino table top card game theme.

- **Effect**: Frosted 3D texture, raised look with blur, semi-transparent backgrounds, and subtle borders.
- **Implementation**:
  - Use `MyButtonRectangle` (in `lib/widgets/buttons/my_button_rectangle.dart`) as the foundation for most UI actions.
  - Do **NOT** use standard Material buttons (`ElevatedButton`, `OutlinedButton`, `TextButton`) for primary UI actions unless specifically requested or inside standard dialogs where they fit better.
  - **Preferred Widgets**:
    - `MyButtonRectangle`: Standard button for most actions.
    - `MyButtonRound`: Circular buttons (e.g., for icons).
  - **Styling API**:    
    - White border opacity: `ConstAnimation.borderOpacity`
    - Blur sigma: `ConstAnimation.blurSigma`

### Layout & Spacing

- **Consistency is King**: Use predefined constants for all spacing, sizing, and fonts.
- **Source of Truth**: Constants are organized across multiple files:
  - `lib/models/app/constants_layout.dart` - `ConstLayout` class for layout, spacing, sizing
  - `lib/models/app/constants_animation.dart` - `ConstAnimation` class for animation and visual effects
  - `lib/models/app/constants_card_value.dart` - `ConstCardValue` class for card values and offsets
  - `lib/screens/game/game_style_constants.dart` - `GameStyleConstants` class for game-specific values
- **Usage Examples**:
  - `ConstLayout.sizeS`, `sizeM`, `sizeL` for spacing/sizing
  - `ConstLayout.radiusL`, `radiusM` for border radius
  - `ConstLayout.textS`, `textM`, `textXL` for font sizes
  - `ConstAnimation.blurSigma`, `borderOpacity` for glass effects
  - `ConstCardValue.skyjoMinValue`, `golfJokerValue` for card values

## 🛠️ Code Standards & Quality

### The "No Magic Numbers" Rule

- **Strictly Enforced**: The CI/CD pipeline uses `fcheck` to ban magic numbers.
- **Rule**: Do not use raw numbers (e.g., `16.0`, `44`, `0.5`) directly in widgets.
- **Solution**: Define them in `ConstLayout` or a local `...Constants` class.

### Fibonacci Numbers Only

- **Rule**: All layout values (sizes, padding, margins, heights, widths) **MUST** be Fibonacci numbers (1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144...).
- **Snap to Closest**: If a design calls for a value like "48" or "100", snap it to the closest Fibonacci number (e.g., 55 or 89).

### Lints & Static Analysis

- **Command**: `flutter analyze` must pass with **zero issues**.
- **Imports**: Remove unused imports immediately.
- **Types**: Always specify types for function parameters and return values.

### Verification Tool

- **Script**: `./tool/check.sh`
- **Mandatory**: This script **MUST** be run before every commit or user review.
- **Strictness**: `fcheck` (magic number detection) warnings are **unacceptable**. The target is **zero warnings**.
- **What it does**: Runs formatting, strict analysis, and `fcheck`.

## 🏗️ Architecture

- **State Management**: Generally uses `setState` for local UI state and `StreamBuilder` for Firebase data.
- **Backend**: Firebase Realtime Database. Logic resides in `lib/models/game/backend_model.dart`.
- **Authentication**: `AuthService` class in `lib/models/app/auth_service.dart`.
- **Folder Structure**:
  - `lib/models/`: Business logic and data classes, organized by domain:
    - `models/app/`: App-level constants, theme, and services
    - `models/card/`: Card models and logic
    - `models/game/`: Game state and backend models
    - `models/player/`: Player models
  - `lib/screens/`: Full-page views and screen-specific constants
  - `lib/widgets/`: Reusable components
    - `widgets/buttons/`: Custom button widgets (`MyButton`, `MyButtonRectangle`, `MyButtonRound`)
    - `widgets/helpers/`: Generic helpers (`Screen`, `Dialog`, `InputKeyboard`, `WiggleWidget`)
    - `widgets/player/`: Player-specific widgets
    - `widgets/cards/`: Card-related widgets
  - `lib/utils/`: Shared utilities (`Logger`)

## 🚀 Release Process

When asked to prepare a release (patch, minor, or major):

1. **Update Version**:
    - Edit `pubspec.yaml`: Bump `version: x.y.z`.
2. **Update Changelog**:
    - Edit `CHANGELOG.md`: Add a new section `## x.y.z` at the top.
    - List succinct bullet points of changes.
3. **Update Readme**:
    - Check `README.md` for any version-specific references (e.g., Dart SDK version) and update if necessary.

## 🤖 Agent Workflow Checklist

1. **Understand**: Read the file context and `AGENTS.md` (this file).
2. **Plan**: Create an `implementation_plan.md` for complex changes.
3. **Implement**: Make changes. **Use `MyButtonRectangle` for buttons.**
4. **Verify**: Run `./tool/check.sh`. Fix magic numbers.
5. **Refine**: Ensure UI matches the Arcade / Table Top style.
