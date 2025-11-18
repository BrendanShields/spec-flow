#!/usr/bin/env bash

# Prepare Spec workspace directories and configuration.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
ensure_directories
ensure_config

if [[ ! -d "${SPEC_DIR}" ]]; then
  mkdir -p "${SPEC_DIR}"
fi

if [[ ! -f "${STATE_DIR}/current-session.md" ]]; then
  cat >"${STATE_DIR}/current-session.md" <<'MARKDOWN'
---
feature: none
phase: initialize
started: ''
last_updated: ''
---

# Current Session State

Spec workflow is ready. Run `/spec` to begin.
MARKDOWN
fi

record_next_step >/dev/null 2>&1 || true

write_hook_output "session-init" "Spec workspace initialized" "{\"config\":\"${CONFIG_FILE}\",\"state_file\":\"${STATE_DIR}/current-session.md\"}"
