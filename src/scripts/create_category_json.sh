#!/bin/bash

# Assumes LABEL, DESCRIPTION, TARGET_REPO_DIRECTORY, and PROJECT_NAME are environment variables

CreateCategoryJSON() {
    # Ensure the target directory exists
    mkdir -p "$TARGET_REPO_DIRECTORY/docs/$PROJECT_NAME/"

    # Inlined template with placeholders
    # shellcheck disable=SC2016
    TEMPLATE='{"label": "${LABEL}","link": {"type": "generated-index","title": "${LABEL}"},"customProps": {"description": "${DESCRIPTION}", "projectName":"${PROJECT_NAME}"}}'

# Substitute the variables in the template and write to target location
    echo "$TEMPLATE" | sed \
        -e "s/\${LABEL}/$LABEL/g" \
        -e "s/\${DESCRIPTION}/$DESCRIPTION/" \
        -e "s/\${PROJECT_NAME}/$PROJECT_NAME/" \
        > "$TARGET_REPO_DIRECTORY/docs/$PROJECT_NAME/_category_.json"

    echo "_project_.json file created successfully."
}

# Check for bats
ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
    CreateCategoryJSON
fi





