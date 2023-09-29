#! /bin/bash

CopyDocs() {
  echo "Copying documents to the target repository."
  cp -R "$FULL_SOURCE_DOCS_PATH" "$TARGET_REPO_DIRECTORY/$TARGET_DOCS_PATH/$PROJECT_NAME"
  echo "Documents copied successfully."
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  CopyDocs
fi

