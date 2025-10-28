#!/bin/bash

# Navi Command Aliases
# Provides backward compatibility during transition from Flow to Navi

# Main command aliases
alias flow="echo '⚠️  DEPRECATED: Use /navi instead' && navi"
alias flow-init="echo '⚠️  DEPRECATED: Use /navi init instead' && navi init"
alias flow-specify="echo '⚠️  DEPRECATED: Use /navi spec instead' && navi spec"
alias flow-plan="echo '⚠️  DEPRECATED: Use /navi plan instead' && navi plan"
alias flow-tasks="echo '⚠️  DEPRECATED: Use /navi tasks instead' && navi tasks"
alias flow-implement="echo '⚠️  DEPRECATED: Use /navi implement instead' && navi implement"
alias flow-validate="echo '⚠️  DEPRECATED: Use /navi validate instead' && navi validate"
alias flow-status="echo '⚠️  DEPRECATED: Use /navi status instead' && navi status"
alias flow-help="echo '⚠️  DEPRECATED: Use /navi help instead' && navi help"

# Function to show deprecation notice
show_deprecation_notice() {
    echo "┌─────────────────────────────────────────────────────┐"
    echo "│                 DEPRECATION NOTICE                  │"
    echo "├─────────────────────────────────────────────────────┤"
    echo "│  Flow has been renamed to Navi                     │"
    echo "│                                                     │"
    echo "│  Old command → New command:                        │"
    echo "│  /flow       → /navi                               │"
    echo "│  /flow init  → /navi init                          │"
    echo "│  /flow spec  → /navi spec                          │"
    echo "│                                                     │"
    echo "│  Please update your workflows to use /navi         │"
    echo "└─────────────────────────────────────────────────────┘"
}

# Export the function so it's available
export -f show_deprecation_notice

# Show notice on first use
if [ -z "$NAVI_DEPRECATION_SHOWN" ]; then
    export NAVI_DEPRECATION_SHOWN=1
    # Uncomment to show notice on first use:
    # show_deprecation_notice
fi