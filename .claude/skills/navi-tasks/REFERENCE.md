# Flow Tasks Reference

## Task Format Specification

### Complete Task Format

```
- [ ] T### [P] [US#] Description with absolute file path
```

**Components**:
| Component | Required | Description | Example |
|-----------|----------|-------------|---------|
| `- [ ]` | Yes | Checkbox ([ ] pending, [X] complete) | `- [ ]` |
| `T###` | Yes | Sequential task ID (T001, T002...) | `T012` |
| `[P]` | No | Parallelizable marker | `[P]` |
| `[US#]` | Yes* | User story label | `[US1]` |
| Description | Yes | Action verb + component + context | `Create User model` |
| File path | Yes | Absolute path to file | `at src/models/user.py` |

*`[US#]` required for story phases, use `[US-SETUP]` or `[US-POLISH]` for non-story tasks.

### Valid Examples

```markdown
✅ - [ ] T001 [P] [US1] Create User model at src/models/user.py
✅ - [ ] T002 [US1] Implement /login endpoint at src/api/auth.py
✅ - [ ] T003 [US-SETUP] Configure database at src/db/config.py
✅ - [X] T004 [P] [US2] Create Product model at src/models/product.py
```

### Invalid Examples

```markdown
❌ - [ ] Create user model  (missing T###, [US#], path)
❌ - [ ] T001 Add login (missing [US#] and path)
❌ - [ ] T002 [US1] Fix bug (no file path)
❌ - [ ] T003 [US1] Update user.py (relative path)
```

## Phase Organization

### Phase Structure

**Phase 1: Setup**
- Project initialization
- Dependencies installation
- Environment configuration
- Tooling setup

Example:
```markdown
## Phase 1: Setup & Dependencies

### Tasks
- [ ] T001 [US-SETUP] Initialize project at package.json
- [ ] T002 [US-SETUP] Install dependencies at package-lock.json
- [ ] T003 [US-SETUP] Configure database at src/db/connection.py
```

**Phase 2: Foundation**
- Blocking prerequisites
- Base models/classes
- Core utilities
- Database schema

Example:
```markdown
## Phase 2: Foundation Components

### Tasks
- [ ] T004 [US-SETUP] Create base model at src/models/base.py
- [ ] T005 [P] [US-SETUP] Create error handler at src/utils/errors.py
- [ ] T006 [P] [US-SETUP] Create logger at src/utils/logger.py

### Parallel Opportunities
Tasks T005, T006 (independent utilities)
```

**Phase 3+: User Stories**
- One phase per user story
- Grouped by priority (P1, P2, P3)
- Independently testable
- Can ship separately

Example:
```markdown
## Phase 3: US1 - User Authentication (P1)

**Goal**: Users can register and log in
**Independent Test**: Register → Login → See dashboard
**Acceptance Criteria**:
- Users can create account with email/password
- Users can login and receive JWT token
- Invalid credentials return 401

### Tasks
- [ ] T010 [P] [US1] Create User model at src/models/user.py
- [ ] T011 [P] [US1] Create Auth service at src/services/auth.py
- [ ] T012 [US1] Implement /register at src/api/auth.py
- [ ] T013 [US1] Implement /login at src/api/auth.py
- [ ] T014 [US1] Add auth middleware at src/middleware/auth.py
- [ ] T015 [US1] Add auth tests at tests/auth.test.py

### Parallel Opportunities
T010, T011 (different files, no dependencies)
```

**Final Phase: Polish**
- Performance optimization
- Additional logging
- Documentation
- Deployment prep

Example:
```markdown
## Final Phase: Polish & Cross-Cutting Concerns

### Tasks
- [ ] T099 [US-POLISH] Add API documentation at docs/api.md
- [ ] T100 [US-POLISH] Optimize database queries at src/db/
- [ ] T101 [US-POLISH] Add monitoring at src/monitoring/
```

## Parallelization Rules

### Can Run in Parallel

| Condition | Example |
|-----------|---------|
| Different files | `user.py` and `auth.py` |
| No shared dependencies | Separate models |
| Independent user stories | US1 and US2 features |
| Read-only operations | Multiple test files |

