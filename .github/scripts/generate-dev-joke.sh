#!/usr/bin/env bash

set -Eeuo pipefail

output_path="${1:-profile/dev-joke.svg}"
temporary_output="${output_path}.tmp"
joke_url='https://readme-jokes.vercel.app/api?theme=tokyonight'

mkdir -p "$(dirname "$output_path")"

cleanup() {
  rm -f "$temporary_output"
}
trap cleanup EXIT

keep_existing_or_fail() {
  local reason="$1"

  echo "Unable to update the dev joke: ${reason}" >&2
  if [[ -s "$output_path" ]] && grep --quiet '<svg' "$output_path"; then
    echo "Keeping the existing ${output_path} asset." >&2
    exit 0
  fi

  echo "No existing ${output_path} fallback is available." >&2
  exit 1
}

if ! curl --fail --silent --show-error \
  --retry 3 --retry-delay 2 \
  "$joke_url" \
  --output "$temporary_output"; then
  keep_existing_or_fail 'the joke endpoint request failed'
fi

if [[ ! -s "$temporary_output" ]] || ! grep --quiet '<svg' "$temporary_output"; then
  keep_existing_or_fail 'the endpoint did not return an SVG document'
fi

if ! perl -0pi -e '
  s{<script\b[^>]*>.*?</script>}{}gis;
  s{<svg\b[^>]*>}{<svg width="845" height="200" viewBox="0 0 845 200" id="qna" fill="none" xmlns="http://www.w3.org/2000/svg">}i;
  s{<div\s+class="container"[^>]*>}{<div class="container" style="width: 100%;">}i;
  s{<div\s+class="text(?:\s+desktop)?"[^>]*>}{<div class="text desktop" style="font-size: 26px; padding: 1rem 1.5rem;">}i;
' "$temporary_output"; then
  keep_existing_or_fail 'the SVG transformation failed'
fi

if ! grep --quiet '<svg width="845" height="200"' "$temporary_output"; then
  keep_existing_or_fail 'the SVG canvas was not resized'
fi
if ! grep --quiet 'class="text desktop" style="font-size: 26px;' "$temporary_output"; then
  keep_existing_or_fail 'the joke text was not resized'
fi
if grep --quiet '<script' "$temporary_output"; then
  keep_existing_or_fail 'the transformed SVG still contains a script element'
fi

mv "$temporary_output" "$output_path"
echo "Updated ${output_path}."
