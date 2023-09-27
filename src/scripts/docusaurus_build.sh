#! /bin/bash
echo "Changing to target directory: $TARGET_REPO_DIRECTORY"
cd "$TARGET_REPO_DIRECTORY" || { echo "Changing directory failed"; exit 1; }
echo "Running Docusaurus build..."
yarn build || { echo "Docusaurus build failed"; exit 1; }
