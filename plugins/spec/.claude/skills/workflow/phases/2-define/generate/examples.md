# Specification Generation Examples

Concrete scenarios demonstrating Generate phase in action.

## Example 1: Greenfield SaaS Authentication

**User Request:**
"I need to create a spec for user authentication in our new SaaS app"

**Skill Execution:**

1. **Context Check:** No existing codebase detected (greenfield)
2. **Requirements Gathering:**
   - AskUserQuestion: "What authentication methods? (email/password, OAuth, SSO)"
   - AskUserQuestion: "What user roles do you need? (admin, user, guest)"
   - AskUserQuestion: "Any specific compliance requirements? (SOC2, GDPR)"

3. **Generated Spec:**

```markdown
# Feature: User Authentication System

**Feature ID**: 001
**Priority**: P1 (Must Have)
**Owner**: dev-team
**Created**: 2024-10-31
**JIRA Epic**: AUTH-123

## Problem Statement

Users need a secure way to access the application. Without authentication,
we cannot protect user data, enforce access controls, or provide personalized
experiences.

## User Stories

### P1 (Must Have)

#### US1.1: Email/Password Registration
As a new user, I can register with email and password
so that I can create an account and access the application.

**Acceptance Criteria:**
- [ ] Email validation (RFC 5322 compliant)
- [ ] Password strength: min 12 chars, uppercase, lowercase, number, symbol
- [ ] Duplicate email detection with clear error message
- [ ] Confirmation email sent within 60 seconds
- [ ] Account activation link expires after 24 hours
- [ ] GDPR consent checkbox required

**Technical Notes:**
- Use bcrypt for password hashing (cost factor 12)
- Store emails lowercase for case-insensitive lookup
- Rate limit: 5 registration attempts per IP per hour

#### US1.2: Email/Password Login
As a registered user, I can log in with email and password
so that I can access my account.

**Acceptance Criteria:**
- [ ] Case-insensitive email matching
- [ ] Account lockout after 5 failed attempts (15 min cooldown)
- [ ] JWT token issued on successful login (1 hour expiry)
- [ ] Refresh token issued (7 day expiry)
- [ ] Last login timestamp updated
- [ ] Failed login attempts logged

#### US1.3: Session Management
As a logged-in user, I can maintain my session across page refreshes
so that I don't have to re-authenticate constantly.

**Acceptance Criteria:**
- [ ] JWT token stored in httpOnly cookie
- [ ] Automatic token refresh before expiry
- [ ] Logout clears all tokens
- [ ] Concurrent session limit: [CLARIFY: 3? 5? unlimited?]

### P2 (Should Have)

#### US1.4: Password Reset
As a user who forgot password, I can reset it via email
so that I can regain access to my account.

**Acceptance Criteria:**
- [ ] Password reset link sent to email
- [ ] Reset link expires after [CLARIFY: 1 hour? 24 hours?]
- [ ] One-time use token (invalidated after reset)
- [ ] Email sent even if account doesn't exist (security)
- [ ] Rate limit: 3 reset requests per email per hour

#### US1.5: OAuth Google Login
As a user, I can log in with my Google account
so that I don't need to manage another password.

**Acceptance Criteria:**
- [ ] OAuth 2.0 flow with Google
- [ ] Email verification from Google profile
- [ ] Account linking if email already exists [CLARIFY: Auto-link or ask user?]
- [ ] Profile picture imported from Google

### P3 (Nice to Have)

#### US1.6: Two-Factor Authentication
As a security-conscious user, I can enable 2FA
so that my account has additional protection.

**Acceptance Criteria:**
- [ ] TOTP-based 2FA (Google Authenticator compatible)
- [ ] QR code generation for setup
- [ ] Backup codes generated (10 codes)
- [ ] Option to disable 2FA with current password

## Technical Requirements

### Security
- Password hashing: bcrypt (cost 12)
- JWT signing: RS256 with rotating keys
- HTTPS required for all authentication endpoints
- CSRF protection on all state-changing operations
- Rate limiting on authentication endpoints

### Performance
- Login response time: < 200ms (p95)
- Token refresh: < 50ms (p95)
- Registration: < 500ms (p95)

### Scalability
- Support: 10,000 concurrent sessions
- Database: Indexed email lookups
- Caching: Redis for session data

## Integration Points

- **Email Service**: SendGrid or AWS SES for transactional emails
- **OAuth Provider**: Google OAuth 2.0 API
- **Session Store**: Redis for token blacklist/session data
- **Analytics**: Track login events, failed attempts, registration funnel

## Non-Functional Requirements

- **Compliance**: GDPR-compliant (consent, data export, right to deletion)
- **Observability**: Log all authentication events (with PII redaction)
- **Monitoring**: Alert on >5% authentication failure rate
- **Disaster Recovery**: Backup user database hourly

## Out of Scope

- Social login beyond Google (Facebook, GitHub) - deferred to v2
- Passwordless/magic link authentication - future consideration
- Single Sign-On (SSO) for enterprises - separate feature
- Biometric authentication - not applicable for web

## Open Questions

1. [CLARIFY: Concurrent session limit - 3, 5, or unlimited?]
2. [CLARIFY: Password reset link expiry - 1 hour or 24 hours?]
3. [CLARIFY: OAuth account linking - automatic or require user confirmation?]
4. [CLARIFY: Email provider - SendGrid or AWS SES?]
5. [CLARIFY: Session storage - Redis or database table?]

## Dependencies

- Email service provider account (SendGrid/SES)
- Redis instance for session storage
- Google OAuth application credentials
- SSL certificate for HTTPS

## Timeline Estimate

- Specification: Complete
- Planning: 2 hours
- Implementation: 3-5 days
- Testing: 2 days
- Total: ~1.5 weeks

## Success Metrics

- Registration completion rate > 80%
- Login success rate > 95%
- Password reset success rate > 90%
- Authentication response time < 200ms (p95)
- Zero security incidents in first 3 months
```

