#! /bin/bash

CopyDocs() {
  echo "Copying documents to the target repository."
  echo "Source: $FULL_SOURCE_DOCS_PATH"
  echo "Destination: $FULL_TARGET_DOCS_PATH"

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

