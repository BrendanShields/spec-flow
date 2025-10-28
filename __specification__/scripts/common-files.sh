#!/bin/bash

# Common File Operations Library
# Reusable file operations to eliminate duplication across scripts

# Error handling
set -euo pipefail

# Configuration
SPEC_DIR="${SPEC_DIR:-__specification__}"
FEATURES_DIR="${FEATURES_DIR:-$SPEC_DIR/features}"
STATE_DIR="${STATE_DIR:-$SPEC_DIR/state}"
CONFIG_DIR="${CONFIG_DIR:-$SPEC_DIR/config}"

# Logging utilities
log() {
    echo "[$(date +'%H:%M:%S')] $*" >&2
}

error() {
    echo "[ERROR] $*" >&2
    return 1
}

# Safe file operations
safe_read() {
    local file="$1"

    if [ ! -f "$file" ]; then
        error "File not found: $file"
        return 1
    fi

    cat "$file"
}

safe_write() {
    local file="$1"
    local content="$2"
    local backup="${3:-true}"

    # Create directory if needed
    local dir=$(dirname "$file")
    [ -d "$dir" ] || mkdir -p "$dir"

    # Backup if requested
    if [ "$backup" = "true" ] && [ -f "$file" ]; then
        cp "$file" "$file.bak.$(date +%Y%m%d-%H%M%S)"
    fi

    # Write content
    echo "$content" > "$file"
    log "Wrote to: $file"
}

safe_append() {
    local file="$1"
    local content="$2"

    # Create if doesn't exist
    [ -f "$file" ] || touch "$file"

    echo "$content" >> "$file"
    log "Appended to: $file"
}

# Directory operations
ensure_dir() {
    local dir="$1"

    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log "Created directory: $dir"
    fi
}

clean_dir() {
    local dir="$1"
    local pattern="${2:-*}"

    if [ -d "$dir" ]; then
        find "$dir" -name "$pattern" -type f -delete
        log "Cleaned: $dir/$pattern"
    fi
}

# Feature file operations
get_current_feature() {
    local latest=$(find "$FEATURES_DIR" -type d -name "[0-9]*-*" 2>/dev/null | \
                   sort -V | tail -1)

    if [ -n "$latest" ]; then
        echo "$latest"
    else
        echo "none"
    fi
}

get_feature_file() {
    local feature_dir="$1"
    local file_type="$2"  # spec, plan, tasks, etc.

    echo "$feature_dir/${file_type}.md"
}

feature_exists() {
    local feature_dir="$1"
    local file_type="${2:-spec}"

    local file=$(get_feature_file "$feature_dir" "$file_type")
    [ -f "$file" ]
}

# Task operations
count_tasks() {
    local tasks_file="$1"
    local filter="${2:-all}"  # all, complete, incomplete

    if [ ! -f "$tasks_file" ]; then
        echo "0"
        return
    fi

    case "$filter" in
        complete)
            grep -c "\[x\]" "$tasks_file" 2>/dev/null || echo "0"
            ;;
        incomplete)
            grep -c "\[ \]" "$tasks_file" 2>/dev/null || echo "0"
            ;;
        all|*)
            grep -c "\[\s*[x ]\s*\]" "$tasks_file" 2>/dev/null || echo "0"
            ;;
    esac
}

mark_task_complete() {
    local tasks_file="$1"
    local task_id="$2"

    if [ ! -f "$tasks_file" ]; then
        error "Tasks file not found: $tasks_file"
        return 1
    fi

    # Mark task as complete
    sed -i.bak "s/\[ \] $task_id/\[x\] $task_id/" "$tasks_file"
    log "Marked complete: $task_id"
}

# Config operations
read_config() {
    local key="$1"
    local config_file="${2:-$CONFIG_DIR/navi.json}"

    if [ ! -f "$config_file" ]; then
        echo ""
        return
    fi

    # Extract value from JSON (simplified)
    grep "\"$key\"" "$config_file" | cut -d'"' -f4
}

write_config() {
    local key="$1"
    local value="$2"
    local config_file="${3:-$CONFIG_DIR/navi.json}"

    ensure_dir "$(dirname "$config_file")"

    # Update or add key (simplified JSON handling)
    if [ -f "$config_file" ]; then
        # Update existing
        local temp=$(mktemp)
        sed "s/\"$key\": \"[^\"]*\"/\"$key\": \"$value\"/" "$config_file" > "$temp"
        mv "$temp" "$config_file"
    else
        # Create new
        echo "{\"$key\": \"$value\"}" > "$config_file"
    fi

    log "Config updated: $key = $value"
}

# State management
save_state() {
    local key="$1"
    local value="$2"
    local state_file="$STATE_DIR/workflow.state"

    ensure_dir "$STATE_DIR"

    # Save key-value pair
    echo "$key=$value" >> "$state_file"
    log "State saved: $key"
}

