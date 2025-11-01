# spec:blueprint - Technical Reference

This file contains complete technical specifications for the spec:blueprint skill.

## Complete Blueprint Template

This is the full template used to generate `.spec/architecture-blueprint.md`:

```markdown
# Architecture Blueprint

**Project**: [Project Name]
**Created**: [Date]
**Last Updated**: [Date]
**Type**: [Greenfield/Brownfield/Migration]
**Status**: [Draft/Approved/Living Document]

---

## 1. System Overview

### High-Level Architecture

[Text-based architecture diagram or description]

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   Frontend  │─────▶│  API Layer  │─────▶│  Database   │
│   (React)   │◀─────│  (Node.js)  │◀─────│ (PostgreSQL)│
└─────────────┘      └─────────────┘      └─────────────┘
                            │
                            ▼
                     ┌─────────────┐
                     │   Cache     │
                     │   (Redis)   │
                     └─────────────┘
```

### Key Components

**Frontend Layer**:
- Responsibility: User interface, client-side logic
- Technology: [Framework/library]
- Communication: [How it talks to backend]

**API Layer**:
- Responsibility: Business logic, request handling
- Technology: [Framework/runtime]
- Communication: [Protocols, formats]

**Data Layer**:
- Responsibility: Data persistence, queries
- Technology: [Database, ORM]
- Communication: [Connection pooling, etc.]

**Supporting Services**:
- Cache: [Technology, purpose]
- Message Queue: [Technology, purpose]
- Background Jobs: [Technology, purpose]

### Integration Points

- **External APIs**: [List of external services integrated]
- **Authentication**: [Auth provider, SSO, etc.]
- **Payment**: [Payment processor]
- **Monitoring**: [Observability tools]

### Data Flow

1. User action in frontend
2. API request to backend
3. Business logic processing
4. Database query/update
5. Response returned to frontend
6. UI update

---

## 2. Technology Stack

### Languages

| Component | Language | Version | Rationale |
|-----------|----------|---------|-----------|
| Frontend  | TypeScript | 5.x | Type safety, better DX |
| Backend   | Node.js | 20 LTS | Event-driven, JS everywhere |
| Scripts   | Python | 3.11+ | Data processing, automation |

### Frameworks & Libraries

**Frontend**:
- **React** 18.x - Component-based UI, large ecosystem
- **Next.js** 14.x - SSR, routing, API routes
- **TailwindCSS** 3.x - Utility-first styling
- **React Query** 5.x - Server state management
- **Zod** 3.x - Runtime validation

**Backend**:
- **Express.js** 4.x - Minimalist web framework
- **Prisma** 5.x - Type-safe ORM
- **Passport.js** - Authentication middleware
- **Joi** - Schema validation

**Testing**:
- **Vitest** - Unit testing (frontend)
- **Jest** - Unit testing (backend)
- **Playwright** - E2E testing
- **SuperTest** - API testing

**DevOps**:
- **Docker** - Containerization
- **GitHub Actions** - CI/CD
- **Terraform** - Infrastructure as code

### Databases & Storage

| Type | Technology | Version | Use Case |
|------|------------|---------|----------|
| Primary | PostgreSQL | 15.x | Relational data, ACID |
| Cache | Redis | 7.x | Session, rate limiting |
| Object Storage | AWS S3 | - | File uploads, assets |

### Third-Party Services

- **Auth**: Auth0 (or Clerk, Firebase Auth)
- **Email**: SendGrid
- **Monitoring**: Sentry (errors), Datadog (metrics)
- **Analytics**: PostHog
- **Search**: Elasticsearch (if needed)

### Alternatives Considered

| Decision | Chosen | Rejected | Reason |
|----------|--------|----------|--------|
| Frontend Framework | React | Vue, Svelte | Team expertise, ecosystem |
| Backend Runtime | Node.js | Go, Python | JS everywhere, async I/O |
| Database | PostgreSQL | MySQL, MongoDB | Advanced features, JSON support |
| ORM | Prisma | TypeORM, Sequelize | Type safety, migrations |

---

## 3. Architecture Patterns

### Primary Pattern: [Layered/Microservices/Event-Driven/etc.]

