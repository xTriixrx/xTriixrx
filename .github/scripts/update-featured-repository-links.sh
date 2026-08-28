#!/usr/bin/env bash

set -Eeuo pipefail

readme_path="${1:-README.md}"

for position in {1..6}; do
  variable_name="REPO_${position}_URL"
  repository_url="${!variable_name:?${variable_name} is required}"
  image_path="./profile/featured-repo-${position}.svg"

  sed -E -i.bak \
    "s|<a href=\"[^\"]*\"><img width=\"49.5%\" src=\"${image_path}\"|<a href=\"${repository_url}\"><img width=\"49.5%\" src=\"${image_path}\"|" \
    "$readme_path"
  rm -f "${readme_path}.bak"

  grep --quiet "<a href=\"${repository_url}\"><img width=\"49.5%\" src=\"${image_path}\"" \
    "$readme_path"
done
