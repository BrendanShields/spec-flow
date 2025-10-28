Execute the following when user types `/status`:

1. Check if spec-flow is initialized (look for `__specification__/` or `CLAUDE.md`)
2. Find the active feature by checking:
   - `__specification__-state/current-session.md` first
   - If not found, list `features/` directory and use most recent
3. If active feature found, analyze it:
   - Read `spec.md`, `plan.md`, `tasks.md` to determine phase
   - Count completed tasks (lines with `[x]`) vs total tasks (lines with `[ ]` or `[x]`)
   - Identify current task (first `[ ]` line)
4. Display status in this format:

```
🔄 Flow Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature: {feature-name}
Phase: {specification|planning|implementation|complete}
Progress: {n}/{total} tasks ({percentage}%)

Current: {current-task-description}

Next Action: {suggested-command}
```

5. Suggest next action based on phase:
   - No `__specification__/` → "Run flow:init to initialize"
   - Only `spec.md` → "Run flow:clarify or flow:plan"
   - Has `plan.md`, no `tasks.md` → "Run flow:tasks"
   - Has `tasks.md`, incomplete → "Run flow:implement --continue"
   - All complete → "Feature done! Run flow:specify for next feature"

6. If no features found, display:
```
❌ No active workflow

To start:
• flow:init (if not initialized)
• flow:specify "Your feature description"
```

Execute this analysis and display the appropriate output based on the current state of the repository.