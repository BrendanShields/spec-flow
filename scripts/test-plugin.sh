#!/bin/bash

# Test individual plugin structure and functionality
# Usage: ./scripts/test-plugin.sh <plugin-name>

set -e

PLUGIN_NAME=$1
PLUGIN_DIR="plugins/$PLUGIN_NAME"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [ -z "$PLUGIN_NAME" ]; then
    echo -e "${RED}Error: Plugin name required${NC}"
    echo "Usage: $0 <plugin-name>"
    exit 1
fi

if [ ! -d "$PLUGIN_DIR" ]; then
    echo -e "${RED}Error: Plugin directory not found: $PLUGIN_DIR${NC}"
    exit 1
fi

echo -e "${BLUE}🔧 Testing Plugin: $PLUGIN_NAME${NC}"
echo "========================================="

ERRORS=0
WARNINGS=0

# Check directory structure
echo -e "\n${BLUE}Checking Directory Structure...${NC}"

# Required directories/files
REQUIRED_ITEMS=(
    ".claude"
    "README.md"
)

for item in "${REQUIRED_ITEMS[@]}"; do
    if [ -e "$PLUGIN_DIR/$item" ]; then
        echo -e "${GREEN}  ✓ $item${NC}"
    else
        echo -e "${RED}  ✗ Missing: $item${NC}"
        ((ERRORS++))
    fi
done

# Recommended items
RECOMMENDED_ITEMS=(
    "LICENSE"
    ".claude/commands"
    ".claude/skills"
)

for item in "${RECOMMENDED_ITEMS[@]}"; do
    if [ -e "$PLUGIN_DIR/$item" ]; then
        echo -e "${GREEN}  ✓ $item${NC}"
    else
        echo -e "${YELLOW}  ⚠ Recommended: $item${NC}"
        ((WARNINGS++))
    fi
done

# Check for commands
echo -e "\n${BLUE}Checking Commands...${NC}"
if [ -d "$PLUGIN_DIR/.claude/commands" ]; then
    COMMAND_COUNT=$(find "$PLUGIN_DIR/.claude/commands" -name "*.md" -type f | wc -l | tr -d ' ')
    if [ "$COMMAND_COUNT" -gt 0 ]; then
        echo -e "${GREEN}  ✓ Found $COMMAND_COUNT command(s)${NC}"

        # List commands
        for cmd in "$PLUGIN_DIR/.claude/commands"/*.md; do
            if [ -f "$cmd" ]; then
                CMD_NAME=$(basename "$cmd" .md)
                echo -e "    • /$CMD_NAME"

                # Check command structure
                if grep -q "## Usage" "$cmd"; then
                    echo -e "${GREEN}      ✓ Has usage section${NC}"
                else
                    echo -e "${YELLOW}      ⚠ Missing usage section${NC}"
                    ((WARNINGS++))
                fi

                if grep -q "## Examples" "$cmd"; then
                    echo -e "${GREEN}      ✓ Has examples${NC}"
                else
                    echo -e "${YELLOW}      ⚠ Missing examples${NC}"
                    ((WARNINGS++))
                fi
            fi
        done
    else
        echo -e "${YELLOW}  ⚠ No commands found${NC}"
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}  ⚠ No commands directory${NC}"
fi

# Check for skills
echo -e "\n${BLUE}Checking Skills...${NC}"
if [ -d "$PLUGIN_DIR/.claude/skills" ]; then
    SKILL_COUNT=$(find "$PLUGIN_DIR/.claude/skills" -name "SKILL.md" -type f | wc -l | tr -d ' ')
    if [ "$SKILL_COUNT" -gt 0 ]; then
        echo -e "${GREEN}  ✓ Found $SKILL_COUNT skill(s)${NC}"

        # Check each skill
        for skill_file in "$PLUGIN_DIR/.claude/skills"/*/SKILL.md; do
            if [ -f "$skill_file" ]; then
                SKILL_DIR=$(dirname "$skill_file")
                SKILL_NAME=$(basename "$SKILL_DIR")
                echo -e "    • $SKILL_NAME"

                # Check for required sections
                if grep -q "## Triggers" "$skill_file"; then
                    echo -e "${GREEN}      ✓ Has triggers${NC}"
                else
                    echo -e "${RED}      ✗ Missing triggers section${NC}"
                    ((ERRORS++))
                fi

                # Check for examples
                if [ -f "$SKILL_DIR/examples.md" ]; then
                    echo -e "${GREEN}      ✓ Has examples file${NC}"
                else
                    echo -e "${YELLOW}      ⚠ Missing examples.md${NC}"
                    ((WARNINGS++))
                fi

                # Check for reference
                if [ -f "$SKILL_DIR/reference.md" ]; then
                    echo -e "${GREEN}      ✓ Has reference file${NC}"
                else
                    echo -e "${YELLOW}      ⚠ Missing reference.md${NC}"
                    ((WARNINGS++))
                fi
            fi
        done
    else
        echo -e "${YELLOW}  ⚠ No skills found${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠ No skills directory${NC}"
fi

# Check for MCP configuration
echo -e "\n${BLUE}Checking MCP Integration...${NC}"
if [ -f "$PLUGIN_DIR/.mcp.json" ]; then
    echo -e "${GREEN}  ✓ MCP configuration found${NC}"

    # Validate JSON
    if jq empty "$PLUGIN_DIR/.mcp.json" 2>/dev/null; then
        echo -e "${GREEN}    ✓ Valid JSON${NC}"

        # Check for tools
        TOOL_COUNT=$(jq '.tools | length' "$PLUGIN_DIR/.mcp.json" 2>/dev/null || echo 0)
        if [ "$TOOL_COUNT" -gt 0 ]; then
            echo -e "${GREEN}    ✓ $TOOL_COUNT MCP tool(s) defined${NC}"
        fi
    else
        echo -e "${RED}    ✗ Invalid JSON${NC}"
        ((ERRORS++))
    fi
