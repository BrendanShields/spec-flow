#!/usr/bin/env bash

# Produce a compact session summary on Stop/SessionEnd.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"
ensure_directories

feature="$(frontmatter_value "feature")"
phase="$(frontmatter_value "phase")"
recent_progress="$(tail -n 5 "${PROGRESS_FILE}" 2>/dev/null || true)"
recent_metrics="$(tail -n 5 "${METRICS_FILE}" 2>/dev/null || true)"

{
  echo "# Spec Session Summary ($(timestamp))"
  echo
  echo "- Feature: ${feature:-none}"
  echo "- Phase: ${phase:-initialize}"
  echo
  echo "## Recent Progress"
  if [[ -n "${recent_progress}" ]]; then
    echo '```'
    echo "${recent_progress}"
    echo '```'
  else
    echo "_No activity recorded yet._"
  fi
  echo
  echo "## Recent Metrics"
  if [[ -n "${recent_metrics}" ]]; then
    echo '```'
    echo "${recent_metrics}"
    echo '```'
  else
    echo "_No metrics collected._"
  fi
} >"${SUMMARY_FILE}"

write_hook_output "session-summary" "Session summary saved" "{\"summary_file\":\"${SUMMARY_FILE}\"}"
