#!/bin/bash
# Slash Command Validator
# Validates Claude Code slash command markdown files

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

COMMAND_FILE="${1:-}"

if [ -z "$COMMAND_FILE" ]; then
    echo -e "${RED}Usage: $0 <command-file.md>${NC}"
    echo ""
    echo "Examples:"
    echo "  $0 .claude/commands/commit.md"
    echo "  $0 ~/.claude/commands/review-pr.md"
    exit 1
fi

if [ ! -f "$COMMAND_FILE" ]; then
    echo -e "${RED}✗ Command file not found: $COMMAND_FILE${NC}"
    exit 1
fi

# Extract command name from filename
COMMAND_NAME=$(basename "$COMMAND_FILE" .md)

echo -e "${BLUE}Validating slash command: /$COMMAND_NAME${NC}"
echo -e "${BLUE}File: $COMMAND_FILE${NC}"
echo ""

ERRORS=0
WARNINGS=0

# 1. Validate filename
echo -n "1. Filename format... "
if [[ ! "$COMMAND_NAME" =~ ^[a-z0-9-]+$ ]]; then
    echo -e "${RED}✗ Invalid name: $COMMAND_NAME${NC}"
    echo "   Names must be lowercase with hyphens only"
    ((ERRORS++))
else
    echo -e "${GREEN}✓ $COMMAND_NAME${NC}"
fi

if [[ "$COMMAND_FILE" != *.md ]]; then
    echo -e "${RED}✗ File must have .md extension${NC}"
    ((ERRORS++))
fi

# 2. Check for frontmatter (optional but recommended)
echo -n "2. YAML frontmatter... "
if grep -q '^---$' "$COMMAND_FILE"; then
    FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$COMMAND_FILE" | sed '1d;$d')
    echo -e "${GREEN}✓ Found${NC}"

    # Validate frontmatter fields
    echo "   Checking frontmatter fields:"

    # Description
    if echo "$FRONTMATTER" | grep -q '^description:'; then
        DESCRIPTION=$(echo "$FRONTMATTER" | grep '^description:' | sed 's/description: *//')
        DESC_LENGTH=${#DESCRIPTION}
        if [ $DESC_LENGTH -gt 120 ]; then
            echo -e "   ${YELLOW}⚠ Description too long ($DESC_LENGTH chars, max 120 recommended)${NC}"
            ((WARNINGS++))
        else
            echo -e "   ${GREEN}✓ description ($DESC_LENGTH chars)${NC}"
        fi
    else
        echo -e "   ${YELLOW}⚠ No description (recommended for /help)${NC}"
        ((WARNINGS++))
    fi

    # Argument hint
    if echo "$FRONTMATTER" | grep -q '^argument-hint:'; then
        ARG_HINT=$(echo "$FRONTMATTER" | grep '^argument-hint:' | sed 's/argument-hint: *//')
        echo -e "   ${GREEN}✓ argument-hint: $ARG_HINT${NC}"
    fi

    # Allowed tools
    if echo "$FRONTMATTER" | grep -q '^allowed-tools:'; then
        TOOLS=$(echo "$FRONTMATTER" | grep '^allowed-tools:' | sed 's/allowed-tools: *//')
        echo -e "   ${GREEN}✓ allowed-tools: $TOOLS${NC}"
    fi

    # Model
    if echo "$FRONTMATTER" | grep -q '^model:'; then
        MODEL=$(echo "$FRONTMATTER" | grep '^model:' | sed 's/model: *//')
        case "$MODEL" in
            sonnet|opus|haiku)
                echo -e "   ${GREEN}✓ model: $MODEL${NC}"
                ;;
            *)
                echo -e "   ${YELLOW}⚠ Unknown model: $MODEL (expected: sonnet, opus, haiku)${NC}"
                ((WARNINGS++))
                ;;
        esac
    fi
else
    echo -e "${YELLOW}⚠ No frontmatter (optional but recommended)${NC}"
fi

# 3. Check for bash commands
echo "3. Bash command usage:"
BASH_COMMANDS=$(grep -o '!\`[^`]*\`' "$COMMAND_FILE" || true)

if [ -n "$BASH_COMMANDS" ]; then
    BASH_COUNT=$(echo "$BASH_COMMANDS" | wc -l | xargs)
    echo -e "   ${GREEN}✓ Found $BASH_COUNT bash command(s)${NC}"

    # Check if allowed-tools is specified for bash
    if [ -n "$FRONTMATTER" ]; then
        if echo "$FRONTMATTER" | grep -q '^allowed-tools:.*Bash'; then
            echo -e "   ${GREEN}✓ Bash tool specified in allowed-tools${NC}"
        else
            echo -e "   ${RED}✗ Bash commands found but not in allowed-tools${NC}"
            echo -e "   ${YELLOW}   Add to frontmatter: allowed-tools: Bash(...)${NC}"
            ((ERRORS++))
        fi
    else
        echo -e "   ${RED}✗ Bash commands found but no frontmatter with allowed-tools${NC}"
        ((ERRORS++))
    fi

    # Show bash commands
    echo "   Commands used:"
    echo "$BASH_COMMANDS" | while IFS= read -r cmd; do
        # Extract command without !` and `
        clean_cmd=$(echo "$cmd" | sed 's/!\`//g' | sed 's/\`//g')
        echo "     - $clean_cmd"
    done
