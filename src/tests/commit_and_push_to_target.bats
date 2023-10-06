#! /bin/bash

# Mock git command
git() {
  # Capture the first argument
  local cmd=$1

  # Handle different git commands
  case $cmd in
    add)
      echo "add $2"  # assuming $2 captures the next argument like 'docs' or 'static'
      ;;
    diff-index)
      # This mock always indicates that there are changes.
      return 1
      ;;
    commit)
      echo "commit -m \"$3\""  # assuming $3 captures the commit message
      ;;
    push)
      echo "push $2 $3"  # assuming $2 captures 'origin' and $3 captures 'main'
      ;;
    *)
      echo "$@"
      ;;
  esac
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

# Source the script to get the CommitAndPushToTarget function
source ./src/scripts/commit_and_push_to_target.sh

@test "It changes to the TARGET_REPO_DIRECTORY and succeeds" {
  # Mock environment variables
  export TARGET_REPO_DIRECTORY="$WORKING_DIR"
  export FINAL_COMMIT_MESSAGE="Commit message"

  # Run the function
  run CommitAndPushToTarget

  # Validate output
  [[ "$output" =~ Changing\ directory\ to\ $WORKING_DIR ]]
  [ "$status" -eq 0 ]
}


@test "It runs git add for docs and static and succeeds" {
  # Mock environment variables
  export TARGET_REPO_DIRECTORY=$WORKING_DIR
  export FINAL_COMMIT_MESSAGE="Commit message"

  # Run the function
  run CommitAndPushToTarget

  # Validate output
  [[ "$output" =~ add\ docs ]]
  [[ "$output" =~ add\ static ]]
}

@test "It runs git commit with the correct message and succeeds" {
  # Mock environment variables
  export TARGET_REPO_DIRECTORY=$WORKING_DIR
  export FINAL_COMMIT_MESSAGE="Commit message"

  # Run the function
  run CommitAndPushToTarget

  # Validate output
  echo "$output" | grep -qE "commit -m \"Commit message\""
}

@test "It runs git push to the main branch and succeeds" {
  # Mock environment variables
  export TARGET_REPO_DIRECTORY=$WORKING_DIR
  export FINAL_COMMIT_MESSAGE="Commit message"

  # Run the function
  run CommitAndPushToTarget

  # Validate output
  [[ "$output" =~ push\ origin\ main ]]
}
