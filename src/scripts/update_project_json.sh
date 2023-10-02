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

# Check reserved JS object keys - can expand this list as needed
declare -A reserved_keys=(
  ["__proto__"]=1
  ["__defineGetter__"]=1
  ["__defineSetter__"]=1
  ["constructor"]=1
)

if [[ ${reserved_keys["$PACKAGE_NAME"]} ]]; then
    echo "[ERROR] Error: $PACKAGE_NAME is a reserved JS object key."
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

# Use jq to update or add the package name and description.
if jq --arg name "$PACKAGE_NAME" --arg desc "$PACKAGE_DESCRIPTION" --arg label "$LABEL" '.[$name] = {"description": $desc, "label": $label}' "$TARGET_JSON" > "$TMP_FILE" && mv "$TMP_FILE" "$TARGET_JSON"; then
    echo "[SUCCESS] $TARGET_JSON has been updated successfully with package name: $PACKAGE_NAME, description: $PACKAGE_DESCRIPTION, and label: $LABEL."
else
    echo "[ERROR] Failed to update $TARGET_JSON. Exiting script."
    exit 1
fi
