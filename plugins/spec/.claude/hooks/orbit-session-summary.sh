#!/usr/bin/env bash

# Produce a compact session summary on Stop/SessionEnd.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
ensure_directories

# Snapshot current session metadata (inline former save-session logic)
python3 - "${SESSION_FILE}" "${PROJECT_DIR}" <<'PY'
import json, sys, time, pathlib, subprocess
session_path = pathlib.Path(sys.argv[1])
project = pathlib.Path(sys.argv[2])
state_path = project / ".spec" / "state" / "current-session.md"
try:
    changed = subprocess.check_output(["git", "status", "--short"], cwd=project).decode().splitlines()
except Exception:
    changed = []
data = {
    "feature": "",
    "phase": "",
    "changed_files": [line.strip() for line in changed if line.strip()],
    "last_updated": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
}
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
session_path.write_text(json.dumps(data, indent=2), encoding='utf-8')
PY

feature="$(frontmatter_value "feature")"
phase="$(frontmatter_value "phase")"
recent_progress="$(tail -n 5 "${PROGRESS_FILE}" 2>/dev/null || true)"
recent_metrics="$(tail -n 5 "${METRICS_FILE}" 2>/dev/null || true)"

{
  echo "# Orbit Session Summary ($(timestamp))"
  echo
  echo "- Feature: ${feature:-none}"
  echo "- Phase: ${phase:-initialize}"
  echo
  echo "## Recent Progress"
  if [[ -n "${recent_progress}" ]]; then
    echo '```'
    echo "${recent_progress}"
    echo '```'
  else
    echo "_No activity recorded yet._"
  fi
  echo
  echo "## Recent Metrics"
  if [[ -n "${recent_metrics}" ]]; then
    echo '```'
    echo "${recent_metrics}"
    echo '```'
  else
    echo "_No metrics collected._"
  fi
} >"${SUMMARY_FILE}"

write_hook_output "orbit-session-summary" "Session summary saved" "{\"summary_file\":\"${SUMMARY_FILE}\"}"
