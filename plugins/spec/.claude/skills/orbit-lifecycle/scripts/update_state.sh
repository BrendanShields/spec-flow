#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
HOOK_LIB="${PROJECT_DIR}/.claude/hooks/lib.sh"

phase="${phase:-${1:-}}"
feature="${feature:-${2:-}}"
status_note="${status_note:-}" 

if [[ -f "${HOOK_LIB}" ]]; then
  # shellcheck source=/dev/null
  source "${HOOK_LIB}"
else
  echo "Orbit hook library missing; cannot update state" >&2
  exit 1
fi

ensure_session_file

if [[ -n "${phase}" ]]; then
  session_set_value "current.phase" "${phase}"
fi

if [[ -n "${feature}" ]]; then
  session_set_value "current.id" "${feature}"
fi

if [[ -n "${status_note}" ]]; then
  session_append_progress "${status_note}"
fi

record_next_step >/dev/null 2>&1 || true

append_log_line "${ACTIVITY_LOG}" "manual_state_update phase=${phase:-n/a} feature=${feature:-n/a}"

echo "Session updated → phase=${phase:-unchanged} feature=${feature:-unchanged}"
