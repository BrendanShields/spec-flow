# /flow-session

Manage Claude Code session state for workflow continuity.

## Purpose
Enables persistent workflow state across Claude Code sessions, creating checkpoints that can be restored when returning to work, ensuring no context is lost between conversations.

## Usage
```
/flow-session save                      # Create checkpoint
/flow-session save --name="pre-deploy"  # Named checkpoint
/flow-session restore                   # Restore latest
/flow-session restore --checkpoint=NAME # Restore specific
/flow-session list                      # Show checkpoints
/flow-session clean                     # Remove old checkpoints
/flow-session clean --keep=5            # Keep last 5
```

## Commands

### Save
Creates a snapshot of current workflow state.

```
/flow-session save
✅ Session checkpoint created: 2024-01-15-10-30
   Feature: 001-user-authentication
   Phase: Implementation (Task 3/15)
   Files tracked: 8
   Checkpoint ID: chk_abc123
```

**What's Saved:**
- Current feature and phase
- Task completion status
- Configuration state
- Recent command history
- Pending decisions
- Active branch info
- Error states (if any)
- Context cache

### Restore
Loads a previous session state.

```
/flow-session restore
📥 Restoring session from: 2024-01-15-10-30
   Feature: 001-user-authentication
   Phase: Implementation
   Progress: Task 3/15 (20%)

✅ Session restored successfully
   Next: T003 [US1] Create User model
   Run: flow:implement --continue
```

**What's Restored:**
- Working directory context
- Feature/phase position
- Configuration values
- Decision history
- Incomplete tasks
- Integration status

### List
Shows available checkpoints.

```
/flow-session list
📋 Available Checkpoints:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. 2024-01-15-14-30 (2 hours ago) ← Latest
   Name: "pre-deploy"
   Feature: 001-user-authentication
   Phase: Implementation (15/15 complete)

2. 2024-01-15-10-30 (6 hours ago)
   Auto-save
   Feature: 001-user-authentication
   Phase: Implementation (3/15)

3. 2024-01-14-16-45 (yesterday)
   Name: "after-planning"
   Feature: 001-user-authentication
   Phase: Planning complete

Total checkpoints: 3 (using 245 KB)
```

### Clean
Removes old checkpoints to save space.

```
/flow-session clean --keep=5
🧹 Cleaning old checkpoints...
   Keeping last 5 checkpoints
   Removed: 3 old checkpoints
   Freed: 156 KB
✅ Cleanup complete
```

## Automatic Checkpoints

Checkpoints are automatically created:
- Before `flow:implement` starts
- After completing each workflow phase
- Before configuration changes
- On error recovery
- Every 30 minutes during active work
- Before branch switches

## Session State Structure

```
__specification__-state/
├── current-session.md          # Active state
├── session-history.md          # Session log
├── workflow-state.json         # Machine-readable
└── checkpoints/
    ├── 2024-01-15-10-30.md    # Full checkpoint
    ├── 2024-01-15-14-30.md    # Full checkpoint
    └── named/
        └── pre-deploy.md       # Named checkpoint
```

### current-session.md Format
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
- [x] flow:init (2024-01-15 09:00)
- [x] flow:specify (2024-01-15 09:15)
- [x] flow:clarify (2024-01-15 09:30)
- [x] flow:plan (2024-01-15 10:00)
- [x] flow:tasks (2024-01-15 10:15)
- [ ] flow:implement (started 10:30)

## Configuration
FLOW_ATLASSIAN_SYNC=enabled
FLOW_JIRA_PROJECT_KEY=PROJ
JIRA_TICKET=PROJ-123

## Context
Branch: 001-user-authentication
Last Command: flow:implement --continue
Working Directory: /project/root
Errors: None
```

## Recovery Scenarios

### Scenario 1: Interrupted Implementation
```bash
# Session 1 (interrupted)
flow:implement
# Complete tasks T001-T002
# Claude session ends unexpectedly

# Session 2 (next day)
/flow-session restore
# Automatically continues from T003
flow:implement --continue
```

### Scenario 2: Context Switch
```bash
# Working on feature A
/flow-session save --name="feature-a-wip"

# Switch to urgent bug
flow:specify "Critical bug fix"
flow:implement

# Return to feature A
/flow-session restore --checkpoint=feature-a-wip
flow:implement --continue
```

### Scenario 3: Team Handoff
```bash
# Developer 1
/flow-session save --name="handoff-to-team"
/flow-report --type=progress > handoff-notes.md

# Developer 2
/flow-session restore --checkpoint=handoff-to-team
/flow-status  # See current state
flow:implement --continue
```

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

**Save Options:**
- `--name=NAME`: Named checkpoint
- `--force`: Overwrite existing
- `--minimal`: Save only essential state

**Restore Options:**
- `--checkpoint=NAME`: Specific checkpoint
- `--from-file=PATH`: External checkpoint
- `--validate`: Check before restore

**List Options:**
- `--verbose`: Show full details
- `--json`: JSON output
- `--named-only`: Only named checkpoints

**Clean Options:**
- `--keep=N`: Keep last N checkpoints
- `--older-than=DAYS`: Remove by age
- `--dry-run`: Preview cleanup

## Error Handling

### No Checkpoints Found
```
❌ No checkpoints found

To create your first checkpoint:
/flow-session save

To start fresh:
/flow-quickstart
```

### Corrupted Checkpoint
```
⚠️ Checkpoint appears corrupted

Attempting recovery...
✅ Partial recovery successful
   Recovered: Feature, phase, configuration
   Lost: Recent command history

Continue with:
/flow-status  # Verify state
flow:implement --continue
```

### Version Mismatch
```
⚠️ Checkpoint from older flow version

Migrating checkpoint...
✅ Migration successful
   Updated to v2.0 format
   All data preserved
```

## Integration Points

### With Skills
All flow skills check for session state:
```
flow:implement
# Reads current-session.md
# Updates progress
# Auto-saves on completion
```

### With Commands
Other commands integrate:
- `/flow-status` - Reads session state
- `/flow-resume` - Uses restore internally
- `/flow-validate` - Checks session consistency
- `/flow-report` - Includes session metrics

### With Git
Checkpoints include git context:
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

- `/flow-status` - Check current state
- `/flow-resume` - Continue work (uses restore)
- `/flow-report` - Generate progress reports
- `/flow-validate` - Verify session consistency