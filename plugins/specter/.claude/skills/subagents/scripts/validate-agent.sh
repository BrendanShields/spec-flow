#!/bin/bash
# Subagent Configuration Validator
# Validates Claude Code subagent markdown files

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

AGENT_FILE="${1:-}"

if [ -z "$AGENT_FILE" ]; then
    echo -e "${RED}Usage: $0 <agent-file.md>${NC}"
    echo ""
    echo "Examples:"
    echo "  $0 .claude/agents/code-reviewer.md"
    echo "  $0 ~/.claude/agents/debugger.md"
    exit 1
fi

if [ ! -f "$AGENT_FILE" ]; then
    echo -e "${RED}✗ Agent file not found: $AGENT_FILE${NC}"
    exit 1
fi

echo -e "${BLUE}Validating subagent: $AGENT_FILE${NC}"
echo ""

ERRORS=0
WARNINGS=0

# Extract YAML frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$AGENT_FILE" | sed '1d;$d')

if [ -z "$FRONTMATTER" ]; then
    echo -e "${RED}✗ No YAML frontmatter found${NC}"
    echo "  Expected:"
    echo "  ---"
    echo "  name: agent-name"
    echo "  description: Purpose statement"
    echo "  ---"
    ((ERRORS++))
    exit 1
fi

# 1. Validate name field
echo -n "1. Name field... "
NAME=$(echo "$FRONTMATTER" | grep '^name:' | sed 's/name: *//' || echo "")
if [ -z "$NAME" ]; then
    echo -e "${RED}✗ Missing 'name' field${NC}"
    ((ERRORS++))
elif [[ ! "$NAME" =~ ^[a-z0-9-]+$ ]]; then
    echo -e "${YELLOW}⚠ Name should be lowercase with hyphens only: $NAME${NC}"
    ((WARNINGS++))
else
    echo -e "${GREEN}✓ $NAME${NC}"
fi

# 2. Validate description field
echo -n "2. Description field... "
DESCRIPTION=$(echo "$FRONTMATTER" | grep '^description:' | sed 's/description: *//' || echo "")
if [ -z "$DESCRIPTION" ]; then
    echo -e "${RED}✗ Missing 'description' field${NC}"
    ((ERRORS++))
else
    DESC_LENGTH=${#DESCRIPTION}
    if [ $DESC_LENGTH -lt 20 ]; then
        echo -e "${YELLOW}⚠ Description too short ($DESC_LENGTH chars). Be more specific.${NC}"
        ((WARNINGS++))
    elif [ $DESC_LENGTH -gt 500 ]; then
        echo -e "${YELLOW}⚠ Description too long ($DESC_LENGTH chars). Keep it concise.${NC}"
        ((WARNINGS++))
    else
        echo -e "${GREEN}✓ ($DESC_LENGTH chars)${NC}"
    fi
fi

# 3. Check for proactive trigger
echo -n "3. Proactive trigger... "
if echo "$DESCRIPTION" | grep -qi "use proactively"; then
    echo -e "${GREEN}✓ Found 'Use PROACTIVELY' trigger${NC}"
else
    echo -e "${YELLOW}⚠ No 'Use PROACTIVELY' - only explicit invocation${NC}"
fi

# 4. Validate tools field (optional)
echo -n "4. Tools field... "
TOOLS=$(echo "$FRONTMATTER" | grep '^tools:' | sed 's/tools: *//' || echo "")
if [ -z "$TOOLS" ]; then
    echo -e "${YELLOW}⚠ No tools specified - defaults to all tools${NC}"
else
    echo -e "${GREEN}✓ $TOOLS${NC}"

    # Check for common tool names
    VALID_TOOLS=("Read" "Write" "Edit" "Bash" "Grep" "Glob" "WebSearch" "WebFetch" "NotebookEdit")
    for TOOL in ${TOOLS//,/ }; do
        TOOL_TRIMMED=$(echo "$TOOL" | xargs)
        if [ "$TOOL_TRIMMED" = "*" ]; then
            echo -e "   ${YELLOW}⚠ Using '*' (all tools) - ensure this is intended${NC}"
            continue
        fi

        VALID=false
        for VALID_TOOL in "${VALID_TOOLS[@]}"; do
            if [ "$TOOL_TRIMMED" = "$VALID_TOOL" ]; then
                VALID=true
                break
            fi
        done

        if [ "$VALID" = false ]; then
            echo -e "   ${YELLOW}⚠ Unknown tool: $TOOL_TRIMMED${NC}"
        fi
    done
fi

# 5. Validate model field (optional)
echo -n "5. Model field... "
MODEL=$(echo "$FRONTMATTER" | grep '^model:' | sed 's/model: *//' || echo "")
if [ -z "$MODEL" ]; then
    echo -e "${YELLOW}⚠ No model specified - defaults to sonnet${NC}"
else
    case "$MODEL" in
        sonnet|opus|haiku)
            echo -e "${GREEN}✓ $MODEL${NC}"
            ;;
        *)
            echo -e "${YELLOW}⚠ Unknown model: $MODEL (expected: sonnet, opus, haiku)${NC}"
            ((WARNINGS++))
            ;;
    esac
