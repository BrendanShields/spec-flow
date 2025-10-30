# Flow Tasks Examples

## 1. User Story-Based Breakdown

**Input**: `plan.md` with 3 user stories (US1: Auth, US2: Profile, US3: Settings)

**Execution**:
```
specter:tasks

Analyzing spec and plan...
Found 3 user stories (2 P1, 1 P2)

Generating tasks...
✅ Phase 1: Setup (2 tasks)
✅ Phase 2: Foundation (3 tasks)
✅ Phase 3: US1 - User Authentication (5 tasks, 2 parallel)
✅ Phase 4: US2 - User Profile (4 tasks, 3 parallel)
✅ Phase 5: US3 - Settings (3 tasks)
✅ Final Phase: Polish (2 tasks)

Total: 19 tasks generated
Parallel opportunities: 5 tasks
```

**Output** (`tasks.md`):
```markdown
## Phase 3: US1 - User Authentication (P1)

**Goal**: Users can register and log in
**Independent Test**: Create account → Login → Dashboard

### Tasks
- [ ] T005 [P] [US1] Create User model at src/models/user.py
- [ ] T006 [P] [US1] Create Auth service at src/services/auth.py
- [ ] T007 [US1] Implement /register endpoint at src/api/auth.py
- [ ] T008 [US1] Implement /login endpoint at src/api/auth.py
- [ ] T009 [US1] Add JWT middleware at src/middleware/auth.py

### Parallel Opportunities
Tasks T005, T006 (different files, no dependencies)
```

## 2. JIRA Subtask Creation

**With `SPECTER_ATLASSIAN_SYNC=enabled`**:

```
specter:tasks

Generating tasks... ✅
19 tasks created in tasks.md

📋 Creating JIRA subtasks...
  → Found parent stories: PROJ-123, PROJ-124, PROJ-125
  → Creating subtask for T005... PROJ-126
  → Creating subtask for T006... PROJ-127
  → Creating subtask for T007... PROJ-128
  ...

✅ 19 JIRA subtasks created
View: https://company.atlassian.net/browse/PROJ-123
```

**JIRA Board After**:
```
Epic PROJ-120: User Management
├─ Story PROJ-123: User Authentication [US1]
│  ├─ PROJ-126: T005 - Create User model
│  ├─ PROJ-127: T006 - Create Auth service [parallel-ok]
│  ├─ PROJ-128: T007 - Implement /register
│  └─ PROJ-129: T008 - Implement /login
└─ Story PROJ-124: User Profile [US2]
   └─ ...
```

## 3. Parallel Execution Planning

**Input**: Complex feature with many independent components

**Output**:
```markdown
## Phase 4: US2 - Product Catalog (P1)

### Tasks
- [ ] T015 [P] [US2] Product model at src/models/product.py
- [ ] T016 [P] [US2] Category model at src/models/category.py
- [ ] T017 [P] [US2] Inventory service at src/services/inventory.py
- [ ] T018 [US2] Product API endpoints at src/api/products.py
- [ ] T019 [US2] Search functionality at src/services/search.py

### Parallel Opportunities
✅ T015, T016, T017 (3 tasks concurrently)
   → Saves ~15 minutes of sequential execution
   → Different files, no shared dependencies
```

## 4. Dependency Chain

**Sequential tasks with dependencies**:

```markdown
## Phase 2: Foundation

### Tasks
- [ ] T003 [US-SETUP] Database schema migrations at migrations/001_initial.sql
- [ ] T004 [US-SETUP] Database connection setup at src/db/connection.py
  Depends on: T003 (schema must exist first)
- [ ] T005 [US-SETUP] Base model classes at src/models/base.py
  Depends on: T004 (connection needed)

### Execution Order
T003 → T004 → T005 (must run sequentially)
```

## 5. Minimal Task List (POC)

**Input**: Simple POC with `--simple` flag

**Execution**:
```
specter:tasks --simple

Generating minimal task list...
Skipping user story grouping...
Flat structure only...

✅ 5 tasks generated
```

**Output**:
```markdown
## Tasks

- [ ] T001 Create models at src/models/
- [ ] T002 Create API endpoints at src/api/
- [ ] T003 Add tests at tests/
- [ ] T004 Write README
- [ ] T005 Deploy
```

For detailed MCP integration and configuration, see [REFERENCE.md](./REFERENCE.md).
