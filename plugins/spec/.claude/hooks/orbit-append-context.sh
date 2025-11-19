#!/usr/bin/env bash

# Append workflow context to prompts during active sessions.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
if [[ -z "${CONTEXT// }" ]]; then
  exit 0
fi

ensure_session_file

export CONTEXT_JSON="${CONTEXT}"
PROMPT="$(python3 <<'PY'
import json, os
data = json.loads(os.environ.get("CONTEXT_JSON") or "{}")
print(data.get("prompt") or "")
PY
)"
export PROMPT

if [[ -z "${PROMPT}" ]]; then
  exit 0
fi

active=0
if [[ "${PROMPT}" == /orbit* || "${PROMPT}" == /orbit-track* || "${PROMPT}" == */orbit* ]]; then
  active=1
  echo "$(timestamp)" >"${WORKFLOW_FLAG_FILE}"
elif [[ -f "${WORKFLOW_FLAG_FILE}" ]]; then
  if python3 - "${WORKFLOW_FLAG_FILE}" <<'PY'
import os, sys, time
path = sys.argv[1]
try:
    mtime = os.path.getmtime(path)
except OSError:
    raise SystemExit(1)
if time.time() - mtime < 3600:
    raise SystemExit(0)
raise SystemExit(1)
PY
  then
    active=1
  fi
fi

if [[ "${active}" -eq 0 ]]; then
  exit 0
fi

feature="$(session_get "current.id")"
phase="$(session_get "current.phase")"
next_phase="$(session_get "nextAction.phase")"
next_hint="$(session_get "nextAction.hint")"

context_block=$'\n\n'"[Orbit Workflow Context]"$'\n'"Feature: ${feature:-none}"$'\n'"Phase: ${phase:-initialize}"$'\n'"Next: ${next_phase:-initialize} (${next_hint:-continue workflow})"

export PROMPT
export CONTEXT_BLOCK="${context_block}"

python3 - <<'PY'
import json, os
prompt = os.environ.get("PROMPT")
context = os.environ.get("CONTEXT_BLOCK")
print(json.dumps({"prompt": f"{prompt}{context}"}))
PY
