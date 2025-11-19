# Orchestrating Workflow: Technical Reference

This document contains the detailed implementation of all auto-mode orchestration functions.

**Language**: Bash (≥4.0 required for `read -t` timeout support)
**Dependencies**: jq (≥1.6), uuidgen or /dev/urandom

---

## Table of Contents

1. [State Management](#state-management)
2. [Backup & Restore](#backup--restore)
3. [Session Management](#session-management)
4. [Phase Sequencing](#phase-sequencing)
5. [Checkpoint System](#checkpoint-system)
6. [Interruption Handling](#interruption-handling)
7. [Resume Logic](#resume-logic)
8. [Utility Functions](#utility-functions)

---

## State Management

### save_auto_mode_state

Creates or initializes auto-mode session state.

**Signature**:
```bash
save_auto_mode_state <session_id> <status> <current_phase>
```

**Parameters**:
- `session_id`: UUID for this session
- `status`: `running|paused|interrupted|complete`
- `current_phase`: `specification|clarification|planning|tasks|implementation`

**Implementation**:
```bash
function save_auto_mode_state() {
  local session_id="$1"
  local status="$2"
  local current_phase="$3"

  local state_file=".spec/state/auto-mode-session.json"
  local temp_file="${state_file}.tmp"

  # Ensure state directory exists
  mkdir -p "$(dirname "$state_file")"

  # Build JSON (atomic write pattern)
  jq -n \
    --arg sid "$session_id" \
    --arg status "$status" \
    --arg phase "$current_phase" \
    --arg started "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg expires "$(date -u -d '+24 hours' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v+24H +%Y-%m-%dT%H:%M:%SZ)" \
    '{
      session_id: $sid,
      mode: "auto",
      status: $status,
      current_phase: $phase,
      completed_phases: [],
      checkpoint_strategy: {
        after_spec: true,
        after_clarify: true,
        after_plan: true,
        after_tasks: true,
        before_implement: true,
        timeout: 10,
        default_action: "continue"
      },
      interruption_count: 0,
      started_at: $started,
      expires_at: $expires,
      metadata: {}
    }' > "$temp_file"

  # Atomic rename
  mv "$temp_file" "$state_file" || {
    echo "Error: Failed to save auto-mode state"
    rm -f "$temp_file"
    return 1
  }

  return 0
}
```

**Example**:
```bash
session_id=$(generate_session_id)
save_auto_mode_state "$session_id" "running" "specification"
```

---

### update_auto_mode_state

Updates current phase and status in existing session.

**Signature**:
```bash
update_auto_mode_state <phase> <status>
```

**Implementation**:
```bash
function update_auto_mode_state() {
  local phase="$1"
  local status="$2"

  local state_file=".spec/state/auto-mode-session.json"
  local temp_file="${state_file}.tmp"

  if [ ! -f "$state_file" ]; then
    echo "Error: No auto-mode session found"
    return 1
  fi

  # Update fields
  jq \
    --arg phase "$phase" \
    --arg status "$status" \
    '.current_phase = $phase | .status = $status' \
    "$state_file" > "$temp_file"

  # Atomic rename
  mv "$temp_file" "$state_file" || {
    echo "Error: Failed to update auto-mode state"
    rm -f "$temp_file"
    return 1
  }

  return 0
}
```

**Example**:
```bash
update_auto_mode_state "planning" "running"
```

---

### add_completed_phase

Appends a phase to the completed_phases array.

**Signature**:
```bash
add_completed_phase <phase>
```

**Implementation**:
```bash
function add_completed_phase() {
  local phase="$1"

  local state_file=".spec/state/auto-mode-session.json"
  local temp_file="${state_file}.tmp"

  if [ ! -f "$state_file" ]; then
    echo "Error: No auto-mode session found"
    return 1
  fi

  # Append to completed_phases array
  jq \
    --arg phase "$phase" \
    '.completed_phases += [$phase]' \
    "$state_file" > "$temp_file"

  # Atomic rename
  mv "$temp_file" "$state_file" || {
    echo "Error: Failed to add completed phase"
    rm -f "$temp_file"
    return 1
  }

  return 0
}
```

**Example**:
```bash
add_completed_phase "specification"
add_completed_phase "clarification"
```

---

### mark_session_complete

Marks session as complete with timestamp.

**Signature**:
```bash
mark_session_complete <session_id>
```

**Implementation**:
```bash
function mark_session_complete() {
  local session_id="$1"

  local state_file=".spec/state/auto-mode-session.json"
  local temp_file="${state_file}.tmp"

  if [ ! -f "$state_file" ]; then
    echo "Warning: No auto-mode session to complete"
    return 0
  fi

  # Verify session ID matches
  local current_sid=$(jq -r '.session_id' "$state_file")
  if [ "$current_sid" != "$session_id" ]; then
    echo "Warning: Session ID mismatch ($current_sid != $session_id)"
  fi

  # Mark complete
  jq \
    --arg completed "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '.status = "complete" | .completed_at = $completed | .current_phase = "complete"' \
    "$state_file" > "$temp_file"

  # Atomic rename
  mv "$temp_file" "$state_file" || {
    echo "Error: Failed to mark session complete"
    rm -f "$temp_file"
    return 1
  }

  return 0
}
```

---

## Backup & Restore

### backup_state

Creates timestamped backup of auto-mode session, retains last 10.

**Signature**:
```bash
backup_state
```

**Implementation**:
```bash
function backup_state() {
  local state_file=".spec/state/auto-mode-session.json"
  local backup_dir=".spec/state/backups"
  local timestamp=$(date +%Y%m%d-%H%M%S)

  if [ ! -f "$state_file" ]; then
    echo "Warning: No state file to backup"
    return 0
  fi

  # Create backup directory
  mkdir -p "$backup_dir"

  # Copy to backup
  cp "$state_file" "$backup_dir/auto-mode-$timestamp.json" || {
    echo "Error: Failed to create backup"
    return 1
  }

  # Keep only last 10 backups
  local backup_count=$(ls -1 "$backup_dir"/auto-mode-*.json 2>/dev/null | wc -l)
  if [ "$backup_count" -gt 10 ]; then
    ls -t "$backup_dir"/auto-mode-*.json | tail -n +11 | xargs rm -f
  fi

  return 0
}
```

**Example**:
```bash
backup_state  # Creates .spec/state/backups/auto-mode-20251119-143022.json
```

---

### restore_state

Restores state from a specific backup file.

**Signature**:
```bash
restore_state <backup_file>
```

**Implementation**:
```bash
function restore_state() {
  local backup_file="$1"
  local state_file=".spec/state/auto-mode-session.json"

  if [ ! -f "$backup_file" ]; then
    echo "Error: Backup file not found: $backup_file"
    return 1
  fi

  # Validate JSON
  if ! jq empty "$backup_file" 2>/dev/null; then
    echo "Error: Invalid JSON in backup file"
    return 1
  fi

  # Restore (atomic copy)
  cp "$backup_file" "$state_file" || {
    echo "Error: Failed to restore state"
    return 1
  }

  echo "State restored from $backup_file"
  return 0
}
```

**Example**:
```bash
restore_state ".spec/state/backups/auto-mode-20251119-143022.json"
```

---

### list_backups

Lists available backups in chronological order.

**Signature**:
```bash
list_backups
```

**Implementation**:
```bash
function list_backups() {
  local backup_dir=".spec/state/backups"

  if [ ! -d "$backup_dir" ]; then
    echo "No backups found"
    return 0
  fi

  local backups=$(ls -t "$backup_dir"/auto-mode-*.json 2>/dev/null)

  if [ -z "$backups" ]; then
    echo "No backups found"
    return 0
  fi

  echo "Available backups (newest first):"
  echo "$backups" | while read -r backup; do
    local basename=$(basename "$backup")
    local timestamp=$(echo "$basename" | sed 's/auto-mode-\(.*\)\.json/\1/')
    local session_id=$(jq -r '.session_id' "$backup" 2>/dev/null || echo "unknown")
    local phase=$(jq -r '.current_phase' "$backup" 2>/dev/null || echo "unknown")

    echo "  $basename (session: ${session_id:0:8}, phase: $phase)"
  done

  return 0
}
```

---

### rollback_to_phase

Rolls back auto-mode state to a specific phase, undoing partial changes.

**Signature**:
```bash
rollback_to_phase <target_phase>
```

**Parameters**:
- `target_phase`: Phase to roll back to (specification, clarification, planning, tasks)

**Implementation**:
```bash
function rollback_to_phase() {
  local target_phase="$1"
  local state_file=".spec/state/auto-mode-session.json"

  if [ ! -f "$state_file" ]; then
    echo "Error: No active auto-mode session"
    return 1
  fi

  # Validate target phase
  case "$target_phase" in
    specification|clarification|planning|tasks)
      ;;  # Valid
    *)
      echo "Error: Invalid target phase: $target_phase"
      echo "Valid phases: specification, clarification, planning, tasks"
      return 1
      ;;
  esac

  # Create rollback backup first
  backup_state

  # Get current phase and completed phases
  local current_phase=$(jq -r '.current_phase' "$state_file")
  local completed_phases=$(jq -r '.completed_phases[]' "$state_file" 2>/dev/null | tr '\n' ' ')

  echo ""
  echo "Rolling back from $current_phase to $target_phase..."
  echo ""

  # Update state: set current phase and remove phases after target
  local temp_file="${state_file}.tmp"
  jq \
    --arg target "$target_phase" \
    '.current_phase = $target |
     .status = "running" |
     .completed_phases = [.completed_phases[] | select(. != "planning" and . != "tasks" and . != "implementation")]' \
    "$state_file" > "$temp_file"

  # Rebuild completed phases list (only phases before target)
  case "$target_phase" in
    specification)
      # Roll back to start, no completed phases
      jq '.completed_phases = []' "$temp_file" > "${temp_file}.2"
      mv "${temp_file}.2" "$temp_file"
      ;;
    clarification)
      # Keep only specification
      jq '.completed_phases = ["specification"]' "$temp_file" > "${temp_file}.2"
      mv "${temp_file}.2" "$temp_file"
      ;;
    planning)
      # Keep specification + clarification
      jq '.completed_phases = ["specification", "clarification"]' "$temp_file" > "${temp_file}.2"
      mv "${temp_file}.2" "$temp_file"
      ;;
    tasks)
      # Keep specification + clarification + planning
      jq '.completed_phases = ["specification", "clarification", "planning"]' "$temp_file" > "${temp_file}.2"
      mv "${temp_file}.2" "$temp_file"
      ;;
  esac

  # Atomic update
  mv "$temp_file" "$state_file" || {
    echo "Error: Failed to update state"
    rm -f "$temp_file" "${temp_file}.2"
    return 1
  }

  echo "✓ Rolled back to $target_phase phase"
  echo "  Completed phases: $(jq -r '.completed_phases | join(", ")' "$state_file")"
  echo ""

  return 0
}
```

**Example**:
```bash
# Rollback from tasks to planning (re-run planning)
rollback_to_phase "planning"

# Rollback to start (re-run entire workflow)
rollback_to_phase "specification"
```

---

### rollback_on_error

Automatically rollback to last known good state if phase fails.

**Signature**:
```bash
rollback_on_error <failed_phase>
```

**Implementation**:
```bash
function rollback_on_error() {
  local failed_phase="$1"
  local backup_dir=".spec/state/backups"

  echo ""
  echo "⚠️  Phase $failed_phase failed"
  echo ""

  # Find most recent backup
  local latest_backup=$(ls -t "$backup_dir"/auto-mode-*.json 2>/dev/null | head -1)

  if [ -z "$latest_backup" ]; then
    echo "Error: No backup found to restore"
    echo "Manual intervention required"
    return 1
  fi

  # Show backup info
  local backup_phase=$(jq -r '.current_phase' "$latest_backup" 2>/dev/null)
  local backup_time=$(basename "$latest_backup" | sed 's/auto-mode-\(.*\)\.json/\1/')

  echo "Options:"
  echo "1. Rollback to last backup (phase: $backup_phase, time: $backup_time)"
  echo "2. Retry current phase"
  echo "3. Exit auto-mode"
  echo ""

  read -p "Choose (1-3): " choice

  case "$choice" in
    1)
      echo ""
      echo "Rolling back to backup..."
      restore_state "$latest_backup"
      return 2  # Signal to retry from backup point
      ;;
    2)
      echo ""
      echo "Retrying $failed_phase..."
      return 3  # Signal to retry current phase
      ;;
    3)
      echo ""
      echo "Exiting auto-mode"
      update_auto_mode_state "$failed_phase" "interrupted"
      return 1  # Signal to exit
      ;;
    *)
      echo ""
      echo "Invalid choice. Exiting auto-mode."
      return 1
      ;;
  esac
}
```

**Example**:
```bash
# Called when a skill fails
if run_phase "planning" "orbit-planning (Plan branch)"; then
  checkpoint "plan_complete" 10 "tasks"
else
  rollback_on_error "planning"
  exit_code=$?
  case $exit_code in
    2) orchestrate_from_phase "$(jq -r '.current_phase' .spec/state/auto-mode-session.json)" ;;
    3) run_phase "planning" "orbit-planning (Plan branch)" ;;  # Retry
    *) exit 1 ;;  # Exit
  esac
fi
```

---

### clean_partial_artifacts

Removes partially created artifacts from failed phase.

**Signature**:
```bash
clean_partial_artifacts <phase>
```

**Implementation**:
```bash
function clean_partial_artifacts() {
  local phase="$1"
  local feature_dir=$(get_current_feature_dir)

  if [ ! -d "$feature_dir" ]; then
    return 0  # No artifacts to clean
  fi

  echo ""
  echo "Cleaning partial artifacts from $phase..."

  # Phase-specific cleanup
  case "$phase" in
    specification)
      # Remove incomplete spec.md (check if has user stories)
      if [ -f "$feature_dir/spec.md" ]; then
        if ! grep -q "^### US-" "$feature_dir/spec.md" 2>/dev/null; then
          echo "  Removing incomplete spec.md"
          rm -f "$feature_dir/spec.md"
        fi
      fi
      ;;

    clarification)
      # No artifacts to clean (clarifications update spec.md)
      ;;

    planning)
      # Remove incomplete plan.md (check if has ADRs or components)
      if [ -f "$feature_dir/plan.md" ]; then
        if ! grep -q "^## ADR-" "$feature_dir/plan.md" 2>/dev/null; then
          echo "  Removing incomplete plan.md"
          rm -f "$feature_dir/plan.md"
        fi
      fi
      ;;

    tasks)
      # Remove incomplete tasks.md (check if has task list)
      if [ -f "$feature_dir/tasks.md" ]; then
        if ! grep -q "^### T[0-9]" "$feature_dir/tasks.md" 2>/dev/null; then
          echo "  Removing incomplete tasks.md"
          rm -f "$feature_dir/tasks.md"
        fi
      fi
      ;;

    implementation)
      # Don't auto-clean implementation artifacts (safer to keep partial code)
      echo "  Skipping implementation cleanup (manual review recommended)"
      ;;
  esac

  echo "✓ Cleanup complete"
  echo ""

  return 0
}
```

**Example**:
```bash
# Clean up after failed planning phase
clean_partial_artifacts "planning"
```

---

## Session Management

### generate_session_id

Generates UUID for session tracking.

**Signature**:
```bash
generate_session_id
```

**Implementation**:
```bash
function generate_session_id() {
  # Try uuidgen first (macOS, some Linux distros)
  if command -v uuidgen &> /dev/null; then
    uuidgen | tr '[:upper:]' '[:lower:]'
    return 0
  fi

  # Fallback: timestamp + random hex
  if [ -r /dev/urandom ]; then
    local timestamp=$(date +%s)
    local random=$(head -c 8 /dev/urandom | xxd -p)
    echo "${timestamp}-${random}"
    return 0
  fi

  # Last resort: timestamp + process ID
  echo "$(date +%s)-$$"
  return 0
}
```

**Example**:
```bash
session_id=$(generate_session_id)
# Output: 550e8400-e29b-41d4-a716-446655440000
```

---

### is_expired

Checks if session has expired (24h default).

**Signature**:
```bash
is_expired <expires_at_timestamp>
```

**Returns**: 0 if expired, 1 if not expired

**Implementation**:
```bash
function is_expired() {
  local expires_at="$1"

  if [ -z "$expires_at" ]; then
    echo "Error: No expiry timestamp provided"
    return 1
  fi

  local now=$(date -u +%s)
  local expiry=$(date -u -d "$expires_at" +%s 2>/dev/null || date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$expires_at" +%s 2>/dev/null)

  if [ -z "$expiry" ] || [ "$expiry" -eq 0 ]; then
    echo "Error: Invalid expiry date format"
    return 1
  fi

  if [ "$now" -gt "$expiry" ]; then
    return 0  # Expired
  else
    return 1  # Not expired
  fi
}
```

**Example**:
```bash
expires_at="2025-11-20T12:00:00Z"

if is_expired "$expires_at"; then
  echo "Session expired"
else
  echo "Session still valid"
fi
```

---

### get_time_until_expiry

Returns human-readable time until expiry.

**Signature**:
```bash
get_time_until_expiry <expires_at_timestamp>
```

**Implementation**:
```bash
function get_time_until_expiry() {
  local expires_at="$1"

  local now=$(date -u +%s)
  local expiry=$(date -u -d "$expires_at" +%s 2>/dev/null || date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$expires_at" +%s 2>/dev/null)

  if [ -z "$expiry" ]; then
    echo "Unknown"
    return 1
  fi

  local diff=$((expiry - now))

  if [ $diff -lt 0 ]; then
    echo "Expired"
    return 0
  fi

  local hours=$((diff / 3600))
  local minutes=$(( (diff % 3600) / 60 ))

  if [ $hours -gt 0 ]; then
    echo "${hours}h ${minutes}m remaining"
  else
    echo "${minutes}m remaining"
  fi

  return 0
}
```

**Example**:
```bash
expires_at=$(jq -r '.expires_at' .spec/state/auto-mode-session.json)
time_left=$(get_time_until_expiry "$expires_at")
echo "Time left: $time_left"
# Output: Time left: 18h 42m remaining
```

---

## Phase Sequencing

### determine_next_phase

Determines next phase based on current phase and conditions.

**Signature**:
```bash
determine_next_phase <current_phase> [has_clarifications]
```

**Implementation**:
```bash
function determine_next_phase() {
  local current_phase="$1"
  local has_clarifications="${2:-false}"

  case "$current_phase" in
    "specification")
      if [ "$has_clarifications" = "true" ]; then
        echo "clarification"
      else
        echo "planning"
      fi
      ;;
    "clarification")
      echo "planning"
      ;;
    "planning")
      echo "tasks"
      ;;
    "tasks")
      echo "implementation"
      ;;
    "implementation")
      echo "complete"
      ;;
    *)
      echo "unknown"
      return 1
      ;;
  esac

  return 0
}
```

**Example**:
```bash
next=$(determine_next_phase "specification" "true")
echo "$next"  # Output: clarification

next=$(determine_next_phase "specification" "false")
echo "$next"  # Output: planning
```

---

### has_clarifications

Checks if current feature has [CLARIFY] tags in spec.md.

**Signature**:
```bash
has_clarifications
```

**Returns**: 0 if clarifications exist, 1 if none

**Implementation**:
```bash
function has_clarifications() {
  local feature_dir=$(get_current_feature_dir)
  local spec_file="$feature_dir/spec.md"

  if [ ! -f "$spec_file" ]; then
    return 1  # No spec file, no clarifications
  fi

  # Search for [CLARIFY] tags (case-insensitive)
  if grep -qi '\[CLARIFY' "$spec_file"; then
    return 0  # Has clarifications
  else
    return 1  # No clarifications
  fi
}
```

---

### run_phase

Executes a single workflow phase by invoking the corresponding skill.

**Signature**:
```bash
run_phase <phase_name> <skill_name> [initial_input]
```

**Implementation**:
```bash
function run_phase() {
  local phase_name="$1"
  local skill_name="$2"
  local initial_input="${3:-}"

  echo "[Auto-Mode] Phase: $(format_phase_name $phase_name)"
  echo "Invoking skill: $skill_name..."
  echo ""

  # Update state to running
  update_auto_mode_state "$phase_name" "running"

  # Backup state before running (in case of errors)
  backup_state

  # TODO: Actual skill invocation via Skill tool
  # This would be handled by Claude's Skill tool in practice
  # For now, we simulate success
  echo "TODO: Invoke skill $skill_name"

  # Simulate skill execution (remove in production)
  # In production, check actual skill exit code and output

  local exit_code=0  # Assume success

  if [ $exit_code -ne 0 ]; then
    echo "Error: Skill $skill_name failed with exit code $exit_code"
    handle_skill_error "$phase_name" "$skill_name"
    return 1
  fi

  # Mark phase complete
  update_auto_mode_state "$phase_name" "complete"
  add_completed_phase "$phase_name"

  echo ""
  echo "✓ Phase $phase_name complete"
  echo ""

  return 0
}
```

---

## Checkpoint System

### checkpoint

Displays checkpoint UI and waits for user decision.

**Signature**:
```bash
checkpoint <checkpoint_id> <timeout_seconds> <next_phase>
```

**Returns**: 0 (continue), 1 (exit), 2 (refine/retry)

**Implementation**:
```bash
function checkpoint() {
  local checkpoint_id="$1"
  local timeout_seconds="${2:-}"
  local next_phase="$3"

  # Check if checkpoint should be shown (config may disable)
  if ! should_show_checkpoint "$checkpoint_id"; then
    return 0  # Skip checkpoint, auto-continue
  fi

  # Get timeout from config if not specified
  if [ -z "$timeout_seconds" ]; then
    timeout_seconds=$(get_checkpoint_timeout)
  fi

  # Display checkpoint UI
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ CHECKPOINT: $(format_checkpoint_name $checkpoint_id)"
  echo ""

  display_checkpoint_summary "$checkpoint_id"

  echo ""
  echo "Next: $(format_phase_name $next_phase)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Prompt with or without timeout
  if [ "$timeout_seconds" -gt 0 ]; then
    prompt_with_timeout "$timeout_seconds" "$next_phase"
  else
    prompt_without_timeout "$next_phase"
  fi

  return $?
}
```

---

### prompt_with_timeout

Prompts user with auto-continue timeout.

**Signature**:
```bash
prompt_with_timeout <timeout_seconds> <next_phase>
```

**Implementation**:
```bash
function prompt_with_timeout() {
  local timeout_seconds="$1"
  local next_phase="$2"

  echo "Continue to $(format_phase_name $next_phase)? (auto in ${timeout_seconds}s)"
  echo "→ Continue    Refine    Pause    Exit"
  echo ""

  # Read with timeout (bash 4.0+ required)
  local response
  read -t "$timeout_seconds" -p "> " response || response="continue"

  process_checkpoint_response "$response" "$next_phase"
  return $?
}
```

---

### prompt_without_timeout

Prompts user without timeout (explicit choice required).

**Signature**:
```bash
prompt_without_timeout <next_phase>
```

**Implementation**:
```bash
function prompt_without_timeout() {
  local next_phase="$1"

  echo "Begin $(format_phase_name $next_phase)?"
  echo "→ Start    Review    Exit"
  echo ""

  # Read without timeout
  local response
  read -p "> " response

  process_checkpoint_response "$response" "$next_phase"
  return $?
}
```

---

### process_checkpoint_response

Processes user response at checkpoint.

**Signature**:
```bash
process_checkpoint_response <response> <next_phase>
```

**Implementation**:
```bash
function process_checkpoint_response() {
  local response="$1"
  local next_phase="$2"

  # Normalize response (lowercase, trim whitespace)
  response=$(echo "$response" | tr '[:upper:]' '[:lower:]' | xargs)

  case "$response" in
    continue|start|"")
      echo ""
      echo "Continuing to $(format_phase_name $next_phase)..."
      echo ""
      return 0  # Continue
      ;;
    refine|review)
      echo ""
      handle_refine_request
      return $?
      ;;
    pause)
      echo ""
      handle_pause_request
      return 1  # Exit
      ;;
    exit)
      echo ""
      handle_exit_request
      return 1  # Exit
      ;;
    *)
      echo ""
      echo "Invalid choice. Continuing..."
      echo ""
      return 0  # Default to continue
      ;;
  esac
}
```

---

### display_checkpoint_summary

Shows context-specific summary at checkpoint.

**Signature**:
```bash
display_checkpoint_summary <checkpoint_id>
```

**Implementation**:
```bash
function display_checkpoint_summary() {
  local checkpoint_id="$1"
  local feature_dir=$(get_current_feature_dir)

  case "$checkpoint_id" in
    "spec_complete")
      local spec_file="$feature_dir/spec.md"
      local user_stories=$(count_user_stories "$spec_file")
      local clarifications=$(count_clarifications "$spec_file")

      echo "Created:"
      echo "  📄 $spec_file ($user_stories user stories)"
      if [ "$clarifications" -gt 0 ]; then
        echo "  📋 $clarifications clarifications needed"
      else
        echo "  ✅ No clarifications needed"
      fi
      ;;

    "clarify_complete")
      local clarifications=$(count_clarifications_resolved)
      echo "Resolved:"
      echo "  ✓ $clarifications clarifications"
      echo "  ✓ Updated spec.md with decisions"
      ;;

    "plan_complete")
      local plan_file="$feature_dir/plan.md"
      local adrs=$(count_adrs "$plan_file")
      local risks=$(count_risks "$plan_file")

      echo "Created:"
      echo "  📐 $plan_file"
      echo "  📝 $adrs ADRs logged"
      echo "  ⚠️ $risks risks identified with mitigations"
      ;;

    "tasks_complete")
      local tasks_file="$feature_dir/tasks.md"
      local task_count=$(count_tasks "$tasks_file")
      local critical_path=$(get_critical_path_hours "$tasks_file")
      local parallel_days=$(get_parallel_days "$tasks_file")

      echo "Created:"
      echo "  🎯 $tasks_file ($task_count tasks)"
      echo "  📊 Critical path: ${critical_path}h"
      echo "  ⚡ Parallel execution: ~${parallel_days} days"
      ;;

    *)
      echo "Phase complete"
      ;;
  esac
}
```

---

### load_checkpoint_config

Loads checkpoint configuration from `.spec/.spec-config.yml` or uses defaults.

**Signature**:
```bash
load_checkpoint_config
```

**Returns**: JSON string with checkpoint configuration

**Implementation**:
```bash
function load_checkpoint_config() {
  local config_file=".spec/.spec-config.yml"
  local default_config='{
    "after_spec": true,
    "after_clarify": true,
    "after_plan": true,
    "after_tasks": true,
    "before_implement": true,
    "timeout": 10,
    "default_action": "continue"
  }'

  # If no config file, use defaults
  if [ ! -f "$config_file" ]; then
    echo "$default_config"
    return 0
  fi

  # Try to parse YAML with yq if available, otherwise use defaults
  if command -v yq &> /dev/null; then
    local yaml_config=$(yq eval '.auto_mode.checkpoints' "$config_file" 2>/dev/null)

    if [ -n "$yaml_config" ] && [ "$yaml_config" != "null" ]; then
      # Convert YAML to JSON
      echo "$yaml_config" | yq eval -o=json
      return 0
    fi
  fi

  # Fallback to checking if checkpoints section exists with grep/awk
  if grep -q "^auto_mode:" "$config_file" 2>/dev/null; then
    # Parse YAML manually (basic support)
    local after_spec=$(grep -A 20 "checkpoints:" "$config_file" | grep "after_spec:" | awk '{print $2}' | head -1)
    local after_clarify=$(grep -A 20 "checkpoints:" "$config_file" | grep "after_clarify:" | awk '{print $2}' | head -1)
    local after_plan=$(grep -A 20 "checkpoints:" "$config_file" | grep "after_plan:" | awk '{print $2}' | head -1)
    local after_tasks=$(grep -A 20 "checkpoints:" "$config_file" | grep "after_tasks:" | awk '{print $2}' | head -1)
    local before_implement=$(grep -A 20 "checkpoints:" "$config_file" | grep "before_implement:" | awk '{print $2}' | head -1)
    local timeout=$(grep -A 20 "checkpoints:" "$config_file" | grep "timeout:" | awk '{print $2}' | head -1)
    local default_action=$(grep -A 20 "checkpoints:" "$config_file" | grep "default_action:" | awk '{print $2}' | head -1)

    # Build JSON with parsed values (fallback to defaults if not found)
    jq -n \
      --argjson after_spec "${after_spec:-true}" \
      --argjson after_clarify "${after_clarify:-true}" \
      --argjson after_plan "${after_plan:-true}" \
      --argjson after_tasks "${after_tasks:-true}" \
      --argjson before_implement "${before_implement:-true}" \
      --argjson timeout "${timeout:-10}" \
      --arg default_action "${default_action:-continue}" \
      '{
        after_spec: $after_spec,
        after_clarify: $after_clarify,
        after_plan: $after_plan,
        after_tasks: $after_tasks,
        before_implement: $before_implement,
        timeout: $timeout,
        default_action: $default_action
      }'
    return 0
  fi

  # No auto_mode config found, use defaults
  echo "$default_config"
  return 0
}
```

**Example**:
```bash
# Load config
checkpoint_config=$(load_checkpoint_config)

# Extract specific values
after_spec=$(echo "$checkpoint_config" | jq -r '.after_spec')
timeout=$(echo "$checkpoint_config" | jq -r '.timeout')

# Use in checkpoint logic
if [ "$after_spec" = "true" ]; then
  checkpoint "spec_complete" "$timeout" "clarification"
fi
```

**Notes**:
- Tries `yq` first for proper YAML parsing
- Falls back to basic grep/awk parsing if `yq` unavailable
- Always returns valid JSON (defaults if config missing/invalid)
- Supports both `true/false` and `yes/no` YAML boolean syntax

---

### should_show_checkpoint

Determines if a checkpoint should be displayed based on configuration.

**Signature**:
```bash
should_show_checkpoint <checkpoint_id>
```

**Returns**: 0 if checkpoint should show, 1 if should skip

**Implementation**:
```bash
function should_show_checkpoint() {
  local checkpoint_id="$1"
  local config=$(load_checkpoint_config)

  # Map checkpoint IDs to config keys
  local config_key=""
  case "$checkpoint_id" in
    "spec_complete") config_key="after_spec" ;;
    "clarify_complete") config_key="after_clarify" ;;
    "plan_complete") config_key="after_plan" ;;
    "tasks_complete") config_key="after_tasks" ;;
    "before_implement") config_key="before_implement" ;;
    *) return 0 ;;  # Unknown checkpoints default to show
  esac

  # Extract boolean from config
  local should_show=$(echo "$config" | jq -r ".$config_key")

  # Convert to bash return code (0 = true/show, 1 = false/skip)
  if [ "$should_show" = "true" ]; then
    return 0
  else
    return 1
  fi
}
```

**Example**:
```bash
# Check if checkpoint should be shown
if should_show_checkpoint "spec_complete"; then
  display_checkpoint "spec_complete" 10 "clarification"
else
  echo "[Auto-Mode] Skipping spec checkpoint (disabled in config)"
fi
```

---

### get_checkpoint_timeout

Gets timeout value for checkpoints from configuration.

**Signature**:
```bash
get_checkpoint_timeout
```

**Returns**: Timeout in seconds (integer)

**Implementation**:
```bash
function get_checkpoint_timeout() {
  local config=$(load_checkpoint_config)
  local timeout=$(echo "$config" | jq -r '.timeout')

  # Validate timeout is a number
  if ! [[ "$timeout" =~ ^[0-9]+$ ]]; then
    echo "10"  # Default to 10 seconds
    return 0
  fi

  echo "$timeout"
  return 0
}
```

**Example**:
```bash
# Get configured timeout
timeout=$(get_checkpoint_timeout)

# Use in checkpoint
prompt_with_timeout "$timeout" "clarification"
```

---

## (Continued in next section due to length...)

## Utility Functions

### format_phase_name

Converts phase identifier to human-readable name.

**Implementation**:
```bash
function format_phase_name() {
  local phase="$1"

  case "$phase" in
    "specification") echo "Specification" ;;
    "clarification") echo "Clarifications" ;;
    "planning") echo "Technical Plan" ;;
    "tasks") echo "Task Breakdown" ;;
    "implementation") echo "Implementation" ;;
    "complete") echo "Complete" ;;
    *) echo "$phase" ;;
  esac
}
```

### format_checkpoint_name

Converts checkpoint ID to display name.

**Implementation**:
```bash
function format_checkpoint_name() {
  local checkpoint_id="$1"

  case "$checkpoint_id" in
    "spec_complete") echo "Specification Complete" ;;
    "clarify_complete") echo "Clarifications Complete" ;;
    "plan_complete") echo "Planning Complete" ;;
    "tasks_complete") echo "Tasks Ready" ;;
    *) echo "$checkpoint_id" ;;
  esac
}
```

### get_current_feature_dir

Gets the active feature directory path.

**Implementation**:
```bash
function get_current_feature_dir() {
  # Read from current-session.md or state
  local feature_id=$(jq -r '.metadata.feature_id // empty' .spec/state/auto-mode-session.json 2>/dev/null)

  if [ -z "$feature_id" ]; then
    # Fallback: read from current-session.md
    feature_id=$(grep -m 1 "^feature:" .spec/state/current-session.md 2>/dev/null | awk '{print $2}')
  fi

  if [ -n "$feature_id" ]; then
    echo ".spec/features/$feature_id"
  else
    echo ""
  fi
}
```

### count_user_stories

Counts user stories in spec.md.

**Implementation**:
```bash
function count_user_stories() {
  local spec_file="$1"

  if [ ! -f "$spec_file" ]; then
    echo "0"
    return
  fi

  # Count lines starting with "#### US" (user story headers)
  grep -c '^#### US' "$spec_file" 2>/dev/null || echo "0"
}
```

### count_clarifications

Counts [CLARIFY] tags in spec.md.

**Implementation**:
```bash
function count_clarifications() {
  local spec_file="$1"

  if [ ! -f "$spec_file" ]; then
    echo "0"
    return
  fi

  # Count [CLARIFY] occurrences (case-insensitive)
  grep -oi '\[CLARIFY' "$spec_file" 2>/dev/null | wc -l | xargs
}
```

### count_adrs

Counts ADR entries in plan.md.

**Implementation**:
```bash
function count_adrs() {
  local plan_file="$1"

  if [ ! -f "$plan_file" ]; then
    echo "0"
    return
  fi

  # Count lines starting with "### ADR-" or "## ADR-"
  grep -cE '^##+ ADR-' "$plan_file" 2>/dev/null || echo "0"
}
```

### count_risks

Counts risk sections in plan.md.

**Implementation**:
```bash
function count_risks() {
  local plan_file="$1"

  if [ ! -f "$plan_file" ]; then
    echo "0"
    return
  fi

  # Count lines starting with "### R" or "## R" (risk IDs like R2.1)
  grep -cE '^##+ R[0-9]' "$plan_file" 2>/dev/null || echo "0"
}
```

### count_tasks

Counts tasks in tasks.md.

**Implementation**:
```bash
function count_tasks() {
  local tasks_file="$1"

  if [ ! -f "$tasks_file" ]; then
    echo "0"
    return
  fi

  # Count lines starting with "### T" (task IDs like T001)
  grep -cE '^### T[0-9]' "$tasks_file" 2>/dev/null || echo "0"
}
```

### get_critical_path_hours

Extracts critical path hours from tasks.md.

**Implementation**:
```bash
function get_critical_path_hours() {
  local tasks_file="$1"

  if [ ! -f "$tasks_file" ]; then
    echo "0"
    return
  fi

  # Search for "Critical path: Xh" or "Critical path: X-Yh"
  local hours=$(grep -oE 'Critical [Pp]ath[^0-9]*[0-9]+-?[0-9]*h' "$tasks_file" 2>/dev/null | head -1 | grep -oE '[0-9]+-?[0-9]*h')

  if [ -n "$hours" ]; then
    echo "$hours"
  else
    echo "unknown"
  fi
}
```

### get_parallel_days

Extracts parallel execution days from tasks.md.

**Implementation**:
```bash
function get_parallel_days() {
  local tasks_file="$1"

  if [ ! -f "$tasks_file" ]; then
    echo "0"
    return
  fi

  # Search for "~X days" or "X-Y days"
  local days=$(grep -oE '~?[0-9]+-?[0-9]* days' "$tasks_file" 2>/dev/null | head -1 | grep -oE '[0-9]+-?[0-9]*')

  if [ -n "$days" ]; then
    echo "$days"
  else
    echo "unknown"
  fi
}
```

---

## Checkpoint Display Functions (T008)

### should_show_checkpoint

Checks if checkpoint should be displayed based on configuration.

**Signature**:
```bash
should_show_checkpoint <checkpoint_id>
```

**Returns**: 0 (show), 1 (skip)

**Implementation**:
```bash
function should_show_checkpoint() {
  local checkpoint_id="$1"
  local config_file=".spec/.spec-config.yml"

  # If no config, show all checkpoints by default
  if [ ! -f "$config_file" ]; then
    return 0
  fi

  # Map checkpoint ID to config key
  local config_key
  case "$checkpoint_id" in
    "spec_complete") config_key="after_spec" ;;
    "clarify_complete") config_key="after_clarify" ;;
    "plan_complete") config_key="after_plan" ;;
    "tasks_complete") config_key="after_tasks" ;;
    *) return 0 ;;  # Show unknown checkpoints by default
  esac

  # Check if yq is available
  if ! command -v yq &> /dev/null; then
    return 0  # Show by default if no yq
  fi

  # Read config value
  local enabled=$(yq e ".auto_mode.checkpoints.$config_key // true" "$config_file" 2>/dev/null)

  if [ "$enabled" = "false" ]; then
    return 1  # Skip checkpoint
  else
    return 0  # Show checkpoint
  fi
}
```

### load_checkpoint_config

Loads checkpoint configuration from .spec-config.yml.

**Signature**:
```bash
load_checkpoint_config
```

**Returns**: Key=value pairs (timeout, default_action)

**Implementation**:
```bash
function load_checkpoint_config() {
  local config_file=".spec/.spec-config.yml"

  # Default values
  local timeout=10
  local default_action="continue"

  if [ ! -f "$config_file" ]; then
    echo "timeout=$timeout"
    echo "default_action=$default_action"
    return 0
  fi

  # Try to read with yq
  if command -v yq &> /dev/null; then
    timeout=$(yq e '.auto_mode.checkpoints.timeout // 10' "$config_file" 2>/dev/null)
    default_action=$(yq e '.auto_mode.checkpoints.default_action // "continue"' "$config_file" 2>/dev/null)
  fi

  echo "timeout=$timeout"
  echo "default_action=$default_action"
}
```

### handle_refine_request

Handles user request to refine current phase output.

**Signature**:
```bash
handle_refine_request
```

**Implementation**:
```bash
function handle_refine_request() {
  local current_phase=$(jq -r '.current_phase' .spec/state/auto-mode-session.json 2>/dev/null || echo "unknown")

  echo ""
  echo "Refining $current_phase..."
  echo ""
  echo "Options:"
  echo "1. Re-run current phase"
  echo "2. Edit spec/plan/tasks manually"
  echo "3. Cancel refine, continue to next phase"
  echo ""

  read -p "Choose (1-3): " choice

  case "$choice" in
    1)
      echo ""
      echo "Re-running $current_phase..."
      # Signal to caller to re-run phase
      return 2
      ;;
    2)
      local feature_dir=$(get_current_feature_dir)
      echo ""
      echo "Edit files in: $feature_dir"
      echo "Run /spec to continue when ready."
      echo ""
      exit 0
      ;;
    3)
      echo ""
      echo "Continuing to next phase..."
      return 0
      ;;
    *)
      echo ""
      echo "Invalid choice. Continuing to next phase..."
      return 0
      ;;
  esac
}
```

### handle_pause_request

Handles user request to pause auto-mode.

**Signature**:
```bash
handle_pause_request
```

**Implementation**:
```bash
function handle_pause_request() {
  local current_phase=$(jq -r '.current_phase' .spec/state/auto-mode-session.json 2>/dev/null)

  echo ""
  echo "⏸️  Auto-mode paused"
  echo ""
  echo "Progress saved. Run /spec to:"
  echo "  • Resume auto-mode"
  echo "  • Switch to interactive mode"
  echo "  • Review current state"
  echo ""

  # Update state to paused
  update_auto_mode_state "$current_phase" "paused"
}
```

### handle_exit_request

Handles user request to exit auto-mode.

**Signature**:
```bash
handle_exit_request
```

**Implementation**:
```bash
function handle_exit_request() {
  echo ""
  echo "🛑 Exiting auto-mode"
  echo ""
  echo "Options:"
  echo "1. Save progress and exit (can resume later)"
  echo "2. Discard auto-mode session (switch to interactive)"
  echo ""

  read -p "Choose (1-2): " choice

  case "$choice" in
    1)
      local current_phase=$(jq -r '.current_phase' .spec/state/auto-mode-session.json 2>/dev/null)
      update_auto_mode_state "$current_phase" "paused"
      echo ""
      echo "Progress saved. Run /spec to resume."
      echo ""
      ;;
    2)
      rm -f .spec/state/auto-mode-session.json
      echo ""
      echo "Auto-mode session discarded."
      echo ""
      ;;
    *)
      local current_phase=$(jq -r '.current_phase' .spec/state/auto-mode-session.json 2>/dev/null)
      update_auto_mode_state "$current_phase" "paused"
      echo ""
      echo "Progress saved. Run /spec to resume."
      echo ""
      ;;
  esac
}
```

---

## Timeout & Prompt Functions (T009)

### prompt_with_timeout

Displays prompt with automatic timeout and default action.

**Signature**:
```bash
prompt_with_timeout <timeout_seconds> <next_phase>
```

**Returns**: 0 (continue), 1 (exit), 2 (refine)

**Implementation**:
```bash
function prompt_with_timeout() {
  local timeout_seconds="$1"
  local next_phase="$2"

  echo "Continue to $(format_phase_name $next_phase)? (auto in ${timeout_seconds}s)"
  echo "→ Continue    Refine    Pause    Exit"
  echo ""

  # Read with timeout (bash 4.0+ required)
  local response
  read -t "$timeout_seconds" -p "> " response || response="continue"

  echo ""  # New line after timeout or input

  process_checkpoint_response "$response" "$next_phase"
  return $?
}
```

**Notes**:
- Requires bash ≥4.0 for `read -t` timeout support
- `|| response="continue"` sets default when timeout occurs
- Returns non-zero exit code on timeout (which we capture)

### prompt_without_timeout

Displays prompt without timeout (requires explicit user choice).

**Signature**:
```bash
prompt_without_timeout <next_phase>
```

**Returns**: 0 (continue), 1 (exit), 2 (refine)

**Implementation**:
```bash
function prompt_without_timeout() {
  local next_phase="$1"

  echo "Begin $(format_phase_name $next_phase)?"
  echo "→ Start    Review    Exit"
  echo ""

  # Read without timeout (wait indefinitely)
  local response
  read -p "> " response

  echo ""

  process_checkpoint_response "$response" "$next_phase"
  return $?
}
```

### process_checkpoint_response

Processes user response at checkpoint.

**Signature**:
```bash
process_checkpoint_response <response> <next_phase>
```

**Returns**: 0 (continue), 1 (exit), 2 (refine)

**Implementation**:
```bash
function process_checkpoint_response() {
  local response="$1"
  local next_phase="$2"

  # Normalize response (lowercase, trim whitespace)
  response=$(echo "$response" | tr '[:upper:]' '[:lower:]' | xargs)

  case "$response" in
    continue|start|"")
      echo "Continuing to $(format_phase_name $next_phase)..."
      echo ""
      return 0  # Continue
      ;;
    refine|review)
      handle_refine_request
      local refine_result=$?
      if [ $refine_result -eq 2 ]; then
        return 2  # Signal re-run
      else
        return 0  # Continue after refine
      fi
      ;;
    pause)
      handle_pause_request
      exit 0  # Exit script
      ;;
    exit)
      handle_exit_request
      exit 0  # Exit script
      ;;
    *)
      echo "Invalid choice. Continuing to $(format_phase_name $next_phase)..."
      echo ""
      return 0  # Default to continue
      ;;
  esac
}
```

---

## Resume & Interruption Functions (T014-T015)

### handle_interruption

Signal handler for graceful interruption (Ctrl+C, SIGTERM, errors).

**Signature**:
```bash
handle_interruption <signal>
```

**Implementation**:
```bash
function handle_interruption() {
  local signal="$1"

  echo ""
  echo "⚠️  Auto-mode interrupted ($signal)"
  echo "Saving progress..."

  # Get current phase from state
  local current_phase=$(jq -r '.current_phase' .spec/state/auto-mode-session.json 2>/dev/null || echo "unknown")

  if [ -f ".spec/state/auto-mode-session.json" ]; then
    # Update state to interrupted
    local temp_file=".spec/state/auto-mode-session.json.tmp"
    jq \
      --arg status "interrupted" \
      '.status = $status | .interruption_count += 1' \
      .spec/state/auto-mode-session.json > "$temp_file"
    mv "$temp_file" .spec/state/auto-mode-session.json

    echo "Progress saved. Run /spec to resume."
  else
    echo "Warning: No session state found to save"
  fi

  echo ""
  exit 130  # Standard exit code for SIGINT
}
```

**Usage**:
```bash
# Set up signal traps at start of auto-mode
trap 'handle_interruption SIGINT' SIGINT
trap 'handle_interruption SIGTERM' SIGTERM
trap 'handle_interruption ERR' ERR
```

### resume_auto_mode

Detects and offers to resume interrupted auto-mode session.

**Signature**:
```bash
resume_auto_mode
```

**Returns**: 0 (resumed), 1 (no session or declined)

**Implementation**:
```bash
function resume_auto_mode() {
  local session_file=".spec/state/auto-mode-session.json"

  if [ ! -f "$session_file" ]; then
    return 1  # No session to resume
  fi

  # Load session data
  local session_id=$(jq -r '.session_id' "$session_file")
  local current_phase=$(jq -r '.current_phase' "$session_file")
  local status=$(jq -r '.status' "$session_file")
  local completed_phases=$(jq -r '.completed_phases[]' "$session_file" 2>/dev/null)
  local expires_at=$(jq -r '.expires_at' "$session_file")
  local interruption_count=$(jq -r '.interruption_count' "$session_file")

  # Check if session is resumable
  if [ "$status" != "interrupted" ] && [ "$status" != "paused" ]; then
    return 1  # Not in resumable state
  fi

  # Check expiry
  if is_expired "$expires_at"; then
    echo "⚠️  Auto-mode session expired"
    echo ""
    echo "Session from: $(jq -r '.started_at' "$session_file")"
    echo "Expired: $expires_at"
    echo ""
    echo "Session too old to resume automatically."
    echo "Please start a new workflow."
    echo ""
    rm "$session_file"
    return 1
  fi

  # Display resume prompt
  echo "⚠️  Auto-mode interrupted during $(format_phase_name $current_phase)"
  echo ""
  echo "Progress saved:"

  # List completed phases
  if [ -n "$completed_phases" ]; then
    echo "$completed_phases" | while read -r phase; do
      echo "  ✓ $(format_phase_name $phase)"
    done
  fi

  echo "  ⚠️ $(format_phase_name $current_phase) (interrupted)"

  if [ "$interruption_count" -gt 1 ]; then
    echo "  (interrupted $interruption_count times)"
  fi

  echo ""
  echo "Time remaining: $(get_time_until_expiry "$expires_at")"
  echo ""
  echo "Resume from $(format_phase_name $current_phase)?"
  echo "→ Resume    Restart    Interactive"
  echo ""

  read -p "> " response

  case "${response,,}" in
    resume|"")
      echo ""
      echo "Resuming from $(format_phase_name $current_phase)..."
      echo ""
      orchestrate_from_phase "$current_phase"
      return 0
      ;;
    restart)
      echo ""
      echo "Restarting from beginning..."
      echo ""
      rm "$session_file"
      orchestrate_auto_mode
      return 0
      ;;
    interactive)
      echo ""
      echo "Switching to interactive mode..."
      echo ""
      rm "$session_file"
      return 1  # Fall back to interactive
      ;;
    *)
      echo ""
      echo "Invalid choice. Resuming..."
      echo ""
      orchestrate_from_phase "$current_phase"
      return 0
      ;;
  esac
}
```

### orchestrate_from_phase

Resumes auto-mode workflow from specific phase.

**Signature**:
```bash
orchestrate_from_phase <start_phase>
```

**Implementation**:
```bash
function orchestrate_from_phase() {
  local start_phase="$1"

  # Set up signal handlers
  trap 'handle_interruption SIGINT' SIGINT
  trap 'handle_interruption SIGTERM' SIGTERM

  # Resume workflow from specific phase
  case "$start_phase" in
    "specification")
      run_phase "specification" "orbit-lifecycle"
      checkpoint "spec_complete" 10 "clarification" || return

      if has_clarifications; then
        run_phase "clarification" "orbit-lifecycle (Clarify branch)"
        checkpoint "clarify_complete" 10 "planning" || return
      fi

      run_phase "planning" "orbit-planning (Plan branch)"
      checkpoint "plan_complete" 10 "tasks" || return

      run_phase "tasks" "orbit-planning (Tasks branch)"
      checkpoint "tasks_complete" 0 "implementation" || return
      ;;

    "clarification")
      run_phase "clarification" "orbit-lifecycle (Clarify branch)"
      checkpoint "clarify_complete" 10 "planning" || return

      run_phase "planning" "orbit-planning (Plan branch)"
      checkpoint "plan_complete" 10 "tasks" || return

      run_phase "tasks" "orbit-planning (Tasks branch)"
      checkpoint "tasks_complete" 0 "implementation" || return
      ;;

    "planning")
      run_phase "planning" "orbit-planning (Plan branch)"
      checkpoint "plan_complete" 10 "tasks" || return

      run_phase "tasks" "orbit-planning (Tasks branch)"
      checkpoint "tasks_complete" 0 "implementation" || return
      ;;

    "tasks")
      run_phase "tasks" "orbit-planning (Tasks branch)"
      checkpoint "tasks_complete" 0 "implementation" || return
      ;;

    *)
      echo "Error: Unknown phase: $start_phase"
      return 1
      ;;
  esac

  # Mark session complete
  local session_id=$(jq -r '.session_id' .spec/state/auto-mode-session.json)
  mark_session_complete "$session_id"

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ AUTO-MODE COMPLETE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}
```

---

## Main Orchestration Function

### orchestrate_auto_mode

Main entry point for auto-mode workflow orchestration.

**Signature**:
```bash
orchestrate_auto_mode [feature_description]
```

**Implementation**:
```bash
function orchestrate_auto_mode() {
  local feature_description="${1:-}"

  # Generate session ID
  local session_id=$(generate_session_id)

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "[Auto-Mode] Starting workflow..."
  echo "Session ID: ${session_id:0:8}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Initialize session state
  save_auto_mode_state "$session_id" "running" "specification"

  # Set up signal handlers
  trap 'handle_interruption SIGINT' SIGINT
  trap 'handle_interruption SIGTERM' SIGTERM

  # If no feature description provided, prompt for it
  if [ -z "$feature_description" ]; then
    echo "Describe your feature in natural language:"
    echo ""
    echo "  Examples:"
    echo "  • \"Auth system for end users, P1\""
    echo "  • \"User dashboard showing metrics (critical)\""
    echo "  • \"Dark mode theme (nice to have)\""
    echo ""
    echo "  Tips:"
    echo "  • Include priority: P1/critical, P2/should, P3/nice"
    echo "  • Mention personas: users, admins, developers"
    echo "  • Context auto-detected from codebase"
    echo ""

    read -p "> " feature_description
    echo ""
  fi

  # Phase 1: Specification
  echo "[Auto-Mode] Phase 1/5: SPECIFICATION"
  echo ""
  run_phase "specification" "orbit-lifecycle"
  checkpoint "spec_complete" 10 "clarification" || return

  # Phase 2: Clarification (conditional)
  if has_clarifications; then
    echo "[Auto-Mode] Phase 2/5: CLARIFICATIONS"
    echo ""
    run_phase "clarification" "orbit-lifecycle (Clarify branch)"
    checkpoint "clarify_complete" 10 "planning" || return
  else
    echo "[Auto-Mode] Phase 2/5: CLARIFICATIONS (skipped - none needed)"
    echo ""
  fi

  # Phase 3: Planning
  echo "[Auto-Mode] Phase 3/5: PLANNING"
  echo ""
  run_phase "planning" "orbit-planning (Plan branch)"
  checkpoint "plan_complete" 10 "tasks" || return

  # Phase 4: Tasks
  echo "[Auto-Mode] Phase 4/5: TASK BREAKDOWN"
  echo ""
  run_phase "tasks" "orbit-planning (Tasks branch)"
  checkpoint "tasks_complete" 0 "implementation" || return

  # Phase 5: Implementation (opt-in via checkpoint decision)
  # The tasks_complete checkpoint determines if user wants to proceed

  # Mark session complete
  mark_session_complete "$session_id"

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ AUTO-MODE COMPLETE"
  echo ""
  echo "Feature workflow complete through task breakdown."
  echo "Ready for implementation phase."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}
```

---

## Keyword Detection Function (T020)

### detect_continue_intent

Detects "continue" keyword in user message for automatic progression.

**Signature**:
```bash
detect_continue_intent <user_message>
```

**Returns**: 0 (detected), 1 (not detected)

**Implementation**:
```bash
function detect_continue_intent() {
  local message="$1"

  # Extract first 50 chars, lowercase
  local prefix=$(echo "$message" | head -c 50 | tr '[:upper:]' '[:lower:]')

  # Check for keywords
  if echo "$prefix" | grep -qE '\b(continue|next|proceed|go|yes)\b'; then
    return 0  # Intent detected
  else
    return 1  # No intent
  fi
}
```

**Example Usage**:
```bash
if detect_continue_intent "$user_message"; then
  echo "Continuing to next phase..."
  next_phase=$(determine_next_phase "$current_phase")
  run_phase "$next_phase" "..."
fi
```

---

**Status**: Implementation complete for T001-T015, T020
**Next**: T016-T019, T021-T032
**File**: `.claude/skills/orchestrating-workflow/reference.md`
