#! /bin/bash

# Global variable declarations
COMMIT_MESSAGE=""
COMMIT_HASH=""
REPO_URL=""
REPO_NAME=""
PR_NUMBER=""
final_commit_message=""

FetchCommitMessage() {
  git log -1 --pretty=%B || { echo "Fetching commit message failed"; exit 1; }
}

FetchCommitHash() {
  git rev-parse HEAD || { echo "Fetching commit hash failed"; exit 1; }
}

FetchRepoURL() {
  git config --get remote.origin.url || { echo "Fetching repo URL failed"; exit 1; }
}

ParseRepoName() {
  basename -s .git "$REPO_URL" || { echo "Parsing repo name failed"; exit 1; }
}

ExtractPRNumber() {
  echo "$COMMIT_MESSAGE" | grep -o "#[0-9]\+" | grep -o "[0-9]\+" || true
}

ConstructCommitMessage() {
  local REPO_NAME="$1"
  local COMMIT_MESSAGE="$2"
  local PR_NUMBER="$3"
  local COMMIT_HASH="$4"

  if [ -n "$PR_NUMBER" ]; then
    PR_LINK="https://github.com/infinitered/$REPO_NAME/pull/$PR_NUMBER"
    echo "orb($REPO_NAME): $COMMIT_MESSAGE $PR_LINK"
  else
    COMMIT_LINK="https://github.com/infinitered/$REPO_NAME/commit/$COMMIT_HASH"
    echo "orb($REPO_NAME): $COMMIT_MESSAGE $COMMIT_LINK"
  fi
}

ParseCommitInfo() {
  cd "$SOURCE_REPO_DIRECTORY" || { echo "Changing directory failed"; exit 1; }

  COMMIT_MESSAGE=$(FetchCommitMessage)
  COMMIT_HASH=$(FetchCommitHash)
  REPO_URL=$(FetchRepoURL)
  REPO_NAME=$(ParseRepoName)
  PR_NUMBER=$(ExtractPRNumber)
  final_commit_message=$(ConstructCommitMessage "$REPO_NAME" "$COMMIT_MESSAGE" "$PR_NUMBER" "$COMMIT_HASH")
  echo "$final_commit_message"
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  final_commit_message="$(ParseCommitInfo)"

  # Logging statements to inspect variables
  echo "COMMIT_MESSAGE: $COMMIT_MESSAGE"
  echo "COMMIT_HASH: $COMMIT_HASH"
  echo "REPO_URL: $REPO_URL"
  echo "REPO_NAME: $REPO_NAME"
  echo "PR_NUMBER: $PR_NUMBER"
  echo "final_commit_message: $final_commit_message"

  export FINAL_COMMIT_MESSAGE=$final_commit_message
  echo "export FINAL_COMMIT_MESSAGE='$final_commit_message'" >> "$BASH_ENV"
fi
