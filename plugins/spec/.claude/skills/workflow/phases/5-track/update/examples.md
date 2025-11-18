# Specification Update Examples

Concrete scenarios showing different types of specification updates.

## Example 1: Requirement Change (Priority Shift)

**User Request**: "Make the password reset feature P1 instead of P2"

**Context**:
- Feature: 001-user-authentication
- Current phase: Planning
- Affected: User Story 1.4

**Execution**:

```bash
# 1. Read current spec
Read {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}
→ Find: "US1.4: User can reset forgotten password [P2]"

# 2. Update priority
Edit spec.md:
  Old: "US1.4: User can reset forgotten password [P2]"
  New: "US1.4: User can reset forgotten password [P1]"

# 3. Check downstream impact
Read {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.tasks}
→ Find tasks T015-T018 related to password reset
→ Update task priorities from P2 to P1

# 4. Log decision
Append to {config.paths.memory}/decisions-log.md:
---
## ADR-012: Elevate Password Reset to P1

**Date**: 2025-10-31
**Status**: Accepted
**Context**: Feature 001 - User Authentication

### Decision
Changed password reset from P2 to P1 based on user feedback showing
high abandonment rate for forgotten passwords.

### Consequences
- Must complete before launch
- Adds 8 hours to critical path
- Requires email service integration sooner
---

# 5. Update session
Edit {config.paths.state}/current-session.md:
→ Note: "Updated US1.4 priority P2→P1"
→ Adjust task queue order
```

**Output**:
```
✓ Updated spec.md: US1.4 priority changed P2 → P1
✓ Adjusted tasks.md: 4 tasks reprioritized to P1
✓ Logged decision: ADR-012
→ Next: Review updated task order in tasks.md
```

---

## Example 2: Add MCP Integration (JIRA)

**User Request**: "Sync this feature with JIRA"

**Context**:
- Feature: 002-product-search
- JIRA configured: SPEC_JIRA_PROJECT_KEY=SHOP
- MCP available: jira_create_issue tool

**Execution**:

```bash
# 1. Read spec for metadata
Read {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}
→ Extract: title, user stories, priority

# 2. Create JIRA issue via MCP
Call jira_create_issue:
  project_key: "SHOP"
  issue_type: "Story"
  summary: "Product Search with Elasticsearch"
  description: |
    ## User Stories
    - US2.1: User can search products by name [P1]
    - US2.2: User can filter search results [P2]
    - US2.3: User sees autocomplete suggestions [P2]

    ## Acceptance Criteria
    [... from spec.md ...]
  priority: "High"  # P1 maps to High

→ Returns: issue_key="SHOP-42"

# 3. Update spec with JIRA metadata
Edit {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}:
  Add to frontmatter:
  ---
  jira_issue: SHOP-42
  jira_url: https://company.atlassian.net/browse/SHOP-42
  synced_at: 2025-10-31T15:30:00Z
  ---

# 4. Log integration
Append to {config.paths.memory}/workflow-progress.md:
  Feature 002: Product Search
  - JIRA: SHOP-42 (created)

# 5. Update session
Edit {config.paths.state}/current-session.md:
  MCP Integrations: jira (enabled)
```

**Output**:
```
✓ Created JIRA issue: SHOP-42
✓ Updated spec.md with JIRA metadata
✓ Logged in workflow-progress.md
→ View issue: https://company.atlassian.net/browse/SHOP-42
→ Next: JIRA will auto-sync on future updates
```

---

## Example 3: Add New User Story (Scope Expansion)

**User Request**: "Add OAuth login to the authentication feature"

**Context**:
- Feature: 001-user-authentication
- Current stories: US1.1 - US1.4 (4 stories)
- Current phase: Implementation (50% complete)

**Execution**:

