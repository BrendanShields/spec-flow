#!/bin/bash

# Skill Validation Script
# Validates Claude Code skill structure and syntax

SKILL_PATH="${1:-.}"
ERRORS=0
WARNINGS=0

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "🔍 Validating Claude Code Skill at: $SKILL_PATH"
echo "================================================"

# Check if SKILL.md exists
if [ ! -f "$SKILL_PATH/SKILL.md" ]; then
    echo -e "${RED}❌ ERROR: SKILL.md not found${NC}"
    ERRORS=$((ERRORS + 1))
    exit 1
fi

echo "✓ SKILL.md found"

# Extract and validate YAML frontmatter
echo ""
echo "Checking YAML frontmatter..."
echo "----------------------------"

# Check for opening ---
if ! head -1 "$SKILL_PATH/SKILL.md" | grep -q "^---$"; then
    echo -e "${RED}❌ ERROR: YAML frontmatter must start with ---${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo "✓ Opening --- found"
fi

# Extract frontmatter
FRONTMATTER=$(awk '/^---$/{i++}i==1' "$SKILL_PATH/SKILL.md" | tail -n +2)

# Check for name field
if ! echo "$FRONTMATTER" | grep -q "^name:"; then
    echo -e "${RED}❌ ERROR: 'name' field missing${NC}"
    ERRORS=$((ERRORS + 1))
else
    NAME=$(echo "$FRONTMATTER" | grep "^name:" | cut -d':' -f2- | xargs)
    echo "✓ Name: $NAME"

    # Validate name format (lowercase, hyphenated)
    if ! echo "$NAME" | grep -qE "^[a-z][a-z0-9-]*$"; then
        echo -e "${YELLOW}⚠ WARNING: Name should be lowercase and hyphenated${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# Check for description field
if ! echo "$FRONTMATTER" | grep -q "^description:"; then
    echo -e "${RED}❌ ERROR: 'description' field missing${NC}"
    ERRORS=$((ERRORS + 1))
