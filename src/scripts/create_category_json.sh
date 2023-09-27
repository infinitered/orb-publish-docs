# Parameters: Project name, Label, Description
echo "Creating _category_.json file."
echo "
\{
  \"label\": \"$LABEL\",
  \"link\": \{
    \"type\": \"generated-index\",
    \"description\": \"$DESCRIPTION\"
  \}
\}
" > "$HOME/$TARGET_REPO_DIRECTORY/docs/$PROJECT_NAME/_category_.json"

echo "_category_.json file created successfully."
