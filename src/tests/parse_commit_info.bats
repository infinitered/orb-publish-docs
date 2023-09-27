#! /bin/bash

# Mocking git commands and basename
git() {
  case "$1" in
    log) echo "Fix: Commit for testing #42";;
    rev-parse) echo "1234567890abcdef";;
    config) echo "https://github.com/infinitered/sample-repo.git";;
    *) return 1;;
  esac
}

basename() {
  echo "sample-repo"
}

# Source the script to get ParseCommitInfo function
source ./src/scripts/parse_commit_info.sh

@test "It fetches the last commit message" {
  expport COMMIT_MESSAGE="Fix: Commit for testing (#42)"
  run FetchCommitMessage
  echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ Fix:\ Commit\ for\ testing\ #42 ]]
  unset COMMIT_MESSAGE
}

@test "It fetches the commit hash" {
  run FetchCommitHash
  echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ 1234567890abcdef ]]
}

@test "It fetches the repo URL" {
  run FetchRepoURL
  echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ https://github.com/infinitered/sample-repo.git ]]
}

@test "It fetches the repo name" {
  run ParseRepoName
  echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ sample-repo ]]
}

@test "It fetches PR number from commit message" {
  run ExtractPRNumber
  echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ \#42 ]]
}

@test "It constructs PR link and commit message when PR number is present" {
  # Set up PR number
  export PR_NUMBER=42
  # shellcheck disable=SC2030
  export REPO_NAME="sample-repo"

  run ConstructCommitMessage
  echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ https://github.com/infinitered/sample-repo/pull/42 ]]
  [[ $output =~ sample-repo\ --\ Fix:\ Commit\ for\ testing\ #42\ --\ https://github.com/infinitered/sample-repo/pull/42 ]]
  unset PR_NUMBER
  unset REPO_NAME
}

@test "It constructs commit link and commit message when PR number is absent" {
  # Unset PR number to simulate absence
  unset PR_NUMBER
  # shellcheck disable=SC2031
  export REPO_NAME="sample-repo"
  export COMMIT_HASH="1234567890abcdef"

  run ConstructCommitMessage
  echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ https://github.com/infinitered/sample-repo/commit/1234567890abcdef ]]
  [[ $output =~ sample-repo\ --\ Fix:\ Commit\ for\ testing\ --\ https://github.com/infinitered/sample-repo/commit/1234567890abcdef ]]
  unset REPO_NAME
  unset COMMIT_HASH
}

@test "It parses and constructs the final commit message" {
  run ParseCommitInfo
  echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ sample-repo\ --\ Fix:\ Commit\ for\ testing\ #42\ --\ https://github.com/infinitered/sample-repo/pull/42 ]]
}

