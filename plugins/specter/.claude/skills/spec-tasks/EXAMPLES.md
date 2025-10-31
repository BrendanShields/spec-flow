# Task Breakdown Examples

Concrete scenarios showing how spec:tasks transforms plans into executable tasks.

## Example 1: Frontend Feature (React Component)

### Input Context

**spec.md (abbreviated)**:
```markdown
## User Stories

### US1.1: User can search products (P1)
User enters search query and sees relevant results with highlighting.

### US1.2: User can filter results (P2)
User applies category, price, and rating filters to narrow results.
```

**plan.md (abbreviated)**:
```markdown
## Technical Approach

1. Create SearchBar component with Tanstack Query
2. Build SearchResults component with virtualized list
3. Add FilterPanel with multi-select
4. Integrate with Elasticsearch backend API
5. Implement debounced search input
```

### Generated tasks.md

```markdown
# Tasks: Product Search Feature

**Feature**: 002-product-search
**Created**: 2025-10-31 14:30
**Total Tasks**: 9
**Estimated Time**: 24 hours

## Summary

- **P1 Tasks**: 5 (14 hours) - Must complete
- **P2 Tasks**: 4 (10 hours) - Should complete
- **P3 Tasks**: 0 (0 hours) - Nice to have
- **Parallel Groups**: 2 groups (save ~6 hours)
- **Critical Path**: T001 → T003 → T005 → T007 (12 hours)

## User Story US1.1: User can search products

### Task T001: Create SearchBar component with input handling [P]
- Priority: P1
- Estimate: 2 hours
- Dependencies: None
- Parallel: [P]
- Files: src/components/SearchBar.tsx, src/components/SearchBar.test.tsx
- User Story: US1.1

**Description**:
Implement SearchBar component with controlled input, debounced onChange (300ms), and search icon. Use shadcn/ui Input component for consistency.

**Acceptance Criteria**:
- [ ] Component renders with placeholder text
- [ ] Input value debounced at 300ms
- [ ] Fires onSearch callback with query string
- [ ] Unit tests cover debounce behavior
- [ ] Accessible (ARIA labels present)

### Task T002: Set up Tanstack Query for search API [P]
- Priority: P1
- Estimate: 2 hours
- Dependencies: None
- Parallel: [P]
- Files: src/api/queries/search.ts, src/api/client.ts
- User Story: US1.1

**Description**:
Create useSearchQuery hook using Tanstack Query. Configure query key factory, stale time, and error handling. Mock Elasticsearch response structure.

**Acceptance Criteria**:
- [ ] useSearchQuery hook created
- [ ] Query key includes search term
- [ ] Handles loading/error states
- [ ] Stale time set to 5 minutes
- [ ] Returns typed response

### Task T003: Integrate SearchBar with query hook
- Priority: P1
- Estimate: 1 hour
- Dependencies: T001, T002
- Files: src/components/SearchBar.tsx
- User Story: US1.1

**Description**:
Connect SearchBar onSearch handler to useSearchQuery. Display loading spinner during fetch. Handle empty states.

**Acceptance Criteria**:
- [ ] Search triggers query refetch
- [ ] Loading indicator shows during fetch
- [ ] Error toast on API failure
- [ ] Integration test covers flow

### Task T004: Build SearchResults virtualized list component [P]
- Priority: P1
- Estimate: 3 hours
- Dependencies: T002
- Parallel: [P]
- Files: src/components/SearchResults.tsx, src/components/SearchResults.test.tsx
- User Story: US1.1

**Description**:
Create SearchResults component using react-virtual for list virtualization. Display product cards with image, title, price. Handle empty results state.

**Acceptance Criteria**:
- [ ] Virtualized list renders 1000+ items smoothly
- [ ] Product card shows image, title, price
- [ ] Empty state message for no results
- [ ] Click handler navigates to product detail
- [ ] Tests verify virtualization

### Task T005: Add search term highlighting to results
- Priority: P1
- Estimate: 2 hours
- Dependencies: T004
- Files: src/components/SearchResults.tsx, src/utils/highlight.ts
- User Story: US1.1

**Description**:
Implement highlight utility that wraps search terms in <mark> tags. Apply to product titles and descriptions in SearchResults.

**Acceptance Criteria**:
- [ ] Search terms highlighted in yellow
- [ ] Case-insensitive matching
- [ ] Multiple term support
- [ ] Sanitizes HTML to prevent XSS
- [ ] Unit tests for edge cases

## User Story US1.2: User can filter results

### Task T006: Create FilterPanel multi-select component [P]
- Priority: P2
- Estimate: 3 hours
- Dependencies: None
- Parallel: [P]
- Files: src/components/FilterPanel.tsx, src/components/FilterPanel.test.tsx
- User Story: US1.2

**Description**:
Build FilterPanel with category checkboxes, price range slider, and star rating selector. Use shadcn/ui Checkbox and Slider components.

**Acceptance Criteria**:
- [ ] Category multi-select checkboxes
- [ ] Price range slider (min-max)
- [ ] Star rating clickable 1-5
- [ ] Clear filters button
- [ ] Fires onChange with filter object
- [ ] Accessible keyboard navigation

### Task T007: Integrate filters with search query
- Priority: P2
- Estimate: 2 hours
- Dependencies: T006, T005
- Files: src/api/queries/search.ts, src/components/SearchPage.tsx
- User Story: US1.2

**Description**:
Extend useSearchQuery to accept filters parameter. Serialize filters to Elasticsearch query DSL. Update query key to include filters.

**Acceptance Criteria**:
- [ ] Filters added to query key
- [ ] API request includes filter params
- [ ] Query refetches on filter change
- [ ] URL params sync with filters
- [ ] Tests verify filter serialization

### Task T008: Add filter result count badges
- Priority: P2
- Estimate: 1 hour
- Dependencies: T007
- Files: src/components/FilterPanel.tsx
- User Story: US1.2

**Description**:
Show count of results for each filter option (e.g., "Electronics (23)"). Use Elasticsearch aggregations to get counts.

**Acceptance Criteria**:
- [ ] Count badge next to each filter option
- [ ] Updates when search query changes
- [ ] Disables options with 0 results
- [ ] Loading skeleton while fetching counts

### Task T009: Add URL query param persistence for filters
- Priority: P2
- Estimate: 2 hours
- Dependencies: T007
- Files: src/hooks/useSearchParams.ts, src/components/SearchPage.tsx
- User Story: US1.2

**Description**:
Sync search query and filters with URL query params. Enable shareable search URLs. Handle browser back/forward navigation.

**Acceptance Criteria**:
- [ ] URL updates on search/filter change
- [ ] Back/forward buttons work correctly
- [ ] URL can be shared and reproduces search
- [ ] Invalid params handled gracefully
- [ ] Tests cover URL sync

## Dependency Graph

```
US1.1: T001 [P] ──┬→ T003 → T005 → T007
       T002 [P] ──┴───────┴→ T004 ─┘

