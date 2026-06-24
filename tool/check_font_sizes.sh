#!/bin/sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$PROJECT_ROOT"

if command -v rg >/dev/null 2>&1; then
  font_size_lines=$(rg -n --glob '*.dart' 'fontSize\s*:' lib || true)
else
  font_size_lines=$(grep -RIn --include='*.dart' 'fontSize[[:space:]]*:' lib || true)
fi

if [ -z "$font_size_lines" ]; then
  exit 0
fi

violations=$(printf '%s\n' "$font_size_lines" |
  grep -vE ':[0-9]+:[[:space:]]*(//|/\*|\*)' |
  grep -vE 'fontSize[[:space:]]*:[[:space:]]*ConstLayout\.(textS|textM|textL)([^[:alnum:]_]|$)' || true)

if [ -n "$violations" ]; then
  cat <<'EOF'
ERROR: Found fontSize assignments that do not use ConstLayout.textS, ConstLayout.textM, or ConstLayout.textL.
Update the call sites to use one of those constants or rely on the shared text theme.
EOF
  printf '%s\n' "$violations"
  exit 1
fi