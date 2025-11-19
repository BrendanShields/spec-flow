#!/usr/bin/env bash

# Restore last session metadata for onboarding messages.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
ensure_directories
ensure_session_file

DETAILS="$(python3 - "${SESSION_JSON}" <<'PY'
import json, sys, datetime, pathlib
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text(encoding='utf-8'))
current = data.get("current") or {}
last = (data.get("timestamps") or {}).get("lastUpdated")
feature = current.get("id") or "none"
phase = current.get("phase") or "initialize"
name = current.get("name") or ""
next_action = data.get("nextAction") or {}

def human_delta(value: str) -> str:
    if not value:
        return "recently"
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

message = f"Feature {feature or 'none'}"
if name:
    message += f" ({name})"
message += f" was last updated {human_delta(last)} (phase: {phase})."

print(json.dumps({
    "feature": feature,
    "name": name,
    "phase": phase,
    "last_updated": last,
    "next": next_action,
    "message": message
}))
PY
)"

write_hook_output "orbit-restore-session" "Session restored" "${DETAILS}"
