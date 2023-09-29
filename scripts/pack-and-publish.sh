#! /bin/bash

PackAndPublish() {
  project_root="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
  source_path="$project_root/src"
  output_path="$project_root/orb.yml"

  # Default version suffix
  version_suffix="alpha"

  # Check if an argument is provided
  if [ "$#" -gt 0 ]; then
    version_suffix="$1"
  fi

  rm -f "$output_path"
  circleci orb pack "$source_path" > "$output_path"
  circleci orb validate "$output_path" || { echo "Orb validation failed"; exit 1; }
  circleci orb publish "$output_path" "infinitered/publish-docs@dev:$version_suffix"
}

PackAndPublish "$@"
