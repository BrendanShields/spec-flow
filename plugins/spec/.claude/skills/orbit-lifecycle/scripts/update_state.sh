#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SPEC_ROOT="${PROJECT_DIR}/.spec"
STATE_DIR="${SPEC_ROOT}/state"
MEMORY_DIR="${SPEC_ROOT}/memory"
HOOK_LIB="${PROJECT_DIR}/.claude/hooks/lib.sh"

phase="${phase:-${1:-}}"
feature="${feature:-${2:-}}"

source "$HOOK_LIB" 2>/dev/null || true

mkdir -p "$STATE_DIR" "$MEMORY_DIR"

if [[ -n "$phase" ]] && command -v update_phase >/dev/null 2>&1; then
  update_phase "$phase" "$feature"
fi

if [[ -f "$MEMORY_DIR/workflow-progress.md" ]]; then
  echo "- $(date -u): Phase $phase for $feature" >> "$MEMORY_DIR/workflow-progress.md"
fi

determine_next_step "$phase" > "$STATE_DIR/next-step.json" 2>/dev/null || true

echo "State updated: phase=${phase:-unknown}"
