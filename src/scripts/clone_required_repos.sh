#!/bin/bash

# Function to log environment variables
LogEnvironmentVariables() {
  echo "Logging Environment Variables:"
  echo "CIRCLE_BRANCH: $CIRCLE_BRANCH"
  echo "CIRCLE_TAG: $CIRCLE_TAG"
  echo "CIRCLE_REPOSITORY_URL: $CIRCLE_REPOSITORY_URL"
  echo "SOURCE_REPO_DIRECTORY: $SOURCE_REPO_DIRECTORY"
  echo "TARGET_REPO: $TARGET_REPO"
  echo "TARGET_REPO_DIRECTORY: $TARGET_REPO_DIRECTORY"
  echo "GIT_USERNAME: $GIT_USERNAME"
  echo "GIT_EMAIL: $GIT_EMAIL"
  echo "-----------------------------"
}

# Function to set the Git username and email
SetGitUser() {
  echo "Configuring Git username and email: $GIT_USERNAME -- $GIT_EMAIL" >&2
  git config --global user.name "$GIT_USERNAME" || { echo "Failed to configure Git username"; exit 1; }
  git config --global user.email "$GIT_EMAIL" || { echo "Failed to configure Git email"; exit 1; }
}

# Function to add github.com to known SSH hosts
AddGithubToKnownHosts() {
  echo "Adding github.com to known SSH hosts" >&2
  mkdir -p ~/.ssh
  ssh-keyscan github.com >> ~/.ssh/known_hosts || { echo "Failed to add github.com to known hosts"; exit 1; }
}

CloneSourceRepo() {
  if [ -n "$CIRCLE_TAG" ]; then
    # For tag builds, checkout the commit instead of a branch
    echo "Cloning source repository ($CIRCLE_REPOSITORY_URL) for tag $CIRCLE_TAG to $SOURCE_REPO_DIRECTORY" >&2
    git clone "$CIRCLE_REPOSITORY_URL" "$SOURCE_REPO_DIRECTORY"
    cd "$SOURCE_REPO_DIRECTORY" || { echo "Failed to change directory to $SOURCE_REPO_DIRECTORY"; exit 1; }
    git checkout "$CIRCLE_TAG"
  elif [ -n "$CIRCLE_BRANCH" ]; then
    # For branch builds, checkout the specific branch
    echo "Cloning the $CIRCLE_BRANCH branch of source repository ($CIRCLE_REPOSITORY_URL) to $SOURCE_REPO_DIRECTORY" >&2
    git clone --branch "$CIRCLE_BRANCH" "$CIRCLE_REPOSITORY_URL" "$SOURCE_REPO_DIRECTORY"
    cd "$SOURCE_REPO_DIRECTORY" || { echo "Failed to change directory to $SOURCE_REPO_DIRECTORY"; exit 1; }
  else
    echo "Neither CIRCLE_BRANCH nor CIRCLE_TAG is set. Unable to determine which branch or tag to clone." >&2
    exit 1
  fi
}

# Function to clone the target repository
CloneTargetRepo() {
  echo "Cloning target repository from $TARGET_REPO to $TARGET_REPO_DIRECTORY" >&2
  git clone "$TARGET_REPO" "$TARGET_REPO_DIRECTORY" || { echo "Failed to clone target repository"; exit 1; }
  ls "$TARGET_REPO_DIRECTORY"
}

# Check if the script is being sourced or executed directly
ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  LogEnvironmentVariables
  echo "Script is being executed directly" >&2

  SetGitUser
  AddGithubToKnownHosts
  CloneSourceRepo
  CloneTargetRepo
fi
