#!/usr/bin/env bash
# retrain.sh — Download correction samples from Firebase and fine-tune the model.
#
# Usage:
#   tool/retrain.sh
#
# Prerequisites:
#   - firebase-admin installed: pip install firebase-admin
#   - Python venv activated: source /Users/jp/src/github/models/.venv/bin/activate
#   - GOOGLE_APPLICATION_CREDENTIALS set, or run from a machine with Firebase CLI auth
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VENV="/Users/jp/src/github/models/.venv"

echo "--- Activate venv"
# shellcheck disable=SC1091
source "$VENV/bin/activate"

echo "--- Run retrain pipeline"
python3 "$SCRIPT_DIR/retrain.py" \
  --project   "vteam-cards" \
  --model     "$PROJECT_ROOT/tmp/models/mustafa_cards.pt" \
  --labels    "$PROJECT_ROOT/assets/models/labels.txt" \
  --out-dir   "/tmp/retrain_output" \
  --epochs    20 \
  --imgsz     640 \
  --tflite    "$PROJECT_ROOT/assets/models/card_detector.tflite" \
  --onnx      "$PROJECT_ROOT/assets/models/card_detector.onnx"

echo "--- Done. Rebuilt models copied to assets/models/"
