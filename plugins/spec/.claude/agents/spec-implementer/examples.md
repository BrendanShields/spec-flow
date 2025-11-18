# Spec Implementer - Examples

Examples of task execution, parallel processing, error recovery, and progress tracking. For detailed technical algorithms, see [reference.md](./reference.md).

## Task Parsing Examples

### Basic Task Format
```markdown
- [ ] T001 [US1] Create database schema in db/schema.sql
- [ ] T002 [P] [US1] Install dependencies via npm install
- [X] T003 [US2] Implement User model in src/models/user.py
```

Where:
- `T###` = Sequential task ID
- `[P]` = Optional parallel marker
- `[US#]` = User story label
- Description includes file path (absolute required)

## Implementation Pattern Examples

### Pattern 1: File Creation
```yaml
pattern: create-file
description: Create new code file with boilerplate
steps:
  1. Check if file exists (skip if exists unless --force)
  2. Create directory structure if needed
  3. Generate file content based on template/spec
  4. Write file with proper formatting
  5. Validate syntax/linting
  6. Update imports/exports in related files

example:
  task: "Create User model in src/models/user.py"
  actions:
    - mkdir -p src/models/
    - Generate Python class with fields
    - Add type hints and docstrings
    - Run black formatter
    - Update __init__.py imports
```

### Pattern 2: Component Implementation (TDD)
```yaml
pattern: implement-component-tdd
description: Implement component using Test-Driven Development
steps:
  1. Create test file first
  2. Write failing tests based on acceptance criteria
  3. Run tests (should fail)
  4. Implement minimal component to pass tests
  5. Run tests (should pass)
  6. Refactor and optimize
  7. Add documentation
  8. Update exports/index

example:
  task: "Implement LoginForm component in src/components/LoginForm.tsx"
  actions:
    - Create LoginForm.test.tsx
    - Write tests for email/password validation
    - Run tests → RED
    - Create LoginForm.tsx with basic structure
    - Implement validation logic
    - Run tests → GREEN
    - Add PropTypes and JSDoc
    - Update src/components/index.ts
```

### Pattern 3: API Endpoint
```yaml
pattern: create-api-endpoint
description: Create RESTful API endpoint with validation and tests
steps:
  1. Define route in router
  2. Create controller function
  3. Add request validation middleware
  4. Implement business logic
  5. Add error handling
  6. Write integration tests
  7. Update API documentation (OpenAPI)

example:
  task: "Create POST /api/users endpoint in src/routes/users.js"
  actions:
    - Add route: router.post('/users', validateUser, createUser)
    - Create validateUser middleware (Joi schema)
    - Implement createUser controller
    - Add try-catch with appropriate HTTP codes
    - Write test: POST /api/users with valid/invalid data
    - Update openapi.yaml with schema
```

### Pattern 4: Database Migration
```yaml
pattern: create-migration
description: Create database migration with up/down paths
steps:
  1. Generate migration file with timestamp
  2. Write up() migration (schema changes)
  3. Write down() migration (rollback)
  4. Add seed data if needed
  5. Test migration in dev environment
  6. Update schema documentation

example:
  task: "Create users table migration in db/migrations/001_create_users.sql"
  actions:
    - Generate: 20241024_create_users_table.sql
    - Write CREATE TABLE users (...)
    - Write DROP TABLE IF EXISTS users
    - Add seed: INSERT INTO users (...)
    - Run: npm run migrate:up
    - Update: db/schema.md
```

## Error Recovery Examples

### Retry Strategy
```javascript
const retryStrategy = {
  maxRetries: 3,
  backoff: 'exponential',
  retryableErrors: ['NetworkError', 'TimeoutError', 'RateLimitError'],
  nonRetryableErrors: ['SyntaxError', 'ValidationError', 'AuthenticationError']
};
```

### Partial Success Handling
When one task fails, independent tasks continue:
- Failed task T004 blocks only its dependents (T008, T009)
- Independent tasks (T005, T006, T007) execute while user fixes T004

## Progress Tracking Examples

### Real-time Progress Display
```
📊 Implementation Progress: ████████░░ 80% (12/15 tasks)

In Progress (3):
  → T012 [P] Create authentication middleware (45s elapsed)
  → T013 [P] Implement login endpoint (12s elapsed)
  → T014 [P] Add password hashing (8s elapsed)

Completed (8): ✓ T001-T008
Queued (4): ⏳ T015-T018
Estimated completion: 3 minutes
```

### Task Execution Summary
```
T012 [P] [US2] Authentication middleware - COMPLETED ✓ (2.3s)
  • Created src/middleware/auth.js with JWT verification
  • Wrote unit tests (4/4 passing)

T013 [P] [US2] Login endpoint - COMPLETED ✓ (3.1s)
  • Created POST /api/auth/login with validation
  • Wrote integration tests (6/6 passing)

T014 [P] [US2] Password hashing - COMPLETED ✓ (1.8s)
  • Created src/utils/password.js module
  • Implemented hash/verify functions with bcrypt
  • Wrote unit tests (8/8 passing)
```

## Configuration Examples

For detailed configuration options, see [shared/config-examples.md](../shared/config-examples.md).

### Quick Reference
```json
{
  "parallel": { "enabled": true, "maxWorkers": 5 },
  "errorRecovery": { "autoRetry": true, "maxRetries": 3 },
  "testing": { "runTests": true, "coverageTarget": 80 },
  "validation": { "linting": true, "typeChecking": true }
}
```

**Profiles:** Fast Prototyping (skip tests) | Standard (default) | Enterprise (TDD, full validation)

## Parallel Execution Examples

**Independent User Stories:**
```markdown
- [ ] T009 [P] [US1] Create User model
- [ ] T010 [P] [US1] Implement auth middleware
- [ ] T011 [P] [US1] Add login endpoint
- [ ] T015 [P] [US2] Create Dashboard component
# Run simultaneously: max(US1, US2) instead of US1 + US2
```

**File Isolation (no conflicts):**
```markdown
- [ ] T020 [P] Create src/models/user.py
- [ ] T021 [P] Create src/models/post.py
- [ ] T022 [P] Create src/models/comment.py
```

**Sequential Dependencies:**
```markdown
- [ ] T001 Initialize database schema
- [ ] T002 Create base models (depends T001)
- [ ] T003 [P] Create User model (depends T002, parallel with T004)
- [ ] T004 [P] Create Post model (depends T002)
- [ ] T005 Create relationships (depends T003, T004)
# Execution: T001 → T002 → (T003 || T004) → T005
```

## Quality Assurance Examples

Pre-execution checks:
✓ Git repository clean | Dependencies installed | Environment vars set | Database accessible

Post-execution validation:
✓ Linting, type checking, formatting | 42/42 unit tests passing (100%) | 87% coverage (target: 80%)

---

*For technical algorithms and detailed reference, see [reference.md](./reference.md)*
