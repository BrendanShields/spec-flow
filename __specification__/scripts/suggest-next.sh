#!/bin/bash

# Context-Aware Suggestions System
# Provides intelligent next-step recommendations based on workflow state

# Source utilities
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/routing.sh"

# Configuration
HISTORY_FILE="__specification__/state/command-history.log"
METRICS_FILE="__specification__/state/usage-metrics.json"

# Analyze current context
analyze_context() {
    local current_phase=$(detect_current_phase)
    local feature_dir=$(get_current_feature_dir)
    local context=""

    # Check completion status
    local tasks_total=0
    local tasks_complete=0
    local has_spec=false
    local has_plan=false
    local has_tasks=false

    if [ "$feature_dir" != "none" ] && [ -d "$feature_dir" ]; then
        [ -f "$feature_dir/spec.md" ] && has_spec=true
        [ -f "$feature_dir/plan.md" ] && has_plan=true
        [ -f "$feature_dir/tasks.md" ] && has_tasks=true

        if [ -f "$feature_dir/tasks.md" ]; then
            tasks_total=$(grep -c "\[ \]\|\[x\]" "$feature_dir/tasks.md" 2>/dev/null || echo 0)
            tasks_complete=$(grep -c "\[x\]" "$feature_dir/tasks.md" 2>/dev/null || echo 0)
        fi
    fi

    # Build context object
    cat <<EOF
{
    "phase": "$current_phase",
    "feature_dir": "$feature_dir",
    "has_spec": $has_spec,
    "has_plan": $has_plan,
    "has_tasks": $has_tasks,
    "tasks_total": $tasks_total,
    "tasks_complete": $tasks_complete,
    "tasks_remaining": $((tasks_total - tasks_complete))
}
EOF
}

# Get intelligent suggestion
get_smart_suggestion() {
    local context=$(analyze_context)
    local phase=$(echo "$context" | grep '"phase"' | cut -d'"' -f4)
    local tasks_remaining=$(echo "$context" | grep '"tasks_remaining"' | grep -oE '[0-9]+')

    local suggestion=""
    local reason=""
    local confidence="high"

    case "$phase" in
        unknown|init)
            suggestion="init"
            reason="Initialize Navi to get started"
            ;;
        specify)
            suggestion="specify"
            reason="Create feature specification"
            ;;
        plan)
            suggestion="plan"
            reason="Design technical architecture"
            ;;
        tasks)
            suggestion="tasks"
            reason="Break down into implementation tasks"
            ;;
        implement)
            if [ "$tasks_remaining" -gt 0 ]; then
                suggestion="implement"
                reason="$tasks_remaining tasks pending completion"
            else
                suggestion="validate"
                reason="All tasks complete, validate consistency"
            fi
            ;;
        complete)
            suggestion="validate"
            reason="Feature complete, run validation"
            confidence="medium"
            ;;
        *)
            suggestion="status"
            reason="Check current workflow status"
            confidence="low"
            ;;
    esac

    # Output suggestion
    cat <<EOF
{
    "command": "$suggestion",
    "reason": "$reason",
    "confidence": "$confidence",
    "phase": "$phase"
}
EOF
}

# Analyze usage patterns
analyze_usage_patterns() {
    if [ ! -f "$HISTORY_FILE" ]; then
        echo "{}"
        return
    fi

    # Count command frequency
    local most_used=$(sort "$HISTORY_FILE" | uniq -c | sort -rn | head -1)
    local most_used_count=$(echo "$most_used" | awk '{print $1}')
    local most_used_cmd=$(echo "$most_used" | awk '{print $2}')

    # Get recent commands
    local recent_commands=$(tail -5 "$HISTORY_FILE" | tr '\n' ',' | sed 's/,$//')

    # Calculate patterns
    local morning_commands=$(grep "^[0-9]*-0[6-9]:" "$HISTORY_FILE" | wc -l)
    local afternoon_commands=$(grep "^[0-9]*-1[2-7]:" "$HISTORY_FILE" | wc -l)
    local evening_commands=$(grep "^[0-9]*-[12][0-9]:" "$HISTORY_FILE" | wc -l)

    cat <<EOF
{
    "most_used_command": "$most_used_cmd",
    "most_used_count": $most_used_count,
    "recent_commands": ["$recent_commands"],
    "time_patterns": {
        "morning": $morning_commands,
        "afternoon": $afternoon_commands,
        "evening": $evening_commands
    }
}
EOF
}

