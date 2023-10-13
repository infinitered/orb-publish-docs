#!/bin/bash

# Function to change to the source repository directory
ChangeToSourceRepoDirectory() {
  cd "$SOURCE_REPO_DIRECTORY" || { echo "Changing directory failed"; exit 1; }
}


# Function to fetch commit information and extract PR number
FetchCommitInfo() {
  local PR_NUMBER
  local COMMIT_MESSAGE
  local COMMIT_HASH

  # Fetch the last commit message and hash
  COMMIT_MESSAGE=$(git log -1 --pretty=%B || { echo "Fetching commit message failed"; exit 1; })
  COMMIT_HASH=$(git rev-parse HEAD || { echo "Fetching commit hash failed"; exit 1; })

  # Extract PR number from the commit message using regex
  PR_NUMBER=$(echo "$COMMIT_MESSAGE" | grep -oP '(Merge pull request #\K\d+)|(\(#\K\d+\))')
  PR_NUMBER=${PR_NUMBER:-""} # Set to empty string if no match

  # Export the variables
  {
    echo "export COMMIT_MESSAGE=\"${COMMIT_MESSAGE}\""
    echo "export COMMIT_HASH=\"${COMMIT_HASH}\""
    echo "export PR_NUMBER=\"$PR_NUMBER\""
  } >> "$BASH_ENV"
}

# Only call the function if not in a Bats test environment
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  ChangeToSourceRepoDirectory
  FetchCommitInfo
fi
