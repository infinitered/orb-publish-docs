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
  COMMIT_HASH=$(git rev-parse HEAD || { echo "Fetching commit hash failed" >&2 ; exit 1; })

  PR_NUMBER=$(echo "$COMMIT_MESSAGE" | grep -oP '(Merge pull request #\K\d+)|(\(#\K\d+\))')
  PR_NUMBER=${PR_NUMBER:-""}

  if [ -z "$BASH_ENV" ]; then
    echo "BASH_ENV is not set" >&2
    exit 1
  fi

  {
    echo "export COMMIT_MESSAGE=\"${COMMIT_MESSAGE}\""
    echo "export COMMIT_HASH=\"${COMMIT_HASH}\""
    echo "export PR_NUMBER=\"$PR_NUMBER\""
  } >> "$BASH_ENV"
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  ChangeToSourceRepoDirectory
  FetchCommitInfo
fi

exit 0
