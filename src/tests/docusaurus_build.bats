#!/usr/bin/env bats

# Mock yarn build command to just echo the arguments
yarn() {
  echo "$@"
}

@test "It changes to the TARGET_REPO_DIRECTORY" {
  export TARGET_REPO_DIRECTORY="/path/to/target"
  run ./src/scripts/build_docusaurus.sh
  [[ "$output" =~ "Changing to target directory: /path/to/target" ]]
}

@test "It runs yarn build" {
  run ./src/scripts/build_docusaurus.sh
  [[ "$output" =~ "Running Docusaurus build..." ]]
}

@test "It handles yarn build failure" {
  # Mock yarn build to return an error
  yarn() {
    return 1
  }
  run ./src/scripts/build_docusaurus.sh
  [[ "$output" =~ "Docusaurus build failed" ]]
  [ "$status" -eq 1 ]
}
