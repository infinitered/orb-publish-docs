#! /bin/bash

if [[ "$USE_MOCKS" == "true" ]]; then
  git() {
    echo "Mocked git $*"
  }
fi

# Parameters: Final commit message

cd "$TARGET_REPO_DIRECTORY" || { echo "Changing directory failed"; exit 1; }
git add docs || { echo "Git add docs failed"; exit 1; }
git add static || { echo "Git add static failed"; exit 1; }
git commit -m "$FINAL_COMMIT_MESSAGE" || { echo "Git commit failed"; exit 1; }
git push origin main || { echo "Git push failed"; exit 1; }
