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
  echo "$commit_msg" | grep -o "#[0-9]\+" | grep -o "[0-9]\+" | tail -n 1 || true
}

FetchCommitMessage() {
  git log -1 --pretty=%B || { echo "Fetching commit message failed"; exit 1; }
}

FetchCommitHash() {
  git rev-parse HEAD || { echo "Fetching commit hash failed"; exit 1; }
}

# Normalize the repository URL for consistent usage
GetNormalizedRepoURL() {
  local circle_repo_url="$1"


  if [[ $circle_repo_url == https://* ]]; then
    # If it's already an HTTPS URL, just ensure it doesn't have the .git suffix
    echo "${circle_repo_url%.git}"
  else
    # Convert SSH format to https format for consistency
    local https_url="${circle_repo_url/git@github.com:/https://github.com/}"
    echo "${https_url%.git}"      # Strip trailing .git if present
  fi
}

ExtractGitHubOrgAndRepo() {
  local repo_url="$1"

  if [[ $repo_url != *github.com* ]]; then
    echo "Error: Not a GitHub URL." >&2
    exit 1
  fi

  local extracted
  extracted=$(echo "$repo_url" | awk -F'/' '{gsub(".git", "", $NF); print $(NF-1), $NF}')

  if [ -z "$extracted" ]; then
    echo "Error: Invalid GitHub URL format." >&2
    exit 1
  fi

  echo "$extracted"
}

ConstructCommitMessage() {
  local org="$1"
  local repo="$2"
  local commit_msg="$3"
  local pr_num="$4"
  local commit_hash="$5"

  local link
  if [ -n "$pr_num" ]; then
    link=$(CreatePRLink "$org" "$repo" "$pr_num")
  else
    link=$(CreateCommitLink "$org" "$repo" "$commit_hash")
  fi
  echo "orb($repo): $commit_msg $link"
}

# Create PR Link
CreatePRLink() {
  local org="$1"
  local repo="$2"
  local pr_number="$3"
  echo "https://github.com/$org/$repo/pull/$pr_number"
}

# Create Commit Link
CreateCommitLink() {
  local org="$1"
  local repo="$2"
  local commit_hash="$3"
  echo "https://github.com/$org/$repo/commit/$commit_hash"
}

ParseCommitInfo() {
  if [ "$ORB_TEST_ENV" = "bats-core" ]; then
    PARSE_COMMIT_REPO_URL=$(GetNormalizedRepoURL "$TEST_REPO_URL")
  else
    PARSE_COMMIT_REPO_URL=$(GetNormalizedRepoURL "$CIRCLE_REPOSITORY_URL")
  fi

  PARSE_COMMIT_COMMIT_MESSAGE=$(FetchCommitMessage)
  PARSE_COMMIT_COMMIT_HASH=$(FetchCommitHash)

  read -r ORG_NAME PARSE_COMMIT_REPO_NAME <<< "$(ExtractGitHubOrgAndRepo "$PARSE_COMMIT_REPO_URL")"
  PARSE_COMMIT_PR_NUMBER=$(ExtractPRNumber "$PARSE_COMMIT_COMMIT_MESSAGE")

  final_commit_message=$(ConstructCommitMessage "$ORG_NAME" "$PARSE_COMMIT_REPO_NAME" "$PARSE_COMMIT_COMMIT_MESSAGE" "$PARSE_COMMIT_PR_NUMBER" "$PARSE_COMMIT_COMMIT_HASH")

  echo "$final_commit_message"
}


ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then

  cd "$SOURCE_REPO_DIRECTORY" || { echo "Changing directory failed"; exit 1; }

  final_commit_message="$(ParseCommitInfo)"

  # Logging statements to inspect variables
  echo "CIRCLE_REPOSITORY_URL: $CIRCLE_REPOSITORY_URL"
  echo "SOURCE_REPO_DIRECTORY: $SOURCE_REPO_DIRECTORY"
  echo "PARSE_COMMIT_COMMIT_MESSAGE: $PARSE_COMMIT_COMMIT_MESSAGE"
  echo "PARSE_COMMIT_COMMIT_HASH: $PARSE_COMMIT_COMMIT_HASH"
  echo "PARSE_COMMIT_REPO_URL: $PARSE_COMMIT_REPO_URL"
  echo "PARSE_COMMIT_REPO_NAME: $PARSE_COMMIT_REPO_NAME"
  echo "PARSE_COMMIT_PR_NUMBER: $PARSE_COMMIT_PR_NUMBER"
  echo "final_commit_message: $final_commit_message"
  echo "export FINAL_COMMIT_MESSAGE='$final_commit_message'" >> "$BASH_ENV"
fi
