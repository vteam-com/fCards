#!/bin/bash
# This script copies the TensorFlow Lite C library into the app bundle
# It's called as a build phase in the macOS build process

RESOURCES_DIR="${BUILT_PRODUCTS_DIR}/${RESOURCES_FOLDER_PATH}"
TFLITE_LIB_SOURCE="${HOME}/.pub-cache/hosted/pub.dev/tflite_flutter-0.12.1/macos/libtensorflowlite_c-mac.dylib"

# Create Resources directory if it doesn't exist
mkdir -p "${RESOURCES_DIR}"

# Copy the library if source exists
if [ -f "${TFLITE_LIB_SOURCE}" ]; then
  cp "${TFLITE_LIB_SOURCE}" "${RESOURCES_DIR}/"
  echo "✓ Copied TensorFlow Lite library to app bundle"
else
  echo "⚠ WARNING: TensorFlow Lite library not found at ${TFLITE_LIB_SOURCE}"
  # Try to find it in alternative locations
  TFLITE_LIB_ALT=$(find "${HOME}/.pub-cache" -name "libtensorflowlite_c-mac.dylib" -path "*/tflite_flutter-*/macos/*" 2>/dev/null | head -1)
  if [ -n "${TFLITE_LIB_ALT}" ]; then
    cp "${TFLITE_LIB_ALT}" "${RESOURCES_DIR}/"
    echo "✓ Copied TensorFlow Lite library from: ${TFLITE_LIB_ALT}"
  fi
fi
