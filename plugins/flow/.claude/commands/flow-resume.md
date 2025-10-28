# /flow-resume

Intelligently resume interrupted workflow from last checkpoint.

## Purpose
Seamlessly continues work from where you left off, automatically detecting the interruption point, restoring context, and suggesting the exact commands to continue your workflow.

## Usage
```
/flow-resume                           # Auto-detect and resume
/flow-resume --from=checkpoint-name    # Resume from specific checkpoint
/flow-resume --feature=001-auth        # Resume specific feature
/flow-resume --validate                # Check state before resuming
/flow-resume --summary                 # Show what was done before resuming
```

## Smart Recovery Process

1. **State Detection**
   - Finds last active session
   - Identifies interruption point
   - Detects incomplete tasks
   - Checks for uncommitted changes

2. **Context Restoration**
   - Loads feature context
   - Restores configuration
   - Re-establishes integrations
   - Recovers decision history

3. **Validation**
   - Verifies file consistency
   - Checks git status
   - Validates dependencies
   - Ensures prerequisites

4. **Continuation**
   - Shows completed work
   - Identifies next task
   - Suggests commands
   - Handles partial completions

## Example Output

### Standard Resume
```
🔄 Resuming Workflow
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📅 Last Session: 2024-01-15 14:30 (2 hours ago)
📁 Feature: 001-user-authentication
📍 Phase: Implementation

✅ Work Completed in Last Session:
   • T001 [US1] Set up user database schema
   • T002 [US1] Create User model
   • Partial: T003 [US1] Add validation rules (50%)

🔨 Resuming From:
   Task: T003 [US1] Add validation rules
   File: src/models/user.ts
   Status: Email validation added, need password rules

📋 Upcoming Tasks:
   • T003 - Complete password validation
   • T004 [P] [US1] Create user service
   • T005 [P] [US1] Add user repository

💡 Suggested Command:
   flow:implement --continue

⚠️ Notes:
   • You have 2 uncommitted changes
   • JIRA PROJ-123 last synced 3 hours ago
   • Consider: git commit before continuing
```

### With Validation
```
/flow-resume --validate

🔍 Validating State Before Resume
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Validation Passed:
   • Files intact: spec.md, plan.md, tasks.md
   • Git status: 2 modified files (expected)
   • Dependencies: All present
   • Configuration: Valid

⚠️ Warnings:
   • Divergence detected: spec.md updated since plan.md
   • Suggestion: Run flow:analyze after resume

Ready to resume? Run:
   flow:implement --continue
```

### With Summary
```
/flow-resume --summary

📊 Session Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Previous Session (2024-01-15):
Duration: 3 hours 15 minutes
Completed: 2.5 tasks
Velocity: 0.77 tasks/hour

Progress Overview:
Phase          Status      Progress
─────────────────────────────────────
Specification  ✅ Complete  100%
Planning       ✅ Complete  100%
Implementation 🔄 Active    17% (2.5/15)

Key Decisions Made:
1. Chose PostgreSQL for database
2. Implemented JWT authentication
3. Added email validation pattern

Git Activity:
• 3 commits
• 8 files changed
• 245 lines added

Ready to continue with task T003
```

## Recovery Scenarios

### Scenario 1: Mid-Task Interruption
```
# Original session
flow:implement
# Working on T003, session ends

# Resume
/flow-resume
> Detected: T003 partially complete
> Found: src/models/user.ts modified
> Continuing from line 45
> Run: flow:implement --continue
```

### Scenario 2: Between Workflow Phases
```
# Original session
flow:plan  # Completed
# Session ends before tasks

# Resume
/flow-resume
> Last phase: Planning complete
> Next phase: Task breakdown
> Run: flow:tasks
```

### Scenario 3: After Configuration Change
```
# Original session
Changed FLOW_ATLASSIAN_SYNC=enabled
# Session ends

# Resume
/flow-resume
> Configuration change detected
> JIRA integration enabled
> Syncing with PROJ-123
> Continue with: flow:implement
```

## Smart Detection Features

### Incomplete Task Detection
```
Analyzing tasks.md...
Found:
- [x] T001 - Complete
- [x] T002 - Complete
- [ ] T003 - In progress (git shows changes)
- [ ] T004 - Not started

Resuming from T003 with context
```

### Uncommitted Changes Warning
```
⚠️ Uncommitted changes detected:
   • src/models/user.ts (modified)
   • tests/user.test.ts (modified)

Options:
1. Commit now: git commit -m "WIP: User validation"
2. Stash: git stash
3. Continue anyway: flow:implement --continue
```

### Stale State Detection
```
⚠️ State may be stale:
   • Last update: 5 days ago
   • Remote has 12 new commits

Recommended:
1. git pull origin main
2. flow:analyze  # Check consistency
3. flow:implement --continue
```

## Options

- `--from=CHECKPOINT`: Resume from specific checkpoint
- `--feature=NAME`: Resume specific feature
- `--validate`: Validate state before resuming
- `--summary`: Show session summary
- `--force`: Resume even with warnings
- `--json`: Output as JSON

## Integration Points

### With Session Management
```
/flow-resume
# Internally runs:
# 1. /flow-session restore
# 2. /flow-validate
# 3. /flow-status
# 4. Suggests next command
```

### With Git
```
# Checks git status
# Warns about uncommitted changes
# Suggests commit points
# Handles branch switches
```

### With JIRA
```
# Re-establishes JIRA connection
# Syncs latest ticket status
# Updates progress if enabled
```

## Automatic Features

### Context Hints
Based on file patterns:
- `user.ts` → "Working on user model"
- `auth.test.ts` → "Writing auth tests"
- `api/routes.ts` → "Setting up API endpoints"

### Smart Suggestions
Based on patterns:
- Tests failing → Suggest `/flow-debug`
- Many uncommitted → Suggest git commit
- Long gap → Suggest `/flow-status` first
- Conflicts → Suggest resolution steps

### Recovery Actions
Automatic recovery for:
- Corrupted task markers
- Missing line breaks
- Incomplete JSON
- Dangling references

## Best Practices

### Before Resuming
1. Check git status
2. Review `/flow-status`
3. Validate with `--validate`
4. Commit any WIP

### After Resuming
1. Verify context is correct
2. Check integration status
3. Run tests if applicable
4. Update progress tracking

### For Long Gaps
1. Use `--summary` first
2. Review decisions log
3. Check for upstream changes
4. Re-read specifications

## Error Handling

### No Session Found
```
❌ No previous session found

Starting fresh? Try:
• /flow-quickstart - Guided setup
• flow:init - Initialize project
• /flow-help - Get help
```

### Multiple Features Active
```
⚠️ Multiple active features detected:
1. 001-user-authentication (3/15 tasks)
2. 002-api-endpoints (1/8 tasks)

Which would you like to resume?
• /flow-resume --feature=001-user-authentication
• /flow-resume --feature=002-api-endpoints
```

### Corrupt State
```
⚠️ Session state appears corrupted

Attempting recovery...
✅ Recovered partial state:
   • Feature: 001-user-authentication
   • Phase: Implementation (estimated)

Recommend:
• /flow-validate --fix
• /flow-status
• Manual review of tasks.md
```

## Performance

- State detection: < 200ms
- Context restoration: < 500ms
- Validation: < 1s
- Full resume: < 2s typical

## Related Commands

- `/flow-status` - Check current state
- `/flow-session` - Manage checkpoints
- `/flow-validate` - Verify consistency
- `/flow-debug` - Troubleshoot issues