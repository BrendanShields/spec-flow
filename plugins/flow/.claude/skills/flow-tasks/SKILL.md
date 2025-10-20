---
name: flow:tasks
description: Generate dependency-ordered task breakdown organized by user story with parallel execution markers. Creates actionable tasks from specifications and technical plans.
---

# Flow Tasks: User Story-Based Task Generation

Break down implementation into executable, parallel-optimized tasks organized by user story.

## When to Use

- After `flow:plan` creates the technical design
- Ready to create detailed implementation breakdown
- Need parallel execution strategy

## What This Skill Does

1. **Loads** spec.md and plan.md
2. **Extracts** user stories with priorities (P1, P2, P3)
3. **Maps** components to user stories
4. **Generates** tasks.md with:
   - Phase 1: Setup (project initialization)
   - Phase 2: Foundation (blocking prerequisites)
   - Phase 3+: One phase per user story
   - Final Phase: Polish & cross-cutting
5. **Marks** parallelizable tasks with `[P]`
6. **Creates** dependency graph

## Task Format

```
- [ ] T001 [P] [US1] Description with absolute file path
```

Components:
- `T###`: Sequential task ID
- `[P]`: Parallelizable marker (optional)
- `[US#]`: User story label
- Absolute file path required

## Organization Strategy

**By User Story**:
- Each P1, P2, P3 story gets its own phase
- All related work grouped together
- Independently testable increments
- Can ship stories separately

## Example Output

```markdown
## Phase 3: User Story 1 - User Authentication (P1)

**Goal**: Users can register and log in
**Independent Test**: Create account → Login → See dashboard

### Tasks
- [ ] T010 [P] [US1] Create User model in src/models/user.py
- [ ] T011 [P] [US1] Create Auth service in src/services/auth.py
- [ ] T012 [US1] Implement login endpoint in src/api/auth.py
- [ ] T013 [US1] Add authentication middleware

### Parallel Opportunities
Tasks T010, T011 can run concurrently (different files)
```

## Configuration

```json
{
  "workflow": {
    "testsRequired": false  // Generate test tasks
  }
}
```

## Related Skills

- **flow:plan**: Generate technical plan (run first)
- **flow:implement**: Execute tasks (run after)
- **flow:analyze**: Validate task completeness
