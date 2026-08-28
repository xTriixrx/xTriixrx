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

curl --fail --silent --show-error \
  --retry 3 --retry-delay 2 \
  "$joke_url" \
  --output "$temporary_output"

perl -0pi -e '
  s{<script>.*?</script>}{}s;
  s{<svg class="" onload="myfunc\(\)" id="qna" fill="none"}{<svg width="845" height="200" viewBox="0 0 845 200" id="qna" fill="none"};
  s{<div class="text">}{<div class="text desktop">};
  s{\.desktop\s*\{\s*font-size:\s*18px;\s*\}}{.desktop {\n            font-size: 26px;\n          }};
  s{padding:\s*0\.5rem;}{padding: 1rem 1.5rem;};
' "$temporary_output"

test -s "$temporary_output"
grep --quiet '<svg width="845" height="200"' "$temporary_output"
grep --quiet 'font-size: 26px' "$temporary_output"
grep --quiet 'class="text desktop"' "$temporary_output"
if grep --quiet '<script>' "$temporary_output"; then
  echo 'The generated joke SVG still contains a script element.' >&2
  exit 1
fi

mv "$temporary_output" "$output_path"

