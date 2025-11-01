# Spec Clarify - Examples

Concrete scenarios demonstrating clarification workflows for different ambiguity types.

## Example 1: Performance Requirements

### Initial Specification

```markdown
## Performance Requirements

- API endpoints should respond [CLARIFY: quickly]
- Database queries must be [CLARIFY: optimized]
- File uploads should handle [CLARIFY: reasonable file sizes]
```

### Clarification Session

**Detected Ambiguities**:
1. "quickly" - vague performance term (P0)
2. "optimized" - unclear target (P1)
3. "reasonable file sizes" - no numerical limit (P1)

**Questions Asked**:

**Q1: API Response Time Target**
```
Context: Spec states endpoints should respond "quickly"

Recommended: < 200ms p95 latency
Rationale: Industry standard for perceived instant response, achievable with proper caching

Alternatives:
A. < 100ms p95 - Perceived instant (requires CDN, aggressive caching)
B. < 200ms p95 - Fast (balanced, standard web APIs)
C. < 500ms p95 - Acceptable (simpler implementation)

User selects: B
```

**Q2: Database Query Performance**
```
Context: Spec mentions "optimized" database queries

Recommended: < 50ms for 95% of queries
Rationale: Allows for API response under 200ms with processing overhead

Alternatives:
A. < 25ms - Very fast (requires extensive indexing)
B. < 50ms - Fast (standard for well-indexed queries)
C. < 100ms - Acceptable (basic optimization)

User selects: B
```

**Q3: File Upload Size Limit**
```
Context: Spec mentions "reasonable file sizes" for uploads

Recommended: 10MB limit
Rationale: Handles most documents/images, prevents abuse, standard for web apps

Alternatives:
A. 5MB - Conservative (fast uploads, limited use cases)
B. 10MB - Balanced (most file types, reasonable)
C. 50MB - Generous (video support, requires chunk upload)

User selects: B (10MB)
```

### Updated Specification

```markdown
## Performance Requirements

- API endpoints must respond within 200ms (p95 latency) under normal load
- Database queries must complete within 50ms (p95) to meet API response targets
- File uploads limited to 10MB maximum size per file
```

### Decision Log Entry

```markdown
## CLR-001: API Performance Targets

Date: 2025-10-31
Status: Accepted
Context: Feature 002 - API specification
Deciders: Product team

### Decision
- API response time: < 200ms (p95 latency)
- Database queries: < 50ms (p95)
- File upload limit: 10MB

### Rationale
Balanced performance targets that provide good user experience while remaining achievable without complex infrastructure. 200ms API response is industry standard for web applications.

### Consequences
**Positive**:
- Clear measurable targets for implementation
- Standard performance acceptable to most users
- Achievable with basic caching/indexing

**Negative**:
- May need optimization for complex queries
- 10MB limit excludes large video files
```

---

## Example 2: Authentication Method Selection

### Initial Specification

```markdown
## User Stories

US2.1: User can [CLARIFY: authenticate] to access protected resources
US2.2: User sessions should [CLARIFY: persist appropriately]
```

### Clarification Session

**Detected Ambiguities**:
1. Authentication method undefined (P0 - blocks architecture)
2. Session persistence strategy unclear (P0 - affects implementation)

**Questions Asked**:

**Q1: Authentication Method**
```
Context: Spec requires user authentication but doesn't specify method

Recommended: JWT tokens with refresh token rotation
Rationale: Stateless, scalable, secure with proper rotation, works for web + mobile

Alternatives:
A. Session cookies - Simple, server-side state (limits scaling)
B. JWT with refresh - Stateless, scalable, mobile-friendly (recommended)
C. OAuth2 only - Delegated auth (requires external provider)

User selects: B
```

**Q2: Session Duration**
```
Context: Need to define token lifetime for user sessions

Recommended: 15min access token, 7 day refresh token
Rationale: Security best practice - short-lived access, longer refresh with rotation

Alternatives:
A. 5min / 1 day - Very secure (frequent re-auth)
B. 15min / 7 day - Balanced security/UX (recommended)
C. 1 hour / 30 day - Convenient (less secure)

User selects: B
```

### Updated Specification

```markdown
## User Stories

US2.1: User can authenticate using email/password, receiving JWT access token
- Access token lifetime: 15 minutes
- Refresh token lifetime: 7 days with rotation
- Tokens stored securely (httpOnly cookies for web, secure storage for mobile)

US2.2: User sessions persist for 7 days with automatic refresh
- Access token refreshed automatically when expired
- User must re-authenticate after refresh token expiration
```

### Decision Log Entry

