#!/bin/bash
# Specter Pre-Commit Hook
# Validates state before git commit

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPECTER_ROOT="$(cd "$HOOK_DIR/../../.." && pwd)"

source "$SPECTER_ROOT/.specter/lib/state-sync.sh"

echo "🔍 Specter: Validating state before commit..."

errors=0

# Validate JSON schemas
for json_file in "$SPECTER_ROOT"/.specter-state/*.json "$SPECTER_ROOT"/.specter-memory/*.json; do
  if [[ -f "$json_file" ]]; then
    if ! jq empty "$json_file" 2>/dev/null; then
      echo "❌ Invalid JSON: $(basename $json_file)"
      ((errors++))
    fi
  fi
done

# Check JSON ↔ MD consistency
for json_file in "$SPECTER_ROOT"/.specter-state/*.json "$SPECTER_ROOT"/.specter-memory/*.json; do
  if [[ -f "$json_file" ]]; then
    md_file="${json_file%.json}.md"
    if [[ -f "$md_file" ]]; then
      temp_md=$(mktemp)
      if specter_generate_md "$json_file" > "$temp_md" 2>/dev/null; then
        if ! diff -q "$temp_md" "$md_file" >/dev/null 2>&1; then
          echo "❌ Inconsistency: $(basename $json_file) ↔ $(basename $md_file)"
          echo "   Run: specter_generate_md $json_file > $md_file"
          ((errors++))
        fi
      fi
      rm -f "$temp_md"
    fi
  fi
done

# Check for stale locks
if [[ -d "$SPECTER_ROOT/.specter-state/locks" ]]; then
  for lock_file in "$SPECTER_ROOT"/.specter-state/locks/*.lock; do
    if [[ -f "$lock_file" ]]; then
      ttl=$(jq -r '.ttl // 7200' "$lock_file" 2>/dev/null || echo "7200")
      locked_at=$(jq -r '.lockedAt // ""' "$lock_file" 2>/dev/null || echo "")

      if [[ -n "$locked_at" ]]; then
        now=$(date -u +%s)

        # Parse ISO 8601 timestamp
        if command -v gdate >/dev/null 2>&1; then
          # macOS with coreutils
          locked_ts=$(gdate -d "$locked_at" +%s 2>/dev/null || echo "$now")
        else
          # Linux
          locked_ts=$(date -d "$locked_at" +%s 2>/dev/null || echo "$now")
        fi

        elapsed=$((now - locked_ts))

        if [[ $elapsed -gt $ttl ]]; then
          echo "❌ Stale lock detected: $(basename $lock_file) (${elapsed}s old, TTL: ${ttl}s)"
          ((errors++))
        fi
      fi
    fi
  done
fi

if [[ $errors -gt 0 ]]; then
  echo ""
  echo "❌ Pre-commit validation failed ($errors errors)"
  echo "   Fix errors above or commit with --no-verify to skip"
  exit 1
fi

echo "✅ Validation passed"
exit 0
