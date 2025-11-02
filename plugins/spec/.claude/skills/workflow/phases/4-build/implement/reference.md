# implement phase - Technical Reference

Technical implementation details, algorithms, and coordination protocols.

## Subagent Coordination Protocol

### Communication Flow

```
implement phase (skill)
    ↓ [Creates context file]
{config.paths.spec_root}/implementation-context.md
    ↓ [Invokes]
implement phaseer (subagent)
    ↓ [Updates progress]
{config.paths.state}/current-session.md
    ↓ [Reads progress]
implement phase (skill)
    ↓ [Reports to user]
Real-time progress display
```

### Context File Format

**`{config.paths.spec_root}/implementation-context.md`**:
```markdown
# Implementation Context

## Configuration
- Mode: parallel|serial
- Filter: P1|P2|P3|US#
- Resume: true|false
- Skip Tests: true|false
- Max Workers: 4

## Task List
[Parsed from tasks.md]
- T001 [P1] [US1] Description path/file.ext
- T002 [P] [P1] [US2] Description path/file.ext
...

## State
- Current Feature: 001-feature-name
- Current Phase: implementation
- Checkpoint: {config.paths.state}/checkpoints/latest.md
- Completed Tasks: [T001, T002, ...]
- Failed Tasks: [T005: error details]

## Execution Plan
Phase 1: Sequential [T001-T003]
Phase 2: Parallel [T004, T005, T006, T007]
Phase 3: Sequential [T008-T010]
```

### Progress Updates

Subagent updates `current-session.md` in real-time:
```markdown
## Current Task
- Task ID: T007
- Description: Database migration
- Status: in_progress
- Started: 2025-10-31T14:23:15Z
- Progress: 45% (applying schema changes...)

## Recently Completed
- T006 [✓] 14:22:58 (15s)
- T005 [✓] 14:22:42 (12s)
- T004 [✓] 14:22:28 (18s)
```

Skill polls this file every 2 seconds for display updates.

---

## Dependency Graph Algorithm

### Graph Construction

**Input**: Ordered task list from tasks.md
**Output**: Directed acyclic graph (DAG) with dependencies

```javascript
// Pseudocode
function buildDependencyGraph(tasks) {
  const graph = new Map();
  const groups = groupTasksByPhase(tasks);

  for (const phase of groups) {
    for (let i = 0; i < phase.tasks.length; i++) {
      const task = phase.tasks[i];
      const deps = [];

      // Same file dependency
      const samePath = phase.tasks.slice(0, i)
        .find(t => t.path === task.path);
      if (samePath) deps.push(samePath.id);

      // Same user story dependency (unless [P])
      if (!task.parallel) {
        const sameStory = phase.tasks.slice(0, i)
          .find(t => t.story === task.story);
        if (sameStory) deps.push(sameStory.id);
      }

      // Explicit dependencies from description
      const explicitDeps = parseExplicitDeps(task.description);
      deps.push(...explicitDeps);

      graph.set(task.id, {
        task,
        dependencies: deps,
        dependents: []
      });
    }
  }

  // Build reverse edges (dependents)
  for (const [id, node] of graph) {
    for (const depId of node.dependencies) {
      graph.get(depId).dependents.push(id);
    }
  }

  return graph;
}
```

### Parallelization Detection

**Algorithm**: Identifies tasks that can run concurrently

```javascript
function identifyParallelGroups(graph) {
  const groups = [];
  const visited = new Set();

  // Topological sort with level grouping
  const levels = [];
  const queue = [];

  // Find tasks with no dependencies (level 0)
  for (const [id, node] of graph) {
    if (node.dependencies.length === 0) {
      queue.push(id);
    }
  }

  while (queue.length > 0) {
    const level = [];
    const nextQueue = [];

    for (const id of queue) {
      if (visited.has(id)) continue;

      const node = graph.get(id);

      // Check if all dependencies completed
      const depsComplete = node.dependencies
        .every(depId => visited.has(depId));

      if (depsComplete) {
        level.push(node.task);
        visited.add(id);

        // Add dependents to next queue
        nextQueue.push(...node.dependents);
      }
    }

    if (level.length > 0) {
      levels.push(level);
    }

    queue.splice(0, queue.length, ...nextQueue);
  }

  // Group parallelizable tasks within each level
  for (const level of levels) {
    const parallel = level.filter(t => t.parallel);
    const sequential = level.filter(t => !t.parallel);

    // Further split parallel by resource conflicts
    const parallelGroups = splitByResources(parallel);

    for (const group of parallelGroups) {
      groups.push({
        type: 'parallel',
        tasks: group
      });
    }

    for (const task of sequential) {
      groups.push({
        type: 'sequential',
        tasks: [task]
      });
    }
  }

  return groups;
}

function splitByResources(tasks) {
  const groups = [];
  const resources = new Map(); // path -> task

  for (const task of tasks) {
    let assigned = false;

    for (const group of groups) {
      // Check if task conflicts with any in group
      const conflicts = group.some(t =>
        t.path === task.path || // Same file
        sharesDependency(t, task) // Shared resource
      );

      if (!conflicts) {
        group.push(task);
        assigned = true;
        break;
      }
    }

    if (!assigned) {
      groups.push([task]);
    }
  }

  return groups;
}
```