else
    DESCRIPTION=$(echo "$FRONTMATTER" | grep "^description:" | cut -d':' -f2-)
    DESC_LENGTH=${#DESCRIPTION}
    echo "✓ Description found (length: $DESC_LENGTH)"

    # Check for "Use when:" in description
    if ! echo "$DESCRIPTION" | grep -q "Use when:"; then
        echo -e "${YELLOW}⚠ WARNING: Description should include 'Use when:' for better discovery${NC}"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "✓ 'Use when:' phrase found"
    fi

    # Check description length
    if [ $DESC_LENGTH -lt 100 ]; then
        echo -e "${YELLOW}⚠ WARNING: Description seems too short (<100 chars)${NC}"
        WARNINGS=$((WARNINGS + 1))
    elif [ $DESC_LENGTH -gt 500 ]; then
        echo -e "${YELLOW}⚠ WARNING: Description might be too long (>500 chars)${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# Check for allowed-tools (optional)
if echo "$FRONTMATTER" | grep -q "^allowed-tools:"; then
    TOOLS=$(echo "$FRONTMATTER" | grep "^allowed-tools:" | cut -d':' -f2-)
    echo "✓ Tool restrictions: $TOOLS"

    # Validate tool names
    VALID_TOOLS="Read Write Edit Bash Grep Glob WebSearch WebFetch AskUserQuestion TodoWrite Skill Task"
    IFS=',' read -ra TOOL_ARRAY <<< "$TOOLS"
    for tool in "${TOOL_ARRAY[@]}"; do
        tool=$(echo "$tool" | xargs)
        if ! echo "$VALID_TOOLS" | grep -q "\b$tool\b"; then
            echo -e "${YELLOW}⚠ WARNING: Unknown tool '$tool'${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    done
else
    echo "ℹ No tool restrictions (all tools available)"
fi

# Check for closing ---
CLOSING_LINE=$(awk '/^---$/{i++}i==2{print NR; exit}' "$SKILL_PATH/SKILL.md")
if [ -z "$CLOSING_LINE" ]; then
    echo -e "${RED}❌ ERROR: Closing --- for frontmatter not found${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo "✓ Closing --- found at line $CLOSING_LINE"
fi

# Check file structure
echo ""
echo "Checking file structure..."
echo "-------------------------"

# Check for examples.md (recommended)
if [ -f "$SKILL_PATH/examples.md" ]; then
    echo "✓ examples.md found"
else
    echo -e "${YELLOW}ℹ examples.md not found (recommended for better usability)${NC}"
fi

# Check for reference.md (optional)
if [ -f "$SKILL_PATH/reference.md" ]; then
    echo "✓ reference.md found"
else
    echo "ℹ reference.md not found (optional)"
fi

# Check for README.md (recommended)
if [ -f "$SKILL_PATH/README.md" ]; then
    echo "✓ README.md found"
else
    echo -e "${YELLOW}ℹ README.md not found (recommended for documentation)${NC}"
fi

# Check for templates directory (if exists)
if [ -d "$SKILL_PATH/templates" ]; then
    echo "✓ templates/ directory found"
    TEMPLATE_COUNT=$(find "$SKILL_PATH/templates" -type f | wc -l)
    echo "  - $TEMPLATE_COUNT template file(s)"
fi

# Check for scripts directory (if exists)
if [ -d "$SKILL_PATH/scripts" ]; then
    echo "✓ scripts/ directory found"
    SCRIPT_COUNT=$(find "$SKILL_PATH/scripts" -type f | wc -l)
    echo "  - $SCRIPT_COUNT script file(s)"

    # Check if scripts are executable
    NON_EXEC=$(find "$SKILL_PATH/scripts" -type f ! -perm -u+x | wc -l)
    if [ "$NON_EXEC" -gt 0 ]; then
        echo -e "${YELLOW}⚠ WARNING: $NON_EXEC script(s) are not executable${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# Estimate context usage
echo ""
echo "Context usage analysis..."
echo "------------------------"

SKILL_SIZE=$(wc -c < "$SKILL_PATH/SKILL.md")
echo "SKILL.md size: $SKILL_SIZE bytes"

if [ $SKILL_SIZE -gt 10000 ]; then
    echo -e "${YELLOW}⚠ WARNING: SKILL.md might be too large (>10KB). Consider using progressive disclosure.${NC}"
    WARNINGS=$((WARNINGS + 1))
elif [ $SKILL_SIZE -gt 5000 ]; then
    echo -e "${YELLOW}ℹ SKILL.md is moderately large (>5KB). Consider moving examples/reference to separate files.${NC}"
else
    echo "✓ SKILL.md size is optimal (<5KB)"
fi

# Test activation phrases
echo ""
echo "Discovery test phrases..."
echo "------------------------"

if echo "$DESCRIPTION" | grep -q "Use when:"; then
    # Extract numbered items after "Use when:"
    USE_WHEN=$(echo "$DESCRIPTION" | sed -n 's/.*Use when: \(.*\)/\1/p')

    # Count numbered items
    TRIGGER_COUNT=$(echo "$USE_WHEN" | grep -o "[0-9])" | wc -l)
    echo "Found $TRIGGER_COUNT trigger scenarios"

    if [ $TRIGGER_COUNT -lt 3 ]; then
        echo -e "${YELLOW}⚠ WARNING: Consider adding more trigger scenarios (3+ recommended)${NC}"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "✓ Good number of trigger scenarios"
    fi
fi

# Summary
echo ""
echo "================================================"
echo "Validation Summary"
echo "================================================"

if [ $ERRORS -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}✅ SKILL VALID: No errors or warnings found!${NC}"
        exit 0
    else
        echo -e "${GREEN}✅ SKILL VALID: No errors found${NC}"
        echo -e "${YELLOW}⚠ $WARNINGS warning(s) found (see above)${NC}"
        exit 0
    fi
else
    echo -e "${RED}❌ SKILL INVALID: $ERRORS error(s) found${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ Also $WARNINGS warning(s) found${NC}"
    fi
    exit 1
fi