**Description**: [Explain the chosen pattern]

**Benefits**:
- [Benefit 1]
- [Benefit 2]
- [Benefit 3]

**Trade-offs**:
- [Trade-off 1]
- [Trade-off 2]

### Component Organization

```
src/
├── api/              # HTTP layer (routes, controllers)
│   ├── routes/       # Route definitions
│   ├── controllers/  # Request handlers
│   └── middleware/   # Express middleware
├── services/         # Business logic layer
│   ├── auth/         # Authentication service
│   ├── users/        # User service
│   └── ...           # Domain services
├── data/             # Data access layer
│   ├── repositories/ # Data access objects
│   ├── models/       # Data models
│   └── migrations/   # Database migrations
├── lib/              # Shared utilities
│   ├── validation/   # Input validation
│   ├── errors/       # Error handling
│   └── logger/       # Logging
└── config/           # Configuration
```

### Communication Patterns

**Synchronous**:
- REST API calls (frontend ↔ backend)
- Database queries (backend ↔ database)

**Asynchronous**:
- Background jobs (email sending, data processing)
- Event-driven updates (webhooks, real-time features)

### Separation of Concerns

**API Layer** (routes, controllers):
- Handles HTTP request/response
- Input validation
- Authentication/authorization checks
- Calls service layer

**Service Layer** (business logic):
- Domain logic implementation
- Transaction management
- Orchestrates multiple data operations
- No HTTP knowledge

**Data Layer** (repositories, models):
- Database queries
- Data mapping
- No business logic

---

## 4. API Conventions

### REST Standards

**Base URL**: `/api/v1`

**Versioning**: URI versioning (`/api/v1`, `/api/v2`)

**HTTP Methods**:
- `GET` - Read resources (idempotent)
- `POST` - Create resources
- `PUT` - Replace resources (idempotent)
- `PATCH` - Partial update
- `DELETE` - Remove resources (idempotent)

**Resource Naming**:
- Use plural nouns: `/users`, `/posts`, `/comments`
- Kebab-case for multi-word: `/user-profiles`
- Nested resources: `/users/123/posts`

### Request/Response Format

**Request Headers**:
```
Content-Type: application/json
Authorization: Bearer <token>
Accept: application/json
```

**Request Body** (POST/PUT/PATCH):
```json
{
  "data": {
    "field1": "value1",
    "field2": "value2"
  }
}
```

**Success Response** (200 OK):
```json
{
  "data": {
    "id": "123",
    "field1": "value1",
    "field2": "value2"
  },
  "meta": {
    "timestamp": "2025-10-31T12:00:00Z"
  }
}
```

**List Response** (200 OK):
```json
{
  "data": [
    { "id": "1", "name": "Item 1" },
    { "id": "2", "name": "Item 2" }
  ],
  "meta": {
    "page": 1,
    "perPage": 20,
    "total": 45,
    "totalPages": 3
  }
}
```

**Error Response** (4xx/5xx):
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

### Status Codes

| Code | Meaning | Use Case |
|------|---------|----------|
| 200 | OK | Successful GET, PUT, PATCH, DELETE |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE with no body |
| 400 | Bad Request | Invalid input, validation error |
| 401 | Unauthorized | Missing or invalid auth token |
| 403 | Forbidden | Valid auth, insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Resource conflict (duplicate) |
| 422 | Unprocessable Entity | Semantic validation error |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Unexpected server error |
| 503 | Service Unavailable | Temporary unavailability |

### Pagination

**Query Parameters**:
```
GET /api/v1/users?page=1&perPage=20
```

**Response Meta**:
```json
{
  "data": [...],
  "meta": {
    "page": 1,
    "perPage": 20,
    "total": 150,
    "totalPages": 8,
    "hasNextPage": true,
    "hasPrevPage": false
  }
}
```

### Filtering & Sorting

**Filtering**:
```
GET /api/v1/users?status=active&role=admin
```

**Sorting**:
```
GET /api/v1/users?sort=createdAt:desc,name:asc
```

### Authentication

**Method**: Bearer Token (JWT)

