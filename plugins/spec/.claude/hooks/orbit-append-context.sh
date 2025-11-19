#!/usr/bin/env bash

# Append workflow context to prompts during active sessions.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
if [[ -z "${CONTEXT// }" ]]; then
  exit 0
fi

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
if [[ "${PROMPT}" == /orbit* || "${PROMPT}" == /spec-track* || "${PROMPT}" == */orbit* ]]; then
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

feature="$(frontmatter_value "feature")"
phase="$(frontmatter_value "phase")"
next_action=""
if [[ -f "${NEXT_STEP_FILE}" ]]; then
  next_action="$(python3 - "${NEXT_STEP_FILE}" <<'PY'
import json, sys, pathlib
path = pathlib.Path(sys.argv[1])
try:
    data = json.loads(path.read_text(encoding='utf-8'))
    print(data.get("action",""))
except Exception:
    print("")
PY
)"
fi

context_block=$'\n\n'"[Spec Workflow Context]"$'\n'"Feature: ${feature:-none}"$'\n'"Phase: ${phase:-initialize}"$'\n'"Next: ${next_action:-initialize}"

export PROMPT
export CONTEXT_BLOCK="${context_block}"

python3 - <<'PY'
import json, os
prompt = os.environ.get("PROMPT")
context = os.environ.get("CONTEXT_BLOCK")
print(json.dumps({"prompt": f"{prompt}{context}"}))
PY
