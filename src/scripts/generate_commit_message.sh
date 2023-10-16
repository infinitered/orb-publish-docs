#!/bin/bash

GenerateCommitMessage() {
  echo "Changing directory to $SOURCE_REPO_DIRECTORY" >&2
  cd "$SOURCE_REPO_DIRECTORY" || { echo "Changing directory failed" >&2; exit 1; }
  echo "Changed directory to $(pwd)" >&2

  # Fetch COMMIT_MESSAGE and COMMIT_HASH from git logs
  COMMIT_MESSAGE=$(git log -1 --pretty=%B)
  echo "COMMIT_MESSAGE: $COMMIT_MESSAGE" >&2

  COMMIT_HASH=$(git rev-parse HEAD)
  echo "COMMIT_HASH: $COMMIT_HASH" >&2

  # Check if it's a pull request commit based on the existence of a PR_NUMBER
   PR_MATCH=$(git log -1 --pretty=%B | grep -o "#[0-9]\+" | grep -o "[0-9]\+" | tail -n 1 || true)  # Use "|| true" to prevent exit on failure
   if [ -n "$PR_MATCH" ]; then
     echo "PR-based commit detected" >&2
     FINAL_COMMIT_MESSAGE="orb($PROJECT_NAME): $COMMIT_MESSAGE https://github.com/$GITHUB_ORG/$GITHUB_REPO/pull/$PR_MATCH"
   else
     echo "Non-PR-based commit detected" >&2
     FINAL_COMMIT_MESSAGE="orb($PROJECT_NAME): $COMMIT_MESSAGE https://github.com/$GITHUB_ORG/$GITHUB_REPO/commit/$COMMIT_HASH"
   fi


  # Differentiate between PR-based and non-PR-based commits
  if [ -n "$PR_NUMBER" ]; then
    echo "PR-based commit detected" >&2
    FINAL_COMMIT_MESSAGE="orb($PROJECT_NAME): $COMMIT_MESSAGE https://github.com/$GITHUB_ORG/$PROJECT_NAME/pull/$PR_NUMBER"
  else
    echo "Non-PR-based commit detected" >&2
    FINAL_COMMIT_MESSAGE="orb($PROJECT_NAME): $COMMIT_MESSAGE ($COMMIT_HASH)"
  fi

  echo "FINAL_COMMIT_MESSAGE: $FINAL_COMMIT_MESSAGE" >&2

  # Export variables
  {
    echo "export COMMIT_MESSAGE=\"${COMMIT_MESSAGE}\""
    echo "export COMMIT_HASH=\"${COMMIT_HASH}\""
    echo "export PR_NUMBER=\"${PR_NUMBER}\""
    echo "export FINAL_COMMIT_MESSAGE=\"${FINAL_COMMIT_MESSAGE}\""
  } >> "$BASH_ENV"

  # Log environment variables
  echo "COMMIT_MESSAGE: ${COMMIT_MESSAGE}" >&2
  echo "COMMIT_HASH: ${COMMIT_HASH}" >&2
  echo "PR_NUMBER: ${PR_NUMBER}" >&2
  echo "FINAL_COMMIT_MESSAGE: ${FINAL_COMMIT_MESSAGE}" >&2
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  GenerateCommitMessage
fi
