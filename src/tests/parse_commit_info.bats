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
  run ParseCommitInfo
  echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ Fix:\ Commit\ for\ testing\ #42 ]]
}

@test "It fetches the commit hash" {
  run ParseCommitInfo
  echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ 1234567890abcdef ]]
}

@test "It fetches the repo URL" {
  run ParseCommitInfo
  echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ https://github.com/infinitered/sample-repo.git ]]
}

@test "It fetches the repo name" {
  run ParseCommitInfo
  echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ sample-repo ]]
}

@test "It fetches PR number from commit message" {
  run ParseCommitInfo
  echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ \#42 ]]
}

@test "It constructs PR link and commit message" {
  run ParseCommitInfo
  echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ https://github.com/infinitered/sample-repo/pull/42 ]]
  [[ $output =~ sample-repo\ --\ Fix:\ Commit\ for\ testing\ #42\ --\ https://github.com/infinitered/sample-repo/pull/42 ]]
}

@test "It constructs commit link when PR number is absent" {
  # Mock git log to not return PR number
  git() {
    case "$1" in
      log) echo "Fix: Commit for testing";;
      *) git "$@";;
    esac
  }

  run ParseCommitInfo
  echo "Debug: Output = '$output'"  # Verbose log
  [[ $output =~ https://github.com/infinitered/sample-repo/commit/1234567890abcdef ]]
  [[ $output =~ sample-repo\ --\ Fix:\ Commit\ for\ testing\ --\ https://github.com/infinitered/sample-repo/commit/1234567890abcdef ]]
}
