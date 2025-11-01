#!/usr/bin/env bash
# Spec v3 - Unified `/spec` router

set -euo pipefail

SPEC_ROOT="${SPEC_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
SPEC_SKILLS_DIR="${SPEC_ROOT}/.claude/skills"
SPEC_STATE_DIR="${PWD}/.spec-state"
SPEC_MEMORY_DIR="${PWD}/.spec-memory"

# Track loaded skill assets to avoid re-printing them
declare -gA SPEC_LOADED_SKILLS=()

# Router state cache
STATE_JSON=""
STATE_PHASE="uninitialized"
STATE_FEATURE=""
STATE_PROGRESS=""
STATE_LOADED=false

LOAD_EXAMPLES=false
LOAD_REFERENCE=false

ensure_state_cache() {
    if [[ "$STATE_LOADED" == "true" ]]; then
        return
    fi

    if [[ -f "${SPEC_STATE_DIR}/session.json" ]]; then
        STATE_JSON=$(cat "${SPEC_STATE_DIR}/session.json")
        STATE_PHASE=$(jq -r '.activeFeature.phase // "uninitialized"' <<<"$STATE_JSON" 2>/dev/null || echo "uninitialized")
        [[ "$STATE_PHASE" == "null" ]] && STATE_PHASE="uninitialized"
        STATE_PHASE=${STATE_PHASE,,}
        STATE_FEATURE=$(jq -r '.activeFeature.name // ""' <<<"$STATE_JSON" 2>/dev/null || echo "")
        [[ "$STATE_FEATURE" == "null" ]] && STATE_FEATURE=""
        local progress
        progress=$(jq -r '.activeFeature.progress // ""' <<<"$STATE_JSON" 2>/dev/null || echo "")
        if [[ "$progress" != "" && "$progress" != "null" ]]; then
            STATE_PROGRESS="$progress"
        fi
    elif [[ -f "${SPEC_STATE_DIR}/current-session.md" ]]; then
        local phase_line
        phase_line=$(grep -m1 -E "\\*\\*Phase\\*\\*: " "${SPEC_STATE_DIR}/current-session.md" | sed 's/.*: //') || true
        STATE_PHASE=${phase_line,,}
        [[ -z "$STATE_PHASE" ]] && STATE_PHASE="uninitialized"

        local feature_line
        feature_line=$(grep -m1 -E "\\*\\*Feature\\*\\*: " "${SPEC_STATE_DIR}/current-session.md" | sed 's/.*: //') || true
        STATE_FEATURE=${feature_line:-}

        local progress_line
        progress_line=$(grep -m1 -E "Progress\\*\\*: " "${SPEC_STATE_DIR}/current-session.md" | sed 's/.*: //') || true
        STATE_PROGRESS=${progress_line:-}
    fi

    STATE_LOADED=true
}

detect_current_phase() {
    ensure_state_cache
    echo "${STATE_PHASE:-uninitialized}"
}

get_next_action() {
    local phase
    phase=$(detect_current_phase)

    case "$phase" in
        uninitialized|init|initialization)
            echo "init"
            ;;
        specification|specification_complete|generate|generated)
            echo "plan"
            ;;
        planning|plan|planning_complete)
            echo "tasks"
            ;;
        tasks|task|tasks_complete)
            echo "implement"
            ;;
        implementation|implement)
            echo "implement --continue"
            ;;
        completed|complete)
            echo "status"
            ;;
        *)
            echo "help"
            ;;
    esac
}

print_state_summary() {
    ensure_state_cache
    echo "📊 **Phase**: ${STATE_PHASE^}"
    if [[ -n "$STATE_FEATURE" ]]; then
        echo "🧩 **Active feature**: $STATE_FEATURE"
    else
        echo "🧩 **Active feature**: none"
    fi
    if [[ -n "$STATE_PROGRESS" ]]; then
        echo "📈 **Progress**: $STATE_PROGRESS"
    fi
    if [[ -d "$SPEC_MEMORY_DIR" ]]; then
        echo "🗂️ **Memory**: $SPEC_MEMORY_DIR"
    fi
}

load_skill() {
    local skill_name=$1
    local include_examples=${2:-false}
    local include_reference=${3:-false}

    local skill_dir="${SPEC_SKILLS_DIR}/${skill_name}"

    if [[ ! -d "$skill_dir" ]]; then
        echo "❌ Error: skill '${skill_name}' not found" >&2
        return 1
    fi

    if [[ ! -v SPEC_LOADED_SKILLS[$skill_name] ]]; then
        if [[ -f "${skill_dir}/SKILL.md" ]]; then
            echo ""
            cat "${skill_dir}/SKILL.md"
        fi
        SPEC_LOADED_SKILLS[$skill_name]=1
    fi

    if [[ "$include_examples" == "true" && -f "${skill_dir}/EXAMPLES.md" ]]; then
        echo ""
        echo "### Skill Examples"
        cat "${skill_dir}/EXAMPLES.md"
    fi

    if [[ "$include_reference" == "true" && -f "${skill_dir}/REFERENCE.md" ]]; then
        echo ""
        echo "### Technical Reference"
        cat "${skill_dir}/REFERENCE.md"
    fi
}

