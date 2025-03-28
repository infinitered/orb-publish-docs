#!/bin/bash

echo "TARGET_REPO_DIRECTORY_PARAM=$TARGET_REPO_DIRECTORY_PARAM"
echo "SOURCE_REPO_DIRECTORY_PARAM=$SOURCE_REPO_DIRECTORY_PARAM"

# Construct paths with $CIRCLE_WORKING_DIRECTORY
FULL_SOURCE_DOCS_PATH=$(eval echo "${CIRCLE_WORKING_DIRECTORY}/${SOURCE_REPO_DIRECTORY_PARAM}/${SOURCE_DOCS_DIR}")
FULL_TARGET_DOCS_PATH=$(eval echo "${CIRCLE_WORKING_DIRECTORY}/${TARGET_REPO_DIRECTORY_PARAM}/${TARGET_DOCS_DIR}")
SOURCE_REPO_DIRECTORY=$(eval echo "${CIRCLE_WORKING_DIRECTORY}/${SOURCE_REPO_DIRECTORY_PARAM}")
TARGET_REPO_DIRECTORY=$(eval echo "${CIRCLE_WORKING_DIRECTORY}/${TARGET_REPO_DIRECTORY_PARAM}")

{
  # Set environment variables for subsequent steps
  echo "export FULL_SOURCE_DOCS_PATH=\"${FULL_SOURCE_DOCS_PATH}\""
  echo "export FULL_TARGET_DOCS_PATH=\"${FULL_TARGET_DOCS_PATH}\""
  echo "export SOURCE_REPO_DIRECTORY=\"${SOURCE_REPO_DIRECTORY}\""
  echo "export TARGET_REPO_DIRECTORY=\"${TARGET_REPO_DIRECTORY}\""
  echo "export DESCRIPTION=\"${DESCRIPTION}\""
  echo "export GIT_EMAIL=\"${GIT_EMAIL}\""
  echo "export GIT_USERNAME=\"${GIT_USERNAME}\""
  echo "export LABEL=\"${LABEL}\""
  echo "export PROJECT_NAME=\"${PROJECT_NAME}\""
  echo "export SOURCE_DOCS_DIR=\"${SOURCE_DOCS_DIR}\""
  echo "export TARGET_REPO=\"${TARGET_REPO}\""
  echo "export SSH_KEY_FINGERPRINT=\"${SSH_KEY_FINGERPRINT}\""
} >> "$BASH_ENV"

# Log Environment Variables
echo "DESCRIPTION: ${DESCRIPTION}"
echo "FULL_SOURCE_DOCS_PATH: ${FULL_SOURCE_DOCS_PATH}"
echo "FULL_TARGET_DOCS_PATH: ${FULL_TARGET_DOCS_PATH}"
echo "GIT_EMAIL: ${GIT_EMAIL}"
echo "GIT_USERNAME: ${GIT_USERNAME}"
echo "LABEL: ${LABEL}"
echo "PROJECT_NAME: ${PROJECT_NAME}"
echo "SOURCE_DOCS_DIR: ${SOURCE_DOCS_DIR}"
echo "SOURCE_REPO_DIRECTORY: ${SOURCE_REPO_DIRECTORY}"
echo "TARGET_REPO: ${TARGET_REPO}"
echo "TARGET_REPO_DIRECTORY: ${TARGET_REPO_DIRECTORY}"
echo "SSH_KEY_FINGERPRINT: ${SSH_KEY_FINGERPRINT}"

echo "Environment variables set"
