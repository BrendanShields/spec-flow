# Flow Implement: Reference Guide

## Task Format Specification

### Task Structure
```
- [ ] T### [P] [US#] Description at file/path
```

- `T###`: Sequential task ID (T001, T002...)
- `[P]`: Optional parallelization marker
- `[US#]`: User story reference (US1, US2...)
- `at file/path`: Absolute file path for the task

## Parallelization Rules

### Can Run in Parallel
- Different files
- No shared dependencies
- Independent user stories
- Read-only operations

### Must Run Sequentially
- Same file modifications
- Dependent data structures
- Ordered migrations
- Test → Implementation (TDD)

## Error Recovery Strategies

### Level 1: Retry
- Simple transient failures
- Network timeouts
- Race conditions

### Level 2: Alternative Approach
- Different implementation pattern
- Fallback libraries
- Simplified logic

### Level 3: Skip & Continue
- Non-critical features
- Optional enhancements
- Can complete independently

### Level 4: Rollback
- Critical failures
- Data corruption risk
- Breaking changes detected

## Configuration Options

```json
{
  "parallel": {
    "enabled": true,
    "maxWorkers": 5,
    "timeout": 300000
  },
  "errorRecovery": {
    "autoRetry": true,
    "maxRetries": 3,
    "backoffMultiplier": 2
  },
  "testing": {
    "runTests": true,
    "testFirst": false,
    "requirePassing": true
  },
  "jira": {
    "updateStatus": true,
    "addComments": true,
    "attachLogs": false
  }
}
```

## Performance Metrics

| Metric | Target | Measurement |
|--------|---------|------------|
| Task completion rate | >95% | Completed/Total |
| Parallel efficiency | >70% | Time saved/Theoretical |
| Error recovery success | >80% | Recovered/Failed |
| Test pass rate | 100% | Passing/Total |

## JIRA Status Mapping

| Task Status | JIRA Status | Trigger |
|-------------|-------------|---------|
| Pending | To Do | Initial state |
| In Progress | In Progress | Task starts |
| Completed | Done | Task succeeds |
| Failed | Blocked | After retries exhausted |
| Skipped | Won't Do | Dependency failed |

## MCP Integration Details

### Real-time JIRA Updates

When `SPECTER_ATLASSIAN_SYNC=enabled` in CLAUDE.md, automatically updates JIRA subtask status as tasks complete.

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

### JIRA Configuration

Enable status sync in CLAUDE.md:
```
SPECTER_ATLASSIAN_SYNC=enabled
SPECTER_JIRA_AUTO_TRANSITION=true       # Auto-move through workflow states
SPECTER_JIRA_ADD_COMMENTS=true          # Add implementation details
```