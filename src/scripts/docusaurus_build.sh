#! /bin/bash

DocusaurusBuild() {
    echo "Changing to target directory: $TARGET_REPO_DIRECTORY" >&2
    cd "$TARGET_REPO_DIRECTORY" || { echo "Changing directory failed" >&2; exit 1; }
    echo "Running Docusaurus build..." >&2
    yarn build || { echo "Docusaurus build failed" >&2; exit 1; }
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  DocusaurusBuild
fi
