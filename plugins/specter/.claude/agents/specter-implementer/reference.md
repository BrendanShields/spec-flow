# Flow Implementer: Reference Guide

## Parallel Execution Algorithm

```javascript
class ParallelExecutor {
  constructor(maxWorkers = 5) {
    this.maxWorkers = maxWorkers;
    this.activeWorkers = 0;
    this.queue = [];
    this.completed = [];
    this.failed = [];
  }

  async execute(tasks) {
    // Build dependency graph
    const graph = this.buildDependencyGraph(tasks);

    // Find parallelizable groups
    const groups = this.findParallelGroups(graph);

    // Execute groups in order
    for (const group of groups) {
      await this.executeGroup(group);
    }
  }

  findParallelGroups(graph) {
    // Topological sort with level grouping
    const groups = [];
    const visited = new Set();
    const levels = new Map();

    // Calculate levels for each node
    for (const task of graph.nodes) {
      if (!visited.has(task.id)) {
        this.calculateLevel(task, graph, levels, visited);
      }
    }

    // Group by level
    const maxLevel = Math.max(...levels.values());
    for (let level = 0; level <= maxLevel; level++) {
      const group = [];
      for (const [taskId, taskLevel] of levels) {
        if (taskLevel === level) {
          group.push(taskId);
        }
      }
      if (group.length > 0) {
        groups.push(group);
      }
    }

    return groups;
  }
}
```

## Error Recovery Patterns

**Exponential Backoff:** Retry with delays (1s, 2s, 4s, ...) up to max retries

**Alternative Approaches:** Try multiple strategies in priority order until success

**Partial Success:** Skip blocked tasks, continue with independent ones

## Performance Optimization

### File Operation Batching
- Group reads from same directory
- Batch writes to reduce I/O
- Use memory cache for frequently accessed files

### Test Execution Optimization
- Run fast unit tests first
- Parallel test suites when possible
- Skip redundant test runs

### Resource Management
- Monitor CPU usage
- Throttle parallel workers under load
- Queue management for large task lists

## JIRA Integration Protocol

### Status Transitions
```
To Do → In Progress → Code Review → Testing → Done
                ↓            ↓          ↓
              Blocked     Blocked    Failed
```

### Comment Templates
```markdown
**🤖 Flow Automated Update**

Task: ${taskId} - ${taskDescription}
Status: ${status}
Duration: ${duration}

${details}

---
*Automated by Flow Implementation Agent*
```

## Common Implementation Patterns

| Pattern | Steps |
|---------|-------|
| Service Creation | Interface → Logic → Errors → Tests → Docs |
| Database Migration | Backup → Script → Test → Execute → Verify |
| API Endpoint | Route → Validation → Handler → Errors → Tests |