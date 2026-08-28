#!/usr/bin/env bash

set -Eeuo pipefail

cards_directory="${1:-profile}"
expected_width=400
expected_height=150

for position in {1..6}; do
  card="${cards_directory}/featured-repo-${position}.svg"
  test -s "$card"

  perl -0pi.bak -e \
    's/width="\d+"\s+height="\d+"\s+viewBox="0 0 \d+ \d+"/width="400"\n        height="150"\n        viewBox="0 0 400 150"/' \
    "$card"
  rm -f "${card}.bak"

  grep --quiet "width=\"${expected_width}\"" "$card"
  grep --quiet "height=\"${expected_height}\"" "$card"
  grep --quiet "viewBox=\"0 0 ${expected_width} ${expected_height}\"" "$card"
done

