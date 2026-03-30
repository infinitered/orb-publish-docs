#!/bin/bash
set -x  # Enable debugging output

ChangeToSourceRepoDirectory() {
  echo "Changing directory to $SOURCE_REPO_DIRECTORY" >&2
  cd "$SOURCE_REPO_DIRECTORY" || { echo "Changing directory to $SOURCE_REPO_DIRECTORY failed" >&2; exit 1; }
}

FetchCommitInfo() {
  local PR_NUMBER
  local COMMIT_MESSAGE
  local COMMIT_HASH

  COMMIT_MESSAGE=$(git log -1 --pretty=%B || { echo "Fetching commit message failed" >&2 ; exit 1; })
  echo "COMMIT_MESSAGE: $COMMIT_MESSAGE" >&2
  COMMIT_HASH=$(git rev-parse HEAD || { echo "Fetching commit hash failed" >&2 ; exit 1; })
  echo "COMMIT_HASH: $COMMIT_HASH" >&2

  PR_NUMBER=$(echo "$COMMIT_MESSAGE" | grep -oP '(Merge pull request #\K\d+)|(\(#\K\d+\))' || true)
  PR_NUMBER=${PR_NUMBER:-""}


  echo "COMMIT_MESSAGE: $COMMIT_MESSAGE" >&2
  printf 'export COMMIT_MESSAGE=%q\n' "$COMMIT_MESSAGE" >> "$BASH_ENV"
  echo "COMMIT_HASH: $COMMIT_HASH" >&2
  printf 'export COMMIT_HASH=%q\n' "$COMMIT_HASH" >> "$BASH_ENV"
  echo "PR_NUMBER: $PR_NUMBER" >&2
  printf 'export PR_NUMBER=%q\n' "$PR_NUMBER" >> "$BASH_ENV"
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  ChangeToSourceRepoDirectory
  FetchCommitInfo
fi
