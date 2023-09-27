#! /bin/bash

# Mock yarn build command to just echo the arguments
yarn() {
  echo "$@"
}

# Source the script to get the DocusaurusBuild function
source ./src/scripts/docusaurus_build.sh

@test "It changes to the TARGET_REPO_DIRECTORY" {
  export TARGET_REPO_DIRECTORY="/path/to/target"

  # Run the function
  run DocusaurusBuild

  # Validate output
  [[ $output =~ Changing\ to\ target\ directory:\ /path/to/target ]]
}

@test "It runs yarn build" {
  # Run the function
  run DocusaurusBuild

  # Validate output
  [[ $output =~ Running\ Docusaurus\ build... ]]
}

@test "It handles yarn build failure" {
  # Mock yarn build to return an error
  yarn() {
    return 1
  }

  # Run the function
  run DocusaurusBuild

  # Validate output and status
  [[ $output =~ Docusaurus\ build\ failed ]]
  [[ "$status" -eq 1 ]]
}
