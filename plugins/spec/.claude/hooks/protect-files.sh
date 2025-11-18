#!/usr/bin/env bash

# Guardrails preventing edits to sensitive files.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
if [[ -z "${CONTEXT// }" ]]; then
  exit 0
fi

export CONTEXT_JSON="${CONTEXT}"
read -r FILE_PATH TOOL < <(python3 <<'PY'
import json, os
data = json.loads(os.environ.get("CONTEXT_JSON") or "{}")
print(data.get("file_path") or "")
print(data.get("tool") or "")
PY
)

if [[ -z "${FILE_PATH}" || ( "${TOOL}" != "Write" && "${TOOL}" != "Edit" ) ]]; then
  exit 0
fi

patterns=(".env" "package-lock.json" ".git/")
for pattern in "${patterns[@]}"; do
  if [[ "${FILE_PATH}" == *"${pattern}"* ]]; then
    write_hook_output "protect-files" "Blocked edit to protected path" "{\"file\":\"${FILE_PATH}\",\"pattern\":\"${pattern}\"}"
    exit 2
  fi
done
