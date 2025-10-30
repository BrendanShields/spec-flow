#!/bin/bash
# Specter Hook Runner
# Executes hooks based on workflow events

set -euo pipefail

# Source directory
SPECTER_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPECTER_ROOT="$(cd "$SPECTER_LIB_DIR/../.." && pwd)"

# Configuration
HOOK_CONFIG="$SPECTER_ROOT/.specter/hooks/config.json"
HOOK_LOG="$SPECTER_ROOT/.specter/logs/hooks.log"
PERF_LOG="$SPECTER_ROOT/.specter/logs/hook-performance.log"

# Ensure directories exist
mkdir -p "$(dirname "$HOOK_LOG")"

# Initialize hooks system if not already done
if [[ ! -f "$HOOK_CONFIG" ]]; then
  echo "⚠️  Hook configuration not found: $HOOK_CONFIG" >&2
  return 1
fi

##
# Run hooks for a given event
#
# Usage: specter_run_hooks <event> <context_json>
#
# Arguments:
#   event: Hook event name (post-command, pre-commit, post-merge, on-task-complete)
#   context: JSON string containing context for hooks
#
# Returns:
#   0 on success, 1 on failure (only if blocking hook fails)
#
specter_run_hooks() {
  local event=$1
  local context=${2:-"{}"}

  # Validate event exists in configuration
  if ! jq -e ".hooks[\"$event\"]" "$HOOK_CONFIG" >/dev/null 2>&1; then
    _log_hook "ERROR" "$event" "system" "Unknown hook event: $event"
    return 1
  fi

  # Check if hook is enabled
  local enabled=$(jq -r ".hooks[\"$event\"].enabled // false" "$HOOK_CONFIG")
  if [[ "$enabled" != "true" ]]; then
    _log_hook "DEBUG" "$event" "system" "Hook disabled, skipping"
    return 0
  fi

  # Get hook configuration
  local mode=$(jq -r ".hooks[\"$event\"].mode // \"sync\"" "$HOOK_CONFIG")
  local blocking=$(jq -r ".hooks[\"$event\"].blocking // false" "$HOOK_CONFIG")
  local scripts=$(jq -r ".hooks[\"$event\"].scripts[]" "$HOOK_CONFIG" 2>/dev/null || echo "")

  if [[ -z "$scripts" ]]; then
    _log_hook "WARN" "$event" "system" "No scripts configured for event"
    return 0
  fi

  # Execute hooks based on mode
  if [[ "$mode" == "async" ]]; then
    # Background execution for async hooks
    {
      for script in $scripts; do
        _run_single_hook "$event" "$script" "$context" "$blocking" || true
      done
    } &
    local hook_pid=$!
    echo "$hook_pid" > "$SPECTER_ROOT/.specter/logs/hook-${event}.pid"
    _log_hook "INFO" "$event" "system" "Started async execution (PID: $hook_pid)"
  else
    # Synchronous execution
    local failures=0
    for script in $scripts; do
      if ! _run_single_hook "$event" "$script" "$context" "$blocking"; then
        ((failures++))
        if [[ "$blocking" == "true" ]]; then
          _log_hook "ERROR" "$event" "$script" "Blocking hook failed, aborting"
          return 1
        fi
      fi
    done

    if [[ $failures -gt 0 ]]; then
      _log_hook "WARN" "$event" "system" "$failures hook(s) failed (non-blocking)"
    fi
  fi

  return 0
}

