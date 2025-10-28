#!/bin/bash

# Navi Command Shortcuts and Aliases
# Natural language command interpretation and shortcuts

# Map natural language to commands
interpret_command() {
    local input="$1"
    local input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    local command=""

    # Direct shortcuts
    case "$input_lower" in
        # Quick actions
        "continue"|"c")
            command="auto"
            ;;
        "build"|"b")
            command="implement"
            ;;
        "check"|"validate"|"v")
            command="validate"
            ;;
        "s"|"stat")
            command="status"
            ;;
        "h"|"?")
            command="help"
            ;;

        # Natural language patterns
        *"start"*|*"begin"*|*"init"*)
            command="init"
            ;;
        *"specify"*|*"feature"*|*"requirement"*)
            command="specify"
            ;;
        *"plan"*|*"design"*|*"architect"*)
            command="plan"
            ;;
        *"task"*|*"break"*|*"todo"*)
            command="tasks"
            ;;
        *"implement"*|*"build"*|*"code"*|*"develop"*)
            command="implement"
            ;;
        *"test"*|*"validate"*|*"check"*)
            command="validate"
            ;;
        *"status"*|*"progress"*|*"where"*)
            command="status"
            ;;
        *"help"*|*"what"*|*"how"*)
            command="help"
            ;;

        # Action phrases
        "what's next"|"next")
            command="auto"
            ;;
        "show me"|"list")
            command="status"
            ;;
        "go"|"do it"|"run")
            command="auto"
            ;;

        # Empty or auto
        ""|"auto")
            command="auto"
            ;;

        *)
            # If no match, try to extract command from sentence
            if [[ "$input_lower" =~ (init|specify|plan|tasks|implement|validate|status|help) ]]; then
                command="${BASH_REMATCH[1]}"
            else
                command="auto"
            fi
            ;;
    esac

    echo "$command"
}

# Get shortcut description
get_shortcut_description() {
    local shortcut="$1"

    case "$shortcut" in
        "c"|"continue")
            echo "Continue from current phase"
            ;;
        "b"|"build")
            echo "Jump to implementation"
            ;;
        "v"|"validate"|"check")
            echo "Run validation checks"
            ;;
        "s"|"stat")
            echo "Show current status"
            ;;
        "h"|"?")
            echo "Get help"
            ;;
        *)
            echo "Run command"
            ;;
    esac
}

# List available shortcuts
list_shortcuts() {
    cat <<EOF
## ⚡ Navi Shortcuts

### Single Letter Shortcuts
- \`c\` → Continue from where you left off
- \`b\` → Build/implement
- \`v\` → Validate
- \`s\` → Status
- \`h\` → Help
- \`?\` → Help

### Word Shortcuts
- \`continue\` → Resume workflow
- \`build\` → Start implementation
- \`check\` → Run validation
- \`next\` → What's next?
- \`go\` → Auto-continue

### Natural Language
- "start new feature" → init/specify
- "build this" → implement
- "what's next" → auto-suggest
- "show progress" → status
- "check my work" → validate

### Smart Patterns
- Just \`/navi\` → Auto-continues based on context
- \`/navi [anything]\` → Interprets your intent
- Empty command → Smart suggestion

### Examples
\`\`\`bash
/navi c              # Continue working
/navi build          # Start implementation
/navi check          # Validate consistency
/navi what's next    # Get suggestion
/navi                # Auto-continue
\`\`\`

### Pro Tips
- Shortcuts work with /navi command
- Natural language is understood
- Context determines best action
- Learn your patterns over time
EOF
}

# Create command aliases file
create_aliases() {
    local aliases_file="__specification__/config/aliases.json"

    cat > "$aliases_file" <<EOF
{
  "shortcuts": {
    "c": "continue",
    "b": "build",
    "v": "validate",
    "s": "status",
    "h": "help",
    "?": "help"
  },
  "natural_language": {
    "continue": ["continue", "go", "next", "resume"],
    "build": ["build", "implement", "code", "develop"],
    "validate": ["validate", "check", "test", "verify"],
    "status": ["status", "progress", "where", "show"],
    "help": ["help", "what", "how", "?"]
  },
  "phrases": {
    "what's next": "auto",
    "start feature": "specify",
    "begin work": "init",
    "check work": "validate",
    "show me": "status",
    "do it": "auto",
    "go ahead": "auto"
  }
}
EOF

    echo "Created aliases configuration at $aliases_file"
}

# Learn user patterns
learn_pattern() {
    local user_input="$1"
    local resolved_command="$2"
    local patterns_file="__specification__/state/learned-patterns.txt"

    mkdir -p "$(dirname "$patterns_file")"

    # Record pattern
    echo "$(date +%Y-%m-%d-%H:%M:%S)|$user_input|$resolved_command" >> "$patterns_file"

    # Analyze patterns periodically
    local line_count=$(wc -l < "$patterns_file" 2>/dev/null || echo 0)

    if [ "$((line_count % 10))" -eq 0 ] && [ "$line_count" -gt 0 ]; then
        analyze_patterns
    fi
}

# Analyze learned patterns
analyze_patterns() {
    local patterns_file="__specification__/state/learned-patterns.txt"

    if [ ! -f "$patterns_file" ]; then
        return
    fi

    # Find most common shortcuts
    echo "## Learned Patterns"

    # Most used shortcuts
    echo "### Your Most Used Shortcuts"
    cut -d'|' -f2,3 "$patterns_file" | sort | uniq -c | sort -rn | head -5 | while read count pattern; do
        echo "  - $pattern (used $count times)"
    done

    # Suggest new shortcuts
    echo ""
    echo "### Suggested Personal Shortcuts"

    # Find repeated long commands
    grep -E ".{10,}" "$patterns_file" | cut -d'|' -f2 | sort | uniq -c | sort -rn | head -3 | while read count cmd; do
        if [ "$count" -gt 2 ]; then
            first_letter=$(echo "$cmd" | cut -c1)
            echo "  - Create shortcut '$first_letter' for \"$cmd\""
        fi
    done
}

# Interactive shortcut creator
create_personal_shortcut() {
    local shortcuts_file="__specification__/config/personal-shortcuts.json"

    echo "## Create Personal Shortcut"
    echo ""
    echo "What command do you use frequently?"
    read -p "> " frequent_command

    echo "What shortcut would you like? (1-3 characters)"
    read -p "> " shortcut

    # Add to personal shortcuts
    if [ ! -f "$shortcuts_file" ]; then
        echo "{}" > "$shortcuts_file"
    fi

    # Update JSON (simplified for bash)
    echo "Added: $shortcut → $frequent_command"
    echo "$shortcut|$frequent_command" >> "__specification__/config/personal-shortcuts.txt"
}

# Main execution
main() {
    local action="${1:-list}"
    shift

    case "$action" in
        interpret)
            input="$*"
            interpret_command "$input"
            ;;
        list)
            list_shortcuts
            ;;
        create)
            create_aliases
            ;;
        learn)
            user_input="$1"
            command="$2"
            learn_pattern "$user_input" "$command"
            ;;
        analyze)
            analyze_patterns
            ;;
        personal)
            create_personal_shortcut
            ;;
        test)
            # Test shortcut interpretation
            echo "Testing Shortcut System..."
            echo ""

            test_inputs=("c" "build" "what's next" "check my work" "start new feature" "")

            for input in "${test_inputs[@]}"; do
                result=$(interpret_command "$input")
                echo "Input: \"$input\" → Command: $result"
            done
            ;;
        *)
            echo "Usage: $0 {interpret|list|create|learn|analyze|personal|test} [args]"
            exit 1
            ;;
    esac
}

# Run if not sourced
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi