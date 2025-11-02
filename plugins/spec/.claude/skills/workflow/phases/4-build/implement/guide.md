---
name: spec:implement
description: Use when implementing tasks, building features, executing code, user says "implement this", "build it", "execute tasks", "run implementation" - autonomously executes implementation tasks with parallel processing and progress tracking
allowed-tools: Read, Write, Edit
model: sonnet
---

# Implementation Executor

Execute implementation tasks from tasks.md with parallel processing, dependency resolution, and real-time progress tracking.

## What This Skill Does

- Reads task list from {config.paths.features}/###-name/{config.naming.files.tasks}
- Identifies parallelizable tasks (marked with [P])
- Delegates execution to implement phaseer subagent
- Tracks progress in {config.paths.state}/current-session.md
- Moves completed tasks to {config.paths.memory}/CHANGES-COMPLETED.md
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
1. Use Read to check {config.paths.features}/###-name/{config.naming.files.tasks} exists
3. Parse task format: `- [ ] T### [P?] [US#] Description path/file.ext`
4. Count pending tasks and identify filters (--filter=P1, --filter=US1)

### Phase 2: Analysis
1. Identify parallelizable tasks (marked with [P])
2. Build dependency graph from task ordering
3. Group by phase (Setup → Foundation → User Stories → Polish)
4. Calculate estimated completion time
5. Check TDD mode configuration

### Phase 2.5: TDD Mode Detection

Read `.claude/.spec-config.yml` to check if TDD mode is enabled:

```yaml
workflow:
  tdd:
    enabled: true/false
    mode: "strict" | "flexible" | "advisory"
```

**TDD Mode Behaviors:**

#### Strict Mode (`mode: "strict"`)
**Requirements**:
- `enforce_test_first: true` - Tests MUST exist before implementation
- `block_implementation_without_tests: true` - Implementation blocked if tests missing
- `fail_on_missing_tests: true` - Fail validation if tests not found

**Workflow**:
1. For each task in tasks.md:
   - Check if corresponding test file exists
   - Test naming: `{name}.test.{ext}` or `{name}.spec.{ext}`
   - Test locations: alongside file, `tests/` dir, or `__tests__/` dir

2. If test missing:
   ```markdown
   ❌ TDD Strict Mode: Test required before implementation

   Task: T003 - Implement user service (src/services/user.service.ts)
   Missing test: src/services/user.service.test.ts

   TDD requires:
   1. 🔴 RED: Write failing test first
   2. 🟢 GREEN: Implement minimal code to pass
   3. 🔵 REFACTOR: Improve code quality

   Action: Create test file before implementing this task.
   ```
   - Block task execution
   - Prompt user to create test using AskUserQuestion:
     ```markdown
     Would you like me to:
     - Generate test stub for this task
     - Skip TDD for this task
     - Disable TDD mode
     ```

3. Execute TDD Cycle:
   - **RED**: Run test (should fail initially)
     ```bash
     npm test -- src/services/user.service.test.ts
     # Expected: FAIL (function not implemented)
     ```

   - **GREEN**: Implement minimal code to pass test
     ```bash
     # Implement task
     # Run test again
     npm test -- src/services/user.service.test.ts
     # Expected: PASS
     ```

   - **REFACTOR**: Improve code while keeping tests green
     ```bash
     # Refactor implementation
     # Ensure tests still pass
     npm test -- src/services/user.service.test.ts
     # Expected: PASS
     ```

#### Flexible Mode (`mode: "flexible"`)
**Requirements**:
- Tests encouraged but not required
- Can implement first, tests after (not strictly test-first)
- Warnings shown but doesn't block

**Workflow**:
1. Check for tests, show warning if missing:
   ```markdown
   ⚠️  TDD Flexible Mode: Test recommended

   Task: T003 - Implement user service
   Recommendation: Create test file for better coverage

   Continue anyway? (Yes/No)
   ```

2. If user continues without test:
   - Allow implementation
   - Track as "needs test" in state
   - Remind after implementation to add test

3. After implementation, generate test coverage report:
   ```markdown
   📊 Coverage Report:
   - src/services/user.service.ts: 0% (no tests)

   Recommendation: Add tests for implemented functionality
   Generate test stub? (Yes/No)
   ```

#### Advisory Mode (`mode: "advisory"`)
**Requirements**:
- TDD suggestions only
- No enforcement or blocking
- Educational guidance

