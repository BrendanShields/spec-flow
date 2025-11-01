#!/bin/bash

# Validate marketplace.json structure and plugin configurations
# Usage: ./scripts/validate.sh

set -e

MARKETPLACE_FILE=".claude-plugin/marketplace.json"
PLUGINS_DIR="plugins"
ERRORS=0
WARNINGS=0

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "🔍 Validating Claude Plugin Marketplace..."
echo "========================================="

# Check marketplace.json exists
if [ ! -f "$MARKETPLACE_FILE" ]; then
    echo -e "${RED}✗ marketplace.json not found${NC}"
    exit 1
fi

# Validate JSON syntax
echo -n "Checking marketplace.json syntax... "
if jq empty "$MARKETPLACE_FILE" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ Invalid JSON${NC}"
    exit 1
fi

# Check required fields
echo "Checking required fields..."

# Check name
NAME=$(jq -r '.name' "$MARKETPLACE_FILE")
if [ "$NAME" == "null" ] || [ -z "$NAME" ]; then
    echo -e "${RED}  ✗ Missing 'name' field${NC}"
    ((ERRORS++))
else
    echo -e "${GREEN}  ✓ name: $NAME${NC}"
fi

# Check version
VERSION=$(jq -r '.version' "$MARKETPLACE_FILE")
if [ "$VERSION" == "null" ] || [ -z "$VERSION" ]; then
    echo -e "${RED}  ✗ Missing 'version' field${NC}"
    ((ERRORS++))
