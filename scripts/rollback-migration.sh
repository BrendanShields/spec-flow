#!/bin/bash

# Navi Migration Rollback Script
# Safely rolls back Navi migration to Flow
# Version: 1.0.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SPEC_DIR="__specification__"
FLOW_DIR=".flow"
LOG_FILE="rollback-$(date +%Y%m%d-%H%M%S).log"

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

# Find latest backup
find_backup() {
    info "Looking for backups..."

    local latest_backup=$(ls -dt .flow-backup-* 2>/dev/null | head -1)

    if [ -z "$latest_backup" ]; then
        error "No backup found. Cannot rollback without a backup."
    fi

    echo "$latest_backup"
}

# Pre-rollback checks
pre_rollback_check() {
    info "Running pre-rollback checks..."

    # Check if we're in a migrated state
    if [ ! -d "$SPEC_DIR" ]; then
        if [ -d "$FLOW_DIR" ] && [ ! -L "$FLOW_DIR" ]; then
            warning "System appears to already be in Flow state."
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                info "Rollback cancelled."
                exit 0
            fi
        fi
    fi

    # Check git status
    if ! git diff --quiet || ! git diff --cached --quiet; then
        warning "You have uncommitted changes."
        info "It's recommended to commit or stash changes before rollback."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Rollback cancelled."
            exit 0
        fi
    fi

    success "Pre-rollback checks completed"
}

# Restore from backup
restore_backup() {
    local backup_dir="$1"

    info "Restoring from backup: $backup_dir"

    # Remove current directories
    if [ -L "$FLOW_DIR" ]; then
        rm -f "$FLOW_DIR"
        info "Removed symlink $FLOW_DIR"
    elif [ -d "$FLOW_DIR" ]; then
        rm -rf "$FLOW_DIR"
        info "Removed existing $FLOW_DIR"
    fi

    if [ -d "$SPEC_DIR" ]; then
        rm -rf "$SPEC_DIR"
        info "Removed $SPEC_DIR"
    fi

    # Restore backup
    cp -r "$backup_dir" "$FLOW_DIR"
    success "Restored $FLOW_DIR from backup"
}

# Revert file references
revert_references() {
    info "Reverting file references..."

    # Find all text files
    local files=$(find . -type f \( -name "*.md" -o -name "*.sh" -o -name "*.json" \) \
                  -not -path "./$FLOW_DIR-backup-*" \
                  -not -path "./.git/*" \
                  -not -path "./node_modules/*" 2>/dev/null)

    local count=0
    for file in $files; do
        # Skip binary files
        if file "$file" | grep -q "text"; then
            # Revert __specification__ to .flow
            if sed -i.bak "s|$SPEC_DIR|$FLOW_DIR|g" "$file" 2>/dev/null; then
                rm -f "${file}.bak"
                ((count++))
            fi
        fi
    done

    success "Reverted references in $count files"
}

# Revert naming
revert_naming() {
    info "Reverting Navi to Flow naming..."

    # Revert in markdown files
    find "$FLOW_DIR" -name "*.md" -type f -exec sed -i.bak 's/Navi/Flow/g; s/navi/flow/g' {} \;
    find "$FLOW_DIR" -name "*.md.bak" -type f -delete

    # Revert in shell scripts
    find "$FLOW_DIR" -name "*.sh" -type f -exec sed -i.bak 's/NAVI_/FLOW_/g; s/navi/flow/g' {} \;
    find "$FLOW_DIR" -name "*.sh.bak" -type f -delete

    # Revert in skill definitions
    if [ -d ".claude/skills" ]; then
        find .claude/skills -name "*.md" -type f -exec sed -i.bak 's/navi-/flow-/g; s/Navi/Flow/g' {} \;
        find .claude/skills -name "*.md.bak" -type f -delete
    fi

    # Revert in commands
    if [ -d ".claude/commands" ]; then
        find .claude/commands -name "*.md" -type f -exec sed -i.bak 's/navi/flow/g; s/Navi/Flow/g' {} \;
        find .claude/commands -name "*.md.bak" -type f -delete
    fi

    success "Reverted naming from Navi to Flow"
}

# Validate rollback
validate_rollback() {
    info "Validating rollback..."

    local errors=0

    # Check .flow exists
    if [ ! -d "$FLOW_DIR" ]; then
        error "Rollback failed: $FLOW_DIR not found"
        ((errors++))
    fi

    # Check no __specification__ references remain
    if grep -r "$SPEC_DIR" . --exclude-dir="$FLOW_DIR-backup-*" --exclude-dir=".git" --exclude="$LOG_FILE" 2>/dev/null | grep -v Binary; then
        warning "Some $SPEC_DIR references may remain"
        ((errors++))
    fi

    # Check no Navi references remain
    if grep -r "Navi\|navi" "$FLOW_DIR" --exclude-dir=".git" 2>/dev/null | grep -v Binary | head -5; then
        warning "Some Navi references may remain in $FLOW_DIR"
    fi

    if [ $errors -eq 0 ]; then
        success "Rollback validated successfully"
    else
        warning "Rollback completed with $errors warnings"
    fi
}

# Clean up old artifacts
cleanup() {
    info "Cleaning up migration artifacts..."

    # Remove migration logs
    rm -f migration-*.log 2>/dev/null

    # Remove any navi-specific files created
    rm -f scripts/migrate-to-navi.sh 2>/dev/null

    info "Cleanup completed"
}

# Main rollback flow
main() {
    echo "========================================="
    echo "     Navi Migration Rollback v1.0.0"
    echo "========================================="
    echo

    # Find backup
    BACKUP_DIR=$(find_backup)

    info "Found backup: $BACKUP_DIR"
    echo
    warning "This will rollback the Navi migration and restore Flow."
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Rollback cancelled."
        exit 0
    fi

    # Run rollback steps
    pre_rollback_check
    restore_backup "$BACKUP_DIR"
    revert_references
    revert_naming
    validate_rollback

    # Optional cleanup
    read -p "Remove migration artifacts? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        cleanup
    fi

    echo
    echo "========================================="
    success "Rollback completed successfully!"
    echo "========================================="
    echo
    info "Next steps:"
    echo "  1. Review changes with: git diff"
    echo "  2. Test Flow commands: /flow status"
    echo "  3. Commit if satisfied: git add -A && git commit -m 'Rollback to Flow'"
    echo "  4. Keep backup for safety: $BACKUP_DIR"
    echo
    info "Rollback log saved to: $LOG_FILE"
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo "Options:"
        echo "  --help, -h       Show this help message"
        echo "  --list-backups   List available backups"
        echo "  --from=BACKUP    Rollback from specific backup"
        echo "  --force          Skip confirmation prompts"
        exit 0
        ;;
    --list-backups)
        info "Available backups:"
        ls -dt .flow-backup-* 2>/dev/null || echo "No backups found"
        exit 0
        ;;
    --from=*)
        BACKUP_DIR="${1#*=}"
        if [ ! -d "$BACKUP_DIR" ]; then
            error "Backup not found: $BACKUP_DIR"
        fi
        main
        ;;
    --force)
        FORCE_MODE=true
        BACKUP_DIR=$(find_backup)
        pre_rollback_check
        restore_backup "$BACKUP_DIR"
        revert_references
        revert_naming
        validate_rollback
        success "Force rollback completed"
        ;;
    *)
        main
        ;;
esac