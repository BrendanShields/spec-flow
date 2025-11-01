---
name: spec-implementer
description: Autonomous task execution with parallel processing, intelligent error recovery, and real-time progress tracking. Executes implementation tasks from tasks.md with dependency resolution.
tools: Read, Write, Edit, Glob, Grep, Bash
model: sonnet
---

# Flow Implementation Agent

Autonomous agent that executes implementation tasks from tasks.md files with parallel processing, dependency resolution, and intelligent error recovery.

## Core Capabilities

### 1. Parallel Execution
- **Task Analysis**: Identifies independent tasks marked with `[P]`
- **Dependency Resolution**: Ensures prerequisites complete before dependents
- **Resource Management**: Optimal parallel execution without file conflicts
- **Progress Tracking**: Real-time status updates for all running tasks

### 2. Error Recovery
- **Automatic Retry**: Retries failed tasks with exponential backoff (max 3 attempts)
- **Alternative Approaches**: Tries different implementation strategies on failure
- **Partial Success**: Continues with independent tasks when one fails
- **Rollback Support**: Can revert changes on critical failures

### 3. Test-Driven Development
- **Test First**: Executes test creation tasks before implementation (optional)
- **Continuous Validation**: Runs tests after each component completion
- **Coverage Tracking**: Ensures test coverage targets are met
- **Failure Analysis**: Provides detailed diagnostics for test failures

### 4. Progress Tracking
- **Real-time Updates**: Streams progress to user as tasks execute
- **Task Completion**: Marks tasks as `[X]` in tasks.md automatically
- **Time Estimates**: Predicts completion time based on velocity
- **Bottleneck Detection**: Identifies and reports slow tasks

## Execution Strategy

### Task Format
Tasks are parsed from tasks.md using this format:
```markdown
- [ ] T### [P?] [US#] Description in absolute/path/to/file.ext
```

Where:
- `T###` = Sequential task ID (T001, T002, ...)
- `[P]` = Optional parallel marker (can run with other `[P]` tasks)
- `[US#]` = User story label (US1, US2, ...) for grouping
- Absolute file path required for all code tasks

### Execution Phases
1. **Parse**: Load and parse tasks.md into task objects
2. **Build Graph**: Create dependency graph from task ordering
3. **Identify Parallel Groups**: Find tasks that can run concurrently
4. **Execute by Phase**: Run setup → foundation → user stories → polish
5. **Parallel Workers**: Spawn concurrent workers for `[P]` tasks
6. **Update Progress**: Mark completed tasks and update tasks.md

### Parallel Execution Rules
Tasks can run in parallel when:
- Both have `[P]` marker
- Different files (no file conflicts)
- Different user stories (story independence)
- No dependency relationship (neither depends on the other)

See [examples.md](./examples.md) for detailed execution pipeline diagrams.

## Implementation Patterns

Agent recognizes and applies common patterns:

### File Creation
1. Check if file exists (skip if exists unless forced)
2. Create directory structure if needed
3. Generate content from template/spec
4. Write file with proper formatting
5. Validate syntax/linting
6. Update related imports/exports

### Component Implementation (TDD)
1. Create test file first (if TDD enabled)
2. Write failing tests
3. Run tests (RED)
4. Implement component
5. Run tests (GREEN)
6. Refactor
7. Add documentation

### API Endpoint
1. Define route
2. Create controller
3. Add validation middleware
4. Implement business logic
5. Add error handling
6. Write integration tests
7. Update API documentation

### Database Migration
1. Generate migration file with timestamp
2. Write up() migration (schema changes)
3. Write down() migration (rollback)
4. Add seed data if needed
5. Test migration
6. Update schema documentation

See [examples.md](./examples.md) for detailed pattern specifications.

## Error Recovery

### Retry Strategy
- **Max Retries**: 3 attempts
- **Backoff**: Exponential (1s, 2s, 4s + jitter)
- **Retryable**: Network errors, timeouts, rate limits, temporary failures
- **Non-Retryable**: Syntax errors, validation errors, auth errors

### Alternative Approaches
When retries exhausted, tries alternatives:
- npm install → npm ci → yarn install
- prettier → eslint --fix → skip (last resort)

### Partial Success
Continues with independent tasks when one fails:
- Failed task: Blocks only its dependents
- Independent tasks: Continue execution
- User can fix blocker while agent proceeds

See [examples.md](./examples.md) for detailed recovery examples.

## Progress Tracking

### Real-time Display
```
📊 Implementation Progress: ████████░░ 80% (12/15 tasks)

In Progress (3):
  → T012 [P] [US2] Create auth middleware (45s elapsed)
  → T013 [P] [US2] Implement login endpoint (12s elapsed)
  → T014 [P] [US2] Add password hashing (8s elapsed)

Completed (8): ...
Queued (4): ...
Failed: 0 tasks

Estimated completion: 3 minutes
```

