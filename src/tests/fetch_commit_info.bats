#!/bin/bash

# Mock git command
git() {
  local cmd=$1
  case $cmd in
    log)
      echo 'feat: update "quoted" thing (#42)'
      ;;
    rev-parse)
      echo "abc123def456"
      ;;
  esac
}

# Mock cd
cd() { return 0; }

setup() {
  export BASH_ENV="$(mktemp)"
  export SOURCE_REPO_DIRECTORY="."
}

teardown() {
  rm -f "$BASH_ENV"
}

# Source the script to get the FetchCommitInfo function
source ./src/scripts/fetch_commit_info.sh

@test "FetchCommitInfo exports COMMIT_MESSAGE with double quotes intact" {
  run FetchCommitInfo
  [ "$status" -eq 0 ]

  # Source BASH_ENV and verify the variable survives round-trip
  source "$BASH_ENV"
  [[ "$COMMIT_MESSAGE" == 'feat: update "quoted" thing (#42)' ]]
}

@test "FetchCommitInfo handles commit messages with many double quotes" {
  git() {
    local cmd=$1
    case $cmd in
      log) echo 'He said "hello" and "goodbye" and "wow"' ;;
      rev-parse) echo "deadbeef" ;;
    esac
  }

  run FetchCommitInfo
  [ "$status" -eq 0 ]

  source "$BASH_ENV"
  [[ "$COMMIT_MESSAGE" == 'He said "hello" and "goodbye" and "wow"' ]]
}

@test "FetchCommitInfo exports COMMIT_HASH to BASH_ENV" {
  run FetchCommitInfo
  [ "$status" -eq 0 ]

  source "$BASH_ENV"
  [[ "$COMMIT_HASH" == "abc123def456" ]]
}

@test "FetchCommitInfo extracts PR_NUMBER from commit message" {
  run FetchCommitInfo
  [ "$status" -eq 0 ]

  source "$BASH_ENV"
  [[ "$PR_NUMBER" == "42" ]]
}

@test "FetchCommitInfo writes to BASH_ENV file (not literal BASH_ENV)" {
  run FetchCommitInfo
  [ "$status" -eq 0 ]

  # The file at $BASH_ENV path should have content
  [ -s "$BASH_ENV" ]
  # There should be no literal file named "BASH_ENV" in cwd
  [ ! -f "BASH_ENV" ]
}
