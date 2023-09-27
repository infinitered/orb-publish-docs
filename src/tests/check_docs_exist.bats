#! /bin/bash

export TEST_DIR="$(pwd)/test_docs_dir_with_files"

create_test_dir(){
    mkdir $TEST_DIR
}

create_test_files(){
    create_test_dir;
    touch $TEST_DIR/file1.txt
    touch $TEST_DIR/file2.txt
}

erase_test_files(){
    rm -rf test_docs_dir_with_files
}

@test "It checks if documents exist in source directory and finds files" {
  create_test_files;
  # Debug: Print current directory
  echo "Debug: Current directory is $(pwd)"

  export SOURCE_DOCS_PATH="$TEST_DIR"

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

  erase_test_files;
}

@test "It checks if documents exist in source directory and finds no files" {
  create_test_dir;
  # Debug: Print current directory
  echo "Debug: Current directory is $(pwd)"

  # Mock the ls command and the environment variable
  ls() { ls_empty; }
  export SOURCE_DOCS_PATH="$TEST_DIR"

  # Debug: Print environment variable
  echo "Debug: SOURCE_DOCS_PATH = '$SOURCE_DOCS_PATH'"

  # Run the script
  run ./src/scripts/check_docs_exist.sh

  # Debug: Print output and status
  echo "Debug: Output = '$output'"
  echo "Debug: Status = '$status'"

  # Validate output or status
  echo "$output" | grep -q "No files found"
  [ "$status" -eq 1 ]

  erase_test_files;
}

@test "It checks if documents exist in a non-existent source directory" {
  # Debug: Print current directory
  echo "Debug: Current directory is $(pwd)"

  # Set a non-existent path
  export SOURCE_DOCS_PATH="/path/to/nonexistent/directory"

  # Debug: Print environment variable
  echo "Debug: SOURCE_DOCS_PATH = '$SOURCE_DOCS_PATH'"

  # Run the script
  run ./src/scripts/check_docs_exist.sh

  # Debug: Print output and status
  echo "Debug: Output = '$output'"
  echo "Debug: Status = '$status'"

  # Validate output or status
  echo "$output" | grep -q "does not exist"
  [ "$status" -eq 1 ]
}