US1.2: T006 [P] ────────────────→ T007 → T008
                                       └→ T009
```

## Parallel Work Opportunities

**Group 1** (start immediately - 6 hours):
- T001: SearchBar component [P]
- T002: Tanstack Query setup [P]
- T006: FilterPanel component [P]

**Group 2** (after T002 complete - 3 hours):
- T003: Integrate SearchBar (needs T001, T002)
- T004: SearchResults component (needs T002) [P]

**Group 3** (after T004 complete - 2 hours):
- T005: Search highlighting (needs T004)

**Group 4** (after T005 complete - 5 hours):
- T007: Filter integration (needs T005, T006)
- T008: Filter counts (needs T007)
- T009: URL persistence (needs T007)

**Time Savings**: Sequential = 20h, Parallel = ~14h (30% savings)

## Next Steps

1. Review task breakdown for completeness
2. Run `spec:implement` to start execution
3. Begin with Group 1 parallel tasks
4. Track progress in .specter-state/current-session.md
```

---

## Example 2: Backend API Feature (Node.js/Express)

### Input Context

**spec.md (abbreviated)**:
```markdown
## User Stories

### US2.1: API accepts payment requests (P1)
POST /api/payments with card details, returns transaction ID.

### US2.2: API handles webhooks from Stripe (P1)
Receives webhook events, updates payment status in database.
```

**plan.md (abbreviated)**:
```markdown
## Technical Approach

1. Install Stripe SDK and configure API keys
2. Create payment schema in Postgres
3. Implement POST /api/payments endpoint
4. Add Stripe payment intent creation
5. Implement webhook handler with signature verification
6. Add payment status update logic
```

