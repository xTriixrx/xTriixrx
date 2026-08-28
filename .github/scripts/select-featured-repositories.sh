#!/usr/bin/env bash

set -Eeuo pipefail

: "${GH_TOKEN:?GH_TOKEN is required}"
: "${OWNER:?OWNER is required}"
: "${GITHUB_OUTPUT:?GITHUB_OUTPUT is required}"
: "${RUNNER_TEMP:?RUNNER_TEMP is required}"

repositories_file="${RUNNER_TEMP}/repositories.json"
featured_file="${RUNNER_TEMP}/featured.json"

gh api --paginate --slurp \
  "/users/${OWNER}/repos?per_page=100&type=owner&sort=full_name" \
  > "$repositories_file"

jq --arg owner "$OWNER" '
  add
  | map(select(
      (.fork | not)
      and (.archived | not)
      and (.disabled | not)
      and (.name != $owner)
    )) as $repositories
  | ($repositories
      | sort_by([-.stargazers_count, -.forks_count, .name])
      | .[:3]) as $favorites
  | ($favorites + ($repositories
      | map(select(.name as $name
          | ($favorites | map(.name) | index($name) | not)))
      | sort_by(.pushed_at)
      | reverse
      | .[:3]))
' "$repositories_file" > "$featured_file"

if [[ "$(jq length "$featured_file")" -ne 6 ]]; then
  echo 'Six eligible public repositories are required to build the featured cards.' >&2
  exit 1
fi

for position in {1..6}; do
  index=$((position - 1))
  repository="$(jq -r ".[${index}].name" "$featured_file")"
  url="$(jq -r ".[${index}].html_url" "$featured_file")"
  echo "repo_${position}=${repository}" >> "$GITHUB_OUTPUT"
  echo "url_${position}=${url}" >> "$GITHUB_OUTPUT"
done

echo 'Selected featured repositories:'
jq -r '.[] | "- \(.name) (stars: \(.stargazers_count), pushed: \(.pushed_at))"' \
  "$featured_file"