else
    echo "  • No MCP configuration (optional)"
fi

# Check README
echo -e "\n${BLUE}Checking Documentation...${NC}"
if [ -f "$PLUGIN_DIR/README.md" ]; then
    README_SIZE=$(wc -c < "$PLUGIN_DIR/README.md" | tr -d ' ')
    if [ "$README_SIZE" -gt 100 ]; then
        echo -e "${GREEN}  ✓ README.md exists (${README_SIZE} bytes)${NC}"

        # Check for required sections
        REQUIRED_SECTIONS=("## Installation" "## Usage")
        for section in "${REQUIRED_SECTIONS[@]}"; do
            if grep -q "$section" "$PLUGIN_DIR/README.md"; then
                echo -e "${GREEN}    ✓ Has $section section${NC}"
            else
                echo -e "${YELLOW}    ⚠ Missing $section section${NC}"
                ((WARNINGS++))
            fi
        done
    else
        echo -e "${YELLOW}  ⚠ README.md is too short (${README_SIZE} bytes)${NC}"
        ((WARNINGS++))
    fi
fi

# Check for LICENSE
echo -e "\n${BLUE}Checking License...${NC}"
if [ -f "$PLUGIN_DIR/LICENSE" ]; then
    echo -e "${GREEN}  ✓ LICENSE file found${NC}"

    # Try to identify license type
    if grep -q "MIT License" "$PLUGIN_DIR/LICENSE"; then
        echo -e "${GREEN}    ✓ MIT License detected${NC}"
    elif grep -q "Apache License" "$PLUGIN_DIR/LICENSE"; then
        echo -e "${GREEN}    ✓ Apache License detected${NC}"
    elif grep -q "GNU General Public License" "$PLUGIN_DIR/LICENSE"; then
        echo -e "${GREEN}    ✓ GPL License detected${NC}"
    else
        echo "    • Custom or unrecognized license"
    fi
else
    echo -e "${YELLOW}  ⚠ No LICENSE file${NC}"
    ((WARNINGS++))
fi

# Check for package.json if JavaScript
echo -e "\n${BLUE}Checking Dependencies...${NC}"
if [ -f "$PLUGIN_DIR/package.json" ]; then
    echo -e "${GREEN}  ✓ package.json found${NC}"

    # Validate JSON
    if jq empty "$PLUGIN_DIR/package.json" 2>/dev/null; then
        echo -e "${GREEN}    ✓ Valid JSON${NC}"

        # Check name
        PKG_NAME=$(jq -r '.name' "$PLUGIN_DIR/package.json")
        if [ "$PKG_NAME" != "null" ] && [ -n "$PKG_NAME" ]; then
            echo -e "${GREEN}    ✓ name: $PKG_NAME${NC}"
        fi

        # Check version
        PKG_VERSION=$(jq -r '.version' "$PLUGIN_DIR/package.json")
        if [ "$PKG_VERSION" != "null" ] && [ -n "$PKG_VERSION" ]; then
            if [[ $PKG_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                echo -e "${GREEN}    ✓ version: $PKG_VERSION${NC}"
            else
                echo -e "${YELLOW}    ⚠ Version doesn't follow semver${NC}"
                ((WARNINGS++))
            fi
        fi

        # Check for test script
        TEST_SCRIPT=$(jq -r '.scripts.test' "$PLUGIN_DIR/package.json" 2>/dev/null)
        if [ "$TEST_SCRIPT" != "null" ] && [ -n "$TEST_SCRIPT" ]; then
            echo -e "${GREEN}    ✓ Test script defined${NC}"
        else
            echo -e "${YELLOW}    ⚠ No test script${NC}"
            ((WARNINGS++))
        fi
    else
        echo -e "${RED}    ✗ Invalid JSON${NC}"
        ((ERRORS++))
    fi
else
    echo "  • No package.json (not a Node.js plugin)"
fi

# Run tests if available
echo -e "\n${BLUE}Running Tests...${NC}"
if [ -f "$PLUGIN_DIR/package.json" ]; then
    TEST_SCRIPT=$(jq -r '.scripts.test' "$PLUGIN_DIR/package.json" 2>/dev/null)
    if [ "$TEST_SCRIPT" != "null" ] && [ -n "$TEST_SCRIPT" ]; then
        echo "  Running: npm test"
        cd "$PLUGIN_DIR"
        if npm test 2>/dev/null; then
            echo -e "${GREEN}  ✓ Tests passed${NC}"
        else
            echo -e "${YELLOW}  ⚠ Tests failed or not configured${NC}"
            ((WARNINGS++))
        fi
        cd - > /dev/null
    fi
elif [ -f "$PLUGIN_DIR/test.sh" ]; then
    echo "  Running: test.sh"
    cd "$PLUGIN_DIR"
    if ./test.sh 2>/dev/null; then
        echo -e "${GREEN}  ✓ Tests passed${NC}"
    else
        echo -e "${YELLOW}  ⚠ Tests failed${NC}"
        ((WARNINGS++))
    fi
    cd - > /dev/null
else
    echo "  • No tests configured"
fi

# Summary
echo -e "\n========================================="
echo -e "${BLUE}Test Summary for: $PLUGIN_NAME${NC}"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    echo -e "\nPlugin is ready for submission!"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Passed with $WARNINGS warning(s)${NC}"
    echo -e "\nPlugin works but could be improved."
    echo "Consider addressing warnings before submission."
    exit 0
else
    echo -e "${RED}❌ Failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    echo -e "\nPlugin needs fixes before submission."
    echo "Please address all errors (✗) first."
    exit 1
fi