#!/bin/bash

# Function to check if documents exist in the source directory
CheckDocsExist() {
  # Parameters: Source docs path
  echo "Checking if documents exist in the source directory." >&2

  # Check if the directory exists
  if [ ! -d "$FULL_SOURCE_DOCS_PATH" ]; then
    echo "Error: Directory $FULL_SOURCE_DOCS_PATH does not exist." >&2
    exit 1
  fi

  # Check if the directory is empty
  if [ ! "$(ls -A "$FULL_SOURCE_DOCS_PATH")" ]; then
    echo "Error: No files found in docs directory." >&2
    exit 1
  fi
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  # shellcheck source=/dev/null
  CheckDocsExist
fi