```bash
# 1. Read current spec
Read {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}
→ Current user stories: 4 total
→ Current tasks: 23 total

# 2. Add new user story
Edit spec.md, append to User Stories section:
---
#### US1.5: User can log in with OAuth providers [P2]

**As a** user
**I want to** log in using Google, GitHub, or Microsoft accounts
**So that** I don't need to create another password

**Acceptance Criteria**:
- [ ] User sees "Sign in with Google" button
- [ ] User sees "Sign in with GitHub" button
- [ ] OAuth flow completes successfully
- [ ] User profile populated from OAuth provider
- [ ] User can link multiple OAuth accounts

**Priority**: P2 (Should Have)
**Estimate**: 8 story points
---

# 3. Check if plan needs update
Read {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan}
→ Current: JWT-based authentication only
→ Needs: OAuth integration section

# 4. Update plan.md
Edit plan.md, add section:
---
### OAuth Integration

**Libraries**:
- passport (authentication middleware)
- passport-google-oauth20
- passport-github2
- passport-microsoft

**Flow**:
1. User clicks OAuth button
2. Redirect to provider authorization
3. Provider redirects back with auth code
4. Exchange code for access token
5. Fetch user profile
6. Create/update user in database
7. Issue JWT for session

**Security**:
- Verify state parameter (CSRF protection)
- Validate redirect URI
- Store minimal profile data
---

# 5. Add tasks to tasks.md
Edit tasks.md, add new tasks:
---
**T024**: Install and configure Passport.js [P]
- Priority: P2
- Estimate: 2 hours
- Files: package.json, src/config/passport.ts

**T025**: Implement Google OAuth strategy
- Priority: P2
- Estimate: 3 hours
- Dependencies: T024
- Files: src/auth/strategies/google.ts

**T026**: Implement GitHub OAuth strategy
- Priority: P2
- Estimate: 3 hours
- Dependencies: T024
- Files: src/auth/strategies/github.ts

**T027**: Create OAuth callback route
- Priority: P2
- Estimate: 2 hours
- Dependencies: T025, T026
- Files: src/api/routes/auth.ts

**T028**: Add OAuth buttons to login UI
- Priority: P2
- Estimate: 2 hours
- Dependencies: T027
- Files: src/components/LoginForm.tsx

**T029**: Write OAuth integration tests
- Priority: P2
- Estimate: 3 hours
- Dependencies: T025, T026, T027
- Files: tests/auth/oauth.test.ts
---

# 6. Update state files
Append to {config.paths.memory}/changes-planned.md:
  Feature 001: User Authentication
  - Added: T024-T029 (6 new tasks for OAuth)

Edit {config.paths.memory}/decisions-log.md:
---
## ADR-013: Add OAuth Authentication

**Date**: 2025-10-31
**Status**: Accepted
**Context**: Feature 001 - User Authentication expansion

### Decision
Add OAuth support for Google, GitHub, and Microsoft alongside
existing email/password authentication.

### Rationale
- User research shows 67% prefer OAuth over passwords
- Reduces password management burden
- Industry standard for modern apps
- Increases signup conversion rate

### Consequences
**Positive**:
- Better user experience
- Reduced support burden (password resets)
- Higher signup conversion

**Negative**:
- Adds complexity to auth system
- Requires OAuth app setup for each provider
- Additional security considerations

**Alternatives Considered**:
- Email-only auth (rejected - poor UX)
- Single OAuth provider (rejected - limits user choice)
---

# 7. Update session
Edit {config.paths.state}/current-session.md:
  → Add note: "Added US1.5 - OAuth support"
  → Task count: 23 → 29 tasks
  → Update queue with new tasks
```

**Output**:
```
✓ Added user story: US1.5 (OAuth authentication)
✓ Updated plan.md: Added OAuth integration section
✓ Added tasks.md: 6 new tasks (T024-T029)
✓ Updated changes-planned.md: 6 tasks added
✓ Logged decision: ADR-013

Impact Assessment:
- Effort Required: 15 hours
- Risk Level: Low (additive change)
- Dependencies: Passport.js library

→ Next: Run implement phase to continue with existing tasks
→ Note: OAuth tasks queued for after current work
```

---

## Example 4: Incorporate Clarification Resolution

**User Request**: "Resolve the [CLARIFY] tags in the spec"

**Context**:
- Feature: 003-payment-processing
- Spec has 3 [CLARIFY] tags from clarify phase
- Decisions made: escrow needed, Stripe chosen, PCI compliance required

**Execution**:

