#! /bin/bash

ClearTarget() {
  echo "Clearing the target repository at: $FULL_TARGET_DOCS_PATH/$PROJECT_NAME"

  # Check if the target path exists
  if [ -d "$FULL_TARGET_DOCS_PATH/$PROJECT_NAME" ]; then
    # Remove all content at the target path
    rm -rf "${FULL_TARGET_DOCS_PATH:?}/$PROJECT_NAME"
    echo "Existing docs at ${FULL_TARGET_DOCS_PATH:?}/$PROJECT_NAME removed."
  else
    echo "The target directory does not yet exist and will be created."
  fi
}

CopyDocs() {
  echo "Copying documents to the target repository."
  echo "Source: $FULL_SOURCE_DOCS_PATH"
  echo "Destination: $FULL_TARGET_DOCS_PATH"

  echo "Clearing the target repository..."
  ClearTarget

  echo "Files to be copied:"
  # Log the list of files to be copied
  find "$FULL_SOURCE_DOCS_PATH" -type f -print
  echo "----"

  echo "Copying files..."
  cp -R "$FULL_SOURCE_DOCS_PATH" "$FULL_TARGET_DOCS_PATH/$PROJECT_NAME"
  echo "Documents copied successfully."
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  CopyDocs
fi

