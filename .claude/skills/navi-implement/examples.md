# Flow Implement: Examples

## Example 1: Parallel Task Execution

**Input tasks.md**:
```markdown
- [ ] T012 [P] [US1] Create User model at src/models/user.py
- [ ] T013 [P] [US1] Create Auth service at src/services/auth.py
- [ ] T014 [P] [US1] Set up database connection at src/db/connection.py
```

**Execution Output**:
```
⚡ Executing 3 tasks in parallel...

[T012] Creating User model...      ████░ 80%
[T013] Creating Auth service...    ██░░░ 40%
[T014] Setting up database...      ███░░ 60%

✅ T012 Complete: User model created
✅ T014 Complete: Database connection established
✅ T013 Complete: Auth service implemented

Parallel execution saved ~8 minutes
```

## Example 2: Error Recovery

**Task fails first attempt**:
```
❌ T025 Failed: Import error in test file

🔄 Retrying with alternative approach...
   → Adding missing import statements
   → Adjusting module paths

✅ T025 Complete: Tests passing after recovery
```

## Example 3: Dependency Resolution

**Complex dependency chain**:
```
Phase 2: Foundation
  T005 → T006 → T007 (sequential)
         ↓
  T008, T009, T010 (parallel after T006)
```

## Example 4: JIRA Integration

**Real-time status updates**:
```
Starting T015 [PROJ-123-1]...
  → JIRA: Status changed to "In Progress"
  → Implementation in progress...
  → Running tests...
✅ T015 Complete
  → JIRA: Status changed to "Done"
  → JIRA: Added comment with implementation details
```