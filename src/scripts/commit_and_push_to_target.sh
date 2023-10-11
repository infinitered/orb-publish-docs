#! /bin/bash

CommitAndPushToTarget () {
cd "$TARGET_REPO_DIRECTORY" || { echo "Changing directory failed"; exit 1; }

git add docs || { echo "Git add docs failed"; exit 1; }
git add static || { echo "Git add static failed"; exit 1; }

if git diff-index --quiet HEAD --; then
    echo "No changes"
    exit 0

else
    git commit -m "$FINAL_COMMIT_MESSAGE" || { echo "Git commit failed"; exit 1; }
    git push origin main || { echo "Git push failed"; exit 1; }
fi
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  echo "Final Commit Message: '$FINAL_COMMIT_MESSAGE'"
  CommitAndPushToTarget
fi
