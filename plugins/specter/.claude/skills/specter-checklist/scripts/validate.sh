#!/bin/bash
set -e
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_FILE="$SKILL_DIR/SKILL.md"
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
PASS=0; FAIL=0

yaml=$(sed -n '/^---$/,/^---$/p' "$SKILL_FILE" | sed '1d;$d')
[ -z "$yaml" ] && { echo -e "${RED}✗ No YAML${NC}"; exit 1; }
echo "$yaml" | grep -q "^name:" || { echo -e "${RED}✗ No name${NC}"; exit 1; }
triggers=$(sed -n '/^description:/p' "$SKILL_FILE" | grep -o "[0-9])" | wc -l | tr -d ' ')
[ "$triggers" -eq 5 ] && echo -e "${GREEN}✓ 5 triggers${NC}" || echo "⚠ $triggers triggers"
[ -f "$SKILL_DIR/EXAMPLES.md" ] && echo -e "${GREEN}✓ EXAMPLES.md${NC}" || echo "⚠ No EXAMPLES.md"
[ -f "$SKILL_DIR/REFERENCE.md" ] && echo -e "${GREEN}✓ REFERENCE.md${NC}" || echo "⚠ No REFERENCE.md"
echo -e "${GREEN}✅ PASSED${NC}"
