#!/bin/bash

TARGET_JSON="$TARGET_REPO_DIRECTORY/projects.json"
TMP_FILE="tmp_$$.json"

# Trap to cleanup temporary files in case of an error
trap 'rm -f "$TMP_FILE"' EXIT

# Validate project name
if [[ "$PACKAGE_NAME" =~ [\"\'\:\*\?\<\>\|\\\/] || "$PACKAGE_NAME" == "." || "$PACKAGE_NAME" == ".." || ${#PACKAGE_NAME} -gt 255 || "$PACKAGE_NAME" =~ ^- || "$PACKAGE_NAME" =~ $'\n' ]]; then
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

echo "NEW JQ LOGIC -- V1"

# Construct the jq query
JQ_QUERY=".[\"$PACKAGE_NAME\"] = {\"description\": \"$PACKAGE_DESCRIPTION\", \"label\": \"$LABEL\"}"

# Use the constructed query with jq
if echo "$JQ_QUERY" | jq -f- "$TARGET_JSON" > "$TMP_FILE" && mv "$TMP_FILE" "$TARGET_JSON"; then
    echo "[SUCCESS] $TARGET_JSON has been updated successfully with package name: $PACKAGE_NAME, description: $PACKAGE_DESCRIPTION, and label: $LABEL."
else
    echo "[ERROR] Failed to update $TARGET_JSON. Exiting script."
    exit 1
fi
