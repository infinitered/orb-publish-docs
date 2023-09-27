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
  echo "$COMMIT_MESSAGE" | grep -o "#[0-9]\+" || true
}

ConstructCommitMessage() {
  if [ -n "$PR_NUMBER" ]; then
    PR_LINK="https://github.com/infinitered/$REPO_NAME/pull/$PR_NUMBER"
    echo "$REPO_NAME -- $COMMIT_MESSAGE -- $PR_LINK"
  else
    COMMIT_LINK="https://github.com/infinitered/$REPO_NAME/commit/$COMMIT_HASH"
    echo "$REPO_NAME -- $COMMIT_MESSAGE -- $COMMIT_LINK"
  fi
}

ParseCommitInfo() {
  COMMIT_MESSAGE=$(FetchCommitMessage)
  echo "COMMIT_MESSAGE: $COMMIT_MESSAGE"
  COMMIT_HASH=$(FetchCommitHash)
  echo "COMMIT_HASH: $COMMIT_HASH"
  REPO_URL=$(FetchRepoURL)
  echo "REPO_URL: $REPO_URL"
  REPO_NAME=$(ParseRepoName)
  echo "REPO_NAME: $REPO_NAME"
  PR_NUMBER=$(ExtractPRNumber)
  echo "PR_NUMBER: $PR_NUMBER"

  final_commit_message=$(ConstructCommitMessage)
  echo "FINAL_COMMIT_MESSAGE: $final_commit_message"
  export FINAL_COMMIT_MESSAGE="$final_commit_message"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  ParseCommitInfo
fi
