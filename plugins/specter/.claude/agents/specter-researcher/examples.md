# Flow Researcher - Examples

Examples of research outputs, strategies, and documentation formats.

## Research Strategy Examples

**Domain-Specific Research:**
- **E-commerce**: Payment processing, inventory management, cart optimization
- **SaaS**: Multi-tenancy, subscription billing, usage metering, feature flags
- **API Platform**: Versioning, rate limiting, authentication, OpenAPI/GraphQL
- **Sources**: Engineering blogs, architecture papers, case studies

**Technology Stack Research:**
- Evaluate candidates (React, Vue, Svelte, Angular) by criteria (learning curve, ecosystem, performance, community)
- Compare options (PostgreSQL, MySQL, MongoDB, DynamoDB) by fit, scalability, consistency
- Research sources: Official benchmarks, GitHub activity, npm trends, production case studies

## Research Output Examples

### Example 1: Specification Support - User Authentication

```markdown
# Research Results for User Authentication

## Best Practices Discovered
1. **JWT vs Sessions**: JWT preferred for stateless microservices
2. **Password Storage**: bcrypt with cost factor 12+ recommended
3. **OAuth Providers**: Google + GitHub cover 80% of developer users
4. **2FA**: TOTP preferred over SMS for security

## Library Recommendations
| Purpose | Library | Reason |
|---------|---------|--------|
| JWT | jsonwebtoken | Most mature, 20M weekly downloads |
| Passwords | bcrypt | Proven secure, hardware acceleration |
| OAuth | Passport.js | 40+ strategies, extensive documentation |
| 2FA | speakeasy | TOTP/HOTP support, well-maintained |

## Domain Patterns
- **Pattern**: Separate auth service
- **Rationale**: Scalability, single responsibility
- **Examples**: Netflix, Uber, Spotify
- **Implementation**: JWT with refresh tokens
```

### Example 2: Planning Support - Architecture Decision

```markdown
# Technical Research for E-commerce Platform

## Architecture Decision: Microservices vs Monolith

### Research Findings
- Team size: 5 developers → Monolith recommended initially
- Expected scale: 10K users/day → Monolith sufficient
- Time to market: 3 months → Monolith faster

### Recommendation: Modular Monolith
Start with monolith but structure for future extraction:
- Clear module boundaries
- Database schemas per module
- Internal APIs between modules
- Ready for service extraction at 50K users/day

### Migration Path
1. Start: Modular monolith
2. 6 months: Extract payment service
3. 12 months: Extract inventory service
4. 18 months: Full microservices if needed

## Technology Stack Research

### Frontend Framework Decision
**Winner: React 18**
- Largest ecosystem (2M+ packages)
- Best hiring pool (60% of frontend devs)
- Excellent e-commerce libraries (Next.js Commerce)
- SSR/SSG support via Next.js

### Database Decision
**Winner: PostgreSQL + Redis**
- PostgreSQL: ACID compliance for transactions
- JSONB for flexible product attributes
- Redis: Session storage, cache, rate limiting
- Both have excellent cloud offerings
```

### Example 3: Architecture Decision Record (ADR)

```markdown
# ADR-001: Use JWT for Authentication

## Status
Accepted

## Context
Need stateless authentication for horizontal scaling and mobile apps.

## Decision
Implement JWT-based authentication with refresh tokens.

## Rationale

### Positive
- Stateless: No server-side session storage
- Scalable: Works across multiple servers
- Mobile-friendly: Native app support
- Standard: RFC 7519, wide library support

### Negative
- Token revocation complexity
- Larger request payloads
- Clock sync requirements

## Alternatives Considered
1. **Sessions**: Rejected - requires sticky sessions
2. **API Keys**: Rejected - not user-specific
3. **OAuth Only**: Rejected - need local accounts too

## Implementation Notes
- Access token expiry: 15 minutes
- Refresh token expiry: 7 days
- Use RS256 for signing (asymmetric)
- Store refresh tokens in database with revocation support

## References
- JWT RFC: https://tools.ietf.org/html/rfc7519
- OAuth 2.0 JWT Profile: https://tools.ietf.org/html/rfc7523
- OWASP JWT Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html
```

### Example 4: Library Comparison Matrix

```markdown
# Payment Gateway Comparison

| Feature | Stripe | PayPal | Square |
|---------|--------|--------|--------|
| **Setup Complexity** | Low | Medium | Low |
| **Transaction Fee** | 2.9% + 30¢ | 2.9% + 30¢ | 2.6% + 10¢ |
| **International** | 195+ countries | 200+ countries | Limited |
| **Subscription Support** | Excellent | Good | Basic |
| **API Quality** | Excellent | Good | Good |
| **Documentation** | Excellent | Good | Good |
| **Developer Experience** | Best-in-class | Average | Good |
| **Dashboard** | Excellent | Good | Excellent |
| **Mobile SDKs** | Yes | Yes | Yes |
| **Webhooks** | Robust | Good | Good |
| **Fraud Detection** | Radar (paid) | Basic (free) | Basic (free) |

## Recommendation: Stripe
**Reasons:**
- Superior developer experience and documentation
- Best API design and reliability
- Excellent subscription management
- Strong fraud detection (Radar)
- Most active ecosystem and community

**Trade-offs:**
- Slightly higher fees for card-present (Square wins)
- Not ideal if primary market is eBay/marketplace (PayPal wins)
```

