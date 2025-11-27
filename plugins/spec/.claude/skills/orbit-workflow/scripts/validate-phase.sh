#!/bin/bash
# validate-phase.sh - Check prerequisites before phase transition
# Usage: validate-phase.sh <feature-path> <target-phase>
# Returns: 0 if valid, 1 if missing prerequisites
# Output: JSON with validation result

set -euo pipefail

FEATURE="${1:-}"
TARGET="${2:-}"

if [[ -z "$FEATURE" || -z "$TARGET" ]]; then
  echo '{"valid":false,"error":"Usage: validate-phase.sh <feature-path> <target-phase>"}'
  exit 1
fi

case "$TARGET" in
  specification|initialize)
    # No prerequisites for starting
    echo '{"valid":true,"phase":"specification"}'
    ;;

  clarification)
    if [[ ! -f "$FEATURE/spec.md" ]]; then
      echo '{"valid":false,"missing":"spec.md","suggestion":"Create specification first","phase":"clarification"}'
      exit 1
    fi
    echo '{"valid":true,"phase":"clarification"}'
    ;;

  planning)
    if [[ ! -f "$FEATURE/spec.md" ]]; then
      echo '{"valid":false,"missing":"spec.md","suggestion":"Create specification first","phase":"planning"}'
      exit 1
    fi
    # Check for unresolved [CLARIFY] tags
    if grep -q '\[CLARIFY\]' "$FEATURE/spec.md" 2>/dev/null; then
      echo '{"valid":false,"missing":"clarifications","suggestion":"Resolve [CLARIFY] tags in spec.md first","phase":"planning"}'
      exit 1
    fi
    echo '{"valid":true,"phase":"planning"}'
    ;;

  implementation)
    if [[ ! -f "$FEATURE/spec.md" ]]; then
      echo '{"valid":false,"missing":"spec.md","suggestion":"Create specification first","phase":"implementation"}'
      exit 1
    fi
    if [[ ! -f "$FEATURE/plan.md" ]]; then
      echo '{"valid":false,"missing":"plan.md","suggestion":"Create plan first","phase":"implementation"}'
      exit 1
    fi
    if [[ ! -f "$FEATURE/tasks.md" ]]; then
      echo '{"valid":false,"missing":"tasks.md","suggestion":"Create tasks first","phase":"implementation"}'
      exit 1
    fi
    echo '{"valid":true,"phase":"implementation"}'
    ;;

  complete)
    if [[ ! -f "$FEATURE/tasks.md" ]]; then
      echo '{"valid":false,"missing":"tasks.md","suggestion":"No tasks to complete","phase":"complete"}'
      exit 1
    fi
    # Check for uncompleted tasks
    if grep -q '^\s*- \[ \]' "$FEATURE/tasks.md" 2>/dev/null; then
      REMAINING=$(grep -c '^\s*- \[ \]' "$FEATURE/tasks.md" || echo "0")
      echo "{\"valid\":false,\"missing\":\"completed_tasks\",\"remaining\":$REMAINING,\"suggestion\":\"Complete all tasks first\",\"phase\":\"complete\"}"
      exit 1
    fi
    echo '{"valid":true,"phase":"complete"}'
    ;;

  *)
    echo "{\"valid\":false,\"error\":\"Unknown phase: $TARGET\",\"valid_phases\":[\"specification\",\"clarification\",\"planning\",\"implementation\",\"complete\"]}"
    exit 1
    ;;
esac
