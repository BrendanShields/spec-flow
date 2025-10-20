---
name: flow:implement
description: Autonomously execute implementation tasks with parallel processing, intelligent error recovery, and real-time progress tracking. Use the flow-implementer subagent for maximum efficiency.
---

# Flow Implement: Autonomous Task Execution

Execute implementation tasks from `tasks.md` with parallel processing and intelligent error handling.

## When to Use

- After generating tasks with `flow:tasks`
- Ready to build the actual implementation
- Want autonomous execution with minimal intervention

## What This Skill Does

1. **Loads** tasks.md and parses task structure
2. **Validates** prerequisites (checklists, dependencies)
3. **Executes** tasks using `flow-implementer` subagent:
   - Parallel execution of independent tasks
   - Dependency resolution
   - Error recovery with retry logic
4. **Tracks** progress in real-time
5. **Marks** completed tasks as `[X]` in tasks.md
6. **Reports** final status and metrics

## Execution Strategy

### Phase-by-Phase
1. **Phase 1: Setup** - Project initialization, dependencies
2. **Phase 2: Foundation** - Core infrastructure, base components
3. **Phase 3+: User Stories** - One phase per story (P1, P2, P3)
4. **Final Phase: Polish** - Optimization, documentation

### Parallel Execution
Tasks marked `[P]` execute concurrently when:
- Modifying different files
- No shared dependencies
- Different user stories

```
⚡ Running 5 tasks in parallel:
[T012] Creating User model...      ███░░ 60%
[T013] Creating Auth service...    ██░░░ 40%
[T014] Setting up database...      ████░ 80%
```

### Error Recovery
- **Auto-retry**: 3 attempts with exponential backoff
- **Alternative approaches**: Try different implementation strategies
- **Partial success**: Continue with independent tasks
- **Rollback**: Revert on critical failures

## Configuration

```json
{
  "implementer": {
    "parallel": {
      "enabled": true,
      "maxWorkers": 5
    },
    "errorRecovery": {
      "autoRetry": true,
      "maxRetries": 3
    },
    "testing": {
      "runTests": true,
      "testFirst": false  // TDD mode
    }
  }
}
```

## Subagents Used

- **flow-implementer**: Executes tasks autonomously with parallel processing and error recovery