# Spec Orchestrate: Comprehensive Examples

Complete scenarios demonstrating end-to-end workflow orchestration with detailed execution traces, decision points, and outcomes.

---

## Example 1: Complete Greenfield Feature (Default Interactive Mode)

**Context**: Adding user authentication system to a new web application. Project already initialized with Spec.

**User Request**:
"I need to add a complete authentication system with email/password login, JWT tokens, and password reset. Can you run the full workflow?"

**Execution**:

### Initial Assessment

```
Checking prerequisites...
✓ {config.paths.spec_root}/ directory exists
✓ {config.paths.state}/ initialized
✓ Project configuration valid

Analyzing current state...
- Current feature: None (ready for new feature)
- Current phase: idle
- Last checkpoint: None
- Workflow mode: interactive (default)

Starting orchestration for: User authentication system
Estimated phases: 6 (generate → clarify → plan → analyze → tasks → implement)
```

### Phase 1: Generate Specification

```
[1/6] Running spec:generate

Prompt to user: "User authentication with email/password, JWT, password reset"

Processing...
- Creating {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}
- Analyzing requirements
- Generating user stories
- Identifying acceptance criteria

Created specification with:
- 5 user stories (3 P1, 2 P2)
  US1.1 [P1]: User can register with email/password
  US1.2 [P1]: User can login and receive JWT token
  US1.3 [P1]: User can access protected routes with valid JWT
  US2.1 [P2]: User can request password reset via email
  US2.2 [P2]: User can set new password via reset token

- Detected: 3 [CLARIFY] tags requiring clarification
  CLARIFY-1: Token expiration duration?
  CLARIFY-2: Password complexity requirements?
  CLARIFY-3: Email service provider?

Checkpoint saved: {config.paths.state}/checkpoints/2025-10-31-14-23-01-post-generate.md

Duration: 48 seconds
Status: ✓ Complete
```

### Phase 2: Clarify Ambiguities

```
[2/6] Running spec:clarify

Detected: 3 clarifications required

┌─────────────────────────────────────────────────────┐
│ Clarification 1/3: Token Expiration                │
└─────────────────────────────────────────────────────┘

CLARIFY-1: How long should JWT tokens remain valid?

Options:
  [A] Short-lived (15 minutes) with refresh tokens
  [B] Medium duration (1 hour)
  [C] Long-lived (24 hours)
  [D] Configurable via environment variable

User selected: [A] Short-lived (15 minutes) with refresh tokens

Rationale: Better security with refresh token rotation

┌─────────────────────────────────────────────────────┐
│ Clarification 2/3: Password Requirements            │
└─────────────────────────────────────────────────────┘

CLARIFY-2: What password complexity should be enforced?

Options:
  [A] Basic (min 8 characters)
  [B] Standard (min 8 chars, uppercase, lowercase, number)
  [C] Strong (min 12 chars, uppercase, lowercase, number, symbol)
  [D] Custom regex pattern

User selected: [B] Standard (min 8 chars, uppercase, lowercase, number)

Rationale: Balance security and usability

┌─────────────────────────────────────────────────────┐
│ Clarification 3/3: Email Service                    │
└─────────────────────────────────────────────────────┘

CLARIFY-3: Which email service for password reset emails?

Options:
  [A] SendGrid
  [B] AWS SES
  [C] Nodemailer with SMTP
  [D] Mailgun

User selected: [C] Nodemailer with SMTP

Rationale: No external dependencies for development

Updated spec.md:
- Replaced CLARIFY-1 with: "JWT tokens expire after 15 minutes, refresh tokens after 7 days"
- Replaced CLARIFY-2 with: "Min 8 chars with uppercase, lowercase, and number"
- Replaced CLARIFY-3 with: "Use Nodemailer with SMTP for email delivery"

Checkpoint saved: {config.paths.state}/checkpoints/2025-10-31-14-25-43-post-clarify.md

Duration: 2 minutes 42 seconds
Status: ✓ Complete (3/3 clarifications resolved)
```

### Phase 3: Create Technical Plan

```
[3/6] Running spec:plan

Generating technical design...

Analyzing requirements from spec.md:
- 5 user stories identified
- Security requirements: JWT, password hashing, token rotation
- External dependencies: Nodemailer, bcrypt, jsonwebtoken

Researching best practices...
- JWT implementation patterns
- Refresh token storage strategies
- Password reset flow security

Creating architecture components:

1. Data Model
   - User entity (id, email, password_hash, created_at, updated_at)
   - RefreshToken entity (id, user_id, token, expires_at)
   - PasswordResetToken entity (id, user_id, token, expires_at)

2. API Endpoints
   - POST /api/auth/register
   - POST /api/auth/login
   - POST /api/auth/refresh
   - POST /api/auth/logout
   - POST /api/auth/password-reset-request
   - POST /api/auth/password-reset-confirm
   - GET /api/auth/me (protected)

3. Middleware
   - authenticateJWT: Verify JWT tokens
   - validateRequest: Input validation
   - errorHandler: Centralized error handling

4. Services
   - AuthService: Registration, login, token management
   - EmailService: Password reset emails
   - TokenService: JWT and refresh token operations

5. Security Measures
   - bcrypt for password hashing (10 rounds)
   - HTTP-only cookies for refresh tokens
   - Rate limiting on auth endpoints
   - Input sanitization

Architecture Decision Records created:

ADR-001: Use JWT with refresh tokens
- Context: Need stateless authentication with security
- Decision: 15-min access tokens + 7-day refresh tokens
- Consequences: More complex but more secure

ADR-002: Store refresh tokens in database
- Context: Need to revoke tokens on logout
- Decision: Store in RefreshToken table with expiry
- Consequences: Slight performance overhead, better control

ADR-003: Use bcrypt for password hashing
- Context: Need secure password storage
- Decision: bcrypt with cost factor 10
- Consequences: Slower auth but industry standard

Logged to: {config.paths.memory}/DECISIONS-LOG.md

Created: {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan} (324 lines)

Checkpoint saved: {config.paths.state}/checkpoints/2025-10-31-14-32-18-post-plan.md

Duration: 6 minutes 35 seconds
Status: ✓ Complete (3 ADRs logged)
```

### Phase 4: Validate Consistency

```
[4/6] Running spec:analyze

Estimating implementation complexity...
- Estimated tasks: 28 (complex feature)
- Estimated files: 15-18 files
- Recommendation: Run validation

Validating spec ↔ plan consistency...

Checking coverage:
✓ US1.1 addressed by: User model, AuthService.register, POST /register endpoint
✓ US1.2 addressed by: AuthService.login, TokenService, POST /login endpoint
✓ US1.3 addressed by: authenticateJWT middleware, GET /me endpoint
✓ US2.1 addressed by: PasswordResetToken model, EmailService, POST /password-reset-request
✓ US2.2 addressed by: AuthService.resetPassword, POST /password-reset-confirm

Checking consistency:
✓ All user stories have corresponding implementation components
✓ All data models support required operations
✓ All API endpoints align with user stories
✓ Security requirements addressed in architecture

Checking for gaps:
⚠ Warning: US1.2 mentions "secure token storage" but plan doesn't specify token encryption
⚠ Warning: Email templates not mentioned in plan

Risk assessment:
- Medium Risk: Email delivery failures could block password reset (mitigation: add retry logic)
- Low Risk: Token expiry timing edge cases (mitigation: thorough testing)

Validation Summary:
✓ Spec-Plan alignment: 98% (2 minor warnings)
✓ Coverage: 100% (all stories addressed)
✓ Critical issues: 0
⚠ Warnings: 2 (non-blocking)

Recommendation: Proceed with implementation
(Warnings can be addressed during task breakdown)

Checkpoint saved: {config.paths.state}/checkpoints/2025-10-31-14-34-52-post-analyze.md

Duration: 2 minutes 34 seconds
Status: ✓ Complete (0 critical issues)
```

### Phase 5: Generate Task Breakdown