### Generated tasks.md (abbreviated)

```markdown
# Tasks: Payment Processing API

**Feature**: 003-payment-api
**Created**: 2025-10-31 15:00
**Total Tasks**: 12
**Estimated Time**: 28 hours

## Summary

- **P1 Tasks**: 10 (24 hours)
- **P2 Tasks**: 2 (4 hours)
- **Parallel Groups**: 3 groups
- **Critical Path**: T001 → T003 → T005 → T007 → T009 (16 hours)

## User Story US2.1: API accepts payment requests

### Task T001: Install and configure Stripe SDK [P]
- Priority: P1
- Estimate: 1 hour
- Dependencies: None
- Parallel: [P]
- Files: package.json, src/config/stripe.ts, .env.example
- User Story: US2.1

**Description**:
Install stripe npm package. Create Stripe client with API keys from env vars. Add test/prod key configuration.

**Acceptance Criteria**:
- [ ] stripe@latest installed
- [ ] Config loads STRIPE_SECRET_KEY
- [ ] Separate test mode keys
- [ ] Client initialization tested

### Task T002: Create payments table schema [P]
- Priority: P1
- Estimate: 2 hours
- Dependencies: None
- Parallel: [P]
- Files: migrations/003-create-payments.sql, src/models/payment.ts
- User Story: US2.1

**Description**:
Create payments table with columns: id, user_id, amount, currency, status, stripe_payment_intent_id, created_at, updated_at. Add indexes.

**Acceptance Criteria**:
- [ ] Migration creates payments table
- [ ] Indexes on user_id and stripe_payment_intent_id
- [ ] Status enum (pending, succeeded, failed, refunded)
- [ ] TypeScript model with Prisma/Drizzle

### Task T003: Create payment validation schema
- Priority: P1
- Estimate: 1 hour
- Dependencies: None
- Files: src/validators/payment.ts
- User Story: US2.1

**Description**:
Use Zod to create payment request validation schema. Validate amount (positive, max limit), currency (supported codes), card details format.

**Acceptance Criteria**:
- [ ] Zod schema validates amount, currency
- [ ] Amount must be positive and under $10,000
- [ ] Currency limited to USD, EUR, GBP
- [ ] Tests cover edge cases

### Task T004: Implement POST /api/payments endpoint
- Priority: P1
- Estimate: 3 hours
- Dependencies: T002, T003
- Files: src/routes/payments.ts, src/controllers/payment.controller.ts
- User Story: US2.1

**Description**:
Create Express route handler. Validate request body. Call payment service. Return transaction ID. Handle errors with proper status codes.

**Acceptance Criteria**:
- [ ] POST /api/payments route registered
- [ ] Request body validated with T003 schema
- [ ] Returns 201 with transaction ID
- [ ] Returns 400 for invalid input
- [ ] Returns 500 for server errors
- [ ] Integration tests cover happy + error paths

### Task T005: Implement Stripe payment intent creation
- Priority: P1
- Estimate: 3 hours
- Dependencies: T001, T004
- Files: src/services/payment.service.ts
- User Story: US2.1

**Description**:
Create service method that calls stripe.paymentIntents.create(). Save payment record to database with pending status. Handle Stripe API errors.

**Acceptance Criteria**:
- [ ] Creates Stripe payment intent
- [ ] Saves record to payments table
- [ ] Returns client_secret for frontend
- [ ] Handles Stripe errors (card declined, etc.)
- [ ] Idempotency with Stripe idempotency keys
- [ ] Unit tests with Stripe mock

### Task T006: Add payment status query endpoint [P]
- Priority: P2
- Estimate: 2 hours
- Dependencies: T002
- Files: src/routes/payments.ts, src/controllers/payment.controller.ts
- User Story: US2.1

**Description**:
Create GET /api/payments/:id endpoint. Return payment status and details. Ensure user can only query their own payments.

**Acceptance Criteria**:
- [ ] GET /api/payments/:id route
- [ ] Returns payment details
- [ ] Authorization check (user owns payment)
- [ ] Returns 404 if not found
- [ ] Tests verify authz

## User Story US2.2: API handles webhooks from Stripe

### Task T007: Create webhook signature verification utility [P]
- Priority: P1
- Estimate: 2 hours
- Dependencies: T001
- Files: src/middleware/verify-stripe-webhook.ts
- User Story: US2.2

**Description**:
Implement Express middleware to verify Stripe webhook signatures using stripe.webhooks.constructEvent(). Reject invalid signatures with 400.

**Acceptance Criteria**:
- [ ] Middleware verifies signature
- [ ] Uses STRIPE_WEBHOOK_SECRET from env
- [ ] Attaches verified event to req
- [ ] Returns 400 for invalid signature
- [ ] Tests with Stripe test events

### Task T008: Implement POST /api/webhooks/stripe endpoint
- Priority: P1
- Estimate: 2 hours
- Dependencies: T007
- Files: src/routes/webhooks.ts, src/controllers/webhook.controller.ts
- User Story: US2.2

**Description**:
Create webhook endpoint. Apply signature verification middleware. Route events to handlers. Return 200 to acknowledge receipt.

**Acceptance Criteria**:
- [ ] POST /api/webhooks/stripe route
- [ ] Uses T007 verification middleware
- [ ] Routes event to correct handler
- [ ] Returns 200 immediately
- [ ] Logs all webhook events

### Task T009: Add payment status update handlers
- Priority: P1
- Estimate: 3 hours
- Dependencies: T008
- Files: src/services/webhook-handlers.ts
- User Story: US2.2

**Description**:
Implement handlers for payment_intent.succeeded and payment_intent.failed events. Update payment status in database. Send notification to user.

**Acceptance Criteria**:
- [ ] Handler for payment_intent.succeeded
- [ ] Handler for payment_intent.failed
- [ ] Updates payment status in DB
- [ ] Idempotent (handles duplicate webhooks)
- [ ] Sends email notification
- [ ] Tests verify idempotency

### Task T010: Add webhook event logging
- Priority: P1
- Estimate: 2 hours
- Dependencies: T008
- Files: src/models/webhook-event.ts, migrations/004-webhook-events.sql
- User Story: US2.2

**Description**:
Create webhook_events table to log all received webhooks. Store event ID, type, payload, processing status. Enable audit trail.

**Acceptance Criteria**:
- [ ] webhook_events table created
- [ ] Logs event before processing
- [ ] Updates status after processing
- [ ] Helps debug webhook issues
- [ ] Retention policy (30 days)

[Additional tasks T011-T012 for error handling and monitoring...]

## Dependency Graph

```
US2.1: T001 [P] ──┬→ T005 ─────→ T007 → T008 → T009
       T002 [P] ──┼─→ T004 ───┘       └─→ T010
       T003 [P] ──┴───┘
       T006 [P] (parallel anytime after T002)
