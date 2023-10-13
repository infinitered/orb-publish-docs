#! /bin/bash

# Function to commit and push changes to the target repository
CommitAndPushToTarget() {
  cd "$TARGET_REPO_DIRECTORY" || { echo "Changing directory failed" >&2; exit 1; }

git add docs || { echo "Git add docs failed" >&2; exit 1; }
git add static || { echo "Git add static failed" >&2; exit 1; }

if git diff-index --quiet HEAD --; then
    echo "No changes"  >&2
    exit 0

else
    git commit -m "$FINAL_COMMIT_MESSAGE" || { echo "Git commit failed" >&2; exit 1; }
    git push origin main || { echo "Git push failed" >&2; exit 1; }
fi
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  echo "Final Commit Message: '$FINAL_COMMIT_MESSAGE'" >&2
  CommitAndPushToTarget
fi
