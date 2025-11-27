#!/bin/bash
# log-activity.sh - Append timestamped activity entry to metrics
# Usage: log-activity.sh <metrics-file> <event>
# Appends: | TIMESTAMP | EVENT | to the Activity table

set -euo pipefail

METRICS="${1:-}"
EVENT="${2:-}"

if [[ -z "$METRICS" || -z "$EVENT" ]]; then
  echo "Usage: log-activity.sh <metrics-file> <event>"
  exit 1
fi

# ISO 8601 timestamp in UTC
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Create metrics file if it doesn't exist
if [[ ! -f "$METRICS" ]]; then
  cat > "$METRICS" << 'EOF'
# Metrics

## Progress

| Phase | Status | Updated |
|-------|--------|---------|
| Specification | pending | |
| Clarification | pending | |
| Planning | pending | |
| Implementation | 0/0 | |

## Activity

| Timestamp | Event |
|-----------|-------|
EOF
fi

# Append activity entry
echo "| $TIMESTAMP | $EVENT |" >> "$METRICS"

echo "{\"logged\":true,\"timestamp\":\"$TIMESTAMP\",\"event\":\"$EVENT\"}"
