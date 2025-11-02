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
[1/6] Running generate phase

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
[2/6] Running clarify phase

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
[3/6] Running plan phase

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
[4/6] Running analyze phase

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
[5/6] Running tasks phase

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
[6/6] Running implement phase

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
  ✓ generate phase (spec.md created)
  ✓ clarify phase (3 clarifications resolved)
  ✓ plan phase (plan.md created, 3 ADRs logged)
  ✓ analyze phase (validation passed, 2 warnings)
  ✓ tasks phase (28 tasks generated)
  ✓ implement phase (28/28 tasks complete)

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

**Note**: Examples 2-5 trimmed for token efficiency. See guide.md for core concepts.

---

## Example 6: Error Recovery with Validation Failures

**Context**: Building an API rate limiting feature. Validation discovers critical inconsistencies between specification and technical plan that must be corrected before implementation.

**User Request**:
"Implement API rate limiting with tiered plans"

**Execution**:

### Phases 1-3: Normal Flow

```
[1/6] generate phase ████████████████████████████ Complete (38s)
[2/6] clarify phase ████████████████████████████ Complete (1m 52s)
[3/6] plan phase ████████████████████████████ Complete (5m 24s)
```

### Phase 4: Validation Reveals Critical Issues

```
[4/6] analyze phase ████████████████████████████ Starting...

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

[4/6] analyze phase ████████████████████████████ Complete (7m 42s)
  (Includes 3m 18s for auto-fixes)
```

### Phases 5-6: Continue After Successful Recovery

```
[5/6] tasks phase ████████████████████████████ Complete (4m 56s)
  - 32 tasks generated (reflects corrected plan)
  - All P1 stories properly covered

[6/6] implement phase ████████████████████████████ Complete (16m 12s)
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

Recommendation: Always run analyze phase for features with 20+ tasks
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
  - Validate: Full analyze phase run
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
