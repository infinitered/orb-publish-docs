#! /bin/bash

# Parameters: Source docs path
echo "Checking if documents exist in the source directory."
if [ ! "$(ls -A "$SOURCE_DOCS_PATH")" ]; then
  echo "Error: No files found in docs directory."
  exit 1
fi
