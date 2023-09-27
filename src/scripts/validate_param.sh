#! /bin/bash

ValidateParam() {
  if [ -z "$PARAM_VALUE" ]; then
    echo "Error: Missing parameter"
    exit 1
  fi
}

ValidateParam
