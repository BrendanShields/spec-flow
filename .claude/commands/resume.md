Execute when user types `/resume`:

1. Check for existing session:
   - Look for `__specification__-state/current-session.md`
   - If not found, look for most recent checkpoint in `__specification__-state/checkpoints/`

2. If session found:
   - Read session file
   - Extract feature ID, phase, last task
   - Locate feature directory in `features/`
   - Read `tasks.md` to find first incomplete task

3. Analyze state:
   - Count completed tasks
   - Identify current task (first `[ ]`)
   - Check for uncommitted git changes
   - Determine next action

4. Display resume summary:
```
🔄 Resuming Workflow
━━━━━━━━━━━━━━━━━━━━━━━━━

Last session: {time-ago}
Feature: {feature-name}
Phase: {phase}

✅ Completed:
   • {completed-task-1}
   • {completed-task-2}
   ...

🔨 Next task:
   {first-incomplete-task}

💡 Continue with:
   flow:implement --continue

{warnings-if-any}
```

5. Check for warnings:
   - Uncommitted changes → "You have {n} uncommitted files"
   - Stale session (>24h) → "Session is {days} old, consider reviewing"
   - Git divergence → "Remote has new commits"

6. If no session:
```
❌ No previous session found

Start fresh:
• flow:init - Initialize project
• flow:specify "Feature" - Create feature
• /status - Check current state
```

Execute this analysis and display appropriate resume information.