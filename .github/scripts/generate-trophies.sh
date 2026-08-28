#!/usr/bin/env bash

set -Eeuo pipefail

: "${GITHUB_TOKEN:?The TROPHY_TOKEN repository secret is required}"

generator_path="${1:-.trophy-generator}"
output_path="${2:-github-trophies.svg}"
temporary_output="${output_path}.tmp"
trophy_url='http://127.0.0.1:8080/?username=xTriixrx&theme=tokyonight&column=4&no-bg=true&no-frame=true&rank=SECRET,SSS,SS,S,AAA,AA,A,B'

echo "/${generator_path}/" >> .git/info/exclude
(
  cd "$generator_path"
  deno run --no-lock --allow-net --allow-read --allow-env debug.ts
) &
server_pid=$!

cleanup() {
  kill "$server_pid" 2>/dev/null || true
  wait "$server_pid" 2>/dev/null || true
  rm -f "$temporary_output"
}
trap cleanup EXIT

for attempt in {1..10}; do
  if curl --fail --silent --show-error "$trophy_url" --output "$temporary_output"; then
    break
  fi
  echo "Trophy server request ${attempt} of 10 failed; retrying..." >&2
  sleep 1
done

test -s "$temporary_output"
grep --quiet '<svg' "$temporary_output"
grep --quiet '>MultiLanguage<' "$temporary_output"
mv "$temporary_output" "$output_path"
