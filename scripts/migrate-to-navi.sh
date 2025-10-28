#!/bin/bash

# Navi Migration Tool
# Migrates existing Flow projects to Navi system
# Version: 1.0.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BACKUP_DIR=".flow-backup-$(date +%Y%m%d-%H%M%S)"
NEW_DIR="__specification__"
LOG_FILE="migration-$(date +%Y%m%d-%H%M%S).log"

# Functions
log() {
    echo -e "${2:-$NC}$1${NC}"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

error() {
    log "ERROR: $1" "$RED"
    exit 1
}

success() {
    log "SUCCESS: $1" "$GREEN"
}

warning() {
    log "WARNING: $1" "$YELLOW"
}

info() {
    log "INFO: $1" "$BLUE"
}

# Pre-flight checks
preflight_check() {
    info "Running pre-flight checks..."

    # Check if .flow exists
    if [ ! -d ".flow" ]; then
        error "No .flow directory found. Are you in a Flow project?"
    fi

    # Check git status
    if ! git diff --quiet || ! git diff --cached --quiet; then
        warning "You have uncommitted changes. It's recommended to commit first."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Migration cancelled."
            exit 0
        fi
    fi

    # Check if __specification__ already exists
    if [ -d "$NEW_DIR" ]; then
        error "$NEW_DIR already exists. Please remove or rename it first."
    fi

    # Check for required tools
    command -v git >/dev/null 2>&1 || error "git is required but not installed."
    command -v sed >/dev/null 2>&1 || error "sed is required but not installed."

    success "Pre-flight checks passed"
}

# Create backup
create_backup() {
    info "Creating backup at $BACKUP_DIR..."
    cp -r .flow "$BACKUP_DIR"
    success "Backup created at $BACKUP_DIR"
}

# Migrate directory structure
migrate_directory() {
    info "Migrating .flow to $NEW_DIR..."

    # Use git mv to preserve history
    if git ls-files --error-unmatch .flow >/dev/null 2>&1; then
        git mv .flow "$NEW_DIR"
        success "Directory migrated with git history preserved"
    else
        mv .flow "$NEW_DIR"
        warning "Directory migrated without git tracking"
    fi

    # Create temporary symlink for compatibility
    ln -s "$NEW_DIR" .flow
    info "Created compatibility symlink .flow -> $NEW_DIR"
}

# Update file references
update_references() {
    info "Updating references in files..."

    # Find all files that might contain references
    local files=$(find . -type f \( -name "*.md" -o -name "*.sh" -o -name "*.json" \) \
                  -not -path "./$BACKUP_DIR/*" \
                  -not -path "./.git/*" \
                  -not -path "./node_modules/*" 2>/dev/null)

    local count=0
    for file in $files; do
        # Skip binary files
        if file "$file" | grep -q "text"; then
            # Update .flow references to __specification__
            if sed -i.bak "s|\.flow|$NEW_DIR|g" "$file" 2>/dev/null; then
                rm -f "${file}.bak"
                ((count++))
            fi
        fi
    done

    success "Updated references in $count files"
}

# Update Flow to Navi naming
update_naming() {
    info "Updating Flow to Navi naming..."

    # Update in markdown files
    find "$NEW_DIR" -name "*.md" -type f -exec sed -i.bak 's/Flow/Navi/g; s/flow/navi/g' {} \;
    find "$NEW_DIR" -name "*.md.bak" -type f -delete

    # Update in shell scripts
    find "$NEW_DIR" -name "*.sh" -type f -exec sed -i.bak 's/FLOW_/NAVI_/g; s/flow/navi/g' {} \;
    find "$NEW_DIR" -name "*.sh.bak" -type f -delete

    # Update in skill definitions
    if [ -d ".claude/skills" ]; then
        find .claude/skills -name "*.md" -type f -exec sed -i.bak 's/flow-/navi-/g; s/Flow/Navi/g' {} \;
        find .claude/skills -name "*.md.bak" -type f -delete
    fi

    success "Updated naming from Flow to Navi"
}

# Consolidate documentation
consolidate_docs() {
    info "Consolidating documentation..."

    local docs_dir="$NEW_DIR/docs"

    if [ -f "$docs_dir/ARCHITECTURE.md" ] && [ -f "$docs_dir/architecture-blueprint.md" ]; then
        cat "$docs_dir/ARCHITECTURE.md" "$docs_dir/architecture-blueprint.md" > "$docs_dir/architecture.md"
        rm -f "$docs_dir/ARCHITECTURE.md" "$docs_dir/architecture-blueprint.md"
        info "Merged ARCHITECTURE.md and architecture-blueprint.md into architecture.md"
    fi

    if [ -f "$docs_dir/PRODUCT-REQUIREMENTS.md" ]; then
        mv "$docs_dir/PRODUCT-REQUIREMENTS.md" "$docs_dir/requirements.md"
        info "Renamed PRODUCT-REQUIREMENTS.md to requirements.md"
    fi

    # Remove redundant files
    rm -f "$docs_dir/COMMANDS.md" "$docs_dir/CLAUDE-FLOW.md" 2>/dev/null

    success "Documentation consolidated"
}

# Validate migration
validate_migration() {
    info "Validating migration..."

    local errors=0

    # Check directory exists
    if [ ! -d "$NEW_DIR" ]; then
        error "Migration failed: $NEW_DIR not found"
        ((errors++))
    fi

    # Check key subdirectories
    for dir in config features memory state scripts templates docs; do
        if [ ! -d "$NEW_DIR/$dir" ]; then
            warning "Missing directory: $NEW_DIR/$dir"
        fi
    done

    # Check no .flow references remain
    if grep -r "\.flow" . --exclude-dir="$BACKUP_DIR" --exclude-dir=".git" --exclude="$LOG_FILE" 2>/dev/null | grep -v Binary; then
        warning "Some .flow references remain"
        ((errors++))
    fi

    if [ $errors -eq 0 ]; then
        success "Migration validated successfully"
    else
        warning "Migration completed with $errors warnings"
    fi
}

# Rollback function
rollback() {
    error "Migration failed. Rolling back..."

    if [ -d "$BACKUP_DIR" ]; then
        rm -rf "$NEW_DIR" 2>/dev/null
        rm -f .flow 2>/dev/null  # Remove symlink
        mv "$BACKUP_DIR" .flow
        success "Rollback completed. Original .flow directory restored."
    else
        error "Cannot rollback: backup not found at $BACKUP_DIR"
    fi
}

# Main migration flow
main() {
    echo "========================================="
    echo "     Navi Migration Tool v1.0.0"
    echo "========================================="
    echo

    # Set up error handling
    trap rollback ERR

    # Run migration steps
    preflight_check
    create_backup
    migrate_directory
    update_references
    update_naming
    consolidate_docs
    validate_migration

    # Cleanup trap
    trap - ERR

    echo
    echo "========================================="
    success "Migration completed successfully!"
    echo "========================================="
    echo
    info "Next steps:"
    echo "  1. Review changes with: git diff"
    echo "  2. Test the migration: /navi status"
    echo "  3. Commit changes: git add -A && git commit -m 'Migrate from Flow to Navi'"
    echo "  4. Remove backup when satisfied: rm -rf $BACKUP_DIR"
    echo
    info "Migration log saved to: $LOG_FILE"
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo "Options:"
        echo "  --help, -h    Show this help message"
        echo "  --dry-run     Show what would be done without making changes"
        echo "  --force       Skip confirmation prompts"
        exit 0
        ;;
    --dry-run)
        info "Dry run mode - no changes will be made"
        preflight_check
        info "Would create backup at $BACKUP_DIR"
        info "Would migrate .flow to $NEW_DIR"
        info "Would update file references"
        info "Would update naming from Flow to Navi"
        info "Would consolidate documentation"
        exit 0
        ;;
    --force)
        FORCE_MODE=true
        main
        ;;
    *)
        main
        ;;
esac