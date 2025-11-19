#!/usr/bin/env bash

# Track workflow status transitions after skill execution.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
if [[ -z "${CONTEXT// }" ]]; then
  exit 0
fi

ensure_session_file

export CONTEXT_JSON="${CONTEXT}"
read -r COMMAND TOOL OUTPUT < <(python3 <<'PY'
import json, os
data = json.loads(os.environ.get("CONTEXT_JSON") or "{}")
print(data.get("command") or "")
print(data.get("tool") or "")
print((data.get("output") or "")[:2000])
PY
)

phase="in-progress"
case "${COMMAND}" in
  *init*|*discover*) phase="initialize" ;;
  *generate*|*define*|*clarify*) phase="specification" ;;
  *plan*|*design*) phase="planning" ;;
  *tasks*) phase="tasks" ;;
  *implement*) phase="implementation" ;;
  *validate*|*analyze*) phase="validation" ;;
  *complete*) phase="complete" ;;
  *) phase="${phase}" ;;
esac

session_set_value "current.phase" "${phase}"
append_log_line "${ACTIVITY_LOG}" "phase_transition=${phase} command=${COMMAND:-unknown}"
record_next_step >/dev/null 2>&1 || true

next_phase="$(session_get "nextAction.phase")"
next_hint="$(session_get "nextAction.hint")"

write_hook_output "orbit-update-status" "Workflow status updated" "{\"command\":\"${COMMAND}\",\"phase\":\"${phase}\",\"next\":{\"phase\":\"${next_phase}\",\"hint\":\"${next_hint}\"}}"
