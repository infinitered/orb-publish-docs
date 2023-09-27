#! /bin/bash

# Extract the last commit message and look for a PR number
COMMIT_MESSAGE=$(git log -1 --pretty=%B) || { echo "Fetching commit message failed"; exit 1; }
COMMIT_HASH=$(git rev-parse HEAD) || { echo "Fetching commit hash failed"; exit 1; }
REPO_URL=$(git config --get remote.origin.url) || { echo "Fetching repo URL failed"; exit 1; }
REPO_NAME=$(basename -s .git "$REPO_URL") || { echo "Parsing repo name failed"; exit 1; }
PR_NUMBER=$(echo "$COMMIT_MESSAGE" | grep -oP "(#\K\d+)")

if [ -n "$PR_NUMBER" ]; then
  PR_LINK="https://github.com/infinitered/$REPO_NAME/pull/$PR_NUMBER"
  FINAL_COMMIT_MESSAGE="$REPO_NAME -- $COMMIT_MESSAGE -- $PR_LINK"
else
  COMMIT_LINK="https://github.com/infinitered/$REPO_NAME/commit/$COMMIT_HASH"
  FINAL_COMMIT_MESSAGE="$REPO_NAME -- $COMMIT_MESSAGE -- $COMMIT_LINK"
fi

echo "export FINAL_COMMIT_MESSAGE=\"$FINAL_COMMIT_MESSAGE\"" >> "$BASH_ENV" || { echo "Exporting FINAL_COMMIT_MESSAGE failed"; exit 1; }
