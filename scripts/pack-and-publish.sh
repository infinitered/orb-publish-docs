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

  # Generate a random 4-letter suffix with LC_ALL=C specifically for tr
  random_suffix=$(LC_ALL=C tr -dc 'a-z' < /dev/urandom | fold -w 4 | head -n 1)

  # Append the random suffix to version_suffix
  version_suffix="${version_suffix}-${random_suffix}"

  rm -f "$output_path"
  circleci orb pack "$source_path" > "$output_path"
  circleci orb validate "$output_path" || { echo "Orb validation failed"; exit 1; }
  circleci orb publish "$output_path" "infinitered/publish-docs@dev:$version_suffix"
}

PackAndPublish "$@"
