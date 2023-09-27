#! /bin/bash

ValidateParam() {
  if [ -z "$PARAM_VALUE" ]; then
    echo "Error: Missing parameter"
    exit 1
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  ValidateParam
fi