**Workflow**:
1. Before implementation, show TDD reminder:
   ```markdown
   💡 TDD Tip: Consider test-driven development

   Benefits:
   - Better design through test-first thinking
   - Immediate feedback on implementation
   - Higher confidence in code correctness

   This is advisory only - proceed as you prefer.
   ```

2. After implementation, show test coverage insights:
   ```markdown
   📈 Coverage: 45% (below target: 80%)

   Tip: Adding tests improves maintainability and catches regressions.
   ```

### Phase 3: Test Generation (TDD Mode)

If TDD enabled and test files missing, auto-generate test stubs based on config:

```yaml
workflow:
  tdd:
    test_generation:
      auto_generate_tests: true
      test_naming_convention: "{name}.test.{ext}"
      test_location: "alongside"  # alongside | separate | mirror
      include_edge_cases: true
      include_error_cases: true
```

**Test Stub Generation Algorithm**:

1. Parse task to identify:
   - File path: `src/services/user.service.ts`
   - Function/class name: `UserService`
   - Expected behavior from task description

2. Generate test file:
   ```typescript
   // Auto-generated by implement phase (TDD Mode)
   import { UserService } from './user.service';

   describe('UserService', () => {
     describe('createUser', () => {
       it('should create a new user with valid data', () => {
         // Arrange
         const userData = { email: 'test@example.com', name: 'Test User' };

         // Act
         const result = UserService.createUser(userData);

         // Assert
         expect(result).toBeDefined();
         expect(result.email).toBe(userData.email);
       });

       it('should throw error with invalid email', () => {
         // Edge case: invalid input
         const invalidData = { email: 'invalid', name: 'Test' };
         expect(() => UserService.createUser(invalidData)).toThrow();
       });

       it('should handle database errors gracefully', () => {
         // Error case: database failure
         // TODO: Add error handling test
       });
     });
   });
   ```

3. Write test file using Write tool
4. Run test to verify it fails (RED phase)
5. Proceed to implementation

### Phase 3.5: TDD Validation

Before delegating to implement phaseer, validate TDD compliance:

```typescript
function validateTDDCompliance(tasks: Task[], config: TDDConfig): ValidationResult {
  const results = [];

  for (const task of tasks) {
    const testFile = findTestFile(task.file, config);

    if (config.mode === 'strict' && !testFile) {
      results.push({
        task: task.id,
        status: 'blocked',
        reason: 'Test file required in strict mode',
        action: 'Create test before implementation'
      });
    } else if (config.mode === 'flexible' && !testFile) {
      results.push({
        task: task.id,
        status: 'warning',
        reason: 'Test file recommended',
        action: 'Continue or create test'
      });
    } else if (testFile) {
      // Run test to verify it fails (RED phase)
      const testResult = runTest(testFile);
      if (testResult.passing) {
        results.push({
          task: task.id,
          status: 'warning',
          reason: 'Test already passing (expected to fail initially)',
          action: 'Verify test correctness'
        });
      } else {
        results.push({
          task: task.id,
          status: 'ready',
          reason: 'Test failing as expected (RED phase)',
          action: 'Proceed to implementation (GREEN phase)'
        });
      }
    }
  }

  return results;
}
```

### Phase 5: Delegation
1. Use Write to create {config.paths.spec_root}/implementation-context.md with:
   - Task list
   - Execution mode (serial/parallel)
   - Current phase
   - Progress checkpoint
   - TDD mode settings (if enabled)
2. Invoke implement phaseer subagent with TDD context
3. Monitor progress (subagent updates current-session.md)
4. Track TDD cycle phases (RED → GREEN → REFACTOR)

### Phase 6: Progress Tracking
1. Use Read to monitor {config.paths.state}/current-session.md for updates
2. Display real-time progress (with TDD indicators if enabled):
   ```
   Progress: ████████░░ 80% (12/15 tasks)
   In Progress: T012 [P] [US2] Auth middleware
     TDD: 🟢 GREEN (test passing, refactoring...)
   Completed: 12 tasks
     Tests: 12/12 passing (95% coverage)
   Remaining: 3 tasks
   ```
3. Stream task completion notifications with TDD cycle status:
   ```markdown
   ✅ T011 completed - user.service.ts
      🔴 RED: Test failed initially ✓
      🟢 GREEN: Test passing ✓
      🔵 REFACTOR: Code improved ✓
      Coverage: 92% (11/12 lines)
   ```

