#!/usr/bin/env bash

set -Eeuo pipefail

generator_path="${1:-.trophy-generator}"
api_client="${generator_path}/src/github_api_client.ts"
user_info="${generator_path}/src/user_info.ts"

sed -i.bak \
  's/repositories(first: 100, ownerAffiliations:/repositories(first: 100, privacy: PUBLIC, ownerAffiliations:/' \
  "$api_client"
sed -i.bak \
  's/userRepository.repositories.nodes.reduce(/userRepository.repositories.nodes.filter((node) => node != null).reduce(/' \
  "$user_info"
sed -i.bak \
  's/userRepository.repositories.nodes.forEach(/userRepository.repositories.nodes.filter((node) => node != null).forEach(/' \
  "$user_info"
rm -f "${api_client}.bak" "${user_info}.bak"

grep --quiet 'repositories(first: 100, privacy: PUBLIC,' "$api_client"
[[ "$(grep --count 'filter((node) => node != null)' "$user_info")" -eq 2 ]]
