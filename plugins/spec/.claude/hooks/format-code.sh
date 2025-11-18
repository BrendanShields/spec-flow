#!/usr/bin/env bash

# Auto-format files prior to Write/Edit operations.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
if [[ -z "${CONTEXT// }" ]]; then
  exit 0
fi

export CONTEXT_JSON="${CONTEXT}"
read -r FILE_PATH TOOL < <(python3 <<'PY'
import json, os
data = json.loads(os.environ.get("CONTEXT_JSON") or "{}")
print(data.get("file_path") or "")
print(data.get("tool") or "")
PY
)

if [[ -z "${FILE_PATH}" ]]; then
  exit 0
fi

if [[ "${TOOL}" != "Write" && "${TOOL}" != "Edit" ]]; then
  exit 0
fi

if [[ ! -f "${FILE_PATH}" ]]; then
  exit 0
fi

formatter=""
case "${FILE_PATH}" in
  *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs|*.json|*.css|*.md)
    formatter="prettier"
    ;;
  *.py)
    formatter="black"
    ;;
  *.go)
    formatter="gofmt"
    ;;
  *.rs)
    formatter="rustfmt"
    ;;
esac

if [[ -z "${formatter}" ]]; then
  exit 0
fi

cd "${PROJECT_DIR}"

case "${formatter}" in
  prettier)
    npx --yes prettier --loglevel warn --write "${FILE_PATH}" >/dev/null 2>&1 || true
    ;;
  black)
    black "${FILE_PATH}" >/dev/null 2>&1 || true
    ;;
  gofmt)
    gofmt -w "${FILE_PATH}" >/dev/null 2>&1 || true
    ;;
  rustfmt)
    rustfmt "${FILE_PATH}" >/dev/null 2>&1 || true
    ;;
esac

write_hook_output "format-code" "Formatter executed" "{\"formatter\":\"${formatter}\",\"file\":\"$(relative_path "${FILE_PATH}")\"}"
