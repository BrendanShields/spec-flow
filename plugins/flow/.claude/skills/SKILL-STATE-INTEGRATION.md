# Skill State Integration Guide

This guide explains how Flow skills should integrate with the state management system.

## Overview

Skills should update state files to enable session continuity and progress tracking. The state management system consists of:

- `.flow/state/` - Session state (current feature, phase, task)
- `.flow/memory/` - Persistent tracking (progress, decisions, changes)

## When Skills Should Update State

### flow:init
**Updates**: Initialize state management
```bash
# Create .flow/state/ and .flow/memory/ if they don't exist
bash plugins/flow/.claude/commands/lib/init-state.sh
```

**State Files**:
- Creates directory structure
- Initializes memory files

### flow:specify
**Updates**: Start new feature tracking
```bash
# Update current session with new feature
# Update WORKFLOW-PROGRESS.md with feature started
```

**Actions**:
1. Create entry in current-session.md:
```markdown
Feature: {feature-id}
Phase: specification
Started: {timestamp}
```

2. Add to WORKFLOW-PROGRESS.md:
```markdown
| {feature-id} | {date} | 0/0 | specification |
```

### flow:clarify
**Updates**: Log decisions made during clarification

**Actions**:
1. For each clarification resolved, optionally add to DECISIONS-LOG.md:
```markdown
## {date}: {Decision from clarification}
**Context**: Clarification question answered
**Decision**: {User's answer}
```

### flow:plan
**Updates**: Log architecture decisions

**Actions**:
1. Extract major decisions from plan
2. Add to DECISIONS-LOG.md:
```markdown
## {date}: {Technical decision}
**Context**: {Why this was needed}
**Decision**: {What was chosen}
**Rationale**: {Why}
**Alternatives**: {What else was considered}
```

### flow:tasks
**Updates**: Update progress tracking with task count

**Actions**:
1. Count total tasks created
2. Update WORKFLOW-PROGRESS.md:
```markdown
| {feature-id} | {date} | 0/{total} | implementation |
```

3. Add tasks to CHANGES-PLANNED.md:
```markdown
## P1 Tasks for {feature}
- [ ] T001: {description}
- [ ] T002: {description}
...
```

### flow:implement
**Updates**: Track task completion

**Actions**:
1. After each task completed, update current-session.md:
```markdown
Current Task: T00{n}
Progress: {completed}/{total}
```

2. When task done, move from CHANGES-PLANNED.md to CHANGES-COMPLETED.md:
```markdown
## {date}
- ✅ T001: {description} - Completed in {time}
```

3. Update WORKFLOW-PROGRESS.md:
```markdown
| {feature-id} | {date} | {completed}/{total} | implementation |
```

4. When all tasks done:
```markdown
| {feature-id} | {date} | {total}/{total} | complete |
```

### flow:update
**Updates**: Track specification changes

**Actions**:
1. Log change in DECISIONS-LOG.md:
```markdown
## {date}: Specification Updated
**Context**: Requirements changed
**Changes**: {What changed}
**Impact**: {Tasks affected}
```

## Implementation Patterns

### Pattern 1: Update Current Session

```bash
# At start of skill
if [[ -f .flow/state/current-session.md ]]; then
    # Update existing
    sed -i "s/^Phase:.*/Phase: {new-phase}/" .flow/state/current-session.md
else
    # Create new
    cat > .flow/state/current-session.md << EOF
# Session State
Feature: {feature}
Phase: {phase}
Updated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF
fi
```

### Pattern 2: Append to Memory Files

```bash
# Add decision
echo "" >> .flow/memory/DECISIONS-LOG.md
echo "## $(date +%Y-%m-%d): {Decision Title}" >> .flow/memory/DECISIONS-LOG.md
echo "**Context**: {context}" >> .flow/memory/DECISIONS-LOG.md
echo "**Decision**: {decision}" >> .flow/memory/DECISIONS-LOG.md
```

### Pattern 3: Update Progress Table

```bash
# Update feature progress
if grep -q "{feature-id}" .flow/memory/WORKFLOW-PROGRESS.md; then
    # Update existing row
    sed -i "s/| {feature-id} | .* |/| {feature-id} | {date} | {progress} | {phase} |/" \
        .flow/memory/WORKFLOW-PROGRESS.md
else
    # Add new row
    echo "| {feature-id} | {date} | {progress} | {phase} |" >> \
        .flow/memory/WORKFLOW-PROGRESS.md
fi
```

## State File Locations

Use these paths (relative to project root):

```bash
FLOW_STATE_DIR=".flow/state"
FLOW_MEMORY_DIR=".flow/memory"

CURRENT_SESSION="$FLOW_STATE_DIR/current-session.md"
WORKFLOW_PROGRESS="$FLOW_MEMORY_DIR/WORKFLOW-PROGRESS.md"
DECISIONS_LOG="$FLOW_MEMORY_DIR/DECISIONS-LOG.md"
CHANGES_PLANNED="$FLOW_MEMORY_DIR/CHANGES-PLANNED.md"
CHANGES_COMPLETED="$FLOW_MEMORY_DIR/CHANGES-COMPLETED.md"
```

## Best Practices

1. **Always check if state dirs exist first**
   ```bash
   [[ -d .flow/state ]] || bash plugins/flow/.claude/commands/lib/init-state.sh
   ```

2. **Use atomic updates**
   - Write to temp file, then move
   - Prevents corruption if interrupted

3. **Preserve existing data**
   - Append, don't overwrite
   - Use sed for in-place updates carefully

4. **Add timestamps**
   - ISO 8601 format: `date -u +"%Y-%m-%dT%H:%M:%SZ"`

5. **Handle missing files gracefully**
   - Check existence before reading
   - Create with defaults if needed

## Testing State Integration

Skills should verify state updates work:

```bash
# After skill runs
test -f .flow/state/current-session.md || echo "ERROR: Session not updated"
grep -q "{feature-id}" .flow/memory/WORKFLOW-PROGRESS.md || echo "ERROR: Progress not tracked"
```

## Example: Complete flow:specify Integration

```bash
# In flow-specify skill

# 1. Initialize state if needed
if [[ ! -d .flow/state ]]; then
    bash plugins/flow/.claude/commands/lib/init-state.sh
fi

# 2. Create feature
FEATURE_ID=$(create_feature)  # e.g., "001-user-auth"

# 3. Update current session
cat > .flow/state/current-session.md << EOF
# Session State
Feature: $FEATURE_ID
Phase: specification
Started: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Updated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF

# 4. Add to progress tracker
echo "| $FEATURE_ID | $(date +%Y-%m-%d) | 0/0 | specification |" >> \
    .flow/memory/WORKFLOW-PROGRESS.md

# 5. Log decision if made
if [[ -n "$ARCHITECTURE_DECISION" ]]; then
    cat >> .flow/memory/DECISIONS-LOG.md << EOF

## $(date +%Y-%m-%d): $DECISION_TITLE
**Context**: During specification
**Decision**: $ARCHITECTURE_DECISION
EOF
fi
```

## Validation

After updating state, skills can optionally run validation:

```bash
# Verify state is consistent
if command -v /validate &> /dev/null; then
    /validate --quiet
fi
```

---

This integration ensures seamless state tracking across all Flow workflows.