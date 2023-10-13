#!/bin/bash




RestoreYarnCache() {
  echo "Target Repo Directory: $TARGET_REPO_DIRECTORY" >&2
  CACHE_KEY="yarn-cache-$TARGET_REPO_DIRECTORY-$(sha256sum "$TARGET_REPO_DIRECTORY/yarn.lock" | awk '{print $1}')"
  ls "$TARGET_REPO_DIRECTORY"
  circleci cache restore "$CACHE_KEY"
}

# Call the function only if not in a Bats test environment
ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  RestoreYarnCache
fi