```markdown
✅ Parallel:
- [ ] T010 [P] [US1] Create User model at src/models/user.py
- [ ] T011 [P] [US1] Create Auth service at src/services/auth.py

Reason: Different files, no shared state
```

### Must Run Sequentially

| Condition | Example |
|-----------|---------|
| Same file modifications | Multiple edits to `app.py` |
| Dependent data structures | Model → Migration → Service |
| Ordered migrations | Database schema versions |
| Setup → Use pattern | Config → Feature using config |

```markdown
❌ Cannot parallelize:
- [ ] T020 [US2] Create Product model at src/models/product.py
- [ ] T021 [US2] Add Product migration at migrations/002_products.sql
- [ ] T022 [US2] Create Product service at src/services/products.py

Reason: T021 depends on T020 (model must exist for migration)
```

## MCP Integration (JIRA Subtasks)

### Configuration

Enable in `CLAUDE.md`:
```
FLOW_ATLASSIAN_SYNC=enabled
FLOW_JIRA_CREATE_SUBTASKS=true
FLOW_JIRA_PROJECT_KEY=PROJ
```

### Subtask Creation Process

**Step 1: Parse tasks.md**
```javascript
const tasks = parseTasksFile('features/001-auth/tasks.md');
// Result:
[
  {
    id: 'T010',
    parallel: true,
    userStory: 'US1',
    description: 'Create User model',
    filePath: 'src/models/user.py',
    phase: 3,
    completed: false
  },
  // ...
]
```

**Step 2: Map to parent stories**
```javascript
// Load JIRA story IDs from spec.md frontmatter
const spec = readSpecFile();
const jiraStories = {
  'US1': 'PROJ-123',  // User Authentication
  'US2': 'PROJ-124',  // User Profile
  'US3': 'PROJ-125'   // Settings
};
```

**Step 3: Create JIRA subtasks**
```javascript
for (const task of tasks) {
  const parentStory = jiraStories[task.userStory];

  if (!parentStory) {
    console.warn(`No JIRA story found for ${task.userStory}`);
    continue;
  }

  const subtask = await mcp.jira.createIssue({
    projectKey: config.FLOW_JIRA_PROJECT_KEY,
    issueType: 'Sub-task',
    parent: parentStory,
    summary: `${task.id}: ${task.description}`,
    description: formatTaskDescription(task),
    labels: [
      'flow-task',
      `task-${task.id}`,
      task.parallel ? 'parallel-ok' : 'sequential'
    ],
    customFields: {
      'Flow Task ID': task.id,
      'File Path': task.filePath,
      'Phase': task.phase
    }
  });

  // Store JIRA ID in tasks.md
  await updateTaskWithJiraId(task.id, subtask.key);
}
```

**Step 4: Update tasks.md with JIRA IDs**
```markdown
- [ ] T010 [P] [US1] Create User model at src/models/user.py
<!-- JIRA: PROJ-126 -->
- [ ] T011 [P] [US1] Create Auth service at src/services/auth.py
<!-- JIRA: PROJ-127 -->
```

### Task Description Format

JIRA subtask description includes:
```markdown
**Task ID**: T010
**User Story**: US1 - User Authentication
**File**: src/models/user.py
**Parallelizable**: Yes
**Phase**: 3

**Description**:
Create User model with fields:
- id (UUID, primary key)
- email (string, unique)
- password_hash (string)
- created_at (timestamp)

**Implementation Notes**:
- Use SQLAlchemy ORM
- Follow existing model pattern in src/models/base.py
- Add email validation

**Generated by Flow**: features/001-auth/tasks.md
```

### Benefits of JIRA Sync

| Benefit | Description |
|---------|-------------|
| Sprint Planning | Drag subtasks into sprints for capacity planning |
| Team Visibility | Entire team sees granular task status |
| Time Tracking | Log hours against specific subtasks |
| Dependencies | JIRA visualizes blocking relationships |
| Burndown Charts | Accurate sprint progress tracking |
| Parallel Identification | `parallel-ok` label helps assign concurrent work |

### JIRA Board Organization

