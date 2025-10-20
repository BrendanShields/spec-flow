# Architecture Blueprint: [PROJECT_NAME]

**Created**: [DATE]
**Last Updated**: [DATE]
**Status**: [Draft/Active/Deprecated]
**Version**: 1.0.0

---

## Purpose

This document defines **HOW** we build the product defined in `.flow/product-requirements.md`.

All features CAN reference this blueprint for guidance. This is a **peer artifact** (not hierarchical enforcer).

---

## Core Principles

<!--
  These are recommended development principles.
  Evolved from the old "constitution" concept but more comprehensive.
-->

### Principle 1: [Name, e.g., "API-First Design"]

**Guideline**: [The principle, e.g., "All features expose APIs before UI"]

**Rationale**: [Why this principle exists]

**Application**:
- [How this applies, e.g., "flow:plan should define API contracts before UI components"]

**Flexibility**: [When deviations are acceptable]

---

### Principle 2: [Name, e.g., "Test-Driven Development"]

**Guideline**: [The principle]

**Rationale**: [Why]

**Application**:
- [How applied]

**Flexibility**: [When allowed to deviate]

---

### Principle 3: [Name]

[Follow same format]

---

## Architecture Patterns

### Overall Architecture Style

**Pattern**: [Monolith/Microservices/Modular Monolith/Serverless/etc.]

**Rationale**: [Why this architecture was chosen]

**Key Characteristics**:
- [Characteristic 1, e.g., "Single deployable unit"]
- [Characteristic 2, e.g., "Bounded contexts internally"]
- [Characteristic 3, e.g., "Event-driven communication"]

**Considerations**:
- [Consideration 1, e.g., "Services should be stateless where possible"]
- [Consideration 2, e.g., "Minimize direct database access across modules"]

---

### Module/Service Boundaries

<!--
  Define how the system is decomposed.
  Features can reference these modules.
-->

#### Module: [Name, e.g., "Authentication"]

**Responsibility**: [What this module owns]

**Exposes**:
- [API/interface 1]
- [API/interface 2]

**Depends On**:
- [Dependency 1]
- [Dependency 2]

**Storage**: [Database/schema ownership]

---

#### Module: [Name]

[Follow same format]

---

### Communication Patterns

**Synchronous**:
- [Pattern, e.g., "REST APIs for user-facing operations"]
- [When to use synchronous communication]

**Asynchronous**:
- [Pattern, e.g., "Event bus for background processing"]
- [When to use asynchronous communication]

**Real-time**:
- [Pattern, e.g., "WebSockets for live updates"]
- [When to use real-time communication]

---

## Technology Stack

### Frontend

**Framework**: [e.g., "React 18+"]
**Rationale**: [Why chosen]

**State Management**: [e.g., "Zustand"]
**Rationale**: [Why chosen]

**Styling**: [e.g., "Tailwind CSS"]
**Rationale**: [Why chosen]

**Build Tool**: [e.g., "Vite"]

**Testing**:
- Unit: [e.g., "Vitest"]
- Integration: [e.g., "Testing Library"]
- E2E: [e.g., "Playwright"]

---

### Backend

**Language**: [e.g., "TypeScript/Node.js"]
**Rationale**: [Why chosen]

**Framework**: [e.g., "Express.js"]
**Rationale**: [Why chosen]

**API Style**: [e.g., "REST with OpenAPI 3.0"]
**Rationale**: [Why chosen]

**Testing**:
- Unit: [e.g., "Jest"]
- Integration: [e.g., "Supertest"]
- Contract: [e.g., "Pact"]

---

### Data Layer

**Primary Database**: [e.g., "PostgreSQL 15+"]
**Rationale**: [Why chosen]

**Caching**: [e.g., "Redis"]
**Rationale**: [Why and when to use]

**Search**: [e.g., "Elasticsearch"]
**Use Cases**: [When to use search vs database]