**Workflow State Updated:**
```markdown
## Active Work
### Current Feature
- **Feature ID**: 001
- **Feature Name**: user-authentication-system
- **Phase**: specification
- **Started**: 2024-10-31
- **JIRA**: AUTH-123

## Workflow Progress
- [x] Generate phase - Feature specification (2024-10-31)
- [ ] clarify phase - 5 questions to resolve
- [ ] plan phase - Technical design
- [ ] tasks phase - Task breakdown
```

---

## Example 2: Brownfield Feature - Add Search to Existing E-commerce

**User Request:**
"Add product search functionality to our existing Rails e-commerce app"

**Skill Execution:**

1. **Analyze Existing Codebase:**
```bash
# Skill reads existing architecture
Glob "app/models/**/*.rb"
Glob "app/controllers/**/*.rb"
Read app/models/product.rb
Read app/controllers/products_controller.rb
Grep "elasticsearch|solr|search" in codebase
```

2. **Context Discovered:**
   - Existing Product model with attributes: name, description, price, category
   - PostgreSQL database
   - No existing search infrastructure
   - ~50,000 products in database

3. **Generated Spec:**

```markdown
# Feature: Product Search

**Feature ID**: 012
**Priority**: P1 (Must Have)
**Owner**: backend-team
**Created**: 2024-10-31

## Problem Statement

Users cannot efficiently find products in our catalog of 50,000+ items.
Browsing by category is slow and frustrating. We need full-text search
with filters to improve product discovery and increase conversion.

## Existing Architecture Context

**Product Model (app/models/product.rb):**
- Attributes: name, description, price, category_id, brand, stock_quantity
- Associations: belongs_to :category, has_many :reviews
- Database: PostgreSQL 13
- Current product count: ~50,000

**Current Navigation:**
- Category browsing (/products?category=electronics)
- Simple SQL LIKE queries (slow, limited)

## User Stories

### P1 (Must Have)

#### US12.1: Keyword Search
As a shopper, I can search for products by keyword
so that I can quickly find what I'm looking for.

**Acceptance Criteria:**
- [ ] Search box on homepage and product pages
- [ ] Searches product name and description
- [ ] Results appear within 500ms
- [ ] Minimum 2 characters required
- [ ] Typo tolerance (fuzzy matching)
- [ ] Relevance ranking (name matches ranked higher)
- [ ] No results shows "Did you mean...?" suggestions

**Integration with Existing Code:**
- Add search action to ProductsController
- Reuse existing product partial for results
- Maintain current URL pattern (/products?q=search+term)

#### US12.2: Filter Search Results
As a shopper, I can filter search results by category, price, brand
so that I can narrow down to relevant products.

**Acceptance Criteria:**
- [ ] Category filter (checkboxes, multi-select)
- [ ] Price range slider ($0-$1000)
- [ ] Brand filter (checkboxes)
- [ ] Stock availability toggle (in-stock only)
- [ ] Filters applied without page reload (AJAX)
- [ ] Filter counts shown (e.g., "Electronics (47)")
- [ ] Clear all filters button

**Existing Category Integration:**
- Leverage Category model and associations
- Maintain existing category URLs for SEO

### P2 (Should Have)

#### US12.3: Sort Search Results
As a shopper, I can sort search results
so that I can find best match, lowest price, or highest rated.

**Acceptance Criteria:**
- [ ] Sort options: Relevance (default), Price Low-High, Price High-Low, Rating, Newest
- [ ] Sort persists across pagination
- [ ] Sort selection saved in session

#### US12.4: Search Autocomplete
As a shopper, I see suggestions as I type
so that I can complete my search faster.

**Acceptance Criteria:**
- [ ] Suggestions appear after 2 characters
- [ ] Max 10 suggestions
- [ ] Keyboard navigation (arrow keys, enter)
- [ ] Click suggestion to search
- [ ] [CLARIFY: Include popular searches or only product names?]

### P3 (Nice to Have)

#### US12.5: Search History
As a returning shopper, I can see my recent searches
so that I can quickly repeat common searches.

**Acceptance Criteria:**
- [ ] Last 10 searches stored per user session
- [ ] Click to re-run search
- [ ] Clear history option

## Technical Requirements

### Search Technology Decision

**Option 1: Elasticsearch (Recommended)**
- Pros: Fast, scalable, great full-text search
- Cons: Additional infrastructure, complexity
- [CLARIFY: Do we have infrastructure team support for Elasticsearch?]

**Option 2: PostgreSQL Full-Text Search**
- Pros: No new infrastructure, simpler
- Cons: Less powerful, may not scale to 100k+ products
- Good for MVP, can migrate to Elasticsearch later

**Recommendation: Start with PostgreSQL FTS, plan Elasticsearch migration**

### Performance Targets
- Search response: < 500ms (p95)
- Autocomplete response: < 100ms (p95)
- Index update: Real-time (within 5 seconds of product change)

### Database Changes
```ruby
# Migration needed
add_column :products, :search_vector, :tsvector
add_index :products, :search_vector, using: :gin
```

## Integration Points

**Existing Code Modifications:**
- ProductsController: Add search action
- Product model: Add search scope/method
- Products index view: Add search box
- Add search results view (or reuse index with query param)

**New Code:**
- Search service object (app/services/product_search.rb)
- Search form component
- Search results JavaScript (filtering, sorting)

**Analytics:**
- Track search queries (integrate with existing analytics)
- Monitor zero-result searches
- Track conversion from search

## Non-Functional Requirements

- **SEO**: Search results pages crawlable (/products?q=term)
- **Performance**: Cache popular searches (Redis)
- **Monitoring**: Alert if search response > 1 second
- **Accessibility**: ARIA labels, keyboard navigation

## Out of Scope

- Visual/image search - future consideration
- Voice search - not applicable for desktop
- AI-powered recommendations - separate feature (Feature 015)
- Saved searches - deferred to v2

## Open Questions

1. [CLARIFY: Elasticsearch infrastructure support available?]
2. [CLARIFY: Autocomplete - popular searches or only product matches?]
3. [CLARIFY: Search analytics - Google Analytics or custom?]
4. [CLARIFY: Cache layer - Redis or Rails cache?]

## Dependencies

- None (all existing infrastructure)
- Optional: Elasticsearch if chosen over PostgreSQL FTS

## Migration Strategy

**Phase 1 (MVP): PostgreSQL Full-Text Search**
- Week 1: Implement basic search
- Week 2: Add filters and sorting
- Week 3: Autocomplete and polish

**Phase 2 (Future): Elasticsearch Migration**
- When product count > 100,000 or search performance degrades
- Zero-downtime migration with dual-write period
- A/B test performance before full cutover

## Success Metrics

- Search usage: > 30% of users per session
- Search success rate: < 10% zero-result searches
- Conversion: Search users convert 2x higher than non-search
- Performance: 95th percentile < 500ms

## Timeline Estimate

- Specification: Complete
- Planning: 3 hours
- Implementation: 1.5 weeks
- Testing: 3 days
- Total: ~2 weeks
```

