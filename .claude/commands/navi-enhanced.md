---
name: navi
description: Intelligent Navi workflow command with context-aware routing. Automatically suggests next steps, detects user intent, and provides smart shortcuts. Use with no args for interactive guidance or with natural language.
---

# Navi - Intelligent Workflow Navigator

You are handling the `/navi` command with enhanced intelligence for context-aware routing and suggestions.

## Step 1: Intelligent Intent Detection

Arguments passed: {{ARGS}}

### Parse User Intent
Analyze the arguments to understand what the user wants:

```bash
# Check for natural language patterns
intent=$(echo "{{ARGS}}" | tr '[:upper:]' '[:lower:]')

# Detect intent patterns
case "$intent" in
  *"start"*|*"begin"*|*"new"*)
    suggested_action="init"
    ;;
  *"feature"*|*"requirement"*|*"story"*)
    suggested_action="specify"
    ;;
  *"design"*|*"architect"*|*"technical"*)
    suggested_action="plan"
    ;;
  *"task"*|*"break"*|*"todo"*)
    suggested_action="tasks"
    ;;
  *"build"*|*"implement"*|*"code"*)
    suggested_action="implement"
    ;;
  *"check"*|*"validate"*|*"test"*)
    suggested_action="validate"
    ;;
  *"help"*|*"what"*|*"how"*)
    suggested_action="help"
    ;;
  *"status"*|*"progress"*|*"where"*)
    suggested_action="status"
    ;;
  *)
    suggested_action="auto"
    ;;
esac
```

## Step 2: Context Analysis

Analyze project context for intelligent suggestions:

```bash
source __specification__/scripts/routing.sh
source __specification__/scripts/config.sh

# Get current context
current_phase=$(detect_current_phase)
feature_dir=$(get_current_feature_dir)
last_modified=$(find __specification__/features -type f -name "*.md" -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)

# Analyze work patterns
if [ -f "__specification__/state/command-history.log" ]; then
  last_command=$(tail -1 __specification__/state/command-history.log)
  frequent_command=$(sort __specification__/state/command-history.log | uniq -c | sort -rn | head -1 | awk '{print $2}')
fi

# Check for incomplete work
incomplete_tasks=0
if [ -f "$feature_dir/tasks.md" ]; then
  incomplete_tasks=$(grep -c "\[ \]" "$feature_dir/tasks.md" 2>/dev/null || echo 0)
fi

# Smart suggestion based on context
if [ "$current_phase" = "unknown" ] || [ "$current_phase" = "init" ]; then
  smart_suggestion="init"
  suggestion_reason="No Navi configuration detected"
elif [ "$incomplete_tasks" -gt 0 ]; then
  smart_suggestion="implement"
  suggestion_reason="$incomplete_tasks tasks pending implementation"
elif [ "$current_phase" = "complete" ]; then
  smart_suggestion="validate"
  suggestion_reason="Feature complete, validation recommended"
else
  smart_suggestion=$(get_next_suggested_command)
  suggestion_reason="Natural workflow progression"
fi
```

## Step 3: Intelligent Routing

### If No Arguments (Interactive Mode)

Show intelligent, context-aware menu:

```javascript
// Build smart options based on context
const options = [];

// Always available
options.push({
  label: "Smart Continue ➡️",
  description: `${smart_suggestion}: ${suggestion_reason}`
});

// Phase-specific options
if (current_phase === "unknown" || current_phase === "init") {
  options.push({
    label: "Initialize Project 🚀",
    description: "Set up Navi in this directory"
  });
} else {
  // Show completed phases with checkmarks
  if (hasSpec) {
    options.push({
      label: "Specification ✅",
      description: "Edit existing specification"
    });
  } else {
    options.push({
      label: "Create Specification 📋",
      description: "Define feature requirements"
    });
  }

  // Add other phase options intelligently...
}

// Quick actions
options.push({
  label: "Quick Status 📊",
  description: "View current progress"
});

options.push({
  label: "Recent Work 🕐",
  description: `Continue: ${last_modified_file}`
});
```

