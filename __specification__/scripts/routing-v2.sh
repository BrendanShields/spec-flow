#!/bin/bash

# Navi Command Routing Utilities (v2)
# Updated to use common utilities for DRY principle

# Source common utilities
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/common-files.sh"
source "$SCRIPT_DIR/common-format.sh"
source "$SCRIPT_DIR/common-validate.sh" 2>/dev/null || true

# Detect current workflow phase
detect_current_phase() {
    local feature_dir=$(get_current_feature)

    # No feature directory
    if [ "$feature_dir" = "none" ]; then
        echo "init"
        return
    fi

    # Check workflow files
    if ! feature_exists "$feature_dir" "spec"; then
        echo "specify"
    elif ! feature_exists "$feature_dir" "plan"; then
        echo "plan"
    elif ! feature_exists "$feature_dir" "tasks"; then
        echo "tasks"
    else
        # Check task completion
        local tasks_file=$(get_feature_file "$feature_dir" "tasks")
        local completed=$(count_tasks "$tasks_file" "complete")
        local total=$(count_tasks "$tasks_file" "all")

        if [ "$total" -eq 0 ]; then
            echo "tasks"
        elif [ "$completed" -lt "$total" ]; then
            echo "implement"
        else
            echo "complete"
        fi
    fi
}

# Get current feature directory
get_current_feature_dir() {
    get_current_feature
}

# Render interactive menu
render_navi_menu() {
    local current_phase=$(detect_current_phase)
    local feature_dir=$(get_current_feature)

    format_header 1 "NAVI WORKFLOW MENU" "🧭"

    # Show current status
    if [ "$feature_dir" != "none" ]; then
        local tasks_file=$(get_feature_file "$feature_dir" "tasks")
        local completed=$(count_tasks "$tasks_file" "complete")
        local total=$(count_tasks "$tasks_file" "all")
        local feature_name=$(basename "$feature_dir")

        format_status info "Feature: $feature_name"
        format_status info "Phase: $current_phase"
        echo -n "Progress: "
        format_progress_bar "$completed" "$total"
    else
        format_status warning "No active feature"
    fi

    format_section "Available Commands"

    # Phase-aware menu items
    local phases=("init" "specify" "plan" "tasks" "implement" "validate")

    for phase in "${phases[@]}"; do
        format_phase_menu_item "$phase" "$current_phase"
    done

    format_section "Quick Actions"
    format_list "$ARROW" \
        "/navi status - Show detailed progress" \
        "/navi help - Get contextual help" \
        "/navi - Auto-continue from current phase"

    echo ""
    format_status success "Recommended: /navi $(get_next_suggested_command)"
}

# Format phase menu item
format_phase_menu_item() {
    local phase="$1"
    local current="$2"

    local status=""
    local description=""

    case "$phase" in
        init)
            description="Initialize Navi in project"
            ;;
        specify)
            description="Create feature specification"
            ;;
        plan)
            description="Design technical architecture"
            ;;
        tasks)
            description="Break down into tasks"
            ;;
        implement)
            description="Execute implementation"
            ;;
        validate)
            description="Check consistency"
            ;;
    esac

    # Determine status
    if [ "$phase" = "$current" ]; then
        format_status progress "/navi $phase - $description (current)"
    elif is_phase_complete "$phase" "$current"; then
        format_status success "/navi $phase - $description"
    else
        echo "${DIM}/navi $phase - $description${RESET}"
    fi
}

# Check if phase is complete
is_phase_complete() {
    local phase="$1"
    local current="$2"

    local phase_order=("init" "specify" "plan" "tasks" "implement" "validate")
    local phase_index=-1
    local current_index=-1

    for i in "${!phase_order[@]}"; do
        if [ "${phase_order[$i]}" = "$phase" ]; then
            phase_index=$i
        fi
        if [ "${phase_order[$i]}" = "$current" ]; then
            current_index=$i
        fi
    done

    [ $phase_index -lt $current_index ]
}

# Get next suggested command
get_next_suggested_command() {
    local current_phase=$(detect_current_phase)

    case "$current_phase" in
        init|unknown)
            echo "init"
            ;;
        specify)
            echo "specify"
            ;;
        plan)
            echo "plan"
            ;;
        tasks)
            echo "tasks"
            ;;
        implement)
            local feature_dir=$(get_current_feature)
            local tasks_file=$(get_feature_file "$feature_dir" "tasks")
            local remaining=$(count_tasks "$tasks_file" "incomplete")

            if [ "$remaining" -gt 0 ]; then
                echo "implement"
            else
                echo "validate"
            fi
            ;;
        complete)
            echo "validate"
            ;;
        *)
            echo "status"
            ;;
    esac
}

# Route command to appropriate skill
route_command() {
    local command="$1"
    shift
    local args="$@"

    case "$command" in
        init)
            echo "Invoking navi:init skill"
            ;;
        specify)
            echo "Invoking navi:specify skill with: $args"
            ;;
        plan)
            echo "Invoking navi:plan skill"
            ;;
        tasks)
            echo "Invoking navi:tasks skill"
            ;;
        implement)
            echo "Invoking navi:implement skill"
            ;;
        validate|analyze)
            echo "Invoking navi:analyze skill"
            ;;
        status)
            show_enhanced_status
            ;;
        help)
            show_contextual_help
            ;;
        *)
            format_status error "Unknown command: $command"
            echo "Try: /navi help"
            ;;
    esac
}

# Show enhanced status
show_enhanced_status() {
    local feature_dir=$(get_current_feature)
    local current_phase=$(detect_current_phase)

    if [ "$feature_dir" = "none" ]; then
        format_alert warning "No active feature. Run '/navi init' to get started."
        return
    fi

    local feature_name=$(basename "$feature_dir")
    local tasks_file=$(get_feature_file "$feature_dir" "tasks")
    local completed=$(count_tasks "$tasks_file" "complete")
    local total=$(count_tasks "$tasks_file" "all")

    format_workflow_status "$current_phase" "$completed" "$total" "$feature_name"

    # Show recent files
    format_section "Recent Files"
    find "$feature_dir" -type f -name "*.md" -exec ls -lt {} \; 2>/dev/null | head -3 | while read -r line; do
        echo "  $line"
    done
}

# Show contextual help
show_contextual_help() {
    local current_phase=$(detect_current_phase)

    format_header 1 "Navi Help" "🆘"

    format_section "Current Context"
    format_status info "Phase: $current_phase"
    format_status success "Next: /navi $(get_next_suggested_command)"

    format_section "Available Commands"
    format_list "$BULLET" \
        "/navi - Auto-continue workflow" \
        "/navi init - Initialize project" \
        "/navi specify - Create specification" \
        "/navi plan - Design architecture" \
        "/navi tasks - Break into tasks" \
        "/navi implement - Execute tasks" \
        "/navi validate - Check consistency" \
        "/navi status - Show progress" \
        "/navi help - This help"

    format_section "Shortcuts"
    format_list "$ARROW" \
        "c - Continue" \
        "b - Build/implement" \
        "v - Validate" \
        "s - Status" \
        "h - Help"
}

# Export functions
export -f detect_current_phase
export -f get_current_feature_dir
export -f render_navi_menu
export -f get_next_suggested_command
export -f route_command
export -f show_enhanced_status
export -f show_contextual_help

# Test if run directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    echo "Testing Routing v2 with Common Utilities..."

    # Test phase detection
    phase=$(detect_current_phase)
    format_status info "Current phase: $phase"

    # Test menu rendering
    render_navi_menu

    # Test routing
    echo ""
    route_command "status"
fi