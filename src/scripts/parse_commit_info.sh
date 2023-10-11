#! /bin/bash

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
  if [ -n "$PR_NUMBER" ]; then
    PR_LINK="https://github.com/infinitered/$REPO_NAME/pull/$PR_NUMBER"
    echo "orb: $REPO_NAME -- $COMMIT_MESSAGE -- $PR_LINK"
  else
    COMMIT_LINK="https://github.com/infinitered/$REPO_NAME/commit/$COMMIT_HASH"
    echo "orb: $REPO_NAME -- $COMMIT_MESSAGE -- $COMMIT_LINK"
  fi
}

ParseCommitInfo() {
  cd "$SOURCE_REPO_DIRECTORY" || { echo "Changing directory failed"; exit 1; }

  declare -g COMMIT_MESSAGE
  declare -g COMMIT_HASH
  declare -g REPO_URL
  declare -g REPO_NAME
  declare -g PR_NUMBER

  COMMIT_MESSAGE=$(FetchCommitMessage)
  COMMIT_HASH=$(FetchCommitHash)
  REPO_URL=$(FetchRepoURL)
  REPO_NAME=$(ParseRepoName)
  PR_NUMBER=$(ExtractPRNumber)

  final_commit_message=$(ConstructCommitMessage)
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
fi