fi

# 6. Check system prompt content
echo "6. System prompt content:"

# Count content after frontmatter
CONTENT_LINES=$(sed -n '/^---$/,/^---$/!p' "$AGENT_FILE" | sed '/^---$/d' | grep -v '^$' | wc -l | xargs)

if [ "$CONTENT_LINES" -lt 10 ]; then
    echo -e "   ${RED}✗ System prompt too short ($CONTENT_LINES lines)${NC}"
    echo -e "   ${YELLOW}   Add detailed instructions, workflow, and examples${NC}"
    ((ERRORS++))
elif [ "$CONTENT_LINES" -gt 200 ]; then
    echo -e "   ${YELLOW}⚠ System prompt very long ($CONTENT_LINES lines)${NC}"
    echo -e "   ${YELLOW}   Consider if it could be more concise${NC}"
    ((WARNINGS++))
else
    echo -e "   ${GREEN}✓ Good length ($CONTENT_LINES lines)${NC}"
fi

# Check for key sections
echo "   Checking for recommended sections:"

SECTIONS=(
    "Role|Your Role|Expertise|Your Expertise"
    "Workflow|Process|Steps"
    "Output Format|Format|Response Format"
)

for SECTION_PATTERN in "${SECTIONS[@]}"; do
    SECTION_NAME=$(echo "$SECTION_PATTERN" | cut -d'|' -f1)
    if grep -qE "## ($SECTION_PATTERN)" "$AGENT_FILE"; then
        echo -e "   ${GREEN}✓ Has $SECTION_NAME section${NC}"
    else
        echo -e "   ${YELLOW}⚠ Missing $SECTION_NAME section (recommended)${NC}"
        ((WARNINGS++))
    fi
done

# 7. Security checks
echo "7. Security validation:"

# Check if using Bash tool with proper guidance
if echo "$TOOLS" | grep -qi "bash"; then
    if grep -qi "validate\|sanitize\|security\|safe" "$AGENT_FILE"; then
        echo -e "   ${GREEN}✓ Bash tool with security guidance${NC}"
    else
        echo -e "   ${YELLOW}⚠ Uses Bash tool without apparent security guidance${NC}"
        ((WARNINGS++))
    fi
fi

# Check for examples in prompt
if grep -q '```' "$AGENT_FILE"; then
    echo -e "   ${GREEN}✓ Includes code examples${NC}"
else
    echo -e "   ${YELLOW}⚠ No code examples found (recommended for clarity)${NC}"
fi

# 8. File location check
echo -n "8. File location... "
if [[ "$AGENT_FILE" == *"/.claude/agents/"* ]]; then
    echo -e "${GREEN}✓ Project agent (.claude/agents/)${NC}"
elif [[ "$AGENT_FILE" == *"/.claude/agents/"* ]]; then
    echo -e "${GREEN}✓ User agent (~/.claude/agents/)${NC}"
else
    echo -e "${YELLOW}⚠ Non-standard location${NC}"
    echo "   Expected: .claude/agents/ (project) or ~/.claude/agents/ (user)"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ Validation complete - No issues found!${NC}"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Validation complete - $WARNINGS warnings${NC}"
else
    echo -e "${RED}✗ Validation failed - $ERRORS errors, $WARNINGS warnings${NC}"
fi

echo ""
echo "Next steps:"
echo "  1. Fix any errors above"
echo "  2. Consider addressing warnings"
echo "  3. Test subagent with: /agents command"
echo "  4. Try explicit invocation: 'Use the $NAME subagent to...'"

if [ $ERRORS -gt 0 ]; then
    exit 1
fi
