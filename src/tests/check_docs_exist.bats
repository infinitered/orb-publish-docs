#!/usr/bin/env bats

unalias ls

# Mock ls command to simulate a directory with files
ls_with_files() {
  echo "file1.txt file2.txt"
  return 0
}

# Mock ls command to simulate an empty directory
ls_empty() {
  echo ""
  return 0
}

@test "It checks if documents exist in source directory and finds files" {
  # Debug: Print current directory
  echo "Debug: Current directory is $(pwd)"

  # Mock the ls command and the environment variable
  ls() { ls_with_files; }
  export SOURCE_DOCS_PATH="/path/to/docs"

  # Debug: Print environment variable
  echo "Debug: SOURCE_DOCS_PATH = '$SOURCE_DOCS_PATH'"

  # Run the script
  run ./src/scripts/check_docs_exist.sh

  # Debug: Print output and status
  echo "Debug: Output = '$output'"
  echo "Debug: Status = '$status'"

  # Validate output or status
  [ "$output" = "Checking if documents exist in the source directory." ]
  [ "$status" -eq 0 ]
}

@test "It checks if documents exist in source directory and finds no files" {
  # Debug: Print current directory
  echo "Debug: Current directory is $(pwd)"

  # Mock the ls command and the environment variable
  ls() { ls_empty; }
  export SOURCE_DOCS_PATH="/path/to/docs"

  # Debug: Print environment variable
  echo "Debug: SOURCE_DOCS_PATH = '$SOURCE_DOCS_PATH'"

  # Run the script
  run ./src/scripts/check_docs_exist.sh

  # Debug: Print output and status
  echo "Debug: Output = '$output'"
  echo "Debug: Status = '$status'"

  # Validate output or status
  [ "$output" = "Checking if documents exist in the source directory.\nError: No files found in docs directory." ]
  [ "$status" -eq 1 ]
}