# Generate contextual tips
generate_tips() {
    local context=$(analyze_context)
    local usage=$(analyze_usage_patterns)
    local phase=$(echo "$context" | grep '"phase"' | cut -d'"' -f4)

    echo "## 💡 Contextual Tips"
    echo ""

    # Phase-specific tips
    case "$phase" in
        specify)
            echo "- Use clear user stories with acceptance criteria"
            echo "- Prioritize features as P1 (must), P2 (should), P3 (nice)"
            echo "- Include non-functional requirements"
            ;;
        plan)
            echo "- Research technology choices thoroughly"
            echo "- Document architecture decisions (ADRs)"
            echo "- Consider parallel execution opportunities"
            ;;
        implement)
            echo "- Tasks marked [P] can run in parallel"
            echo "- Use --parallel flag for faster execution"
            echo "- Check /navi status to monitor progress"
            ;;
    esac

    # Usage-based tips
    if [ -f "$HISTORY_FILE" ]; then
        local command_count=$(wc -l < "$HISTORY_FILE")
        if [ "$command_count" -lt 10 ]; then
            echo ""
            echo "🆕 **New User Tips:**"
            echo "- Just type '/navi' to auto-continue"
            echo "- Use '/navi help' for guidance"
            echo "- Natural language works: '/navi build the feature'"
        fi
    fi
}

# Suggest based on time of day
time_based_suggestion() {
    local hour=$(date +%H)
    local suggestion=""

    if [ "$hour" -ge 6 ] && [ "$hour" -lt 9 ]; then
        suggestion="Morning startup: Review status and plan the day"
    elif [ "$hour" -ge 9 ] && [ "$hour" -lt 12 ]; then
        suggestion="Focus time: Deep work on implementation"
    elif [ "$hour" -ge 12 ] && [ "$hour" -lt 13 ]; then
        suggestion="Pre-lunch: Quick validation check"
    elif [ "$hour" -ge 13 ] && [ "$hour" -lt 17 ]; then
        suggestion="Afternoon: Continue implementation"
    elif [ "$hour" -ge 17 ] && [ "$hour" -lt 18 ]; then
        suggestion="Wrap-up: Validate and commit progress"
    else
        suggestion="After hours: Light planning or documentation"
    fi

    echo "$suggestion"
}

# Generate suggestion message
format_suggestion() {
    local suggestion_json="$1"
    local command=$(echo "$suggestion_json" | grep '"command"' | cut -d'"' -f4)
    local reason=$(echo "$suggestion_json" | grep '"reason"' | cut -d'"' -f4)
    local confidence=$(echo "$suggestion_json" | grep '"confidence"' | cut -d'"' -f4)

    # Confidence indicator
    local indicator="💡"
    case "$confidence" in
        high) indicator="🎯" ;;
        medium) indicator="💡" ;;
        low) indicator="🤔" ;;
    esac

    echo ""
    echo "$indicator **Suggested Next Step**: \`/navi $command\`"
    echo "   _${reason}_"

    # Add time-based context
    local time_suggestion=$(time_based_suggestion)
    if [ -n "$time_suggestion" ]; then
        echo ""
        echo "⏰ $time_suggestion"
    fi
}

# Learn from user behavior
record_command() {
    local command="$1"
    local timestamp=$(date +"%Y-%m-%d-%H:%M:%S")

    mkdir -p "$(dirname "$HISTORY_FILE")"
    echo "$timestamp $command" >> "$HISTORY_FILE"

    # Update metrics
    if [ -f "$METRICS_FILE" ]; then
        # Update JSON metrics (simplified for bash)
        local total=$(grep -c "" "$HISTORY_FILE")
        echo "{\"total_commands\": $total, \"last_update\": \"$timestamp\"}" > "$METRICS_FILE"
    fi
}

# Predict next action based on patterns
predict_next() {
    local last_command="$1"
    local prediction=""

    # Common sequences
    case "$last_command" in
        init)
            prediction="specify"
            ;;
        specify)
            prediction="plan"
            ;;
        plan)
            prediction="tasks"
            ;;
        tasks)
            prediction="implement"
            ;;
        implement)
            prediction="validate"
            ;;
        validate)
            prediction="specify"  # New feature
            ;;
    esac

    echo "$prediction"
}

# Main execution
main() {
    local action="${1:-suggest}"
    shift

    case "$action" in
        suggest)
            # Get and format suggestion
            suggestion=$(get_smart_suggestion)
            format_suggestion "$suggestion"
            ;;
        analyze)
            # Show detailed context analysis
            echo "## Context Analysis"
            analyze_context | python3 -m json.tool 2>/dev/null || analyze_context
            echo ""
            echo "## Usage Patterns"
            analyze_usage_patterns | python3 -m json.tool 2>/dev/null || analyze_usage_patterns
            ;;
        tips)
            # Show contextual tips
            generate_tips
            ;;
        record)
            # Record command execution
            command="$1"
            record_command "$command"
            ;;
        predict)
            # Predict next action
            last="$1"
            predict_next "$last"
            ;;
        time)
            # Time-based suggestion
            time_based_suggestion
            ;;
        test)
            # Test all functions
            echo "Testing Suggestion System..."
            echo ""
            echo "1. Smart Suggestion:"
            get_smart_suggestion | python3 -m json.tool
            echo ""
            echo "2. Time-based:"
            time_based_suggestion
            echo ""
            echo "3. Tips:"
            generate_tips
            ;;
        *)
            echo "Usage: $0 {suggest|analyze|tips|record|predict|time|test} [args]"
            exit 1
            ;;
    esac
}

# Run if not sourced
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi