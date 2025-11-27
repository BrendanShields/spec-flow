#!/bin/bash
# update-status.sh - Update frontmatter status and timestamp
# Usage: update-status.sh <spec-file> <new-status> [tasks-done] [tasks-total]
# Updates: status, updated timestamp, optionally progress

set -euo pipefail

SPEC="${1:-}"
STATUS="${2:-}"
TASKS_DONE="${3:-}"
TASKS_TOTAL="${4:-}"

if [[ -z "$SPEC" || -z "$STATUS" ]]; then
  echo "Usage: update-status.sh <spec-file> <new-status> [tasks-done] [tasks-total]"
  exit 1
fi

if [[ ! -f "$SPEC" ]]; then
  echo "Error: File not found: $SPEC"
  exit 1
fi

# ISO 8601 timestamp in UTC
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Update status line
if grep -q '^status:' "$SPEC"; then
  sed -i '' "s/^status:.*/status: $STATUS/" "$SPEC"
else
  echo "Warning: No status field found in $SPEC"
fi

# Update timestamp
if grep -q '^updated:' "$SPEC"; then
  sed -i '' "s/^updated:.*/updated: $TIMESTAMP/" "$SPEC"
else
  echo "Warning: No updated field found in $SPEC"
fi

# Update progress if provided
if [[ -n "$TASKS_DONE" && -n "$TASKS_TOTAL" ]]; then
  if grep -q '^\s*tasks_done:' "$SPEC"; then
    sed -i '' "s/^\(\s*\)tasks_done:.*/\1tasks_done: $TASKS_DONE/" "$SPEC"
  fi
  if grep -q '^\s*tasks_total:' "$SPEC"; then
    sed -i '' "s/^\(\s*\)tasks_total:.*/\1tasks_total: $TASKS_TOTAL/" "$SPEC"
  fi
fi

echo "{\"updated\":true,\"status\":\"$STATUS\",\"timestamp\":\"$TIMESTAMP\"}"
