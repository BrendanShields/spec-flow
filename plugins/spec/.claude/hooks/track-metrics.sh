#!/usr/bin/env bash

# Lightweight metric tracking per file change.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
if [[ -z "${CONTEXT// }" ]]; then
  exit 0
fi

export CONTEXT_JSON="${CONTEXT}"
read -r FILE_PATH TOOL COMMAND AGENT < <(python3 <<'PY'
import json, os
data = json.loads(os.environ.get("CONTEXT_JSON") or "{}")
print(data.get("file_path") or "")
print(data.get("tool") or "")
print(data.get("command") or "")
print(data.get("agent") or "")
PY
)

if [[ -z "${FILE_PATH}" || ( "${TOOL}" != "Write" && "${TOOL}" != "Edit" ) ]]; then
  exit 0
fi

lines=0
if [[ -f "${FILE_PATH}" ]]; then
  lines="$(wc -l <"${FILE_PATH}" 2>/dev/null || echo 0)"
fi

append_log_line "${METRICS_FILE}" "tool=${TOOL} command=${COMMAND:-unknown} agent=${AGENT:-main} file=$(relative_path "${FILE_PATH}") lines=${lines}"

write_hook_output "track-metrics" "Metrics updated for ${TOOL}" "{\"file\":\"$(relative_path "${FILE_PATH}")\",\"lines\":${lines}}"
