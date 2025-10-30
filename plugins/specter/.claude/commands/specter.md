# /specter - Unified Workflow Command

Single entry point for all Specter workflow operations.

## Usage

```bash
/specter                       # Context-aware: continues from current phase
/specter init                  # Initialize Specter in project
/specter "Feature description" # Create specification
/specter plan                  # Create technical plan
/specter tasks                 # Break down into tasks
/specter implement             # Execute implementation
```

## Command Behavior

This command intelligently routes based on:
1. Current workflow phase (reads from `.specter-state/session.json`)
2. Explicit subcommands (init, plan, tasks, implement, etc.)
3. Free text input (auto-detects specification intent)

## Implementation

When invoked:

1. **Detect context**: Read `.specter-state/session.json` to determine current phase
2. **Route appropriately**:
   - No arguments → Continue from current phase
   - `init` → Route to specter-init skill
   - `plan` → Route to specter-plan skill
   - `tasks` → Route to specter-tasks skill
   - `implement` → Route to specter-implement skill
   - `analyze`/`validate` → Route to specter-analyze skill
   - Free text → Route to specter-specify skill
   - `help`/`--help` → Show contextual help

3. **Handle errors**: Provide helpful error messages if routing fails

## Examples

```bash
# New project
/specter init

# Create spec (both work)
/specter "Add user authentication"
/specter specify "Add user authentication"

# Continue workflow (context-aware)
/specter  # In spec phase → creates plan
/specter  # In plan phase → creates tasks
/specter  # In tasks phase → begins implementation

# Explicit commands
/specter plan
/specter tasks
/specter implement
```

## Routing Logic

```
Input: /specter [args...]

1. Parse args
2. If no args:
   - Read session.json
   - Determine current phase
   - Route to next logical step

3. If args start with known subcommand:
   - Route to corresponding skill

4. If args are free text:
   - Treat as specification
   - Route to specter-specify

5. If unknown:
   - Show help
```

## Context Detection

Phase detection logic:
- `uninitialized` → Suggest init
- `specification` → Suggest plan
- `planning` → Suggest tasks
- `tasks` → Suggest implement
- `implementation` → Suggest continue

## Error Handling

- If `.specter-state/` doesn't exist → Suggest `/specter init`
- If session.json is invalid → Show error, suggest validation
- If skill not found → Show available skills

---

**Note**: This is the unified entry point that replaces the following v2.1 commands:
- `/specter-init` → `/specter init`
- `/specter-specify` → `/specter "text"` or `/specter specify`
- `/specter-plan` → `/specter plan`
- `/specter-tasks` → `/specter tasks`
- `/specter-implement` → `/specter implement`

Old commands still work but show deprecation warnings.