else
    echo -e "   ${YELLOW}⚠ No bash commands (this is fine if not needed)${NC}"
fi

# 4. Check for file references
echo "4. File references:"
FILE_REFS=$(grep -o '@[^ ]*' "$COMMAND_FILE" || true)

if [ -n "$FILE_REFS" ]; then
    FILE_COUNT=$(echo "$FILE_REFS" | wc -l | xargs)
    echo -e "   ${GREEN}✓ Found $FILE_COUNT file reference(s)${NC}"

    echo "   Files referenced:"
    echo "$FILE_REFS" | while IFS= read -r ref; do
        echo "     - $ref"
    done
else
    echo -e "   ${YELLOW}⚠ No file references (this is fine if not needed)${NC}"
fi

# 5. Check for parameter usage
echo "5. Parameter usage:"

# Check for $ARGUMENTS
if grep -q '\$ARGUMENTS' "$COMMAND_FILE"; then
    echo -e "   ${GREEN}✓ Uses \$ARGUMENTS${NC}"

    # Recommend argument-hint
    if [ -n "$FRONTMATTER" ]; then
        if ! echo "$FRONTMATTER" | grep -q '^argument-hint:'; then
            echo -e "   ${YELLOW}⚠ Consider adding argument-hint to frontmatter${NC}"
            ((WARNINGS++))
        fi
    fi
fi

# Check for positional arguments
POSITIONAL=$(grep -o '\$[0-9]' "$COMMAND_FILE" | sort -u || true)
if [ -n "$POSITIONAL" ]; then
    echo -e "   ${GREEN}✓ Uses positional arguments: $POSITIONAL${NC}"

    # Recommend argument-hint
    if [ -n "$FRONTMATTER" ]; then
        if ! echo "$FRONTMATTER" | grep -q '^argument-hint:'; then
            echo -e "   ${YELLOW}⚠ Consider adding argument-hint to frontmatter${NC}"
            ((WARNINGS++))
        fi
    fi
fi

if [ -z "$POSITIONAL" ] && ! grep -q '\$ARGUMENTS' "$COMMAND_FILE"; then
    echo -e "   ${YELLOW}⚠ No parameters used (static command)${NC}"
fi

# 6. Content validation
echo "6. Content validation:"

CONTENT_LINES=$(wc -l < "$COMMAND_FILE" | xargs)

if [ $CONTENT_LINES -lt 5 ]; then
    echo -e "   ${RED}✗ Content too short ($CONTENT_LINES lines)${NC}"
    ((ERRORS++))
elif [ $CONTENT_LINES -gt 200 ]; then
    echo -e "   ${YELLOW}⚠ Content very long ($CONTENT_LINES lines)${NC}"
    echo -e "   ${YELLOW}   Consider using a Skill for complex workflows${NC}"
    ((WARNINGS++))
else
    echo -e "   ${GREEN}✓ Good length ($CONTENT_LINES lines)${NC}"
fi

# 7. Security checks
echo "7. Security validation:"

# Check for potentially dangerous commands
DANGEROUS_PATTERNS=(
    "rm -rf"
    "sudo"
    "--force"
    "DROP TABLE"
    "DELETE FROM"
)

SECURITY_ISSUES=0
for PATTERN in "${DANGEROUS_PATTERNS[@]}"; do
    if grep -q "$PATTERN" "$COMMAND_FILE"; then
        echo -e "   ${YELLOW}⚠ Found potentially dangerous pattern: $PATTERN${NC}"
        ((SECURITY_ISSUES++))
    fi
done

if [ $SECURITY_ISSUES -eq 0 ]; then
    echo -e "   ${GREEN}✓ No obvious security concerns${NC}"
else
    echo -e "   ${YELLOW}⚠ $SECURITY_ISSUES potential security concerns - review carefully${NC}"
    ((WARNINGS++))
fi

# 8. File location
echo -n "8. File location... "
if [[ "$COMMAND_FILE" == *"/.claude/commands/"* ]]; then
    echo -e "${GREEN}✓ Project command (.claude/commands/)${NC}"
    echo "   Scope: Team-shared (version control recommended)"
elif [[ "$COMMAND_FILE" == *"/.claude/commands/"* ]]; then
    echo -e "${GREEN}✓ User command (~/.claude/commands/)${NC}"
    echo "   Scope: Personal only"
else
    echo -e "${YELLOW}⚠ Non-standard location${NC}"
    echo "   Expected: .claude/commands/ (project) or ~/.claude/commands/ (user)"
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
echo "  3. Test command: /$COMMAND_NAME"
echo "  4. View in help: /help"

if [ $ERRORS -gt 0 ]; then
    exit 1
fi
