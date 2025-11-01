#!/bin/bash
# Specter v3.0 - Unified Command Router
# This is the execution engine for /👻 command

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

SPECTER_ROOT="${SPECTER_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
SPECTER_SKILLS_DIR="${SPECTER_ROOT}/.claude/skills"
SPECTER_STATE_DIR="${PWD}/.specter-state"
SPECTER_MEMORY_DIR="${PWD}/.specter-memory"

# Track loaded skills
declare -gA SPECTER_LOADED_SKILLS

# ============================================================================
# LAZY LOADING
# ============================================================================

load_skill() {
    local skill_name=$1
    local load_examples=${2:-false}
    local load_reference=${3:-false}

    local skill_dir="${SPECTER_SKILLS_DIR}/${skill_name}"

    if [[ ! -d "$skill_dir" ]]; then
        echo "❌ Error: Skill '$skill_name' not found" >&2
        return 1
    fi

    # Load core skill (only once)
    if [[ ! -v SPECTER_LOADED_SKILLS[$skill_name] ]]; then
        if [[ -f "${skill_dir}/SKILL.md" ]]; then
            source "${skill_dir}/SKILL.md" 2>/dev/null || true
            SPECTER_LOADED_SKILLS[$skill_name]=1
        fi
    fi

    # Load examples if requested
    if [[ "$load_examples" == "true" && -f "${skill_dir}/EXAMPLES.md" ]]; then
        source "${skill_dir}/EXAMPLES.md" 2>/dev/null || true
    fi

    # Load reference if requested
    if [[ "$load_reference" == "true" && -f "${skill_dir}/REFERENCE.md" ]]; then
        source "${skill_dir}/REFERENCE.md" 2>/dev/null || true
    fi
}

# ============================================================================
# CONTEXT DETECTION
# ============================================================================

detect_current_phase() {
    if [[ ! -f "${SPECTER_STATE_DIR}/session.json" ]]; then
        echo "uninitialized"
        return
    fi

    jq -r '.activeFeature.phase // "uninitialized"' "${SPECTER_STATE_DIR}/session.json" 2>/dev/null || echo "uninitialized"
}

get_next_action() {
    local phase=$(detect_current_phase)

    case "$phase" in
        uninitialized)
            echo "init"
            ;;
        specification)
            echo "plan"
            ;;
        planning)
            echo "tasks"
            ;;
        tasks)
            echo "implement"
            ;;
        implementation)
            echo "implement --continue"
            ;;
        *)
            echo "help"
            ;;
    esac
}

# ============================================================================
# INTERACTIVE MODE
# ============================================================================

show_interactive_menu() {
    local phase=$(detect_current_phase)

    echo ""
    echo "📊 Specter Workflow - Current Phase: ${phase^}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "What would you like to do?"
    echo ""

    case "$phase" in
        uninitialized)
            options=("Initialize Specter" "Exit")
            ;;
        specification)
            options=("Continue to planning" "Update specification" "Clarify requirements" "Check status" "Exit")
            ;;
        planning)
            options=("Continue to tasks" "Update plan" "Check status" "Exit")
            ;;
        tasks)
            options=("Begin implementation" "Update tasks" "Check status" "Exit")
            ;;
        implementation)
            options=("Continue implementation" "Check status" "View team dashboard" "Exit")
            ;;
        *)
            options=("Check status" "Initialize new feature" "Exit")
            ;;
    esac

    PS3="Choose an option: "
    select opt in "${options[@]}"; do
        case "$REPLY" in
            1)
                case "$phase" in
                    uninitialized) route_to_skill "init" ;;
                    specification) route_to_skill "plan" ;;
                    planning) route_to_skill "tasks" ;;
                    tasks) route_to_skill "implement" ;;
                    implementation) route_to_skill "implement" "--continue" ;;
                    *) route_to_skill "status" ;;
                esac
                break
                ;;
            2)
                case "$phase" in
                    specification) route_to_skill "specify" "--update" ;;
                    planning) route_to_skill "plan" "--update" ;;
                    tasks) route_to_skill "tasks" "--update" ;;
                    implementation) route_to_skill "status" ;;
                    *) route_to_skill "specify" ;;
                esac
                break
                ;;
            3)
                case "$phase" in
                    specification) route_to_skill "clarify" ;;
                    *) route_to_skill "status" ;;
                esac
                break
                ;;
            4)
                route_to_skill "status"
                break
                ;;
            5|*)
                echo "Exiting..."
                exit 0
                ;;
        esac
    done
}

# ============================================================================
# ROUTING
# ============================================================================

route_to_skill() {
    local skill=$1
    shift
    local args="$@"

    # Map subcommands to skills
    case "$skill" in
        init|initialize)
            load_skill "specter-init"
            # Invoke specter:init skill
            ;;
        plan|planning)
            load_skill "specter-plan"
            # Invoke specter:plan skill
            ;;
        tasks|task)
            load_skill "specter-tasks"
            # Invoke specter:tasks skill
            ;;
        implement|impl|execute)
            load_skill "specter-implement"
            # Invoke specter:implement skill
            ;;
        clarify)
            load_skill "specter-clarify"
            # Invoke specter:clarify skill
            ;;
        analyze|validate)
            load_skill "specter-analyze"
            # Invoke specter:analyze skill
            ;;
        metrics|stats)
            load_skill "specter-metrics"
            # Invoke specter:metrics skill
            ;;
        team|status)
            show_team_status
            ;;
        assign)
            assign_task "$@"
            ;;
        lock)
            lock_feature "$@"
            ;;
        unlock)
            unlock_feature "$@"
            ;;
        master-spec)
            generate_master_spec "$@"
            ;;
        help|--help|-h)
            show_contextual_help
            ;;
        *)
            # Unknown subcommand - might be free text specification
            if [[ -n "$skill" ]]; then
                # Treat as specification text
                load_skill "specter-specify"
                # Invoke specter:specify skill with full text: "$skill $args"
            else
                show_contextual_help
            fi
            ;;
    esac
}

