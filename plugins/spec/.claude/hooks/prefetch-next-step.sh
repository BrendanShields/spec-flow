#!/usr/bin/env bash

# Compute and cache the recommended next workflow step.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
payload="$(record_next_step 2>/dev/null || true)"

if [[ -n "${payload}" ]]; then
  write_hook_output "next-step" "Next workflow step prefetched" "${payload}"
else
  write_hook_output "next-step" "Next step unavailable"
fi
