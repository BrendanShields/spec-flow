#!/usr/bin/env bash

# Notify user of recommended next step when Claude is idle.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"

if [[ ! -f "${NEXT_STEP_FILE}" ]]; then
  exit 0
fi

payload="$(python3 - "${NEXT_STEP_FILE}" <<'PY'
import json, sys, pathlib
path = pathlib.Path(sys.argv[1])
try:
    data = json.loads(path.read_text(encoding='utf-8'))
except Exception:
    data = {}
print(json.dumps(data))
PY
)"

write_hook_output "orbit-notify-next-step" "Next step suggestion ready" "${payload}"
