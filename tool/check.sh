#!/bin/sh
set -euo pipefail

RUN_CLEAN=0
if [ "${1:-}" = "--clean" ]; then
  RUN_CLEAN=1
  shift
fi

if [ "$#" -ne 0 ]; then
  echo "Usage: $0 [--clean]"
  exit 1
fi

FIREBASE_OPTIONS_FILE="lib/models/app/firebase_options.dart"
COVERAGE_DIR="coverage"
COVERAGE_UNITS_FILE="$COVERAGE_DIR/lcov_units.info"
COVERAGE_FILE="$COVERAGE_DIR/lcov.info"
COVERAGE_SUMMARY_FILE="$COVERAGE_DIR/cc.txt"

if [ "$RUN_CLEAN" -eq 1 ]; then
  echo --- Clean
  sh ./tool/clean.sh
fi

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

 
echo --- Analyze
flutter analyze lib test --no-pub 2>&1 | sed 's/^/    /'

echo --- Font size policy
sh ./tool/check_font_sizes.sh

echo --- Test
echo "    Running tests with coverage..."
mkdir -p "$COVERAGE_DIR"
flutter test --coverage --coverage-path="$COVERAGE_UNITS_FILE" --reporter=compact --no-pub

echo --- Coverage
lcov -a "$COVERAGE_UNITS_FILE" -o "$COVERAGE_FILE"
lcov --summary "$COVERAGE_FILE" > "$COVERAGE_SUMMARY_FILE"
cat "$COVERAGE_SUMMARY_FILE"

echo --- fCheck
# Use an ephemeral private directory for this session's fcheck installation
# (avoid contaminating the user's global pub cache and avoid version conflicts)
mkdir -p "$PWD/.dart_tool/fcheck_pub_cache"
export PUB_CACHE="$PWD/.dart_tool/fcheck_pub_cache"

dart pub global activate fcheck "1.4.1" > /dev/null
dart pub global run fcheck --svg --fix --list full

echo --- Format sources
dart format ./lib
dart format ./test
