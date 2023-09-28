#! /bin/bash

# Function to set the Git username and email
SetGitUser() {
  echo "Configuring Git username and email: $GIT_USERNAME -- $GIT_EMAIL"
  git config --global user.name "$GIT_USERNAME" || { echo "Failed to configure Git username"; exit 1; }
  git config --global user.email "$GIT_EMAIL" || { echo "Failed to configure Git email"; exit 1; }
}

# Function to add github.com to known SSH hosts
AddGithubToKnownHosts() {
  echo "Adding github.com to known SSH hosts"
  mkdir -p ~/.ssh
  ssh-keyscan github.com >> ~/.ssh/known_hosts || { echo "Failed to add github.com to known hosts"; exit 1; }
}

# Function to clone the source repository
CloneSourceRepo() {
  echo "Cloning source repository from $CIRCLE_REPOSITORY_URL to $SOURCE_REPO_DIRECTORY"
  git clone "$CIRCLE_REPOSITORY_URL" "$SOURCE_REPO_DIRECTORY" || { echo "Failed to clone source repository"; exit 1; }
}

# Function to clone the target repository
CloneTargetRepo() {
  echo "Cloning target repository from $TARGET_REPO to $TARGET_REPO_DIRECTORY"
  git clone "$TARGET_REPO" "$TARGET_REPO_DIRECTORY" || { echo "Failed to clone target repository"; exit 1; }
}

# Check if the script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  SetGitUser
  AddGithubToKnownHosts
  CloneSourceRepo
  CloneTargetRepo
fi