invoke_skill() {
    local skill_dir_name=$1
    shift || true
    local colon_name=${skill_dir_name/-/:}

    echo "## Spec Workflow Context"
    print_state_summary
    echo ""
    echo "### Invoking skill: ${colon_name}"
    if [[ $# -gt 0 ]]; then
        echo "Arguments: $*"
    fi

    load_skill "$skill_dir_name" "$LOAD_EXAMPLES" "$LOAD_REFERENCE"
}

show_status() {
    echo "## Current Spec Session"
    print_state_summary
}

show_interactive_menu() {
    local phase
    phase=$(detect_current_phase)

    echo ""
    echo "📟 Spec Workflow Hub"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_state_summary
    echo ""
    echo "What would you like to do?"

    local options=()
    case "$phase" in
        uninitialized)
            options=("Initialize Spec" "Exit")
            ;;
        specification|generate)
            options=("Continue to planning" "Update specification" "Clarify requirements" "Check status" "Exit")
            ;;
        planning|plan)
            options=("Continue to tasks" "Update plan" "Check status" "Exit")
            ;;
        tasks|task)
            options=("Begin implementation" "Update tasks" "Check status" "Exit")
            ;;
        implementation|implement)
            options=("Continue implementation" "Check status" "View dashboard" "Exit")
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
                    specification|generate) route_to_skill "plan" ;;
                    planning|plan) route_to_skill "tasks" ;;
                    tasks|task) route_to_skill "implement" ;;
                    implementation|implement) route_to_skill "implement" "--continue" ;;
                    *) route_to_skill "status" ;;
                esac
                break
                ;;
            2)
                case "$phase" in
                    specification|generate) route_to_skill "update" ;;
                    planning|plan) route_to_skill "plan" "--update" ;;
                    tasks|task) route_to_skill "tasks" "--update" ;;
                    implementation|implement) route_to_skill "status" ;;
                    *) route_to_skill "generate" ;;
                esac
                break
                ;;
            3)
                case "$phase" in
                    specification|generate) route_to_skill "clarify" ;;
                    implementation|implement) show_status ;;
                    *) route_to_skill "status" ;;
                esac
                break
                ;;
            4)
                show_status
                break
                ;;
            5|*)
                echo "Exiting..."
                break
                ;;
        esac
    done
}

show_contextual_help() {
    local phase
    phase=$(detect_current_phase)

    echo ""
    echo "🧭 Spec Command Help"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_state_summary
    echo ""
    echo "Common commands:"
    echo "  /spec init               # Initialize workflow"
    echo "  /spec \"Feature\"         # Generate specification from text"
    echo "  /spec plan               # Create technical plan"
    echo "  /spec tasks              # Break work into tasks"
    echo "  /spec implement          # Execute implementation"
    echo "  /spec status             # View cached state"
    echo "  /spec --interactive      # Guided menu"
    echo ""
    echo "Phase-aware next step: $(get_next_action)"
    echo ""
}

route_to_skill() {
    local subcommand=$1
    shift || true

    case "$subcommand" in
        init|initialize)
            invoke_skill "spec-init" "$@"
            ;;
        generate)
            invoke_skill "spec-generate" "$@"
            ;;
        plan|planning)
            invoke_skill "spec-plan" "$@"
            ;;
        tasks|task)
            invoke_skill "spec-tasks" "$@"
            ;;
        implement|impl|execute)
            invoke_skill "spec-implement" "$@"
            ;;
        clarify)
            invoke_skill "spec-clarify" "$@"
            ;;
        update)
            invoke_skill "spec-update" "$@"
            ;;
        blueprint)
            invoke_skill "spec-blueprint" "$@"
            ;;
        analyze|validate)
            invoke_skill "spec-analyze" "$@"
            ;;
        discover)
            invoke_skill "spec-discover" "$@"
            ;;
        orchestrate)
            invoke_skill "spec-orchestrate" "$@"
            ;;
        metrics|stats)
            invoke_skill "spec-metrics" "$@"
            ;;
        checklist)
            invoke_skill "spec-checklist" "$@"
            ;;
        status)
            show_status
            ;;
        help)
            show_contextual_help
            ;;
        --continue)
            invoke_skill "spec-implement" "$@"
            ;;
        *)
            if [[ -n "$subcommand" ]]; then
                local specification_text="$subcommand"
                if [[ $# -gt 0 ]]; then
                    specification_text="$subcommand $*"
                fi
                echo "→ Detected specification request"
                invoke_skill "spec-generate" "$specification_text"
            else
                show_contextual_help
            fi
            ;;
    esac
}

main() {
    local raw_args=("$@")
    local interactive=false
    local filtered_args=()

    for arg in "${raw_args[@]}"; do
        case "$arg" in
            --examples)
                LOAD_EXAMPLES=true
                ;;
            --reference)
                LOAD_REFERENCE=true
                ;;
            --interactive|-i)
                interactive=true
                ;;
            --help|-h)
                filtered_args+=("help")
                ;;
            *)
                filtered_args+=("$arg")
                ;;
        esac
    done

    if [[ "$interactive" == "true" ]]; then
        show_interactive_menu
        return
    fi

    if [[ ${#filtered_args[@]} -eq 0 ]]; then
        local next
        next=$(get_next_action)
        echo "→ Continuing workflow: $next"
        route_to_skill $next
        return
    fi

    route_to_skill "${filtered_args[@]}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
