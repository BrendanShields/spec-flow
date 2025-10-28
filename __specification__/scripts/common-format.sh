#!/bin/bash

# Common Formatting Library
# Reusable formatting utilities to eliminate duplication

# Color codes (if terminal supports it)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    DIM='\033[2m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    BOLD=''
    DIM=''
    RESET=''
fi

# Status indicators
SUCCESS="✅"
FAILURE="❌"
WARNING="⚠️"
INFO="ℹ️"
PROGRESS="🔄"
COMPLETE="✓"
INCOMPLETE="○"
ARROW="→"
BULLET="•"

# Headers and sections
format_header() {
    local level="$1"
    local text="$2"
    local emoji="${3:-}"

    case "$level" in
        1)
            echo ""
            echo "${BOLD}${emoji:+$emoji }$text${RESET}"
            echo "$(printf '═%.0s' $(seq 1 ${#text}))"
            ;;
        2)
            echo ""
            echo "${BOLD}${emoji:+$emoji }$text${RESET}"
            echo "$(printf '─%.0s' $(seq 1 ${#text}))"
            ;;
        3)
            echo ""
            echo "${BOLD}${emoji:+$emoji }$text${RESET}"
            ;;
        *)
            echo "${emoji:+$emoji }$text"
            ;;
    esac
}

format_section() {
    local title="$1"
    echo ""
    echo "## $title"
    echo ""
}

# Status formatting
format_status() {
    local status="$1"
    local message="$2"

    case "$status" in
        success|ok|done)
            echo "${GREEN}${SUCCESS}${RESET} $message"
            ;;
        error|fail|failed)
            echo "${RED}${FAILURE}${RESET} $message"
            ;;
        warning|warn)
            echo "${YELLOW}${WARNING}${RESET} $message"
            ;;
        info)
            echo "${BLUE}${INFO}${RESET} $message"
            ;;
        progress|running)
            echo "${CYAN}${PROGRESS}${RESET} $message"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Progress indicators
format_progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-30}"

    if [ "$total" -eq 0 ]; then
        echo "[No items]"
        return
    fi

    local percent=$((current * 100 / total))
    local filled=$((percent * width / 100))
    local empty=$((width - filled))

    echo -n "["
    printf "${GREEN}█%.0s${RESET}" $(seq 1 $filled 2>/dev/null)
    printf "░%.0s" $(seq 1 $empty 2>/dev/null)
    echo "] $current/$total ($percent%)"
}

format_spinner() {
    local pid="$1"
    local message="${2:-Processing}"
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c] %s\r" "$spinstr" "$message"
        spinstr=$temp${spinstr%"$temp"}
        sleep 0.1
    done

    echo " ${SUCCESS} $message - Done"
}

# Lists and items
format_list() {
    local marker="${1:-$BULLET}"
    shift

    for item in "$@"; do
        echo "$marker $item"
    done
}

format_numbered_list() {
    local count=1

    for item in "$@"; do
        echo "$count. $item"
        ((count++))
    done
}

format_checkbox() {
    local checked="$1"
    local text="$2"

    if [ "$checked" = "true" ] || [ "$checked" = "1" ]; then
        echo "[x] $text"
    else
        echo "[ ] $text"
    fi
}

# Tables
format_table_header() {
    local columns=("$@")

    echo -n "| "
    for col in "${columns[@]}"; do
        printf "%-20s | " "$col"
    done
    echo ""

    echo -n "|"
    for col in "${columns[@]}"; do
        printf " %-20s |" "$(printf '─%.0s' $(seq 1 20))"
    done
    echo ""
}

format_table_row() {
    local values=("$@")

    echo -n "| "
    for val in "${values[@]}"; do
        printf "%-20s | " "$val"
    done
    echo ""
}

# Time formatting
format_duration() {
    local seconds="$1"

    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))

    if [ $hours -gt 0 ]; then
        printf "%dh %dm %ds" $hours $minutes $secs
    elif [ $minutes -gt 0 ]; then
        printf "%dm %ds" $minutes $secs
    else
        printf "%ds" $secs
    fi
}

format_timestamp() {
    local format="${1:-%Y-%m-%d %H:%M:%S}"
    date +"$format"
}

format_relative_time() {
    local timestamp="$1"
    local now=$(date +%s)
    local then=$(date -j -f "%Y-%m-%d %H:%M:%S" "$timestamp" +%s 2>/dev/null || echo "$timestamp")

    local diff=$((now - then))

    if [ $diff -lt 60 ]; then
        echo "just now"
    elif [ $diff -lt 3600 ]; then
        echo "$((diff / 60)) minutes ago"
    elif [ $diff -lt 86400 ]; then
        echo "$((diff / 3600)) hours ago"
    else
        echo "$((diff / 86400)) days ago"
    fi
}

# File size formatting
format_bytes() {
    local bytes="$1"

    if [ "$bytes" -lt 1024 ]; then
        echo "${bytes}B"
    elif [ "$bytes" -lt 1048576 ]; then
        echo "$((bytes / 1024))KB"
    elif [ "$bytes" -lt 1073741824 ]; then
        echo "$((bytes / 1048576))MB"
    else
        echo "$((bytes / 1073741824))GB"
    fi
}