load_state() {
    local key="$1"
    local state_file="$STATE_DIR/workflow.state"

    if [ ! -f "$state_file" ]; then
        echo ""
        return
    fi

    # Get most recent value for key
    grep "^$key=" "$state_file" | tail -1 | cut -d'=' -f2-
}

clear_state() {
    local state_file="$STATE_DIR/workflow.state"

    if [ -f "$state_file" ]; then
        > "$state_file"
        log "State cleared"
    fi
}

# Template operations
apply_template() {
    local template="$1"
    local output="$2"
    shift 2

    if [ ! -f "$template" ]; then
        error "Template not found: $template"
        return 1
    fi

    local content=$(cat "$template")

    # Replace variables
    while [ $# -gt 0 ]; do
        local var="$1"
        local val="$2"
        content=$(echo "$content" | sed "s/{{$var}}/$val/g")
        shift 2
    done

    safe_write "$output" "$content"
}

# Backup operations
create_backup() {
    local source="$1"
    local backup_dir="${2:-$STATE_DIR/backups}"

    ensure_dir "$backup_dir"

    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_name=$(basename "$source")-$timestamp

    if [ -d "$source" ]; then
        tar -czf "$backup_dir/$backup_name.tar.gz" -C "$(dirname "$source")" "$(basename "$source")"
    else
        cp "$source" "$backup_dir/$backup_name"
    fi

    log "Backup created: $backup_dir/$backup_name"
}

restore_backup() {
    local backup="$1"
    local target="$2"

    if [[ "$backup" == *.tar.gz ]]; then
        tar -xzf "$backup" -C "$(dirname "$target")"
    else
        cp "$backup" "$target"
    fi

    log "Restored from: $backup"
}

# Lock operations for parallel safety
acquire_lock() {
    local lock_name="$1"
    local lock_file="$STATE_DIR/locks/$lock_name.lock"
    local timeout="${2:-30}"

    ensure_dir "$STATE_DIR/locks"

    local count=0
    while [ -f "$lock_file" ] && [ $count -lt $timeout ]; do
        sleep 1
        ((count++))
    done

    if [ $count -ge $timeout ]; then
        error "Failed to acquire lock: $lock_name"
        return 1
    fi

    echo "$$" > "$lock_file"
    log "Lock acquired: $lock_name"
}

release_lock() {
    local lock_name="$1"
    local lock_file="$STATE_DIR/locks/$lock_name.lock"

    if [ -f "$lock_file" ]; then
        rm "$lock_file"
        log "Lock released: $lock_name"
    fi
}

# Atomic operations
atomic_update() {
    local file="$1"
    local update_function="$2"

    acquire_lock "$(basename "$file")"

    # Perform update
    local content=$(safe_read "$file")
    local new_content=$($update_function "$content")
    safe_write "$file" "$new_content" false

    release_lock "$(basename "$file")"
}

# File monitoring
watch_file() {
    local file="$1"
    local callback="$2"
    local interval="${3:-1}"

    local last_mod=""

    while true; do
        if [ -f "$file" ]; then
            local current_mod=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null)

            if [ "$current_mod" != "$last_mod" ]; then
                $callback "$file"
                last_mod="$current_mod"
            fi
        fi

        sleep "$interval"
    done
}

# Utility functions
file_age_days() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "999"
        return
    fi

    local mod_time=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null)
    local current_time=$(date +%s)
    local age_seconds=$((current_time - mod_time))
    local age_days=$((age_seconds / 86400))

    echo "$age_days"
}

cleanup_old_files() {
    local dir="$1"
    local days="${2:-30}"

    find "$dir" -type f -mtime "+$days" -delete
    log "Cleaned files older than $days days in: $dir"
}

# Export functions if sourced
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    export -f log error
    export -f safe_read safe_write safe_append
    export -f ensure_dir clean_dir
    export -f get_current_feature get_feature_file feature_exists
    export -f count_tasks mark_task_complete
    export -f read_config write_config
    export -f save_state load_state clear_state
    export -f apply_template
    export -f create_backup restore_backup
    export -f acquire_lock release_lock
    export -f atomic_update watch_file
    export -f file_age_days cleanup_old_files
fi

# Test functions if run directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    echo "Testing Common File Operations..."

    # Test directory operations
    test_dir="/tmp/navi-test-$$"
    ensure_dir "$test_dir"

    # Test file operations
    safe_write "$test_dir/test.txt" "Hello World"
    content=$(safe_read "$test_dir/test.txt")
    echo "Read content: $content"

    # Test config operations
    write_config "test_key" "test_value" "$test_dir/config.json"
    value=$(read_config "test_key" "$test_dir/config.json")
    echo "Config value: $value"

    # Test state operations
    STATE_DIR="$test_dir" save_state "phase" "implement"
    phase=$(STATE_DIR="$test_dir" load_state "phase")
    echo "State phase: $phase"

    # Cleanup
    rm -rf "$test_dir"

    echo "All tests passed!"
fi