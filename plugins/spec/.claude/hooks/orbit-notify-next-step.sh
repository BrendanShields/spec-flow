#!/usr/bin/env bash

# Notify user of recommended next step when Claude is idle.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
ensure_session_file

payload="$(python3 - "${SESSION_JSON}" <<'PY'
import json, sys, pathlib
path = pathlib.Path(sys.argv[1])
try:
    data = json.loads(path.read_text(encoding='utf-8'))
except Exception:
    data = {}
next_action = data.get("nextAction") or {}
current = data.get("current") or {}
message = {
    "feature": current.get("id"),
    "phase": current.get("phase"),
    "next": next_action
}
print(json.dumps(message))
PY
)"

write_hook_output "orbit-notify-next-step" "Next step suggestion ready" "${payload}"