else
    # Validate semver format
    if [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${GREEN}  ✓ version: $VERSION${NC}"
    else
        echo -e "${YELLOW}  ⚠ version '$VERSION' doesn't follow semver${NC}"
        ((WARNINGS++))
    fi
fi

# Check owner
OWNER_NAME=$(jq -r '.owner.name' "$MARKETPLACE_FILE")
OWNER_EMAIL=$(jq -r '.owner.email' "$MARKETPLACE_FILE")
if [ "$OWNER_NAME" == "null" ] || [ -z "$OWNER_NAME" ]; then
    echo -e "${RED}  ✗ Missing 'owner.name' field${NC}"
    ((ERRORS++))
else
    echo -e "${GREEN}  ✓ owner.name: $OWNER_NAME${NC}"
fi

if [ "$OWNER_EMAIL" == "null" ] || [ -z "$OWNER_EMAIL" ]; then
    echo -e "${YELLOW}  ⚠ Missing 'owner.email' field${NC}"
    ((WARNINGS++))
fi

# Validate plugins
echo -e "\nValidating plugins..."
echo "---------------------"

PLUGIN_COUNT=$(jq '.plugins | length' "$MARKETPLACE_FILE")
if [ "$PLUGIN_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠ No plugins defined${NC}"
    ((WARNINGS++))
else
    echo "Found $PLUGIN_COUNT plugin(s)"
fi

# Check each plugin
for i in $(seq 0 $((PLUGIN_COUNT - 1))); do
    echo -e "\nPlugin $((i + 1)):"

    # Get plugin data
    PLUGIN=$(jq ".plugins[$i]" "$MARKETPLACE_FILE")
    PLUGIN_NAME=$(echo "$PLUGIN" | jq -r '.name')
    PLUGIN_SOURCE=$(echo "$PLUGIN" | jq -r '.source')
    PLUGIN_DESC=$(echo "$PLUGIN" | jq -r '.description')
    PLUGIN_VERSION=$(echo "$PLUGIN" | jq -r '.version')
    PLUGIN_CATEGORY=$(echo "$PLUGIN" | jq -r '.category')

    # Check required fields
    if [ "$PLUGIN_NAME" == "null" ] || [ -z "$PLUGIN_NAME" ]; then
        echo -e "${RED}  ✗ Missing 'name'${NC}"
        ((ERRORS++))
    else
        echo -e "${GREEN}  ✓ name: $PLUGIN_NAME${NC}"

        # Check kebab-case
        if [[ ! $PLUGIN_NAME =~ ^[a-z][a-z0-9-]*$ ]]; then
            echo -e "${YELLOW}    ⚠ Name should be kebab-case${NC}"
            ((WARNINGS++))
        fi
    fi

    if [ "$PLUGIN_SOURCE" == "null" ] || [ -z "$PLUGIN_SOURCE" ]; then
        echo -e "${RED}  ✗ Missing 'source'${NC}"
        ((ERRORS++))
    else
        echo -e "${GREEN}  ✓ source: $PLUGIN_SOURCE${NC}"

        # Check if local source exists
        if [[ $PLUGIN_SOURCE == ./* ]]; then
            SOURCE_PATH="${PLUGIN_SOURCE#./}"
            if [ ! -d "$SOURCE_PATH" ]; then
                echo -e "${RED}    ✗ Source directory not found: $SOURCE_PATH${NC}"
                ((ERRORS++))
            else
                # Check plugin structure
                echo "    Checking plugin structure..."

                # Check for .claude directory
                if [ ! -d "$SOURCE_PATH/.claude" ]; then
                    echo -e "${RED}    ✗ Missing .claude directory${NC}"
                    ((ERRORS++))
                fi

                # Check for README
                if [ ! -f "$SOURCE_PATH/README.md" ]; then
                    echo -e "${YELLOW}    ⚠ Missing README.md${NC}"
                    ((WARNINGS++))
                fi

                # Check for LICENSE
                if [ ! -f "$SOURCE_PATH/LICENSE" ]; then
                    echo -e "${YELLOW}    ⚠ Missing LICENSE file${NC}"
                    ((WARNINGS++))
                fi
            fi
        fi
    fi

    if [ "$PLUGIN_DESC" == "null" ] || [ -z "$PLUGIN_DESC" ]; then
        echo -e "${YELLOW}  ⚠ Missing 'description'${NC}"
        ((WARNINGS++))
    else
        DESC_LENGTH=${#PLUGIN_DESC}
        if [ $DESC_LENGTH -gt 200 ]; then
            echo -e "${YELLOW}  ⚠ Description too long ($DESC_LENGTH chars, max 200)${NC}"
            ((WARNINGS++))
        else
            echo -e "${GREEN}  ✓ description: $(echo $PLUGIN_DESC | cut -c1-50)...${NC}"
        fi
    fi

    # Check version
    if [ "$PLUGIN_VERSION" != "null" ] && [ -n "$PLUGIN_VERSION" ]; then
        if [[ $PLUGIN_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo -e "${GREEN}  ✓ version: $PLUGIN_VERSION${NC}"
        else
            echo -e "${YELLOW}  ⚠ Version '$PLUGIN_VERSION' doesn't follow semver${NC}"
            ((WARNINGS++))
        fi
    fi

    # Check category
    VALID_CATEGORIES="development testing deployment utilities productivity integrations documentation security"
    if [ "$PLUGIN_CATEGORY" != "null" ] && [ -n "$PLUGIN_CATEGORY" ]; then
        if [[ $VALID_CATEGORIES =~ $PLUGIN_CATEGORY ]]; then
            echo -e "${GREEN}  ✓ category: $PLUGIN_CATEGORY${NC}"
        else
            echo -e "${YELLOW}  ⚠ Unknown category: $PLUGIN_CATEGORY${NC}"
            ((WARNINGS++))
        fi
    fi

    # Check keywords
    KEYWORDS_COUNT=$(echo "$PLUGIN" | jq '.keywords | length' 2>/dev/null || echo 0)
    if [ "$KEYWORDS_COUNT" -gt 0 ]; then
        if [ "$KEYWORDS_COUNT" -lt 3 ]; then
            echo -e "${YELLOW}  ⚠ Only $KEYWORDS_COUNT keyword(s) (recommend 3-10)${NC}"
            ((WARNINGS++))
        elif [ "$KEYWORDS_COUNT" -gt 10 ]; then
            echo -e "${YELLOW}  ⚠ Too many keywords ($KEYWORDS_COUNT, recommend 3-10)${NC}"
            ((WARNINGS++))
        else
            echo -e "${GREEN}  ✓ keywords: $KEYWORDS_COUNT defined${NC}"
        fi
    fi
done

# Summary
echo -e "\n========================================="
echo "Validation Summary:"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed!${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Passed with $WARNINGS warning(s)${NC}"
    exit 0
else
    echo -e "${RED}❌ Failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    exit 1
fi