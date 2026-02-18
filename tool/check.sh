#!/bin/sh
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
flutter pub get > /dev/null || { echo "Pub get failed"; exit 1; }
echo --- Pub Upgrade
flutter pub upgrade > /dev/null
echo --- Pub Outdated
flutter pub outdated

echo --- Format sources
dart format . | sed 's/^/    /'
dart fix --apply | sed 's/^/    /'

echo --- Analyze
flutter analyze lib test --no-pub | sed 's/^/    /'

echo --- Test
echo "    Running tests..."
flutter test --reporter=compact --no-pub

echo --- fCheck
# Use an ephemeral private directory for this session's fcheck installation
# (avoid contaminating the user's global pub cache and avoid version conflicts)
mkdir -p "$PWD/.dart_tool/fcheck_pub_cache"
export PUB_CACHE="$PWD/.dart_tool/fcheck_pub_cache"

echo --- Graph Dependencies
tool/graph.sh | sed 's/^/    /'


# Install the pinned version into the isolated cache, then run it.
# Note: `dart pub cache exec` doesn't exist on all Dart SDK versions; `pub global run` does.
FCHECK_PINNED_VERSION="0.9.14"
FCHECK_LATEST_VERSION="$(curl -fsSL https://pub.dev/api/packages/fcheck 2>/dev/null | python3 -c 'import json,sys
data=json.load(sys.stdin)
print(data.get("latest", {}).get("version", ""))
' 2>/dev/null)"

if [ -n "$FCHECK_LATEST_VERSION" ] && [ "$FCHECK_LATEST_VERSION" != "$FCHECK_PINNED_VERSION" ]; then
  BANNER_COLOR='\033[1;97;41m'
  BANNER_RESET='\033[0m'
  echo "${BANNER_COLOR}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${BANNER_RESET}"
  echo "${BANNER_COLOR}!!${BANNER_RESET}  FCHECK UPDATE AVAILABLE: $FCHECK_PINNED_VERSION -> $FCHECK_LATEST_VERSION"
  echo "${BANNER_COLOR}!!${BANNER_RESET}  Consider bumping FCHECK_PINNED_VERSION in tool/check.sh to keep tooling current."
  echo "${BANNER_COLOR}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${BANNER_RESET}"
elif [ -n "$FCHECK_LATEST_VERSION" ]; then
  echo "    fcheck is up to date: $FCHECK_PINNED_VERSION"
else
  echo "    fcheck latest version check skipped (no network or pub.dev unavailable)"
fi

dart pub global activate fcheck "$FCHECK_PINNED_VERSION" > /dev/null

dart pub global run fcheck --svg --svgfolder --fix --list full .

