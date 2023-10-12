#! /bin/bash
# shellcheck disable=SC2031
# shellcheck disable=SC2030

setup() {
  export COMMIT_HASH="commitHash1234567890"
  export COMMIT_MESSAGE_WITHOUT_PR="Test: Commit message without PR"
  export COMMIT_MESSAGE_WITH_PR="Test: Commit message with PR (#42)"
  export ORG_NAME="org-name"
  export REPO_NAME="repo-name"
  export TEST_REPO_URL="https://github.com/org-name/repo-name.git"
  export TEST_COMMIT_MESSAGE="$COMMIT_MESSAGE_WITH_PR"
}

# Mocking git commands and basename
git() {
  case "$1" in
    log) echo "$TEST_COMMIT_MESSAGE";;
    rev-parse) echo "$COMMIT_HASH";;
    config) echo "$REPO_URL_MOCK";;
    *) return 1;;
  esac
}

# Mock the cd command
cd() {
  # Store the directory change in a variable for inspection
  # shellcheck disable=SC2034
  LAST_CD_DIRECTORY="$1"
  # You can also echo a message to indicate that cd was called, if needed
  # echo "cd $1"
}

basename() {
  echo "$REPO_NAME"
}

# Source the script to get ParseCommitInfo function
source ./src/scripts/parse_commit_info.sh

@test "FetchCommitMessage: It fetches the last commit message" {
  run FetchCommitMessage
  [[ "$output" =~ Test:\ Commit\ message\ with\ PR\ \(#42\) ]]
}

@test "FetchCommitHash: It fetches the commit hash" {
  run FetchCommitHash
  [[ $output =~ $COMMIT_HASH ]]
}

@test "GetNormalizedRepoURL: It fetches and normalizes HTTPS repo URL" {
  export REPO_URL_MOCK="https://github.com/org-name/repo-name.git"
  run GetNormalizedRepoURL $REPO_URL_MOCK
  [[ $output == "https://github.com/org-name/repo-name" ]]
  unset REPO_URL_MOCK
}

@test "GetNormalizedRepoURL: It fetches and normalizes SSH repo URL" {
  export REPO_URL_MOCK="git@github.com:org-name/repo-name.git"
  run GetNormalizedRepoURL $REPO_URL_MOCK
  [[ $output == "https://github.com/org-name/repo-name" ]]
  unset REPO_URL_MOCK
}

@test "ExtractGitHubOrgAndRepo: It extracts org and repo from HTTPS URL with .git suffix" {
  run ExtractGitHubOrgAndRepo "https://github.com/sample-org/sample-repo.git"
  [ "$status" -eq 0 ]
  [ "$output" = "sample-org sample-repo" ]
}

@test "ExtractGitHubOrgAndRepo: It extracts org and repo from HTTPS URL without .git suffix" {
  run ExtractGitHubOrgAndRepo "https://github.com/sample-org/sample-repo"
  [ "$status" -eq 0 ]
  [ "$output" = "sample-org sample-repo" ]
}

@test "ExtractGitHubOrgAndRepo: It throws an error when given an invalid GitHub URL" {
  run ExtractGitHubOrgAndRepo "https://invalid.com/sample-org/sample-repo.git"
  [ "$status" -eq 1 ]
  [[ "$output" == "Error: Not a GitHub URL."* ]]
}


@test "ExtractPRNumber: It fetches PR number from commit message" {
  run ExtractPRNumber "$COMMIT_MESSAGE_WITH_PR"
  [[ $output =~ \42 ]]
}

@test "CreatePRLink: It constructs PR link" {
  export PR_NUMBER=42
  run CreatePRLink "$ORG_NAME" "$REPO_NAME" "$PR_NUMBER"
  [[ $output == https://github.com/org-name/repo-name/pull/42 ]]
  unset PR_NUMBER
}

@test "CreateCommitLink: It constructs commit link" {
  run CreateCommitLink "$ORG_NAME" "$REPO_NAME" "$COMMIT_HASH"
  [[ $output == "https://github.com/org-name/repo-name/commit/$COMMIT_HASH" ]]
}

@test "ParseCommitInfo: It parses and constructs the final commit message with PR link" {
  run ParseCommitInfo
  FINAL_MSG=$(echo "$output" | xargs)
  [[ $FINAL_MSG == "orb($REPO_NAME): $COMMIT_MESSAGE_WITH_PR https://github.com/org-name/repo-name/pull/42" ]]
  >&1 echo "DEBUG: FINAL_MSG \"$FINAL_MSG\""
}

@test "ParseCommitInfo: It parses and constructs the final commit message with commit link" {
  TEST_COMMIT_MESSAGE="$COMMIT_MESSAGE_WITHOUT_PR"
  run ParseCommitInfo
  FINAL_MSG=$(echo "$output" | grep "^Final constructed message:" | cut -d ':' -f 2- | xargs)
  [[ $FINAL_MSG == "orb($REPO_NAME): $COMMIT_MESSAGE_WITHOUT_PR https://github.com/org-name/repo-name/commit/$COMMIT_HASH" ]]
  >&1 echo "DEBUG: FINAL_MSG \"$FINAL_MSG\""
}

@test "FetchCommitMessage: It handles commit messages with special characters" {
  export COMMIT_MESSAGE_WITH_PR="Fix & Improve: Commit for !testing (#42)"
  run FetchCommitMessage
  [[ $output =~ Fix\ \&\ Improve:\ Commit\ for\ \!testing\ \(#42\) ]]
  >&1 echo "DEBUG: output \"$output\""
  unset COMMIT_MESSAGE_WITH_PR
}

@test "ExtractPRNumber: It takes the last possible PR number in messages with multiple potential PR numbers" {
  export COMMIT_MESSAGE_WITH_PR="Fix: Commit for testing (#123) (#42)"
  run ExtractPRNumber
  [[ $output =~ \42 ]]  # Assuming it extracts the last PR number by default
  >&1 echo "DEBUG: output \"$output\""
  unset COMMIT_MESSAGE_WITH_PR
}

@test "FetchCommitMessage: It handles very long commit messages" {
  long_msg="Fix: $(printf 'A%.0s' {1..500})"  # Generates a message "Fix: AAAAAAAAAA... (500 times)"
  export COMMIT_MESSAGE_WITH_PR="$long_msg (#42)"
  run FetchCommitMessage
  [[ ${#output} -eq 507 ]]  # Length should be 507 (500 + 7 for "Fix: " and "(#42)")
  unset COMMIT_MESSAGE_WITH_PR
}

@test "ParseCommitInfo: It handles commit messages with URL-like strings" {
  export COMMIT_MESSAGE_WITH_PR="Fix: See https://example.com/issues/42 for more info (#42)"
  run ParseCommitInfo
  FINAL_MSG=$(echo "$output" | grep "^Final constructed message:" | cut -d ':' -f 2- | xargs)
  [[ $FINAL_MSG == "orb($REPO_NAME): Fix: See https://example.com/issues/42 for more info (#42) https://github.com/org-name/repo-name/pull/42" ]]
  unset COMMIT_MESSAGE_WITH_PR
}

teardown() {
  unset COMMIT_HASH
  unset COMMIT_MESSAGE
  unset COMMIT_MESSAGE_WITHOUT_PR
  unset COMMIT_MESSAGE_WITH_PR
  unset FINAL_MSG
  unset ORG_NAME
  unset PR_NUMBER
  unset REPO_NAME
  unset $TEST_REPO_URL
  unset TEST_COMMIT_MESSAGE
}
