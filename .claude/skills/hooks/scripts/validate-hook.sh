#!/bin/bash
# Hook Configuration Validator
# Validates Claude Code hook JSON syntax and security

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SETTINGS_FILE="${1:-.claude/settings.json}"

if [ ! -f "$SETTINGS_FILE" ]; then
    echo -e "${RED}✗ Settings file not found: $SETTINGS_FILE${NC}"
    exit 1
fi

echo "Validating hooks in: $SETTINGS_FILE"
echo ""

# 1. Validate JSON syntax
echo -n "1. JSON syntax... "
if jq empty "$SETTINGS_FILE" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ Invalid JSON${NC}"
    jq empty "$SETTINGS_FILE"
    exit 1
fi

# 2. Check if hooks exist
echo -n "2. Hooks configuration... "
if jq -e '.hooks' "$SETTINGS_FILE" >/dev/null 2>&1; then
    HOOK_COUNT=$(jq '[.hooks | to_entries[]] | length' "$SETTINGS_FILE")
    echo -e "${GREEN}✓ ($HOOK_COUNT event types configured)${NC}"
else
    echo -e "${YELLOW}⚠ No hooks configured${NC}"
    exit 0
fi

# 3. Validate hook structure
echo "3. Hook structure validation:"
EVENTS=$(jq -r '.hooks | keys[]' "$SETTINGS_FILE")

for EVENT in $EVENTS; do
    echo -n "   - $EVENT... "

    # Valid event types
    VALID_EVENTS=("PreToolUse" "PostToolUse" "UserPromptSubmit" "Notification" "Stop" "SubagentStop" "PreCompact" "SessionStart" "SessionEnd")
    if [[ " ${VALID_EVENTS[@]} " =~ " ${EVENT} " ]]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}⚠ Unknown event type${NC}"
    fi

    # Check hook array structure
    HOOK_ITEMS=$(jq -r ".hooks.$EVENT | length" "$SETTINGS_FILE")
    for ((i=0; i<HOOK_ITEMS; i++)); do
        # Check if hooks array exists
        if ! jq -e ".hooks.$EVENT[$i].hooks" "$SETTINGS_FILE" >/dev/null 2>&1; then
            echo -e "     ${RED}✗ Missing 'hooks' array at index $i${NC}"
            continue
        fi

        # Check command type
        COMMANDS=$(jq -r ".hooks.$EVENT[$i].hooks | length" "$SETTINGS_FILE")
        for ((j=0; j<COMMANDS; j++)); do
            TYPE=$(jq -r ".hooks.$EVENT[$i].hooks[$j].type // empty" "$SETTINGS_FILE")
            if [ "$TYPE" != "command" ] && [ -n "$TYPE" ]; then
                echo -e "     ${YELLOW}⚠ Unknown hook type: $TYPE${NC}"
            fi
        done
    done
done

# 4. Security checks
echo "4. Security validation:"

COMMANDS=$(jq -r '.. | select(.command?) | .command' "$SETTINGS_FILE")

# Check for common security issues
WARN_COUNT=0

# Unquoted variables
if echo "$COMMANDS" | grep -qE '\$[A-Za-z_][A-Za-z0-9_]*[^"]'; then
    echo -e "   ${YELLOW}⚠ Potential unquoted variables detected${NC}"
    ((WARN_COUNT++))
fi

# Eval usage
if echo "$COMMANDS" | grep -qE '\beval\b'; then
    echo -e "   ${RED}✗ DANGER: eval detected (extremely unsafe)${NC}"
    ((WARN_COUNT++))
fi

# Sensitive file access
if echo "$COMMANDS" | grep -qE '\.(env|secret|key|pem)'; then
    echo -e "   ${YELLOW}⚠ Sensitive file patterns detected${NC}"
    ((WARN_COUNT++))
fi

# Destructive commands without checks
if echo "$COMMANDS" | grep -qE 'rm -rf|DROP TABLE|--force' | grep -qvE 'grep|if|check'; then
    echo -e "   ${YELLOW}⚠ Destructive commands without apparent safeguards${NC}"
    ((WARN_COUNT++))
fi

if [ $WARN_COUNT -eq 0 ]; then
    echo -e "   ${GREEN}✓ No obvious security issues detected${NC}"
else
    echo -e "   ${YELLOW}⚠ $WARN_COUNT potential security concerns${NC}"
fi

# 5. Matcher validation (for PreToolUse/PostToolUse)
echo "5. Matcher patterns:"
for EVENT in PreToolUse PostToolUse; do
    if jq -e ".hooks.$EVENT" "$SETTINGS_FILE" >/dev/null 2>&1; then
        MATCHERS=$(jq -r ".hooks.$EVENT[].matcher // empty" "$SETTINGS_FILE" | sort -u)
        if [ -n "$MATCHERS" ]; then
            echo "   $EVENT matchers:"
            while IFS= read -r MATCHER; do
                echo -e "     - ${GREEN}$MATCHER${NC}"
            done <<< "$MATCHERS"
        fi
    fi
done

# 6. Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✓ Validation complete${NC}"
echo ""
echo "Next steps:"
echo "  1. Review security warnings above"
echo "  2. Test hooks with: claude --debug"
echo "  3. Check logs with: /hooks command"
echo ""
echo "To apply changes:"
echo "  - Hooks are automatically loaded from settings files"
echo "  - Restart Claude Code if hooks don't activate"
