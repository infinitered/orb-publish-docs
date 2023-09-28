#! /bin/bash

CopyDocs() {
  echo "Copying documents to the target repository."
  cp -R "$SOURCE_DOCS_PATH" "$TARGET_REPO_DIRECTORY/$TARGET_DOCS_PATH/$PROJECT_NAME"
  echo "Documents copied successfully."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  CopyDocs
fi

