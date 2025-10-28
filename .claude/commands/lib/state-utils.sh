#!/bin/bash
# State Management Utilities for Flow Commands
# Used by slash commands to read/write session state

set -euo pipefail

# Configuration
FLOW_STATE_DIR="${FLOW_STATE_DIR:-.flow/state}"
FLOW_MEMORY_DIR="${FLOW_MEMORY_DIR:-.flow/memory}"
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"

# Ensure directories exist
ensure_directories() {
    mkdir -p "$FLOW_STATE_DIR" "$FLOW_MEMORY_DIR" "$FLOW_STATE_DIR/checkpoints"
}

# Get current session file
get_session_file() {
    echo "$FLOW_STATE_DIR/current-session.md"
}

# Check if session exists
has_active_session() {
    local session_file=$(get_session_file)
    [[ -f "$session_file" ]] && [[ -s "$session_file" ]]
}

# Get active feature
get_active_feature() {
    local session_file=$(get_session_file)
    if [[ -f "$session_file" ]]; then
        grep "^- \*\*Feature ID\*\*:" "$session_file" | sed 's/.*: //' || echo ""
    else
        echo ""
    fi
}

# Get active phase
get_active_phase() {
    local session_file=$(get_session_file)
    if [[ -f "$session_file" ]]; then
        grep "^- \*\*Phase\*\*:" "$session_file" | sed 's/.*: //' | awk '{print $1}' || echo "unknown"
    else
        echo "unknown"
    fi
}

# Get current task
get_current_task() {
    local session_file=$(get_session_file)
    if [[ -f "$session_file" ]]; then
        grep "^- \*\*Task ID\*\*:" "$session_file" | sed 's/.*: //' || echo ""
    else
        echo ""
    fi
}

# Count completed tasks
count_completed_tasks() {
    local feature_dir="$1"
    local tasks_file="$feature_dir/tasks.md"

    if [[ -f "$tasks_file" ]]; then
        grep -c "^- \[x\]" "$tasks_file" || echo "0"
    else
        echo "0"
    fi
}

# Count total tasks
count_total_tasks() {
    local feature_dir="$1"
    local tasks_file="$feature_dir/tasks.md"

    if [[ -f "$tasks_file" ]]; then
        grep -c "^- \[.\]" "$tasks_file" || echo "0"
    else
        echo "0"
    fi
}

# Find features directory
find_features_dir() {
    if [[ -d ".flow/features" ]]; then
        echo ".flow/features"
    elif [[ -d "features" ]]; then
        echo "features"
    else
        echo ""
    fi
}

# Get latest feature
get_latest_feature() {
    local features_dir=$(find_features_dir)
    if [[ -n "$features_dir" ]] && [[ -d "$features_dir" ]]; then
        ls -t "$features_dir" | head -1 || echo ""
    else
        echo ""
    fi
}

# Check if flow is initialized
is_flow_initialized() {
    [[ -d ".flow" ]] || [[ -f "CLAUDE.md" ]]
}

# Get workflow phase from feature
get_feature_phase() {
    local feature_dir="$1"

    # Check which files exist to determine phase
    if [[ ! -f "$feature_dir/spec.md" ]]; then
        echo "not_started"
    elif [[ ! -f "$feature_dir/plan.md" ]]; then
        echo "specification"
    elif [[ ! -f "$feature_dir/tasks.md" ]]; then
        echo "planning"
    else
        local completed=$(count_completed_tasks "$feature_dir")
        local total=$(count_total_tasks "$feature_dir")

        if [[ "$completed" -eq "$total" ]] && [[ "$total" -gt 0 ]]; then
            echo "complete"
        else
            echo "implementation"
        fi
    fi
}

# Update session state
update_session() {
    local feature_id="$1"
    local phase="$2"
    local task_id="${3:-}"

    local session_file=$(get_session_file)
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    cat > "$session_file" << EOF
# Current Session State

**Session ID**: sess_$(date +%s)
**Created**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Updated**: $timestamp

## Active Work

### Current Feature
- **Feature ID**: $feature_id
- **Phase**: $phase
- **Started**: $timestamp
${task_id:+- **Current Task**: $task_id}

## Last Updated
$timestamp
EOF
}

# Create checkpoint
create_checkpoint() {
    local name="${1:-auto}"
    local timestamp=$(date +"%Y-%m-%d-%H-%M")
    local session_file=$(get_session_file)

    if [[ -f "$session_file" ]]; then
        local checkpoint_file="$FLOW_STATE_DIR/checkpoints/${timestamp}-${name}.md"
        cp "$session_file" "$checkpoint_file"
        echo "$checkpoint_file"
    else
        echo ""
    fi
}

# List checkpoints
list_checkpoints() {
    local checkpoints_dir="$FLOW_STATE_DIR/checkpoints"
    if [[ -d "$checkpoints_dir" ]]; then
        ls -t "$checkpoints_dir"/*.md 2>/dev/null | head -10 || echo ""
    else
        echo ""
    fi
}

# Restore checkpoint
restore_checkpoint() {
    local checkpoint="$1"
    local session_file=$(get_session_file)

    if [[ -f "$checkpoint" ]]; then
        cp "$checkpoint" "$session_file"
        echo "restored"
    else
        echo "not_found"
    fi
}

# Export functions for use in scripts
export -f ensure_directories
export -f has_active_session
export -f get_active_feature
export -f get_active_phase
export -f get_current_task
export -f count_completed_tasks
export -f count_total_tasks
export -f find_features_dir
export -f get_latest_feature
export -f is_flow_initialized
export -f get_feature_phase
export -f update_session
export -f create_checkpoint
export -f list_checkpoints
export -f restore_checkpoint