#!/usr/bin/env bash
set -euo pipefail

# Helper functions for Orbit Lifecycle implementation branch.
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SPEC_ROOT="${PROJECT_DIR}/.spec"
MEMORY_DIR="${SPEC_ROOT}/memory"
STATE_DIR="${SPEC_ROOT}/state"
HOOK_LIB="${PROJECT_DIR}/.claude/hooks/lib.sh"

source "$HOOK_LIB" 2>/dev/null || true

task_id="$1"
description="$2"
feature="$3"
test_cmd="${4:-npm test}"

log(){ echo "[orbit:tdd] $1"; }

log "Starting task $task_id – $description"

log "Running tests (expecting red)"
if ! bash -lc "$test_cmd"; then
  log "Red ✅"
else
  log "Warning: test suite passed before implementation"
fi

log "Implementing change (edit files with Read/Edit tools before re-running)"

log "Running tests (expecting green)"
bash -lc "$test_cmd"

if command -v update_task_completion >/dev/null 2>&1; then
  update_task_completion "$task_id: $description" "$feature"
fi

log "Task complete; hooks will update session.json and metrics"