```
[5/6] Running spec:tasks

Breaking down implementation into tasks...

Analyzing plan.md:
- 5 components (models, routes, services, middleware, tests)
- 6 API endpoints
- 3 database tables

Generating task list:

Core Implementation (P1):
T001 [P1]: Set up project dependencies (jsonwebtoken, bcrypt, nodemailer)
T002 [P1]: Create database schema migration for User table
T003 [P1]: Create database schema migration for RefreshToken table
T004 [P1]: Create database schema migration for PasswordResetToken table
T005 [P1]: Implement User model with password hashing
T006 [P1]: Create TokenService for JWT generation/verification
T007 [P1]: Implement AuthService.register method
T008 [P1]: Implement AuthService.login method
T009 [P1]: Implement AuthService.refresh method
T010 [P1]: Create authenticateJWT middleware
T011 [P1]: Implement POST /api/auth/register endpoint
T012 [P1]: Implement POST /api/auth/login endpoint
T013 [P1]: Implement POST /api/auth/refresh endpoint
T014 [P1]: Implement POST /api/auth/logout endpoint
T015 [P1]: Implement GET /api/auth/me endpoint (protected)
T016 [P1]: Write unit tests for AuthService (8 test cases)
T017 [P1]: Write integration tests for auth endpoints (6 test cases)

Password Reset Features (P2):
T018 [P2]: Configure Nodemailer SMTP transport
T019 [P2]: Create email templates (password reset, welcome)
T020 [P2]: Implement EmailService for sending emails
T021 [P2]: Implement AuthService.requestPasswordReset method
T022 [P2]: Implement AuthService.confirmPasswordReset method
T023 [P2]: Implement POST /api/auth/password-reset-request endpoint
T024 [P2]: Implement POST /api/auth/password-reset-confirm endpoint
T025 [P2]: Write tests for password reset flow (5 test cases)

Security Enhancements (P2):
T026 [P2]: Add rate limiting middleware to auth endpoints
T027 [P2]: Implement input validation schemas
T028 [P2]: Add security headers (helmet.js)

Parallel execution opportunities identified:
- [PARALLEL-GROUP-1]: T002, T003, T004 (database migrations - independent)
- [PARALLEL-GROUP-2]: T006, T007, T008, T009 (service methods - independent)
- [PARALLEL-GROUP-3]: T011, T012, T013, T014, T015 (endpoints - independent after services)
- [PARALLEL-GROUP-4]: T018, T019, T020 (email setup - independent)

Task summary:
- Total: 28 tasks
- P1 (Must Have): 17 tasks
- P2 (Should Have): 11 tasks
- Parallel opportunities: 14 tasks across 4 groups
- Estimated completion time: 3-4 hours

Created: {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.tasks} (187 lines)
Updated: {config.paths.memory}/CHANGES-PLANNED.md with 28 new entries

Checkpoint saved: {config.paths.state}/checkpoints/2025-10-31-14-38-27-post-tasks.md

Duration: 3 minutes 35 seconds
Status: ✓ Complete (28 tasks generated)
```

### Phase 6: Execute Implementation

```
[6/6] Running spec:implement

Preparing implementation environment...
✓ Verified working directory clean
✓ Checked dependencies available
✓ Validated write permissions

Starting implementation of 28 tasks...

┌─────────────────────────────────────────────────────┐
│ Would you like to execute parallel tasks?          │
└─────────────────────────────────────────────────────┘

4 parallel groups identified (14 tasks total)
Running in parallel can reduce time by ~35%

Options:
  [Y] Yes, run parallel tasks concurrently
  [N] No, run all tasks serially
  [S] Show me which tasks would run in parallel

User selected: [Y] Yes

────────────────────────────────────────────────────────
Task T001: Set up project dependencies
────────────────────────────────────────────────────────
Status: Running...
Action: Installing npm packages (jsonwebtoken, bcrypt, nodemailer, express-rate-limit)
✓ Complete (18 seconds)

────────────────────────────────────────────────────────
Parallel Group 1: Database Migrations (T002, T003, T004)
────────────────────────────────────────────────────────
Status: Running in parallel...

T002: Create User table migration
  ✓ Created migrations/001_create_users_table.js

T003: Create RefreshToken table migration
  ✓ Created migrations/002_create_refresh_tokens_table.js

T004: Create PasswordResetToken table migration
  ✓ Created migrations/003_create_password_reset_tokens_table.js

✓ All complete (12 seconds)

────────────────────────────────────────────────────────
Task T005: Implement User model with password hashing
────────────────────────────────────────────────────────
Status: Running...
Action: Creating models/User.js with bcrypt integration
✓ Complete (24 seconds)
  - Created models/User.js (78 lines)
  - Added password hashing pre-save hook
  - Added password comparison method

────────────────────────────────────────────────────────
Parallel Group 2: Service Methods (T006, T007, T008, T009)
────────────────────────────────────────────────────────
Status: Running in parallel...

T006: Create TokenService
  ✓ Created services/TokenService.js (92 lines)

T007: Implement AuthService.register
  ✓ Created services/AuthService.js with register method

T008: Implement AuthService.login
  ✓ Added login method to services/AuthService.js

T009: Implement AuthService.refresh
  ✓ Added refresh method to services/AuthService.js

✓ All complete (38 seconds)

────────────────────────────────────────────────────────
Task T010: Create authenticateJWT middleware
────────────────────────────────────────────────────────
Status: Running...
Action: Creating middleware/authenticateJWT.js
✓ Complete (15 seconds)

────────────────────────────────────────────────────────
Parallel Group 3: API Endpoints (T011-T015)
────────────────────────────────────────────────────────
Status: Running in parallel...

T011: POST /api/auth/register
  ✓ Created routes/auth.js with register endpoint

T012: POST /api/auth/login
  ✓ Added login endpoint to routes/auth.js

T013: POST /api/auth/refresh
  ✓ Added refresh endpoint to routes/auth.js

T014: POST /api/auth/logout
  ✓ Added logout endpoint to routes/auth.js

T015: GET /api/auth/me
  ✓ Added protected me endpoint to routes/auth.js

✓ All complete (42 seconds)

────────────────────────────────────────────────────────
Task T016: Write unit tests for AuthService
────────────────────────────────────────────────────────
Status: Running...
Action: Creating tests/unit/AuthService.test.js
✓ Complete (31 seconds)
  - 8 test cases written
  - All tests passing ✓

────────────────────────────────────────────────────────
Task T017: Write integration tests for auth endpoints
────────────────────────────────────────────────────────
Status: Running...
Action: Creating tests/integration/auth.test.js
✓ Complete (28 seconds)
  - 6 test cases written
  - All tests passing ✓

Progress: 17/28 tasks complete (P1 complete) - 60%

┌─────────────────────────────────────────────────────┐
│ P1 tasks complete. Continue with P2 tasks?         │
└─────────────────────────────────────────────────────┘

Options:
  [Y] Yes, continue with P2 tasks (password reset, security)
  [N] No, stop here (P2 can be done later)
  [R] Review P1 implementation first

User selected: [Y] Yes

────────────────────────────────────────────────────────
Parallel Group 4: Email Setup (T018, T019, T020)
────────────────────────────────────────────────────────
Status: Running in parallel...

T018: Configure Nodemailer SMTP transport
  ✓ Created config/email.js with SMTP configuration

T019: Create email templates
  ✓ Created templates/emails/password-reset.html
  ✓ Created templates/emails/welcome.html

T020: Implement EmailService
  ✓ Created services/EmailService.js (65 lines)

✓ All complete (25 seconds)

────────────────────────────────────────────────────────
Task T021: Implement requestPasswordReset method
────────────────────────────────────────────────────────
Status: Running...
Action: Adding requestPasswordReset to services/AuthService.js
✓ Complete (22 seconds)

────────────────────────────────────────────────────────
Task T022: Implement confirmPasswordReset method
────────────────────────────────────────────────────────
Status: Running...
Action: Adding confirmPasswordReset to services/AuthService.js
✓ Complete (18 seconds)

────────────────────────────────────────────────────────
Task T023: POST /api/auth/password-reset-request endpoint
────────────────────────────────────────────────────────
Status: Running...
Action: Adding endpoint to routes/auth.js
✓ Complete (12 seconds)

────────────────────────────────────────────────────────
Task T024: POST /api/auth/password-reset-confirm endpoint
────────────────────────────────────────────────────────
Status: Running...
Action: Adding endpoint to routes/auth.js
✓ Complete (11 seconds)

────────────────────────────────────────────────────────
Task T025: Write tests for password reset flow
────────────────────────────────────────────────────────
Status: Running...
Action: Creating tests/integration/password-reset.test.js
✓ Complete (26 seconds)
  - 5 test cases written
  - All tests passing ✓

────────────────────────────────────────────────────────
Task T026: Add rate limiting middleware
────────────────────────────────────────────────────────
Status: Running...
Action: Creating middleware/rateLimiter.js and applying to routes
✓ Complete (15 seconds)

────────────────────────────────────────────────────────
Task T027: Implement input validation schemas
────────────────────────────────────────────────────────
Status: Running...
Action: Creating validation/authSchemas.js with Joi schemas
✓ Complete (20 seconds)

────────────────────────────────────────────────────────
Task T028: Add security headers (helmet.js)
────────────────────────────────────────────────────────
Status: Running...
Action: Configuring helmet middleware in app.js
✓ Complete (8 seconds)

════════════════════════════════════════════════════════
Implementation Complete!
════════════════════════════════════════════════════════

Progress: 28/28 tasks complete (100%)

Updated files:
- {config.paths.state}/current-session.md (status: complete)
- {config.paths.memory}/CHANGES-COMPLETED.md (28 entries added)
- {config.paths.memory}/WORKFLOW-PROGRESS.md (updated metrics)

Checkpoint saved: {config.paths.state}/checkpoints/2025-10-31-14-48-15-complete.md

Duration: 9 minutes 48 seconds
Total parallel time saved: ~3 minutes 22 seconds
Status: ✓ Complete
```

