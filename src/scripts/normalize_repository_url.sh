#! /bin/bash

# Function to change to the source repository directory
ChangeToSourceRepoDirectory() {
  cd "$SOURCE_REPO_DIRECTORY" || { echo "Changing directory failed" >&2; exit 1; }
}

# Function to normalize the GitHub URL
NormalizeRepoURL() {
  local REPO_URL="$1"
  local NORMALIZED_REPO_URL

  echo "REPO_URL: $REPO_URL" >&2

  if [[ "$REPO_URL" == https://* ]]; then
    echo "HTTPS URL detected" >&2
    NORMALIZED_REPO_URL="${REPO_URL%.git}"
  else
    echo "SSH URL detected" >&2
    NORMALIZED_REPO_URL="${REPO_URL/git@github.com:/https://github.com/}"
    NORMALIZED_REPO_URL="${NORMALIZED_REPO_URL%.git}"
  fi

  echo "NORMALIZED_REPO_URL: $NORMALIZED_REPO_URL" >&2



  echo "export NORMALIZED_REPO_URL=\"${NORMALIZED_REPO_URL}\"" >> "$BASH_ENV"
}

# Only call the functions if not in a Bats test environment
ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  ChangeToSourceRepoDirectory
  NormalizeRepoURL "$CIRCLE_REPOSITORY_URL"
fi
