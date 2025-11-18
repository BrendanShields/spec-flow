#!/usr/bin/env bash

# Execute project tests after significant edits.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
if [[ -z "${CONTEXT// }" ]]; then
  exit 0
fi

if [[ "${SPEC_SKIP_AUTO_TESTS:-0}" = "1" ]]; then
  exit 0
fi

export CONTEXT_JSON="${CONTEXT}"
read -r TOOL COMMAND < <(python3 <<'PY'
import json, os
data = json.loads(os.environ.get("CONTEXT_JSON") or "{}")
print(data.get("tool") or "")
print(data.get("command") or "")
PY
)

if [[ "${TOOL}" != "Write" && "${TOOL}" != "Edit" ]]; then
  exit 0
fi

if [[ ! -f "${PROJECT_DIR}/package.json" ]]; then
  exit 0
fi

has_test="$(python3 - "${PROJECT_DIR}/package.json" <<'PY'
import json, pathlib, sys
pkg = pathlib.Path(sys.argv[1])
try:
    data = json.loads(pkg.read_text(encoding='utf-8'))
except Exception:
    print("")
    raise SystemExit
print("yes" if "test" in (data.get("scripts") or {}) else "")
PY
)"

if [[ "${has_test}" != "yes" ]]; then
  exit 0
fi

cd "${PROJECT_DIR}"
if npm run --silent test -- --runInBand >/dev/null 2>&1; then
  append_log_line "${TEST_LOG_FILE}" "PASS command=${COMMAND:-unknown}"
  write_hook_output "auto-test" "Automated tests passed" "{\"command\":\"${COMMAND}\"}"
else
  append_log_line "${TEST_LOG_FILE}" "FAIL command=${COMMAND:-unknown}"
  write_hook_output "auto-test" "Automated tests failed" "{\"command\":\"${COMMAND}\",\"details\":\"See ${TEST_LOG_FILE}\"}"
fi
