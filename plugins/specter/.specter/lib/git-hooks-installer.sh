#!/bin/bash
# Specter Git Hooks Installer
# Install/uninstall git hooks for Specter

set -euo pipefail

SPECTER_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPECTER_ROOT="$(cd "$SPECTER_LIB_DIR/../.." && pwd)"

##
# Install Specter git hooks
#
# Usage: specter_install_git_hooks
#
specter_install_git_hooks() {
  local git_hooks_dir="$SPECTER_ROOT/.git/hooks"

  if [[ ! -d "$SPECTER_ROOT/.git" ]]; then
    echo "⚠️  Not a git repository, skipping git hooks installation"
    return 0
  fi

  mkdir -p "$git_hooks_dir"

  echo "📦 Installing Specter git hooks..."

  # Pre-commit hook
  cat > "$git_hooks_dir/pre-commit" <<'HOOK_EOF'
#!/bin/bash
# Specter Pre-Commit Hook - Validate state before commit

set -euo pipefail

# Check if Specter is initialized
if [[ ! -d ".specter" ]]; then
  exit 0  # Not a Specter project
fi

echo "🔍 Specter: Validating state before commit..."

# Run validation
if bash .specter/hooks/core/pre-commit.sh; then
  echo "✅ Specter validation passed"
  exit 0
else
  echo "❌ Specter validation failed"
  echo "   Fix errors above or commit with --no-verify to skip"
  exit 1
fi
HOOK_EOF

  chmod +x "$git_hooks_dir/pre-commit"
  echo "✅ Installed pre-commit hook"

  # Post-merge hook
  cat > "$git_hooks_dir/post-merge" <<'HOOK_EOF'
#!/bin/bash
# Specter Post-Merge Hook - Sync state after merge/pull

set -euo pipefail

if [[ ! -d ".specter" ]]; then
  exit 0
fi

echo "🔄 Specter: Syncing state after merge..."

if bash .specter/hooks/core/post-merge.sh 2>&1; then
  echo "✅ Specter state synchronized"
else
  echo "⚠️  Specter sync encountered issues (non-blocking)"
fi

exit 0
HOOK_EOF

  chmod +x "$git_hooks_dir/post-merge"
  echo "✅ Installed post-merge hook"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ Git hooks installed successfully"
  echo ""
  echo "Hooks installed:"
  echo "  - pre-commit: State validation"
  echo "  - post-merge: State synchronization"
  echo ""
  echo "To bypass hooks: git commit --no-verify"
  echo "To uninstall: specter_uninstall_git_hooks"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  return 0
}

##
# Uninstall Specter git hooks
#
# Usage: specter_uninstall_git_hooks
#
specter_uninstall_git_hooks() {
  local git_hooks_dir="$SPECTER_ROOT/.git/hooks"

  if [[ ! -d "$git_hooks_dir" ]]; then
    echo "⚠️  .git/hooks directory not found"
    return 0
  fi

  echo "🗑️  Uninstalling Specter git hooks..."

  local removed=0

  for hook in pre-commit post-merge; do
    local hook_file="$git_hooks_dir/$hook"
    if [[ -f "$hook_file" ]]; then
      if grep -q "Specter" "$hook_file" 2>/dev/null; then
        rm "$hook_file"
        echo "✅ Removed $hook hook"
        ((removed++))
      else
        echo "⚠️  $hook hook exists but not Specter's, leaving intact"
      fi
    fi
  done

  if [[ $removed -gt 0 ]]; then
    echo "✅ Git hooks uninstalled ($removed hooks removed)"
  else
    echo "ℹ️  No Specter hooks found to remove"
  fi

  return 0
}

##
# Check if git hooks are installed
#
# Returns: 0 if installed, 1 if not
#
specter_git_hooks_installed() {
  local git_hooks_dir="$SPECTER_ROOT/.git/hooks"

  if [[ ! -f "$git_hooks_dir/pre-commit" ]] || [[ ! -f "$git_hooks_dir/post-merge" ]]; then
    return 1
  fi

  if ! grep -q "Specter" "$git_hooks_dir/pre-commit" 2>/dev/null; then
    return 1
  fi

  return 0
}

# Export functions
export -f specter_install_git_hooks
export -f specter_uninstall_git_hooks
export -f specter_git_hooks_installed
