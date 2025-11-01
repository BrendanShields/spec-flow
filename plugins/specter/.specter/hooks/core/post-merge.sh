#!/bin/bash
# Specter Post-Merge Hook
# Synchronizes state after git pull/merge

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPECTER_ROOT="$(cd "$HOOK_DIR/../../.." && pwd)"

source "$SPECTER_ROOT/.specter/lib/state-sync.sh"

echo "🔄 Syncing state after merge..."

# Regenerate all markdown files from JSON
for json_file in "$SPECTER_ROOT"/.specter-state/*.json "$SPECTER_ROOT"/.specter-memory/*.json; do
  if [[ -f "$json_file" ]]; then
    md_file="${json_file%.json}.md"
    if specter_generate_md "$json_file" > "${md_file}.tmp" 2>/dev/null; then
      mv "${md_file}.tmp" "$md_file"
      echo "✅ Regenerated $(basename $md_file)"
    else
      rm -f "${md_file}.tmp"
    fi
  fi
done

# Check for conflicting locks
my_user=$(git config user.name 2>/dev/null || echo "unknown")

if [[ -d "$SPECTER_ROOT/.specter-state/locks" ]]; then
  for lock_file in "$SPECTER_ROOT"/.specter-state/locks/*.lock; do
    if [[ -f "$lock_file" ]]; then
      locked_by=$(jq -r '.lockedBy // "unknown"' "$lock_file" 2>/dev/null)
      feature_id=$(jq -r '.featureId // "unknown"' "$lock_file" 2>/dev/null)

      if [[ "$locked_by" != "$my_user" ]] && [[ "$locked_by" != "unknown" ]]; then
        echo ""
        echo "⚠️  Feature $feature_id is locked by @$locked_by"
        echo "   Your work may conflict. Consider:"
        echo "   - Check status: /specter team"
        echo "   - Contact @$locked_by before continuing"
        echo ""
      fi
    fi
  done
fi

# Warn if active feature was modified
if [[ -f "$SPECTER_ROOT/.specter-state/session.json" ]]; then
  active_feature=$(jq -r '.activeFeature.id // ""' "$SPECTER_ROOT/.specter-state/session.json" 2>/dev/null)

  if [[ -n "$active_feature" ]]; then
    # Check if feature files were modified in the merge
    feature_dir="$SPECTER_ROOT/features/$active_feature"

    if [[ -d "$feature_dir" ]]; then
      if git diff --name-only HEAD@{1} HEAD 2>/dev/null | grep -q "features/$active_feature/"; then
        echo ""
        echo "⚠️  Active feature $active_feature was modified by merge"
        echo "   Review changes before continuing work"
        echo ""
      fi
    fi
  fi
fi

echo "✅ State synchronized"
exit 0