```markdown
## CLR-002: Authentication Strategy

Date: 2025-10-31
Status: Accepted
Context: Feature 001 - User Authentication
Deciders: Security team + Engineering

### Decision
Use JWT tokens with refresh token rotation:
- Access token: 15 minute lifetime
- Refresh token: 7 day lifetime
- Automatic rotation on refresh

### Rationale
Provides balance between security and user experience. Short-lived access tokens limit exposure if compromised, while 7-day refresh tokens minimize re-authentication friction.

### Consequences
**Positive**:
- Stateless authentication (scales horizontally)
- Works for web and mobile clients
- Industry standard approach

**Negative**:
- Token revocation requires deny-list
- Slightly more complex than session cookies
- Must implement refresh flow correctly
```

---

## Example 3: Error Handling Strategy

### Initial Specification

```markdown
## Error Handling

- API should [CLARIFY: handle errors gracefully]
- Failed requests should [CLARIFY: retry when appropriate]
- Users should see [CLARIFY: helpful error messages]
```

### Clarification Session

**Q1: Retry Strategy**
```
Context: Need to define when and how failed requests retry

Recommended: 3 retries with exponential backoff for network errors only
Rationale: Handles transient failures without overwhelming servers, exponential backoff prevents thundering herd

Alternatives:
A. No retries - Fail fast (simple but poor UX)
B. 3 retries, exponential - Handle transient issues (recommended)
C. 5 retries, linear - Persistent but may delay errors

User selects: B
```

**Q2: Error Message Detail Level**
```
Context: Balance between helpful debugging and security

Recommended: User-friendly messages + error codes, detailed logs server-side
Rationale: Users get actionable guidance, developers get debugging details, no security info leaked

User selects: Recommended
```

### Updated Specification

```markdown
## Error Handling

### Retry Policy
- Automatic retry for network/timeout errors: 3 attempts
- Backoff strategy: Exponential (1s, 2s, 4s)
- No retry for: 4xx client errors, authentication failures
- Retry for: 5xx server errors, network timeouts, connection errors

### Error Messages
- User-facing: Simple, actionable messages with error codes
  - Example: "Unable to save changes. Please try again. (ERR-1234)"
- Server logs: Detailed error information including stack traces
- No sensitive information in user-facing errors (no stack traces, DB details)
```

---

## Example 4: Data Validation Rules

### Initial Specification

```markdown
## User Registration

US4.1: User can create account with email and password
- Email: [CLARIFY: valid format]
- Password: [CLARIFY: secure enough]
```

### Clarification Session

**Q1: Password Requirements**
```
Context: Need to define password security rules

Recommended: Min 12 chars, require mixed case + number + special
Rationale: NIST 800-63B recommendations for secure passwords

Alternatives:
A. Min 8 chars, any - Simple (weak security)
B. Min 12 chars, mixed - Secure + usable (recommended)
C. Min 16 chars, complex - Very secure (poor UX)

User selects: B
```

**Q2: Email Validation**
```
Context: Define email validation strictness

Recommended: RFC 5322 format + domain verification
Rationale: Catch typos while allowing valid addresses

User selects: Recommended
```

### Updated Specification

```markdown
## User Registration

US4.1: User can create account with validated email and secure password

### Email Validation
- Format: Must match RFC 5322 standard
- Domain verification: Check MX record exists
- Disposable email blocking: Block known disposable providers
- Confirmation required: Send verification email

### Password Requirements
- Minimum length: 12 characters
- Required character types:
  - At least one uppercase letter (A-Z)
  - At least one lowercase letter (a-z)
  - At least one number (0-9)
  - At least one special character (!@#$%^&*)
- Not in common password list (check against breach database)
- Cannot contain user's email or name
```

---

## Common Patterns

### Pattern: Numerical Clarification
```
Vague → Specific
"fast" → "< 200ms p95 latency"
"large files" → "up to 10MB"
"many users" → "10,000 concurrent users"
```

### Pattern: Choice Clarification
```
Ambiguous → Decided
"authenticate" → "JWT with refresh tokens"
"store data" → "PostgreSQL database"
"handle errors" → "3 retries with exponential backoff"
```

### Pattern: Scope Clarification
```
Unclear → Defined
"delete account" → "Soft delete with 30-day recovery window"
"sort results" → "Sort by relevance (default), date, or price"
"validate input" → "Sanitize HTML, check length, verify format"
```

### Pattern: Priority Clarification
```
Unranked → Prioritized
[CLARIFY] → P1 (must have for v1.0)
[CLARIFY] → P2 (nice to have, defer if needed)
[CLARIFY] → P3 (future enhancement)
```

---

## Usage Notes

**When to run spec:clarify**:
- Immediately after spec:generate if [CLARIFY] tags present
- Before spec:plan to ensure complete requirements
- When stakeholders need to make decisions
- After requirements review when gaps identified

**Iteration pattern**:
```
Round 1: Resolve P0 blockers (architecture decisions)
Round 2: Resolve P1 requirements (implementation details)
Round 3: Resolve P2 polish (edge cases, nice-to-haves)
```

**Best practices**:
- Limit to 4 questions per session (avoid fatigue)
- Always provide recommended option with rationale
- Log decisions for future reference
- Update spec.md immediately after each answer
- Scan for remaining ambiguities before proceeding to planning