```

## Parallel Work Opportunities

**Group 1** (start immediately - 4 hours):
- T001: Stripe SDK setup [P]
- T002: Database schema [P]
- T003: Validation schema [P]

**Group 2** (after Group 1 - 3 hours):
- T004: POST endpoint (needs T002, T003)
- T007: Webhook verification (needs T001) [P]

**Group 3** (after T004, T007 - 5 hours):
- T005: Payment intent creation (needs T001, T004)
- T008: Webhook endpoint (needs T007)

**Group 4** (anytime after T002):
- T006: Status query endpoint [P]

**Time Savings**: Sequential = 28h, Parallel = ~19h (32% savings)
```

---

## Example 3: Full-Stack Feature (Auth System)

### Input Context

**spec.md**: User authentication with email/password, OAuth, and session management.

**plan.md**: JWT-based auth, refresh tokens, OAuth integration with Google/GitHub.

### Generated tasks.md (abbreviated)

```markdown
# Tasks: User Authentication System

**Feature**: 001-user-auth
**Created**: 2025-10-31 16:00
**Total Tasks**: 23
**Estimated Time**: 52 hours

## Summary

- **P1 Tasks**: 16 (38 hours) - Must complete
- **P2 Tasks**: 5 (10 hours) - Should complete
- **P3 Tasks**: 2 (4 hours) - Nice to have
- **Parallel Groups**: 4 groups
- **Critical Path**: T001 → T004 → T008 → T012 → T016 (24 hours)

## User Story US1.1: User can register with email/password

### Task T001: Create users table schema [P]
- Priority: P1
- Estimate: 2 hours
- Dependencies: None
- Parallel: [P]
- Files: migrations/001-users.sql, src/models/user.ts

[Database schema setup...]

### Task T002: Implement password hashing utility [P]
- Priority: P1
- Estimate: 2 hours
- Dependencies: None
- Parallel: [P]
- Files: src/utils/crypto.ts

[bcrypt integration...]

### Task T003: Create registration form component [P]
- Priority: P1
- Estimate: 3 hours
- Dependencies: None
- Parallel: [P]
- Files: src/components/RegisterForm.tsx

[React form with validation...]

[Tasks T004-T023 covering full auth flow...]

## Dependency Graph

```
Backend Track:
T001 [P] ──→ T004 → T008 → T012 → T016
T002 [P] ────┘      └──────┘

