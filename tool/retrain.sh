#!/usr/bin/env bash
# retrain.sh — Download correction samples from Firebase and fine-tune the model.
#
# Usage:
#   tool/retrain.sh [--fresh|--continue]
#
# Prerequisites:
#   - firebase-admin installed: pip install firebase-admin
#   - Python venv activated: source /Users/jp/src/github/models/.venv/bin/activate
#   - GOOGLE_APPLICATION_CREDENTIALS set, or run from a machine with Firebase CLI auth
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VENV="/Users/jp/src/github/models/.venv"
OUT_DIR="/tmp/retrain_output"
FRESH_MODEL="$PROJECT_ROOT/tmp/models/mustafa_cards.pt"
CONTINUE_MODEL="$OUT_DIR/runs/retrain/weights/best.pt"

show_help() {
  cat <<'EOF'
Usage: tool/retrain.sh [--fresh|--continue]

Options:
  --fresh      Start from the canonical base checkpoint.
  --continue   Start from the latest retrain checkpoint if available.
  -h, --help   Show this help.

Default mode is --fresh for reproducibility.
EOF
}

MODE="fresh"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --fresh)
      MODE="fresh"
      shift
      ;;
    --continue)
      MODE="continue"
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      show_help >&2
      exit 1
      ;;
  esac
done

MODEL_PATH="$FRESH_MODEL"
if [[ "$MODE" == "continue" ]]; then
  if [[ -f "$CONTINUE_MODEL" ]]; then
    MODEL_PATH="$CONTINUE_MODEL"
    echo "--- Using continue checkpoint: $MODEL_PATH"
  else
    echo "--- Continue checkpoint not found, falling back to fresh model"
  fi
else
  echo "--- Using fresh base model: $MODEL_PATH"
fi

echo "--- Activate venv"
# shellcheck disable=SC1091
source "$VENV/bin/activate"

echo "--- Run retrain pipeline"
python3 "$SCRIPT_DIR/retrain.py" \
  --project   "vteam-cards" \
  --model     "$MODEL_PATH" \
  --labels    "$PROJECT_ROOT/assets/models/labels.txt" \
  --out-dir   "$OUT_DIR" \
  --epochs    20 \
  --imgsz     640 \
  --tflite    "$PROJECT_ROOT/assets/models/card_detector.tflite" \
  --onnx      "$PROJECT_ROOT/assets/models/card_detector.onnx"

echo "--- Done. Rebuilt models copied to assets/models/"
