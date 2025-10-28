#!/bin/bash
# Common Flow utility functions

# Get the next feature number
get_next_feature_number() {
    local features_dir="${1:-features}"
    local last_num=$(ls -1 "$features_dir" 2>/dev/null | grep -E '^[0-9]{3}-' | tail -1 | cut -d'-' -f1)
    if [ -z "$last_num" ]; then
        echo "001"
    else
        printf "%03d" $((10#$last_num + 1))
    fi
}

# Convert string to kebab-case
to_kebab_case() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g'
}

# Get current feature from session
get_current_feature() {
    local session_file=".flow-state/current-session.md"
    if [ -f "$session_file" ]; then
        grep "Feature ID" "$session_file" | head -1 | cut -d':' -f2 | xargs
    fi
}

# Update session timestamp
update_session_timestamp() {
    local session_file=".flow-state/current-session.md"
    if [ -f "$session_file" ]; then
        local timestamp=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
        sed -i.bak "s/\*\*Updated\*\*: .*/\*\*Updated\*\*: $timestamp/" "$session_file"
        rm -f "$session_file.bak"
    fi
}

# Check if Flow is initialized
check_flow_initialized() {
    if [ ! -d ".flow" ] || [ ! -d ".flow-state" ] || [ ! -d ".flow-memory" ]; then
        echo "Error: Flow not initialized. Run '/flow-init' first."
        return 1
    fi
    return 0
}

# Get git branch
get_git_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"
}

# Get git status summary
get_git_status() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local modified=$(git status --porcelain | grep -c "^ M")
        local added=$(git status --porcelain | grep -c "^A")
        local deleted=$(git status --porcelain | grep -c "^D")
        echo "Modified: $modified, Added: $added, Deleted: $deleted"
    else
        echo "Not a git repository"
    fi
}

# Validate file exists
validate_file_exists() {
    local file="$1"
    local description="${2:-File}"
    if [ ! -f "$file" ]; then
        echo "Error: $description not found at: $file"
        return 1
    fi
    return 0
}

# Create checkpoint
create_checkpoint() {
    local checkpoint_name="${1:-auto-checkpoint}"
    local checkpoint_dir=".flow-state/checkpoints"
    mkdir -p "$checkpoint_dir"

    local timestamp=$(date -u +"%Y%m%d-%H%M%S")
    local checkpoint_file="$checkpoint_dir/${timestamp}-${checkpoint_name}.md"

    cp ".flow-state/current-session.md" "$checkpoint_file"
    echo "Checkpoint created: $checkpoint_file"
}

# List checkpoints
list_checkpoints() {
    local checkpoint_dir=".flow-state/checkpoints"
    if [ -d "$checkpoint_dir" ]; then
        ls -1t "$checkpoint_dir"/*.md 2>/dev/null | head -10
    fi
}

# Restore from checkpoint
restore_checkpoint() {
    local checkpoint="$1"
    local checkpoint_dir=".flow-state/checkpoints"

    if [ -f "$checkpoint_dir/$checkpoint" ]; then
        cp "$checkpoint_dir/$checkpoint" ".flow-state/current-session.md"
        echo "Restored from checkpoint: $checkpoint"
        return 0
    else
        echo "Error: Checkpoint not found: $checkpoint"
        return 1
    fi
}
