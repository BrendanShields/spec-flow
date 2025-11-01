---
name: spec:implement
description: Use when implementing tasks, building features, executing code, user says "implement this", "build it", "execute tasks", "run implementation" - autonomously executes implementation tasks with parallel processing and progress tracking
allowed-tools: Read, Write, Edit
model: sonnet
---

# Implementation Executor

Execute implementation tasks from tasks.md with parallel processing, dependency resolution, and real-time progress tracking.

## What This Skill Does

- Reads task list from features/###-name/tasks.md
- Identifies parallelizable tasks (marked with [P])
- Delegates execution to spec:implementer subagent
- Tracks progress in .spec-state/current-session.md
- Moves completed tasks to .spec-memory/CHANGES-COMPLETED.md
- Runs tests after implementation phases
- Creates git commits (optional)
- Supports resumption after interruption

## When to Use

1. User says "implement", "build", "execute tasks", "run implementation"
2. tasks.md exists with pending tasks
3. Ready to execute implementation after planning
4. Resuming interrupted implementation (--continue)
5. Need parallel execution for independent tasks

## Execution Flow

### Phase 1: Validation
1. Use Read to check features/###-name/tasks.md exists
2. Use Read to verify .spec-state/current-session.md
3. Parse task format: `- [ ] T### [P?] [US#] Description path/file.ext`
4. Count pending tasks and identify filters (--filter=P1, --filter=US1)

### Phase 2: Analysis
1. Identify parallelizable tasks (marked with [P])
2. Build dependency graph from task ordering
3. Group by phase (Setup → Foundation → User Stories → Polish)
4. Calculate estimated completion time

### Phase 3: Delegation
1. Use Write to create .spec/implementation-context.md with:
   - Task list
   - Execution mode (serial/parallel)
   - Current phase
   - Progress checkpoint
2. Invoke spec:implementer subagent
3. Monitor progress (subagent updates current-session.md)

### Phase 4: Progress Tracking
1. Use Read to monitor .spec-state/current-session.md for updates
2. Display real-time progress:
   ```
   Progress: ████████░░ 80% (12/15 tasks)
   In Progress: T012 [P] [US2] Auth middleware
   Completed: 12 tasks
   Remaining: 3 tasks
   ```
3. Stream task completion notifications

### Phase 5: Validation & Cleanup
1. Use Read to check test results from subagent
2. Move completed tasks to .spec-memory/CHANGES-COMPLETED.md using Edit
3. Update .spec-memory/WORKFLOW-PROGRESS.md metrics
4. Create checkpoint in .spec-state/checkpoints/
5. Optional: Create git commit with completed changes

## Execution Modes

### Default Mode
Execute all pending P1 tasks sequentially:
```
spec:implement
```

### Parallel Mode
Enable parallel execution for [P] tasks:
```
spec:implement --parallel
```

### Filtered Execution
Execute specific tasks:
```
spec:implement --filter=P1          # Only P1 tasks
spec:implement --filter=US1.1       # Specific user story
```

### Resume Mode
Continue from interruption:
```
spec:implement --continue
```

## Error Handling

### Task Failures
- Subagent retries failed tasks (max 3 attempts)
- Logs failure details to implementation.log
- Continues with independent tasks
- Reports blocker to user for resolution

### Interruption Recovery
- Saves checkpoint before each phase
- Stores completed task IDs in session state
- Resume flag: `--continue` picks up from last task
- Preserves partial progress

### Validation Failures
- Runs tests after each phase completion
- Stops on test failures (unless --skip-tests)
- Shows test output and failed assertions
- Suggests fixes based on error patterns

## Output Format

### Success Output
```
Implementation Complete

Completed Tasks: 15/15
- Phase 1 (Setup): 3 tasks in 45s
- Phase 2 (Foundation): 5 tasks in 2m 15s
- Phase 3 (User Stories): 7 tasks in 4m 30s

Tests: All passing (92% coverage)
Files Modified: 23 files
Git Commit: abc1234 "Implement user authentication"

Next Steps:
- Run /validate to check consistency
- Run /spec-checklist for quality review
- Run /spec-metrics for performance baseline
```

### Progress Output (During Execution)
```
Executing Phase 2: Foundation [5 tasks]

[✓] T004 [US2] Create user service (23s)
[✓] T005 [US2] Add auth middleware (18s)
[→] T006 [P] [US2] JWT handling (in progress...)
[→] T007 [P] [US2] Rate limiting (in progress...)
[ ] T008 [US2] Session management (queued)

Progress: 40% (2/5 tasks) | Est. 2m remaining
```

### Error Output
```
Implementation Failed

Completed: 12/15 tasks
Failed Task: T013 [US2] Database migration
Error: Syntax error in migration file line 45

Blocker Details:
  File: src/migrations/20250131_users.sql
  Issue: Missing comma after column definition

Suggested Fix:
  Edit line 45 to add comma after username VARCHAR(255)

Resume Command:
  After fixing the error, run: spec:implement --continue
```

## Configuration

See shared/config-examples.md for detailed options.

Default settings:
- Parallel execution: Disabled (enable with --parallel)
- Test execution: Enabled (skip with --skip-tests)
- Git commits: Disabled (enable with --commit)
- Max parallel tasks: 4
- Retry attempts: 3

## Integration

### Subagent Communication
This skill delegates to spec:implementer subagent:
- Input: .spec/implementation-context.md
- Output: .spec/implementation.log, metrics.json
- Progress: Updates current-session.md in real-time

### State Management
See shared/state-management.md for state file structure.

Progress tracked in:
- `.spec-state/current-session.md` - Active progress
- `.spec-memory/CHANGES-COMPLETED.md` - Completion log
- `.spec-memory/WORKFLOW-PROGRESS.md` - Metrics

### Workflow Integration
Follows workflow sequence:
1. spec:specify → 2. spec:plan → 3. spec:tasks → **4. spec:implement** → 5. validate

## Examples

See examples.md for:
- Serial execution workflow
- Parallel execution with 3 concurrent tasks
- Resume after interruption scenario
- Filtered execution (P1 only, specific user story)
- Error recovery and retry

## Reference

See reference.md for:
- Subagent coordination protocol
- Dependency graph algorithm
- Parallel execution scheduler
- Error recovery strategies
- Test execution pipeline
- Performance optimization techniques
