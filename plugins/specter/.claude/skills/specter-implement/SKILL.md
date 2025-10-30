---
name: specter:implement
description: Execute all tasks from tasks.md autonomously. Use when 1) Tasks are ready and want automated implementation, 2) User says "implement/build/code this", 3) Resuming after interruption with --resume, 4) Building specific priority only (--filter=P1), 5) Need autonomous code generation with test execution. Executes with parallel processing and marks tasks complete.
allowed-tools: Read, Write, Edit, Bash, Task, Grep, Glob
---

# Flow Implement: Autonomous Task Execution

Execute implementation tasks from `tasks.md` with parallel processing and intelligent error handling.

## When to Use

- After generating tasks with `specter:tasks`
- Ready to build the actual implementation
- Want autonomous execution with minimal intervention

## What This Skill Does

1. **Loads** tasks.md and parses task structure
2. **Validates** prerequisites (checklists, dependencies)
3. **Executes** tasks using `specter-implementer` subagent:
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

## MCP Integration (JIRA)

When `SPECTER_ATLASSIAN_SYNC=enabled`, automatically syncs task progress to JIRA:
- Updates subtask status (To Do → In Progress → Done)
- Adds implementation comments with file paths and duration
- Provides real-time visibility for team
- Tracks parallel execution across multiple subtasks

See [reference.md](./reference.md#mcp-integration-details) for detailed integration patterns.

## Examples

See [examples.md](./examples.md) for:
- Parallel task execution
- Error recovery strategies
- Dependency resolution
- JIRA integration in action

## Reference

See [reference.md](./reference.md) for:
- Task format specification
- Parallelization rules
- Error recovery strategies
- Configuration options
- Performance metrics
- JIRA status mapping

## Related Skills

- **specter-implementer** (subagent): Executes tasks autonomously
- **specter:tasks**: Generates implementation tasks
- **specter:checklist**: Quality gates before implementation

## Validation

Test this skill:
```bash
scripts/validate.sh
```