### Final Summary

```
════════════════════════════════════════════════════════
Orchestration Complete: User Authentication System
════════════════════════════════════════════════════════

Total Duration: 23 minutes 42 seconds
  - Generate: 48s
  - Clarify: 2m 42s
  - Plan: 6m 35s
  - Analyze: 2m 34s
  - Tasks: 3m 35s
  - Implement: 9m 48s

Phases Executed: 6/6
  ✓ spec:generate (spec.md created)
  ✓ spec:clarify (3 clarifications resolved)
  ✓ spec:plan (plan.md created, 3 ADRs logged)
  ✓ spec:analyze (validation passed, 2 warnings)
  ✓ spec:tasks (28 tasks generated)
  ✓ spec:implement (28/28 tasks complete)

Artifacts Created:
  - {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec} (142 lines)
  - {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan} (324 lines)
  - {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.tasks} (187 lines)
  - 3 ADRs in {config.paths.memory}/DECISIONS-LOG.md

Implementation Summary:
  - Files created: 18 files
  - Lines added: +2,247
  - Lines deleted: -0
  - Tests written: 19 test cases
  - Tests passing: 19/19 ✓

Code Coverage:
  - Overall: 94.2%
  - AuthService: 97.1%
  - TokenService: 91.8%
  - Routes: 92.5%

Next Steps:
  1. Review implementation in feature/001-authentication branch
  2. Test authentication flow manually
  3. Update API documentation
  4. Create pull request when ready

Checkpoints saved: 6
Resume command: /spec orchestrate --resume (if needed)
```

---

## Example 2: Auto Mode (Minimal Interaction)

**Context**: Need to rapidly prototype a contact form feature without interruptions. Speed is priority over detailed interaction.

**User Request**:
"Quick POC for contact form submission with email notifications. Just get it done fast."

**Command**: User explicitly requests auto mode via: "Run orchestrate in auto mode"

**Execution**:

### Auto Mode Initialization

```
Auto Mode Enabled
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Configuration:
  - Minimize user prompts: ✓
  - Use sensible defaults: ✓
  - Skip optional phases: ✓
  - Fast-track decisions: ✓
  - Reduced validation: ✓

Proceeding with automatic workflow execution...
```

### Phase 1: Generate (Auto)

```
[1/6] spec:generate ████████████████████████████ Complete (32s)

Created: {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}
- 3 user stories generated (simple feature, all P1)
- 0 [CLARIFY] tags (straightforward requirements)
- Using defaults for unspecified details

Auto-decisions made:
  ✓ Form fields: name, email, message (standard)
  ✓ Validation: HTML5 + server-side
  ✓ Storage: PostgreSQL database
```

### Phase 2: Clarify (Skipped)

```
[2/6] spec:clarify ░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Skipped (0s)

Reason: No [CLARIFY] tags present
Status: Proceeding to next phase
```

### Phase 3: Plan (Auto)

```
[3/6] spec:plan ████████████████████████████ Complete (1m 29s)

Created: {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan}
- Architecture: Simple REST API + database
- No research needed (standard patterns)

Auto-decisions made:
  ✓ Email service: Nodemailer (from previous feature)
  ✓ Form validation: express-validator
  ✓ Database table: contact_submissions
  ✓ API endpoint: POST /api/contact

ADRs logged:
  - ADR-004: Use existing email infrastructure (auto-selected)
  - ADR-005: No spam protection for POC (auto-deferred to P3)
```

### Phase 4: Analyze (Skipped)

```
[4/6] spec:analyze ░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Skipped (0s)

Reason: Auto mode + simple feature (<10 tasks estimated)
Status: Validation deferred, proceeding to tasks
```

### Phase 5: Tasks (Auto)

```
[5/6] spec:tasks ████████████████████████████ Complete (24s)

Created: {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.tasks}
- 8 tasks generated (all P1)
- Serial execution plan (no parallelization in auto mode)

Task list:
  T001: Create database migration for contact_submissions table
  T002: Create ContactSubmission model
  T003: Implement ContactService.submit method
  T004: Create POST /api/contact endpoint
  T005: Add form validation middleware
  T006: Update EmailService for contact notifications
  T007: Write tests for contact submission
  T008: Create simple HTML form (optional)
```

### Phase 6: Implement (Auto)

```
[6/6] spec:implement ████████████████████████████ Complete (4m 27s)

Executing tasks serially (auto mode)...

T001 ✓ (14s) - Migration created
T002 ✓ (18s) - Model created
T003 ✓ (32s) - Service method implemented
T004 ✓ (28s) - API endpoint created
T005 ✓ (21s) - Validation added
T006 ✓ (35s) - Email service updated
T007 ✓ (56s) - Tests written (4 test cases, all passing)
T008 ✓ (43s) - HTML form created

Progress: 8/8 tasks (100%)

No prompts for:
  - Parallel execution (auto mode runs serial)
  - P2 continuation (no P2 tasks)
  - Manual review (auto mode)
```

### Auto Mode Summary

```
════════════════════════════════════════════════════════
Auto Mode Complete: Contact Form
════════════════════════════════════════════════════════

Total Duration: 6 minutes 52 seconds
Prompts Required: 0 (fully automatic)

Time Comparison:
  - Auto mode: 6m 52s
  - Estimated interactive mode: 12-15 minutes
  - Time saved: ~45%

Phases Executed: 4/6
  ✓ spec:generate (32s)
  ⏭ spec:clarify (skipped - no clarifications)
  ✓ spec:plan (1m 29s)
  ⏭ spec:analyze (skipped - auto mode)
  ✓ spec:tasks (24s)
  ✓ spec:implement (4m 27s)

Auto-Decisions Made: 6
  - Form fields (standard)
  - Email service (reused)
  - Spam protection (deferred)
  - Validation approach (standard)
  - Execution mode (serial)
  - Review step (skipped)

Implementation:
  - Files created: 6 files
  - Tests: 4/4 passing ✓
  - Ready for testing

Trade-offs:
  ✓ Faster execution
  ✓ No interruptions
  ⚠ Less customization
  ⚠ Skipped validation
  ⚠ No parallel execution optimization

Recommendation: Suitable for POCs and simple features
For production features, use interactive mode
```

