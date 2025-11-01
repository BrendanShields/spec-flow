# spec:plan - Technical Reference

This file contains technical specifications, templates, and advanced patterns for the spec:plan skill.

## plan.md Template

Complete template for generated technical plans:

```markdown
# [Feature Name] - Technical Plan

**Feature ID**: [###]
**Feature**: [Feature name from spec]
**Created**: [YYYY-MM-DD]
**Author**: spec:plan skill
**Status**: Active | Implemented | Superseded
**Spec**: [Link to spec.md]
**JIRA**: [PROJ-###] (if MCP enabled)
**Confluence**: [URL] (if MCP enabled)

---

## Overview

[High-level technical approach in 3-5 sentences. Answer: What are we building? How does it work? Why this approach?]

**Key Technologies**:
- [Technology 1]: [Usage]
- [Technology 2]: [Usage]
- [Technology 3]: [Usage]

**Estimated Complexity**: Low | Medium | High
**Estimated Duration**: [X days/weeks]
**Team Size**: [N developers]

---

## Data Model

### Entities

**[Entity Name 1]**:
```
Fields:
- id: [type, constraints]
- field1: [type, constraints, description]
- field2: [type, constraints, description]
- created_at: [type]
- updated_at: [type]

Relationships:
- belongs_to: [Entity2]
- has_many: [Entity3]

Indexes:
- [field1, field2] (for common query pattern)

