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