**Header**:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Token Payload**:
```json
{
  "sub": "user-id-123",
  "email": "user@example.com",
  "role": "user",
  "iat": 1234567890,
  "exp": 1234568790
}
```

**Token Expiry**: 15 minutes (access token), 7 days (refresh token)

### Rate Limiting

**Limits**:
- Authenticated: 1000 requests/hour
- Unauthenticated: 100 requests/hour

**Headers**:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1234567890
```

---

## 5. Data Model Principles

### Database Choice: PostgreSQL

**Rationale**:
- ACID compliance for data integrity
- Rich data types (JSON, arrays, etc.)
- Advanced indexing (B-tree, GiST, GIN)
- Mature ecosystem and tooling
- Horizontal scaling with read replicas

### Schema Design

**Normalization**: 3NF for core entities, denormalization for performance-critical queries

**Primary Keys**: UUID v4 for distributed systems

**Timestamps**: Always include `created_at`, `updated_at`

**Soft Deletes**: Use `deleted_at` for important entities

**Example Schema**:
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  role VARCHAR(50) DEFAULT 'user',
  metadata JSONB,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  deleted_at TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NULL;
```

### Data Access Patterns

**ORM**: Prisma for type-safe queries

**Query Optimization**:
- Use indexes for frequent queries
- Avoid N+1 queries (use joins or dataloader)
- Paginate large result sets
- Use database functions for aggregations

**Transactions**:
- Use for multi-step operations
- Keep transactions short
- Retry on serialization failures

**Example Transaction**:
```typescript
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: userData });
  await tx.profile.create({ data: { userId: user.id, ...profileData } });
  return user;
});
```

### Caching Strategy

**Cache Layers**:
1. **Application Cache** (in-memory): Hot data, 5-minute TTL
2. **Redis Cache**: Session data, user preferences, 1-hour TTL
3. **CDN Cache**: Static assets, API responses (where appropriate)

**Cache Invalidation**:
- Time-based (TTL)
- Event-based (on update/delete)
- Explicit (cache.del())

**Cache-Aside Pattern**:
```typescript
async function getUser(id: string) {
  // Try cache first
  const cached = await redis.get(`user:${id}`);
  if (cached) return JSON.parse(cached);

  // Fetch from database
  const user = await db.user.findUnique({ where: { id } });

  // Store in cache
  await redis.setex(`user:${id}`, 3600, JSON.stringify(user));

  return user;
}
```

### Migrations

**Tool**: Prisma Migrate

**Process**:
1. Define schema in `schema.prisma`
2. Generate migration: `prisma migrate dev --name description`
3. Review generated SQL
4. Apply to production: `prisma migrate deploy`

**Best Practices**:
- Never edit migrations after applied
- Always backup before production migrations
- Test migrations on staging first
- Support rollback strategy

---

## 6. Security & Compliance

### Authentication

**Method**: OAuth 2.0 + JWT

**Flow**: Authorization Code Flow with PKCE

**Provider**: Auth0 (or Clerk, Firebase Auth)

**Token Storage**:
- Access token: Memory (not localStorage)
- Refresh token: Secure, httpOnly cookie

### Authorization

**Model**: Role-Based Access Control (RBAC)

**Roles**:
- `admin` - Full access
- `user` - Standard user access
- `guest` - Limited read-only access

**Permissions**:
- Defined per endpoint
- Checked in middleware
- Principle of least privilege

**Example Middleware**:
```typescript
function requireRole(role: string) {
  return (req, res, next) => {
    if (req.user.role !== role) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
}
```

### Data Encryption

**At Rest**:
- Database: AES-256 encryption (managed by cloud provider)
- Sensitive fields: Application-level encryption (bcrypt for passwords)
- Object storage: Server-side encryption (SSE-S3)

**In Transit**:
- TLS 1.3 for all connections
- Certificate pinning for mobile apps
- HSTS headers enabled

### Input Validation

**All Inputs**:
- Validate type, format, range
- Sanitize for XSS prevention
- Use schema validation (Zod, Joi)

**Example**:
```typescript
const userSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).regex(/[A-Z]/).regex(/[0-9]/),
  name: z.string().max(255)
});
```