---

## Example 3: Mobile App Feature - Offline Mode

**User Request:**
"We need offline support for our React Native app"

**Skill Execution (Abbreviated):**

```markdown
# Feature: Offline Mode Support

**Feature ID**: 008
**Priority**: P1 (Must Have)

## User Stories

### P1 (Must Have)

#### US8.1: View Cached Content Offline
As a mobile user with no internet connection, I can view previously loaded content
so that the app remains useful without connectivity.

**Acceptance Criteria:**
- [ ] Last viewed 50 items cached locally
- [ ] Images cached (max 100MB total)
- [ ] Offline indicator shown in UI
- [ ] Cached data expires after 7 days
- [ ] [CLARIFY: Which screens need offline support - all or subset?]

#### US8.2: Queue Actions for Sync
As an offline user, I can perform actions that sync when online
so that I can continue working without internet.

**Acceptance Criteria:**
- [ ] Actions queued: likes, bookmarks, profile edits
- [ ] Visual indicator for queued actions
- [ ] Auto-sync when connection restored
- [ ] Conflict resolution if data changed server-side
- [ ] [CLARIFY: Max queue size - 100 actions? 500?]

### P2 (Should Have)

#### US8.3: Offline Search
As an offline user, I can search cached content
so that I can find items without connectivity.

**Acceptance Criteria:**
- [ ] Search works on cached items only
- [ ] Clear indication of limited results
- [ ] Prompt to go online for full search

## Technical Requirements

**Storage:**
- AsyncStorage for metadata
- React Native MMKV for performance-critical data
- Expo FileSystem for cached images

**Sync Strategy:**
- Background sync when app opens
- Retry failed syncs (exponential backoff)
- Conflict resolution: server wins, user notified

## Open Questions

1. [CLARIFY: Which screens require offline support?]
2. [CLARIFY: Maximum queue size before blocking actions?]
3. [CLARIFY: Conflict resolution - server wins or manual merge?]
4. [CLARIFY: Cache size limit - 100MB, 500MB, unlimited?]
```

