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
  echo "## $(timestamp) - ${AGENT:-unknown} (${STATUS})"
  echo "${OUTPUT}"
  echo
} >>"${SUBAGENT_SUMMARY_FILE}"

write_hook_output "aggregate-results" "Subagent result recorded" "{\"agent\":\"${AGENT}\",\"status\":\"${STATUS}\"}"
