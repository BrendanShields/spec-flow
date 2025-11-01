# spec:implement - Examples

Concrete scenarios demonstrating implementation execution patterns.

## Example 1: Serial Execution (Default)

### Scenario
Execute 8 tasks sequentially for user authentication feature.

### Input
```bash
# User command
spec:implement

# tasks.md content
- [ ] T001 [US1] Create user model in src/models/user.js
- [ ] T002 [US1] Add database schema in db/schema.sql
- [ ] T003 [US1] Create auth service in src/services/auth.js
- [ ] T004 [US2] Add login endpoint in src/routes/auth.js
- [ ] T005 [US2] Create JWT helper in src/utils/jwt.js
- [ ] T006 [US2] Add middleware in src/middleware/auth.js
- [ ] T007 [US3] Write integration tests in tests/auth.test.js
- [ ] T008 [US3] Update API docs in docs/api.md
```

### Execution Flow
```
Phase 1: Parse Tasks
- Loaded 8 tasks from features/001-auth/tasks.md
- No [P] markers found → Serial execution
- Grouped by user story: US1 (3), US2 (3), US3 (2)

Phase 2: Execute Sequentially
[1/8] T001 [US1] Create user model
  → Created src/models/user.js (245 lines)
  → Added imports to src/models/index.js
  ✓ Completed in 12s

[2/8] T002 [US1] Add database schema
  → Created db/schema.sql (89 lines)
  → Added migration timestamp
  ✓ Completed in 8s

[3/8] T003 [US1] Create auth service
  → Created src/services/auth.js (178 lines)
  → Added unit tests (auto-generated)
  ✓ Completed in 15s

[Running Tests: Phase 1]
  ✓ user.model.test.js - 12 passing
  ✓ auth.service.test.js - 8 passing
  Coverage: 94%

[4/8] T004 [US2] Add login endpoint
  → Created route in src/routes/auth.js
  → Added validation schema
  ✓ Completed in 10s

[5/8] T005 [US2] Create JWT helper
  → Created src/utils/jwt.js
  → Added configuration in .env.example
  ✓ Completed in 7s

[6/8] T006 [US2] Add middleware
  → Created src/middleware/auth.js
  → Integrated with express app
  ✓ Completed in 9s

[Running Tests: Phase 2]
  ✓ auth.routes.test.js - 15 passing
  ✓ jwt.test.js - 6 passing
  Coverage: 91%

[7/8] T007 [US3] Write integration tests
  → Created tests/auth.test.js
  → Added test fixtures
  ✓ Completed in 18s

[8/8] T008 [US3] Update API docs
  → Updated docs/api.md
  → Generated OpenAPI spec
  ✓ Completed in 5s

[Final Tests]
  ✓ All tests passing (41 total)
  ✓ Coverage: 92%
  ✓ Linting: No errors
```

### Output
```
Implementation Complete ✓

Summary:
- Tasks Completed: 8/8
- Total Duration: 1m 44s
- Average Task Time: 13s
- Tests: 41 passing (92% coverage)
- Files Created: 8
- Files Modified: 3

Phase Breakdown:
- Phase 1 (US1): 3 tasks in 35s
- Phase 2 (US2): 3 tasks in 26s
- Phase 3 (US3): 2 tasks in 23s
- Testing: 20s

State Updated:
✓ current-session.md → Implementation phase complete
✓ CHANGES-COMPLETED.md → 8 tasks added
✓ WORKFLOW-PROGRESS.md → Metrics updated

Next Steps:
  /validate           # Check consistency
  /spec-checklist  # Quality review
```

---

## Example 2: Parallel Execution

### Scenario
Execute 12 tasks with 4 parallelizable tasks to reduce total time.

### Input
```bash
# User command
spec:implement --parallel

# tasks.md content (note [P] markers)
- [ ] T001 [US1] Create user model in src/models/user.js
- [ ] T002 [US1] Create auth service in src/services/auth.js
- [ ] T003 [US2] Create profile model in src/models/profile.js
- [ ] T004 [US3] Create notification model in src/models/notification.js
- [ ] T005 [P] [US1] Write user tests in tests/user.test.js
- [ ] T006 [P] [US2] Write profile tests in tests/profile.test.js
- [ ] T007 [P] [US3] Write notification tests in tests/notification.test.js
- [ ] T008 [P] [US1] Update user docs in docs/models/user.md
- [ ] T009 [US1] Add user routes in src/routes/users.js
- [ ] T010 [US2] Add profile routes in src/routes/profiles.js
- [ ] T011 [US3] Add notification routes in src/routes/notifications.js
- [ ] T012 [ALL] Update API index in docs/api.md
```