---

## Parallel Execution Scheduler

### Worker Pool Management

```javascript
class WorkerPool {
  constructor(maxWorkers = 4) {
    this.maxWorkers = maxWorkers;
    this.activeWorkers = 0;
    this.queue = [];
    this.results = new Map();
  }

  async execute(tasks) {
    // Add tasks to queue
    this.queue.push(...tasks);

    // Start workers up to max
    const workers = [];
    for (let i = 0; i < Math.min(this.maxWorkers, tasks.length); i++) {
      workers.push(this.worker());
    }

    // Wait for all tasks to complete
    await Promise.all(workers);

    return this.results;
  }

  async worker() {
    while (this.queue.length > 0) {
      const task = this.queue.shift();
      if (!task) break;

      this.activeWorkers++;

      try {
        const result = await this.executeTask(task);
        this.results.set(task.id, {
          status: 'success',
          result,
          duration: result.duration
        });
      } catch (error) {
        this.results.set(task.id, {
          status: 'failed',
          error: error.message,
          retryable: this.isRetryable(error)
        });
      } finally {
        this.activeWorkers--;
      }
    }
  }

  async executeTask(task) {
    const startTime = Date.now();

    // Invoke implement phaseer subagent for this task
    await invokeSubagent('implement phaseer', {
      task: task,
      mode: 'single'
    });

    return {
      duration: Date.now() - startTime
    };
  }

  isRetryable(error) {
    const retryableErrors = [
      'ECONNREFUSED',
      'ETIMEDOUT',
      'ENOTFOUND',
      'RATE_LIMITED'
    ];

    return retryableErrors.some(e =>
      error.message.includes(e)
    );
  }
}
```

### Load Balancing

```javascript
function balanceTasks(tasks, workerCount) {
  // Sort tasks by estimated duration (longest first)
  const sorted = tasks.slice().sort((a, b) =>
    estimateDuration(b) - estimateDuration(a)
  );

  // Assign to workers round-robin
  const workers = Array.from({ length: workerCount }, () => []);
  const loads = Array(workerCount).fill(0);

  for (const task of sorted) {
    // Find worker with minimum load
    const minLoadIndex = loads.indexOf(Math.min(...loads));

    workers[minLoadIndex].push(task);
    loads[minLoadIndex] += estimateDuration(task);
  }

  return workers;
}

function estimateDuration(task) {
  // Estimate based on task type and complexity
  const patterns = {
    'model': 15, // seconds
    'service': 20,
    'controller': 12,
    'route': 10,
    'test': 18,
    'migration': 8,
    'docs': 5
  };

  for (const [keyword, duration] of Object.entries(patterns)) {
    if (task.description.toLowerCase().includes(keyword)) {
      return duration;
    }
  }

  return 12; // default
}
```

---

## Error Recovery Strategies

### Retry Logic

```javascript
async function executeWithRetry(task, maxRetries = 3) {
  let lastError;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const result = await executeTask(task);

      if (attempt > 1) {
        logRecovery(task, attempt);
      }

      return result;

    } catch (error) {
      lastError = error;

      if (!isRetryable(error)) {
        throw error; // Non-retryable, fail immediately
      }

      if (attempt < maxRetries) {
        const delay = getBackoffDelay(attempt);
        await sleep(delay);
        logRetry(task, attempt, delay, error);
      }
    }
  }

  // All retries exhausted
  throw new RetryExhaustedError(task, lastError, maxRetries);
}

function getBackoffDelay(attempt) {
  // Exponential backoff with jitter
  const base = 1000; // 1 second
  const exponential = Math.pow(2, attempt - 1) * base;
  const jitter = Math.random() * 500; // 0-500ms

  return Math.min(exponential + jitter, 10000); // max 10s
}
```

### Alternative Approaches

```javascript
const alternativeStrategies = {
  'npm_install_failed': [
    () => exec('npm ci'),
    () => exec('yarn install'),
    () => exec('npm install --legacy-peer-deps')
  ],

  'lint_failed': [
    () => exec('eslint --fix .'),
    () => exec('prettier --write .'),
    () => { /* skip linting */ }
  ],

  'test_failed': [
    () => exec('npm test -- --forceExit'),
    () => exec('npm test -- --runInBand'),
    () => { /* report and continue */ }
  ],

  'build_failed': [
    () => exec('npm run build -- --no-cache'),
    () => exec('rm -rf dist && npm run build'),
    () => { /* fallback to dev mode */ }
  ]
};

async function executeWithAlternatives(task, error) {
  const errorType = classifyError(error);
  const strategies = alternativeStrategies[errorType];

  if (!strategies) {
    throw error; // No alternatives available
  }

  for (let i = 0; i < strategies.length; i++) {
    try {
      logAlternative(task, errorType, i + 1);
      await strategies[i]();
      return; // Success
    } catch (altError) {
      if (i === strategies.length - 1) {
        throw altError; // All alternatives failed
      }
    }
  }
}
```

