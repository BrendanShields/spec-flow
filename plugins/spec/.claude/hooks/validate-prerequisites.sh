#!/usr/bin/env bash

# Verify required tooling before skill execution.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
ensure_directories

declare -a missing

if ! command -v git >/dev/null 2>&1; then
  missing+=("git")
fi

if [[ -f "${PROJECT_DIR}/package.json" && ! -d "${PROJECT_DIR}/node_modules" ]]; then
  missing+=("node_modules")
fi

if [[ "${#missing[@]}" -gt 0 ]]; then
  payload="$(SPEC_MISSING="$(IFS='||'; echo "${missing[*]}")" python3 - <<'PY'
import json, os
payload = {"missing": [m for m in os.environ.get('SPEC_MISSING','').split('||') if m]}
print(json.dumps(payload))
PY
)"
  write_hook_output "missing-prerequisites" "Missing prerequisites detected" "${payload}"
else
  write_hook_output "prerequisites" "All prerequisites satisfied"
fi
