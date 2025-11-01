#!/usr/bin/env bash

# Common Bash utilities for Specter scripts
# Eliminates duplication across bash scripts

# ============= Argument Parsing =============

# Parse common arguments (--json, --help)
parse_common_args() {
    local usage_text="$1"
    shift

    JSON_MODE=false
    SHOW_HELP=false
    VERBOSE=false
    ARGS=()

    for arg in "$@"; do
        case "$arg" in
            --json) JSON_MODE=true ;;
            --help|-h) SHOW_HELP=true ;;
            --verbose|-v) VERBOSE=true ;;
            *) ARGS+=("$arg") ;;
        esac
    done

    if $SHOW_HELP; then
        echo "$usage_text"
        exit 0
    fi

    export JSON_MODE VERBOSE ARGS
}

# ============= Repository Detection =============

# Get repository root
get_repo_root() {
    git rev-parse --show-toplevel 2>/dev/null || pwd
}

# Get current feature directory
get_current_feature() {
    local features_dir="$(get_repo_root)/features"
    if [ ! -d "$features_dir" ]; then
        echo "none"
        return
    fi

    # Find most recently modified feature
    find "$features_dir" -maxdepth 1 -type d -name "[0-9][0-9][0-9]-*" | \
        xargs -I{} stat -f "%m %N" {} 2>/dev/null | \
        sort -rn | head -1 | cut -d' ' -f2 | xargs basename
}

# Get current branch
get_current_branch() {
    git branch --show-current 2>/dev/null || echo "unknown"
}

# ============= Phase Detection =============

# Detect current workflow phase
detect_current_phase() {
    local feature_dir="$1"

    if [ ! -f ".specter/config.json" ]; then
        echo "uninitialized"
        return
    fi

    if [ -z "$feature_dir" ] || [ "$feature_dir" = "none" ]; then
        echo "initialized"
        return
    fi

    local feature_path="features/$feature_dir"

    if [ -f "$feature_path/tasks.md" ]; then
        echo "implementation"
    elif [ -f "$feature_path/plan.md" ]; then
        echo "planning"
    elif [ -f "$feature_path/spec.md" ]; then
        echo "specification"
    else
        echo "initialized"
    fi
}

# ============= Task Progress =============

# Count completed tasks
count_completed_tasks() {
    local tasks_file="$1"
    [ -f "$tasks_file" ] || echo "0" && return
    grep -c "\[x\]" "$tasks_file" 2>/dev/null || echo "0"
}

# Count total tasks
count_total_tasks() {
    local tasks_file="$1"
    [ -f "$tasks_file" ] || echo "0" && return
    grep -c "\[ \]\|\[x\]" "$tasks_file" 2>/dev/null || echo "0"
}

# Get task progress percentage
get_task_progress() {
    local tasks_file="$1"
    local completed=$(count_completed_tasks "$tasks_file")
    local total=$(count_total_tasks "$tasks_file")

    if [ "$total" -eq 0 ]; then
        echo "0"
    else
        echo "$((completed * 100 / total))"
    fi
}

# ============= Output Formatting =============

# Output in JSON or text format
output_result() {
    local key="$1"
    local value="$2"

    if $JSON_MODE; then
        printf '"%s":"%s"' "$key" "$value"
    else
        echo "$key: $value"
    fi
}

# Format status output
format_status() {
    local feature="$1"
    local phase="$2"
    local progress="$3"

    if $JSON_MODE; then
        cat <<EOF
{
  "feature": "$feature",
  "phase": "$phase",
  "progress": $progress
}
EOF
    else
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Feature: $feature"
        echo "Phase:   $phase"
        echo "Progress: ${progress}%"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    fi
}

# Print separator line
print_separator() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ============= Validation Functions =============

# Validate feature directory name
validate_feature_dir() {
    local dir="$1"
    [[ "$dir" =~ ^[0-9]{3}-[a-z][a-z0-9-]*$ ]]
}

# Validate branch name
validate_branch() {
    local branch="$1"
    [[ "$branch" =~ ^[0-9]{3}- ]] || [[ "$branch" =~ ^feature/[0-9]{3}- ]]
}

# Validate JIRA key
validate_jira_key() {
    local key="$1"
    [[ "$key" =~ ^[A-Z]{2,10}(-[0-9]+)?$ ]]
}

# ============= Error Handling =============

# Error with message
error_exit() {
    local message="$1"
    local exit_code="${2:-1}"

    if $JSON_MODE; then
        printf '{"error":"%s"}\n' "$message" >&2
    else
        echo "ERROR: $message" >&2
    fi

    exit "$exit_code"
}

# Warning message
warn() {
    local message="$1"

    if ! $JSON_MODE; then
        echo "WARNING: $message" >&2
    fi
}

# Debug output (only in verbose mode)
debug() {
    local message="$1"

    if $VERBOSE && ! $JSON_MODE; then
        echo "DEBUG: $message" >&2
    fi
}

# ============= File Operations =============

# Ensure directory exists
ensure_dir() {
    local dir="$1"
    [ -d "$dir" ] || mkdir -p "$dir"
}

# Read file or return default
read_file_or_default() {
    local file="$1"
    local default="$2"

    if [ -f "$file" ]; then
        cat "$file"
    else
        echo "$default"
    fi
}