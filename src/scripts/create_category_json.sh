#! /bin/bash
# Parameters: Project name, Label, Description

CreateCategoryJSON() {
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
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  CreateCategoryJSON
fi

