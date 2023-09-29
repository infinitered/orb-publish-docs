#!/bin/bash
CACHE_KEY="yarn-cache-$TARGET_REPO_DIRECTORY-$(sha256sum "$TARGET_REPO_DIRECTORY"/yarn.lock | awk '{print $1}')"
circleci cache save --key "$CACHE_KEY" --path "$TARGET_REPO_DIRECTORY"/.yarn/cache