---

## Example 3: Resume After Interruption

**Context**: Implementing a complex payment processing feature. Network failure occurred during implementation phase at task 12 of 27.

**Initial Run** (Before Interruption):

```
Starting orchestration: Stripe payment processing integration

[1/6] spec:generate ████████████████████████████ Complete (52s)
[2/6] spec:clarify ████████████████████████████ Complete (3m 18s)
[3/6] spec:plan ████████████████████████████ Complete (7m 45s)
[4/6] spec:analyze ████████████████████████████ Complete (3m 12s)
[5/6] spec:tasks ████████████████████████████ Complete (4m 22s)
[6/6] spec:implement ████████░░░░░░░░░░░░░░░░░ INTERRUPTED

Progress at interruption:
  - Phase: Implementation
  - Tasks completed: 11/27 (41%)
  - Last checkpoint: 2025-10-31-15-42-18-task-11.md
  - Reason: Network connection lost during task T012

Files modified before interruption:
  ✓ T001-T011 completed successfully
  ⚠ T012 partially complete (transaction incomplete)
  ✗ T013-T027 not started
```

**User Returns** (30 minutes later):

```
User: "Resume the payment processing workflow"
```

**Resume Execution**:

### Step 1: Checkpoint Detection

```
Resume Mode Activated
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Scanning for checkpoints in {config.paths.state}/checkpoints/...

Found checkpoints:
  ✓ 2025-10-31-15-23-04-post-generate.md
  ✓ 2025-10-31-15-26-22-post-clarify.md
  ✓ 2025-10-31-15-34-07-post-plan.md
  ✓ 2025-10-31-15-37-19-post-analyze.md
  ✓ 2025-10-31-15-41-41-post-tasks.md
  ⚠ 2025-10-31-15-42-18-task-11.md (partial - during implementation)

Most recent valid checkpoint:
  - Timestamp: 2025-10-31-15-42-18
  - Phase: Implementation
  - Feature: 003-payment-processing
  - Progress: 11/27 tasks complete

Loading checkpoint state...
```

### Step 2: State Recovery

```
Restoring Workflow State
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Feature: 003-payment-processing
Status: In Progress

Loaded artifacts:
  ✓ {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec} (verified)
  ✓ {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan} (verified)
  ✓ {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.tasks} (verified)

Completed tasks (validated):
  ✓ T001: Set up Stripe SDK dependencies
  ✓ T002: Configure Stripe API keys
  ✓ T003: Create Payment model
  ✓ T004: Create Customer model
  ✓ T005: Implement PaymentService.createPaymentIntent
  ✓ T006: Implement PaymentService.capturePayment
  ✓ T007: Create POST /api/payments/intent endpoint
  ✓ T008: Create POST /api/payments/capture endpoint
  ✓ T009: Implement webhook verification
  ✓ T010: Create POST /api/webhooks/stripe endpoint
  ✓ T011: Write tests for PaymentService (6 tests ✓)

Partially completed task (will be restarted):
  ⚠ T012: Create payment UI components
  Status: Transaction incomplete (file write interrupted)
  Action: Will restart from beginning

Pending tasks:
  ✗ T013-T027: Not started (16 remaining)

Files modified during session (verified intact):
  - models/Payment.js ✓
  - models/Customer.js ✓
  - services/PaymentService.js ✓
  - routes/payments.js ✓
  - routes/webhooks.js ✓
  - middleware/verifyStripeWebhook.js ✓
  - tests/unit/PaymentService.test.js ✓

Session integrity: ✓ Valid (all completed work preserved)
Resume point: Task T012 (will restart)
```

### Step 3: Resume Confirmation

```
┌────────────────────────────────────────────────────────┐
│ Resume Implementation                                  │
└────────────────────────────────────────────────────────┘

Checkpoint loaded successfully. Ready to continue.

Progress Summary:
  - Completed: 11/27 tasks (41%)
  - Remaining: 16 tasks (59%)
  - Estimated time to complete: ~12-15 minutes

Resume Options:
  [A] Continue from task T012 (restart partial task)
  [B] Review completed tasks first
  [C] Restart from task T001 (not recommended)
  [D] Abort and exit

User selected: [A] Continue from task T012

Resuming implementation from task T012...
```

### Step 4: Continue Implementation

```
Resuming Implementation Phase
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Starting at: Task T012 (restarting after interruption)
Remaining: 16 tasks

────────────────────────────────────────────────────────
Task T012: Create payment UI components [RESTART]
────────────────────────────────────────────────────────
Status: Running...
Action: Creating React components for Stripe integration
✓ Complete (41s)
  - Created components/PaymentForm.jsx
  - Created components/CardElement.jsx
  - Stripe Elements integrated

────────────────────────────────────────────────────────
Task T013: Implement payment confirmation page
────────────────────────────────────────────────────────
Status: Running...
✓ Complete (28s)

────────────────────────────────────────────────────────
Parallel Group: Customer Management (T014, T015, T016)
────────────────────────────────────────────────────────
Status: Running in parallel...

T014: Implement CustomerService.create ✓ (32s)
T015: Implement CustomerService.update ✓ (28s)
T016: Create customer management endpoints ✓ (35s)

✓ All complete (35s total)

────────────────────────────────────────────────────────
Task T017: Add payment error handling
────────────────────────────────────────────────────────
Status: Running...
✓ Complete (22s)

[Progress continues for T018-T027...]

════════════════════════════════════════════════════════
Resume Complete!
════════════════════════════════════════════════════════

Resumed at: Task T012
Completed: 16 tasks (T012-T027)
Total tasks: 27/27 (100%)

Resume session metrics:
  - Resume time: 11 minutes 42 seconds
  - Tasks completed: 16 tasks
  - Zero rework needed (checkpoint integrity preserved)
  - Time saved: ~15 minutes (avoided re-running T001-T011)

Session totals:
  - Original session: 11 tasks before interruption
  - Interruption duration: 30 minutes (user away)
  - Resume session: 16 tasks
  - Combined implementation time: 21 minutes 28 seconds
  - Total workflow time: 40 minutes 56 seconds

Status: ✓ Complete
All tests passing: 19/19 ✓
```

### Resume Summary

```
════════════════════════════════════════════════════════
Successful Resume: Payment Processing Feature
════════════════════════════════════════════════════════

Timeline:
  - Initial start: 2025-10-31 15:23:04
  - Interruption: 2025-10-31 15:42:18 (at task 11)
  - Resume: 2025-10-31 16:12:35 (30 min gap)
  - Completion: 2025-10-31 16:24:17

Recovery Success:
  ✓ All completed work preserved
  ✓ Partial task (T012) correctly identified and restarted
  ✓ No data corruption
  ✓ Seamless continuation

Time Efficiency:
  - Work preserved: 11 tasks (~10 minutes of work)
  - Resume overhead: <5 seconds (checkpoint loading)
  - Zero rework required
  - Time saved vs restart: ~15 minutes

Key Benefits of Checkpointing:
  1. No lost work from interruptions
  2. Intelligent partial task handling
  3. Fast resume with context restoration
  4. File integrity verification
  5. Clear progress tracking

Lesson: Always use checkpoints for long-running workflows
Resume command: Always available with /spec orchestrate --resume
```

---

## Example 4: Selective Phase Execution

**Context**: Product owner wants to review specification and technical design before committing to implementation. Need to stop workflow early for approval.

**User Request**:
"I want to see the spec and plan for the product search feature, but don't start implementing yet. I need to review and get approval first."

**Execution**:

### Phase 1: Generate Specification

```
[1/6] spec:generate ████████████████████████████ Complete (56s)

Created: {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}

User Stories Generated:
  US1.1 [P1]: User can search products by keyword
  US1.2 [P1]: User can filter search results
  US1.3 [P1]: User can sort search results
  US2.1 [P2]: User can save search queries
  US2.2 [P2]: System provides autocomplete suggestions

Detected: 4 [CLARIFY] tags
```

