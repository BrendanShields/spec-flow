#!/usr/bin/env bash

# Compute and store the recommended next workflow step inside session.json.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
ensure_session_file

record_next_step >/dev/null 2>&1 || true

next_phase="$(session_get "nextAction.phase")"
next_hint="$(session_get "nextAction.hint")"

write_hook_output "orbit-prefetch-next-step" "Next workflow step recorded" "{\"next\":{\"phase\":\"${next_phase}\",\"hint\":\"${next_hint}\"}}"