```
Epic: Feature Name (PROJ-120)
├─ Story: US1 - User Authentication (PROJ-123)
│  ├─ Subtask: T010 - Create User model (PROJ-126) [parallel-ok]
│  ├─ Subtask: T011 - Create Auth service (PROJ-127) [parallel-ok]
│  ├─ Subtask: T012 - Implement /register (PROJ-128)
│  └─ Subtask: T013 - Implement /login (PROJ-129)
├─ Story: US2 - User Profile (PROJ-124)
│  ├─ Subtask: T020 - Create Profile model (PROJ-130)
│  └─ ...
└─ Story: US3 - Settings (PROJ-125)
   └─ ...
```

### Sprint Workflow

1. **Planning**: PM drags subtasks into sprint
2. **Assignment**: Team members self-assign
3. **Execution**: `flow:implement` updates status automatically
4. **Tracking**: Real-time burndown as tasks complete

## Dependency Management

### Dependency Annotations

Use comments to document dependencies:
```markdown
- [ ] T010 [US1] Create User model at src/models/user.py
- [ ] T011 [US1] Create migration at migrations/002_users.sql
  Depends on: T010
- [ ] T012 [US1] Create Auth service at src/services/auth.py
  Depends on: T010, T011
```

### Dependency Graph

```
T010 (User model)
  ↓
T011 (Migration)
  ↓
T012 (Auth service) ← T013 (Auth tests)
  ↓
T014 (Login endpoint)
```

Sequential execution: T010 → T011 → T012 → T014
Parallel branch: T013 (independent tests)

### JIRA Dependency Linking

```javascript
// Create JIRA links for dependencies
if (task.dependencies) {
  for (const depId of task.dependencies) {
    await mcp.jira.createIssueLink({
      type: 'Blocks',
      inwardIssue: jiraIds[depId],  // Blocking task
      outwardIssue: jiraIds[task.id]  // Blocked task
    });
  }
}
```

JIRA then shows:
- "T010 blocks T011"
- "T011 is blocked by T010"

## Configuration Options

### Flag: `--simple`

Generate flat task list without user story organization:
```bash
flow:tasks --simple
```

Output:
```markdown
## Tasks

- [ ] T001 Setup project
- [ ] T002 Create models
- [ ] T003 Add API endpoints
- [ ] T004 Write tests
```

Use when:
- POC/prototype
- Simple features (<10 tasks)
- No user stories defined
- Quick iteration needed

### Flag: `--filter=P1|P2|P3`

Generate tasks for specific priority only:
```bash
flow:tasks --filter=P1
```

Output: Only tasks for P1 user stories

Use when:
- MVP scope cut
- Phased delivery
- Resource constraints
- Deadline pressure

### Flag: `--no-jira`

Skip JIRA subtask creation:
```bash
flow:tasks --no-jira
```

Use when:
- Solo developer
- JIRA not configured
- Testing task generation
- Local-only workflow

## Validation Rules

### Task ID Validation

- Sequential (T001, T002, T003...)
- No gaps
- No duplicates
- Starts at T001 or continues from last

### File Path Validation

- Must be absolute (starts with `/` or project root)
- Must specify actual file name
- Can't be directory only
- Must be valid for OS

### User Story Validation

- Must match spec.md user stories
- Label format: `[US#]` where # is number
- Special labels: `[US-SETUP]`, `[US-POLISH]`

### Parallel Marker Validation

- Only `[P]` is valid (not `[PARALLEL]` or `[||]`)
- Must be after task ID, before user story label
- Cannot mark dependent tasks as parallel

## Troubleshooting

### "Tasks not aligned with user stories"
- **Cause**: spec.md changed after tasks generated
- **Fix**: Run `flow:tasks --update` to regenerate

### "JIRA subtasks not created"
- **Cause**: Missing JIRA story IDs in spec.md
- **Fix**: Run `flow:specify --update` to sync JIRA IDs

### "Parallel markers incorrect"
- **Cause**: Shared file dependencies not detected
- **Fix**: Manually review and remove `[P]` from dependent tasks

### "Too many/few tasks"
- **Cause**: Task granularity mismatch
- **Fix**: Adjust in plan.md (more/less component breakdown)

## Related Files

- `spec.md` - Source for user stories and priorities
- `plan.md` - Source for component breakdown
- `tasks.md` - Output task list
- `.flow/architecture-blueprint.md` - Task structure guidance
