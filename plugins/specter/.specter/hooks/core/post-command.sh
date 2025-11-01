#!/bin/bash
# Specter Post-Command Hook
# Runs after every /specter command to update state

set -euo pipefail

# Source state synchronization library
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPECTER_ROOT="$(cd "$HOOK_DIR/../../.." && pwd)"

source "$SPECTER_ROOT/.specter/lib/state-sync.sh"

# Read context from stdin (JSON)
context=$(cat)

# Extract relevant information from context
command=$(echo "$context" | jq -r '.command // "unknown"')
feature_id=$(echo "$context" | jq -r '.activeFeature.id // empty')
phase=$(echo "$context" | jq -r '.activeFeature.phase // empty')
timestamp=$(date -Iseconds)

# Update session.json with current phase and timestamp
if [[ -n "$phase" ]]; then
  specter_update_state "$SPECTER_ROOT/.specter-state/session.json" \
    ".activeFeature.phase = \"$phase\" | .lastUpdated = \"$timestamp\" | .lastCommand = \"$command\""
fi

# Update workflow.json metrics
specter_update_state "$SPECTER_ROOT/.specter-memory/workflow.json" \
  ".lastCommandRun = \"$timestamp\" | .metrics.commandCount += 1"

# Trigger master spec regeneration if feature changed
if echo "$command" | grep -qE "(specify|complete)"; then
  # Feature was created or completed, regenerate master spec
  if [[ -f "$SPECTER_ROOT/.specter/lib/master-spec-gen.sh" ]]; then
    source "$SPECTER_ROOT/.specter/lib/master-spec-gen.sh"
    specter_generate_master_spec 2>/dev/null || true
  fi
fi

echo "✅ State synchronized after $command"
exit 0
