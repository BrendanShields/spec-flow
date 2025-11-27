# Technical Plan: Workflow Phase Gates

## Architecture

Layered enforcement with self-contained skill scripts:

```
.claude/skills/orbit-workflow/
├── SKILL.md              # Main instructions with validation rules
├── scripts/
│   ├── validate-phase.sh # Check prerequisites before phase transition
│   ├── update-status.sh  # Update frontmatter status + timestamp
│   └── log-activity.sh   # Append to metrics.md with ISO timestamp
└── templates/
    └── metrics.md        # Template with timestamp format

.claude/agents/
└── implementing-tasks.md # Add pre-flight gate for tasks.md
```

## Key Design Decisions

1. **Scripts in skill, not hooks** - Skills are self-contained, no external dependencies
2. **ISO 8601 timestamps** - `2025-11-27T10:30:00Z` format in all metrics
3. **Validation before action** - Check prerequisites, warn/block accordingly
4. **Layered gates** - Skill warns, agent blocks

## Components

| Component | Purpose | Location |
|-----------|---------|----------|
| validate-phase.sh | Check artifact prerequisites | skill/scripts/ |
| update-status.sh | Update frontmatter + timestamp | skill/scripts/ |
| log-activity.sh | Append timestamped activity | skill/scripts/ |
| implementing-tasks.md | Pre-flight tasks.md check | agents/ |

## Script Specifications

### validate-phase.sh

```bash
#!/bin/bash
# Usage: validate-phase.sh <feature-path> <target-phase>
# Returns: 0 if valid, 1 if missing prerequisites
# Output: JSON with validation result

FEATURE="$1"
TARGET="$2"

case "$TARGET" in
  specification)
    # No prerequisites
    echo '{"valid":true}'
    ;;
  planning)
    if [[ ! -f "$FEATURE/spec.md" ]]; then
      echo '{"valid":false,"missing":"spec.md","suggestion":"Create specification first"}'
      exit 1
    fi
    ;;
  implementation)
    if [[ ! -f "$FEATURE/tasks.md" ]]; then
      echo '{"valid":false,"missing":"tasks.md","suggestion":"Create tasks first"}'
      exit 1
    fi
    ;;
esac
```

### update-status.sh

```bash
#!/bin/bash
# Usage: update-status.sh <spec-file> <new-status>
# Updates frontmatter status and timestamp

SPEC="$1"
STATUS="$2"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Update status line
sed -i '' "s/^status:.*/status: $STATUS/" "$SPEC"

# Update timestamp
sed -i '' "s/^updated:.*/updated: $TIMESTAMP/" "$SPEC"
```

### log-activity.sh

```bash
#!/bin/bash
# Usage: log-activity.sh <metrics-file> <event>
# Appends timestamped activity entry

METRICS="$1"
EVENT="$2"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "| $TIMESTAMP | $EVENT |" >> "$METRICS"
```

## Skill Updates

Add to SKILL.md:

```markdown
## Phase Validation

Before any phase transition, validate prerequisites:

\`\`\`bash
bash scripts/validate-phase.sh "$FEATURE" "implementation"
\`\`\`

If validation fails, show the missing artifact and suggest next action.
Do NOT proceed to implementation without tasks.md.

## Status Updates

After completing a phase artifact:

\`\`\`bash
bash scripts/update-status.sh "$FEATURE/spec.md" "planning"
bash scripts/log-activity.sh "$FEATURE/metrics.md" "Plan created"
\`\`\`
```

## Agent Updates

Add to implementing-tasks.md `<inputs>` section:

```markdown
## Pre-Flight Gate

Before starting, verify tasks.md exists:

\`\`\`bash
if [[ ! -f "{feature}/tasks.md" ]]; then
  echo "ERROR: tasks.md not found"
  echo "Run orbit-workflow to create tasks before implementation"
  exit 1
fi
\`\`\`

If tasks.md is missing, STOP and report:
- What's missing
- How to fix (run /orbit → Create Tasks)
```

## Metrics Template Update

```markdown
# Metrics: {title}

## Progress

| Phase | Status | Updated |
|-------|--------|---------|
| Specification | pending | |
| Clarification | pending | |
| Planning | pending | |
| Implementation | 0/0 | |

## Activity

| Timestamp | Event |
|-----------|-------|
```

## Migration

Existing features with old metrics format continue working - new format only for new features.

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Scripts not portable | Fails on Windows | Use POSIX-compatible commands |
| Timestamp timezone issues | Inconsistent logs | Always use UTC (Z suffix) |
| Over-blocking workflow | Frustration | Add explicit bypass flag |
