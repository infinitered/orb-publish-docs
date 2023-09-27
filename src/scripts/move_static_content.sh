


echo "Checking for static files in the target repository."
if [ "$(ls -A "$HOME/$TARGET_REPO_DIRECTORY/docs/$PROJECT_NAME/_static_")" ]; then
  echo "Moving static files."
  mv "$HOME/$TARGET_REPO_DIRECTORY/docs/$PROJECT_NAME/_static_" "$HOME/$TARGET_REPO_DIRECTORY/static/$PROJECT_NAME/"
  echo "Static files moved successfully."
else
  echo "No static files to copy."
fi
