#!/usr/bin/env bats

load '../src/scripts/docusaurus_build.sh'

@test "It changes to the TARGET_REPO_DIRECTORY" {
  export TARGET_REPO_DIRECTORY="/path/to/target"
  run build_docusaurus  # Assuming function name is build_docusaurus in docusaurus_build.sh
  [ "$output" =~ "Changing to target directory: /path/to/target" ]
}

@test "It runs yarn build" {
  run build_docusaurus
  [ "$output" =~ "Running Docusaurus build..." ]
}

@test "It handles yarn build failure" {
  run build_docusaurus
  [ "$output" =~ "Docusaurus build failed" ]
}
