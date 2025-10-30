# /specter-session

Manage Claude Code session state for workflow continuity.

## Purpose

Enables persistent workflow state across Claude Code sessions, creating checkpoints that can be restored to ensure no context is lost between conversations.

## Usage

```
/specter-session save                      # Create checkpoint
/specter-session save --name="pre-deploy"  # Named checkpoint
/specter-session restore                   # Restore latest
/specter-session restore --checkpoint=NAME # Restore specific
/specter-session list                      # Show checkpoints
/specter-session clean --keep=5            # Remove old
```

## Commands

### Save

Creates a snapshot of current workflow state.

**What's saved:**
- Current feature and phase
- Task completion status
- Configuration state
- Recent command history
- Pending decisions
- Active branch info
- Error states (if any)
- Context cache

```
/specter-session save
✅ Session checkpoint created: 2024-01-15-10-30
   Feature: 001-user-authentication
   Phase: Implementation (Task 3/15)
   Files tracked: 8
```

### Restore

Loads a previous session state.

**What's restored:**
- Working directory context
- Feature/phase position
- Configuration values
- Decision history
- Incomplete tasks
- Integration status

```
/specter-session restore
✅ Session restored successfully
   Next: T003 [US1] Create User model
   Run: specter:implement --continue
```

### List

Shows available checkpoints.

```
/specter-session list
📋 Available Checkpoints:

1. 2024-01-15-14-30 (2 hours ago) ← Latest
   Name: "pre-deploy"
   Feature: 001-user-authentication
   Phase: Implementation (15/15 complete)

2. 2024-01-15-10-30 (6 hours ago)
   Feature: 001-user-authentication
   Phase: Implementation (3/15)

Total checkpoints: 3 (using 245 KB)
```

### Clean

Removes old checkpoints to save space.

```
/specter-session clean --keep=5
🧹 Cleaning old checkpoints...
   Keeping last 5 checkpoints
   Removed: 3 old checkpoints
   Freed: 156 KB
```

## Automatic Checkpoints

Checkpoints created automatically:
- Before `specter:implement` starts
- After completing each workflow phase
- Before configuration changes
- On error recovery
- Every 30 minutes during active work
- Before branch switches

## Session State Structure

```
.specter-state/
├── current-session.md          # Active state
├── session-history.md          # Session log
├── workflow-state.json         # Machine-readable
└── checkpoints/
    ├── 2024-01-15-10-30.md    # Full checkpoint
    ├── 2024-01-15-14-30.md    # Full checkpoint
    └── named/
        └── pre-deploy.md       # Named checkpoint
```

**current-session.md format:**
```markdown
# Current Session State
Session ID: sess_abc123
Created: 2024-01-15T10:30:00Z
Updated: 2024-01-15T14:30:00Z

## Active Work
Feature: 001-user-authentication
Phase: implementation
Task: T003 [US1] Create User model
Progress: 3/15 tasks (20%)

## Workflow History
- [x] specter:init (2024-01-15 09:00)
- [x] specter:specify (2024-01-15 09:15)
- [x] specter:plan (2024-01-15 10:00)
- [ ] specter:implement (started 10:30)

## Configuration
SPECTER_ATLASSIAN_SYNC=enabled
JIRA_TICKET=PROJ-123

## Context
Branch: 001-user-authentication
Working Directory: /project/root
Errors: None
```

## Recovery Scenarios

| Scenario | Action |
|----------|--------|
| Mid-task interrupt | `/specter-session restore` then `specter:implement --continue` |
| Context switch | Save current feature, switch, then restore when ready |
| Team handoff | Save with name, share checkpoint, restore on other machine |

## Best Practices

### When to Save
- Before stopping work for the day
- Before switching features
- After completing major milestones
- Before risky operations
- Before team handoffs

### Naming Conventions
- `pre-deploy` - Before deployment
- `feature-complete` - Feature done
- `handoff-[name]` - Team handoffs
- `experiment-[desc]` - Before experiments
- `stable-[version]` - Known good state

### Checkpoint Management
- Keep 5-10 recent checkpoints
- Name important milestones
- Clean weekly to save space
- Archive completed features
- Document in session-history.md

## Options

**Save:** `--name=NAME`, `--force`, `--minimal`

**Restore:** `--checkpoint=NAME`, `--from-file=PATH`, `--validate`

**List:** `--verbose`, `--json`, `--named-only`

**Clean:** `--keep=N`, `--older-than=DAYS`, `--dry-run`

## Integration Points

All flow skills integrate with session state:
- `specter:implement` reads/updates progress
- `/specter-status` reads session state
- `/specter-resume` uses restore internally
- `/flow-report` includes session metrics

**Git context included:**
- Current branch
- Uncommitted changes count
- Last commit hash
- Remote sync status

## Performance

- Checkpoint size: ~5-10 KB typical
- Save time: < 100ms
- Restore time: < 200ms
- Storage limit: 100 MB default
- Auto-cleanup: After 30 days

## Related Commands

- `/specter-status` - Check current state
- `/specter-resume` - Continue work
- `/flow-report` - Generate progress reports
- `/specter-validate` - Verify session consistency

---

**Next:** Use `/specter-session save` before major changes.
