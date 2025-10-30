---
name: specter:tasks
description: Break down plan into executable tasks with dependencies. Use when 1) Technical plan complete and ready for implementation, 2) Need structured task list with priorities, 3) Identifying parallel work opportunities, 4) Creating JIRA subtasks, 5) Organizing work by user stories for incremental delivery. Generates tasks.md with T### IDs and [P] parallelization markers.
allowed-tools: Read, Write, Edit, Bash
---

# Flow Tasks

Break down implementation into executable, parallel-optimized tasks organized by user story.

## Core Capability

Transforms technical plans into actionable task lists:
- Loads `spec.md` (user stories) and `plan.md` (components)
- Maps components to user stories with priorities
- Generates `tasks.md` with phase organization
- Identifies parallel execution opportunities
- Creates JIRA subtasks (if enabled)

## Task Format

```
- [ ] T### [P] [US#] Description at absolute/file/path
```

| Component | Purpose | Example |
|-----------|---------|---------|
| `T###` | Sequential task ID | `T010` |
| `[P]` | Parallelizable marker (optional) | `[P]` |
| `[US#]` | User story label | `[US1]` |
| Description | Action + component | `Create User model` |
| File path | Absolute path | `at src/models/user.py` |

## Phase Organization

### Phase 1: Setup
Project initialization, dependencies, environment

### Phase 2: Foundation
Blocking prerequisites, base models, core utilities

### Phase 3+: User Stories (One per story)
- Grouped by priority (P1, P2, P3)
- Independently testable
- Can ship separately
- Includes goal, test criteria, tasks

**Example**:
```markdown
## Phase 3: US1 - User Authentication (P1)

**Goal**: Users can register and log in
**Independent Test**: Register → Login → Dashboard

### Tasks
- [ ] T010 [P] [US1] Create User model at src/models/user.py
- [ ] T011 [P] [US1] Create Auth service at src/services/auth.py
- [ ] T012 [US1] Implement /login at src/api/auth.py

### Parallel Opportunities
T010, T011 (different files, no dependencies)
```

### Final Phase: Polish
Performance optimization, documentation, deployment prep

## MCP Integration (JIRA)

When `SPECTER_ATLASSIAN_SYNC=enabled`, creates JIRA subtasks:
- Maps tasks to parent JIRA stories (from `spec.md`)
- Creates subtask for each `[US#]` task
- Adds labels: `flow-task`, `task-T###`, `parallel-ok`
- Updates `tasks.md` with JIRA IDs as comments
- Enables sprint planning, time tracking, burndown charts

See [REFERENCE.md](./REFERENCE.md#mcp-integration-jira-subtasks) for detailed sync process.

## Parallelization

Tasks marked `[P]` can run concurrently:
- Different files
- No shared dependencies
- Independent user stories

Sequential tasks (no `[P]`):
- Same file modifications
- Dependent data structures
- Must run in order

## Examples

See [EXAMPLES.md](./EXAMPLES.md) for:
- User story-based breakdown
- JIRA subtask creation workflow
- Parallel execution planning
- Dependency chain examples
- Minimal POC task lists

## Reference

See [REFERENCE.md](./REFERENCE.md) for:
- Complete task format specification
- Phase organization details
- Parallelization rules
- MCP/JIRA integration
- Dependency management
- Configuration options (`--simple`, `--filter`)
- Validation rules

## Phase Transition (Optional)

After successfully creating the task breakdown, check if interactive transitions are enabled:

```bash
source .specter/scripts/config.sh

if should_prompt_transitions; then
  # Show transition prompt using AskUserQuestion
fi
```

**If transitions enabled**, use AskUserQuestion to ask what to do next:

```json
{
  "questions": [{
    "question": "Task breakdown complete! What would you like to do next?",
    "header": "Next Step",
    "multiSelect": false,
    "options": [
      {
        "label": "Start Implementation",
        "description": "Execute tasks autonomously (specter:implement)"
      },
      {
        "label": "Review Tasks",
        "description": "Review the task breakdown first"
      },
      {
        "label": "Estimate Effort",
        "description": "Review time estimates and dependencies"
      },
      {
        "label": "Exit",
        "description": "Continue later"
      }
    ]
  }]
}
```

**Action based on selection**:
- "Start Implementation" → Automatically invoke specter:implement skill
- "Review Tasks" → Exit, let user review the tasks.md file
- "Estimate Effort" → Exit, let user analyze estimates
- "Exit" → Exit gracefully
- "Other" → Ask what command they want to run

## Related Skills

- **specter:plan**: Generate technical plan (run before)
- **specter:implement**: Execute tasks (run after)
- **specter:analyze**: Validate task completeness

## Validation

Test this skill:
```bash
scripts/validate.sh
```