Use AskUserQuestion with these intelligent options.

### If Arguments Provided

Route based on intelligent intent detection:

```bash
case "$suggested_action" in
  auto)
    # Use smart suggestion from context
    action="$smart_suggestion"
    echo "✨ Auto-detected intent: $action ($suggestion_reason)"
    ;;
  *)
    action="$suggested_action"
    echo "🎯 Understood: $action"
    ;;
esac

# Log command for pattern learning
echo "$(date +%Y-%m-%d-%H:%M:%S) $action" >> __specification__/state/command-history.log

# Execute with progress indicator
case "$action" in
  init)
    echo "🚀 Initializing Navi..."
    # Invoke navi:init skill
    ;;
  specify)
    echo "📋 Creating specification..."
    # Invoke navi:specify skill
    ;;
  plan)
    echo "🏗️ Designing technical plan..."
    # Invoke navi:plan skill
    ;;
  tasks)
    echo "📝 Breaking down into tasks..."
    # Invoke navi:tasks skill
    ;;
  implement)
    echo "⚡ Executing implementation..."
    # Show progress bar if available
    if [ "$incomplete_tasks" -gt 0 ]; then
      completed=$(grep -c "\[x\]" "$feature_dir/tasks.md")
      total=$((completed + incomplete_tasks))
      percent=$((completed * 100 / total))
      echo "Progress: [$completed/$total] ${percent}%"
    fi
    # Invoke navi:implement skill
    ;;
  validate)
    echo "✔️ Validating consistency..."
    # Invoke navi:analyze skill
    ;;
  status)
    # Enhanced status with visual indicators
    show_enhanced_status
    ;;
  help)
    # Context-aware help
    show_smart_help
    ;;
esac
```

## Step 4: Context-Aware Suggestions

After each command, suggest the next logical step:

```bash
suggest_next_action() {
  local last_action="$1"

  case "$last_action" in
    init)
      echo "💡 Next: /navi specify \"Your feature description\""
      ;;
    specify)
      echo "💡 Next: /navi plan (or just /navi to continue)"
      ;;
    plan)
      echo "💡 Next: /navi tasks"
      ;;
    tasks)
      echo "💡 Next: /navi implement"
      echo "    Tip: Use /navi implement --parallel for faster execution"
      ;;
    implement)
      if [ "$incomplete_tasks" -eq 0 ]; then
        echo "🎉 Implementation complete!"
        echo "💡 Next: /navi validate"
      else
        echo "💡 Continue: /navi (to resume implementation)"
      fi
      ;;
    validate)
      echo "✅ Validation complete!"
      echo "💡 Options:"
      echo "  - /navi specify \"Next feature\""
      echo "  - /navi status (review progress)"
      ;;
  esac

  # Show shortcuts learned from usage
  if [ -f "__specification__/state/command-history.log" ]; then
    echo ""
    echo "🔥 Your shortcuts:"
    echo "  - /navi → Auto-continues from where you left off"
    echo "  - /navi build → Jump straight to implementation"
    echo "  - /navi check → Run validation"
  fi
}
```

## Step 5: Enhanced Status Display

