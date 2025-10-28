#!/bin/bash
set -e
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_FILE="$SKILL_DIR/SKILL.md"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
PASS=0; FAIL=0; WARN=0

test_yaml() {
  echo "Testing YAML frontmatter..."
  yaml=$(sed -n '/^---$/,/^---$/p' "$SKILL_FILE" | sed '1d;$d')
  [ -z "$yaml" ] && { echo -e "${RED}✗ FAIL: No YAML${NC}"; ((FAIL++)); return 1; }
  echo "$yaml" | grep -q "^name:" || { echo -e "${RED}✗ FAIL: No name${NC}"; ((FAIL++)); return 1; }
  echo -e "${GREEN}✓ PASS: YAML valid${NC}"; ((PASS++))
}

test_description() {
  echo "Testing description..."
  desc=$(sed -n '/^description:/p' "$SKILL_FILE" | sed 's/^description: *//')
  triggers=$(echo "$desc" | grep -o "[0-9])" | wc -l | tr -d ' ')
  [ "$triggers" -ne 5 ] && echo -e "${YELLOW}⚠ WARN: Expected 5 triggers, found $triggers${NC}" && ((WARN++)) || { echo -e "${GREEN}✓ PASS: 5 triggers${NC}"; ((PASS++)); }
  echo -e "${GREEN}✓ PASS: Description OK${NC}"; ((PASS++))
}

test_resources() {
  echo "Testing modular resources..."
  [ -f "$SKILL_DIR/EXAMPLES.md" ] && echo -e "${GREEN}  ✓ EXAMPLES.md${NC}" || echo -e "${YELLOW}  ⚠ EXAMPLES.md missing${NC}"
  [ -f "$SKILL_DIR/REFERENCE.md" ] && echo -e "${GREEN}  ✓ REFERENCE.md${NC}" && ((PASS++)) || echo -e "${YELLOW}  ⚠ REFERENCE.md missing${NC}"
}

echo "========================================="; echo "Validating flow-clarify skill"; echo "========================================="; echo ""
test_yaml; echo ""; test_description; echo ""; test_resources; echo ""
echo "========================================="; echo "Validation Summary"; echo "========================================="
echo -e "${GREEN}Passed: $PASS${NC}"; echo -e "${YELLOW}Warnings: $WARN${NC}"; echo -e "${RED}Failed: $FAIL${NC}"; echo ""
[ "$FAIL" -gt 0 ] && { echo -e "${RED}❌ FAILED${NC}"; exit 1; } || { echo -e "${GREEN}✅ PASSED${NC}"; exit 0; }
