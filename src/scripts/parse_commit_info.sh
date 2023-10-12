#! /bin/bash

# Global variable declarations
COMMIT_MESSAGE=""
COMMIT_HASH=""
REPO_URL=""
REPO_NAME=""
PR_NUMBER=""
final_commit_message=""

ExtractPRNumber() {
  local commit_msg="$1"
  echo "$commit_msg" | grep -o "#[0-9]\+" | grep -o "[0-9]\+" || true
}

FetchCommitMessage() {
  git log -1 --pretty=%B || { echo "Fetching commit message failed"; exit 1; }
}

FetchCommitHash() {
  git rev-parse HEAD || { echo "Fetching commit hash failed"; exit 1; }
}

# Normalize the repository URL for consistent usage
GetNormalizedRepoURL() {
  local repo_url="$1"
  if [[ $repo_url == https://* && ! $repo_url == *.git ]]; then
    echo "$repo_url.git"
  else
    # Convert SSH format to https format for consistency
    echo "$repo_url" | sed 's,git@,https://,' | sed 's,:,/,'
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
    REPOSITORY_URL="$TEST_REPO_URL"
  else
    cd "$SOURCE_REPO_DIRECTORY" || { echo "Changing directory failed"; exit 1; }
    REPOSITORY_URL="$CIRCLE_REPOSITORY_URL"
  fi

  COMMIT_MESSAGE=$(FetchCommitMessage)
  COMMIT_HASH=$(FetchCommitHash)


  REPO_URL=$(GetNormalizedRepoURL "$REPOSITORY_URL")

  read -r ORG_NAME REPO_NAME <<< "$(ExtractGitHubOrgAndRepo "$REPO_URL")"
  PR_NUMBER=$(ExtractPRNumber "$COMMIT_MESSAGE")

  final_commit_message=$(ConstructCommitMessage "$ORG_NAME" "$REPO_NAME" "$COMMIT_MESSAGE" "$PR_NUMBER" "$COMMIT_HASH")
  echo "$final_commit_message"
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  final_commit_message="$(ParseCommitInfo)"

  # Logging statements to inspect variables
  echo "COMMIT_MESSAGE: $COMMIT_MESSAGE"
  echo "COMMIT_HASH: $COMMIT_HASH"
  echo "REPO_URL: $REPO_URL"
  echo "REPO_NAME: $REPO_NAME"
  echo "PR_NUMBER: $PR_NUMBER"
  echo "final_commit_message: $final_commit_message"

  export FINAL_COMMIT_MESSAGE=$final_commit_message
  echo "export FINAL_COMMIT_MESSAGE='$final_commit_message'" >> "$BASH_ENV"
fi
