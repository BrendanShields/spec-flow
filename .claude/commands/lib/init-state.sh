#!/bin/bash
# Initialize Flow state management system
# Called automatically by commands when state doesn't exist

set -euo pipefail

FLOW_STATE_DIR=".flow/state"
FLOW_MEMORY_DIR=".flow/memory"

# Create directory structure
create_directories() {
    echo "Initializing Flow state management..."

    mkdir -p "$FLOW_STATE_DIR/checkpoints"
    mkdir -p "$FLOW_MEMORY_DIR"

    echo "✅ Created state directories"
}

# Create initial memory files
create_memory_files() {
    # Workflow Progress
    if [[ ! -f "$FLOW_MEMORY_DIR/WORKFLOW-PROGRESS.md" ]]; then
        cat > "$FLOW_MEMORY_DIR/WORKFLOW-PROGRESS.md" << 'EOF'
# Workflow Progress Tracker

**Last Updated**: {auto-updated}
**Project Started**: {auto-set}

## Features In Progress

| Feature | Started | Progress | Phase |
|---------|---------|----------|-------|
| - | - | - | - |

## Features Completed

| Feature | Completed | Duration | Tasks |
|---------|-----------|----------|-------|
| - | - | - | - |

## Metrics

- **Average Velocity**: Calculating...
- **Success Rate**: Calculating...
- **Total Features**: 0

---

*This file is automatically updated by Flow commands*
EOF
        echo "✅ Created WORKFLOW-PROGRESS.md"
    fi

    # Decisions Log
    if [[ ! -f "$FLOW_MEMORY_DIR/DECISIONS-LOG.md" ]]; then
        cat > "$FLOW_MEMORY_DIR/DECISIONS-LOG.md" << 'EOF'
# Architecture & Design Decisions Log

## Decision Template

When making significant decisions, log them here:

```markdown
## YYYY-MM-DD: {Decision Title}

**Context**: {What prompted this decision}
**Decision**: {What was decided}
**Rationale**: {Why this choice}
**Alternatives**: {What else was considered}
**Impact**: {Expected consequences}
```

## Decisions

{Your decisions will appear below}

---

*Log architectural and design decisions here for future reference*
EOF
        echo "✅ Created DECISIONS-LOG.md"
    fi

    # Changes Planned
    if [[ ! -f "$FLOW_MEMORY_DIR/CHANGES-PLANNED.md" ]]; then
        cat > "$FLOW_MEMORY_DIR/CHANGES-PLANNED.md" << 'EOF'
# Planned Changes Queue

## Priority 1 - Critical (This Week)

- [ ] {Add your P1 items here}

## Priority 2 - High (This Sprint)

- [ ] {Add your P2 items here}

## Priority 3 - Medium (Next Month)

- [ ] {Add your P3 items here}

## Backlog

- [ ] {Future ideas}

---

*Track planned work here. Items are moved to CHANGES-COMPLETED.md when done.*
EOF
        echo "✅ Created CHANGES-PLANNED.md"
    fi

    # Changes Completed
    if [[ ! -f "$FLOW_MEMORY_DIR/CHANGES-COMPLETED.md" ]]; then
        cat > "$FLOW_MEMORY_DIR/CHANGES-COMPLETED.md" << 'EOF'
# Completed Changes Log

## Recent Completions

{Completed items will appear here}

## Statistics

- **Total Completed**: 0
- **Average Time**: Calculating...
- **Success Rate**: Calculating...

---

*Completed work is automatically logged here*
EOF
        echo "✅ Created CHANGES-COMPLETED.md"
    fi
}

# Create README
create_readme() {
    if [[ ! -f "$FLOW_STATE_DIR/README.md" ]]; then
        cat > "$FLOW_STATE_DIR/README.md" << 'EOF'
# Flow State Directory

This directory contains session state and checkpoints for the Flow workflow system.

## Files

- `current-session.md` - Active session state (auto-updated)
- `checkpoints/` - Saved session snapshots

## Usage

State is managed automatically by Flow commands:
- `/status` - View current state
- `/session save` - Create checkpoint
- `/session restore` - Load checkpoint
- `/resume` - Continue from last session

## Do Not Edit

These files are auto-generated. Manual edits may be overwritten.
EOF
        echo "✅ Created state README"
    fi

    if [[ ! -f "$FLOW_MEMORY_DIR/README.md" ]]; then
        cat > "$FLOW_MEMORY_DIR/README.md" << 'EOF'
# Flow Memory Directory

Persistent memory and tracking for Flow workflows.

## Files

- `WORKFLOW-PROGRESS.md` - Velocity and completion tracking
- `DECISIONS-LOG.md` - Architecture decisions
- `CHANGES-PLANNED.md` - Upcoming work queue
- `CHANGES-COMPLETED.md` - Historical record

## Usage

These files track project history and decisions. Feel free to edit:
- Add decisions as they're made
- Update planned changes
- Review progress metrics

Files are updated automatically but can be manually edited.
EOF
        echo "✅ Created memory README"
    fi
}

# Add to .gitignore
update_gitignore() {
    if [[ -f ".gitignore" ]]; then
        if ! grep -q ".flow/state" ".gitignore"; then
            cat >> ".gitignore" << 'EOF'

# Flow state (session-specific)
.flow/state/current-session.md
.flow/state/checkpoints/
EOF
            echo "✅ Updated .gitignore"
        fi
    fi
}

# Main initialization
main() {
    create_directories
    create_memory_files
    create_readme
    update_gitignore

    echo ""
    echo "✅ Flow state management initialized!"
    echo ""
    echo "State tracking is now active. Commands will automatically:"
    echo "  • Track workflow progress"
    echo "  • Save session checkpoints"
    echo "  • Log decisions and changes"
    echo ""
    echo "Use /status to check current state anytime."
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi