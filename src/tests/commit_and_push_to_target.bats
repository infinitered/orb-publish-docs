#!/usr/bin/env bats

# Mock git command to just echo the arguments
git() {
  echo "$@"
}

export WORKING_DIR="."


# Mock cd command to just echo the directory
cd() {
  if [ "$1" = $WORKING_DIR ]; then
    echo "Changing directory to $1"
    return 0  # Success
  else
    echo "Changing directory failed"
    return 1  # Failure
  fi
}

@test "It changes to the TARGET_REPO_DIRECTORY and succeeds" {
  # Mock environment variables
  export TARGET_REPO_DIRECTORY="/path/to/repo"
  export FINAL_COMMIT_MESSAGE="Commit message"

  # Run the script
  run ./src/scripts/commit_and_push_to_target.sh

  # Debug: Print output and status
  echo "Debug: Output = '$output'"
  echo "Debug: Status = '$status'"

  # Validate output or status
  echo "$output" | grep -q "Changing directory to /path/to/repo"
  [ "$status" -eq 0 ]  # assuming the script should exit successfully
}

@test "It runs git add and succeeds" {
  pwd
  # Mock environment variables
  export TARGET_REPO_DIRECTORY=$WORKING_DIR
  export FINAL_COMMIT_MESSAGE="Commit message"

  # Run the script
  run ./src/scripts/commit_and_push_to_target.sh

  echo "Debug: Output = '$output'"

  # Validate output
  [ "$output" =~ "add ." ]
}

@test "It runs git commit and succeeds" {
  # Mock environment variables
  export TARGET_REPO_DIRECTORY=$WORKING_DIR
  export FINAL_COMMIT_MESSAGE="Commit message"

  # Run the script
  run ./src/scripts/commit_and_push_to_target.sh

  echo "Debug: Output = '$output'"

  # Validate output
  [ "$output" =~ "commit -m \"Commit message\"" ]
}

@test "It runs git push and succeeds" {
  # Mock environment variables
  export TARGET_REPO_DIRECTORY=$WORKING_DIR
  export FINAL_COMMIT_MESSAGE="Commit message"

  # Run the script
  run ./src/scripts/commit_and_push_to_target.sh

  echo "Debug: Output = '$output'"

  # Validate output
  [ "$output" =~ "push origin main" ]
}
