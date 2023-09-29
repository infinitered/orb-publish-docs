#! /bin/bash


MoveStaticDocs() {
  # Move static content out of /docs into /static.
  echo "Checking for static files in the target repository."
  if [ "$(ls -A "$TARGET_REPO_DIRECTORY/docs/$PROJECT_NAME/_static_")" ]; then
    echo "Moving static files."
    mv "$TARGET_REPO_DIRECTORY/docs/$PROJECT_NAME/_static_" "$TARGET_REPO_DIRECTORY/static/$PROJECT_NAME/"
    echo "Static files moved successfully."
  else
    echo "No static files to copy."
  fi
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  MoveStaticDocs
fi

