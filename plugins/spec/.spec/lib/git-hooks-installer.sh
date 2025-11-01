#!/bin/bash
# Spec Git Hooks Installer
# Install/uninstall git hooks for Spec

set -euo pipefail

SPEC_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPEC_ROOT="$(cd "$SPEC_LIB_DIR/../.." && pwd)"

##
# Install Spec git hooks
#
# Usage: spec_install_git_hooks
#
spec_install_git_hooks() {
  local git_hooks_dir="$SPEC_ROOT/.git/hooks"

  if [[ ! -d "$SPEC_ROOT/.git" ]]; then
    echo "⚠️  Not a git repository, skipping git hooks installation"
    return 0
  fi

  mkdir -p "$git_hooks_dir"

  echo "📦 Installing Spec git hooks..."

  # Pre-commit hook
  cat > "$git_hooks_dir/pre-commit" <<'HOOK_EOF'
#!/bin/bash
# Spec Pre-Commit Hook - Validate state before commit

set -euo pipefail

# Check if Spec is initialized
if [[ ! -d ".spec" ]]; then
  exit 0  # Not a Spec project
fi

echo "🔍 Spec: Validating state before commit..."

# Run validation
if bash .spec/hooks/core/pre-commit.sh; then
  echo "✅ Spec validation passed"
  exit 0
else
  echo "❌ Spec validation failed"
  echo "   Fix errors above or commit with --no-verify to skip"
  exit 1
fi
HOOK_EOF

  chmod +x "$git_hooks_dir/pre-commit"
  echo "✅ Installed pre-commit hook"

  # Post-merge hook
  cat > "$git_hooks_dir/post-merge" <<'HOOK_EOF'
#!/bin/bash
# Spec Post-Merge Hook - Sync state after merge/pull

set -euo pipefail

if [[ ! -d ".spec" ]]; then
  exit 0
fi

echo "🔄 Spec: Syncing state after merge..."

if bash .spec/hooks/core/post-merge.sh 2>&1; then
  echo "✅ Spec state synchronized"
else
  echo "⚠️  Spec sync encountered issues (non-blocking)"
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
  echo "To uninstall: spec_uninstall_git_hooks"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  return 0
}

##
# Uninstall Spec git hooks
#
# Usage: spec_uninstall_git_hooks
#
spec_uninstall_git_hooks() {
  local git_hooks_dir="$SPEC_ROOT/.git/hooks"

  if [[ ! -d "$git_hooks_dir" ]]; then
    echo "⚠️  .git/hooks directory not found"
    return 0
  fi

  echo "🗑️  Uninstalling Spec git hooks..."

  local removed=0

  for hook in pre-commit post-merge; do
    local hook_file="$git_hooks_dir/$hook"
    if [[ -f "$hook_file" ]]; then
      if grep -q "Spec" "$hook_file" 2>/dev/null; then
        rm "$hook_file"
        echo "✅ Removed $hook hook"
        ((removed++))
      else
        echo "⚠️  $hook hook exists but not Spec's, leaving intact"
      fi
    fi
  done

  if [[ $removed -gt 0 ]]; then
    echo "✅ Git hooks uninstalled ($removed hooks removed)"
  else
    echo "ℹ️  No Spec hooks found to remove"
  fi

  return 0
}

##
# Check if git hooks are installed
#
# Returns: 0 if installed, 1 if not
#
spec_git_hooks_installed() {
  local git_hooks_dir="$SPEC_ROOT/.git/hooks"

  if [[ ! -f "$git_hooks_dir/pre-commit" ]] || [[ ! -f "$git_hooks_dir/post-merge" ]]; then
    return 1
  fi

  if ! grep -q "Spec" "$git_hooks_dir/pre-commit" 2>/dev/null; then
    return 1
  fi

  return 0
}

# Export functions
export -f spec_install_git_hooks
export -f spec_uninstall_git_hooks
export -f spec_git_hooks_installed
