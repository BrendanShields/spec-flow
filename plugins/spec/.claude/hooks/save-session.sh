#!/usr/bin/env bash

# Persist lightweight session metadata on Stop/SessionEnd.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
ensure_directories

changed_files="$(cd "${PROJECT_DIR}" && git status --short 2>/dev/null || true)"

python3 - "${SESSION_FILE}" "${changed_files}" <<'PY'
import json, sys, time, pathlib
path = pathlib.Path(sys.argv[1])
changed = [line.strip() for line in sys.argv[2].splitlines() if line.strip()]
data = {
    "feature": "",
    "phase": "",
    "changed_files": changed,
    "last_updated": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
}
state_path = pathlib.Path(path.parent / "state" / "current-session.md")
if state_path.exists():
    lines = state_path.read_text(encoding='utf-8').splitlines()
    if lines and lines[0].strip() == '---':
        for line in lines[1:]:
            if line.strip() == '---':
                break
            if ':' not in line:
                continue
            key, value = line.split(':', 1)
            data[key.strip()] = value.strip()
path.write_text(json.dumps(data, indent=2), encoding='utf-8')
print(json.dumps(data))
PY

write_hook_output "session-saved" "Session snapshot written" "{\"session_file\":\"${SESSION_FILE}\"}"
