#!/usr/bin/env bash

# Prepare Orbit workspace directories and session state.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
ensure_directories
ensure_config
ensure_session_file

current_status="$(session_get "current.status")"
if [[ -z "${current_status}" || "${current_status}" == "null" ]]; then
  session_set_value "current.phase" "initialize"
  session_set_value "current.status" "not_initialized"
  session_set_value "timestamps.started" "$(timestamp)"
fi

record_next_step >/dev/null 2>&1 || true

write_hook_output "orbit-session-init" "Orbit session initialized" "{\"session_file\":\"${SESSION_JSON}\"}"