---

## Example 4: API Feature - Rate Limiting

**User Request:**
"Add rate limiting to our REST API"

**Generated Spec (Abbreviated):**

```markdown
# Feature: API Rate Limiting

**Feature ID**: 019
**Priority**: P1 (Must Have)

## Problem Statement

Our API has no rate limiting, exposing us to abuse, DoS attacks, and
unfair resource consumption. We need tiered rate limits to protect
infrastructure while allowing legitimate usage.

## User Stories

### P1 (Must Have)

#### US19.1: Enforce Rate Limits
As an API operator, the system enforces rate limits per API key
so that no single client can overwhelm the service.

**Acceptance Criteria:**
- [ ] Rate limit: 100 requests/minute (free tier)
- [ ] Rate limit: 1000 requests/minute (paid tier)
- [ ] 429 status code when limit exceeded
- [ ] Retry-After header in response
- [ ] Rate limit headers in all responses:
  - X-RateLimit-Limit: 100
  - X-RateLimit-Remaining: 47
  - X-RateLimit-Reset: 1635724800

#### US19.2: Rate Limit by Endpoint
As an API operator, expensive endpoints have stricter limits
so that resource-intensive operations don't impact all users.

**Acceptance Criteria:**
- [ ] Default: 100 req/min
- [ ] Search endpoint: 30 req/min
- [ ] Report generation: 5 req/min
- [ ] Bulk operations: 10 req/min
- [ ] [CLARIFY: Should limits be per-endpoint or combined?]

## Technical Requirements

**Implementation:**
- Redis for distributed rate limiting
- Token bucket algorithm
- API key extracted from Authorization header

**Performance:**
- Rate limit check: < 10ms overhead per request
- Redis failover: Allow requests if Redis unavailable (fail open)

## Open Questions

1. [CLARIFY: Per-endpoint limits or combined total?]
2. [CLARIFY: Redis failover strategy - fail open or fail closed?]
3. [CLARIFY: IP-based rate limiting for non-authenticated requests?]
```