Constraints:
- UNIQUE(field1)
- CHECK(field2 > 0)
```

**[Entity Name 2]**:
[Similar structure...]

### Database Schema

**SQL Example**:
```sql
CREATE TABLE entity_name (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  field1 VARCHAR(255) NOT NULL,
  field2 INTEGER CHECK (field2 > 0),
  entity2_id UUID REFERENCES entity2(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_entity_name_field1_field2 ON entity_name(field1, field2);
```

**NoSQL Example** (if applicable):
```json
{
  "collection": "entity_name",
  "schema": {
    "id": "ObjectId",
    "field1": "String (required, indexed)",
    "field2": "Number (min: 0)",
    "nested": {
      "subfield1": "String",
      "subfield2": "Array<String>"
    }
  },
  "indexes": [
    { "field1": 1, "field2": -1 },
    { "nested.subfield1": "text" }
  ]
}
```

---

## API Contracts

### Endpoint 1: [Name]

**Route**: `[METHOD] /api/v1/resource`

**Authentication**: Required | Optional | None
**Authorization**: [Role requirements]

**Request**:
```json
{
  "field1": "string (required, max 255 chars)",
  "field2": "number (optional, min 0)",
  "nested": {
    "subfield": "string (required if nested present)"
  }
}
```

**Response** (Success - 200/201):
```json
{
  "data": {
    "id": "uuid",
    "field1": "string",
    "field2": "number",
    "created_at": "ISO8601 timestamp"
  },
  "meta": {
    "timestamp": "ISO8601 timestamp"
  }
}
```

**Response** (Error - 4xx/5xx):
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": {
      "field": "field1",
      "reason": "validation_failed"
    }
  }
}
```

**Example Request**:
```bash
curl -X POST /api/v1/resource \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"field1": "value", "field2": 42}'
```

### Endpoint 2: [Name]
[Similar structure for each endpoint...]

### WebSocket API (if applicable)

**Connection**: `wss://api.example.com/ws`

**Messages**:
```json
// Client → Server
{
  "type": "subscribe",
  "channel": "entity.updates",
  "filters": { "entity_id": "uuid" }
}

// Server → Client
{
  "type": "update",
  "channel": "entity.updates",
  "data": { "entity": {...}, "action": "created" }
}
```

---

## Architecture

### System Components

**Component Diagram** (text-based):
```
┌─────────────────────────────────────────────────┐
│  Client Layer                                   │
│  ┌─────────────┐  ┌─────────────┐              │
│  │   Web App   │  │  Mobile App │              │
│  └──────┬──────┘  └──────┬──────┘              │
└─────────┼─────────────────┼────────────────────┘
          │                 │
          ▼                 ▼
┌─────────────────────────────────────────────────┐
│  API Gateway Layer                              │
│  ┌──────────────────────────────────────┐      │
│  │     Load Balancer + Rate Limiting     │      │
│  └──────────────┬────────────────────────┘      │
└─────────────────┼──────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│  Application Layer                              │
│  ┌──────────────┐  ┌──────────────┐            │
│  │ Service A    │  │  Service B   │            │
│  │ (REST API)   │  │  (Worker)    │            │
│  └──────┬───────┘  └──────┬───────┘            │
└─────────┼──────────────────┼────────────────────┘
          │                  │
          ▼                  ▼
┌─────────────────────────────────────────────────┐
│  Data Layer                                     │
│  ┌──────────────┐  ┌──────────────┐            │
│  │  PostgreSQL  │  │   Redis      │            │
│  │  (Primary DB)│  │   (Cache)    │            │
│  └──────────────┘  └──────────────┘            │
└─────────────────────────────────────────────────┘
```

### Component Descriptions

**Service A (REST API)**:
- Handles HTTP requests
- Business logic layer
- Database access via ORM
- Response formatting
- Input validation

**Service B (Worker)**:
- Background job processing
- Event handling (from queue)
- Scheduled tasks (cron)
- Email/notification sending

**PostgreSQL**:
- Primary data storage
- ACID transactions
- Relational queries
- Full-text search (if applicable)

**Redis**:
- Session storage
- Cache layer
- Rate limiting counters
- Real-time data (pub/sub)

### Data Flow

**Create Entity Flow**:
```
1. User submits form → Client
2. Client validates → API request to Service A
3. Service A validates → Business logic
4. Service A writes → PostgreSQL
5. Service A publishes event → Message Queue
6. Worker processes event → Send notification
7. Service A returns response → Client
8. Client updates UI → Success message
```

**Read with Caching**:
```
1. Client requests entity → Service A
2. Service A checks → Redis cache
3. Cache HIT: Return cached data
4. Cache MISS:
   a. Query PostgreSQL
   b. Store in Redis (TTL: 5min)
   c. Return data
5. Client renders data
```

### Layer Responsibilities

**Presentation Layer** (Client):
- User interface
- Input validation (client-side)
- State management
- API communication

**API Layer** (Service A):
- Request routing
- Authentication/authorization
- Input validation (server-side)
- Business logic orchestration
- Response formatting

**Business Logic Layer**:
- Domain rules
- Workflow execution
- Data transformation
- Integration coordination

**Data Access Layer**:
- Database queries
- ORM/query builder
- Transaction management
- Cache operations

**Infrastructure Layer**:
- Message queues
- File storage
- External API clients
- Monitoring/logging

---

## Security Considerations

### Authentication
- **Method**: [JWT, OAuth, API keys, etc.]
- **Token expiration**: [Duration]
- **Refresh strategy**: [How tokens are refreshed]
- **Storage**: [Where tokens stored - httpOnly cookies, localStorage, etc.]

### Authorization
- **Model**: [RBAC, ABAC, etc.]
- **Roles**: [List of roles and permissions]
- **Resource-level**: [How to check if user can access specific resource]

### Input Validation
- **Client-side**: Basic format validation
- **Server-side**: Comprehensive validation + sanitization
- **Schema validation**: JSON Schema, Zod, Joi, etc.
- **SQL injection prevention**: Parameterized queries, ORM

### Data Protection
- **Encryption at rest**: [Database encryption, field-level encryption]
- **Encryption in transit**: [TLS/HTTPS only]
- **Sensitive data**: [PII handling, password hashing with bcrypt]
- **Secrets management**: [Environment variables, vault, etc.]

### Rate Limiting
- **Per user**: [X requests per Y minutes]
- **Per IP**: [X requests per Y minutes]
- **Implementation**: [Redis counters, API gateway]

### Audit Logging
- **Events logged**: [Authentication, data changes, admin actions]
- **Log format**: [JSON structured logs]
- **Retention**: [Duration]
- **Storage**: [Log aggregation service]

---

## Performance Considerations

### Database Optimization
- **Indexes**: [List critical indexes]
- **Query optimization**: [N+1 prevention, eager loading]
- **Connection pooling**: [Pool size, configuration]
- **Partitioning**: [If large tables]

### Caching Strategy
- **Cache layer**: [Redis, Memcached, etc.]
- **Cache keys**: [Naming convention]
- **TTL**: [Per resource type]
- **Invalidation**: [Strategy for cache busting]

### API Performance
- **Pagination**: [Default page size, max page size]
- **Rate limiting**: [Prevent abuse]
- **Response compression**: [gzip enabled]
- **CDN**: [Static assets served via CDN]

### Monitoring
- **Metrics collected**: [Response time, error rate, throughput]
- **Alerting**: [SLO violations, error spikes]
- **Tools**: [Prometheus, Grafana, DataDog, etc.]

---

## Implementation Notes

### Setup Steps

**1. Environment Setup**:
```bash
# Install dependencies
npm install

# Copy environment template
cp .env.example .env

# Configure environment variables
# - DATABASE_URL
# - REDIS_URL
# - API_KEY
# - [Other variables]

# Run database migrations
npm run migrate

# Seed development data
npm run seed
```

**2. Database Setup**:
```bash
# Create database
createdb myapp_development

# Run migrations
npx prisma migrate deploy

# Or for raw SQL:
psql myapp_development < migrations/001_initial_schema.sql
```

**3. Service Setup**:
```bash
# Start dependencies (Docker)
docker-compose up -d

# Start development server
npm run dev

# In another terminal, start worker
npm run worker
```

### Key Files and Directories

```
src/
├── api/
│   ├── routes/          # Route definitions
│   │   ├── entity.ts    # Entity CRUD routes
│   │   └── index.ts     # Route aggregation
│   ├── middleware/      # Express middleware
│   │   ├── auth.ts      # Authentication
│   │   └── validation.ts # Request validation
│   └── controllers/     # Request handlers
│       └── entity-controller.ts
├── services/            # Business logic
│   ├── entity-service.ts
│   └── notification-service.ts
├── models/              # Data models (ORM)
│   └── entity.ts
├── workers/             # Background jobs
│   └── email-worker.ts
├── config/              # Configuration
│   ├── database.ts
│   └── redis.ts
└── utils/               # Utilities
    ├── validation.ts
    └── encryption.ts

tests/
├── unit/                # Unit tests
├── integration/         # Integration tests
└── e2e/                 # End-to-end tests

migrations/              # Database migrations
└── 001_initial_schema.sql

scripts/                 # Helper scripts
├── seed.ts              # Data seeding
└── migrate.ts           # Migration runner
```

### Development Workflow

**1. Create Feature Branch**:
```bash
git checkout -b feat/feature-name
```

**2. Implement Components** (in order):
1. Database migration (if schema changes)
2. Models (data access layer)
3. Services (business logic)
4. Controllers (API handlers)
5. Routes (wire up endpoints)
6. Tests (unit → integration → e2e)

**3. Testing**:
```bash
# Run all tests
npm test

# Run specific test suite
npm test -- entity-service

# Run with coverage
npm run test:coverage
```

**4. Local Verification**:
```bash
# Start locally
npm run dev

# Test endpoints
curl localhost:3000/api/v1/entity

# Check logs
tail -f logs/app.log
```

### Common Patterns

**Error Handling**:
```typescript
// Centralized error handler
class AppError extends Error {
  statusCode: number;
  code: string;

  constructor(message: string, statusCode: number, code: string) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
  }
}

// Usage
throw new AppError('Entity not found', 404, 'ENTITY_NOT_FOUND');
```

**Input Validation**:
```typescript
// Using Zod
const createEntitySchema = z.object({
  field1: z.string().max(255),
  field2: z.number().min(0).optional(),
});

// In controller
const data = createEntitySchema.parse(req.body);
```

**Database Transaction**:
```typescript
// Using Prisma
await prisma.$transaction(async (tx) => {
  const entity1 = await tx.entity1.create({ data: {...} });
  const entity2 = await tx.entity2.create({ data: {...} });
  return { entity1, entity2 };
});
```

---

## Testing Strategy

### Test Pyramid

```
        ┌────────────┐
        │    E2E     │  (10% - Full user workflows)
        └────────────┘
       ┌──────────────┐
       │ Integration  │  (30% - Service + DB interactions)
       └──────────────┘
     ┌──────────────────┐
     │      Unit        │  (60% - Individual functions/classes)
     └──────────────────┘
```

### Test Coverage Goals

- **Overall**: 80%+ code coverage
- **Critical paths**: 100% coverage
- **Business logic**: 90%+ coverage
- **Controllers**: 70%+ coverage
- **Utils**: 90%+ coverage

### Test Types

**Unit Tests**:
- Test individual functions in isolation
- Mock external dependencies
- Fast execution (<1s per test)
- Run on every commit

**Integration Tests**:
- Test service + database interactions
- Use test database
- Verify API contracts
- Run before PR merge

**E2E Tests**:
- Test complete user workflows
- Use staging environment
- Verify UI + API + DB together
- Run before deployment

### Test Examples

**Unit Test**:
```typescript
describe('EntityService', () => {
  describe('createEntity', () => {
    it('should create entity with valid data', async () => {
      const mockRepo = { create: jest.fn().mockResolvedValue({ id: '123' }) };
      const service = new EntityService(mockRepo);

      const result = await service.createEntity({ field1: 'value' });

      expect(result.id).toBe('123');
      expect(mockRepo.create).toHaveBeenCalledWith({ field1: 'value' });
    });

    it('should throw error for invalid data', async () => {
      const service = new EntityService(mockRepo);

      await expect(
        service.createEntity({ field1: '' })
      ).rejects.toThrow('field1 is required');
    });
  });
});
```

**Integration Test**:
```typescript
describe('POST /api/v1/entity', () => {
  it('should create entity and return 201', async () => {
    const response = await request(app)
      .post('/api/v1/entity')
      .set('Authorization', `Bearer ${testToken}`)
      .send({ field1: 'value', field2: 42 })
      .expect(201);

    expect(response.body.data).toMatchObject({
      field1: 'value',
      field2: 42,
    });

    // Verify in database
    const entity = await db.entity.findById(response.body.data.id);
    expect(entity).toBeTruthy();
  });
});
```

**E2E Test** (using Playwright):
```typescript
test('user can create and view entity', async ({ page }) => {
  await page.goto('/entities');

  // Create entity
  await page.click('button:has-text("Create")');
  await page.fill('input[name="field1"]', 'Test Value');
  await page.fill('input[name="field2"]', '42');
  await page.click('button:has-text("Submit")');

  // Verify creation
  await expect(page.locator('.success-message')).toBeVisible();
  await expect(page.locator('.entity-list')).toContainText('Test Value');
});
```

---

## ADR Format Specification

Architecture Decision Records (ADRs) use the following format:

```markdown
## ADR-###: [Decision Title]

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Rejected | Superseded | Deprecated
**Context**: [Feature or area this decision affects]
**Deciders**: [Team members involved]
**Technical Story**: [Link to JIRA/GitHub issue if applicable]

### Problem Statement

[Describe the problem that requires a decision. What is the context? What are the constraints?]

### Decision

[State the decision clearly and concisely. "We will [decision]..."]

### Rationale

[Explain WHY this decision was made. List the factors considered:]

**Positive Factors**:
- Factor 1: [Why this is positive]
- Factor 2: [Why this is positive]

**Negative Factors**:
- Factor 1: [Trade-off accepted]
- Factor 2: [Trade-off accepted]

**Constraints**:
- Constraint 1: [How it influenced decision]
- Constraint 2: [How it influenced decision]

### Consequences

**Positive**:
- [Good consequence 1]
- [Good consequence 2]
- [Good consequence 3]

**Negative**:
- [Bad consequence 1 - mitigation strategy]
- [Bad consequence 2 - mitigation strategy]

**Neutral**:
- [Consequence that's neither good nor bad]

### Alternatives Considered

**Alternative 1: [Name]**
- Description: [Brief description]
- Pros: [List pros]
- Cons: [List cons]
- Reason rejected: [Why not chosen]

**Alternative 2: [Name]**
[Similar structure...]

### Implementation Notes

[Practical guidance for implementing this decision:]
- Files affected: [List]
- Migration required: [Yes/No - details]
- Timeline: [When to implement]
- Rollback plan: [How to reverse if needed]

### Validation

[How will we know this decision was correct?]
- Metric 1: [What to measure]
- Metric 2: [What to measure]
- Review date: [When to reassess]

### References

- [Link to research 1]
- [Link to documentation 2]
- [Link to benchmark 3]

### Related Decisions

- ADR-###: [Related decision]
- Supersedes: ADR-### (if replacing old decision)
- Superseded by: ADR-### (if this decision is replaced)

---
```

---

## Integration with spec:researcher

### Invoking Research Agent

**From spec:plan skill**:

```markdown
When technology choices needed:
1. Identify decision points from spec
2. Formulate research query
3. Invoke spec:researcher agent
4. Receive research report + decision matrix
5. Use findings in plan + ADR
```

**Research Query Format**:
```
Topic: [What to research]
Context: [Project domain, tech stack, constraints]
Criteria: [What to evaluate - performance, cost, DX, etc.]
Alternatives: [Known options, if any]
```

**Example**:
```
Topic: Database for multi-tenant SaaS
Context: Node.js backend, 100+ tenants expected, strong data isolation required
Criteria: Scalability, data isolation, operational complexity, cost
Alternatives: PostgreSQL (schema-per-tenant), MongoDB, MySQL
```

### Processing Research Findings

**Research Report Structure**:
```markdown
# Research Report: [Topic]

## Executive Summary
[Key findings in 2-3 sentences]

## Alternatives Evaluated

### Option 1: [Name]
- Description: [...]
- Pros: [...]
- Cons: [...]
- Score: [X/10]

### Option 2: [Name]
[Similar...]

## Recommendation
[Clear recommendation with rationale]

## Implementation Notes
[Practical guidance]

## References
[Sources consulted]
```

**Using in Plan**:
1. Extract recommendation → Use in Architecture section
2. Extract alternatives → Use in ADR "Alternatives Considered"
3. Extract implementation notes → Use in Implementation Notes
4. Include research report link in plan references

---

## MCP Integration Details

### Confluence Publishing

**When to Publish**:
- After plan.md generated
- If `SPEC_ATLASSIAN_SYNC=enabled` in CLAUDE.md
- User confirms publish action

**Confluence Page Structure**:
```markdown
# [Feature Name] - Technical Plan

<info>
This page is auto-generated from spec:plan.
Source: features/###-feature-name/plan.md
Last synced: YYYY-MM-DD HH:MM:SS
</info>

[Full plan content formatted for Confluence]

## Metadata
- Feature ID: ###
- JIRA: [PROJ-###]
- Status: Active
- Last updated: [timestamp]
```

**MCP Call Pattern**:
```typescript
// Pseudocode for MCP integration
async function publishToConfluence(plan: Plan) {
  const config = readConfig('CLAUDE.md');

  if (!config.SPEC_ATLASSIAN_SYNC) {
    return; // Skip if not enabled
  }

  const content = formatForConfluence(plan);

  try {
    const page = await mcp.confluence.createPage({
      space_key: config.SPEC_CONFLUENCE_SPACE,
      parent_page_id: config.SPEC_CONFLUENCE_ROOT_PAGE_ID,
      title: `${plan.featureName} - Technical Plan`,
      content: content,
    });

    // Store URL in plan metadata
    updatePlanMetadata(plan, { confluence_url: page.url });

    return page.url;
  } catch (error) {
    console.warn('Confluence publish failed:', error);
    // Continue workflow, don't block
  }
}
```

### JIRA Integration

**Update JIRA Issue**:
```markdown
When plan created:
1. Find JIRA issue from spec metadata
2. Update issue with plan summary
3. Add comment with link to plan
4. Update custom field "Technical Plan" with URL
```

**JIRA Comment Format**:
```markdown
Technical plan created: [Link to plan.md]

Summary:
- Architecture: [Key decisions]
- Estimated complexity: [Low/Medium/High]
- Key technologies: [List]

Full plan: [Link]
ADRs documented: [Count]
```

---

## Error Recovery

### Missing Spec File

**Detection**:
```bash
if [[ ! -f "features/###-feature-name/spec.md" ]]; then
  echo "Error: No specification found"
fi
```

**Recovery**:
1. Check if feature ID is correct
2. Suggest running spec:generate first
3. Offer to list available features
4. Exit gracefully

### Research Agent Unavailable

**Detection**:
- spec:researcher not responding
- WebSearch tool unavailable

**Recovery**:
1. Warn user: "Research agent unavailable, using cached knowledge"
2. Continue with manual planning
3. Document limitation in plan: "Note: Plan created without deep research"
4. Suggest re-running with research when available

### Conflicting ADRs

**Detection**:
- New decision contradicts existing ADR
- Same problem being solved differently

**Recovery**:
1. Alert user: "Decision conflicts with ADR-###"
2. Show conflict details
3. Ask user: "Update ADR-### or create new ADR-###?"
4. If update: Mark old ADR as "Superseded by ADR-###"
5. If new: Document relationship in both ADRs

### MCP Failure

**Detection**:
- MCP tool call fails
- Timeout or network error

**Recovery**:
1. Log warning: "MCP integration failed: [reason]"
2. Continue workflow locally
3. Save plan artifacts to filesystem
4. Suggest manual sync if needed
5. Never block workflow on MCP failures

---

## Performance Optimization

### Token Efficiency

**Core SKILL.md**: ~1,400 tokens
**EXAMPLES.md**: ~3,000 tokens (loaded on demand)
**REFERENCE.md**: ~4,500 tokens (loaded on demand)

**Total**: ~8,900 tokens (vs previous ~15,000 tokens = 41% reduction)

### Progressive Disclosure Strategy

**Level 1** (Always loaded): SKILL.md
- Core workflow
- When to use
- Error handling basics

**Level 2** (Loaded when examples needed): EXAMPLES.md
- Concrete scenarios
- Common patterns
- Tips and tricks

**Level 3** (Loaded when deep reference needed): REFERENCE.md
- Complete templates
- Technical specifications
- Advanced patterns
- MCP integration details

**When to load each level**:
- L1: Every plan invocation
- L2: User asks "show me an example" or first-time users
- L3: User needs template details or MCP integration

---

## Related Files

**Shared Resources**:
- `../shared/workflow-patterns.md` - Phase transitions, validation
- `../shared/integration-patterns.md` - MCP publishing patterns
- `../shared/state-management.md` - State file specifications

**Related Skills**:
- `../spec-generate/` - Creates spec.md (prerequisite)
- `../spec-tasks/` - Creates tasks.md (next step)
- `../spec-researcher/` - Research agent (invoked by this skill)

**Commands**:
- `.claude/commands/spec-plan.md` - Slash command wrapper

---

**Last Updated**: 2025-10-31
**Token Size**: ~4,500 tokens
**Used By**: spec:plan skill
