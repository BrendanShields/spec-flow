#!/bin/bash
# Specter On-Task-Complete Hook
# Runs when a task is marked complete

set -euo pipefail

# Source state synchronization library
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPECTER_ROOT="$(cd "$HOOK_DIR/../../.." && pwd)"

source "$SPECTER_ROOT/.specter/lib/state-sync.sh"

# Read context from stdin
context=$(cat)

# Extract task information
task_id=$(echo "$context" | jq -r '.taskId // empty')
feature_id=$(echo "$context" | jq -r '.featureId // empty')

if [[ -z "$task_id" ]]; then
  echo "⚠️  No task ID provided in context" >&2
  exit 1
fi

# Mark task complete in session.json
specter_update_state "$SPECTER_ROOT/.specter-state/session.json" \
  "(.taskList[] | select(.id == \"$task_id\") | .status) = \"complete\" |
   (.taskList[] | select(.id == \"$task_id\") | .completedAt) = \"$(date -Iseconds)\""

# Update workflow metrics
specter_update_state "$SPECTER_ROOT/.specter-memory/workflow.json" \
  ".metrics.totalTasksCompleted += 1 |
   .metrics.lastTaskCompleted = \"$task_id\" |
   .metrics.lastTaskCompletedAt = \"$(date -Iseconds)\""

# Get task description for logging
task_desc=$(jq -r ".taskList[] | select(.id == \"$task_id\") | .description // \"Unknown task\"" \
  "$SPECTER_ROOT/.specter-state/session.json" 2>/dev/null || echo "Unknown task")

# Move to CHANGES-COMPLETED
if [[ -f "$SPECTER_ROOT/.specter-memory/CHANGES-COMPLETED.md" ]]; then
  echo "- [$task_id] $task_desc ($(date +%Y-%m-%d))" >> "$SPECTER_ROOT/.specter-memory/CHANGES-COMPLETED.md"
fi

# Recalculate feature progress
total_tasks=$(jq -r '.taskList | length' "$SPECTER_ROOT/.specter-state/session.json" 2>/dev/null || echo "0")
completed_tasks=$(jq -r '[.taskList[] | select(.status == "complete")] | length' \
  "$SPECTER_ROOT/.specter-state/session.json" 2>/dev/null || echo "0")

if [[ "$total_tasks" -gt 0 ]]; then
  progress=$(( completed_tasks * 100 / total_tasks ))

  specter_update_state "$SPECTER_ROOT/.specter-state/session.json" \
    ".activeFeature.progress = $progress |
     .tasks.completed = $completed_tasks |
     .tasks.remaining = ($total_tasks - $completed_tasks)"

  echo "✅ Task $task_id complete ($completed_tasks/$total_tasks = $progress%)"
else
  echo "✅ Task $task_id complete"
fi

exit 0
