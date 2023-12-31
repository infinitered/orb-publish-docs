#! /bin/bash

SetGitUser() {
# Configure Git username and email
echo "Configuring Git username and email: $GIT_USERNAME -- $GIT_EMAIL"
git config --global user.name "$GIT_USERNAME" || { echo "Git username configuration failed"; exit 1; }
git config --global user.email "$GIT_EMAIL" || { echo "Git email configuration failed"; exit 1; }
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  SetGitUser
fi