##
# Run a single hook script
#
# Arguments:
#   event: Hook event name
#   script: Hook script path (relative to .specter/hooks/)
#   context: JSON context
#   blocking: Whether failure should block
#
# Returns:
#   0 on success, 1 on failure
#
_run_single_hook() {
  local event=$1
  local script=$2
  local context=$3
  local blocking=$4

  local hook_path="$SPECTER_ROOT/.specter/hooks/$script"

  # Validate hook exists
  if [[ ! -f "$hook_path" ]]; then
    _log_hook "ERROR" "$event" "$script" "Hook file not found: $hook_path"
    return 1
  fi

  # Make executable if not already
  if [[ ! -x "$hook_path" ]]; then
    chmod +x "$hook_path"
  fi

  # Get timeout from config
  local timeout=$(jq -r ".hooks[\"$event\"].timeout // 5000" "$HOOK_CONFIG")

  # Prepare sandbox environment
  local sandbox_env=""
  sandbox_env="${sandbox_env} PATH=/usr/bin:/bin"
  sandbox_env="${sandbox_env} SPECTER_ROOT=$SPECTER_ROOT"
  sandbox_env="${sandbox_env} SPECTER_EVENT=$event"

  # Add feature context if available
  if jq -e '.activeFeature.id' <<<"$context" >/dev/null 2>&1; then
    local feature_id=$(jq -r '.activeFeature.id' <<<"$context")
    sandbox_env="${sandbox_env} SPECTER_FEATURE=$feature_id"
  fi

  # Execute hook with timeout
  local start_time=$(date +%s%N)
  local exit_code=0
  local hook_output=""

  _log_hook "INFO" "$event" "$script" "Executing (timeout: ${timeout}ms)"

  # Run hook and capture output
  if command -v timeout >/dev/null 2>&1; then
    # GNU timeout available
    hook_output=$(timeout "${timeout}ms" env $sandbox_env bash "$hook_path" <<< "$context" 2>&1) || exit_code=$?
  elif command -v gtimeout >/dev/null 2>&1; then
    # macOS with coreutils installed
    hook_output=$(gtimeout "${timeout}ms" env $sandbox_env bash "$hook_path" <<< "$context" 2>&1) || exit_code=$?
  else
    # Fallback: no timeout (not ideal, but functional)
    hook_output=$(env $sandbox_env bash "$hook_path" <<< "$context" 2>&1) || exit_code=$?
  fi

  local end_time=$(date +%s%N)
  local elapsed_ms=$(( (end_time - start_time) / 1000000 ))

  # Log performance
  echo "[$(date -Iseconds)] $event:$script - ${elapsed_ms}ms - exit:$exit_code" >> "$PERF_LOG"

  # Log output
  if [[ -n "$hook_output" ]]; then
    echo "$hook_output" >> "$HOOK_LOG"
  fi

  # Check performance budget
  local budget=$(jq -r ".performance.budgets[\"$event\"] // 5000" "$HOOK_CONFIG")
  if [[ $elapsed_ms -gt $budget ]]; then
    _log_hook "WARN" "$event" "$script" "Exceeded performance budget: ${elapsed_ms}ms > ${budget}ms"
  fi

  # Handle exit code
  if [[ $exit_code -eq 0 ]]; then
    _log_hook "INFO" "$event" "$script" "Completed successfully (${elapsed_ms}ms)"
    return 0
  elif [[ $exit_code -eq 124 ]] || [[ $exit_code -eq 143 ]]; then
    _log_hook "ERROR" "$event" "$script" "Timeout after ${timeout}ms"
    return 1
  else
    _log_hook "ERROR" "$event" "$script" "Failed with exit code $exit_code (${elapsed_ms}ms)"
    return 1
  fi
}

##
# Log hook execution
#
# Arguments:
#   level: Log level (INFO, WARN, ERROR, DEBUG)
#   event: Hook event
#   script: Hook script name
#   message: Log message
#
_log_hook() {
  local level=$1
  local event=$2
  local script=$3
  local message=$4

  local timestamp=$(date -Iseconds)
  local log_entry="[$timestamp] $level [$event:$script] $message"

  # Get configured log level
  local log_level=$(jq -r ".logging.level // \"INFO\"" "$HOOK_CONFIG")

  # Log level hierarchy: DEBUG < INFO < WARN < ERROR
  local should_log=false
  case "$log_level" in
    DEBUG)
      should_log=true
      ;;
    INFO)
      [[ "$level" != "DEBUG" ]] && should_log=true
      ;;
    WARN)
      [[ "$level" == "WARN" ]] || [[ "$level" == "ERROR" ]] && should_log=true
      ;;
    ERROR)
      [[ "$level" == "ERROR" ]] && should_log=true
      ;;
  esac

  if [[ "$should_log" == "true" ]]; then
    echo "$log_entry" >> "$HOOK_LOG"

    # Also print to stderr for errors
    if [[ "$level" == "ERROR" ]]; then
      echo "$log_entry" >&2
    fi
  fi
}

##
# Check if hooks are enabled globally
#
# Returns:
#   0 if enabled, 1 if disabled
#
specter_hooks_enabled() {
  # Check environment variable override
  if [[ "${SPECTER_HOOKS_ENABLED:-true}" == "false" ]]; then
    return 1
  fi

  # Check if any hooks are enabled
  local any_enabled=$(jq -r '[.hooks[] | select(.enabled == true)] | length' "$HOOK_CONFIG")
  if [[ "$any_enabled" -gt 0 ]]; then
    return 0
  fi

  return 1
}

##
# Wait for async hooks to complete
#
# Usage: specter_wait_for_hooks <event>
#
specter_wait_for_hooks() {
  local event=$1
  local pid_file="$SPECTER_ROOT/.specter/logs/hook-${event}.pid"

  if [[ -f "$pid_file" ]]; then
    local pid=$(cat "$pid_file")
    if kill -0 "$pid" 2>/dev/null; then
      _log_hook "INFO" "$event" "system" "Waiting for async hooks to complete (PID: $pid)"
      wait "$pid" 2>/dev/null || true
    fi
    rm -f "$pid_file"
  fi
}

# Export functions for use in other scripts
export -f specter_run_hooks
export -f specter_hooks_enabled
export -f specter_wait_for_hooks
