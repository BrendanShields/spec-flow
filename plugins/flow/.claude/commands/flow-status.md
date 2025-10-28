# flow-status Command

When the user invokes `/flow-status`, execute the following:

## Instructions

1. **Check if Flow is initialized**
   - Look for `.flow/` directory or `CLAUDE.md` file
   - If not found, inform user to run `flow:init`

2. **Find active feature**
   - Check `.flow-state/current-session.md` for active feature
   - If not found, look in `features/` for most recent directory
   - If no features exist, report "No active workflow"

3. **Determine current phase**
   - Check which files exist in feature directory:
     - Only `spec.md` → Specification phase
     - `spec.md` + `plan.md` → Planning complete
     - All files + incomplete tasks → Implementation phase
     - All tasks complete → Feature complete

4. **Count task progress**
   - Read `tasks.md` if exists
   - Count lines with `- [x]` (completed)
   - Count lines with `- [ ]` (pending)
   - Calculate percentage

5. **Display formatted status report** (see Output Format below)

6. **Suggest next action**
   - Based on phase and completion status

## Output Format

Display a structured status report with the following sections:

### If No Active Workflow:

```
🔄 Flow Status Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Current Feature: 001-user-authentication
📍 Workflow Phase: Implementation
📊 Progress: Task 3 of 15 (20%)

✅ Completed Steps:
   • flow:init (project setup)
   • flow:specify (feature specification)
   • flow:clarify (3 questions resolved)
   • flow:plan (technical design)
   • flow:tasks (15 tasks generated)

🔨 Current Task:
   T003 [US1] Create User model at src/models/user.ts

⏭️ Suggested Next Action:
   Continue implementation with: flow:implement --continue

⚠️ Warnings:
   • 2 clarification questions pending review
   • Blueprint not yet defined (optional)

💡 Tips:
   • Use /flow-validate to check consistency
   • Run /flow-session save before stopping
```

## Options

- `--verbose`: Show detailed state information
- `--feature=NAME`: Check specific feature status
- `--json`: Output in JSON format for tooling

## Integration

This command reads from:
- `.flow-state/current-session.md` (if exists)
- `.flow-memory/WORKFLOW-PROGRESS.md` (if exists)
- `features/*/spec.md`, `plan.md`, `tasks.md`
- `.flow/architecture-blueprint.md`

## Error Handling

If no active workflow is found:
```
❌ No active workflow detected

To start a new workflow:
1. Run 'flow:init' to initialize project
2. Run 'flow:specify "Your feature"' to begin

For help: /flow-help
```

## Related Commands

- `/flow-help` - Get context-aware help
- `/flow-resume` - Continue interrupted work
- `/flow-validate` - Check workflow consistency
- `/flow-session` - Manage session state