# Code formatting
format_code() {
    local language="${1:-bash}"
    local code="$2"

    echo '```'"$language"
    echo "$code"
    echo '```'
}

format_inline_code() {
    local code="$1"
    echo "\`$code\`"
}

# Message boxes
format_box() {
    local title="$1"
    local content="$2"
    local width="${3:-60}"

    # Top border
    echo "╔$(printf '═%.0s' $(seq 1 $((width - 2))))╗"

    # Title
    if [ -n "$title" ]; then
        local padding=$(((width - ${#title} - 2) / 2))
        echo -n "║"
        printf ' %.0s' $(seq 1 $padding)
        echo -n "${BOLD}$title${RESET}"
        printf ' %.0s' $(seq 1 $((width - padding - ${#title} - 2)))
        echo "║"
        echo "╠$(printf '═%.0s' $(seq 1 $((width - 2))))╣"
    fi

    # Content (word wrap)
    echo "$content" | fold -w $((width - 4)) | while IFS= read -r line; do
        printf "║ %-$((width - 3))s║\n" "$line"
    done

    # Bottom border
    echo "╚$(printf '═%.0s' $(seq 1 $((width - 2))))╝"
}

format_alert() {
    local type="$1"
    local message="$2"

    case "$type" in
        success)
            echo "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
            echo "${GREEN}${SUCCESS} SUCCESS${RESET}"
            echo "$message"
            echo "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
            ;;
        error)
            echo "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
            echo "${RED}${FAILURE} ERROR${RESET}"
            echo "$message"
            echo "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
            ;;
        warning)
            echo "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
            echo "${YELLOW}${WARNING} WARNING${RESET}"
            echo "$message"
            echo "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
            ;;
        info)
            echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
            echo "${BLUE}${INFO} INFO${RESET}"
            echo "$message"
            echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
            ;;
    esac
}

# JSON formatting (simplified)
format_json_pretty() {
    local json="$1"

    if which python3 > /dev/null 2>&1; then
        echo "$json" | python3 -m json.tool
    elif which jq > /dev/null 2>&1; then
        echo "$json" | jq .
    else
        echo "$json"
    fi
}

# Markdown formatting
format_markdown_link() {
    local text="$1"
    local url="$2"
    echo "[$text]($url)"
}

format_markdown_image() {
    local alt="$1"
    local url="$2"
    echo "![$alt]($url)"
}

# Phase indicators
format_phase() {
    local phase="$1"
    local current_phase="$2"

    if [ "$phase" = "$current_phase" ]; then
        echo "${GREEN}${ARROW}${RESET} ${BOLD}$phase${RESET} (current)"
    elif [ "$phase" = "complete" ]; then
        echo "${GREEN}${COMPLETE}${RESET} $phase"
    else
        echo "${DIM}${INCOMPLETE} $phase${RESET}"
    fi
}

# Workflow status
format_workflow_status() {
    local phase="$1"
    local completed="$2"
    local total="$3"
    local feature="${4:-Unknown Feature}"

    format_box "NAVI WORKFLOW STATUS" "$(cat <<EOF
${BOLD}Feature:${RESET} $feature
${BOLD}Phase:${RESET} $phase
${BOLD}Progress:${RESET} $(format_progress_bar $completed $total 20)

${BOLD}Next Step:${RESET} /navi $(get_next_command $phase)
EOF
    )"
}

# Export functions if sourced
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    export -f format_header format_section
    export -f format_status format_progress_bar format_spinner
    export -f format_list format_numbered_list format_checkbox
    export -f format_table_header format_table_row
    export -f format_duration format_timestamp format_relative_time
    export -f format_bytes
    export -f format_code format_inline_code
    export -f format_box format_alert
    export -f format_json_pretty
    export -f format_markdown_link format_markdown_image
    export -f format_phase format_workflow_status
fi

# Test if run directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    echo "Testing Common Formatting..."

    format_header 1 "Test Header" "🧪"

    format_status success "Operation completed"
    format_status error "Operation failed"
    format_status warning "Check this"
    format_status info "For your information"

    echo ""
    echo "Progress Bar:"
    format_progress_bar 7 10

    echo ""
    echo "List:"
    format_list "$BULLET" "Item 1" "Item 2" "Item 3"

    echo ""
    echo "Checkboxes:"
    format_checkbox true "Completed task"
    format_checkbox false "Pending task"

    echo ""
    echo "Table:"
    format_table_header "Name" "Status" "Progress"
    format_table_row "Task 1" "Complete" "100%"
    format_table_row "Task 2" "In Progress" "60%"

    echo ""
    format_alert success "All tests passed!"
fi

# Helper to get next command (stub)
get_next_command() {
    case "$1" in
        init) echo "specify" ;;
        specify) echo "plan" ;;
        plan) echo "tasks" ;;
        tasks) echo "implement" ;;
        implement) echo "validate" ;;
        *) echo "status" ;;
    esac
}