### Phase 2: Clarify Requirements

```
[2/6] spec:clarify ████████████████████████████ Complete (4m 12s)

Clarifications resolved:
  ✓ Search engine: Elasticsearch 8.x selected
  ✓ Search scope: Products, categories, tags
  ✓ Filter types: Price range, category, brand, rating
  ✓ Autocomplete: Server-side with debouncing

Updated: spec.md (all ambiguities resolved)
```

### Phase 3: Create Technical Plan

```
[3/6] spec:plan ████████████████████████████ Complete (8m 18s)

Created: {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan}

Architecture Components:
  - Elasticsearch cluster setup
  - Product indexing service
  - Search API with facets
  - Autocomplete endpoint
  - Search analytics tracking

Research conducted:
  - Elasticsearch best practices
  - Fuzzy search configuration
  - Performance optimization strategies

ADRs logged: 5
  - ADR-006: Use Elasticsearch for search (vs PostgreSQL full-text)
  - ADR-007: Index products asynchronously via queue
  - ADR-008: Implement faceted search with aggregations
  - ADR-009: Cache frequent search queries (Redis)
  - ADR-010: Track search analytics for relevance tuning
```

### Phase 4: User Stop Request

```
┌────────────────────────────────────────────────────────┐
│ Continue to Validation?                                │
└────────────────────────────────────────────────────────┘

Next phase: spec:analyze (validate spec ↔ plan consistency)

User: "No, stop here. I need to review these documents with the team before we continue."

Options:
  [A] Stop now, save checkpoint
  [B] Just run validation, then stop
  [C] Continue full workflow

User selected: [A] Stop now, save checkpoint

Stopping workflow as requested...
Checkpoint saved: {config.paths.state}/checkpoints/2025-10-31-16-45-33-post-plan.md
```

### Selective Execution Summary

```
════════════════════════════════════════════════════════
Workflow Paused: Product Search Feature
════════════════════════════════════════════════════════

Duration: 13 minutes 26 seconds

Phases Completed: 3/6
  ✓ spec:generate (56s)
  ✓ spec:clarify (4m 12s)
  ✓ spec:plan (8m 18s)
  ⏸ Paused (by user request)
  ⏭ spec:analyze (not run)
  ⏭ spec:tasks (not run)
  ⏭ spec:implement (not run)

Artifacts Created:
  ✓ {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec} (198 lines)
  ✓ {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan} (427 lines)
  ✓ 5 ADRs in {config.paths.memory}/DECISIONS-LOG.md

State: Paused for review
Checkpoint: Saved successfully

Next Steps:
  1. Review spec.md with product team
  2. Review plan.md with engineering team
  3. Review ADRs with architecture team
  4. Get stakeholder approval

When Ready to Continue:
  Option A - Resume full workflow:
    Command: /spec orchestrate --resume
    Will continue from: spec:analyze → spec:tasks → spec:implement

  Option B - Run phases individually:
    Command: /spec analyze (validate)
    Command: /spec tasks (breakdown)
    Command: /spec implement (execute)

  Option C - Make changes and restart:
    1. Edit spec.md or plan.md as needed
    2. Command: /spec orchestrate --resume --revalidate

Review Materials:
  📄 Specification: {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}
  📄 Technical Plan: {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan}
  📄 Architecture Decisions: {config.paths.memory}/DECISIONS-LOG.md (ADR-006 to ADR-010)

Estimated time to complete (when resumed): ~18-22 minutes
  - spec:analyze: ~3 minutes
  - spec:tasks: ~4 minutes
  - spec:implement: ~11-15 minutes
```

### Later: Resume After Approval

```
[Two days later, after team approval]

User: "The team approved the search feature plan. Let's continue with implementation."

Command: /spec orchestrate --resume

Resuming from checkpoint...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Loaded checkpoint: 2025-10-31-16-45-33-post-plan.md
Feature: 004-product-search
Last completed phase: plan
Next phase: analyze

Continuing workflow...

[4/6] spec:analyze ████████████████████████████ Complete (3m 8s)
[5/6] spec:tasks ████████████████████████████ Complete (4m 34s)
[6/6] spec:implement ████████████████████████████ Complete (14m 18s)

════════════════════════════════════════════════════════
Complete: Product Search Feature
════════════════════════════════════════════════════════

Total time (across sessions):
  - Initial session: 13m 26s (generate → plan)
  - Review period: 2 days
  - Resume session: 22m 0s (analyze → implement)
  - Total workflow time: 35m 26s

Status: ✓ Complete
```

---

## Example 5: Complex Clarifications with Multi-Round Questions

**Context**: Building a reporting dashboard with vague, ambiguous requirements that need extensive clarification.

**User Request**:
"Add a comprehensive reporting dashboard for analytics"

**Execution**:

### Phase 1: Generate with Extensive Ambiguity

```
[1/6] spec:generate ████████████████████████████ Complete (1m 8s)

Created: {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}

User Stories Generated: 7 stories
  US1.1 [P1]: User can view sales reports
  US1.2 [P1]: User can view analytics reports
  US1.3 [P1]: User can export reports
  US2.1 [P2]: User can schedule recurring reports
  US2.2 [P2]: User can create custom reports
  US3.1 [P3]: System sends report alerts
  US3.2 [P3]: User can share reports with team

Ambiguity Alert: 9 [CLARIFY] tags detected!
This is a complex feature requiring extensive clarification.

Clarification preview:
  - CLARIFY-1: Which types of reports needed?
  - CLARIFY-2: Real-time or batch processing?
  - CLARIFY-3: Export formats?
  - CLARIFY-4: Access control model?
  - CLARIFY-5: Data retention period?
  - CLARIFY-6: Dashboard refresh rate?
  - CLARIFY-7: Custom report builder UI?
  - CLARIFY-8: Alert delivery methods?
  - CLARIFY-9: Performance requirements?
```

### Phase 2: Multi-Round Clarification Process