### Example 5: Performance Benchmark Research

```markdown
# Frontend Framework Performance Benchmarks

## Lighthouse Scores (median of 10 runs)

| Framework | Performance | First Contentful Paint | Time to Interactive |
|-----------|-------------|------------------------|---------------------|
| **Svelte** | 99 | 0.9s | 1.2s |
| **Preact** | 98 | 1.0s | 1.3s |
| **Vue 3** | 96 | 1.1s | 1.5s |
| **React 18** | 94 | 1.2s | 1.7s |
| **Angular** | 91 | 1.4s | 2.1s |

## Bundle Size (minified + gzipped)

| Framework | Runtime | Hello World App | TodoMVC App |
|-----------|---------|-----------------|-------------|
| Svelte | 0 KB | 3.6 KB | 7.1 KB |
| Preact | 4 KB | 8.2 KB | 12.5 KB |
| Vue 3 | 34 KB | 41 KB | 48 KB |
| React 18 | 42 KB | 49 KB | 56 KB |
| Angular | 67 KB | 78 KB | 95 KB |

## Recommendation Context
- **For maximum performance**: Svelte (smallest bundle, fastest)
- **For best ecosystem**: React (most packages, largest community)
- **For progressive adoption**: Vue (gentle learning curve)
- **For enterprise with TypeScript**: Angular (batteries-included)

## Source
- Benchmarks: https://krausest.github.io/js-framework-benchmark/
- Bundle sizes: https://bundlephobia.com
- Real-world tests: Lighthouse audits on sample apps
```

### Example 6: Security Assessment

```markdown
# Authentication Library Security Assessment

## bcrypt Evaluation

### Security Posture
✅ **Strong**: Adaptive hashing (adjustable cost factor)
✅ **Proven**: 20+ years in production
✅ **Standard**: Used by major platforms (GitHub, GitLab, etc.)
✅ **Audited**: Multiple security audits, no critical CVEs

### Known Issues
⚠️ **Max password length**: 72 characters (rarely an issue)
⚠️ **Null byte handling**: Terminates at \x00 (avoid in passwords)

### Best Practices
- Cost factor: 12-14 (2023 recommendations)
- Don't lowercase before hashing
- Salt is automatically handled
- Use async version (bcrypt.hash) to avoid blocking

### Alternatives Considered
- **Argon2**: Newer, but less ecosystem support in Node.js
- **scrypt**: Good, but bcrypt has better library support
- **PBKDF2**: Weaker than bcrypt, not recommended

### Verdict
✅ **Recommended** - Mature, secure, well-supported

### References
- OWASP Password Storage: https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
- CVE Database: https://cve.mitre.org (search: bcrypt)
- npm audit: `npm audit bcrypt` (check regularly)
```

### Example 7: State Management Pattern Discovery

**React state management layers:**

| Layer | Tool | Use Case | Key Benefits |
|-------|------|----------|--------------|
| Server State | React Query | API data, caching | Auto-invalidation, background sync, request dedup |
| Client State | Zustand | UI state, preferences | Minimal boilerplate, TypeScript-friendly |
| Form State | React Hook Form | Form validation | Minimal re-renders, 100KB smaller than Formik |

**Implementation priority:**
1. React Query for all API calls
2. Zustand for global UI state
3. React Hook Form for complex forms

**References:** [State Management Guide](https://react.dev/learn/managing-state), [React Query](https://tanstack.com/query/latest), [Zustand](https://github.com/pmndrs/zustand)

## Context-Aware Research

**Keyword-based research triggering:**
- "real-time" → WebSockets, SSE, Socket.io, Pusher
- "video streaming" → HLS, DASH, WebRTC, CDN
- "authentication" → JWT, OAuth2, Passport.js, Auth0
- "payments" → Stripe, PayPal, Square, Braintree
- "search" → Elasticsearch, Algolia, MeiliSearch

**Trend analysis:**
- **Rising**: Svelte, Deno, Rust, WebAssembly → Evaluate for future projects
- **Stable**: React, Node.js, PostgreSQL, Docker → Safe production choices
- **Declining**: jQuery, Backbone, CoffeeScript → Avoid for new projects

**Risk assessment:**
- New technology (0.8) → Prototype first
- Single maintainer (0.9) → Check governance model
- Small community (0.6) → Assess documentation quality
- Breaking changes (0.7) → Check semver adherence

---

*For technical specifications, see [reference.md](./reference.md)*