Frontend Track:
T003 [P] ──→ T009 → T013 → T017
T007 [P] ────┘

OAuth Track:
T018 [P] → T019 → T020

Testing Track:
T021 [P] (anytime after T012)
T022 [P] (anytime after T017)
T023 (final integration tests)
```

## Parallel Work Opportunities

**Group 1** (start immediately - 7 hours):
- T001: Database schema [P]
- T002: Password hashing [P]
- T003: Registration form [P]
- T007: Login form [P]

**Group 2** (after Group 1 - 8 hours):
- T004: Registration API (needs T001, T002)
- T009: Form integration (needs T003)
- T021: Backend tests (needs T001, T002) [P]

[Additional parallel groups...]

**Time Savings**: Sequential = 52h, Parallel = ~31h (40% savings)

## Next Steps

1. Review 23 tasks for completeness
2. Backend team starts T001, T002
3. Frontend team starts T003, T007
4. Run `spec:implement --parallel` for multi-track execution
5. Sync daily standup with current-session.md progress
```

---

## Example 4: Update Scenario (Requirements Changed)

### Input Context

**Original tasks.md**: Had 15 tasks for simple JWT auth.

**Updated spec.md**: Now requires OAuth, 2FA, and password complexity rules.

**Updated plan.md**: Added OAuth providers, TOTP implementation.

### Command

```bash
spec:tasks --update
```

### Generated Diff

```markdown
# Task Update Report

**Feature**: 001-user-auth
**Update Type**: Requirements expansion
**Original Tasks**: 15
**New Tasks**: 23 (+8 new, +3 modified, -0 removed)

## Added Tasks

### Task T016: Add OAuth Google provider
- Priority: P1
- Estimate: 4 hours
- Dependencies: T001
- Files: src/services/oauth.service.ts
- Reason: New requirement for OAuth login

### Task T017: Add OAuth GitHub provider
- Priority: P1
- Estimate: 3 hours
- Dependencies: T016
- Files: src/services/oauth.service.ts

### Task T018: Implement TOTP 2FA generation
- Priority: P2
- Estimate: 3 hours
- Dependencies: T001
- Files: src/services/totp.service.ts

[More new tasks...]

## Modified Tasks

### Task T005: Implement password validation ⚠️ CHANGED
- **Old**: Simple regex validation
- **New**: Must include complexity rules (min 12 chars, upper/lower/number/symbol)
- **New Estimate**: 2 hours → 3 hours (+1 hour)

[More modifications...]

## Migration Plan

1. Move completed tasks (T001-T007) to CHANGES-COMPLETED.md
2. Update in-progress task T008 with new requirements
3. Add new tasks T016-T023 to CHANGES-PLANNED.md
4. Update critical path estimate: 24h → 38h (+14h)

## Impact Analysis

- **Timeline**: +14 hours to original estimate
- **Parallel Opportunity**: New OAuth tasks can run parallel to 2FA tasks
- **Dependencies**: T016-T017 block final integration (T023)
- **Risk**: OAuth provider APIs may have rate limits (test thoroughly)

**Proceed with update? (yes/no)**
```

---

## Token Budgets

- **SKILL.md**: ~1,450 tokens (core execution logic)
- **EXAMPLES.md**: ~3,800 tokens (this file - 4 detailed scenarios)
- **REFERENCE.md**: ~2,000 tokens (task format specs, algorithms)

**Total**: ~7,250 tokens with progressive disclosure:
- Level 1 (always loaded): SKILL.md frontmatter (~100 tokens)
- Level 2 (on activation): SKILL.md body (~1,450 tokens)
- Level 3 (on demand): EXAMPLES.md + REFERENCE.md (~5,800 tokens)
