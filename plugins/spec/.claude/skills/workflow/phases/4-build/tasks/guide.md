---
name: spec:tasks
description: Use when user requests "create tasks", "break down plan", "generate task list", "implementation breakdown", or mentions task dependencies - transforms technical plan into executable task list with priorities, dependencies, and parallel work markers
allowed-tools: Read, Write, Edit, Bash
---

# Task Breakdown Generator

Breaks down technical plan into executable tasks with priorities, dependencies, and parallel work opportunities.

## What This Skill Does

- Reads plan.md and spec.md to understand requirements and technical approach
- Generates tasks.md with unique task IDs (T001, T002, etc.)
- Assigns priorities (P1/P2/P3) based on user story priorities
- Identifies task dependencies and execution order
- Marks parallel-executable tasks with [P] markers
- Groups tasks by user stories from spec
- Updates .spec-memory/CHANGES-PLANNED.md
- Optional: Creates issues in JIRA/Linear/GitHub via MCP if configured

## When to Use

1. User says "create tasks", "break down the plan", "generate task list"
2. After spec:plan phase completes
3. User requests "implementation breakdown" or "what tasks needed"
4. Before starting spec:implement phase
5. When updating requirements require task re-evaluation
6. User asks "what needs to be done" or "task dependencies"

## Execution Flow

### Phase 1: Load Context

1. **Read current session state**
   - Load `.spec-state/current-session.md` to get active feature
   - Extract feature ID and current phase
   - Verify feature exists and plan phase is complete

