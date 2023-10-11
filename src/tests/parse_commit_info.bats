#! /bin/bash

COMMIT_MESSAGE_WITH_PR="Fix: Commit for testing (#42)"

# Mocking git commands and basename
git() {
  case "$1" in
    log) echo $COMMIT_MESSAGE_WITH_PR;;
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
  run FetchCommitMessage
  >&2 echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ Fix:\ Commit\ for\ testing\ \(#42\) ]]
}

@test "It fetches the commit hash" {
  run FetchCommitHash
  >&2 echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ 1234567890abcdef ]]
}

@test "It fetches the repo URL" {
  run FetchRepoURL
  >&2 echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ https://github.com/infinitered/sample-repo.git ]]
}

@test "It fetches the repo name" {
  run ParseRepoName
  >&2 echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ sample-repo ]]
}

@test "It fetches PR number from commit message" {
  export COMMIT_MESSAGE=$COMMIT_MESSAGE_WITH_PR
  run ExtractPRNumber
  >&2 echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ \42 ]]
}

@test "It constructs PR link and commit message when PR number is present" {
  # Set up PR number
  export PR_NUMBER=42
  # shellcheck disable=SC2030
  export REPO_NAME="sample-repo"
  export COMMIT_MESSAGE="Fix: Commit for testing (#42)"

  run ConstructCommitMessage
  >&2 echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ https://github.com/infinitered/sample-repo/pull/42 ]]
  [[ $output =~ orb:\ sample-repo\ --\ Fix:\ Commit\ for\ testing\ \(#42\)\ --\ https://github.com/infinitered/sample-repo/pull/42 ]]
  unset PR_NUMBER
  unset REPO_NAME
  unset COMMIT_MESSAGE
}

@test "It constructs commit link and commit message when PR number is absent" {
  # Unset PR number to simulate absence
  unset PR_NUMBER
  # shellcheck disable=SC2031
  export REPO_NAME="sample-repo"
  export COMMIT_HASH="1234567890abcdef"
  export COMMIT_MESSAGE="Fix: Commit for testing"

  run ConstructCommitMessage "$REPO_NAME" "$COMMIT_MESSAGE" "$PR_NUMBER" "$COMMIT_HASH"
  >&2 echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ orb\(sample-repo\):\ Fix:\ Commit\ for\ testing\ (#42)\ https://github.com/infinitered/sample-repo/pull/42 ]]

  unset REPO_NAME
  unset COMMIT_HASH
  unset COMMIT_MESSAGE
}

@test "It parses and constructs the final commit message" {
  run ParseCommitInfo
  final_msg=$(echo "$output" | grep "^Final constructed message:" | cut -d ':' -f 2- | xargs)
  >&2 echo "Debug: Extracted Final Commit Message = '$final_msg'"
  [[ $final_msg == "orb(sample-repo): Fix: Commit for testing (#42) https://github.com/infinitered/sample-repo/pull/42" ]]
}
