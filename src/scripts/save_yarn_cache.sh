#!/bin/bash

SaveYarnCache() {
  CACHE_KEY="yarn-cache-$TARGET_REPO_DIRECTORY-$(sha256sum "$TARGET_REPO_DIRECTORY"/yarn.lock | awk '{print $1}')"
  circleci cache save --key "$CACHE_KEY" --path "$TARGET_REPO_DIRECTORY"/.yarn/cache
}

# Check for bats
ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
    SaveYarnCache
fi
