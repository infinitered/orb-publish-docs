#! /bin/bash


# Function to validate the repository URL and extract organization and repository name
ValidateAndExtractRepoInfo() {
  local EXTRACTED
  local ORG
  local REPO

  # Validate the repository URL
  if [[ "$NORMALIZED_REPO_URL" != *github.com* ]]; then
    echo "Error: Not a GitHub URL." >&2
    exit 1
  fi

  # Extract GitHub organization and repository name
  EXTRACTED=$(echo "$NORMALIZED_REPO_URL" | awk -F'/' '{gsub(".git", "", $NF); print $(NF-1), $NF}')

  echo "EXTRACTED: $EXTRACTED" >&2

  if [ -z "$EXTRACTED" ]; then
    echo "Error: Invalid GitHub URL format." >&2
    exit 1
  fi

  read -r ORG REPO <<< "$EXTRACTED"

  echo "ORG: $ORG" >&2
  echo "REPO: $REPO" >&2

  # Export extracted organization and repository name as environment variables
  {
    echo "export GITHUB_ORG=\"${ORG}\""; \
    echo "export GITHUB_REPO=\"${REPO}\""; \
  } >> "$BASH_ENV"
}


# Check for bats
ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  ValidateAndExtractRepoInfo
fi
