# flow-status Command

When the user invokes `/specter-status`, execute the following:

## Instructions

1. **Check if Specter is initialized**
   - Look for `.specter/` directory or `CLAUDE.md` file
   - If not found, inform user to run `specter:init`

2. **Find active feature**
   - Check `.specter-state/current-session.md` for active feature
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
   • specter:init (project setup)
   • specter:specify (feature specification)
   • specter:clarify (3 questions resolved)
   • specter:plan (technical design)
   • specter:tasks (15 tasks generated)

🔨 Current Task:
   T003 [US1] Create User model at src/models/user.ts

⏭️ Suggested Next Action:
   Continue implementation with: specter:implement --continue

⚠️ Warnings:
   • 2 clarification questions pending review
   • Blueprint not yet defined (optional)

💡 Tips:
   • Use /specter-validate to check consistency
   • Run /specter-session save before stopping
```

## Options

- `--verbose`: Show detailed state information
- `--feature=NAME`: Check specific feature status
- `--json`: Output in JSON format for tooling

## Integration

This command reads from:
- `.specter-state/current-session.md` (if exists)
- `.specter-memory/WORKFLOW-PROGRESS.md` (if exists)
- `features/*/spec.md`, `plan.md`, `tasks.md`
- `.specter/architecture-blueprint.md`

## Error Handling

If no active workflow is found:
```
❌ No active workflow detected

To start a new workflow:
1. Run 'specter:init' to initialize project
2. Run 'specter:specify "Your feature"' to begin

For help: /specter-help
```

## Related Commands

- `/specter-help` - Get context-aware help
- `/specter-resume` - Continue interrupted work
- `/specter-validate` - Check workflow consistency
- `/specter-session` - Manage session state