### Security Headers

**Required Headers**:
```
Content-Security-Policy: default-src 'self'
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
Strict-Transport-Security: max-age=31536000; includeSubDomains
Referrer-Policy: no-referrer
Permissions-Policy: geolocation=(), microphone=()
```

### Compliance Requirements

**[GDPR/HIPAA/SOC2/etc.]**: [Applicable compliance standards]

**Data Retention**: [Policy details]

**Right to Delete**: [Implementation approach]

**Audit Logging**: [What's logged, where, retention]

---

## 7. Development Standards

### Code Style

**Linting**: ESLint with Airbnb config (customized)

**Formatting**: Prettier (2-space indent, single quotes)

**Type Checking**: TypeScript strict mode

**Example .eslintrc.js**:
```javascript
module.exports = {
  extends: ['airbnb-typescript', 'prettier'],
  rules: {
    'no-console': 'warn',
    'import/prefer-default-export': 'off',
    '@typescript-eslint/explicit-function-return-type': 'warn'
  }
};
```

### Testing Requirements

**Unit Tests**:
- Coverage: Minimum 80%
- Tool: Jest/Vitest
- Run: On every commit (pre-commit hook)

**Integration Tests**:
- Coverage: All API endpoints
- Tool: SuperTest + Jest
- Run: On PR

**E2E Tests**:
- Coverage: Critical user flows
- Tool: Playwright
- Run: On PR, nightly

**Example Test**:
```typescript
describe('User API', () => {
  it('should create a user', async () => {
    const response = await request(app)
      .post('/api/v1/users')
      .send({ email: 'test@example.com', name: 'Test' })
      .expect(201);

    expect(response.body.data).toHaveProperty('id');
    expect(response.body.data.email).toBe('test@example.com');
  });
});
```

### Git Workflow

**Branching Strategy**: GitHub Flow (simplified Git Flow)

**Branch Naming**:
- `main` - Production-ready code
- `feat/description` - New features
- `fix/description` - Bug fixes
- `chore/description` - Maintenance

**Commit Messages**: Conventional Commits

**Example**:
```
feat(auth): add password reset functionality

- Implement password reset email flow
- Add reset token generation and validation
- Create password reset form component

Closes #123
```

**Pull Request Process**:
1. Create feature branch from `main`
2. Commit changes with conventional commits
3. Push and open PR
4. Address review comments
5. Merge to `main` (squash merge)
6. Delete feature branch

### CI/CD Pipeline

**On Push**:
- Lint and format check
- Type checking
- Unit tests
- Build verification

**On PR**:
- All of above
- Integration tests
- E2E tests (if critical path)
- Security scan (Snyk, Dependabot)

**On Merge to Main**:
- All tests
- Build production assets
- Deploy to staging
- Smoke tests
- (Manual) Deploy to production

---

## 8. Deployment Architecture

### Infrastructure

**Cloud Provider**: AWS (or GCP, Azure)

**Services Used**:
- **Compute**: ECS Fargate (containers)
- **Database**: RDS PostgreSQL (multi-AZ)
- **Cache**: ElastiCache Redis
- **Storage**: S3
- **CDN**: CloudFront
- **Monitoring**: CloudWatch, Sentry, Datadog

**Infrastructure as Code**: Terraform

### Environments

| Environment | Purpose | URL | Database | Resources |
|-------------|---------|-----|----------|-----------|
| Development | Local dev | localhost:3000 | Local PostgreSQL | Minimal |
| Staging | Pre-prod testing | staging.app.com | RDS (small) | Medium |
| Production | Live users | app.com | RDS (multi-AZ) | Full |

### Container Strategy

**Docker Images**:
- Base: `node:20-alpine`
- Multi-stage builds for optimization
- Layer caching for fast builds

**Example Dockerfile**:
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### Deployment Process

**Staging**:
1. Merge to `main`
2. CI builds Docker image
3. Push to ECR
4. Deploy to ECS staging
5. Run smoke tests
6. Notify team in Slack

**Production**:
1. Tag release in Git
2. Manually trigger production deploy
3. Blue-green deployment
4. Health checks pass
5. Switch traffic
6. Monitor for errors
7. Rollback if needed

### Monitoring & Observability

**Logs**:
- Structured JSON logging
- Centralized in CloudWatch
- Retention: 30 days

**Metrics**:
- Request rate, error rate, latency (RED)
- CPU, memory, disk (USE)
- Custom business metrics

**Alerts**:
- Error rate > 1%
- Latency p95 > 500ms
- CPU > 80% sustained
- Failed deployments

**APM**: Datadog (or New Relic)

### Scaling Strategy

**Horizontal Scaling**:
- Auto-scaling based on CPU/memory
- Min: 2 instances (HA)
- Max: 10 instances (cost control)

**Vertical Scaling**:
- Database: Upsize instance type as needed
- Cache: Larger ElastiCache nodes

**Database Scaling**:
- Read replicas for read-heavy workloads
- Connection pooling (PgBouncer)
- Sharding if data grows beyond single instance

---

## ADR Template

Use this template for all architecture decision records:

```markdown
## ADR-[NUMBER]: [DECISION TITLE]

**Date**: YYYY-MM-DD
**Status**: [Proposed/Accepted/Superseded/Rejected]
**Context**: [Feature/phase that prompted this decision]
**Deciders**: [Who made this decision]

### Decision

[What is being decided - one clear statement]

### Rationale

[Why this decision was made - list of reasons]

**Benefits**:
- [Benefit 1]
- [Benefit 2]
- [Benefit 3]

**Trade-offs**:
- [Trade-off 1]
- [Trade-off 2]

### Consequences

**Positive**:
- [Positive consequence 1]
- [Positive consequence 2]

**Negative**:
- [Negative consequence 1]
- [Negative consequence 2]

**Alternatives Considered**:
- [Alternative 1] - Rejected because [reason]
- [Alternative 2] - Rejected because [reason]

### Implementation Notes

[Any specific implementation details or follow-up actions]

---
```

## Brownfield Analysis Script

When analyzing existing codebases, follow this pattern:

```bash
# 1. Identify project type
if [ -f "package.json" ]; then
  echo "Node.js project detected"
  PACKAGE_MANAGER=$([ -f "package-lock.json" ] && echo "npm" || echo "yarn")
  FRAMEWORK=$(grep -E "\"(react|vue|angular|svelte|next)\":" package.json | head -1)
fi

if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  echo "Python project detected"
  FRAMEWORK=$(grep -E "(django|flask|fastapi)" requirements.txt 2>/dev/null)
fi

# 2. Analyze structure
find . -name "*.js" -o -name "*.ts" | head -20  # Sample files
ls -la src/ 2>/dev/null || ls -la app/ 2>/dev/null  # Common directories

# 3. Extract patterns
grep -r "app.get\|app.post" --include="*.js" --include="*.ts" | wc -l  # Express routes
grep -r "@app.route" --include="*.py" | wc -l  # Flask routes
grep -r "class.*View" --include="*.py" | wc -l  # Django views

# 4. Database detection
grep -E "(postgres|mysql|mongodb|redis)" package.json requirements.txt docker-compose.yml 2>/dev/null

# 5. Check for tests
[ -d "tests" ] || [ -d "test" ] || [ -d "__tests__" ] && echo "Tests found"

# 6. Check for Docker
[ -f "Dockerfile" ] && echo "Dockerized"
[ -f "docker-compose.yml" ] && echo "Docker Compose configured"
```

## Token Budget

**SKILL.md**: ~1,450 tokens (target: <1,500)
**EXAMPLES.md**: ~2,400 tokens
**REFERENCE.md**: ~4,800 tokens (this file)

**Total**: ~8,650 tokens

**Progressive Disclosure**:
- Level 1: SKILL.md always loaded (~1,450 tokens)
- Level 2: EXAMPLES.md loaded on "show examples" (~2,400 tokens)
- Level 3: REFERENCE.md loaded on "show reference" or specific queries (~4,800 tokens)

---

**Last Updated**: 2025-10-31
**Maintained By**: Spec plugin team
**Related Skills**: spec:init, spec:generate, spec:discover