2. **Load feature artifacts**
   - Read `features/###-name/spec.md` for user stories and priorities
   - Read `features/###-name/plan.md` for technical approach
   - Parse user stories (US#.#) and priorities (P1/P2/P3)

3. **Validate prerequisites**
   - Ensure plan.md exists and is complete
   - Ensure spec.md has user stories defined
   - Check no blocking [CLARIFY] tags remain

### Phase 2: Generate Tasks

1. **Break down by user story**
   - For each user story in spec.md:
     - Extract technical requirements from plan.md
     - Break into atomic tasks (1-4 hours each)
     - Assign task IDs sequentially (T001, T002, ...)
     - Inherit priority from user story

2. **Structure each task**
   ```markdown
   ## Task T###: [Clear action verb] [specific outcome]
   - Priority: P1|P2|P3 (from user story)
   - Estimate: X hours (1-4 hours per task)
   - Dependencies: T###, T### | None
   - Parallel: [P] (if can run concurrently)
   - Files: src/path/to/file.ext
   - User Story: US#.#
   ```

3. **Identify dependencies**
   - Analyze task inputs/outputs
   - Mark tasks that require other tasks to complete first
   - Create dependency chains (T001 → T002 → T003)
   - Detect circular dependencies and warn

4. **Mark parallel work**
   - Identify tasks with no shared dependencies
   - Add [P] marker to task title
   - Group parallel-executable tasks in section
   - Estimate time savings from parallelization

### Phase 3: Write Artifacts

1. **Create tasks.md**
   - Use Write tool to create `features/###-name/tasks.md`
   - Structure: Header → Summary → Grouped Tasks → Dependencies Graph
   - See EXAMPLES.md for complete format

2. **Update state files**
   - Append task list to `.spec-memory/CHANGES-PLANNED.md`
   - Update `.spec-state/current-session.md` phase to "tasks_complete"
   - Update `.spec-memory/WORKFLOW-PROGRESS.md` with task count

3. **Optional: Create external issues**
   - If MCP configured (check CLAUDE.md), ask user preference
   - Use MCP tools to create JIRA/Linear/GitHub issues
   - Store issue references in tasks.md metadata
   - See `shared/integration-patterns.md` for MCP details

### Phase 4: Validate and Report

1. **Validate task list**
   - Check all user stories have tasks
   - Verify no orphaned tasks
   - Ensure P1 tasks cover critical path
   - Check estimates are reasonable (1-4h range)

2. **Generate summary report**
   ```
   ✓ Tasks Created: X tasks
   ✓ By Priority: P1 (X), P2 (X), P3 (X)
   ✓ Parallel Groups: X groups (Y% time savings)
   ✓ Critical Path: T### → T### → T### (X hours)
   ✓ Total Estimate: X hours

   Next: Run spec:implement to execute tasks
   ```

3. **Save checkpoint**
   - Create timestamped checkpoint in `.spec-state/checkpoints/`
   - Include task list snapshot

## Error Handling

**plan.md not found**:
- Check if spec:plan has run
- Prompt user to run spec:plan first
- Offer to run spec:plan automatically

**No user stories in spec**:
- Warn user spec.md may be incomplete
- Offer to run spec:clarify to add stories
- Allow proceeding with plan-only breakdown

**Circular dependencies detected**:
- Report cycle: T001 → T003 → T005 → T001
- Ask user to clarify execution order
- Suggest breaking cycle point

**MCP sync fails**:
- Log error but continue locally
- Save tasks.md successfully
- Notify user of sync failure
- Provide manual sync instructions

## Output Format

Creates `features/###-name/tasks.md`:

```markdown
# Tasks: [Feature Name]

**Feature**: ###-feature-name
**Created**: YYYY-MM-DD HH:MM
**Total Tasks**: X
**Estimated Time**: X hours

## Summary

- **P1 Tasks**: X (Y hours) - Must complete
- **P2 Tasks**: X (Y hours) - Should complete
- **P3 Tasks**: X (Y hours) - Nice to have
- **Parallel Groups**: X groups
- **Critical Path**: T### → T### → T### (X hours)

## User Story US1.1: [Story Name]

### Task T001: [Action verb] [outcome]
- Priority: P1
- Estimate: 2 hours
- Dependencies: None
- Parallel: [P]
- Files: src/component.ts
- User Story: US1.1

**Description**:
Clear description of what to implement.

**Acceptance Criteria**:
- [ ] Criterion 1
- [ ] Criterion 2

[More tasks grouped by user story...]

## Dependency Graph

```
US1.1: T001 [P] → T003 → T005
US1.2: T002 [P] → T004 → T005
US1.3: T006 → T007
```

## Parallel Work Opportunities

**Group 1** (start immediately):
- T001: Setup infrastructure [P]
- T002: Create UI components [P]

**Group 2** (after Group 1):
- T003: Integrate backend [P]
- T004: Add validation [P]

## Next Steps

1. Review task breakdown
2. Run `spec:implement` to execute
3. Track progress in current-session.md
```

Updates `.spec-memory/CHANGES-PLANNED.md` with task entries.

## Templates Used

This function uses the following templates:

**Primary Template**:
- `templates/feature-artifacts/tasks-template.md` → `features/###-name/tasks.md`

**Purpose**: Provides structure for task breakdown with IDs, dependencies, priorities, and estimates

**Customization**:
1. Copy template to `.spec/templates/tasks-template.md` in your project
2. Modify task format, add custom fields (e.g., assignee, sprint)
3. tasks/ will automatically use your custom template

**Template includes**:
- Task ID format (T001, T002, etc.)
- Task description structure
- Dependency notation (T002 → T001)
- Priority markers (P1/P2/P3)
- Parallel indicators [P]
- Effort estimation format
- Acceptance criteria per task
- Testing requirements

**See also**: `templates/README.md` for complete template documentation

## Integration Points

**Workflow**: For phase patterns, see `shared/workflow-patterns.md`

**State**: For state file updates, see `shared/state-management.md`

**MCP**: For external issue sync, see `shared/integration-patterns.md`

**Examples**: For complete scenarios, see EXAMPLES.md

**Reference**: For task format specs, see REFERENCE.md

---

**Token Budget**: ~1,450 tokens
**Progressive Disclosure**: Core logic here, examples in EXAMPLES.md, specs in REFERENCE.md
