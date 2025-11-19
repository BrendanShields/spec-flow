#!/usr/bin/env bash
set -euo pipefail
plan_file="$1"
shift
for section in "$@"; do
  printf '\n## %s\n\n- TODO\n' "$section" >> "$plan_file"
  echo "Added section $section"
done
