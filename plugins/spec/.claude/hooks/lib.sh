#!/usr/bin/env bash

# Shared helpers for Spec workflow hooks.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SPEC_DIR="${PROJECT_DIR}/.spec"
STATE_DIR="${SPEC_DIR}/state"
MEMORY_DIR="${SPEC_DIR}/memory"
CONFIG_FILE="${SPEC_DIR}/.spec-config.yml"
WORKFLOW_FLAG_FILE="${STATE_DIR}/.workflow-active"
SESSION_JSON="${STATE_DIR}/session.json"
ARCHIVE_DIR="${SPEC_DIR}/archive"
ACTIVITY_LOG="${MEMORY_DIR}/activity-log.md"
HISTORY_FILE="${ARCHIVE_DIR}/history.md"
METRICS_FILE="${MEMORY_DIR}/WORKFLOW-METRICS.log"
TEST_LOG_FILE="${MEMORY_DIR}/TEST-RESULTS.log"
ARCHITECTURE_DIR="${SPEC_DIR}/architecture"

ensure_directories() {
  mkdir -p "${STATE_DIR}" "${MEMORY_DIR}" "${ARCHIVE_DIR}"
  touch "${ACTIVITY_LOG}" "${HISTORY_FILE}" "${METRICS_FILE}" "${TEST_LOG_FILE}"
}

ensure_config() {
  if [[ ! -f "${CONFIG_FILE}" ]]; then
    mkdir -p "$(dirname "${CONFIG_FILE}")"
    cat >"${CONFIG_FILE}" <<'YAML'
version: 3.3.0
paths:
  spec_root: ".spec"
  state: ".spec/state"
  memory: ".spec/memory"
workflow:
  auto_validate: true
  auto_checkpoint: true
  protect:
    - ".env"
    - "package-lock.json"
    - ".git/"
YAML
  fi
}

ensure_session_file() {
  ensure_directories
  if [[ ! -f "${SESSION_JSON}" ]]; then
    cat >"${SESSION_JSON}" <<'JSON'
{
  "current": {
    "id": null,
    "name": null,
    "phase": "initialize",
    "status": "not_initialized",
    "priority": null,
    "progress": []
  },
  "nextAction": {
    "phase": "initialize",
    "hint": "Run /orbit to initialize the workspace"
  },
  "timestamps": {
    "started": null,
    "lastUpdated": null
  }
}
JSON
  fi
}

session_get() {
  local path="$1"
  ensure_session_file
  python3 - "$SESSION_JSON" "$path" <<'PY'
import json, sys, pathlib
session_path = pathlib.Path(sys.argv[1])
path = sys.argv[2].split('.')
data = json.loads(session_path.read_text(encoding='utf-8'))
value = data
for key in path:
    if isinstance(value, dict):
        value = value.get(key)
    else:
        value = None
        break
if value is None:
    print("")
elif isinstance(value, (dict, list)):
    print(json.dumps(value))
else:
    print(value)
PY
}

session_set_value() {
  local path="$1"
  local value="$2"
  ensure_session_file
  python3 - "$SESSION_JSON" "$path" "$value" <<'PY'
import json, sys, pathlib
session_path = pathlib.Path(sys.argv[1])
path = sys.argv[2].split('.')
value = sys.argv[3]
data = json.loads(session_path.read_text(encoding='utf-8'))
cursor = data
for key in path[:-1]:
    cursor = cursor.setdefault(key, {})
cursor[path[-1]] = value
data.setdefault("timestamps", {})["lastUpdated"] = __import__("time").strftime("%Y-%m-%dT%H:%M:%SZ", __import__("time").gmtime())
session_path.write_text(json.dumps(data, indent=2), encoding='utf-8')
PY
}