**Migrations**: [Tool, e.g., "Knex.js"]

---

### Infrastructure

**Hosting**: [e.g., "AWS"]
**Deployment**: [e.g., "Docker + Kubernetes"]
**CI/CD**: [e.g., "GitHub Actions"]
**Monitoring**: [e.g., "Datadog"]
**Logging**: [e.g., "Structured JSON logs to CloudWatch"]

---

## API Design Guidelines

<!--
  All features creating APIs should follow these guidelines.
  Referenced by flow:plan when creating API contracts.
  See .flow/contracts/openapi.yaml for actual contracts.
-->

### Versioning

**Strategy**: [e.g., "URI versioning (/v1/, /v2/)"]

**Deprecation Policy**: [How long versions are supported]

**Breaking Changes**: [What constitutes a breaking change, how to handle]

---

### Resource Naming

**Convention**: [e.g., "Plural nouns, lowercase, kebab-case"]

**Examples**:
- `/api/v1/users`
- `/api/v1/task-lists`

**Nested Resources**: [When and how deep, e.g., "Max 2 levels: /users/:id/tasks/:taskId"]

---

### Request/Response Format

**Request Body**: [Format, e.g., "JSON, camelCase keys"]

**Response Body**: [Format, e.g., "JSON, camelCase keys"]