### Partial Success Handling

```javascript
function handlePartialSuccess(results, graph) {
  const completed = [];
  const failed = [];
  const blocked = [];

  for (const [taskId, result] of results) {
    if (result.status === 'success') {
      completed.push(taskId);
    } else {
      failed.push(taskId);

      // Find all tasks blocked by this failure
      const dependents = findAllDependents(taskId, graph);
      blocked.push(...dependents);
    }
  }

  // Identify tasks that can still proceed
  const independent = findIndependentTasks(failed, blocked, graph);

  return {
    completed,
    failed,
    blocked,
    canProceed: independent
  };
}

function findAllDependents(taskId, graph) {
  const dependents = new Set();
  const queue = [taskId];

  while (queue.length > 0) {
    const id = queue.shift();
    const node = graph.get(id);

    for (const dependent of node.dependents) {
      if (!dependents.has(dependent)) {
        dependents.add(dependent);
        queue.push(dependent);
      }
    }
  }

  return Array.from(dependents);
}

function findIndependentTasks(failed, blocked, graph) {
  const cannotExecute = new Set([...failed, ...blocked]);
  const independent = [];

  for (const [id, node] of graph) {
    if (cannotExecute.has(id)) continue;

    // Check if all dependencies completed
    const depsOk = node.dependencies.every(depId =>
      !cannotExecute.has(depId)
    );

    if (depsOk) {
      independent.push(id);
    }
  }

  return independent;
}
```

---

## Test Execution Pipeline

### Test Strategy

```javascript
const testStrategy = {
  // When to run tests
  triggers: {
    afterPhase: true,     // After each implementation phase
    afterTask: false,     // After individual tasks (too slow)
    beforeCommit: true,   // Before git commit
    onDemand: true        // When user requests
  },

  // What tests to run
  scope: {
    unit: true,           // Unit tests (fast)
    integration: true,    // Integration tests (medium)
    e2e: false,          // E2E tests (slow, optional)
    coverage: true        // Track coverage
  },

  // How to handle failures
  failureMode: {
    stopOnFailure: true,  // Stop implementation
    continueOnWarning: true,
    reportOnly: false     // Just report, don't stop
  }
};
```

### Test Execution

```javascript
async function runTests(phase, tasks) {
  const testFiles = identifyTestFiles(tasks);

  if (testFiles.length === 0) {
    return { status: 'skipped', reason: 'no tests' };
  }

  const results = {
    passed: 0,
    failed: 0,
    skipped: 0,
    duration: 0,
    coverage: null,
    failures: []
  };

  const startTime = Date.now();

  try {
    // Run test suite
    const output = await exec(
      `npm test -- ${testFiles.join(' ')} --coverage`
    );

    // Parse results
    const parsed = parseTestOutput(output);
    Object.assign(results, parsed);

    results.status = parsed.failed > 0 ? 'failed' : 'passed';

  } catch (error) {
    results.status = 'error';
    results.error = error.message;
  } finally {
    results.duration = Date.now() - startTime;
  }

  return results;
}

function identifyTestFiles(tasks) {
  const testFiles = new Set();

  for (const task of tasks) {
    // Direct test file
    if (task.path.includes('test') || task.path.includes('spec')) {
      testFiles.add(task.path);
    }

    // Corresponding test for implementation file
    const testPath = inferTestPath(task.path);
    if (testPath && fileExists(testPath)) {
      testFiles.add(testPath);
    }
  }

  return Array.from(testFiles);
}

function inferTestPath(filePath) {
  // src/services/auth.js → tests/services/auth.test.js
  const patterns = [
    path => path.replace('/src/', '/tests/').replace('.js', '.test.js'),
    path => path.replace('.js', '.spec.js'),
    path => path.replace('/src/', '/__tests__/')
  ];

  for (const pattern of patterns) {
    const testPath = pattern(filePath);
    if (fileExists(testPath)) return testPath;
  }

  return null;
}
```

---

## Performance Optimization

### Caching Strategy

