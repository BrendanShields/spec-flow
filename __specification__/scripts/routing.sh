#!/bin/bash
# Flow Command Routing Utilities
# Handles command routing, phase detection, and menu rendering

# Detect current workflow phase
detect_current_phase() {
  local feature_dir=$(get_current_feature_dir)

  # If no feature directory, need to init or specify
  if [ -z "$feature_dir" ] || [ "$feature_dir" = "none" ]; then
    echo "init"
    return
  fi

  # Check for spec.md
  if [ ! -f "$feature_dir/spec.md" ]; then
    echo "specify"
    return
  fi

  # Check for plan.md
  if [ ! -f "$feature_dir/plan.md" ]; then
    echo "plan"
    return
  fi

  # Check for tasks.md
  if [ ! -f "$feature_dir/tasks.md" ]; then
    echo "tasks"
    return
  fi

  # Check task completion
  if [ -f "$feature_dir/tasks.md" ]; then
    local completed=$(grep -c "\\[x\\]" "$feature_dir/tasks.md" 2>/dev/null || echo 0)
    local total=$(grep -c "\\[ \\]\\|\\[x\\]" "$feature_dir/tasks.md" 2>/dev/null || echo 0)

    if [ "$total" -eq 0 ]; then
      echo "tasks"
      return
    fi

    if [ "$completed" -lt "$total" ]; then
      echo "implement"
      return
    else
      echo "complete"
      return
    fi
  fi

  echo "unknown"
}

# Get current feature directory
get_current_feature_dir() {
  # Check session state for current feature
  if [ -f "__specification__/state/current-session.md" ]; then
    local feature_id=$(grep "Feature ID:" "__specification__/state/current-session.md" | cut -d':' -f2 | tr -d ' ' | head -1)
    if [ -n "$feature_id" ] && [ "$feature_id" != "N/A" ]; then
      # Find feature directory
      local feature_dir=$(find __specification__/features -maxdepth 1 -name "*$feature_id*" -type d 2>/dev/null | head -1)
      if [ -n "$feature_dir" ]; then
        echo "$feature_dir"
        return
      fi
    fi
  fi

  # Fallback: get most recent feature directory
  local latest=$(ls -t __specification__/features 2>/dev/null | head -1)
  if [ -n "$latest" ]; then
    echo "__specification__/features/$latest"
  else
    echo "none"
  fi
}

# Get next suggested command based on current phase
get_next_suggested_command() {
  local phase=$(detect_current_phase)

  case "$phase" in
    init)
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
      echo "implement"
      ;;
    complete)
      echo "validate"
      ;;
    *)
      echo "status"
      ;;
  esac
}

# Route flow command to appropriate skill
# Usage: route_flow_command "plan" [args...]
route_flow_command() {
  local subcommand="$1"
  shift || true

  case "$subcommand" in
    init)
      # Invoke flow:init skill
      echo "Routing to flow:init skill..."
      # Skill invocation handled by command wrapper
      ;;
    specify)
      echo "Routing to flow:specify skill..."
      # Skill invocation handled by command wrapper
      ;;
    plan)
      echo "Routing to flow:plan skill..."
      # Skill invocation handled by command wrapper
      ;;
    tasks)
      echo "Routing to flow:tasks skill..."
      # Skill invocation handled by command wrapper
      ;;
    implement)
      echo "Routing to flow:implement skill..."
      # Skill invocation handled by command wrapper
      ;;
    validate)
      echo "Routing to flow:validate skill..."
      # Skill invocation handled by command wrapper
      ;;
    status)
      echo "Showing workflow status..."
      # Status command invocation
      ;;
    help)
      echo "Showing Flow help..."
      # Help command invocation
      ;;
    *)
      echo "Error: Unknown subcommand: $subcommand"
      echo ""
      echo "Available commands:"
      echo "  init      - Initialize Flow"
      echo "  specify   - Create feature specification"
      echo "  plan      - Create technical plan"
      echo "  tasks     - Break into implementation tasks"
      echo "  implement - Execute implementation"
      echo "  validate  - Check workflow consistency"
      echo "  status    - Show current progress"
      echo "  help      - Get context-aware help"
      echo ""
      echo "Run /flow for interactive menu"
      return 1
      ;;
  esac
}

# Render interactive flow menu
render_flow_menu() {
  local current_phase=$(detect_current_phase)
  local suggested=$(get_next_suggested_command)

  echo ""
  echo "What would you like to do?"
  echo ""
  echo "Workflow Commands:"

  # Init
  if [ "$current_phase" = "init" ]; then
    echo "  ➡️ init       - Initialize Flow (recommended next)"
  else
    echo "  ✅ init       - Initialize Flow (completed)"
  fi

  # Specify
  if [ "$current_phase" = "specify" ]; then
    echo "  ➡️ specify    - Create feature specification (recommended next)"
  elif [ "$current_phase" = "init" ]; then
    echo "  ⏳ specify    - Create feature specification (requires init)"
  else
    echo "  ✅ specify    - Create feature specification (completed)"
  fi

  # Plan
  if [ "$current_phase" = "plan" ]; then
    echo "  ➡️ plan       - Create technical plan (recommended next)"
  elif [ "$current_phase" = "init" ] || [ "$current_phase" = "specify" ]; then
    echo "  ⏳ plan       - Create technical plan (requires spec)"
  else
    echo "  ✅ plan       - Create technical plan (completed)"
  fi

  # Tasks
  if [ "$current_phase" = "tasks" ]; then
    echo "  ➡️ tasks      - Break into implementation tasks (recommended next)"
  elif [ "$current_phase" = "init" ] || [ "$current_phase" = "specify" ] || [ "$current_phase" = "plan" ]; then
    echo "  ⏳ tasks      - Break into implementation tasks (requires plan)"
  else
    echo "  ✅ tasks      - Break into implementation tasks (completed)"
  fi

  # Implement
  if [ "$current_phase" = "implement" ]; then
    echo "  ➡️ implement  - Execute implementation (recommended next)"
  elif [ "$current_phase" = "init" ] || [ "$current_phase" = "specify" ] || [ "$current_phase" = "plan" ] || [ "$current_phase" = "tasks" ]; then
    echo "  ⏳ implement  - Execute implementation (requires tasks)"
  else
    echo "  ✅ implement  - Execute implementation (completed)"
  fi

  echo ""
  echo "Utility Commands:"
  echo "  validate    - Check workflow consistency"
  echo "  status      - Show current progress"
  echo "  help        - Get context-aware help"
  echo ""

  # Show suggestion
  if [ -n "$suggested" ]; then
    echo "Recommended: /flow $suggested"
    echo ""
  fi
}

# Check if phase is complete
is_phase_complete() {
  local phase="$1"
  local current_phase=$(detect_current_phase)

  case "$phase" in
    init)
      [ "$current_phase" != "init" ]
      ;;
    specify)
      [ "$current_phase" != "init" ] && [ "$current_phase" != "specify" ]
      ;;
    plan)
      [ "$current_phase" != "init" ] && [ "$current_phase" != "specify" ] && [ "$current_phase" != "plan" ]
      ;;
    tasks)
      [ "$current_phase" = "implement" ] || [ "$current_phase" = "complete" ]
      ;;
    implement)
      [ "$current_phase" = "complete" ]
      ;;
    *)
      return 1
      ;;
  esac
}

# Export functions for use in other scripts
export -f detect_current_phase
export -f get_current_feature_dir
export -f get_next_suggested_command
export -f route_flow_command
export -f render_flow_menu
export -f is_phase_complete
