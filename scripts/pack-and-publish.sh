#! /bin/bash

PackAndPublish() {
  project_root="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
  source_path="$project_root/src"
  output_path="$project_root/orb.yml"
   rm -f "$output_path"
   circleci orb pack "$source_path" > "$output_path"
   circleci orb validate "$output_path" || { echo "Orb validation failed"; exit 1; }
   circleci orb publish "$output_path" "infinitered/publish-docs@dev:alpha"
}

PackAndPublish
