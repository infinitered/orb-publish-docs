#! /bin/bash

# Function to clear the target repository
ClearTarget() {
  echo "Clearing the target repository at: $FULL_TARGET_DOCS_PATH/$PROJECT_NAME" >&2

  # Check if the target path exists
  if [ -d "$FULL_TARGET_DOCS_PATH/$PROJECT_NAME" ]; then
    # Remove all content at the target path
    rm -rf "${FULL_TARGET_DOCS_PATH:?}/$PROJECT_NAME"
    echo "Existing docs at ${FULL_TARGET_DOCS_PATH:?}/$PROJECT_NAME removed." >&2
  else
    echo "The target directory does not yet exist and will be created." >&2
  fi
}

# Function to copy documents to the target repository
CopyDocs() {
  echo "Copying documents to the target repository." >&2
  echo "Source: $FULL_SOURCE_DOCS_PATH" >&2
  echo "Destination: $FULL_TARGET_DOCS_PATH" >&2

  echo "Clearing the target repository..." >&2
  ClearTarget

  echo "Files to be copied:" >&2
  # Log the list of files to be copied
  find "$FULL_SOURCE_DOCS_PATH" -type f -print >&2
  echo "----" >&2

  echo "Copying files..." >&2
  cp -R "$FULL_SOURCE_DOCS_PATH" "$FULL_TARGET_DOCS_PATH/$PROJECT_NAME"
  echo "Documents copied successfully." >&2
}

# Check if the script is being sourced or executed directly
ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  CopyDocs
fi