### Execution Flow
```
Phase 1: Dependency Analysis
- Found 12 tasks
- Identified 4 parallelizable tasks (T005, T006, T007, T008)
- Built dependency graph:
  T001 → T005 → T009
  T003 → T006 → T010
  T004 → T007 → T011
  All → T012

Phase 2: Sequential Foundation
[1/12] T001 Create user model → ✓ 14s
[2/12] T002 Create auth service → ✓ 12s
[3/12] T003 Create profile model → ✓ 11s
[4/12] T004 Create notification model → ✓ 13s

Phase 3: Parallel Execution (4 workers)
Starting parallel batch with 4 tasks...

[Worker 1] T005 Write user tests
[Worker 2] T006 Write profile tests
[Worker 3] T007 Write notification tests
[Worker 4] T008 Update user docs

Progress Updates:
  00:05 - Worker 4 completed T008 (5s) ✓
  00:12 - Worker 2 completed T006 (12s) ✓
  00:15 - Worker 1 completed T005 (15s) ✓
  00:18 - Worker 3 completed T007 (18s) ✓

Parallel batch complete: 4 tasks in 18s (vs 50s sequential)
Time saved: 32s (64% reduction)

Phase 4: Sequential Completion
[9/12] T009 Add user routes → ✓ 9s
[10/12] T010 Add profile routes → ✓ 8s
[11/12] T011 Add notification routes → ✓ 10s
[12/12] T012 Update API index → ✓ 4s

[Running All Tests]
  ✓ 67 tests passing
  ✓ Coverage: 89%
```

### Output
```
Implementation Complete ✓

Summary:
- Tasks Completed: 12/12
- Total Duration: 2m 3s
- Sequential Equivalent: 3m 25s
- Time Saved: 1m 22s (40% faster)
- Parallel Efficiency: 64%
- Tests: 67 passing (89% coverage)

Parallel Performance:
- Parallel Tasks: 4
- Concurrent Workers: 4
- Longest Task: 18s (T007)
- Shortest Task: 5s (T008)
- Average Parallelism: 3.2 tasks/min

Next Steps:
  /spec-metrics    # Review performance baseline
```

---

## Example 3: Resume After Interruption

### Scenario
Implementation interrupted at task 7/15, user fixes blocker and resumes.

### Input
```bash
# Original execution interrupted
spec:implement

# ... tasks 1-6 completed ...
# Task 7 failed with database connection error
# User fixes database configuration
# Resume with:
spec:implement --continue
```

### Session State Before Resume
```markdown
# current-session.md
Current Task: T007 [US2] Database migration
Status: FAILED
Progress: 6/15 tasks

Completed Tasks:
- [x] T001 [US1] User model
- [x] T002 [US1] Auth service
- [x] T003 [US1] User routes
- [x] T004 [US2] Profile model
- [x] T005 [US2] Profile service
- [x] T006 [US2] Profile routes

Failed Task:
- [ ] T007 [US2] Database migration
  Error: Connection refused (ECONNREFUSED)
  Retry: 3/3 (exhausted)

Blocker: Database not running
Action: Start database and run --continue
```

### Execution Flow
```
Phase 1: Resume Validation
✓ Loaded checkpoint from current-session.md
✓ Found 6 completed tasks
✓ Identified failed task: T007
✓ Detected 9 pending tasks

Phase 2: Retry Failed Task
[Retry] T007 [US2] Database migration
  → Checking database connection... ✓
  → Running migration up()... ✓
  → Verifying schema changes... ✓
  ✓ Completed in 8s (retry successful)

Phase 3: Continue Remaining Tasks
[8/15] T008 [US2] Seed data → ✓ 5s
[9/15] T009 [US3] Notification model → ✓ 12s
[10/15] T010 [US3] Notification service → ✓ 14s

[Running Tests: Phase 2]
  ✓ All migrations applied
  ✓ Database schema valid

[11/15] T011 [US3] Notification routes → ✓ 11s
[12/15] T012 [P] [US3] Notification tests → ✓ 16s
[13/15] T013 [P] [US1] User integration tests → ✓ 20s
[14/15] T014 [US3] WebSocket handler → ✓ 15s
[15/15] T015 [ALL] Update documentation → ✓ 6s

[Final Tests]
  ✓ 82 tests passing
  ✓ Coverage: 91%
```

### Output
```
Implementation Complete ✓ (Resumed)

Summary:
- Tasks Completed: 15/15
- Previously Completed: 6 tasks
- Resumed Tasks: 9 tasks
- Failed Task Retry: T007 (successful)
- Resume Duration: 1m 47s
- Total Duration: 3m 22s (across 2 sessions)

Recovery Details:
- Checkpoint: .spec-state/checkpoints/checkpoint-001.md
- Failed Task: T007 (database migration)
- Retry Successful: Yes (1 attempt)
- Data Preserved: All previous work intact

Next Steps:
  /session save      # Save completion checkpoint
  /validate          # Final consistency check
```

---

## Example 4: Filtered Execution (P1 Tasks Only)

### Scenario
Execute only P1 (Must Have) priority tasks, deferring P2/P3 for later.

