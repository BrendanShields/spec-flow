---
name: flow:implement
description: Execute all tasks from tasks.md autonomously. Use when: 1) Tasks are ready and want automated implementation, 2) User says "implement/build/code this", 3) Resuming after interruption with --resume, 4) Building specific priority only (--filter=P1). Executes with parallel processing and marks tasks complete.
allowed-tools: Read, Write, Edit, Bash, Task, Grep, Glob
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

## MCP Integration (JIRA Status Updates)

If `FLOW_ATLASSIAN_SYNC=enabled` in CLAUDE.md, automatically updates JIRA subtask status as tasks complete:

### Real-time JIRA Updates

**When task starts**:
```javascript
// Mark task as in-progress
await mcp.jira.updateIssue({
  issueKey: taskJiraId,
  update: {
    status: { name: 'In Progress' },
    comment: 'Started by Flow autonomous implementation'
  }
});
```

**When task completes successfully**:
```javascript
// Mark as Done in tasks.md
markTaskComplete(taskId);

// Update JIRA
await mcp.jira.updateIssue({
  issueKey: taskJiraId,
  update: {
    status: { name: 'Done' },
    comment: `Completed by Flow\nFile: ${filePath}\nDuration: ${duration}ms`
  }
});
```

**When task fails**:
```javascript
// Keep task pending in tasks.md
// Update JIRA with error details
await mcp.jira.addComment({
  issueKey: taskJiraId,
  comment: `❌ Task failed after ${retries} attempts\nError: ${error.message}\nRetrying...`
});
```

### Progress Visibility

**Team sees real-time progress in JIRA**:
- Subtasks move from "To Do" → "In Progress" → "Done"
- Comments show execution details
- Sprint burndown updates automatically
- Team can follow along without checking local repo

### Parallel Execution Tracking

**Multiple subtasks in-progress simultaneously**:
```
JIRA Board View:
Story US1: User Authentication
  ├─ T010: Create User model         [In Progress] @flow-bot
  ├─ T011: Create Auth service       [In Progress] @flow-bot
  ├─ T012: Implement login endpoint  [To Do]
  └─ T013: Add authentication middleware [To Do]
```

### Benefits

- **Real-time visibility**: Team sees what's being implemented live
- **Progress tracking**: Sprint burndown updates automatically
- **Error transparency**: Failed tasks visible in JIRA comments
- **Audit trail**: Complete history of implementation in JIRA
- **Integration**: Works with existing JIRA workflows and automations

### Configuration

Enable status sync in CLAUDE.md:
```
FLOW_ATLASSIAN_SYNC=enabled
FLOW_JIRA_AUTO_TRANSITION=true       # Auto-move through workflow states
FLOW_JIRA_ADD_COMMENTS=true          # Add implementation details
```

## Subagents Used

- **flow-implementer**: Executes tasks autonomously with parallel processing and error recovery