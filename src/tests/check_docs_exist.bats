#!/usr/bin/env bats

# Mock ls command to simulate a directory with files
ls_with_files() {
  echo "file1.txt file2.txt"
}

# Mock ls command to simulate an empty directory
ls_empty() {
  echo ""
}

@test "It checks if documents exist in source directory and finds files" {
  # Mock the ls command and the environment variable
  ls() { ls_with_files; }
  export SOURCE_DOCS_PATH="/path/to/docs"

  # Run the script
  run source check_docs_exist.sh

  # Validate output or status
  [ "$output" = "Checking if documents exist in the source directory." ]
  [ "$status" -eq 0 ]
}

@test "It checks if documents exist in source directory and finds no files" {
  # Mock the ls command and the environment variable
  ls() { ls_empty; }
  export SOURCE_DOCS_PATH="/path/to/docs"

  # Run the script
  run source check_docs_exist.sh

  # Validate output or status
  [ "$output" = "Checking if documents exist in the source directory.\nError: No files found in docs directory." ]
  [ "$status" -eq 1 ]
}
