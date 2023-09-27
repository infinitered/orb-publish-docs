#!/usr/bin/env bats

# Mock git command to just echo the arguments
git() {
  echo "$@"
}

export $WORKING_DIR="."


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
  pwd
  # Mock environment variables
  export TARGET_REPO_DIRECTORY="/path/to/nonexistent/repo"
  export FINAL_COMMIT_MESSAGE="Commit message"

  # Run the script
  run ./src/scripts/commit_and_push_to_target.sh

  # Validate output or status
  [ "$output" =~ "Changing directory failed" ]
  [ "$status" -eq 1 ]
}

@test "It runs git add and succeeds" {
  pwd
  # Mock environment variables
  export TARGET_REPO_DIRECTORY=$WORKING_DIR
  export FINAL_COMMIT_MESSAGE="Commit message"

  # Run the script
  run ./src/scripts/commit_and_push_to_target.sh

  # Validate output
  [ "$output" =~ "add ." ]
}

@test "It runs git commit and succeeds" {
  # Mock environment variables
  export TARGET_REPO_DIRECTORY=$WORKING_DIR
  export FINAL_COMMIT_MESSAGE="Commit message"

  # Run the script
  run ./src/scripts/commit_and_push_to_target.sh

  # Validate output
  [ "$output" =~ "commit -m \"Commit message\"" ]
}

@test "It runs git push and succeeds" {
  # Mock environment variables
  export TARGET_REPO_DIRECTORY=$WORKING_DIR
  export FINAL_COMMIT_MESSAGE="Commit message"

  # Run the script
  run ./src/scripts/commit_and_push_to_target.sh

  # Validate output
  [ "$output" =~ "push origin main" ]
}