```
[2/6] spec:clarify ████████████████████████████ Starting...

Clarification Strategy:
  - Total clarifications: 9
  - Approach: Multi-round questioning
  - Round 1: Critical decisions (3 questions)
  - Round 2: Detailed requirements (3 questions)
  - Round 3: Advanced features (3 questions)

This will take several minutes. Grab coffee! ☕

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Round 1: Critical Decisions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌────────────────────────────────────────────────────────┐
│ Question 1/9: Report Types                             │
└────────────────────────────────────────────────────────┘

CLARIFY-1: Which types of reports are needed?

Background: Different report types require different data models and processing.

Options:
  [A] Sales reports only
      - Revenue, transactions, products sold
      - Simpler implementation
      - Estimated: 12 tasks

  [B] Analytics reports only
      - User behavior, page views, conversions
      - Requires analytics integration
      - Estimated: 15 tasks

  [C] Both sales and analytics ⭐ Recommended for comprehensive dashboard
      - Complete business intelligence
      - More complex but more valuable
      - Estimated: 25 tasks

  [D] Custom - specify exact report types

User selected: [C] Both sales and analytics

Decision logged: Will implement both sales and analytics reporting
Impact: +13 additional tasks, +2 external integrations

┌────────────────────────────────────────────────────────┐
│ Question 2/9: Processing Mode                          │
└────────────────────────────────────────────────────────┘

CLARIFY-2: Real-time or batch processing for reports?

Background: Real-time is responsive but resource-intensive; batch is efficient but delayed.

Context: You selected both sales and analytics reports.
- Sales data: Best for batch (large datasets)
- Analytics data: Can benefit from real-time (user engagement)

Options:
  [A] Real-time updates for everything
      - WebSocket connections, immediate updates
      - High server load
      - Better UX but expensive

  [B] Batch processing for everything
      - Scheduled updates (e.g., hourly, daily)
      - Efficient, lower cost
      - Acceptable for most use cases

  [C] Hybrid approach ⭐ Recommended
      - Real-time: Simple metrics (active users, recent sales)
      - Batch: Complex reports (trends, aggregations)
      - Balanced performance and UX

  [D] Custom processing rules

User selected: [C] Hybrid approach

Decision logged: Real-time for simple metrics, batch for complex reports
Impact: +5 tasks (WebSocket setup), +1 architecture decision

Sub-question:
  Batch report frequency?
    [1] Every 15 minutes
    [2] Hourly ⭐
    [3] Daily
    [4] Configurable per report

User selected: [2] Hourly with configurable override

┌────────────────────────────────────────────────────────┐
│ Question 3/9: Export Formats                           │
└────────────────────────────────────────────────────────┘

CLARIFY-3: Which export formats should be supported?

Background: Each format requires different libraries and formatting logic.

Options:
  [A] PDF only
      - Professional presentation
      - Estimated: +3 tasks

  [B] CSV/Excel only
      - Data analysis focused
      - Estimated: +2 tasks

  [C] Multiple formats (PDF, CSV, Excel) ⭐ Most flexible
      - Users choose preferred format
      - Estimated: +6 tasks

  [D] JSON API only (no file exports)

User selected: [C] Multiple formats (PDF, CSV, Excel)

Decision logged: Support PDF, CSV, and Excel exports
Impact: +6 tasks, +2 dependencies (pdfkit, exceljs)

Round 1 Complete (3/9 clarifications)
Time elapsed: 2 minutes 18 seconds

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Round 2: Detailed Requirements
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Questions 4-6 follow similar pattern...]

┌────────────────────────────────────────────────────────┐
│ Question 4/9: Access Control                           │
└────────────────────────────────────────────────────────┘

CLARIFY-4: How should report access be controlled?

User selected: [B] Role-based access control (RBAC)
- Admin: All reports
- Manager: Department reports
- User: Personal reports only

Impact: +4 tasks (role checking, permissions)

┌────────────────────────────────────────────────────────┐
│ Question 5/9: Data Retention                           │
└────────────────────────────────────────────────────────┘

CLARIFY-5: How long should historical report data be retained?

User selected: [B] 1 year retention
- Balance between data availability and storage costs
- Automated cleanup after 1 year

Impact: +2 tasks (cleanup job, archiving)

┌────────────────────────────────────────────────────────┐
│ Question 6/9: Dashboard Refresh                        │
└────────────────────────────────────────────────────────┘

CLARIFY-6: How often should dashboard metrics refresh?

Context: You selected hybrid processing (real-time + batch)

User selected: [C] Real-time metrics refresh every 5 seconds, batch reports on update
- Real-time: Active users, recent sales (WebSocket)
- Batch: Complex charts, trends (poll on completion)

Impact: +3 tasks (WebSocket, polling logic)

Round 2 Complete (6/9 clarifications)
Time elapsed: 4 minutes 42 seconds

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Round 3: Advanced Features
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌────────────────────────────────────────────────────────┐
│ Question 7/9: Custom Report Builder                    │
└────────────────────────────────────────────────────────┘

CLARIFY-7: Should users be able to create custom reports?

User selected: [B] Admin-only custom reports
- Regular users: Predefined reports only
- Admins: Drag-drop report builder

Impact: +8 tasks (report builder UI, query generator)
Priority: P2 (can defer if needed)

┌────────────────────────────────────────────────────────┐
│ Question 8/9: Alert Delivery                           │
└────────────────────────────────────────────────────────┘

CLARIFY-8: How should report alerts be delivered?

User selected: [C] Multiple channels (email + in-app)
- Email: Digest format
- In-app: Real-time notifications

Impact: +4 tasks (notification system)
Priority: P3 (nice-to-have)

┌────────────────────────────────────────────────────────┐
│ Question 9/9: Performance Requirements                 │
└────────────────────────────────────────────────────────┘

CLARIFY-9: What are the performance expectations?

Background: Based on your selections, estimated data volume:
- 100K+ sales records
- 500K+ analytics events per day

User selected: [B] Standard performance (2-5 second response times)
- Acceptable for business reports
- Use database indexing and caching
- No expensive real-time compute

Impact: +3 tasks (performance optimization, caching)

Round 3 Complete (9/9 clarifications)
Total clarification time: 7 minutes 28 seconds

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Clarification Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

All ambiguities resolved!

Decisions Summary:
  1. Report types: Sales + Analytics
  2. Processing: Hybrid (real-time + batch hourly)
  3. Export formats: PDF, CSV, Excel
  4. Access control: Role-based (Admin/Manager/User)
  5. Data retention: 1 year with automated cleanup
  6. Refresh rate: 5 seconds (real-time), on-completion (batch)
  7. Custom reports: Admin-only builder (P2)
  8. Alerts: Email + in-app notifications (P3)
  9. Performance: 2-5 second response times

Impact Analysis:
  - Base tasks: 14
  - Added by clarifications: +44 tasks
  - Total estimated: 58 tasks
  - Feature complexity: High
  - Estimated implementation: 6-8 hours

Updated: spec.md (all 9 [CLARIFY] tags resolved)
Status: Ready for planning

[2/6] spec:clarify ████████████████████████████ Complete (7m 28s)
```

### Phases 3-6: Continue Normally

```
[3/6] spec:plan ████████████████████████████ Complete (12m 45s)
  - Comprehensive architecture for complex feature
  - 7 ADRs logged (processing, exports, caching, etc.)

[4/6] spec:analyze ████████████████████████████ Complete (4m 18s)
  - Validation passed
  - 1 warning: High complexity (58 tasks)
  - Recommendation: Consider phased delivery

[5/6] spec:tasks ████████████████████████████ Complete (6m 52s)
  - 58 tasks generated (34 P1, 18 P2, 6 P3)
  - 8 parallel groups identified

[6/6] spec:implement ████████████████████████████ Complete (28m 36s)
  - P1 tasks: 34/34 complete
  - P2 tasks: User opted to defer (implement later)
  - P3 tasks: Deferred
```

### Complex Clarification Summary

```
════════════════════════════════════════════════════════
Complete: Reporting Dashboard (Complex Feature)
════════════════════════════════════════════════════════

Total Duration: 60 minutes 47 seconds
  - Generate: 1m 8s
  - Clarify: 7m 28s (9 rounds, critical for success)
  - Plan: 12m 45s
  - Analyze: 4m 18s
  - Tasks: 6m 52s
  - Implement: 28m 36s (P1 only)

Clarification Impact:
  - Questions asked: 9 (across 3 rounds)
  - User interaction time: ~7 minutes
  - Tasks added by clarifications: +44 tasks
  - Ambiguities prevented: 9 major issues

Value of Clarification:
  ✓ Avoided 3+ days of rework
  ✓ Clear requirements from start
  ✓ All stakeholders aligned
  ✓ Technical approach validated
  ✓ Realistic scope established

Key Lesson: 7 minutes clarifying >> 3 days fixing wrong implementation

Final Scope:
  - P1 Complete: 34 tasks (core reporting)
  - P2 Deferred: 18 tasks (custom builder)
  - P3 Deferred: 6 tasks (advanced alerts)
  - Total delivered: 34/58 tasks (59%)

Next Steps:
  - Deploy P1 features
  - Gather user feedback
  - Plan P2 delivery for next sprint
```

---

## Example 6: Error Recovery with Validation Failures

**Context**: Building an API rate limiting feature. Validation discovers critical inconsistencies between specification and technical plan that must be corrected before implementation.

**User Request**:
"Implement API rate limiting with tiered plans"

**Execution**:

### Phases 1-3: Normal Flow

```
[1/6] spec:generate ████████████████████████████ Complete (38s)
[2/6] spec:clarify ████████████████████████████ Complete (1m 52s)
[3/6] spec:plan ████████████████████████████ Complete (5m 24s)
```

### Phase 4: Validation Reveals Critical Issues

