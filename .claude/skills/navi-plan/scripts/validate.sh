#!/bin/bash
# Validation script for flow-plan skill
# Tests SKILL.md syntax, activation patterns, and configuration

set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_FILE="$SKILL_DIR/SKILL.md"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASS=0
FAIL=0
WARN=0

# Test functions
test_yaml_syntax() {
  echo "Testing YAML frontmatter..."

  # Extract YAML frontmatter (between --- markers)
  yaml=$(sed -n '/^---$/,/^---$/p' "$SKILL_FILE" | sed '1d;$d')

  if [ -z "$yaml" ]; then
    echo -e "${RED}✗ FAIL: No YAML frontmatter found${NC}"
    ((FAIL++))
    return 1
  fi

  # Check required fields
  if ! echo "$yaml" | grep -q "^name:"; then
    echo -e "${RED}✗ FAIL: Missing 'name' field${NC}"
    ((FAIL++))
    return 1
  fi

  if ! echo "$yaml" | grep -q "^description:"; then
    echo -e "${RED}✗ FAIL: Missing 'description' field${NC}"
    ((FAIL++))
    return 1
  fi

  echo -e "${GREEN}✓ PASS: YAML frontmatter valid${NC}"
  ((PASS++))
}

test_description_format() {
  echo "Testing description format..."

  desc=$(sed -n '/^description:/p' "$SKILL_FILE" | sed 's/^description: *//')

  # Check length (should be under 1024 chars, ideally under 512)
  length=${#desc}
  if [ "$length" -gt 1024 ]; then
    echo -e "${RED}✗ FAIL: Description too long ($length chars, max 1024)${NC}"
    ((FAIL++))
    return 1
  elif [ "$length" -gt 512 ]; then
    echo -e "${YELLOW}⚠ WARN: Description long ($length chars, recommend <512)${NC}"
    ((WARN++))
  fi

  # Check for "Use when:" pattern
  if ! echo "$desc" | grep -q "Use when:"; then
    echo -e "${YELLOW}⚠ WARN: Description missing 'Use when:' pattern${NC}"
    ((WARN++))
  fi

  # Count numbered triggers (should have 5)
  trigger_count=$(echo "$desc" | grep -o "[0-9])" | wc -l | tr -d ' ')
  if [ "$trigger_count" -ne 5 ]; then
    echo -e "${YELLOW}⚠ WARN: Expected 5 numbered triggers, found $trigger_count${NC}"
    ((WARN++))
  else
    echo -e "${GREEN}✓ PASS: Has 5 numbered triggers${NC}"
    ((PASS++))
  fi

  echo -e "${GREEN}✓ PASS: Description format acceptable${NC}"
  ((PASS++))
}

test_token_count() {
  echo "Testing token count..."

  # Count words as proxy for tokens (rough estimate: 1 token ≈ 0.75 words)
  word_count=$(wc -w < "$SKILL_FILE" | tr -d ' ')
  estimated_tokens=$((word_count * 3 / 4))
  line_count=$(wc -l < "$SKILL_FILE" | tr -d ' ')

  echo "  Lines: $line_count"
  echo "  Words: $word_count"
  echo "  Estimated tokens: ~$estimated_tokens"

  # Target: <1500 tokens (~2000 words, ~200 lines for skill core)
  if [ "$estimated_tokens" -gt 1500 ]; then
    echo -e "${YELLOW}⚠ WARN: High token count (~$estimated_tokens, target <1500)${NC}"
    echo -e "${YELLOW}  Consider extracting content to EXAMPLES.md or REFERENCE.md${NC}"
    ((WARN++))
  elif [ "$line_count" -gt 200 ]; then
    echo -e "${YELLOW}⚠ WARN: High line count ($line_count, target <200)${NC}"
    ((WARN++))
  else
    echo -e "${GREEN}✓ PASS: Token count acceptable${NC}"
    ((PASS++))
  fi
}

test_modular_resources() {
  echo "Testing modular resources..."

  has_resources=false

  if [ -f "$SKILL_DIR/EXAMPLES.md" ]; then
    echo -e "${GREEN}  ✓ EXAMPLES.md exists${NC}"
    has_resources=true
  else
    echo -e "${YELLOW}  ⚠ EXAMPLES.md missing${NC}"
  fi

  if [ -f "$SKILL_DIR/REFERENCE.md" ]; then
    echo -e "${GREEN}  ✓ REFERENCE.md exists${NC}"
    has_resources=true
  else
    echo -e "${YELLOW}  ⚠ REFERENCE.md missing${NC}"
  fi

  if [ -d "$SKILL_DIR/templates" ]; then
    echo -e "${GREEN}  ✓ templates/ directory exists${NC}"
    has_resources=true
  fi

  if [ -d "$SKILL_DIR/scripts" ]; then
    echo -e "${GREEN}  ✓ scripts/ directory exists${NC}"
    has_resources=true
  fi

  if $has_resources; then
    echo -e "${GREEN}✓ PASS: Modular resources present${NC}"
    ((PASS++))
  else
    echo -e "${YELLOW}⚠ WARN: No modular resources (EXAMPLES.md, REFERENCE.md, etc.)${NC}"
    ((WARN++))
  fi
}

test_activation_patterns() {
  echo "Testing activation patterns..."

  # These phrases should trigger the skill
  triggers=(
    "flow:plan"
    "create implementation plan"
    "design the architecture"
    "technical planning"
    "generate plan"
  )

  # Test if description contains relevant keywords
  desc=$(sed -n '/^description:/p' "$SKILL_FILE" | sed 's/^description: *//')

  keywords_found=0
  for keyword in "plan" "technical" "design" "architecture" "implementation"; do
    if echo "$desc" | grep -iq "$keyword"; then
      ((keywords_found++))
    fi
  done

  if [ "$keywords_found" -ge 3 ]; then
    echo -e "${GREEN}✓ PASS: Activation keywords present ($keywords_found/5)${NC}"
    ((PASS++))
  else
    echo -e "${YELLOW}⚠ WARN: Few activation keywords found ($keywords_found/5)${NC}"
    ((WARN++))
  fi
}

test_plan_specifics() {
  echo "Testing plan-specific content..."

  # Check for key planning concepts
  content=$(cat "$SKILL_FILE")

  required_concepts=(
    "plan.md"
    "architecture"
    "research"
  )

  missing_concepts=()
  for concept in "${required_concepts[@]}"; do
    if ! echo "$content" | grep -iq "$concept"; then
      missing_concepts+=("$concept")
    fi
  done

  if [ ${#missing_concepts[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ PASS: All planning concepts present${NC}"
    ((PASS++))
  else
    echo -e "${YELLOW}⚠ WARN: Missing concepts: ${missing_concepts[*]}${NC}"
    ((WARN++))
  fi
}

# Run all tests
echo "========================================="
echo "Validating flow-plan skill"
echo "========================================="
echo ""

test_yaml_syntax
echo ""
test_description_format
echo ""
test_token_count
echo ""
test_modular_resources
echo ""
test_activation_patterns
echo ""
test_plan_specifics
echo ""

# Summary
echo "========================================="
echo "Validation Summary"
echo "========================================="
echo -e "${GREEN}Passed: $PASS${NC}"
echo -e "${YELLOW}Warnings: $WARN${NC}"
echo -e "${RED}Failed: $FAIL${NC}"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}❌ VALIDATION FAILED${NC}"
  exit 1
elif [ "$WARN" -gt 3 ]; then
  echo -e "${YELLOW}⚠️  VALIDATION PASSED WITH WARNINGS${NC}"
  echo "Consider addressing warnings for better quality"
  exit 0
else
  echo -e "${GREEN}✅ VALIDATION PASSED${NC}"
  exit 0
fi