### Phase 7: Validation & Cleanup
1. Use Read to check test results from subagent
2. **TDD Coverage Validation** (if TDD mode enabled):
   ```bash
   # Run coverage report
   npm run test:coverage

   # Parse coverage output
   # Check against min_coverage_per_task (default: 80%)
   # Check against min_coverage_overall (default: 75%)
   ```

   **Coverage Check**:
   ```typescript
   function validateCoverage(config: TDDConfig): CoverageResult {
     const coverage = parseCoverageReport();
     const failures = [];

     // Check per-task coverage
     for (const task of completedTasks) {
       const file = task.file;
       const fileCoverage = coverage.files[file];

       if (fileCoverage < config.min_coverage_per_task) {
         failures.push({
           file,
           actual: fileCoverage,
           required: config.min_coverage_per_task,
           status: 'below_threshold'
         });
       }
     }

     // Check overall coverage
     if (coverage.overall < config.min_coverage_overall) {
       failures.push({
         type: 'overall',
         actual: coverage.overall,
         required: config.min_coverage_overall,
         status: 'below_threshold'
       });
     }

     return { coverage, failures };
   }
   ```

   **If coverage below threshold**:
   ```markdown
   ❌ Coverage below threshold

   Files needing more tests:
   - src/services/user.service.ts: 65% (need 80%)
     Missing coverage:
       Lines 45-52: Error handling
       Lines 78-84: Edge case validation

   Overall coverage: 72% (need 75%)

   Options:
   - Add missing tests now
   - Mark as technical debt (track in CHANGES-PLANNED.md)
   - Adjust coverage threshold in config
   ```

   Use AskUserQuestion to prompt:
   ```markdown
   Coverage below threshold. What would you like to do?

   Options:
   - Add tests now (recommended)
   - Continue and track as tech debt
   - Adjust threshold for this feature
   ```

3. Move completed tasks to {config.paths.memory}/CHANGES-COMPLETED.md using Edit
   - Include TDD metrics if enabled:
     ```markdown
     ## T011 - User Service [COMPLETED]
     - File: src/services/user.service.ts
     - Tests: src/services/user.service.test.ts
     - Coverage: 92% (11/12 lines)
     - TDD Cycle: ✅ (RED → GREEN → REFACTOR)
     ```

4. Update {config.paths.memory}/WORKFLOW-PROGRESS.md metrics
   - Add TDD-specific metrics:
     ```markdown
     ### TDD Metrics
     - TDD Mode: Strict
     - Tests Created: 15
     - Coverage Average: 88%
     - Coverage Range: 75% - 95%
     - RED-GREEN-REFACTOR Cycles: 15/15 ✅
     ```

5. Create checkpoint in {config.paths.state}/checkpoints/
6. Optional: Create git commit with completed changes

## Execution Modes

### Default Mode
Execute all pending P1 tasks sequentially:
```
implement phase
```

### Parallel Mode
Enable parallel execution for [P] tasks:
```
implement phase --parallel
```

### Filtered Execution
Execute specific tasks:
```
implement phase --filter=P1          # Only P1 tasks
implement phase --filter=US1.1       # Specific user story
```

### Resume Mode
Continue from interruption:
```
implement phase --continue
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
- Run /workflow:track → "🔍 Analyze Consistency" to check consistency
- Run /workflow:track → "✅ Quality Checklist" for quality review
- Run /workflow:track → "📊 View Metrics" for performance baseline
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
  After fixing the error, run: implement phase --continue
```

## Configuration

Configuration options:
- `--parallel`: Enable parallel execution for [P] tasks
- `--skip-tests`: Skip test execution after implementation
- `--commit`: Create git commits after completion
- `--filter=P1|P2|P3|US#`: Execute specific priority or user story
- `--continue`: Resume from last checkpoint

See CLAUDE.md for SPEC_IMPLEMENT_* configuration variables.

## Integration

### Subagent Communication
This skill delegates to implement phaseer subagent:
- Input: {config.paths.spec_root}/implementation-context.md
- Output: {config.paths.spec_root}/implementation.log, metrics.json
- Progress: Updates current-session.md in real-time

### State Management
See shared/state-management.md for state file structure.

Progress tracked in:
- `{config.paths.state}/current-session.md` - Active progress
- `{config.paths.memory}/CHANGES-COMPLETED.md` - Completion log
- `{config.paths.memory}/WORKFLOW-PROGRESS.md` - Metrics

### Workflow Integration
Follows workflow sequence:
1. Generate → 2. Plan → 3. Tasks → **4. Implement** → 5. Validate

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