```
[4/6] spec:analyze ████████████████████████████ Starting...

Running comprehensive validation...

Checking spec.md ↔ plan.md consistency...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VALIDATION ERRORS DETECTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

❌ CRITICAL Issue 1: Missing Implementation

Location: spec.md, Line 45
User Story: US1.3 [P1] "User can upgrade/downgrade rate limit tier"

Problem: This P1 story is NOT addressed in plan.md
Impact: Core feature will be missing from implementation
Required: Plan must include tier management logic

❌ CRITICAL Issue 2: Priority Mismatch

Location: spec.md US2.2 vs tasks.md
User Story: US2.2 [P1] "System enforces rate limits per endpoint"

Problem: Spec marks this as P1 (Must Have), but plan.md treats it as P2
Impact: Critical functionality might be deferred
Required: Align priorities between spec and plan

⚠️ HIGH Issue 3: Orphaned Implementation

Location: plan.md, Section 4.3 "Redis cluster setup"
Problem: No user story justifies Redis cluster (only single instance needed for spec scope)
Impact: Over-engineering, unnecessary complexity
Recommendation: Simplify to single Redis instance or justify with story

⚠️ MEDIUM Issue 4: Incomplete Coverage

Location: plan.md
User Story: US1.4 [P1] "Admin can view rate limit usage"

Problem: Plan mentions "admin dashboard" but provides no implementation details
Impact: Vague requirements lead to implementation uncertainty
Recommendation: Add detailed admin dashboard design to plan

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Validation Summary:
  ❌ Critical Issues: 2 (block implementation)
  ⚠️ High Issues: 1 (strongly recommend fixing)
  ⚠️ Medium Issues: 1 (should address)

  Coverage: 85% (3/4 P1 stories addressed)
  Consistency: 72% (priority mismatches found)

Status: ❌ VALIDATION FAILED

Cannot proceed to implementation with critical issues.
```

### Error Recovery Decision Point

```
┌────────────────────────────────────────────────────────┐
│ Validation Failed - Choose Recovery Path               │
└────────────────────────────────────────────────────────┘

Critical validation errors prevent safe implementation.
Proceeding without fixes risks significant rework.

Recovery Options:

[A] Auto-fix with AI assistance ⭐ Recommended
    - Claude will update plan.md to address issues
    - Re-run validation automatically
    - Fastest resolution
    - Estimated time: 3-4 minutes

[B] Guided manual fixes
    - Claude guides you through each issue
    - You manually edit files
    - More control over solutions
    - Estimated time: 8-12 minutes

[C] Skip validation and continue (NOT RECOMMENDED)
    - Implementation will likely fail or be incorrect
    - Will waste significant time
    - Only use for throwaway prototypes

[D] Abort workflow
    - Review issues independently
    - Restart workflow later

[E] Re-run planning phase with corrections
    - Start fresh with better context
    - Most thorough but time-consuming
    - Estimated time: 5-6 minutes

User selected: [A] Auto-fix with AI assistance

Proceeding with automated corrections...
```

### Automated Error Correction

```
Auto-Fix Process
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Analyzing issues...

Issue 1: Missing tier management implementation
├─ Reading spec.md US1.3 requirements
├─ Generating implementation plan
└─ Adding to plan.md Section 3.4 "Tier Management"

✓ Added tier management components:
  - TierService for upgrade/downgrade logic
  - Database migration for tier history
  - PUT /api/users/:id/tier endpoint
  - Stripe integration for billing changes

Issue 2: Priority mismatch (US2.2)
├─ Confirming US2.2 is critical (rate limit enforcement)
├─ Updating plan.md priority from P2 → P1
└─ Adjusting task estimates

✓ Updated: Section 5.2 now marked P1 (Must Have)

Issue 3: Over-engineered Redis cluster
├─ Reviewing actual requirements
├─ Confirming single Redis instance sufficient
└─ Simplifying plan.md Section 4.3

✓ Simplified: Redis cluster → single instance + persistence
✓ Removed: Unnecessary cluster configuration tasks

Issue 4: Vague admin dashboard
├─ Reading US1.4 requirements in detail
├─ Generating specific dashboard design
└─ Adding to plan.md Section 6 "Admin Dashboard"

✓ Added detailed design:
  - Dashboard UI wireframe
  - Real-time usage charts
  - Rate limit override controls
  - User tier management interface

Updating DECISIONS-LOG.md...

✓ ADR-011: Use single Redis instance (sufficient for current scale)
✓ ADR-012: Implement tier management with Stripe integration

Files updated:
  - {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan} (+127 lines)
  - {config.paths.memory}/DECISIONS-LOG.md (+2 ADRs)

Auto-fix complete (3m 18s)
```

### Re-validation After Fixes

```
Re-running Validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Checking spec.md ↔ plan.md consistency...

✓ Issue 1: RESOLVED
  US1.3 tier management now fully addressed in plan.md

✓ Issue 2: RESOLVED
  Priority alignment fixed (US2.2 now P1 in plan)

✓ Issue 3: RESOLVED
  Redis approach simplified and justified

✓ Issue 4: RESOLVED
  Admin dashboard fully specified in plan

Additional checks:
✓ All P1 stories addressed in plan
✓ All plan sections map to user stories
✓ Priorities consistent across documents
✓ Technical approach feasible
✓ Dependencies identified

Validation Summary:
  ✓ Critical Issues: 0
  ✓ High Issues: 0
  ⚠️ Minor Issues: 1 (consider adding load testing - P3)

  Coverage: 100% (all P1 stories addressed)
  Consistency: 98% (alignment achieved)

Status: ✅ VALIDATION PASSED

Safe to proceed with implementation.

[4/6] spec:analyze ████████████████████████████ Complete (7m 42s)
  (Includes 3m 18s for auto-fixes)
```

### Phases 5-6: Continue After Successful Recovery

```
[5/6] spec:tasks ████████████████████████████ Complete (4m 56s)
  - 32 tasks generated (reflects corrected plan)
  - All P1 stories properly covered

[6/6] spec:implement ████████████████████████████ Complete (16m 12s)
  - 32/32 tasks complete
  - Implementation aligned with corrected plan
  - Zero rework required (issues caught early)
```

### Error Recovery Summary

```
════════════════════════════════════════════════════════
Successful Recovery: API Rate Limiting
════════════════════════════════════════════════════════

Total Duration: 36 minutes 24 seconds
  - Generate: 38s
  - Clarify: 1m 52s
  - Plan: 5m 24s (initial)
  - Analyze: 7m 42s (with auto-fixes)
  - Tasks: 4m 56s
  - Implement: 16m 12s

Error Recovery:
  - Issues detected: 4 (2 critical, 1 high, 1 medium)
  - Auto-fix time: 3m 18s
  - Manual intervention: 0 (fully automated)
  - Re-validation: Passed ✓

Value of Validation:
  ✓ Caught issues before implementation
  ✓ Prevented estimated 4-6 hours of rework
  ✓ Ensured spec-plan alignment
  ✓ Validated technical approach
  ✓ Improved plan quality

Cost-Benefit:
  - Validation overhead: 7m 42s
  - Rework prevented: 4-6 hours
  - ROI: Massive (30x+ time savings)

Key Lesson: Never skip validation for complex features

Corrected Implementation:
  ✓ All P1 stories covered
  ✓ Tier management included
  ✓ Priority alignment correct
  ✓ Simplified Redis approach
  ✓ Admin dashboard specified

Recommendation: Always run spec:analyze for features with 20+ tasks
```

---

## Common Patterns

### Pattern 1: Speed Optimized (POC/Prototype)

```
Use Case: Quick proof of concept, speed > quality
Command: "Run orchestrate in auto mode"

Execution:
  - Mode: --auto
  - Skip: clarify (if possible), analyze
  - Parallelization: Disabled (serial execution)
  - Validation: Minimal

Result: Fastest path from idea to working code
Duration: 5-10 minutes for simple features
Quality: Suitable for POCs, not production

Example:
  "Need quick contact form POC" → 6m 52s (Example 2)
```

