# /specter-resume

Intelligently resume interrupted workflow from last checkpoint.

## Purpose

Seamlessly continues work from where you left off, automatically detecting the interruption point, restoring context, and suggesting the exact commands to continue.

## Usage

```
/specter-resume                           # Auto-detect and resume
/specter-resume --from=checkpoint-name    # Resume from specific checkpoint
/specter-resume --feature=001-auth        # Resume specific feature
/specter-resume --validate                # Check state before resuming
/specter-resume --summary                 # Show what was done
```

## Smart Recovery Process

1. **State Detection** - Finds last active session, identifies interruption point, detects incomplete tasks, checks git status
2. **Context Restoration** - Loads feature context, restores configuration, re-establishes integrations, recovers decision history
3. **Validation** - Verifies file consistency, checks git status, validates dependencies, ensures prerequisites
4. **Continuation** - Shows completed work, identifies next task, suggests commands, handles partial completions

## Example Output

See [resume-example.md](./examples/resume-example.md) for full examples.

**Standard resume:**
```
🔄 Resuming Workflow
📅 Last Session: 2024-01-15 14:30 (2 hours ago)
📍 Phase: Implementation | Feature: 001-user-authentication

✅ Work Completed:
   • T001 [US1] Set up user database schema
   • T002 [US1] Create User model
   • Partial: T003 [US1] (50%)

💡 Suggested Command:
   /specter-implement --continue

⚠️ Notes:
   • 2 uncommitted changes
   • JIRA PROJ-123 last synced 3 hours ago
```

## Recovery Scenarios

| Scenario | Detection | Action |
|----------|-----------|--------|
| Mid-task interrupt | T003 partially complete | Continue from line |
| Between phases | Planning complete | Suggest task breakdown |
| Config change | New settings detected | Re-sync integrations |

## Smart Detection Features

**Incomplete task detection:** Analyzes tasks.md, identifies in-progress vs not started

**Uncommitted changes warning:** Suggests commit, stash, or continue options

**Stale state detection:** Warns if changes > 5 days old, suggests git pull

**Context hints:** Based on file patterns (user.ts, auth.test.ts, api/routes.ts)

## Options

- `--from=CHECKPOINT`: Resume from specific checkpoint
- `--feature=NAME`: Resume specific feature
- `--validate`: Validate state before resuming
- `--summary`: Show session summary
- `--force`: Resume even with warnings
- `--json`: JSON output

## Integration Points

**With session management:**
1. Internally runs `/specter-session restore`
2. Runs `/specter-validate`
3. Shows `/specter-status`
4. Suggests next command

**With Git:** Checks status, warns about uncommitted changes, suggests commit points, handles branch switches

**With JIRA:** Re-establishes connection, syncs latest status, updates progress if enabled

## Best Practices

### Before Resuming
1. Check git status
2. Review `/specter-status`
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

| Error | Solution |
|-------|----------|
| No session found | Try `/flow-quickstart` or `specter:init` |
| Multiple features active | Use `--feature=NAME` to specify |
| Corrupt state | Run `/specter-validate --fix` |

## Performance

- State detection: < 200ms
- Context restoration: < 500ms
- Validation: < 1s
- Full resume: < 2s typical

## Related Commands

- `/specter-status` - Check current state
- `/specter-session` - Manage checkpoints
- `/specter-validate` - Verify consistency
- `/flow-debug` - Troubleshoot issues

---

**Next:** Follow suggestions to continue workflow.