session_append_progress() {
  local message="$1"
  ensure_session_file
  python3 - "$SESSION_JSON" "$message" <<'PY'
import json, sys, pathlib, time
session_path = pathlib.Path(sys.argv[1])
message = sys.argv[2]
data = json.loads(session_path.read_text(encoding='utf-8'))
progress = data.setdefault("current", {}).setdefault("progress", [])
if message not in progress:
    progress.append(message)
data.setdefault("timestamps", {})["lastUpdated"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
session_path.write_text(json.dumps(data, indent=2), encoding='utf-8')
PY
}

read_context_json() {
  python3 - "$@" <<'PY'
import json, sys
data = sys.stdin.read()
if not data.strip():
    ctx = {}
else:
    ctx = json.loads(data)
if len(sys.argv) == 1:
    print(json.dumps(ctx))
else:
    for key in sys.argv[1:]:
        value = ctx
        for part in key.split('.'):
            if isinstance(value, dict):
                value = value.get(part)
            else:
                value = None
                break
        if value is None:
            print()
        else:
            print(value)
PY
}

write_hook_output() {
  local type="$1"
  local message="$2"
  local details="${3:-}"
  if [[ -n "${details}" ]]; then
    python3 - "$type" "$message" "$details" <<'PY'
import json, sys
t, msg, details_raw = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    details = json.loads(details_raw)
except json.JSONDecodeError:
    details = {"raw": details_raw}
print(json.dumps({"type": t, "message": msg, "details": details}))
PY
  else
    python3 - "$type" "$message" <<'PY'
import json, sys
print(json.dumps({"type": sys.argv[1], "message": sys.argv[2]}))
PY
  fi
}

relative_path() {
  python3 - "$PROJECT_DIR" "$1" <<'PY'
import os, sys
base, path = sys.argv[1], sys.argv[2]
try:
    print(os.path.relpath(path, base))
except ValueError:
    print(path)
PY
}

timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

determine_next_step() {
  local phase="${1:-}"
  local action="create-feature"
  case "${phase}" in
    ""|"none")
      action="initialize"
      ;;
    generate|define|clarify|specification)
      action="move-to-design"
      ;;
    plan|planning|design)
      action="break-down-tasks"
      ;;
    tasks)
      action="start-implementation"
      ;;
    implement|implementation)
      action="validate"
      ;;
    validate|validation)
      action="complete-feature"
      ;;
    complete)
      action="start-new-feature"
      ;;
  esac
  echo "${action}"
}

record_next_step() {
  ensure_session_file
  local current_phase
  current_phase="$(session_get "current.phase")"
  local action
  action="$(determine_next_step "${current_phase}")"
  local target_phase=""
  local hint=""
  case "${action}" in
    initialize)
      target_phase="initialize"
      hint="Initialize Orbit workspace"
      ;;
    create-feature|move-to-design)
      target_phase="specification"
      hint="Define or refine the feature specification"
      ;;
    break-down-tasks|start-implementation)
      if [[ "${action}" == "break-down-tasks" ]]; then
        target_phase="planning"
        hint="Create technical plan and tasks"
      else
        target_phase="implementation"
        hint="Begin implementing defined tasks"
      fi
      ;;
    validate)
      target_phase="validation"
      hint="Run validation/consistency checks"
      ;;
    complete-feature)
      target_phase="complete"
      hint="Wrap up and archive the feature"
      ;;
    *)
      target_phase="${action}"
      hint="Continue Orbit workflow"
      ;;
  esac
  python3 - "$SESSION_JSON" "$target_phase" "$hint" <<'PY'
import json, sys, pathlib, time
session_path = pathlib.Path(sys.argv[1])
next_phase, hint = sys.argv[2], sys.argv[3]
data = json.loads(session_path.read_text(encoding='utf-8'))
data["nextAction"] = {
    "phase": next_phase,
    "hint": hint,
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
}
session_path.write_text(json.dumps(data, indent=2), encoding='utf-8')
print(json.dumps(data["nextAction"]))
PY
}

append_log_line() {
  local file="$1"
  local line="$2"
  mkdir -p "$(dirname "${file}")"
  printf '%s %s\n' "$(timestamp)" "${line}" >>"${file}"
}

update_task_completion() {
  local task_name="$1"
  local feature="${2:-}"
  ensure_directories

  session_append_progress "Task completed: ${task_name}"
  append_log_line "${ACTIVITY_LOG}" "task_completed=${task_name} feature=${feature}"

  record_next_step >/dev/null 2>&1 || true
}

update_phase() {
  local new_phase="$1"
  local feature="${2:-}"
  ensure_directories

  session_set_value "current.phase" "${new_phase}"
  if [[ -n "${feature}" ]]; then
    session_set_value "current.id" "${feature}"
  fi

  # Refresh next-step cache
  record_next_step >/dev/null 2>&1 || true
}

mark_user_story_complete() {
  local user_story="$1"
  local feature="${2:-}"
  ensure_directories

  # Log completion
  append_log_line "${ACTIVITY_LOG}" "user_story_completed=${user_story} feature=${feature}"

  # Refresh next-step cache
  record_next_step >/dev/null 2>&1 || true
}

read_prompt_from_context() {
  python3 <<'PY'
import json, sys
data = sys.stdin.read()
if not data.strip():
    print()
    raise SystemExit
ctx = json.loads(data)
print(ctx.get("prompt",""))
PY
}
