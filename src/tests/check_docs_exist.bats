#! /bin/bash



declare -x TEST_DIR=""
TEST_DIR="$(pwd)/test_docs_dir_with_files"

create_test_dir(){
    mkdir "$TEST_DIR"
}

create_test_files(){
    create_test_dir;
    touch "$TEST_DIR/file1.txt"
    touch "$TEST_DIR/file2.txt"
}

erase_test_files(){
    rm -rf "$TEST_DIR"
}

# Source the script to get the CheckDocsExist function
source ./src/scripts/check_docs_exist.sh

@test "It checks if documents exist in source directory and finds files" {
  create_test_files;

  export FULL_SOURCE_DOCS_PATH="$TEST_DIR"

  # Run the function
  run CheckDocsExist

  # Validate output or status
  [[ "$output" == "Checking if documents exist in the source directory." ]]
  [[ "$status" -eq 0 ]]

  erase_test_files;
}

@test "It checks if documents exist in source directory and finds no files" {
  create_test_dir;

  ls() { :; }  # Mock ls to simulate an empty directory

  export FULL_SOURCE_DOCS_PATH="$TEST_DIR"

  # Run the function
  run CheckDocsExist

  # Validate output or status
  [[ "$output" =~ "No files found" ]]
  [[ "$status" -eq 1 ]]

  erase_test_files;
}

@test "It checks if documents exist in a non-existent source directory" {
  # Set a non-existent path
  export FULL_SOURCE_DOCS_PATH="/path/to/nonexistent/directory"

  # Run the function
  run CheckDocsExist

  # Validate output or status
  [[ "$output" =~ "does not exist" ]]
  [[ "$status" -eq 1 ]]
}