**Error Format**:
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": {}
  }
}
```

---

### Authentication & Authorization

**Authentication**: [Method, e.g., "JWT tokens in Authorization header"]

**Authorization**: [Model, e.g., "RBAC with role-based permissions"]

**Token Expiry**: [e.g., "Access: 15min, Refresh: 7 days"]

---

### Rate Limiting

**Strategy**: [e.g., "Token bucket, per-user"]

**Limits**:
- Authenticated: [e.g., "100 req/min"]
- Unauthenticated: [e.g., "10 req/min"]

**Headers**:
- `X-RateLimit-Limit`
- `X-RateLimit-Remaining`
- `X-RateLimit-Reset`

---

### Pagination

**Method**: [e.g., "Cursor-based pagination"]

**Parameters**:
- `limit`: [e.g., "Max 100, default 20"]
- `cursor`: [e.g., "Opaque cursor string"]

**Response**:
```json
{
  "data": [],
  "pagination": {
    "nextCursor": "...",
    "hasMore": true
  }
}
```

---

## Data Modeling Guidelines

### Naming Conventions

**Tables/Collections**: [e.g., "snake_case, plural"]

**Columns/Fields**: [e.g., "snake_case"]

**Enums**: [e.g., "SCREAMING_SNAKE_CASE"]

---

### Primary Keys

**Strategy**: [e.g., "UUIDs for public IDs, auto-increment for internal"]

**Rationale**: [Why this approach]

---

### Timestamps

**Recommended Fields**:
- `created_at`: [ISO 8601, UTC]
- `updated_at`: [ISO 8601, UTC]

**Soft Deletes**: [Strategy, e.g., "deleted_at field, null = not deleted"]

---

### Relationships

**Foreign Keys**: [Recommendation on DB-level enforcement]

**Cascading**: [Guidance for deletes]

**Denormalization**: [When considered, when recommended]

---

## Security Guidelines

### Authentication
- [Guideline 1, e.g., "Passwords hashed with bcrypt, cost 12"]
- [Guideline 2, e.g., "MFA recommended for admin roles"]

### Data Protection
- [Guideline 1, e.g., "PII should be encrypted at rest"]
- [Guideline 2, e.g., "TLS 1.3 for all traffic"]

### Input Validation
- [Guideline 1, e.g., "All input sanitized server-side"]
- [Guideline 2, e.g., "SQL injection prevention via parameterized queries"]

### Secrets Management
- [Guideline 1, e.g., "Secrets in environment variables, never committed"]
- [Guideline 2, e.g., "Rotate credentials every 90 days"]

---

## Performance Guidelines

### Response Times (Targets)
- **P50**: [e.g., "< 100ms"]
- **P95**: [e.g., "< 300ms"]
- **P99**: [e.g., "< 1000ms"]

### Database Queries
- [Guideline, e.g., "Avoid N+1 queries"]
- [Guideline, e.g., "Prefer indexed queries"]

### Caching Strategy
- [When to cache, e.g., "Cache read-heavy, rarely changing data"]
- [TTL recommendations]

---

## Testing Guidelines

### Coverage Recommendations
- **Unit Tests**: [e.g., "80% coverage target"]
- **Integration Tests**: [e.g., "All API endpoints"]
- **E2E Tests**: [e.g., "Critical user paths"]

### Test Naming
- [Convention, e.g., "describe('Module'), it('should behavior when condition')"]

### Mocking Guidelines
- [When to mock vs use real dependencies]

---

## Deployment & Operations

### Deployment Process
1. [Step 1, e.g., "PR merged to main"]
2. [Step 2, e.g., "CI runs tests"]
3. [Step 3, e.g., "Deploy to staging"]
4. [Step 4, e.g., "Smoke tests pass"]
5. [Step 5, e.g., "Deploy to production"]

### Rollback Strategy
- [How to rollback, e.g., "Revert deployment, database migrations are forward-only"]

### Monitoring
- [What to monitor, e.g., "Error rates, latency, throughput"]

### Alerting
- [When to alert, e.g., "Error rate > 1%, P99 latency > 2s"]

---

## Code Quality Guidelines

### Code Style
- **Linter**: [e.g., "ESLint with Airbnb config"]
- **Formatter**: [e.g., "Prettier"]
- **Auto-formatting**: [e.g., "On save, pre-commit hook"]

### Code Review
- [Recommendations, e.g., "All PRs benefit from 1 approval"]
- [Checklist items]

### Documentation
- [What should be documented, e.g., "All public APIs, complex algorithms"]
- [Format, e.g., "JSDoc for code, Markdown for guides"]

---

## Decision Records (ADRs)

<!--
  Log major architecture decisions here.
  Features can reference these or add new ones.
-->

### ADR-001: [Decision Title]

**Date**: [DATE]
**Status**: [Accepted/Superseded/Deprecated]

**Context**: [What problem/decision]

**Decision**: [What was decided]

**Rationale**: [Why this decision]

**Consequences**: [Trade-offs, implications]

**Alternatives Considered**:
- [Alternative 1]: [Why not chosen]
- [Alternative 2]: [Why not chosen]

---

### ADR-002: [Decision Title]

[Follow same format]

---

## Using This Blueprint

### Flat Artifact Model
- This blueprint is a **peer document** (not a hierarchical enforcer)
- Features CAN reference these guidelines but aren't strictly enforced
- Developers ensure consistency manually
- Tools like `flow:analyze` can help detect inconsistencies

### When to Update
1. Major architecture decisions
2. Tech stack changes
3. New patterns adopted
4. Security/compliance requirements change

### Update Process
1. Document proposed change
2. Discuss with team
3. Update blueprint
4. Increment version number
5. Consider impact on existing features

### flow:plan Integration
- `flow:plan` can read this blueprint for guidance
- May propose updates when patterns evolve
- User approval required for blueprint modifications

---

**Version History**:

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0.0 | [DATE] | Initial blueprint | [NAME] |
| 1.1.0 | [DATE] | [Change] | [NAME] |

---

**Related Artifacts**:
- Product Requirements: `.flow/product-requirements.md`
- API Contracts: `.flow/contracts/openapi.yaml` (if API project)
- Data Models: `.flow/data-models/entities.md`

**Notes**:
- This blueprint defines HOW we build (`.flow/product-requirements.md` defines WHAT)
- Features can reference this for guidance
- Not strictly enforced - peer artifact in flat model
- Living document - update as architecture evolves
