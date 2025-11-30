# Orbit

Specification-driven development workflow. Detects state from artifacts and guides next action.

## Behavior

1. Check for context in system-reminder from SessionStart hook
2. If `initialized: false`, offer to initialize `.spec/` directory
3. Show status banner with suggestion
4. Present options based on state and in-progress features
5. Invoke skill or agent based on selection

## Context from SessionStart

The SessionStart hook provides context in a system-reminder. Look for:

```json
{"initialized": true, "features": [...], "suggestion": "..."}
```

If `initialized: false`, the `.spec/` directory doesn't exist - offer initialization.

## Initialization (Not Initialized)

When `.spec/` directory doesn't exist:

```
  ██████╗ ██████╗ ██████╗ ██╗████████╗
 ██╔═══██╗██╔══██╗██╔══██╗██║╚══██╔══╝
 ██║   ██║██████╔╝██████╔╝██║   ██║
 ██║   ██║██╔══██╗██╔══██╗██║   ██║
 ╚██████╔╝██║  ██║██████╔╝██║   ██║
  ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝   ╚═╝

Status: Not Initialized

Orbit enables specification-driven development for this project.
```

Present options:
- "Initialize" - Create `.spec/` directory structure
- "Learn More" - Explain the workflow

When user selects "Initialize":
1. Create directory structure:
   ```bash
   mkdir -p .spec/features .spec/architecture .spec/state .spec/archive
   echo '{"feature": null}' > .spec/state/session.json
   ```
2. Then invoke `orbit-workflow` skill to start first feature

## Status Banner

```
  ██████╗ ██████╗ ██████╗ ██╗████████╗
 ██╔═══██╗██╔══██╗██╔══██╗██║╚══██╔══╝
 ██║   ██║██████╔╝██████╔╝██║   ██║
 ██║   ██║██╔══██╗██╔══██╗██║   ██║
 ╚██████╔╝██║  ██║██████╔╝██║   ██║
  ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝   ╚═╝

Feature: {title or "none"}
Phase: {status} ({tasks_done}/{tasks_total})

Suggestion: {suggestion from context}
```

## In-Progress Features

If multiple features in progress, show them:

```
Features in Progress:
  - 001-auth (implementation 3/8)
  - 002-payments (planning)
  - 003-notifications (specification)
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
- "Initialize" - Create `.spec/` directory structure

**Ready (no feature):**
- "New Feature" - `managing-workflow` skill
- "Analyze Codebase" - `codebase-analyst` agent

**Multiple Features (show AskUserQuestion):**
- List each in-progress feature with status
- "New Feature" option

**Clarification:**
- "Resolve Clarifications" - `managing-workflow` skill (clarify)
- "Skip to Planning" - `managing-workflow` skill (plan)

**Specification:**
- "Create Plan" - `managing-workflow` skill (plan)
- "Validate Spec" - `artifact-validator` agent

**Planning:**
- "Create Tasks" - `managing-workflow` skill (tasks)
- "Validate Plan" - `artifact-validator` agent

**Implementation:**
- "Continue Building" - `task-implementer` agent
- "Check Progress" - Show metrics summary
- "Validate" - `artifact-validator` agent

**Complete:**
- "Archive Feature" - Move to `.spec/archive/`
- "Start New Feature" - `managing-workflow` skill
- "Final Validation" - `artifact-validator` agent

## Example Flow

```
User: /orbit

Claude:
  ██████╗ ██████╗ ██████╗ ██╗████████╗
  ...

Feature: User Authentication
Phase: implementation (3/10 tasks)

Suggestion: Continue implementing User Authentication

Other Features:
  - 002-payments (planning)

AskUserQuestion: "What would you like to do?"
- Continue Building (001-auth)
- Switch to 002-payments
- Check Progress
- New Feature
```

## Archive Flow

When user selects "Archive Feature":

1. Move feature directory:
   ```bash
   mv .spec/features/001-feature-name .spec/archive/
   ```
2. Clear session if this was current feature
3. Suggest next action from remaining in-progress features