```javascript
const cache = {
  // Compiled code cache
  compiled: new Map(), // path -> compiled output

  // Test fixtures
  fixtures: new Map(), // testId -> fixture data

  // Dependency resolution
  dependencies: new Map(), // package -> resolved version

  // File read cache (for frequently accessed files)
  files: new LRUCache({ max: 100 })
};

function getCachedOrExecute(key, factory, ttl = 3600) {
  if (cache.has(key)) {
    const entry = cache.get(key);
    if (Date.now() - entry.timestamp < ttl * 1000) {
      return entry.value;
    }
  }

  const value = factory();
  cache.set(key, {
    value,
    timestamp: Date.now()
  });

  return value;
}
```

### Resource Management

```javascript
class ResourceManager {
  constructor() {
    this.pools = {
      database: new ConnectionPool({ max: 10 }),
      http: new ConnectionPool({ max: 20 })
    };
    this.tempFiles = new Set();
  }

  async acquire(resource, config) {
    const pool = this.pools[resource];
    if (pool) {
      return await pool.acquire();
    }
    throw new Error(`Unknown resource: ${resource}`);
  }

  release(resource, handle) {
    const pool = this.pools[resource];
    if (pool) {
      pool.release(handle);
    }
  }

  trackTempFile(path) {
    this.tempFiles.add(path);
  }

  async cleanup() {
    // Close all pools
    for (const pool of Object.values(this.pools)) {
      await pool.drain();
    }

    // Delete temp files
    for (const path of this.tempFiles) {
      await fs.unlink(path).catch(() => {});
    }
  }
}
```

---

## State File Formats

### implementation-context.md
```markdown
# Implementation Context
mode: parallel
filter: P1
maxWorkers: 4
skipTests: false
resume: false

## Tasks
- T001 [P1] [US1] Create user model src/models/user.js
- T002 [P] [P1] [US2] Create profile model src/models/profile.js

## Execution Plan
### Phase 1: Sequential
- T001

### Phase 2: Parallel (2 workers)
- T002
- T003

## Checkpoint
completed: [T001]
failed: []
blocked: []
```

### implementation.log
```
2025-10-31T14:20:00Z [INFO] Implementation started
2025-10-31T14:20:00Z [INFO] Loaded 15 tasks from tasks.md
2025-10-31T14:20:01Z [INFO] Built dependency graph: 15 nodes, 23 edges
2025-10-31T14:20:01Z [INFO] Identified 4 parallel groups
2025-10-31T14:20:01Z [TASK] T001 started
2025-10-31T14:20:13Z [TASK] T001 completed (12s)
2025-10-31T14:20:13Z [PARALLEL] Starting batch with 3 workers
2025-10-31T14:20:13Z [TASK] T002 started (worker 1)
2025-10-31T14:20:13Z [TASK] T003 started (worker 2)
2025-10-31T14:20:13Z [TASK] T004 started (worker 3)
```

### implementation-metrics.json
```json
{
  "startTime": "2025-10-31T14:20:00Z",
  "endTime": "2025-10-31T14:25:32Z",
  "duration": 332,
  "tasks": {
    "total": 15,
    "completed": 15,
    "failed": 0,
    "skipped": 0
  },
  "parallel": {
    "enabled": true,
    "maxWorkers": 4,
    "parallelTasks": 8,
    "efficiency": 0.64,
    "timeSaved": 128
  },
  "tests": {
    "passed": 67,
    "failed": 0,
    "coverage": 89,
    "duration": 42
  },
  "performance": {
    "tasksPerMinute": 2.7,
    "avgTaskDuration": 22,
    "longestTask": 45,
    "shortestTask": 5
  }
}
```

---

## Integration Points

### Skill → Subagent
1. Skill creates implementation-context.md
2. Skill invokes: `@implement phaseer`
3. Subagent reads context, executes tasks
4. Subagent updates current-session.md
5. Skill polls for progress, displays to user

### Subagent → State Files
1. Read tasks.md for task list
2. Update current-session.md for progress
3. Write implementation.log for audit trail
4. Write implementation-metrics.json for analytics
5. Move completed tasks to CHANGES-COMPLETED.md

### State Files → Memory
1. Append completed tasks to CHANGES-COMPLETED.md
2. Update WORKFLOW-PROGRESS.md with metrics
3. Log decisions to DECISIONS-LOG.md
4. Save checkpoint to checkpoints/

---

## Algorithm Complexity

### Dependency Graph Construction
- **Time**: O(n²) where n = task count
- **Space**: O(n + e) where e = edge count
- **Optimization**: Cache same-file lookups in hash map

### Parallel Group Identification
- **Time**: O(n + e) topological sort
- **Space**: O(n) for level grouping
- **Optimization**: Early exit when no [P] markers found

### Resource Conflict Detection
- **Time**: O(n² / k) where k = parallel group count
- **Space**: O(n)
- **Optimization**: Index tasks by file path for O(1) lookup

### Worker Pool Scheduling
- **Time**: O(n log n) for task sorting + O(n) assignment
- **Space**: O(n)
- **Optimization**: Reuse worker threads, avoid spawn overhead
