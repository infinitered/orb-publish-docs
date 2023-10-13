#! /bin/bash

set -e

# Global variable declarations
declare -g PARSE_COMMIT_COMMIT_MESSAGE=""
declare -g PARSE_COMMIT_COMMIT_HASH=""
declare -g PARSE_COMMIT_REPO_URL=""
declare -g PARSE_COMMIT_REPO_NAME=""
declare -g PARSE_COMMIT_PR_NUMBER=""
declare -g final_commit_message=""

ExtractPRNumber() {
  local commit_msg="$1"
  echo "Debug: Entering ExtractPRNumber with commit_msg: $commit_msg" >&2
  local result=$(echo "$commit_msg" | grep -o "#[0-9]\+" | grep -o "[0-9]\+" | tail -n 1 || true)
  echo "Debug: Exiting ExtractPRNumber with result: $result" >&2
  echo "$result"
}

FetchCommitMessage() {
  echo "Debug: Entering FetchCommitMessage" >&2
  local result=$(git log -1 --pretty=%B || { echo "Fetching commit message failed" >&2; exit 1; })
  echo "Debug: Exiting FetchCommitMessage with result: $result" >&2
  echo "$result"
}

FetchCommitHash() {
  echo "Debug: Entering FetchCommitHash" >&2
  local result=$(git rev-parse HEAD || { echo "Fetching commit hash failed" >&2; exit 1; })
  echo "Debug: Exiting FetchCommitHash with result: $result" >&2
  echo "$result"
}

GetNormalizedRepoURL() {
  local circle_repo_url="$1"
  echo "Debug: Entering GetNormalizedRepoURL with circle_repo_url: $circle_repo_url" >&2

  local result
  if [[ $circle_repo_url == https://* ]]; then
    result="${circle_repo_url%.git}"
  else
    result="${circle_repo_url/git@github.com:/https://github.com/}"
    result="${result%.git}"
  fi
  echo "Debug: Exiting GetNormalizedRepoURL with result: $result" >&2
  echo "$result"
}

ExtractGitHubOrgAndRepo() {
  local repo_url="$1"
  echo "Debug: Entering ExtractGitHubOrgAndRepo with repo_url: $repo_url" >&2

  if [[ $repo_url != *github.com* ]]; then
    echo "Error: Not a GitHub URL." >&2
    exit 1
  fi

  local extracted=$(echo "$repo_url" | awk -F'/' '{gsub(".git", "", $NF); print $(NF-1), $NF}')

  if [ -z "$extracted" ]; then
    echo "Error: Invalid GitHub URL format." >&2
    exit 1
  fi
  echo "Debug: Exiting ExtractGitHubOrgAndRepo with result: $extracted" >&2
  echo "$extracted"
}

ConstructCommitMessage() {
  local org="$1"
  local repo="$2"
  local commit_msg="$3"
  local pr_num="$4"
  local commit_hash="$5"

  echo "Debug: Entering ConstructCommitMessage with org: $org, repo: $repo, commit_msg: $commit_msg, pr_num: $pr_num, commit_hash: $commit_hash" >&2

  local link
  if [ -n "$pr_num" ]; then
    link=$(CreatePRLink "$org" "$repo" "$pr_num")
  else
    link=$(CreateCommitLink "$org" "$repo" "$commit_hash")
  fi
  local result="orb($repo): $commit_msg $link"
  echo "Debug: Exiting ConstructCommitMessage with result: $result" >&2
  echo "$result"
}

CreatePRLink() {
  local org="$1"
  local repo="$2"
  local pr_number="$3"
  echo "Debug: Entering CreatePRLink with org: $org, repo: $repo, pr_number: $pr_number" >&2
  local result="https://github.com/$org/$repo/pull/$pr_number"
  echo "Debug: Exiting CreatePRLink with result: $result" >&2
  echo "$result"
}

CreateCommitLink() {
  local org="$1"
  local repo="$2"
  local commit_hash="$3"
  echo "Debug: Entering CreateCommitLink with org: $org, repo: $repo, commit_hash: $commit_hash" >&2
  local result="https://github.com/$org/$repo/commit/$commit_hash"
  echo "Debug: Exiting CreateCommitLink with result: $result" >&2
  echo "$result"
}

ParseCommitInfo() {

  cd $SOURCE_REPO_DIRECTORY || { echo "Changing directory failed"; exit 1; }

  echo "Debug: Entering ParseCommitInfo" >&2

  if [ "$ORB_TEST_ENV" = "bats-core" ]; then
    PARSE_COMMIT_REPO_URL=$(GetNormalizedRepoURL "$TEST_REPO_URL")
  else
    echo "Debug: CIRCLE_REPOSITORY_URL before normalization: $CIRCLE_REPOSITORY_URL" >&2
    PARSE_COMMIT_REPO_URL=$(GetNormalizedRepoURL "$CIRCLE_REPOSITORY_URL")
  fi

  echo "Debug: PARSE_COMMIT_REPO_URL after normalization: $PARSE_COMMIT_REPO_URL" >&2

  PARSE_COMMIT_COMMIT_MESSAGE=$(FetchCommitMessage)
  PARSE_COMMIT_COMMIT_HASH=$(FetchCommitHash)

  local extracted
  extracted=$(ExtractGitHubOrgAndRepo "$PARSE_COMMIT_REPO_URL")

  local org
  local repo
  read -r org repo <<<"$extracted"

  PARSE_COMMIT_REPO_NAME="$repo"
  PARSE_COMMIT_PR_NUMBER=$(ExtractPRNumber "$PARSE_COMMIT_COMMIT_MESSAGE")

  final_commit_message=$(ConstructCommitMessage "$org" "$repo" "$PARSE_COMMIT_COMMIT_MESSAGE" "$PARSE_COMMIT_PR_NUMBER" "$PARSE_COMMIT_COMMIT_HASH")
  echo "Debug: Exiting ParseCommitInfo with final_commit_message: $final_commit_message" >&2
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then

  cd "$SOURCE_REPO_DIRECTORY" || { echo "Changing directory failed" >&2; exit 1; }

  # Check if running in a git repository
  if [ ! -d ".git" ]; then
    echo "Error: Not a git repository. Exiting." >&2
    exit 1
  fi

  echo "Debug: Entering ParseCommitInfo" >&2
  final_commit_message="$(ParseCommitInfo)"
  echo "Debug: Exiting ParseCommitInfo with final_commit_message: $final_commit_message" >&2

  # Logging statements to inspect variables, output to stderr
  echo "Debug: CIRCLE_REPOSITORY_URL: $CIRCLE_REPOSITORY_URL" >&2
  echo "Debug: SOURCE_REPO_DIRECTORY: $SOURCE_REPO_DIRECTORY" >&2
  echo "Debug: PARSE_COMMIT_COMMIT_MESSAGE: $PARSE_COMMIT_COMMIT_MESSAGE" >&2
  echo "Debug: PARSE_COMMIT_COMMIT_HASH: $PARSE_COMMIT_COMMIT_HASH" >&2
  echo "Debug: PARSE_COMMIT_REPO_URL: $PARSE_COMMIT_REPO_URL" >&2
  echo "Debug: PARSE_COMMIT_REPO_NAME: $PARSE_COMMIT_REPO_NAME" >&2
  echo "Debug: PARSE_COMMIT_PR_NUMBER: $PARSE_COMMIT_PR_NUMBER" >&2
  echo "Debug: final_commit_message: $final_commit_message" >&2

  echo "export FINAL_COMMIT_MESSAGE='$final_commit_message'" >> "$BASH_ENV"
fi
