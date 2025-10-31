#!/bin/bash
# Validates skill structure and syntax

SKILL_DIR=$1
SKILL_FILE="$SKILL_DIR/SKILL.md"

if [ -z "$SKILL_DIR" ]; then
  echo "Usage: $0 <skill-directory>"
  exit 1
fi

echo "Validating $SKILL_DIR..."

# Check SKILL.md exists
if [ ! -f "$SKILL_FILE" ]; then
  echo "❌ SKILL.md not found"
  exit 1
fi

# Extract YAML frontmatter (between first two --- lines)
YAML=$(awk '/^---$/{i++}i==1{if(!/^---$/)print}i==2{exit}' "$SKILL_FILE")

# Check name format
NAME=$(echo "$YAML" | grep '^name:' | cut -d: -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
if [ -z "$NAME" ]; then
  echo "❌ Missing 'name' field in frontmatter"
  exit 1
fi

if [[ ! "$NAME" =~ ^[a-z0-9-]+$ ]]; then
  echo "❌ Invalid name format: '$NAME' (use lowercase-with-hyphens only)"
  exit 1
fi

# Check description exists
DESC=$(echo "$YAML" | grep '^description:' | cut -d: -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
if [ -z "$DESC" ]; then
  echo "❌ Missing 'description' field in frontmatter"
  exit 1
fi

# Check description starts with "Use when"
if [[ ! "$DESC" =~ ^Use\ when ]]; then
  echo "⚠️  Description should start with 'Use when...' for better discovery"
fi

# Check description length
DESC_LENGTH=${#DESC}
if [ "$DESC_LENGTH" -gt 500 ]; then
  echo "⚠️  Description is ${DESC_LENGTH} characters (recommend <500)"
fi

# Check for required sections
REQUIRED=("What This Skill Does" "When to Use" "Execution Flow" "Error Handling" "Output Format")
MISSING=0
for section in "${REQUIRED[@]}"; do
  if ! grep -q "## $section" "$SKILL_FILE"; then
    echo "❌ Missing required section: $section"
    MISSING=1
  fi
done

if [ $MISSING -eq 1 ]; then
  exit 1
fi

# Check for examples.md (recommended)
if [ ! -f "$SKILL_DIR/examples.md" ]; then
  echo "⚠️  examples.md not found (recommended for skills)"
fi

echo "✅ Skill validation passed"
exit 0
