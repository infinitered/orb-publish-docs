#! /bin/bash


CheckDocsExist() {
  # Parameters: Source docs path
  echo "Checking if documents exist in the source directory."

  # Check if the directory exists
  if [ ! -d "$SOURCE_DOCS_PATH" ]; then
    echo "Error: Directory $SOURCE_DOCS_PATH does not exist."
    exit 1
  fi

  # Check if the directory is empty
  if [ ! "$(ls -A "$SOURCE_DOCS_PATH")" ]; then
    echo "Error: No files found in docs directory."
    exit 1
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  CheckDocsExist
fi
