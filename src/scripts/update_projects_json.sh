#!/bin/bash

TARGET_JSON="$TARGET_REPO_DIRECTORY/projects.json"
TMP_FILE="tmp_$$.json"

# Trap to cleanup temporary files in case of an error
trap 'rm -f "$TMP_FILE"' EXIT

# Validate project name
if [[ "$PROJECT_NAME" =~ [\"\'\:\*\?\<\>\|\\\/] || "$PROJECT_NAME" == "." || "$PROJECT_NAME" == ".." || ${#PROJECT_NAME} -gt 255 || "$PROJECT_NAME" =~ ^- || "$PROJECT_NAME" =~ $'\n' ]]; then
    echo "[ERROR] Error: Project-name must be a valid directory name and js-object key."
    exit 1
fi

# Check if jq is installed, if not, install it.
if ! command -v jq &> /dev/null; then
    echo "[INFO] jq could not be found. Attempting to install..."
    if sudo apt-get update && sudo apt-get install -y jq; then
        echo "[SUCCESS] jq was installed successfully."
    else
        echo "[ERROR] Failed to install jq. Exiting script."
        exit 1
    fi

    # Re-check if jq is installed after attempting to install it
    if ! command -v jq &> /dev/null; then
        echo "[ERROR] jq is still not available. Exiting script."
        exit 1
    fi
else
    echo "[INFO] jq is already installed."
fi

# Check if projects.json exists. If not, create an empty one.
if [ ! -f "$TARGET_JSON" ]; then
    echo "[INFO] $TARGET_JSON does not exist. Creating an empty file."
    echo "{}" > "$TARGET_JSON"
else
    echo "[INFO] $TARGET_JSON found."
fi

# Construct the jq query
JQ_QUERY=".[\"$PROJECT_NAME\"] = {\"description\": \"$DESCRIPTION\", \"label\": \"$LABEL\"}"



# Use the constructed query with jq
if cat "$TARGET_JSON" | jq "$JQ_QUERY" > "$TMP_FILE" && mv "$TMP_FILE" "$TARGET_JSON"; then
    echo "[SUCCESS] $TARGET_JSON has been updated successfully with package name: $PROJECT_NAME, description: $DESCRIPTION, and label: $LABEL."
else
    echo "[ERROR] Failed to update $TARGET_JSON. Exiting script."
    exit 1
fi
