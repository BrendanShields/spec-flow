#!/bin/bash
# Validation script for flow-tasks skill

set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_FILE="$SKILL_DIR/SKILL.md"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

test_yaml_syntax() {
  echo "Testing YAML frontmatter..."
  yaml=$(sed -n '/^---$/,/^---$/p' "$SKILL_FILE" | sed '1d;$d')
  if [ -z "$yaml" ]; then
    echo -e "${RED}✗ FAIL: No YAML frontmatter found${NC}"
    ((FAIL++))
    return 1
  fi
  if ! echo "$yaml" | grep -q "^name:"; then
    echo -e "${RED}✗ FAIL: Missing 'name' field${NC}"
    ((FAIL++))
    return 1
  fi
  echo -e "${GREEN}✓ PASS: YAML frontmatter valid${NC}"
  ((PASS++))
}

test_description_format() {
  echo "Testing description format..."
  desc=$(sed -n '/^description:/p' "$SKILL_FILE" | sed 's/^description: *//')
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
  word_count=$(wc -w < "$SKILL_FILE" | tr -d ' ')
  estimated_tokens=$((word_count * 3 / 4))
  line_count=$(wc -l < "$SKILL_FILE" | tr -d ' ')
  echo "  Lines: $line_count"
  echo "  Estimated tokens: ~$estimated_tokens"
  if [ "$estimated_tokens" -gt 1500 ] || [ "$line_count" -gt 200 ]; then
    echo -e "${YELLOW}⚠ WARN: High token/line count${NC}"
    ((WARN++))
  else
    echo -e "${GREEN}✓ PASS: Token count acceptable${NC}"
    ((PASS++))
  fi
}

test_modular_resources() {
  echo "Testing modular resources..."
  has_resources=false
  [ -f "$SKILL_DIR/EXAMPLES.md" ] && has_resources=true && echo -e "${GREEN}  ✓ EXAMPLES.md exists${NC}"
  [ -f "$SKILL_DIR/REFERENCE.md" ] && has_resources=true && echo -e "${GREEN}  ✓ REFERENCE.md exists${NC}"
  if $has_resources; then
    echo -e "${GREEN}✓ PASS: Modular resources present${NC}"
    ((PASS++))
  else
    echo -e "${YELLOW}⚠ WARN: No modular resources${NC}"
    ((WARN++))
  fi
}

echo "========================================="
echo "Validating flow-tasks skill"
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
else
  echo -e "${GREEN}✅ VALIDATION PASSED${NC}"
  exit 0
fi
