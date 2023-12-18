#! /bin/bash

ValidateParam() {
  if [ -z "$PARAM_VALUE" ]; then
    echo "Error: Missing parameter"
    exit 1
  fi
  echo "Param is set"
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  ValidateParam
fi

