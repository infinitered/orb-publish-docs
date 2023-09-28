#! /bin/bash


MoveStaticDocs() {
  # Move static content out of /docs into /static.
  echo "Checking for static files in the target repository."
  if [ "$(ls -A "$CIRCLE_WORKING_DIRECTORY/$TARGET_REPO_DIRECTORY/docs/$PROJECT_NAME/_static_")" ]; then
    echo "Moving static files."
    mv "$CIRCLE_WORKING_DIRECTORY/$TARGET_REPO_DIRECTORY/docs/$PROJECT_NAME/_static_" "$CIRCLE_WORKING_DIRECTORY/$TARGET_REPO_DIRECTORY/static/$PROJECT_NAME/"
    echo "Static files moved successfully."
  else
    echo "No static files to copy."
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  MoveStaticDocs
fi