---

## Example 5: Quick Spec with Many Clarifications

**User Request:**
"Add notifications to the app"

**Generated Spec:**

```markdown
# Feature: User Notifications

**Feature ID**: 023
**Priority**: [CLARIFY: P1, P2, or P3?]

## Problem Statement

Users need to be notified of important events in the application.

[CLARIFY: What events require notifications?]
[CLARIFY: What notification channels - email, push, in-app, SMS?]

## User Stories

### [CLARIFY: Priority?]

#### US23.1: Receive Notifications
As a user, I can receive notifications about [CLARIFY: which events?]
so that I stay informed.

**Acceptance Criteria:**
- [ ] [CLARIFY: Real-time or batch notifications?]
- [ ] [CLARIFY: Notification frequency limits?]
- [ ] [CLARIFY: User can disable notifications?]
- [ ] [CLARIFY: Notification persistence - how long stored?]

## Technical Requirements

[CLARIFY: Technology choice - Firebase, OneSignal, custom?]
[CLARIFY: Notification storage - database or external service?]
[CLARIFY: Delivery guarantees - at-least-once or exactly-once?]

## Open Questions

1. [CLARIFY: What events trigger notifications?]
2. [CLARIFY: Notification channels - email, push, in-app, SMS?]
3. [CLARIFY: Priority level - must-have or nice-to-have?]
4. [CLARIFY: Real-time or batch delivery?]
5. [CLARIFY: Technology preference - Firebase, OneSignal, custom?]
6. [CLARIFY: User notification preferences/settings?]
7. [CLARIFY: Notification retention period?]

**Next Step:** Run /workflow:spec → "🔍 Clarify" to resolve these questions before planning.
```

---

## Key Patterns Demonstrated

1. **Greenfield vs Brownfield**: Different context analysis approaches
2. **Priority Application**: P1/P2/P3 framework with clear criteria
3. **Clarification Tags**: Mark unknowns explicitly for follow-up
4. **Existing Code Integration**: Reference and build on current architecture
5. **Technical Decisions**: Document options and recommendations
6. **Scalability Considerations**: Performance targets and future migration
7. **Incomplete Requirements**: Generate spec with many [CLARIFY] tags when vague

See REFERENCE.md for complete spec template and field definitions.
