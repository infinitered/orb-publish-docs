#!/bin/bash

echo "Target Repo Directory: $TARGET_REPO_DIRECTORY"
ls "$TARGET_REPO_DIRECTORY"
CACHE_KEY="yarn-cache-$TARGET_REPO_DIRECTORY-$(sha256sum "$TARGET_REPO_DIRECTORY/yarn.lock" | awk '{print $1}')"
circleci cache restore "$CACHE_KEY"
