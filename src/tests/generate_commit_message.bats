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
  export PROJECT_NAME="my-project"
  export GITHUB_ORG="infinitered"
  export GITHUB_REPO="my-project"
  export PR_NUMBER="42"
}

teardown() {
  rm -f "$BASH_ENV"
}

# Source the script to get the GenerateCommitMessage function
source ./src/scripts/generate_commit_message.sh

@test "GenerateCommitMessage exports FINAL_COMMIT_MESSAGE with double quotes intact" {
  run GenerateCommitMessage
  [ "$status" -eq 0 ]

  source "$BASH_ENV"
  [[ "$FINAL_COMMIT_MESSAGE" == *'"quoted"'* ]]
}

@test "GenerateCommitMessage exports COMMIT_MESSAGE with double quotes intact" {
  run GenerateCommitMessage
  [ "$status" -eq 0 ]

  source "$BASH_ENV"
  [[ "$COMMIT_MESSAGE" == 'feat: update "quoted" thing (#42)' ]]
}

@test "GenerateCommitMessage includes PR link for PR-based commits" {
  run GenerateCommitMessage
  [ "$status" -eq 0 ]

  source "$BASH_ENV"
  [[ "$FINAL_COMMIT_MESSAGE" == *"/pull/42"* ]]
}

@test "GenerateCommitMessage includes commit hash for non-PR commits" {
  export PR_NUMBER=""

  git() {
    local cmd=$1
    case $cmd in
      log) echo 'fix: a simple "bugfix"' ;;
      rev-parse) echo "deadbeef123" ;;
    esac
  }

  run GenerateCommitMessage
  [ "$status" -eq 0 ]

  source "$BASH_ENV"
  [[ "$FINAL_COMMIT_MESSAGE" == *"deadbeef123"* ]]
}

@test "GenerateCommitMessage handles aggressive double-quote content" {
  git() {
    local cmd=$1
    case $cmd in
      log) echo 'Merge "feature/new" into "main" with "fixes" (#99)' ;;
      rev-parse) echo "cafe1234" ;;
    esac
  }

  run GenerateCommitMessage
  [ "$status" -eq 0 ]

  source "$BASH_ENV"
  [[ "$COMMIT_MESSAGE" == 'Merge "feature/new" into "main" with "fixes" (#99)' ]]
}
