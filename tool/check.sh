#!/bin/sh
set -euo pipefail

FIREBASE_OPTIONS_FILE="lib/models/app/firebase_options.dart"

echo --- Firebase config
if [ ! -f "$FIREBASE_OPTIONS_FILE" ]; then
  echo "ERROR: $FIREBASE_OPTIONS_FILE is missing (the file is intentionally gitignored)."
  echo "       Start from the committed template at lib/models/app/firebase_options.example.dart and run"
  echo "       'flutterfire configure --out=$FIREBASE_OPTIONS_FILE' from the project root to generate it."
  exit 1
fi

if grep -q 'YOUR_PROJECT_ID' "$FIREBASE_OPTIONS_FILE"; then
  cat <<'EOF'
Firebase configuration still contains the placeholder values committed for example purposes.
Regenerate the file for your own Firebase project with:

    flutterfire configure --out=lib/models/app/firebase_options.dart

Then rerun this script (or stage the generated `lib/models/app/firebase_options.dart` file) so the checks can pass.
EOF
  exit 1
fi

echo --- Pub Get
flutter pub get > /dev/null

echo --- Pub Upgrade
flutter pub upgrade > /dev/null

echo --- Pub Outdated
flutter pub outdated

echo --- Format sources
dart format . 2>&1 | sed 's/^/    /'
dart fix --apply 2>&1 | sed 's/^/    /'

echo --- Analyze
flutter analyze lib test --no-pub 2>&1 | sed 's/^/    /'

echo --- Test
echo "    Running tests..."
flutter test --reporter=compact --no-pub

echo --- fCheck
# Use an ephemeral private directory for this session's fcheck installation
# (avoid contaminating the user's global pub cache and avoid version conflicts)
mkdir -p "$PWD/.dart_tool/fcheck_pub_cache"
export PUB_CACHE="$PWD/.dart_tool/fcheck_pub_cache"

dart pub global activate fcheck "1.1.0" > /dev/null
dart pub global run fcheck --svg --fix --list full .