```bash
# 1. Read spec with clarifications
Read {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}
→ Find [CLARIFY] tags with questions and decisions

# 2. Replace each [CLARIFY] with resolution
Edit spec.md:

Old:
---
[CLARIFY: Should we support escrow for marketplace transactions?
DECISION: Yes - add escrow for P2P sales to protect buyers/sellers
IMPACT: Adds escrow service integration, ~16 hours]
---

New:
---
**Escrow Support**: System will hold payment in escrow for P2P
marketplace transactions, releasing funds only after buyer confirms
receipt. Protects both buyers and sellers in peer-to-peer sales.
---

Old:
---
[CLARIFY: Which payment provider: Stripe, PayPal, or Braintree?
DECISION: Stripe - best API, lowest fees, team has experience
IMPACT: Use Stripe API, no impact on timeline]
---

New:
---
**Payment Provider**: Stripe for payment processing. Provides best
developer experience, competitive fees (2.9% + $0.30), and team
has existing expertise.
---

Old:
---
[CLARIFY: PCI compliance required? Should we handle card data directly?
DECISION: No direct card handling - use Stripe Elements for PCI compliance
IMPACT: Use Stripe Elements, reduces compliance burden]
---

New:
---
**PCI Compliance**: Stripe Elements handles all card data, keeping
application PCI-DSS compliant without direct card storage or transmission.
---

# 3. Update plan.md with clarification decisions
Edit {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan}:
  Add technical details for:
  - Escrow service architecture
  - Stripe integration specifics
  - Stripe Elements implementation

# 4. Update tasks.md with new requirements
Edit {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.tasks}:
  Add tasks for:
  - T015: Implement escrow service (new)
  - T016: Integrate Stripe Elements (updated from generic)
  - T017: Build escrow release workflow (new)

# 5. Log clarification resolutions
Append to {config.paths.memory}/decisions-log.md:
---
## ADR-014: Payment Processing Architecture

**Date**: 2025-10-31
**Status**: Accepted
**Context**: Feature 003 - Resolved spec clarifications

### Decisions Made

**1. Escrow Support**: YES
- Required for P2P marketplace transactions
- Protects buyers and sellers
- Industry standard for marketplaces

**2. Payment Provider**: Stripe
- Best API quality and documentation
- Competitive pricing (2.9% + $0.30)
- Team expertise available

**3. PCI Compliance Strategy**: Stripe Elements
- No direct card data handling
- Reduces compliance scope
- Maintains security standards

### Consequences
- Escrow adds 16 hours development
- Stripe integration well-documented
- PCI compliance simplified
---

# 6. Update workflow progress
Edit {config.paths.memory}/workflow-progress.md:
  Feature 003: Payment Processing
  - Status: Clarifications resolved, ready for planning
  - Added: Escrow requirement
```

**Output**:
```
✓ Resolved 3 [CLARIFY] tags in spec.md
✓ Updated plan.md with technical decisions
✓ Added tasks.md: 2 new tasks for escrow
✓ Logged decisions: ADR-014

Clarifications Resolved:
1. Escrow support: YES (marketplace protection)
2. Payment provider: Stripe (best API, team experience)
3. PCI compliance: Stripe Elements (no direct card handling)

Impact:
- Added 16 hours for escrow implementation
- No timeline impact for Stripe (planned already)
- Reduced PCI compliance burden

→ Next: Run plan phase to complete technical design
```

---

## Example 5: Remove Deprecated Functionality

**User Request**: "Remove session-based auth, we're going JWT-only"

**Context**:
- Feature: 001-user-authentication
- Current phase: Implementation (30% complete)
- Tasks T005-T008 implement session-based auth (not yet started)
- Tasks T001-T004 implement JWT (already complete)

**Execution**:

