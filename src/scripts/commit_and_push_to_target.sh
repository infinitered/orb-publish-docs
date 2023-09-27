#! /bin/bash

CommitAndPushToTarget () {
cd "$TARGET_REPO_DIRECTORY" || { echo "Changing directory failed"; exit 1; }
git add docs || { echo "Git add docs failed"; exit 1; }
git add static || { echo "Git add static failed"; exit 1; }
git commit -m "$FINAL_COMMIT_MESSAGE" || { echo "Git commit failed"; exit 1; }
git push origin main || { echo "Git push failed"; exit 1; }
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  CommitAndPushToTarget
fi
