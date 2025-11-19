#!/usr/bin/env bash

# Restore last session metadata for onboarding messages.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
ensure_directories

if [[ -f "${SESSION_FILE}" ]]; then
  DETAILS="$(python3 - "${SESSION_FILE}" <<'PY'
import json, sys, datetime, pathlib
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text(encoding='utf-8'))
last = data.get("last_updated")
feature = data.get("feature") or "none"
phase = data.get("phase") or "initialize"
def human_delta(value: str) -> str:
    try:
        dt = datetime.datetime.fromisoformat(value.replace('Z','+00:00'))
        delta = datetime.datetime.utcnow() - dt.replace(tzinfo=None)
        hours = int(delta.total_seconds()//3600)
        minutes = int((delta.total_seconds()%3600)//60)
        if hours > 0:
            return f"{hours}h {minutes}m ago"
        return f"{minutes}m ago"
    except Exception:
        return "recently"
message = f"Feature {feature} was last updated {human_delta(last)} (phase: {phase})."
print(json.dumps({
    "feature": feature,
    "phase": phase,
    "last_updated": last,
    "message": message
}))
PY
)"
  write_hook_output "orbit-restore-session" "Session restored" "${DETAILS}"
else
  write_hook_output "orbit-restore-session" "No previous session to restore" "{\"feature\":\"none\"}"
fi
