#!/usr/bin/env bash

# Persist a compact session snapshot when the main agent or session stops.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
ensure_directories
ensure_session_file

SESSION_JSON_SNAPSHOT="$(python3 - "${SESSION_JSON}" <<'PY'
import json, sys, pathlib
path = pathlib.Path(sys.argv[1])
print(json.dumps(json.loads(path.read_text(encoding='utf-8'))))
PY
)"
export SESSION_JSON_SNAPSHOT

feature_id="$(python3 - <<'PY'
import json, os
session = json.loads(os.environ.get('SESSION_JSON_SNAPSHOT') or '{}')
print(session.get('current', {}).get('id') or '')
PY
)"

feature_name="$(python3 - <<'PY'
import json, os
session = json.loads(os.environ.get('SESSION_JSON_SNAPSHOT') or '{}')
print(session.get('current', {}).get('name') or '')
PY
)"

phase="$(python3 - <<'PY'
import json, os
session = json.loads(os.environ.get('SESSION_JSON_SNAPSHOT') or '{}')
print(session.get('current', {}).get('phase') or '')
PY
)"

progress_json="$(python3 - <<'PY'
import json, os
session = json.loads(os.environ.get('SESSION_JSON_SNAPSHOT') or '{}')
print(json.dumps(session.get('current', {}).get('progress') or []))
PY
)"
export progress_json

changed_files="$(git -C "${PROJECT_DIR}" status --short 2>/dev/null || true)"
recent_activity="$(tail -n 10 "${ACTIVITY_LOG}" 2>/dev/null || true)"
recent_metrics="$(tail -n 10 "${METRICS_FILE}" 2>/dev/null || true)"

{
  echo "## $(timestamp) Session Snapshot"
  echo "- Feature: ${feature_id:-none}${feature_name:+ (${feature_name})}"
  echo "- Phase: ${phase:-initialize}"
  echo
  echo "### Progress"
  if [[ -n "${progress_json}" && "${progress_json}" != "[]" ]]; then
    python3 - <<'PY'
import json, os
progress = json.loads(os.environ.get('progress_json') or '[]')
for item in progress[-5:]:
    print(f"- {item}")
PY
  else
    echo "_No progress recorded yet._"
  fi
  echo
  echo "### Recent Activity"
  if [[ -n "${recent_activity}" ]]; then
    echo '```'
    echo "${recent_activity}"
    echo '```'
  else
    echo "_Activity log empty._"
  fi
  echo
  echo "### Recent Metrics"
  if [[ -n "${recent_metrics}" ]]; then
    echo '```'
    echo "${recent_metrics}"
    echo '```'
  else
    echo "_No metrics yet._"
  fi
  echo
  if [[ -n "${changed_files}" ]]; then
    echo "### Pending Changes"
    echo '```'
    echo "${changed_files}"
    echo '```'
    echo
  fi
} >>"${HISTORY_FILE}"

write_hook_output "orbit-session-summary" "Session snapshot recorded" "{\"feature\":\"${feature_id:-none}\",\"phase\":\"${phase:-initialize}\"}"