### Pattern 2: Production Quality (Default)

```
Use Case: Production-ready feature development
Command: "Run full workflow"

Execution:
  - Mode: Interactive (default)
  - Clarify: All ambiguities resolved
  - Validate: Full spec:analyze run
  - Parallelization: User-prompted
  - Checkpointing: After each phase

Result: High-quality, well-documented implementation
Duration: 20-40 minutes for typical features
Quality: Production-ready with full validation

Example:
  "Add authentication system" → 23m 42s (Example 1)
```

### Pattern 3: Complex Features (Extended)

```
Use Case: Large, complex features with many requirements
Command: "Orchestrate comprehensive feature"

Execution:
  - Mode: Interactive with extensive clarification
  - Clarify: Multi-round questioning (8+ questions)
  - Validate: Required (high complexity)
  - Research: Deep dive into best practices
  - Checkpointing: Frequent

Result: Well-planned, validated complex implementation
Duration: 45-90 minutes for complex features
Quality: Enterprise-grade with full documentation

Example:
  "Build reporting dashboard" → 60m 47s (Example 5)
```

### Pattern 4: Resume After Interruption

```
Use Case: Continue work after network failure, break, or other interruption
Command: "Resume the workflow"

Execution:
  - Loads last checkpoint automatically
  - Validates completed work integrity
  - Continues from interruption point
  - Skips all completed phases/tasks

Result: Seamless continuation without lost work
Duration: Zero overhead (instant resume)
Quality: Identical to uninterrupted execution

Example:
  "Resume payment feature" → 11m 42s for remaining work (Example 3)
```

### Pattern 5: Phased Delivery (Stop Early)

```
Use Case: Need approval before implementation
Command: "Generate spec and plan, then stop"

Execution:
  - Run: generate → clarify → plan
  - Stop: Before analyze/tasks/implement
  - Review: Team reviews artifacts
  - Resume: Continue when approved

Result: Specification and design ready for review
Duration: 10-20 minutes for spec+plan
Quality: Complete planning, deferred implementation

Example:
  "Plan search feature for review" → 13m 26s (Example 4)
```

---

## Tips for Effective Use

### 1. Mode Selection

**Use Auto Mode When:**
- Building throwaway prototypes
- Time-constrained POCs
- Simple, well-understood features
- Exploring ideas quickly

**Use Interactive Mode When:**
- Production features
- Complex requirements
- Team collaboration needed
- Compliance/audit requirements

### 2. Clarification Strategy

**Invest Time in Clarification:**
- 5 minutes clarifying → saves 3+ hours rework
- More [CLARIFY] tags = more important to clarify
- Don't skip clarify phase for P1 features
- Use multi-round questioning for complex features (Example 5)

**Red Flags:**
- 5+ [CLARIFY] tags = complex feature, clarify thoroughly
- Vague requirements = expect 10+ minutes clarification
- Multiple stakeholders = interactive mode required

### 3. Validation Best Practices

**Always Validate When:**
- Feature has 20+ estimated tasks
- Multiple priorities (P1, P2, P3) present
- Complex architecture decisions
- Multiple external integrations
- Team collaboration required

**Skip Validation Only For:**
- Simple features (<10 tasks)
- Throwaway prototypes
- Tight time constraints
- Low-risk experiments

### 4. Checkpoint Management

**Automatic Checkpoints:**
- Created after each phase
- Saved to {config.paths.state}/checkpoints/
- Enable instant resume
- Cost: ~200ms per checkpoint (negligible)

**Resume Strategy:**
- Always use --resume after interruption
- Never restart from scratch
- Checkpoints preserve all context
- Works across Claude sessions

### 5. Parallel Execution

**When to Parallelize:**
- 10+ tasks identified
- Independent task groups exist
- Time is critical
- System resources available

**When to Run Serial:**
- Auto mode (simpler execution)
- Learning/educational purposes
- Limited system resources
- Debugging issues

### 6. Error Handling

**Validation Failures:**
- Always fix critical issues (Example 6)
- Consider fixing high-severity issues
- Medium/low issues can be deferred
- Auto-fix is usually fastest option

**Interruption Recovery:**
- Use --resume immediately
- Don't manually restart phases
- Trust checkpoint integrity
- Review resumed state briefly

---

## Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Skipping Clarification

**Don't:**
```
User: "Build reporting feature" (vague, 8 [CLARIFY] tags)
Claude: [CLARIFY] tags present, should clarify...
User: "Skip clarify, just use defaults"
Result: 3 days rebuilding wrong implementation
```

**Do:**
```
User: "Build reporting feature"
Claude: 8 clarifications needed (7 min estimated)
User: "Okay, let's clarify"
Result: 7 minutes → correct implementation first try
```

### ❌ Anti-Pattern 2: Ignoring Validation Errors

**Don't:**
```
Validation: 2 CRITICAL errors found
User: "Skip validation, continue anyway"
Result: Implementation fails, major rework needed
```

**Do:**
```
Validation: 2 CRITICAL errors found
User: "Auto-fix these issues"
Result: 3 minutes fixing → successful implementation
```

### ❌ Anti-Pattern 3: Restarting Instead of Resuming

**Don't:**
```
[Interruption at task 15/30]
User: "Start over from beginning"
Result: Waste 10+ minutes re-doing completed work
```

**Do:**
```
[Interruption at task 15/30]
User: "Resume workflow"
Result: Continue from task 15, zero wasted time
```

### ❌ Anti-Pattern 4: Using Auto Mode for Complex Features

**Don't:**
```
User: "Build enterprise reporting system" (58 tasks)
User: "Use auto mode, skip everything"
Result: Wrong architecture, missed requirements
```

**Do:**
```
User: "Build enterprise reporting system"
Claude: Complex feature detected, recommend interactive mode
User: "Yes, use interactive with full clarification"
Result: Well-planned, validated implementation
```

### ❌ Anti-Pattern 5: No Checkpointing

**Don't:**
```
[Configure to disable checkpoints]
[Network failure at 80% complete]
Result: Lost all progress, start over
```

**Do:**
```
[Use default checkpoint settings]
[Network failure at 80% complete]
Result: Resume from 80%, 2 minutes remaining
```

---

## Troubleshooting

### Issue: Orchestration Won't Start

**Symptoms:**
```
Error: Cannot start orchestration
Reason: Spec not initialized
```

**Solution:**
```
Run: /spec init
Then: /spec orchestrate [feature]
```

### Issue: Checkpoint Not Found

**Symptoms:**
```
Resume failed: No checkpoint found
```

**Solution:**
```
Check: {config.paths.state}/checkpoints/ directory exists
Fallback: Run individual phases manually
```

### Issue: Validation Always Failing

**Symptoms:**
```
Validation: Same errors persist after fixes
```

**Solution:**
```
1. Read validation error details carefully
2. Manually review spec.md and plan.md
3. Use auto-fix option
4. If persistent, report as bug
```

### Issue: Auto Mode Too Fast/Sloppy

**Symptoms:**
```
Auto mode output lacks quality
Missing important details
```

**Solution:**
```
Switch to interactive mode:
"Run orchestrate in interactive mode"
```

---

**For More Information:**
- **SKILL.md**: Complete skill documentation
- **REFERENCE.md**: Technical algorithms and configuration
- **shared/workflow-patterns.md**: Orchestration patterns library
- **shared/state-management.md**: Checkpoint and resume internals

---

**Quick Reference:**

```
Modes:
  - Interactive (default): Full control, all prompts
  - Auto (--auto): Minimal prompts, fast execution
  - Resume (--resume): Continue from checkpoint

Phases:
  1. generate: Create spec.md
  2. clarify: Resolve ambiguities
  3. plan: Create plan.md
  4. analyze: Validate consistency
  5. tasks: Generate tasks.md
  6. implement: Execute implementation

Commands:
  Start: "Run orchestrate for [feature]"
  Auto: "Run orchestrate in auto mode"
  Resume: "Resume workflow"
  Stop: "Stop after planning phase"
```