### Input
```bash
# User command
spec:implement --filter=P1

# tasks.md content (mixed priorities)
## Phase 1: Core Features (P1)
- [ ] T001 [P1] [US1] User authentication in src/auth/
- [ ] T002 [P1] [US1] Session management in src/auth/
- [ ] T003 [P1] [US2] Core API endpoints in src/routes/

## Phase 2: Enhanced Features (P2)
- [ ] T004 [P2] [US3] Email notifications in src/notifications/
- [ ] T005 [P2] [US3] Push notifications in src/notifications/
- [ ] T006 [P2] [US4] User profile images in src/uploads/

## Phase 3: Optional (P3)
- [ ] T007 [P3] [US5] Social login in src/auth/social/
- [ ] T008 [P3] [US5] OAuth integration in src/auth/oauth/
```

### Execution Flow
```
Phase 1: Filter Tasks
- Total tasks: 8
- Filtered to P1: 3 tasks
- Skipped: 5 tasks (P2: 3, P3: 2)

Phase 2: Execute P1 Tasks
[1/3] T001 [P1] [US1] User authentication
  → Created auth module
  → Added password hashing
  → Implemented login/logout
  ✓ Completed in 25s

[2/3] T002 [P1] [US1] Session management
  → Created session store
  → Added Redis integration
  → Implemented session middleware
  ✓ Completed in 18s

[3/3] T003 [P1] [US2] Core API endpoints
  → Created CRUD endpoints
  → Added validation
  → Implemented error handling
  ✓ Completed in 22s

[Running Tests: P1 Only]
  ✓ auth.test.js - 18 passing
  ✓ session.test.js - 12 passing
  ✓ api.test.js - 24 passing
  Coverage: 88% (core modules)
```

### Output
```
Implementation Complete ✓ (P1 Tasks)

Summary:
- P1 Tasks Completed: 3/3
- P2/P3 Tasks Deferred: 5
- Duration: 1m 5s
- Tests: 54 passing (88% coverage)

Completed:
✓ User authentication
✓ Session management
✓ Core API endpoints

Remaining (for later):
  P2: 3 tasks (email, push, profile images)
  P3: 2 tasks (social login, OAuth)

Next Steps:
  # Execute P2 tasks when ready:
  spec:implement --filter=P2

  # Or execute specific user story:
  spec:implement --filter=US3
```

---

## Example 5: Error Recovery with Partial Success

### Scenario
One task fails, but implementation continues with independent tasks.

### Input
```bash
spec:implement --parallel
```

### Execution Flow
```
Phase 1: Execute Tasks
[1/10] T001 User model → ✓ 12s
[2/10] T002 Auth service → ✓ 15s
[3/10] T003 Database migration → ✓ 8s

Phase 2: Parallel Batch
[Worker 1] T004 User routes
[Worker 2] T005 API tests
[Worker 3] T006 Email service ← FAILED
[Worker 4] T007 Documentation

Progress:
  00:08 - Worker 4 completed T007 ✓
  00:12 - Worker 1 completed T004 ✓
  00:15 - Worker 2 completed T005 ✓
  00:18 - Worker 3 FAILED T006 ✗
           Error: SMTP connection timeout

Partial Success: 3/4 tasks completed in parallel batch

Phase 3: Continue Independent Tasks
Task T006 blocked T008 (depends on email service)
Continuing with independent tasks T009, T010

[8/10] T009 Logging service → ✓ 10s
[9/10] T010 Health checks → ✓ 7s

Phase 4: Report Blocker
Task T008 [US3] Email templates
  Blocked by: T006 (email service)
  Status: Waiting for fix
```

### Output
```
Implementation Partially Complete

Summary:
- Tasks Completed: 8/10
- Tasks Failed: 1 (T006)
- Tasks Blocked: 1 (T008, depends on T006)
- Duration: 1m 42s

Failed Task Details:
  T006 [US2] Email service
  Error: SMTP connection timeout after 30s
  Retry: 3/3 attempts (exhausted)

  Possible Causes:
  - SMTP server not reachable
  - Firewall blocking port 587
  - Invalid credentials in .env

  Suggested Fix:
  1. Check SMTP_HOST in .env file
  2. Verify network connectivity: telnet smtp.example.com 587
  3. Test credentials with email client

Blocked Tasks:
  T008 [US3] Email templates (depends on T006)

Independent Tasks Completed:
  ✓ T001-T005, T007, T009-T010 (8 tasks)

Next Steps:
  1. Fix T006 email service configuration
  2. Resume with: spec:implement --continue
  3. This will retry T006 and execute T008
```

---

## Summary of Patterns

### Serial Execution
- **When**: Default mode, sequential dependencies
- **Time**: Predictable, sum of all task durations
- **Best For**: Simple workflows, debugging

### Parallel Execution
- **When**: Independent tasks marked [P]
- **Time**: 40-60% reduction typical
- **Best For**: Large implementations, time-critical

### Resume After Failure
- **When**: Interruption or blocker encountered
- **Time**: Only re-runs failed + remaining tasks
- **Best For**: Recovery, incremental progress

### Filtered Execution
- **When**: Subset needed (P1, specific user story)
- **Time**: Proportional to filtered task count
- **Best For**: MVP development, phased rollout

### Partial Success
- **When**: Some tasks fail but others independent
- **Time**: Maximum progress despite blockers
- **Best For**: Maximizing forward progress
