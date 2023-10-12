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
  echo "DEBUG: output \"$output\""
  [[ $output == "https://github.com/org-name/repo-name" ]]
}

@test "GetNormalizedRepoURL: It fetches and normalizes SSH repo URL" {
  export REPO_URL_MOCK="git@github.com:org-name/repo-name.git"
  run GetNormalizedRepoURL $REPO_URL_MOCK
  echo "DEBUG: output \"$output\""
  [[ $output == "https://github.com/org-name/repo-name" ]]
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

@test "ExtractPRNumber: It takes the last possible PR number in messages with multiple potential PR numbers" {
  export TEST_COMMIT_MESSAGE="Fix: Commit for testing (#123) (#42)"
  run ExtractPRNumber "$TEST_COMMIT_MESSAGE"
  echo "DEBUG: output \"$output\""
  [[ $output =~ \42 ]]  # Assuming it extracts the last PR number by default
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


@test "FetchCommitMessage: It handles commit messages with special characters" {
  export TEST_COMMIT_MESSAGE="Fix & Improve: Commit for !testing (#42)"
  run FetchCommitMessage
  echo "DEBUG: output \"$output\""
  [[ $output =~ Fix\ \&\ Improve:\ Commit\ for\ \!testing\ \(#42\) ]]
}


@test "ParseCommitInfo: It handles commit messages with URL-like strings" {
  echo "DEBUG: REPO_NAME Before - \"$REPO_NAME\"" >&2  # New Debug Line, directed to stderr
  export TEST_COMMIT_MESSAGE="Fix: See https://example.com/issues/42 for more info (#42)"
  run ParseCommitInfo
  FINAL_MSG=$(echo "$output" | xargs)
  echo "DEBUG: REPO_NAME After - \"$REPO_NAME\"" >&2  # New Debug Line, directed to stderr
  echo "DEBUG    FINAL_MSG: \"$FINAL_MSG\"" >&2
  echo "EXPECTED FINAL_MSG: \"orb($REPO_NAME): $COMMIT_MESSAGE_WITHOUT_PR https://github.com/$ORG_NAME/$REPO_NAME/commit/$COMMIT_HASH\"" >&2
  [[ $FINAL_MSG == "orb($REPO_NAME): Fix: See https://example.com/issues/42 for more info (#42) https://github.com/org-name/repo-name/pull/42" ]]
}


@test "ParseCommitInfo: It parses and constructs the final commit message with PR link" {
  run ParseCommitInfo
  FINAL_MSG=$(echo "$output" | xargs)
  echo "DEBUG    FINAL_MSG: \"$FINAL_MSG\""
  echo "EXPECTED FINAL_MSG: \"orb($REPO_NAME): $COMMIT_MESSAGE_WITHOUT_PR https://github.com/$ORG_NAME/$REPO_NAME/commit/$COMMIT_HASH\""
  [[ $FINAL_MSG == "orb(repo-name): $COMMIT_MESSAGE_WITH_PR https://github.com/org-name/repo-name/pull/42" ]]
}

@test "ParseCommitInfo: It parses and constructs the final commit message with commit link" {
  export TEST_COMMIT_MESSAGE="$COMMIT_MESSAGE_WITHOUT_PR"
  run ParseCommitInfo
  FINAL_MSG=$(echo "$output" | xargs)
  echo "DEBUG    FINAL_MSG: \"$FINAL_MSG\""
  echo "EXPECTED FINAL_MSG: \"orb($REPO_NAME): $COMMIT_MESSAGE_WITHOUT_PR https://github.com/$ORG_NAME/$REPO_NAME/commit/$COMMIT_HASH\""
  [[ $FINAL_MSG == "orb($REPO_NAME): $COMMIT_MESSAGE_WITHOUT_PR https://github.com/$ORG_NAME/$REPO_NAME/commit/$COMMIT_HASH" ]]
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
  unset TEST_REPO_URL
  unset TEST_COMMIT_MESSAGE
}
