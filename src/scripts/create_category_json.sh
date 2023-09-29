#!/bin/bash

# Assumes LABEL, DESCRIPTION, TARGET_REPO_DIRECTORY, and PROJECT_NAME are environment variables

CreateCategoryJSONFromTemplate() {
    # Inlined template with placeholders
    # shellcheck disable=SC2016
    TEMPLATE='{"label": "${LABEL}","link": {"type": "generated-index","description": "${DESCRIPTION}"}}'

    # Substitute the variables in the template and write to target location
    echo "$TEMPLATE" | sed \
        -e "s/\${LABEL}/$LABEL/" \
        -e "s/\${DESCRIPTION}/$DESCRIPTION/" \
        > "$TARGET_REPO_DIRECTORY/docs/$PROJECT_NAME/_category_.json"

    echo "_category_.json file created successfully."
}

# Check for bats
ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
    CreateCategoryJSONFromTemplate
fi