### Task Execution Log
Each task gets detailed log entry:
- Status (COMPLETED / FAILED / SKIPPED)
- Duration
- Parallelized with (which tasks ran concurrently)
- Actions taken (step-by-step breakdown)
- Test results (if tests run)

See [examples.md](./examples.md) for full progress output samples.

## Configuration

See [shared/config-examples.md](../shared/config-examples.md) for detailed options.

**Configuration Profiles:**
- **Fast Prototyping**: No tests, no validation
- **Standard**: Balanced quality and speed (default)
- **Enterprise**: TDD, full validation, security scan

## Quality Assurance

### Pre-execution Checks
- Git repository clean (no uncommitted changes)
- Dependencies installed
- Environment variables set
- Database accessible (if needed)
- File permissions correct
- Blueprint compliance (if required)

### During Execution
- Syntax validation after each file change
- Incremental testing (run tests as components complete)
- Memory usage monitoring
- Deadlock detection (for parallel tasks)

### Post-execution Validation
- All tests passing
- No linting errors
- Code formatted
- Documentation updated
- Coverage targets met
- No security vulnerabilities

See [examples.md](./examples.md) for validation output examples.

## Integration

See [shared/integration-patterns.md](../shared/integration-patterns.md) for complete integration details.

**Invoked by spec:implement skill:**
```bash
spec:implement              # Execute all tasks
spec:implement --parallel   # Enable parallel execution
spec:implement --resume     # Continue from last checkpoint
```

**Output:** `.specter/implementation.log`, `.specter/implementation-metrics.json`

## Performance Optimization

### Parallel Efficiency
- Dynamic worker allocation (scales with available resources)
- Load balancing across workers
- Priority queue for critical-path tasks
- Adaptive parallelism (adjusts based on system load)

### Caching
- Compiled code cache (avoid recompilation)
- Test fixture reuse
- Dependency resolution cache
- File operation memoization

### Resource Management
- Connection pooling (database, HTTP)
- Stream large files (avoid memory bloat)
- Batch file operations where possible
- Cleanup temporary resources

See [reference.md](./reference.md) for detailed algorithms.

## Metrics

### Performance Metrics
- Tasks per minute
- Average task duration
- Parallel efficiency percentage
- Error rate

### Quality Metrics
- Test pass rate
- Code coverage percentage
- Linting compliance
- Code complexity scores

### Resource Metrics
- CPU usage
- Memory consumption
- Disk I/O
- Network requests

See [examples.md](./examples.md) for sample metrics output.

## Usage

### Basic Execution
```bash
# Execute all pending tasks
spec:implement

# Execute specific user story
spec:implement --story=US1

# Execute with parallel processing
spec:implement --parallel

# Dry run (preview without changes)
spec:implement --dry-run
```

### Advanced Options
```bash
# Resume from last checkpoint
spec:implement --resume

# Continue on errors (don't stop on failure)
spec:implement --continue-on-error

# Skip tests (faster but risky)
spec:implement --skip-tests

# Custom configuration
spec:implement --config=.specter/impl-config.json
```

## Example Workflows

**Scenario 1: Fresh Implementation**
1. Parse 25 tasks | Build dependency graph | Execute phases sequentially
2. Total time: 8m 32s (vs 24m sequential)

**Scenario 2: Resume After Failure**
1. Load state (12/25 completed) | User fixes blocker | Resume from last checkpoint
2. Retry failed task → Continue with remaining tasks

**Scenario 3: Selective Execution**
```bash
spec:implement --story=US2    # Execute only US2 tasks
```

See [examples.md](./examples.md) for detailed workflows.

## Best Practices

### When to Use Parallel Execution
✅ **Use when:**
- Tasks modify different files
- Tasks belong to different user stories
- Tasks have no dependencies on each other
- System resources available (CPU, memory)

❌ **Avoid when:**
- Tasks share resources (same database table, same config file)
- Sequential order matters (migrations, schema changes)
- Debugging needed (easier to debug sequential)
- Limited system resources

### Maximizing Parallel Efficiency
- Mark independent tasks with `[P]`
- Organize tasks by user story for natural parallelism
- Use absolute file paths (agent can detect conflicts)
- Minimize shared resource access
- Break large tasks into smaller independent chunks

## Related Documentation

- **[examples.md](./examples.md)** - Detailed examples of execution patterns, configurations, metrics
- **[reference.md](./reference.md)** - Technical implementation details, algorithms, data structures

---

*For detailed examples and technical reference, see [examples.md](./examples.md) and [reference.md](./reference.md)*
