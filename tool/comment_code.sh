#!/bin/bash

# Set directories
SOURCE_DIR="../lib"
OUTPUT_DIR="../lib" # Overwrite files directly, or change if you prefer separate output

# Loop through each Dart file
for file in $(find "$SOURCE_DIR" -name "*.dart"); do
  echo "Processing $file..."
  python3 comment_code.py "$file"
done

echo "All files have been processed!"
