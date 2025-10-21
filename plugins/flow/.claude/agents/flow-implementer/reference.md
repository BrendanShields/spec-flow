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

### Pattern 1: Exponential Backoff
```javascript
async function retryWithBackoff(fn, maxRetries = 3) {
  let lastError;
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      const delay = Math.min(1000 * Math.pow(2, i), 10000);
      await sleep(delay);
    }
  }
  throw lastError;
}
```

### Pattern 2: Alternative Approaches
```javascript
const strategies = [
  () => implementWithLibraryA(),
  () => implementWithLibraryB(),
  () => implementCustomSolution()
];

for (const strategy of strategies) {
  try {
    return await strategy();
  } catch (error) {
    continue; // Try next strategy
  }
}
```

### Pattern 3: Partial Success Handling
```javascript
async function executeWithPartialSuccess(tasks) {
  const results = {
    succeeded: [],
    failed: [],
    skipped: []
  };

  for (const task of tasks) {
    if (task.dependencies.some(d => results.failed.includes(d))) {
      results.skipped.push(task);
      continue;
    }

    try {
      await executeTask(task);
      results.succeeded.push(task);
    } catch (error) {
      results.failed.push(task);
      if (task.critical) {
        throw error; // Fail fast on critical tasks
      }
    }
  }

  return results;
}
```

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

### Pattern: Service Creation
1. Create interface/contract
2. Implement core logic
3. Add error handling
4. Write tests
5. Add documentation

### Pattern: Database Migration
1. Backup existing data
2. Create migration script
3. Test on sample data
4. Execute migration
5. Verify integrity

### Pattern: API Endpoint
1. Define route
2. Add validation
3. Implement handler
4. Add error responses
5. Write integration tests
6. Update OpenAPI spec