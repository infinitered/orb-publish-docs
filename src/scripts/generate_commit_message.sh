#!/bin/bash

GenerateCommitMessage() {
  cd "$SOURCE_REPO_DIRECTORY" || { echo "Changing directory failed" >&2; exit 1; }

  # Fetch COMMIT_MESSAGE and COMMIT_HASH from git logs
  COMMIT_MESSAGE=$(git log -1 --pretty=%B)
  COMMIT_HASH=$(git rev-parse HEAD)

  # Check if it's a pull request commit based on the existence of a PR_NUMBER
  PR_NUMBER=$(git log -1 --pretty=%B | grep -o "#[0-9]\+" | grep -o "[0-9]\+" | tail -n 1)

  # Differentiate between PR-based and non-PR-based commits
  if [ -n "$PR_NUMBER" ]; then
    FINAL_COMMIT_MESSAGE="orb($PROJECT_NAME): $COMMIT_MESSAGE https://github.com/org/$PROJECT_NAME/pull/$PR_NUMBER"
  else
    FINAL_COMMIT_MESSAGE="orb($PROJECT_NAME): $COMMIT_MESSAGE ($COMMIT_HASH)"
  fi

  # Export variables
  {
    echo "export COMMIT_MESSAGE=\"${COMMIT_MESSAGE}\""
    echo "export COMMIT_HASH=\"${COMMIT_HASH}\""
    echo "export PR_NUMBER=\"${PR_NUMBER}\""
    echo "export FINAL_COMMIT_MESSAGE=\"${FINAL_COMMIT_MESSAGE}\""
  } >> "$BASH_ENV"
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  GenerateCommitMessage
fi
