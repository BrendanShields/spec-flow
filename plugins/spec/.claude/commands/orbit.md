# Orbit

Specification-driven development workflow. Detects state from artifacts and guides next action.

## Behavior

1. Use context from SessionStart hook (check system-reminder for recent context)
2. Only reload context if needed: `bash .claude/hooks/lib/context-loader.sh`
3. Show status banner with suggestion
4. Present options based on state and in-progress features
5. Invoke skill or agent based on selection

## Context Loading

**The SessionStart hook already loads context!** Check for a system-reminder with context before reloading.

Only reload if:
- No context found in system-reminder
- User explicitly requests refresh
- Context is needed after state changes

```bash
# Only call if needed
bash .claude/hooks/lib/context-loader.sh
```

Returns:
- `suggestion`: Recommended next action
- `current.state`: Active feature status from frontmatter
- `features.in_progress`: All features needing attention
- `extensions`: Available MCP servers, skills, agents

## Status Banner

```
  ██████╗ ██████╗ ██████╗ ██╗████████╗
 ██╔═══██╗██╔══██╗██╔══██╗██║╚══██╔══╝
 ██║   ██║██████╔╝██████╔╝██║   ██║
 ██║   ██║██╔══██╗██╔══██╗██║   ██║
 ╚██████╔╝██║  ██║██████╔╝██║   ██║
  ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝   ╚═╝

Feature: {current.state.title or "none"}
Phase: {current.state.status} ({progress.tasks_done}/{progress.tasks_total})

💡 Suggestion: {suggestion.reason}
```

## In-Progress Features

If multiple features in progress, show them:

```
📋 Features in Progress:
  • 001-auth (implementation 3/8)
  • 002-payments (planning)
  • 003-notifications (specification)
```

## State Detection (from frontmatter)

| Status | Options |
|--------|---------|
| No `.spec/` | Initialize |
| No features | New Feature, Analyze Codebase |
| `clarification` | Resolve, Skip to Plan |
| `specification` | Create Plan, Validate |
| `planning` | Create Tasks, Validate |
| `implementation` | Continue, Check Progress |
| `complete` | Archive, New Feature |

## Options by State

**Not Initialized:**
- "Initialize" → Create `.spec/` directory structure

**Ready (no feature):**
- "New Feature" → `orbit-workflow` skill
- "Analyze Codebase" → `analyzing-codebase` agent

**Multiple Features (show AskUserQuestion):**
- List each in-progress feature with status
- "New Feature" option

**Clarification:**
- "Resolve Clarifications" → `orbit-workflow` skill (clarify)
- "Skip to Planning" → `orbit-workflow` skill (plan)

**Specification:**
- "Create Plan" → `orbit-workflow` skill (plan)
- "Validate Spec" → `validating-artifacts` agent

**Planning:**
- "Create Tasks" → `orbit-workflow` skill (tasks)
- "Validate Plan" → `validating-artifacts` agent

**Implementation:**
- "Continue Building" → `implementing-tasks` agent
- "Check Progress" → Show metrics summary
- "Validate" → `validating-artifacts` agent

**Complete:**
- "Archive Feature" → Move to `.spec/archive/`
- "Start New Feature" → `orbit-workflow` skill
- "Final Validation" → `validating-artifacts` agent

## Example Flow

```
User: /orbit

Claude:
  ██████╗ ██████╗ ██████╗ ██╗████████╗
  ...

Feature: User Authentication
Phase: implementation (3/10 tasks)

💡 Suggestion: Continue implementing User Authentication

📋 Other Features:
  • 002-payments (planning)

AskUserQuestion: "What would you like to do?"
- Continue Building (001-auth)
- Switch to 002-payments
- Check Progress
- New Feature
```

## Archive Flow

When user selects "Archive Feature":

```bash
source .claude/hooks/lib.sh
archive_feature "001-feature-name"
```

Then suggest next action from remaining in-progress features.
