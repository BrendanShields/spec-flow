#!/bin/bash

# Skill Validator - Checks skill quality and structure
# Usage: ./validate.sh [skill-path]

set -e

SKILL_PATH="${1:-.}"
SKILL_FILE="$SKILL_PATH/SKILL.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0

# Helper functions
error() {
    echo -e "${RED}✗ ERROR: $1${NC}"
    ((ERRORS++))
}

warning() {
    echo -e "${YELLOW}⚠ WARNING: $1${NC}"
    ((WARNINGS++))
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Check if skill exists
if [ ! -f "$SKILL_FILE" ]; then
    error "SKILL.md not found at $SKILL_FILE"
    exit 1
fi

echo "🔍 Validating skill at: $SKILL_PATH"
echo "================================"

# 1. YAML Syntax Check
echo -e "\n📋 Checking YAML frontmatter..."

if ! grep -q "^---$" "$SKILL_FILE"; then
    error "Missing YAML frontmatter opening delimiter"
else
    success "YAML opening delimiter found"
fi

if ! grep -q "^name:" "$SKILL_FILE"; then
    error "Missing 'name' field in frontmatter"
else
    NAME=$(grep "^name:" "$SKILL_FILE" | cut -d: -f2 | tr -d ' ')
    if [[ "$NAME" =~ ^[a-z0-9-]+$ ]] && [ ${#NAME} -ge 3 ] && [ ${#NAME} -le 64 ]; then
        success "Name format valid: $NAME"
    else
        error "Invalid name format: $NAME (must be lowercase-hyphenated, 3-64 chars)"
    fi
fi

if ! grep -q "^description:" "$SKILL_FILE"; then
    error "Missing 'description' field in frontmatter"
else
    success "Description field found"
fi

# 2. Description Quality Check
echo -e "\n🎯 Checking description quality..."

DESC=$(sed -n '/^description:/p' "$SKILL_FILE" | head -1 | cut -d: -f2- | sed 's/^ //')

if echo "$DESC" | grep -q "Use when:"; then
    success "Description includes 'Use when:' trigger phrase"

    # Count numbered triggers
    TRIGGER_COUNT=$(echo "$DESC" | grep -o "[0-9])" | wc -l)
    if [ $TRIGGER_COUNT -ge 5 ]; then
        success "Description has $TRIGGER_COUNT numbered triggers (excellent!)"
    elif [ $TRIGGER_COUNT -ge 3 ]; then
        warning "Description has only $TRIGGER_COUNT triggers (recommend 5+)"
    else
        error "Description has only $TRIGGER_COUNT triggers (need at least 3)"
    fi
else
    error "Description missing 'Use when:' trigger phrase"
fi

DESC_LENGTH=${#DESC}
if [ $DESC_LENGTH -lt 100 ]; then
    error "Description too short: $DESC_LENGTH chars (minimum 100)"
elif [ $DESC_LENGTH -gt 1024 ]; then
    error "Description too long: $DESC_LENGTH chars (maximum 1024)"
else
    success "Description length optimal: $DESC_LENGTH chars"
fi

# 3. Token Efficiency Check
echo -e "\n⚡ Checking token efficiency..."

WORD_COUNT=$(wc -w < "$SKILL_FILE")
if [ $WORD_COUNT -lt 1000 ]; then
    success "Excellent token efficiency: ~$WORD_COUNT words"
elif [ $WORD_COUNT -lt 1500 ]; then
    success "Good token efficiency: ~$WORD_COUNT words"
elif [ $WORD_COUNT -lt 2500 ]; then
    warning "Acceptable token efficiency: ~$WORD_COUNT words (consider optimizing)"
else
    error "Poor token efficiency: ~$WORD_COUNT words (needs optimization)"
fi

# 4. Progressive Disclosure Check
echo -e "\n📚 Checking progressive disclosure..."

if [ -f "$SKILL_PATH/EXAMPLES.md" ]; then
    success "EXAMPLES.md found (modular structure)"
else
    warning "EXAMPLES.md missing (consider extracting examples)"
fi

if [ -f "$SKILL_PATH/REFERENCE.md" ]; then
    success "REFERENCE.md found (modular structure)"
else
    warning "REFERENCE.md missing (consider extracting reference material)"
fi

if [ -d "$SKILL_PATH/templates" ]; then
    TEMPLATE_COUNT=$(ls "$SKILL_PATH/templates" 2>/dev/null | wc -l)
    success "Templates directory found with $TEMPLATE_COUNT templates"
fi

if [ -d "$SKILL_PATH/scripts" ]; then
    SCRIPT_COUNT=$(ls "$SKILL_PATH/scripts" 2>/dev/null | wc -l)
    success "Scripts directory found with $SCRIPT_COUNT scripts"
fi

# 5. Tool Restrictions Check
echo -e "\n🔧 Checking tool restrictions..."

if grep -q "^allowed-tools:" "$SKILL_FILE"; then
    TOOLS=$(grep "^allowed-tools:" "$SKILL_FILE" | cut -d: -f2)
    TOOL_COUNT=$(echo "$TOOLS" | tr ',' '\n' | wc -l)
    success "Tool restrictions defined: $TOOL_COUNT tools"

    if echo "$TOOLS" | grep -q "Bash" && ! [ -d "$SKILL_PATH/scripts" ]; then
        warning "Bash tool allowed but no scripts directory found"
    fi
else
    warning "No tool restrictions defined (using all tools)"
fi

# 6. Activation Pattern Tests
echo -e "\n🎪 Testing activation patterns..."

if [ -f "$SKILL_PATH/test-phrases.txt" ]; then
    success "Test phrases file found"
else
    warning "No test-phrases.txt file (can't verify activation)"
fi

# Summary
echo -e "\n================================"
echo "📊 Validation Summary"
echo "================================"

if [ $ERRORS -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}✨ Perfect! Skill passes all checks${NC}"
        SCORE=10
    else
        echo -e "${GREEN}✅ Skill is valid with $WARNINGS warnings${NC}"
        SCORE=$((10 - WARNINGS))
    fi
else
    echo -e "${RED}❌ Skill has $ERRORS errors and $WARNINGS warnings${NC}"
    SCORE=$((5 - ERRORS))
fi

[ $SCORE -lt 0 ] && SCORE=0
[ $SCORE -gt 10 ] && SCORE=10

echo -e "\n🏆 Quality Score: $SCORE/10"

# Discovery strength estimate
DISCOVERY_SCORE=0
echo "$DESC" | grep -q "Use when:" && ((DISCOVERY_SCORE+=3))
[ $TRIGGER_COUNT -ge 5 ] && ((DISCOVERY_SCORE+=3))
[ $DESC_LENGTH -ge 200 ] && ((DISCOVERY_SCORE+=2))
echo "$DESC" | grep -q "Output" && ((DISCOVERY_SCORE+=2))

echo "🔍 Discovery Strength: $DISCOVERY_SCORE/10"

# Token efficiency score
if [ $WORD_COUNT -lt 1000 ]; then
    TOKEN_SCORE="Excellent"
elif [ $WORD_COUNT -lt 1500 ]; then
    TOKEN_SCORE="Good"
elif [ $WORD_COUNT -lt 2500 ]; then
    TOKEN_SCORE="Acceptable"
else
    TOKEN_SCORE="Needs Work"
fi

echo "⚡ Token Efficiency: $TOKEN_SCORE (~$WORD_COUNT words)"

exit $ERRORS