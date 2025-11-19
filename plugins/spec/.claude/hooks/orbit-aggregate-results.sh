#!/usr/bin/env bash

# Combine subagent outputs for quick reference.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
if [[ -z "${CONTEXT// }" ]]; then
  exit 0
fi

export CONTEXT_JSON="${CONTEXT}"
read -r AGENT OUTPUT STATUS < <(python3 <<'PY'
import json, os
data = json.loads(os.environ.get("CONTEXT_JSON") or "{}")
print(data.get("agent") or "")
print((data.get("output") or "")[:2000])
print(data.get("status") or "completed")
PY
)

ensure_directories
{
  echo "## $(timestamp) - Subagent: ${AGENT:-unknown} (${STATUS})"
  if [[ -n "${OUTPUT}" ]]; then
    echo "${OUTPUT}"
  else
    echo "(no output captured)"
  fi
  echo
} >>"${HISTORY_FILE}"

append_log_line "${ACTIVITY_LOG}" "subagent=${AGENT:-unknown} status=${STATUS}"

write_hook_output "orbit-aggregate-results" "Subagent result recorded" "{\"agent\":\"${AGENT}\",\"status\":\"${STATUS}\"}"
