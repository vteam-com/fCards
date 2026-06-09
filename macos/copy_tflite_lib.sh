#!/bin/bash
# This script copies the TensorFlow Lite C library into the app bundle.
# It is called as a Run Script build phase in the macOS Xcode project.
#
# UNLOCALIZED_RESOURCES_FOLDER_PATH is the correct modern Xcode variable
# (RESOURCES_FOLDER_PATH is deprecated and empty in Xcode 14+).

RESOURCES_DIR="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
TFLITE_LIB_SOURCE="${HOME}/.pub-cache/hosted/pub.dev/tflite_flutter-0.12.1/macos/libtensorflowlite_c-mac.dylib"

# Create Resources directory if it doesn't exist
mkdir -p "${RESOURCES_DIR}"

# Copy the library if source exists at the expected version path
if [ -f "${TFLITE_LIB_SOURCE}" ]; then
  cp "${TFLITE_LIB_SOURCE}" "${RESOURCES_DIR}/"
  echo "✓ Copied TensorFlow Lite library to ${RESOURCES_DIR}"
else
  echo "⚠ WARNING: TensorFlow Lite library not found at ${TFLITE_LIB_SOURCE}"
  # Fall back to any installed tflite_flutter version
  TFLITE_LIB_ALT=$(find "${HOME}/.pub-cache" -name "libtensorflowlite_c-mac.dylib" -path "*/tflite_flutter-*/macos/*" 2>/dev/null | head -1)
  if [ -n "${TFLITE_LIB_ALT}" ]; then
    cp "${TFLITE_LIB_ALT}" "${RESOURCES_DIR}/"
    echo "✓ Copied TensorFlow Lite library from: ${TFLITE_LIB_ALT}"
  else
    echo "✗ ERROR: libtensorflowlite_c-mac.dylib not found anywhere in pub-cache"
    exit 1
  fi
fi
