#!/usr/bin/env bash

# Shared helpers for Spec workflow hooks.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SPEC_DIR="${PROJECT_DIR}/.spec"
STATE_DIR="${SPEC_DIR}/state"
MEMORY_DIR="${SPEC_DIR}/memory"
CONFIG_FILE="${SPEC_DIR}/.spec-config.yml"
SESSION_FILE="${SPEC_DIR}/.session.json"
NEXT_STEP_FILE="${STATE_DIR}/next-step.json"
WORKFLOW_FLAG_FILE="${STATE_DIR}/.workflow-active"
SUMMARY_FILE="${MEMORY_DIR}/session-summary.md"
SUBAGENT_SUMMARY_FILE="${MEMORY_DIR}/subagent-summary.md"
METRICS_FILE="${MEMORY_DIR}/WORKFLOW-METRICS.log"
PROGRESS_FILE="${MEMORY_DIR}/workflow-progress.md"
TEST_LOG_FILE="${MEMORY_DIR}/TEST-RESULTS.log"
ARCHITECTURE_DIR="${SPEC_DIR}/architecture"

ensure_directories() {
  mkdir -p "${STATE_DIR}" "${MEMORY_DIR}"
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

frontmatter_value() {
  local key="$1"
  local file="${2:-${STATE_DIR}/current-session.md}"
  python3 - "$key" "$file" <<'PY'
import sys, pathlib
key, path = sys.argv[1], pathlib.Path(sys.argv[2])
if not path.exists():
    print()
    raise SystemExit
lines = path.read_text(encoding='utf-8').splitlines()
if not lines or lines[0].strip() != '---':
    print()
    raise SystemExit
for line in lines[1:]:
    if line.strip() == '---':
        break
    if ':' not in line:
        continue
    k, v = line.split(':', 1)
    if k.strip() == key:
        print(v.strip())
        break
else:
    print()
PY
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
  ensure_directories
  local phase
  phase="$(frontmatter_value "phase" "${STATE_DIR}/current-session.md")"
  local feature
  feature="$(frontmatter_value "feature" "${STATE_DIR}/current-session.md")"
  local action
  action="$(determine_next_step "${phase}")"
  python3 - "$NEXT_STEP_FILE" "$action" "$phase" "$feature" <<'PY'
import json, sys, pathlib, time
path, action, phase, feature = sys.argv[1:]
data = {
    "action": action,
    "phase": phase or "",
    "feature": feature or "",
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
}
pathlib.Path(path).write_text(json.dumps(data, indent=2), encoding='utf-8')
print(json.dumps(data))
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

  # Log to workflow progress
  append_log_line "${PROGRESS_FILE}" "task_completed=${task_name} feature=${feature}"

  # Refresh next-step cache
  record_next_step >/dev/null 2>&1 || true
}

update_phase() {
  local new_phase="$1"
  local feature="${2:-}"
  ensure_directories

  # Update current-session.md frontmatter
  python3 - "${STATE_DIR}/current-session.md" "$new_phase" "$feature" <<'PY'
import sys, pathlib, time
session_file, new_phase, feature = sys.argv[1], sys.argv[2], sys.argv[3]
path = pathlib.Path(session_file)

if not path.exists():
    print(f"Error: {session_file} does not exist", file=sys.stderr)
    sys.exit(1)

lines = path.read_text(encoding='utf-8').splitlines()
new_lines = []
in_frontmatter = False
frontmatter_ended = False

for i, line in enumerate(lines):
    if i == 0 and line.strip() == '---':
        in_frontmatter = True
        new_lines.append(line)
    elif in_frontmatter and line.strip() == '---':
        in_frontmatter = False
        frontmatter_ended = True
        new_lines.append(line)
    elif in_frontmatter:
        if line.startswith('phase:'):
            new_lines.append(f'phase: {new_phase}')
        elif line.startswith('last_updated:'):
            new_lines.append(f"last_updated: '{time.strftime('%Y-%m-%d')}'")
        elif line.startswith('feature:') and feature:
            new_lines.append(f'feature: {feature}')
        else:
            new_lines.append(line)
    else:
        new_lines.append(line)

path.write_text('\n'.join(new_lines) + '\n', encoding='utf-8')
print(f"✓ Updated phase to: {new_phase}")
PY

  # Log to workflow progress
  append_log_line "${PROGRESS_FILE}" "phase_transition=${new_phase} feature=${feature}"

  # Refresh next-step cache
  record_next_step >/dev/null 2>&1 || true
}

mark_user_story_complete() {
  local user_story="$1"
  local feature="${2:-}"
  ensure_directories

  # Log completion
  append_log_line "${PROGRESS_FILE}" "user_story_completed=${user_story} feature=${feature}"

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