```bash
# 1. Read current spec and tasks
Read {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}
→ Find: US1.6 "User session persists across browser restarts" [P2]

Read {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.tasks}
→ Find: T005-T008 (session storage, session middleware, etc.)

# 2. Mark user story as deprecated
Edit spec.md:
---
#### ~~US1.6: User session persists across browser restarts~~ [DEPRECATED]

**Reason**: Moving to stateless JWT-only authentication. Session
persistence handled by client-side token storage instead.

**Deprecated**: 2025-10-31
**Replaced by**: JWT refresh tokens (US1.2)
---

# 3. Remove/update plan.md
Edit plan.md:
  Remove section: "Session Storage with Redis"
  Update section: "Authentication Flow" to JWT-only
  Add note about JWT refresh tokens

# 4. Handle affected tasks
Edit tasks.md:
  Mark as obsolete:
  - ~~T005: Set up Redis for session storage~~ [OBSOLETE]
  - ~~T006: Implement session middleware~~ [OBSOLETE]
  - ~~T007: Add session persistence logic~~ [OBSOLETE]
  - ~~T008: Write session tests~~ [OBSOLETE]

# 5. Update state files
Move from {config.paths.memory}/changes-planned.md to changes-completed.md:
---
## Obsolete Tasks (Feature 001)

**T005**: Set up Redis for session storage ❌
- Status: obsolete
- Reason: Architecture change to JWT-only
- Date: 2025-10-31
- Effort saved: 4 hours

**T006**: Implement session middleware ❌
- Status: obsolete
- Reason: Architecture change to JWT-only
- Date: 2025-10-31
- Effort saved: 3 hours

**T007**: Add session persistence logic ❌
- Status: obsolete
- Reason: Architecture change to JWT-only
- Date: 2025-10-31
- Effort saved: 2 hours

**T008**: Write session tests ❌
- Status: obsolete
- Reason: Architecture change to JWT-only
- Date: 2025-10-31
- Effort saved: 2 hours

**Total effort saved**: 11 hours
---

# 6. Log architecture decision
Append to {config.paths.memory}/decisions-log.md:
---
## ADR-015: Remove Session-Based Authentication

**Date**: 2025-10-31
**Status**: Accepted
**Context**: Feature 001 - Architecture simplification

### Decision
Remove planned session-based authentication. Use JWT-only with
refresh tokens for persistence.

### Rationale
- Simpler architecture (no Redis dependency)
- Better scalability (stateless)
- Consistent with microservices pattern
- Reduces operational complexity

### Consequences
**Positive**:
- Saved 11 hours development time
- No Redis infrastructure needed
- Easier horizontal scaling
- Reduced operational overhead

**Negative**:
- Token revocation more complex (already mitigated)
- Slightly larger cookies (acceptable)

**Migration**:
- No migration needed (not yet implemented)
- Removed T005-T008 from task queue
- Enhanced JWT refresh token logic instead
---

# 7. Update session
Edit {config.paths.state}/current-session.md:
  Tasks: 23 → 19 tasks (4 obsolete)
  Progress: 4/23 (17%) → 4/19 (21%)
  Note: "Removed session-based auth, JWT-only"
```

**Output**:
```
✓ Deprecated user story: US1.6 (session-based auth)
✓ Updated plan.md: Removed Redis session section
✓ Obsoleted tasks: T005-T008 (4 tasks)
✓ Moved to changes-completed.md with obsolete status
✓ Logged decision: ADR-015

Impact Assessment:
- Tasks removed: 4 tasks
- Effort saved: 11 hours
- Risk level: None (not yet implemented)
- Dependencies removed: Redis infrastructure

Progress Update:
- Before: 4/23 tasks complete (17%)
- After: 4/19 tasks complete (21%)

→ Next: Continue with implement phase on remaining tasks
→ Note: No migration needed, removed from queue
```

---

## Common Patterns Summary

### Update Types

1. **Priority Shift**: Change P1 ↔ P2 ↔ P3, update task order
2. **MCP Integration**: Add JIRA/Confluence/Linear sync, store metadata
3. **Scope Addition**: Add user stories, update plan/tasks, log decision
4. **Clarification Resolution**: Replace [CLARIFY] tags, update downstream
5. **Scope Reduction**: Deprecate stories, obsolete tasks, save effort

### State Updates Required

All updates must:
- Edit spec.md with changes
- Check plan.md and tasks.md for impact
- Log decision in decisions-log.md
- Update workflow-progress.md
- Update current-session.md
- Move tasks between changes-planned.md and changes-completed.md

### When to Use Each Pattern

- **Priority shift**: User feedback, business priority change
- **MCP integration**: Team uses external tools, wants sync
- **Scope addition**: New requirements discovered during dev
- **Clarification resolution**: After clarify phase completes
- **Scope reduction**: Feature cut, architecture simplification
