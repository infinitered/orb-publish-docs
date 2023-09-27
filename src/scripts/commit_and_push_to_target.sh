#! /bin/bash

# Parameters: Final commit message

cd "$TARGET_REPO_DIRECTORY" || { echo "Changing directory failed"; exit 1; }
git add . || { echo "Git add failed"; exit 1; }
git commit -m "$FINAL_COMMIT_MESSAGE" || { echo "Git commit failed"; exit 1; }
git push origin main || { echo "Git push failed"; exit 1; }