# ============================================================================
# BUILT-IN COMMANDS
# ============================================================================

show_team_status() {
    echo "📊 Specter Team Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Active locks
    if [[ -d "${SPECTER_STATE_DIR}/locks" ]]; then
        echo "🔒 Active Locks:"
        local has_locks=false
        for lock in "${SPECTER_STATE_DIR}/locks"/*.lock 2>/dev/null; do
            [[ -f "$lock" ]] || continue
            has_locks=true
            local feature=$(jq -r '.featureId' "$lock")
            local user=$(jq -r '.lockedBy' "$lock")
            local since=$(jq -r '.lockedAt' "$lock")
            echo "  - Feature $feature: $user (since $since)"
        done
        [[ "$has_locks" == "false" ]] && echo "  No active locks"
        echo ""
    fi

    # Task assignments
    if [[ -f "${SPECTER_STATE_DIR}/session.json" ]]; then
        echo "👥 Task Assignments:"
        jq -r '.tasks[]? | select(.assignedTo) | "  - \(.id): \(.description) (@\(.assignedTo))"' \
            "${SPECTER_STATE_DIR}/session.json" 2>/dev/null || echo "  No assignments"
        echo ""
    fi

    # Feature progress
    if [[ -f "${SPECTER_STATE_DIR}/session.json" ]]; then
        echo "📈 Feature Progress:"
        jq -r '.features[]? | "  - \(.id)-\(.name): \(.status) (\(.progress)%)"' \
            "${SPECTER_STATE_DIR}/session.json" 2>/dev/null || echo "  No features"
    fi
}

assign_task() {
    local user=$1
    local task_id=$2

    if [[ -z "$user" || -z "$task_id" ]]; then
        echo "Usage: /👻 assign @username T001"
        return 1
    fi

    echo "✅ Assigned $task_id to $user"
    # TODO: Update session.json with assignment
}

lock_feature() {
    local feature_id=$1
    echo "🔒 Locked feature $feature_id"
    # TODO: Create lock file
}

unlock_feature() {
    local feature_id=$1
    echo "🔓 Unlocked feature $feature_id"
    # TODO: Remove lock file
}

generate_master_spec() {
    local script="${SPECTER_ROOT}/scripts/generate-master-spec.sh"
    if [[ -f "$script" ]]; then
        bash "$script" "$@"
    else
        echo "❌ Error: Master spec generator not found" >&2
        return 1
    fi
}

show_contextual_help() {
    local phase=$(detect_current_phase)

    echo ""
    echo "👻 Specter v3.0 - Unified Workflow Command"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    case "$phase" in
        uninitialized)
            echo "Status: Not initialized"
            echo ""
            echo "Get started:"
            echo "  /👻 init                    # Initialize Specter"
            ;;
        specification)
            echo "Status: Specification phase"
            echo ""
            echo "Next steps:"
            echo "  /👻 plan                    # Create technical plan"
            echo "  /👻 clarify                 # Resolve ambiguities"
            echo "  /👻 update \"changes\"        # Modify specification"
            ;;
        planning)
            echo "Status: Planning phase"
            echo ""
            echo "Next steps:"
            echo "  /👻 tasks                   # Break into tasks"
            echo "  /👻 plan --update           # Modify plan"
            ;;
        tasks)
            echo "Status: Task breakdown complete"
            echo ""
            echo "Next steps:"
            echo "  /👻 implement               # Begin implementation"
            echo "  /👻 tasks --update          # Modify tasks"
            ;;
        implementation)
            echo "Status: Implementation in progress"
            echo ""
            echo "Next steps:"
            echo "  /👻 implement --continue    # Continue work"
            echo "  /👻 status                  # Check progress"
            echo "  /👻 team                    # View team status"
            ;;
    esac

    echo ""
    echo "Common commands:"
    echo "  /👻 \"Your feature\"           # Create specification"
    echo "  /👻                          # Context-aware continue"
    echo "  /👻 --interactive            # Interactive menu"
    echo "  /👻 status                   # Check status"
    echo "  /👻 team                     # Team dashboard"
    echo ""
    echo "Full documentation: /👻 --help --reference"
    echo ""
}

# ============================================================================
# MAIN ENTRY POINT
# ============================================================================

main() {
    local args=("$@")

    # Handle flags
    local load_examples=false
    local load_reference=false
    local interactive=false

    # Parse flags
    for arg in "${args[@]}"; do
        case "$arg" in
            --examples) load_examples=true ;;
            --reference) load_reference=true ;;
            --interactive|-i) interactive=true ;;
        esac
    done

    # Interactive mode
    if [[ "$interactive" == "true" ]]; then
        show_interactive_menu
        return
    fi

    # No arguments - context-aware continue
    if [[ ${#args[@]} -eq 0 ]]; then
        local next_action=$(get_next_action)
        echo "→ Continuing workflow: $next_action"
        route_to_skill $next_action
        return
    fi

    # Route based on first argument
    route_to_skill "${args[@]}"
}

# Only run main if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
