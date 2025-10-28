---
name: flow
description: Unified Flow workflow command. Use with no args for interactive menu, or with subcommand (init, specify, plan, tasks, implement, validate, status, help). Provides phase-aware navigation through specification-driven development workflow.
---

# Flow - Unified Workflow Command

You are handling the `/flow` command. This provides unified access to all Flow workflow phases with interactive menu support.

## Step 1: Parse Arguments

Arguments passed to this command: {{ARGS}}

Extract the subcommand (first argument) if provided:
- If no arguments: Show interactive menu
- If subcommand provided: Route to appropriate skill

## Step 2: Detect Current Phase

Use bash to detect the current workflow phase:

```bash
source .flow/scripts/routing.sh
current_phase=$(detect_current_phase)
echo "Current phase: $current_phase"
```

The phase will be one of: `init`, `specify`, `plan`, `tasks`, `implement`, `complete`, `unknown`

## Step 3: Interactive Menu or Direct Routing

### If No Subcommand Provided

Check if interactive mode is enabled by reading the config:

```bash
source .flow/scripts/config.sh
if should_prompt_interactive; then
  echo "interactive_mode_enabled"
else
  echo "interactive_mode_disabled"
fi
```

**If interactive mode is ENABLED** (default):

Use the AskUserQuestion tool to show a phase-aware interactive menu. Build the options based on current phase:

**Phase-aware option descriptions**:
- **init phase**: Mark init as ➡️ (next), others as ⏳ (not ready) or greyed out
- **specify phase**: Mark init as ✅ (done), specify as ➡️ (next), others as ⏳
- **plan phase**: Mark init/specify as ✅, plan as ➡️, others as ⏳
- **tasks phase**: Mark init/specify/plan as ✅, tasks as ➡️, others as ⏳
- **implement phase**: Mark init/specify/plan/tasks as ✅, implement as ➡️
- **complete phase**: Mark all as ✅, suggest validate

**AskUserQuestion Structure**:
```json
{
  "questions": [{
    "question": "What would you like to do next?",
    "header": "Flow Action",
    "multiSelect": false,
    "options": [
      {
        "label": "Initialize",
        "description": "Set up Flow in this project (init)"
      },
      {
        "label": "Specify",
        "description": "Create feature specification (specify)"
      },
      {
        "label": "Plan",
        "description": "Design technical approach (plan)"
      },
      {
        "label": "Tasks",
        "description": "Break down into tasks (tasks)"
      },
      {
        "label": "Implement",
        "description": "Execute implementation (implement)"
      },
      {
        "label": "Validate",
        "description": "Check workflow consistency (validate)"
      },
      {
        "label": "Status",
        "description": "Show current progress (status)"
      },
      {
        "label": "Help",
        "description": "Get context-aware help (help)"
      }
    ]
  }]
}
```

After the user selects an option, automatically execute the corresponding skill:
- "Initialize" → invoke flow:init skill
- "Specify" → invoke flow:specify skill
- "Plan" → invoke flow:plan skill
- "Tasks" → invoke flow:tasks skill
- "Implement" → invoke flow:implement skill
- "Validate" → invoke flow:analyze skill
- "Status" → show status inline (see below)
- "Help" → show help inline (see below)
- "Other" → ask what command they want to run

**If interactive mode is DISABLED**:

Show text-based menu using bash:
```bash
source .flow/scripts/routing.sh
render_flow_menu
```

### If Subcommand Provided

Route directly to the appropriate skill based on the subcommand:

**Routing Table**:
- `init` → Invoke flow:init skill
- `specify` → Invoke flow:specify skill
- `plan` → Invoke flow:plan skill
- `tasks` → Invoke flow:tasks skill
- `implement` → Invoke flow:implement skill
- `validate` → Invoke flow:analyze skill
- `status` → Show status (inline)
- `help` → Show help (inline)

**Status Command** (inline, don't invoke skill):
```bash
source .flow/scripts/routing.sh
source .flow/scripts/config.sh

current_phase=$(detect_current_phase)
feature_dir=$(get_current_feature_dir)

echo ""
echo "## Current Workflow Status"
echo ""
echo "**Phase**: $current_phase"

if [ "$feature_dir" != "none" ]; then
  feature_id=$(basename "$feature_dir" | cut -d'-' -f1-2)
  echo "**Feature**: $feature_id"

  # Count tasks if tasks.md exists
  if [ -f "$feature_dir/tasks.md" ]; then
    completed=$(grep -c "\[x\]" "$feature_dir/tasks.md" 2>/dev/null || echo 0)
    total=$(grep -c "\[ \]\|\[x\]" "$feature_dir/tasks.md" 2>/dev/null || echo 0)
    echo "**Progress**: $completed/$total tasks"
  fi
else
  echo "**Feature**: None (run /flow init to get started)"
fi

echo ""
next_cmd=$(get_next_suggested_command)
echo "**Recommended next**: /flow $next_cmd"
echo ""
```

**Help Command** (inline, don't invoke skill):
```bash
source .flow/scripts/routing.sh

current_phase=$(detect_current_phase)

echo ""
echo "## Flow Help"
echo ""
echo "**Current Phase**: $current_phase"
echo ""

case "$current_phase" in
  init)
    echo "**Next Step**: Initialize Flow"
    echo "Run: /flow init"
    echo ""
    echo "This will set up the Flow directory structure and configuration."
    ;;
  specify)
    echo "**Next Step**: Create Feature Specification"
    echo "Run: /flow specify \"Feature description\""
    echo ""
    echo "This creates a specification with prioritized user stories."
    ;;
  plan)
    echo "**Next Step**: Create Technical Plan"
    echo "Run: /flow plan"
    echo ""
    echo "This designs the technical architecture and implementation approach."
    ;;
  tasks)
    echo "**Next Step**: Break Down into Tasks"
    echo "Run: /flow tasks"
    echo ""
    echo "This converts the plan into actionable implementation tasks."
    ;;
  implement)
    echo "**Next Step**: Execute Implementation"
    echo "Run: /flow implement"
    echo ""
    echo "This executes tasks autonomously with progress tracking."
    ;;
  complete)
    echo "**Feature Complete!**"
    echo "Run: /flow validate to check consistency"
    echo "Or: /flow specify \"Next feature\" to start another"
    ;;
esac

echo ""
echo "**All Commands**:"
echo "- /flow          - Show interactive menu"
echo "- /flow init     - Initialize Flow"
echo "- /flow specify  - Create specification"
echo "- /flow plan     - Create technical plan"
echo "- /flow tasks    - Break into tasks"
echo "- /flow implement - Execute implementation"
echo "- /flow validate - Check consistency"
echo "- /flow status   - Show progress"
echo "- /flow help     - Show this help"
echo ""
```

## Backward Compatibility

- CLI arguments automatically skip interactive prompts
- Legacy `/flow-*` commands still work
- Text-based menu available via config: `preferences.interactive_mode: false`

## Examples

**Interactive menu** (default):
```
User: /flow
Claude: Shows AskUserQuestion with phase-aware options
User: Selects "Specify"
Claude: Automatically invokes flow:specify skill
```

**Direct execution**:
```
User: /flow specify "User authentication"
Claude: Directly invokes flow:specify skill with argument
```

**Status check**:
```
User: /flow status
Claude: Shows current phase, feature, and progress inline
```

## Notes

- Interactive mode is enabled by default (config: `preferences.interactive_mode: true`)
- Disable with: `--no-interactive` flag or config setting
- AskUserQuestion provides visual selection interface
- Selected option automatically executes the corresponding skill
- Phase detection is automatic based on file existence
