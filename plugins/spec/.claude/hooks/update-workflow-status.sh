#!/usr/bin/env bash

# Track workflow status transitions after skill execution.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
if [[ -z "${CONTEXT// }" ]]; then
  exit 0
fi

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
  *init*|*discover*)
    phase="initialize"
    ;;
  *generate*|*define*|*clarify*)
    phase="specification"
    ;;
  *plan*|*design*)
    phase="planning"
    ;;
  *tasks*)
    phase="tasks"
    ;;
  *implement*)
    phase="implementation"
    ;;
  *validate*|*analyze*)
    phase="validate"
    ;;
  *complete*)
    phase="complete"
    ;;
esac

append_log_line "${PROGRESS_FILE}" "command=${COMMAND:-unknown} phase=${phase}"
echo "$(timestamp)" >"${WORKFLOW_FLAG_FILE}"
record_next_step >/dev/null 2>&1 || true

write_hook_output "workflow-status" "Workflow status updated" "{\"command\":\"${COMMAND}\",\"phase\":\"${phase}\"}"
