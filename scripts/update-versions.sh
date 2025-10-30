#!/bin/bash

# Update plugin versions in marketplace.json
# Usage: ./scripts/update-versions.sh [plugin-name]

set -e

MARKETPLACE_FILE=".claude-plugin/marketplace.json"
PLUGIN_NAME=$1

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📦 Updating Plugin Versions${NC}"
echo "========================================="

# Function to get version from package.json
get_package_version() {
    local plugin_dir=$1
    if [ -f "$plugin_dir/package.json" ]; then
        jq -r '.version' "$plugin_dir/package.json" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

# Function to update single plugin
update_plugin_version() {
    local plugin_name=$1
    local plugin_index=$2
    local plugin_dir="plugins/$plugin_name"

    echo -e "\n${BLUE}Plugin: $plugin_name${NC}"

    # Get current version from marketplace
    CURRENT_VERSION=$(jq -r ".plugins[$plugin_index].version" "$MARKETPLACE_FILE")
    echo "  Current version: $CURRENT_VERSION"

    # Try to find new version
    NEW_VERSION=""

    # Check package.json
    if [ -f "$plugin_dir/package.json" ]; then
        NEW_VERSION=$(get_package_version "$plugin_dir")
        echo "  Found in package.json: $NEW_VERSION"
    fi

    # Check README for version
    if [ -z "$NEW_VERSION" ] && [ -f "$plugin_dir/README.md" ]; then
        VERSION_LINE=$(grep -E "Version:?\s*[0-9]+\.[0-9]+\.[0-9]+" "$plugin_dir/README.md" | head -1 || echo "")
        if [ -n "$VERSION_LINE" ]; then
            NEW_VERSION=$(echo "$VERSION_LINE" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -1)
            echo "  Found in README: $NEW_VERSION"
        fi
    fi

    # Update if version changed
    if [ -n "$NEW_VERSION" ] && [ "$NEW_VERSION" != "$CURRENT_VERSION" ]; then
        # Create temporary file with updated version
        jq ".plugins[$plugin_index].version = \"$NEW_VERSION\"" "$MARKETPLACE_FILE" > "$MARKETPLACE_FILE.tmp"
        mv "$MARKETPLACE_FILE.tmp" "$MARKETPLACE_FILE"
        echo -e "${GREEN}  ✓ Updated to: $NEW_VERSION${NC}"
    elif [ -n "$NEW_VERSION" ]; then
        echo -e "${GREEN}  ✓ Version unchanged${NC}"
    else
        echo -e "${YELLOW}  ⚠ Could not determine version${NC}"
    fi
}

# Main logic
if [ -n "$PLUGIN_NAME" ]; then
    # Update specific plugin
    echo "Updating single plugin: $PLUGIN_NAME"

    # Find plugin index
    PLUGIN_INDEX=$(jq ".plugins | map(.name == \"$PLUGIN_NAME\") | index(true)" "$MARKETPLACE_FILE")

    if [ "$PLUGIN_INDEX" == "null" ]; then
        echo -e "${YELLOW}Plugin not found in marketplace: $PLUGIN_NAME${NC}"
        exit 1
    fi

    update_plugin_version "$PLUGIN_NAME" "$PLUGIN_INDEX"
else
    # Update all plugins
    echo "Updating all plugins..."

    # Get plugin count
    PLUGIN_COUNT=$(jq '.plugins | length' "$MARKETPLACE_FILE")

    for i in $(seq 0 $((PLUGIN_COUNT - 1))); do
        PLUGIN_NAME=$(jq -r ".plugins[$i].name" "$MARKETPLACE_FILE")
        update_plugin_version "$PLUGIN_NAME" "$i"
    done
fi

# Update marketplace version
echo -e "\n${BLUE}Updating Marketplace Version${NC}"
MARKET_VERSION=$(jq -r '.version' "$MARKETPLACE_FILE")
echo "Current marketplace version: $MARKET_VERSION"

# Parse version components
IFS='.' read -r MAJOR MINOR PATCH <<< "$MARKET_VERSION"

# Increment patch version
NEW_PATCH=$((PATCH + 1))
NEW_MARKET_VERSION="$MAJOR.$MINOR.$NEW_PATCH"

read -p "Update marketplace version to $NEW_MARKET_VERSION? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    jq ".version = \"$NEW_MARKET_VERSION\"" "$MARKETPLACE_FILE" > "$MARKETPLACE_FILE.tmp"
    mv "$MARKETPLACE_FILE.tmp" "$MARKETPLACE_FILE"
    echo -e "${GREEN}✓ Marketplace version updated to: $NEW_MARKET_VERSION${NC}"
else
    echo "Marketplace version unchanged"
fi

echo -e "\n========================================="
echo -e "${GREEN}✅ Version update complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Review changes: git diff $MARKETPLACE_FILE"
echo "2. Commit: git commit -m \"chore: Update plugin versions\""
echo "3. Push: git push origin main"