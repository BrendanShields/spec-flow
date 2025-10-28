Execute when user types `/session [action]`:

Parse the action from user input:
- `/session save` or `/session save --name=X` → Save checkpoint
- `/session restore` or `/session restore --checkpoint=X` → Restore
- `/session list` → List checkpoints
- No action → Show session status

## For `/session save`:

1. Create `__specification__-state/` directory if needed
2. Gather current state:
   - Active feature from `features/` (most recent directory)
   - Current phase (based on which files exist)
   - Task progress (count [x] vs [ ] in tasks.md)
   - Git branch if available
3. Create session file at `__specification__-state/current-session.md`:
```markdown
# Session State
Updated: {timestamp}

Feature: {feature-id}
Phase: {phase}
Progress: {n}/{total} tasks

Current Task: {current-task-line}
Branch: {git-branch}
```
4. Copy to checkpoint: `__specification__-state/checkpoints/{timestamp}.md`
5. If `--name=X` provided, also save as `__specification__-state/checkpoints/{name}.md`
6. Output:
```
✅ Session saved: {timestamp}
   Feature: {feature}
   Progress: {n}/{total} tasks
```

## For `/session restore`:

1. Find checkpoint:
   - If `--checkpoint=X`, use `__specification__-state/checkpoints/X.md`
   - Otherwise use most recent `__specification__-state/checkpoints/*.md`
2. Read checkpoint file
3. Extract feature ID and restore context
4. Update `__specification__-state/current-session.md`
5. Output:
```
📥 Session restored from {timestamp}
   Feature: {feature}
   Phase: {phase}
   Next: {suggested-action}
```

## For `/session list`:

1. List files in `__specification__-state/checkpoints/`
2. For each, extract timestamp and feature
3. Output:
```
📋 Available Checkpoints:
1. {timestamp} - {feature} ({phase})
2. {timestamp} - {feature} ({phase})
...

Use: /session restore --checkpoint={timestamp}
```

## For `/session` (no action):

Show current session state if `__specification__-state/current-session.md` exists, otherwise:
```
No active session

Use:
• /session save - Create checkpoint
• /status - Check workflow state
```

Execute the appropriate action based on user input.