```bash
show_enhanced_status() {
  source __specification__/scripts/routing.sh

  echo ""
  echo "╔════════════════════════════════════════╗"
  echo "║         NAVI WORKFLOW STATUS           ║"
  echo "╚════════════════════════════════════════╝"
  echo ""

  # Visual phase indicator
  phases=("init" "specify" "plan" "tasks" "implement" "validate")
  current_index=0

  for i in "${!phases[@]}"; do
    if [ "${phases[$i]}" = "$current_phase" ]; then
      current_index=$i
      break
    fi
  done

  # Progress bar
  echo -n "Progress: ["
  for i in "${!phases[@]}"; do
    if [ $i -lt $current_index ]; then
      echo -n "✅"
    elif [ $i -eq $current_index ]; then
      echo -n "🔄"
    else
      echo -n "⏳"
    fi
  done
  echo "]"
  echo ""

  # Details
  echo "📍 Current Phase: $current_phase"

  if [ "$feature_dir" != "none" ]; then
    feature_name=$(grep "^# " "$feature_dir/spec.md" 2>/dev/null | head -1 | sed 's/# //')
    echo "🎯 Feature: $feature_name"

    # Task progress with visual bar
    if [ -f "$feature_dir/tasks.md" ]; then
      completed=$(grep -c "\[x\]" "$feature_dir/tasks.md")
      total=$(grep -c "\[ \]\|\[x\]" "$feature_dir/tasks.md")
      percent=$((completed * 100 / total))

      # Visual progress bar
      bar_length=30
      filled=$((percent * bar_length / 100))
      empty=$((bar_length - filled))

      echo -n "📊 Tasks: ["
      printf '█%.0s' $(seq 1 $filled)
      printf '░%.0s' $(seq 1 $empty)
      echo "] $completed/$total ($percent%)"
    fi
  fi

  echo ""
  echo "💡 Recommended: /navi $smart_suggestion"
  echo "   Reason: $suggestion_reason"
  echo ""

  # Recent activity
  if [ -f "__specification__/state/command-history.log" ]; then
    echo "🕐 Recent Activity:"
    tail -3 __specification__/state/command-history.log | while read -r line; do
      echo "   - $line"
    done
  fi
}
```

## Step 6: Smart Help System

```bash
show_smart_help() {
  echo ""
  echo "🧭 NAVI - Intelligent Workflow Navigator"
  echo ""
  echo "✨ SMART COMMANDS"
  echo "  /navi              → Auto-continue from current context"
  echo "  /navi [intent]     → Natural language understanding"
  echo ""
  echo "📋 WORKFLOW COMMANDS"
  echo "  /navi init         → Initialize project"
  echo "  /navi specify      → Create specification"
  echo "  /navi plan         → Design architecture"
  echo "  /navi tasks        → Break into tasks"
  echo "  /navi implement    → Execute implementation"
  echo "  /navi validate     → Check consistency"
  echo ""
  echo "⚡ SHORTCUTS (learned from your usage)"
  if [ "$frequent_command" ]; then
    echo "  Your most used: /navi $frequent_command"
  fi
  echo "  /navi build        → Jump to implementation"
  echo "  /navi check        → Run validation"
  echo "  /navi continue     → Resume last work"
  echo ""
  echo "🎯 CURRENT CONTEXT"
  echo "  Phase: $current_phase"
  echo "  Suggestion: /navi $smart_suggestion"
  echo "  Reason: $suggestion_reason"
  echo ""
  echo "💡 TIPS"
  echo "  • Just type '/navi' to auto-continue"
  echo "  • Use natural language: '/navi start new feature'"
  echo "  • Add --parallel for faster execution"
  echo "  • Check /navi status for progress"
}
```

## Key Improvements

### 1. Intent Detection
- Natural language understanding
- Pattern recognition from user input
- Auto-routing based on keywords

### 2. Context Awareness
- Tracks command history
- Learns user patterns
- Suggests based on workflow state

### 3. Smart Suggestions
- Analyzes incomplete work
- Recommends next logical step
- Provides reasoning for suggestions

### 4. Visual Feedback
- Progress bars and indicators
- Emoji-based status display
- Clear phase visualization

### 5. Adaptive Shortcuts
- Learns from usage patterns
- Provides personalized shortcuts
- Natural language aliases

This intelligent routing system reduces cognitive load by:
- Auto-detecting user intent
- Suggesting contextually relevant actions
- Learning from usage patterns
- Providing visual progress indicators
- Offering smart shortcuts based on behavior