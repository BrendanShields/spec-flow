# spec:blueprint - Examples

Complete scenarios demonstrating architecture blueprint creation for different project types.

---

## Example 1: Greenfield SaaS Application

**Context**: Starting a new multi-tenant SaaS product with a team of 5 engineers. Need to define architecture before writing any code.

**User Request**:
```
"Create an architecture blueprint for our new project management SaaS"
```

**Skill Execution**:

### Step 1: Initial Questions

The skill uses AskUserQuestion to gather requirements:

```
Question 1: What is the primary technology stack preference?
Options:
  - Node.js + TypeScript (Modern JavaScript ecosystem)
  - Python + Django/FastAPI (Rapid development, mature ecosystem)
  - Ruby on Rails (Convention over configuration)
  - Java + Spring Boot (Enterprise-grade, type-safe)

User Selection: Node.js + TypeScript

Question 2: What database architecture do you need?
Options:
  - SQL (PostgreSQL/MySQL) - Relational, ACID compliance
  - NoSQL (MongoDB/DynamoDB) - Flexible schema, horizontal scaling
  - Hybrid (SQL + Redis) - Relational + caching
  - Multi-model - Different databases for different needs

User Selection: Hybrid (SQL + Redis)

Question 3: What deployment strategy?
Options:
  - Cloud-native (AWS/GCP/Azure with managed services)
  - Container orchestration (Kubernetes/ECS)
  - Serverless (Lambda/Cloud Functions)
  - Traditional VPS (DigitalOcean/Heroku)

User Selection: Container orchestration (Kubernetes/ECS)

Question 4: Required compliance/security level?
Options:
  - Standard (HTTPS, password hashing, basic security)
  - Enhanced (2FA, audit logging, encryption at rest)
  - Compliance (SOC 2, GDPR, HIPAA requirements)
  - High-security (Zero-trust, end-to-end encryption)

User Selection: Enhanced (2FA, audit logging, encryption at rest)
```

### Step 2: Architecture Definition

The skill creates `.spec/architecture-blueprint.md`:

```markdown
# Architecture Blueprint

**Project**: Project Management SaaS
**Type**: Greenfield
**Created**: 2025-10-31
**Status**: Active

---

## 1. System Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Client Layer                        │
│  React SPA + Mobile Apps (React Native)                 │
└────────────────┬────────────────────────────────────────┘
                 │ HTTPS/WSS
┌────────────────▼────────────────────────────────────────┐
│                   API Gateway Layer                      │
│  NGINX + Load Balancer + Rate Limiting                  │
└────────────────┬────────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────────┐
│                 Application Layer                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │   Auth   │  │ Projects │  │   Tasks  │              │
│  │ Service  │  │ Service  │  │ Service  │              │
│  └──────────┘  └──────────┘  └──────────┘              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │  Users   │  │ Comments │  │  Notify  │              │
│  │ Service  │  │ Service  │  │ Service  │              │
│  └──────────┘  └──────────┘  └──────────┘              │
└────────────────┬────────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────────┐
│                    Data Layer                            │
│  PostgreSQL (Primary) + Redis (Cache/Sessions)          │
│  S3 (File Storage)                                       │
└─────────────────────────────────────────────────────────┘
```

### Key Components

**Frontend**:
- React SPA with TypeScript
- React Native for iOS/Android
- Real-time updates via WebSocket

**Backend**:
- Node.js microservices (TypeScript)
- RESTful APIs + GraphQL gateway
- WebSocket server for real-time features

**Data Storage**:
- PostgreSQL for relational data
- Redis for caching and sessions
- S3 for file uploads (documents, attachments)

**Infrastructure**:
- AWS ECS for container orchestration
- CloudFront CDN for static assets
- Route53 for DNS management

---

## 2. Technology Stack

### Backend

**Runtime**: Node.js 20 LTS
- **Why**: Non-blocking I/O for real-time features, large ecosystem, TypeScript support
- **Alternatives**: Python (considered, slower for real-time), Java (too heavyweight)

**Language**: TypeScript 5.x
- **Why**: Type safety, better IDE support, scales with team size
- **Alternatives**: JavaScript (considered, lacks type safety)

**Framework**: Express.js 4.x + NestJS for services
- **Why**: Flexible, well-documented, mature ecosystem
- **Alternatives**: Fastify (considered, less mature), Koa (smaller community)

**ORM**: Prisma 5.x
- **Why**: Type-safe queries, migrations, multi-database support
- **Alternatives**: TypeORM (less type-safe), Sequelize (dated API)

**Validation**: Zod
- **Why**: TypeScript-first, runtime validation matches compile-time types
- **Alternatives**: Joi (no TS integration), class-validator (decorator-heavy)

### Frontend

**Framework**: React 18.x
- **Why**: Component model, hooks, large ecosystem, hiring pool
- **Alternatives**: Vue (smaller ecosystem), Angular (too opinionated)

**State Management**: Zustand + React Query
- **Why**: Simple API, automatic caching, optimistic updates
- **Alternatives**: Redux (too verbose), MobX (less popular)

**Build Tool**: Vite
- **Why**: Fast HMR, modern ESM, optimized builds
- **Alternatives**: Create React App (outdated), Next.js (over-engineered for SPA)

**UI Library**: Material-UI (MUI) v5
- **Why**: Comprehensive components, accessibility, customizable
- **Alternatives**: Ant Design (less flexible), Chakra UI (smaller)

### Data Layer

**Primary Database**: PostgreSQL 15
- **Why**: ACID compliance, JSON support, excellent performance, row-level security
- **Alternatives**: MySQL (weaker JSON support), MongoDB (no transactions)

**Cache/Session Store**: Redis 7.x
- **Why**: In-memory performance, pub/sub for real-time, session management
- **Alternatives**: Memcached (no persistence), DynamoDB (higher cost)

**Object Storage**: AWS S3
- **Why**: Scalable, durable, CDN integration, cost-effective
- **Alternatives**: Cloudinary (limited storage), self-hosted (operational overhead)

### Infrastructure

**Container Orchestration**: AWS ECS with Fargate
- **Why**: Serverless containers, no EC2 management, auto-scaling
- **Alternatives**: Kubernetes (too complex for team size), EC2 (manual scaling)

**CI/CD**: GitHub Actions
- **Why**: Integrated with repo, generous free tier, marketplace
- **Alternatives**: CircleCI (cost), Jenkins (maintenance overhead)

**Monitoring**: Datadog
- **Why**: Unified logs/metrics/traces, APM, alerting
- **Alternatives**: CloudWatch (limited features), Prometheus (self-hosted)

---

## 3. Architecture Patterns

### Overall Pattern: Modular Monolith (transitioning to Microservices)

**Current State**: Modular monolith with clear service boundaries
- Separate modules: Auth, Projects, Tasks, Users, Comments, Notifications
- Each module owns its data models and business logic
- Shared infrastructure (database, caching) but isolated schemas

**Future State**: Microservices when scale requires
- Extract high-traffic modules (Auth, Projects) to separate services
- Implement API gateway for routing
- Event-driven communication between services

### Layered Architecture (per module)

```
┌─────────────────────────────────────┐
│        Controllers Layer            │  HTTP/GraphQL endpoints
│  (Route handlers, input validation) │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Service Layer               │  Business logic
│  (Use cases, business rules)        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Repository Layer               │  Data access
│  (Database queries, caching)        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│          Data Layer                 │  PostgreSQL + Redis
└─────────────────────────────────────┘
```

### Key Patterns

**Dependency Injection**: Use NestJS IoC container for service dependencies
**Repository Pattern**: Abstract database access behind repositories
**DTO Pattern**: Separate data transfer objects from domain models
**Factory Pattern**: For complex object creation (notifications, reports)
**Observer Pattern**: For event-driven features (real-time updates)
**Strategy Pattern**: For pluggable features (notification channels, file storage)

---

## 4. API Conventions

### REST API Standards

**Base URL**: `https://api.projectmanager.com/v1`

**Versioning**: URL-based (`/v1`, `/v2`)
- Major version in URL
- Deprecation notices 6 months before removal

**Resource Naming**:
- Plural nouns: `/projects`, `/tasks`, `/users`
- Nested resources: `/projects/:id/tasks`
- Actions as verbs: `/projects/:id/archive`

**HTTP Methods**:
- `GET` - Retrieve resource(s)
- `POST` - Create new resource
- `PUT` - Replace entire resource
- `PATCH` - Partial update
- `DELETE` - Remove resource

**Request Format**:
```json
{
  "data": {
    "type": "project",
    "attributes": {
      "name": "New Project",
      "description": "Project description"
    },
    "relationships": {
      "owner": { "id": "user-123" }
    }
  }
}
```

**Response Format**:
```json
{
  "data": {
    "id": "proj-456",
    "type": "project",
    "attributes": { ... },
    "relationships": { ... }
  },
  "meta": {
    "requestId": "req-789",
    "timestamp": "2025-10-31T12:00:00Z"
  }
}
```

**Error Format**:
```json
{
  "errors": [
    {
      "status": "400",
      "code": "VALIDATION_ERROR",
      "title": "Invalid project name",
      "detail": "Name must be between 3-100 characters",
      "source": { "pointer": "/data/attributes/name" }
    }
  ]
}
```

**Pagination**:
```
GET /projects?page[number]=2&page[size]=20
```

**Filtering**:
```
GET /projects?filter[status]=active&filter[owner]=user-123
```

**Sorting**:
```
GET /projects?sort=-createdAt,name
```

**Field Selection**:
```
GET /projects?fields[project]=name,description
```

### Authentication

**Method**: JWT (JSON Web Tokens)
- Access token: 15 minutes expiry
- Refresh token: 7 days expiry
- Stored in httpOnly cookies

**Headers**:
```
Authorization: Bearer <access-token>
X-Request-ID: <unique-request-id>
```

**Token Refresh Flow**:
1. Access token expires
2. Client sends refresh token to `/auth/refresh`
3. Server issues new access + refresh tokens
4. Client retries original request

### Rate Limiting

**Limits**:
- Authenticated: 1000 requests/hour
- Unauthenticated: 100 requests/hour
- GraphQL: 5000 query cost/hour

**Headers**:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 847
X-RateLimit-Reset: 1698765432
```

---

## 5. Data Model Principles

### Database Design

**Multi-Tenancy Strategy**: Row-level security with tenant_id
- Every table has `tenant_id` foreign key
- Database policies enforce tenant isolation
- Indexes include tenant_id for performance

**Naming Conventions**:
- Tables: snake_case plural (`projects`, `task_assignments`)
- Columns: snake_case (`created_at`, `owner_id`)
- Primary keys: `id` (UUID v4)
- Foreign keys: `{table}_id` (`project_id`, `user_id`)

**Timestamps**: Every table includes
- `created_at` (timestamptz, default NOW())
- `updated_at` (timestamptz, updated via trigger)
- `deleted_at` (timestamptz, nullable - soft deletes)

**Schema Organization**:
- `public` schema: Core tables (users, tenants)
- `projects` schema: Project-related tables
- `auth` schema: Authentication tables

### Example Schema

```sql
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  plan VARCHAR(50) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  status VARCHAR(50) DEFAULT 'active',
  owner_id UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,

  CONSTRAINT valid_status CHECK (status IN ('active', 'archived', 'completed'))
);

CREATE INDEX idx_projects_tenant ON projects(tenant_id, deleted_at);
CREATE INDEX idx_projects_owner ON projects(owner_id);
```

### Caching Strategy

**Redis Usage**:
- **Sessions**: `session:{userId}` (TTL: 7 days)
- **User profiles**: `user:{userId}` (TTL: 1 hour)
- **Project lists**: `projects:tenant:{tenantId}` (TTL: 5 minutes)
- **Rate limits**: `ratelimit:{userId}:{endpoint}` (TTL: 1 hour)

**Cache Invalidation**:
- Write-through: Update cache on write
- TTL-based: Short expiry for frequently changing data
- Event-based: Invalidate on relevant events

---

## 6. Security & Compliance

### Authentication & Authorization

**Authentication**: JWT with refresh tokens
- Password hashing: bcrypt (cost factor 12)
- 2FA: TOTP (Google Authenticator, Authy)
- Session management: Redis-backed, httpOnly cookies

**Authorization**: Role-Based Access Control (RBAC)
- Roles: Admin, Manager, Member, Guest
- Permissions: project.create, task.update, user.delete
- Tenant-level: Global admin vs tenant admin

**Password Policy**:
- Minimum 12 characters
- Requires: uppercase, lowercase, number, special character
- Password history: Last 5 passwords
- Expiry: 90 days for admin accounts

### Data Protection

**Encryption at Rest**:
- Database: AWS RDS encryption (AES-256)
- S3: Server-side encryption (SSE-S3)
- Backups: Encrypted with KMS

**Encryption in Transit**:
- HTTPS only (TLS 1.3)
- HSTS headers enabled
- Certificate pinning for mobile apps

**Sensitive Data Handling**:
- PII fields: Encrypted at application level
- Audit logging: All access to sensitive data
- Data retention: 90-day soft delete before purge

### Security Headers

```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
```

### Input Validation

**Principles**:
- Validate all inputs (never trust client)
- Whitelist approach (allow known-good)
- Sanitize outputs (prevent XSS)
- Parameterized queries (prevent SQL injection)

**Validation Layers**:
1. Schema validation (Zod at controller)
2. Business logic validation (service layer)
3. Database constraints (final safety net)

### Audit Logging

**Logged Events**:
- Authentication (login, logout, failed attempts)
- Authorization (permission denied)
- Data access (view/edit sensitive data)
- Configuration changes
- Admin actions

**Log Format**:
```json
{
  "timestamp": "2025-10-31T12:00:00Z",
  "event": "project.update",
  "actor": { "id": "user-123", "email": "user@example.com" },
  "resource": { "type": "project", "id": "proj-456" },
  "changes": { "status": { "from": "active", "to": "archived" } },
  "ip": "192.168.1.1",
  "userAgent": "Mozilla/5.0...",
  "requestId": "req-789"
}
```

### Compliance

**GDPR**:
- Data export: `/api/v1/users/me/export`
- Right to be forgotten: `/api/v1/users/me/delete`
- Consent management: Cookie consent banner
- Data processing agreement: In Terms of Service

**SOC 2 (planned)**:
- Security controls documented
- Access reviews quarterly
- Vendor risk assessments
- Incident response plan

---

## 7. Development Standards

### Code Style

**Linting**: ESLint with Airbnb config
```json
{
  "extends": ["airbnb-typescript", "plugin:@typescript-eslint/recommended"],
  "rules": {
    "no-console": "error",
    "max-len": ["error", { "code": 100 }]
  }
}
```

**Formatting**: Prettier
```json
{
  "singleQuote": true,
  "trailingComma": "es5",
  "printWidth": 100,
  "tabWidth": 2
}
```

**Naming Conventions**:
- Files: kebab-case (`user-service.ts`, `project-controller.ts`)
- Classes: PascalCase (`UserService`, `ProjectController`)
- Functions/Variables: camelCase (`createProject`, `userId`)
- Constants: UPPER_SNAKE_CASE (`MAX_UPLOAD_SIZE`)
- Interfaces: PascalCase with `I` prefix (`IUserRepository`)

### Testing Requirements

**Unit Tests**: 80% code coverage minimum
- Framework: Jest
- Mocking: jest.mock()
- Location: `*.spec.ts` alongside source

**Integration Tests**: Critical paths covered
- Framework: Supertest
- Database: Test database with migrations
- Location: `tests/integration/`

**E2E Tests**: Key user flows
- Framework: Playwright
- Environment: Staging environment
- Location: `tests/e2e/`

**Test Structure**:
```typescript
describe('ProjectService', () => {
  describe('createProject', () => {
    it('should create project with valid data', async () => {
      // Arrange
      const projectData = { name: 'Test Project' };

      // Act
      const result = await service.createProject(projectData);

      // Assert
      expect(result.name).toBe('Test Project');
    });
  });
});
```

### Git Workflow

**Branching Strategy**: Git Flow
- `main`: Production-ready code
- `develop`: Integration branch
- `feature/*`: New features
- `hotfix/*`: Production fixes
- `release/*`: Release preparation

**Commit Messages**: Conventional Commits
```
feat(auth): add 2FA support
fix(projects): resolve duplicate project names
docs(readme): update installation steps
test(tasks): add unit tests for task service
```

**Pull Requests**:
- Required reviewers: 2
- Status checks must pass (lint, test, build)
- Squash merge to main
- Delete branch after merge

### CI/CD Pipeline

**GitHub Actions Workflow**:
```yaml
1. Lint: ESLint + Prettier check
2. Test: Unit + Integration tests
3. Build: TypeScript compilation
4. Security: npm audit, Snyk scan
5. Deploy to staging: Auto-deploy on develop
6. E2E tests: Run on staging
7. Deploy to production: Manual approval
```

**Deployment Stages**:
- **Development**: Auto-deploy on push to develop
- **Staging**: Auto-deploy on PR to main
- **Production**: Manual approval + deployment

---

## 8. Deployment Architecture

### Infrastructure

**Cloud Provider**: AWS
- **Compute**: ECS with Fargate (serverless containers)
- **Database**: RDS PostgreSQL (Multi-AZ)
- **Cache**: ElastiCache Redis (cluster mode)
- **Storage**: S3 (Standard tier)
- **CDN**: CloudFront
- **DNS**: Route53

**Network Architecture**:
```
┌─────────────────────────────────────────┐
│           CloudFront (CDN)              │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│     Application Load Balancer           │
│  (public subnet, SSL termination)       │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│       ECS Fargate Tasks                 │
│  (private subnet, auto-scaling)         │
└────┬─────────────────────────┬──────────┘
     │                         │
┌────▼─────────┐     ┌─────────▼──────────┐
│ RDS PostgreSQL│     │ElastiCache Redis   │
│ (Multi-AZ)    │     │(cluster mode)      │
└───────────────┘     └────────────────────┘
```

### Environments

**Development**:
- Single ECS task
- db.t3.micro RDS instance
- cache.t3.micro Redis node
- Auto-deploy on push to develop

**Staging**:
- 2 ECS tasks (load balanced)
- db.t3.small RDS instance
- cache.t3.small Redis cluster
- Production-like data (anonymized)

**Production**:
- 4+ ECS tasks (auto-scaling 4-20)
- db.r5.xlarge RDS instance (Multi-AZ)
- cache.r5.large Redis cluster (3 nodes)
- Blue-green deployment strategy

### Monitoring & Observability

**Metrics** (Datadog):
- Application: Request rate, latency, error rate
- Infrastructure: CPU, memory, disk, network
- Business: Sign-ups, projects created, active users

**Logging** (CloudWatch + Datadog):
- Application logs: Structured JSON
- Access logs: ALB logs to S3
- Audit logs: Dedicated log stream
- Retention: 30 days hot, 1 year archive

**Tracing** (Datadog APM):
- Distributed tracing across services
- Database query performance
- External API calls

**Alerts**:
- P1: Error rate >1%, Response time >2s, CPU >80%
- P2: Disk >70%, Memory >75%
- P3: SSL expiry in 30 days

### Scaling Strategy

**Horizontal Scaling**:
- ECS tasks: Auto-scale on CPU/memory (target: 70%)
- Database: Read replicas for read-heavy workloads
- Redis: Cluster mode for horizontal scaling

**Vertical Scaling**:
- Database: Upgrade instance class during maintenance window
- Redis: Upgrade node type with minimal downtime

**Caching Strategy**:
- CDN: Cache static assets (1 year)
- Application: Cache API responses (5 minutes)
- Database: Query result caching (Redis)

### Backup & Disaster Recovery

**Backups**:
- Database: Daily automated snapshots (30-day retention)
- S3: Versioning enabled, lifecycle policies
- Configuration: Stored in git, encrypted

**Disaster Recovery**:
- RTO (Recovery Time Objective): 4 hours
- RPO (Recovery Point Objective): 1 hour
- Multi-region failover: Planned for future

---

## ADRs (Architecture Decision Records)

See `.spec-memory/DECISIONS-LOG.md` for complete ADRs:

1. **ADR-001**: Use Node.js + TypeScript for backend
2. **ADR-002**: PostgreSQL with row-level security for multi-tenancy
3. **ADR-003**: JWT with refresh tokens for authentication
4. **ADR-004**: Redis for caching and session management
5. **ADR-005**: AWS ECS with Fargate for container orchestration
6. **ADR-006**: Modular monolith architecture (transition to microservices later)
7. **ADR-007**: GraphQL gateway for frontend (REST for service-to-service)
8. **ADR-008**: Datadog for unified observability

---

**Status**: Active
**Last Updated**: 2025-10-31
**Review Cycle**: Quarterly
**Next Review**: 2026-01-31
```

### Step 3: ADR Generation

The skill adds ADRs to `.spec-memory/DECISIONS-LOG.md`:

```markdown
## ADR-001: Use Node.js + TypeScript for backend

**Date**: 2025-10-31
**Status**: Accepted
**Context**: Choosing backend runtime and language for new SaaS application

**Decision**: Use Node.js 20 LTS with TypeScript 5.x

**Rationale**:
- Non-blocking I/O excellent for real-time features (WebSocket)
- Large ecosystem of packages (npm)
- Team has strong JavaScript/TypeScript experience
- Type safety prevents runtime errors at scale
- Excellent IDE support and developer experience

**Alternatives Considered**:
- **Python + Django/FastAPI**: Slower for real-time, GIL limitations, but excellent for data processing
- **Ruby on Rails**: Great conventions, but slower runtime, smaller ecosystem
- **Java + Spring Boot**: Enterprise-grade, but verbose, heavyweight, longer development cycles

**Consequences**:
- Positive: Fast development, real-time capabilities, good hiring pool
- Negative: Callback hell if not careful, memory leaks if not monitored
- Neutral: Need strong TypeScript discipline, async/await patterns

**Related**: ADR-006 (modular architecture)

---

## ADR-002: PostgreSQL with row-level security for multi-tenancy

**Date**: 2025-10-31
**Status**: Accepted
**Context**: Need database strategy for multi-tenant SaaS

**Decision**: Use PostgreSQL 15 with row-level security policies for tenant isolation

**Rationale**:
- ACID compliance ensures data integrity
- Row-level security (RLS) enforces tenant isolation at database level
- JSON/JSONB support for flexible data
- Excellent performance with proper indexing
- Mature ecosystem and tooling

**Alternatives Considered**:
- **Separate database per tenant**: Too many databases to manage, backup complexity
- **MongoDB**: No ACID guarantees, weak multi-tenancy story
- **MySQL**: Weaker JSON support, less robust RLS

**Consequences**:
- Positive: Strong data isolation, single database to manage, excellent tooling
- Negative: Must include tenant_id in all queries, RLS adds minor overhead
- Neutral: Need proper indexing strategy with tenant_id

**Implementation**:
```sql
CREATE POLICY tenant_isolation ON projects
  USING (tenant_id = current_setting('app.current_tenant')::uuid);
```

**Related**: ADR-004 (Redis for caching)

---

[Additional ADRs continue...]
```

### Step 4: State Update

Updates `.spec-memory/WORKFLOW-PROGRESS.md`:

```markdown
## Feature 000: Architecture Blueprint

**Status**: Completed
**Created**: 2025-10-31
**Completed**: 2025-10-31

**Specification**: Comprehensive architecture blueprint for project management SaaS
**Deliverables**:
- Architecture blueprint document (8 sections)
- 8 ADRs documenting key decisions
- Technology stack defined
- Security standards established

**Metrics**:
- Sections: 8/8 complete
- ADRs: 8 created
- Review status: Pending team review
```

### Output

```
Architecture Blueprint Created

Location: .spec/architecture-blueprint.md
Type: Greenfield
ADRs Created: 8 decisions logged

Sections:
  ✓ System Overview (Component diagram, integration points)
  ✓ Technology Stack (Node.js, TypeScript, PostgreSQL, Redis)
  ✓ Architecture Patterns (Modular monolith → Microservices)
  ✓ API Conventions (REST + GraphQL, JWT auth)
  ✓ Data Model Principles (Row-level security, multi-tenancy)
  ✓ Security & Compliance (RBAC, encryption, audit logging)
  ✓ Development Standards (ESLint, Jest, Git Flow)
  ✓ Deployment Architecture (AWS ECS, Fargate, Multi-AZ)

Key Decisions:
  • Node.js + TypeScript for development speed and real-time
  • PostgreSQL with RLS for secure multi-tenancy
  • JWT authentication with refresh tokens
  • AWS ECS with Fargate for serverless containers
  • Modular monolith (transition to microservices at scale)

Next Steps:
  1. Review blueprint with team
  2. Get approval on technology choices
  3. Run `spec:generate "User Authentication"` to begin development
  4. Reference blueprint in all feature planning
```

**Files Created**:
- `.spec/architecture-blueprint.md` (3,200 tokens)
- `.spec-memory/DECISIONS-LOG.md` (updated with 8 ADRs)
- `.spec-memory/WORKFLOW-PROGRESS.md` (Feature 000 completed)

---

## Example 2: Brownfield Django Application

**Context**: Existing Django monolith with 50,000 lines of code, 2 years old. Need to document current architecture before adding new features with Spec.

**User Request**:
```
"Extract architecture blueprint from our existing Django codebase"
```

**Skill Execution**:

### Step 1: Codebase Analysis

The skill analyzes the existing codebase:

```bash
# Discover project structure
Glob: **/*.py | wc -l
Result: 487 Python files

Glob: **/requirements*.txt
Result: requirements.txt, requirements-dev.txt

# Read dependencies
Read: requirements.txt
Result:
  Django==4.2.5
  djangorestframework==3.14.0
  celery==5.3.1
  redis==4.6.0
  psycopg2-binary==2.9.7
  gunicorn==21.2.0
  django-cors-headers==4.2.0

# Discover Django structure
Glob: **/models.py
Result: 15 model files found

Glob: **/views.py
Result: 12 view files found

Glob: **/serializers.py
Result: 8 serializer files found

# Analyze Django settings
Read: config/settings.py
Result: PostgreSQL database, Redis cache, Celery configured

# Find API patterns
Grep: @api_view --include="*.py" -r
Result: 47 API endpoints using DRF decorators

Grep: class.*ViewSet --include="*.py" -r
Result: 23 ViewSets defined

# Check for async tasks
Grep: @celery_app.task --include="*.py" -r
Result: 12 Celery tasks defined

# Analyze database structure
Bash: python manage.py showmigrations | wc -l
Result: 87 migrations

# Check deployment configuration
Read: Dockerfile
Result: Multi-stage build, gunicorn server

Read: docker-compose.yml
Result: Django, PostgreSQL, Redis, Celery worker, Celery beat
```

### Step 2: Pattern Detection

Based on analysis, the skill identifies:

**Technology Stack**:
- Backend: Django 4.2 + Django Rest Framework
- Database: PostgreSQL
- Cache: Redis
- Task Queue: Celery
- Server: Gunicorn
- Deployment: Docker containers

**Architecture Patterns**:
- MTV (Model-Template-View) pattern
- Service layer for business logic (detected in apps/*/services.py)
- Repository-like pattern with managers (custom model managers)
- RESTful API with DRF ViewSets
- Async task processing with Celery

**File Structure**:
```
project/
├── apps/
│   ├── accounts/       (User management)
│   ├── projects/       (Project CRUD)
│   ├── tasks/          (Task management)
│   └── notifications/  (Email/SMS notifications)
├── config/             (Settings, URLs)
├── static/
└── templates/
```

### Step 3: Blueprint Generation

Creates `.spec/architecture-blueprint.md` documenting current state:

```markdown
# Architecture Blueprint

**Project**: Project Management Platform (Brownfield)
**Type**: Brownfield Analysis
**Analyzed**: 2025-10-31
**Status**: Active (Existing Codebase)

---

## 1. System Overview

### Current Architecture (Discovered)

```
┌─────────────────────────────────────────┐
│         Client Applications             │
│  Web (Django Templates) + Mobile (API)  │
└──────────────┬──────────────────────────┘
               │ HTTPS
┌──────────────▼──────────────────────────┐
│        NGINX (Reverse Proxy)            │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      Django Application Server          │
│  (Gunicorn workers, 4 processes)        │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │ Apps: accounts, projects, tasks,   │ │
│  │       notifications                 │ │
│  └────────────────────────────────────┘ │
└────┬─────────────────────┬──────────────┘
     │                     │
┌────▼──────────┐    ┌────▼─────────────┐
│  PostgreSQL   │    │  Redis           │
│  (Primary DB) │    │  (Cache/Sessions)│
└───────────────┘    └──────────────────┘
                            │
                     ┌──────▼───────────┐
                     │ Celery Workers   │
                     │ (Background jobs)│
                     └──────────────────┘
```

### Key Components

**Backend**: Django 4.2 monolith
- 4 Django apps: accounts, projects, tasks, notifications
- 15 models, 87 database migrations
- 47 REST API endpoints (Django Rest Framework)
- 12 Celery background tasks

**Data Storage**:
- PostgreSQL 14 (primary database)
- Redis 7 (caching and Celery broker)

**Deployment**:
- Docker containerized (Dockerfile + docker-compose)
- Gunicorn WSGI server (4 workers)
- NGINX reverse proxy
- Deployed on AWS EC2 instances

---

## 2. Technology Stack

### Backend (Discovered)

**Framework**: Django 4.2.5
- **Current Use**: MTV pattern, ORM, admin interface, DRF for APIs
- **Strengths**: Mature, batteries-included, excellent admin
- **[TODO]**: Upgrade path to Django 5.x

**API Framework**: Django Rest Framework 3.14.0
- **Current Use**: 23 ViewSets, 47 API endpoints
- **Strengths**: Serialization, authentication, browsable API
- **[TODO]**: Add API versioning (currently unversioned)

**Task Queue**: Celery 5.3.1
- **Current Use**: 12 background tasks (email, reports, cleanup)
- **Strengths**: Reliable, supports scheduling
- **[TODO]**: Add monitoring (Flower or Celery Insights)

**Database**: PostgreSQL 14
- **Current Use**: Primary data store, 15 models
- **Strengths**: ACID, JSON support, performance
- **[TODO]**: Upgrade to PostgreSQL 15 for performance

**Cache**: Redis 7.x
- **Current Use**: Session storage, Celery broker, view caching
- **Strengths**: Fast, pub/sub support
- **[TODO]**: Add cache warming strategy

### Frontend (Discovered)

**Template Engine**: Django Templates
- **Current Use**: Server-side rendered pages
- **[TODO]**: Consider SPA migration for better UX

**Static Assets**: No build system detected
- **[TODO]**: Add Vite/Webpack for asset optimization

### Infrastructure (Discovered)

**Containerization**: Docker
- Multi-stage Dockerfile
- docker-compose for local development
- **[TODO]**: Add health checks to Dockerfile

**Web Server**: Gunicorn 21.2.0
- 4 worker processes
- **[TODO]**: Tune workers based on load

**Reverse Proxy**: NGINX (assumed from deployment)
- **[TODO]**: Document NGINX configuration

**Deployment**: AWS EC2
- **[TODO]**: Consider migrating to ECS/Fargate for better scaling

---

## 3. Architecture Patterns

### Overall Pattern: Django Monolith with App Separation

**Current Structure**:
```
Django Project
├── accounts app       (User auth, profiles)
├── projects app       (Project CRUD, permissions)
├── tasks app          (Task management, assignments)
└── notifications app  (Email/SMS via Celery)
```

**App Boundaries**:
- Each app owns its models and business logic
- Apps communicate via Python imports (direct coupling)
- **[TODO]**: Define clear app interfaces to reduce coupling

### Layered Architecture (Discovered)

**Current Implementation**:
```
┌─────────────────────────────────────┐
│        Views/ViewSets Layer         │  HTTP endpoints
│  (URL routing, DRF views)           │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Service Layer               │  Business logic
│  (apps/*/services.py - 8 files)     │  [PARTIAL]
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Model Layer (ORM)              │  Data access
│  (apps/*/models.py - 15 files)      │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│        Database (PostgreSQL)        │
└─────────────────────────────────────┘
```

**Observations**:
- Service layer partially implemented (8 of 15 models have services)
- Some business logic still in views (fat views anti-pattern)
- **[TODO]**: Extract all business logic to service layer

### Patterns Identified

**Repository-like Pattern**: Custom model managers
```python
# Example found in apps/projects/models.py
class ProjectManager(models.Manager):
    def active_for_user(self, user):
        return self.filter(owner=user, archived=False)
```

**Service Layer Pattern**: Business logic separation
```python
# Example found in apps/projects/services.py
class ProjectService:
    def create_project(self, user, data):
        # Business logic here
```

**Task Queue Pattern**: Celery for async operations
```python
# Example found in apps/notifications/tasks.py
@celery_app.task
def send_email_notification(user_id, message):
    # Email sending logic
```

**[TODO] Patterns to Implement**:
- Consistent service layer across all apps
- Event-driven communication between apps (signals or dedicated events)
- CQRS for read-heavy endpoints

---

## 4. API Conventions

### REST API (Discovered)

**Base URL**: `/api/` (no versioning detected)
- **[TODO]**: Implement API versioning (`/api/v1/`, `/api/v2/`)

**Endpoints Discovered** (47 total):
```
/api/projects/             (ProjectViewSet)
/api/projects/{id}/tasks/  (Nested tasks)
/api/tasks/                (TaskViewSet)
/api/users/                (UserViewSet)
/api/notifications/        (NotificationViewSet)
```

**HTTP Methods**: Standard REST conventions
- GET, POST, PUT, PATCH, DELETE all used correctly

**Response Format** (DRF default):
```json
{
  "id": 123,
  "name": "Project Name",
  "created_at": "2025-10-31T12:00:00Z"
}
```

**Pagination** (DRF PageNumberPagination):
```json
{
  "count": 100,
  "next": "http://api/projects/?page=2",
  "previous": null,
  "results": [...]
}
```

**Error Format** (DRF default):
```json
{
  "detail": "Not found.",
  "field": ["This field is required."]
}
```

**[TODO] API Improvements**:
- Standardize error format (current inconsistent)
- Add HATEOAS links for resource navigation
- Implement API documentation (drf-spectacular)
- Add request/response examples to docs

### Authentication (Discovered)

**Current Method**: Token Authentication (DRF)
```python
# Found in config/settings.py
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ]
}
```

**Token Management**: Simple tokens (no expiry)
- **[TODO]**: Migrate to JWT with refresh tokens
- **[TODO]**: Implement token expiry and rotation

**Authorization**: Permission classes
- IsAuthenticated, IsOwner (custom)
- **[TODO]**: Implement RBAC for fine-grained control

### Rate Limiting (Discovered)

**Current State**: Not implemented
- **[TODO]**: Add rate limiting (django-ratelimit or API gateway)
- **[TODO]**: Define limits per user tier

---

## 5. Data Model Principles

### Database Design (Discovered)

**Schema Analysis** (15 models found):

**User Management**:
- CustomUser (extends AbstractUser)
- UserProfile (one-to-one with User)

**Project Management**:
- Project (name, description, owner, created_at)
- ProjectMember (project, user, role)

**Task Management**:
- Task (project, title, description, assignee, status, priority)
- Comment (task, author, content)
- Attachment (task, file, uploaded_by)

**Notifications**:
- Notification (user, message, read, created_at)

**Naming Conventions** (Observed):
- Models: PascalCase (Project, Task)
- Fields: snake_case (created_at, owner_id)
- Tables: Django auto-generated (app_model)

**Timestamps**: Consistent pattern
```python
created_at = models.DateTimeField(auto_now_add=True)
updated_at = models.DateTimeField(auto_now=True)
```

**Soft Deletes**: Partially implemented
- Some models have `archived` boolean
- **[TODO]**: Standardize soft delete pattern across all models

### Example Schema (Projects App)

```python
class Project(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    owner = models.ForeignKey(User, on_delete=models.CASCADE)
    archived = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    objects = ProjectManager()

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['owner', 'archived']),
        ]
```

**Indexing Strategy** (Discovered):
- Primary keys (automatic)
- Foreign keys (some indexed, not all)
- **[TODO]**: Add indexes for common queries (status, created_at)
- **[TODO]**: Analyze slow queries and optimize

### Caching Strategy (Discovered)

**Redis Configuration** (Found in settings.py):
```python
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
    }
}
```

**Current Usage**:
- Session storage (django.contrib.sessions)
- View-level caching (some views use @cache_page)
- Template fragment caching (minimal usage)

**[TODO] Caching Improvements**:
- Add query result caching for expensive queries
- Implement cache invalidation strategy
- Cache user permissions for auth checks

---

## 6. Security & Compliance

### Authentication & Authorization (Discovered)

**Authentication**: Django auth + DRF tokens
- Password validation: Django defaults (8 chars minimum)
- **[TODO]**: Strengthen password requirements
- **[TODO]**: Add 2FA support

**Authorization**: Permission-based
- Django permissions (add, change, delete)
- Custom IsOwner permission for resources
- **[TODO]**: Implement RBAC with roles and permissions

**Session Security** (Found in settings.py):
```python
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
```

### Data Protection (Discovered)

**Encryption at Rest**: Not implemented at app level
- Database: Assumed encrypted by AWS RDS
- **[TODO]**: Encrypt sensitive fields (PII)

**Encryption in Transit**: HTTPS enforced
- SECURE_SSL_REDIRECT = True (in production settings)
- **[TODO]**: Enforce TLS 1.3 minimum

**Sensitive Data**:
- User emails, names stored in plain text
- **[TODO]**: Identify and encrypt PII fields
- **[TODO]**: Implement data retention policy

### Security Headers (Discovered)

**Found in middleware**:
```python
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]
```

**Settings**:
```python
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = 'DENY'
SECURE_CONTENT_TYPE_NOSNIFF = True
```

**[TODO] Security Enhancements**:
- Add Strict-Transport-Security header (HSTS)
- Implement Content-Security-Policy
- Add Referrer-Policy header

### Audit Logging (Discovered)

**Current State**: Basic Django admin logging only
- **[TODO]**: Implement comprehensive audit logging
- **[TODO]**: Log authentication events
- **[TODO]**: Log data access and modifications

### Input Validation (Discovered)

**Current Approach**: DRF serializers
- Field-level validation with serializers
- Django form validation (for admin)
- **[TODO]**: Add request payload size limits
- **[TODO]**: Implement input sanitization for XSS prevention

---

## 7. Development Standards

### Code Style (Discovered)

**Linting**: Minimal configuration
- **[TODO]**: Add flake8 or pylint
- **[TODO]**: Configure pre-commit hooks

**Formatting**: No formatter detected
- **[TODO]**: Add Black for consistent formatting
- **[TODO]**: Add isort for import sorting

**Naming Conventions** (Observed):
- Files: snake_case (models.py, views.py)
- Classes: PascalCase (ProjectViewSet)
- Functions: snake_case (create_project)
- Mostly consistent across codebase

### Testing (Discovered)

**Test Framework**: Django TestCase
```bash
Glob: **/test*.py
Result: 23 test files found
```

**Coverage Analysis**:
```bash
Bash: coverage run manage.py test && coverage report
Result: 47% overall coverage
```

**Test Types Found**:
- Unit tests: Model methods, utility functions
- Integration tests: API endpoints (limited)
- No E2E tests

**[TODO] Testing Improvements**:
- Increase coverage to 80% minimum
- Add integration tests for all API endpoints
- Add E2E tests for critical user flows
- Set up CI to run tests automatically

### Git Workflow (Discovered)

**Branching** (from git history):
- `main` branch for production
- Feature branches (inconsistent naming)
- **[TODO]**: Standardize branch naming (feature/*, fix/*)

**Commit Messages**: Inconsistent format
- **[TODO]**: Adopt Conventional Commits standard

**Pull Requests**: GitHub used
- **[TODO]**: Define PR review process
- **[TODO]**: Add PR templates

### CI/CD (Discovered)

**Current State**: No CI/CD detected
- **[TODO]**: Set up GitHub Actions or similar
- **[TODO]**: Automate: lint, test, build, deploy
- **[TODO]**: Add automated security scanning

---

## 8. Deployment Architecture

### Infrastructure (Discovered)

**Platform**: AWS EC2 (based on configuration)
- **Instance Type**: [TODO] Document instance size
- **[TODO]**: Consider containerization (ECS) for better scaling

**Components**:
```
┌─────────────────────┐
│  Route53 (DNS)      │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│  Load Balancer      │  [TODO] Verify if ALB or ELB
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│  EC2 Instances      │  [TODO] Auto-scaling configured?
│  (NGINX + Django)   │
└──────────┬──────────┘
           │
┌──────────▼──────────────────────┐
│  RDS PostgreSQL   │  ElastiCache │
│  [TODO] Multi-AZ? │  Redis       │
└───────────────────┴──────────────┘
```

### Environments (Discovered)

**Development**: Local Docker Compose
- All services containerized
- Hot reload enabled

**Staging**: [TODO] Verify if staging exists
- **[TODO]**: Set up staging environment

**Production**: AWS deployment
- **[TODO]**: Document production deployment process
- **[TODO]**: Blue-green or rolling deployment?

### Monitoring & Observability (Discovered)

**Current State**: Minimal monitoring
- **[TODO]**: Add application monitoring (Datadog, New Relic, or Sentry)
- **[TODO]**: Set up log aggregation (CloudWatch, ELK)
- **[TODO]**: Implement health checks
- **[TODO]**: Add performance monitoring (APM)

**Logging**: Python logging configured
- Logs to stdout (captured by Docker)
- **[TODO]**: Structured logging (JSON format)
- **[TODO]**: Log retention policy

### Scaling Strategy (Discovered)

**Current State**: Manual scaling
- **[TODO]**: Implement auto-scaling for EC2
- **[TODO]**: Database connection pooling (pgbouncer)
- **[TODO]**: Define scaling triggers (CPU, memory, requests)

### Backup & Disaster Recovery (Discovered)

**Database Backups**: AWS RDS automated backups (assumed)
- **[TODO]**: Document backup retention
- **[TODO]**: Test restore process

**Application Code**: Git repository
- **[TODO]**: Document disaster recovery procedures
- **[TODO]**: Define RTO and RPO targets

---

## Technical Debt Identified

### High Priority
1. **API Versioning**: Add versioning to prevent breaking changes
2. **Security**: Strengthen password requirements, add 2FA
3. **Testing**: Increase coverage from 47% to 80%+
4. **Monitoring**: Add APM and error tracking

### Medium Priority
5. **Service Layer**: Extract business logic from views consistently
6. **CI/CD**: Automate testing and deployment
7. **Caching**: Implement query caching strategy
8. **Documentation**: Add API documentation (drf-spectacular)

### Low Priority
9. **Code Style**: Add linting and formatting tools
10. **Soft Deletes**: Standardize across all models
11. **Frontend**: Consider SPA migration for better UX

---

## ADRs (Architecture Decision Records)

See `.spec-memory/DECISIONS-LOG.md` for documented decisions:

1. **ADR-001**: Django MTV pattern with app separation (existing)
2. **ADR-002**: Django Rest Framework for API layer (existing)
3. **ADR-003**: Celery with Redis for background tasks (existing)
4. **ADR-004**: PostgreSQL for primary database (existing)
5. **ADR-005**: Token authentication (existing, needs upgrade to JWT)

---

**Status**: Active (Brownfield)
**Last Analyzed**: 2025-10-31
**Codebase Size**: 487 Python files, ~50,000 lines
**Next Steps**: Address technical debt, begin feature development with Spec
```

### Output

```
Architecture Blueprint Created (Brownfield Analysis)

Location: .spec/architecture-blueprint.md
Type: Brownfield (existing codebase analyzed)
ADRs Created: 5 decisions logged (existing patterns)

Analysis Results:
  ✓ Technology Stack: Django 4.2, DRF, Celery, PostgreSQL, Redis
  ✓ Architecture: Django monolith with 4 apps
  ✓ API: 47 REST endpoints (no versioning)
  ✓ Database: 15 models, 87 migrations
  ✓ Deployment: Docker on AWS EC2

Tech Debt Identified (High Priority):
  • [TODO] Add API versioning (breaking changes risk)
  • [TODO] Strengthen security (2FA, password requirements)
  • [TODO] Increase test coverage (currently 47%, target 80%)
  • [TODO] Add monitoring and APM (currently none)
  • [TODO] Implement CI/CD pipeline

Architecture Gaps:
  • [TODO] Inconsistent service layer (partial implementation)
  • [TODO] No rate limiting on APIs
  • [TODO] Missing audit logging
  • [TODO] No comprehensive error handling strategy

Performance Optimization:
  • [TODO] Add query result caching
  • [TODO] Optimize database indexes
  • [TODO] Implement auto-scaling

Files Analyzed:
  • 487 Python files
  • 15 models across 4 Django apps
  • 47 API endpoints
  • 12 Celery tasks
  • 23 test files (47% coverage)

Next Steps:
  1. Review technical debt priorities with team
  2. Address high-priority items before new features
  3. Run `spec:generate "Your Feature"` to begin development
  4. All new features will follow discovered patterns
```

**Files Created**:
- `.spec/architecture-blueprint.md` (2,800 tokens, includes [TODO] tags)
- `.spec-memory/DECISIONS-LOG.md` (updated with 5 ADRs documenting existing)
- `.spec-memory/WORKFLOW-PROGRESS.md` (Feature 000 completed)

---

## Example 3: Microservices Migration with Update Mode

**Context**: Team has monolith blueprint (from Example 2), now planning microservices migration. Need to update blueprint with migration strategy.

**User Request**:
```
"Update architecture blueprint to add microservices migration plan"
```

**Skill Execution**:

### Step 1: Read Existing Blueprint

```bash
Read: .spec/architecture-blueprint.md
Result: Current Django monolith architecture loaded
```

### Step 2: Migration Strategy Design

Skill asks clarifying questions:

```
Question: Which migration approach?
Options:
  - Strangler Pattern (Gradual replacement, low risk)
  - Big Bang Migration (All at once, high risk)
  - Parallel Run (Both systems until proven, highest cost)
  - Service Extraction (Extract one service at a time)

User Selection: Strangler Pattern

Question: Which services to extract first?
(Multiple selection enabled)
Options:
  - Authentication (Core, highest priority)
  - Notifications (Async, good candidate)
  - Projects (High traffic, scaling benefits)
  - Tasks (Complex, defer until later)

User Selection: Authentication, Notifications
```

### Step 3: Blueprint Update

The skill updates `.spec/architecture-blueprint.md` by adding new sections:

```markdown
# Architecture Blueprint

[... existing sections ...]

---

## Migration Plan: Monolith → Microservices

**Strategy**: Strangler Pattern
**Timeline**: 6 months
**Status**: Planning

### Phase 1: Extract Authentication Service (Month 1-2)

**Rationale**:
- Core functionality needed by all services
- Clear boundaries (users, tokens, permissions)
- Low-risk extraction (read-heavy, stable API)

**Target Architecture**:
```
┌─────────────────────┐
│   API Gateway       │  (Kong or AWS API Gateway)
│   (Auth routing)    │
└──────┬──────────────┘
       │
       ├─────────────────────────────┐
       │                             │
┌──────▼─────────┐        ┌──────────▼────────┐
│  Auth Service  │        │  Django Monolith  │
│  (New: Node.js)│        │  (Existing apps)  │
│                │◄───────┤                   │
│  - Users       │  Auth  │  - Projects       │
│  - Tokens      │ checks │  - Tasks          │
│  - Permissions │        │  - Notifications  │
└────────────────┘        └───────────────────┘
       │                             │
┌──────▼─────────┐        ┌──────────▼────────┐
│  PostgreSQL    │        │  PostgreSQL       │
│  (Auth DB)     │        │  (Monolith DB)    │
└────────────────┘        └───────────────────┘
```

**Migration Steps**:
1. Deploy Auth service alongside monolith
2. Sync user data bidirectionally (temporary)
3. Route new auth requests to Auth service
4. Migrate existing sessions gradually
5. Update monolith to call Auth service for checks
6. Remove auth code from monolith (after validation)

**Success Criteria**:
- Zero downtime during migration
- Auth API latency <100ms (p95)
- 100% of auth requests through new service
- Monolith auth code removed

**Rollback Plan**:
- API Gateway can route back to monolith
- Bidirectional sync allows fallback
- No data loss risk

### Phase 2: Extract Notifications Service (Month 3-4)

**Rationale**:
- Async operations (good for extraction)
- Independent scaling (spiky traffic)
- Clear interface (send notification, check status)

**Target Architecture**:
```
┌─────────────────────┐
│   API Gateway       │
└──────┬──────────────┘
       │
       ├───────────────────────────────────────┐
       │                                       │
┌──────▼─────────┐    ┌────────────┐   ┌──────▼────────┐
│  Auth Service  │    │ Notif Svc  │   │Django Monolith│
└────────────────┘    │(New: Node) │   │               │
                      │            │◄──┤- Projects     │
                      │- Email     │   │- Tasks        │
                      │- SMS       │   └───────────────┘
                      │- Push      │
                      └──────┬─────┘
                             │
                      ┌──────▼─────┐
                      │RabbitMQ    │  (Event bus)
                      └────────────┘
```

**Migration Steps**:
1. Deploy Notifications service
2. Publish events to RabbitMQ from monolith
3. Notifications service consumes events
4. Dual-send: Both old Celery tasks and new events
5. Validate parity, turn off Celery tasks
6. Remove notification code from monolith

**Event Schema**:
```json
{
  "event": "notification.send",
  "payload": {
    "user_id": "uuid",
    "type": "email",
    "template": "project_assigned",
    "data": { "project_name": "..." }
  }
}
```

### Phase 3: API Gateway Implementation (Month 3)

**Technology**: Kong API Gateway
- Routing based on path
- Authentication integration
- Rate limiting per service
- Monitoring and logging

**Routes Configuration**:
```yaml
routes:
  - path: /api/v2/auth/*
    service: auth-service

  - path: /api/v2/notifications/*
    service: notification-service

  - path: /api/v1/*
    service: django-monolith
```

### Phase 4: Projects Service (Month 5-6) [Future]

**Deferred**: High complexity, wait until team experience grows

### Phase 5: Complete Migration (Month 6+) [Future]

**Eventual Goal**: All services extracted
- Decommission Django monolith
- Full event-driven architecture
- Independent deployment cycles

---

## Updated Technology Stack

### API Gateway (NEW)

**Technology**: Kong
- **Why**: Open-source, plugin ecosystem, Kubernetes-native
- **Alternatives**: AWS API Gateway (vendor lock-in), NGINX (manual config)

### Event Bus (NEW)

**Technology**: RabbitMQ
- **Why**: Reliable, supports multiple patterns, good monitoring
- **Alternatives**: Kafka (overkill for scale), AWS SQS (vendor lock-in)

### Microservices Runtime (NEW)

**Technology**: Node.js + TypeScript (for new services)
- **Why**: Consistency with planned stack, async I/O, fast development
- **Note**: Keeping Django monolith unchanged during transition

---

## Updated Deployment Architecture

### Target Infrastructure (Post-Migration)

```
┌──────────────────────────────────────────────┐
│          Kubernetes Cluster (EKS)            │
│                                              │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐ │
│  │  Auth    │  │  Notif   │  │  Django   │ │
│  │ Service  │  │ Service  │  │ Monolith  │ │
│  │(2 pods)  │  │(3 pods)  │  │(4 pods)   │ │
│  └──────────┘  └──────────┘  └───────────┘ │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │     Kong API Gateway (3 replicas)    │   │
│  └──────────────────────────────────────┘   │
└──────────────────────────────────────────────┘
          │                      │
┌─────────▼──────┐    ┌──────────▼────────┐
│  RDS PostgreSQL│    │ ElastiCache Redis │
│  (Multi-AZ)    │    │ (Cluster mode)    │
└────────────────┘    └───────────────────┘
          │
┌─────────▼──────┐
│   RabbitMQ     │  (Managed: Amazon MQ)
└────────────────┘
```

### Service Communication

**Synchronous**: HTTP/REST via API Gateway
- Auth checks: Monolith → Auth Service
- User lookup: Projects → Auth Service

**Asynchronous**: Events via RabbitMQ
- Notification triggers: Any service → Notification Service
- Audit events: All services → Audit Service (future)

---

## New ADRs (Migration)

See `.spec-memory/DECISIONS-LOG.md`:

6. **ADR-006**: Strangler pattern for microservices migration
7. **ADR-007**: Kong API Gateway for service routing
8. **ADR-008**: RabbitMQ for event-driven communication
9. **ADR-009**: Extract Auth service first (core dependency)
10. **ADR-010**: Node.js for new microservices (consistency)

---

**Status**: Active (Migration Planning)
**Last Updated**: 2025-10-31
**Migration Status**: Phase 0 (Planning)
**Next Review**: After Phase 1 completion
```

### Step 4: ADR for Migration Strategy

Adds ADR-006 to `.spec-memory/DECISIONS-LOG.md`:

```markdown
## ADR-006: Strangler Pattern for Microservices Migration

**Date**: 2025-10-31
**Status**: Accepted
**Context**: Need to migrate Django monolith to microservices without downtime

**Decision**: Use Strangler Pattern to gradually extract services

**Rationale**:
- **Risk Mitigation**: Incremental changes reduce risk vs big-bang migration
- **Learning Curve**: Team learns microservices with low-risk services first
- **Zero Downtime**: Monolith continues serving during migration
- **Validation**: Each phase can be validated before next extraction
- **Rollback**: Easy to revert individual services if issues arise

**Alternatives Considered**:
- **Big Bang Migration**: Rewrite entire system (too risky, months of no releases)
- **Parallel Run**: Run both systems (too expensive, data sync complexity)
- **Start Fresh**: New system from scratch (lose existing features, long timeline)

**Migration Phases**:
1. Auth Service (core, stable) - 2 months
2. Notifications (async, independent) - 2 months
3. Projects (high value) - 3 months
4. Tasks (complex) - 3 months
5. Decommission monolith - 1 month

**Consequences**:
- Positive: Low risk, continuous delivery, team learning, gradual investment
- Negative: Temporary complexity (dual systems), migration overhead, longer timeline
- Neutral: Need API Gateway, event bus infrastructure

**Success Metrics**:
- Zero downtime during migration
- No loss of functionality
- Improved service latency (<200ms p95)
- Independent deployment achieved

**Related**: ADR-007 (API Gateway), ADR-008 (Event Bus)
```

### Output

```
Architecture Blueprint Updated (Migration Plan Added)

Location: .spec/architecture-blueprint.md
Type: Update (Microservices Migration)
ADRs Created: 5 new decisions logged

Migration Strategy:
  ✓ Pattern: Strangler (gradual replacement)
  ✓ Timeline: 6 months
  ✓ Phases: 5 defined

Phase 1 - Auth Service (Month 1-2):
  • Extract users, authentication, authorization
  • Technology: Node.js + PostgreSQL
  • Communication: REST API
  • Risk: Low (read-heavy, stable API)

Phase 2 - Notifications Service (Month 3-4):
  • Extract email, SMS, push notifications
  • Technology: Node.js + RabbitMQ
  • Communication: Event-driven
  • Risk: Low (async, independent)

Infrastructure Changes:
  • Add Kong API Gateway for routing
  • Add RabbitMQ for event bus
  • Migrate to Kubernetes (EKS)

New ADRs:
  • ADR-006: Strangler pattern for migration
  • ADR-007: Kong for API Gateway
  • ADR-008: RabbitMQ for events
  • ADR-009: Extract Auth service first
  • ADR-010: Node.js for new services

Next Steps:
  1. Review migration plan with team
  2. Set up infrastructure (Kong, RabbitMQ, K8s)
  3. Run `spec:generate "Auth Service Extraction"` to begin Phase 1
  4. Implement monitoring for both systems during transition
```

**Files Updated**:
- `.spec/architecture-blueprint.md` (migration sections added)
- `.spec-memory/DECISIONS-LOG.md` (5 new ADRs)
- `.spec-memory/WORKFLOW-PROGRESS.md` (Feature 000 updated)

---

## Example 4: HIPAA-Compliant Healthcare Application

**Context**: Healthcare startup building patient management system. Must comply with HIPAA regulations from day one.

**User Request**:
```
"Create architecture blueprint for HIPAA-compliant patient management system"
```

**Skill Execution**:

### Step 1: Compliance Research

```bash
WebSearch: "HIPAA technical safeguards requirements 2025"
Results: Security Rule requirements, encryption standards, audit controls

WebSearch: "AWS HIPAA eligible services"
Results: List of HIPAA-compliant AWS services

WebSearch: "HIPAA application architecture best practices"
Results: Reference architectures, security patterns
```

### Step 2: Compliance-Focused Questions

```
Question: What types of PHI will you handle?
(Multiple selection)
Options:
  - Patient demographics (Name, DOB, SSN)
  - Medical records (Diagnoses, treatments)
  - Billing information (Insurance, payment)
  - Clinical notes (Provider observations)

User Selection: All

Question: What is your deployment timeline?
Options:
  - Immediate (Production in <3 months)
  - Normal (Production in 3-6 months)
  - Extended (Production in 6+ months)

User Selection: Normal (3-6 months)

Question: Do you have a compliance officer or consultant?
Options:
  - Yes (Dedicated compliance resource)
  - Consulting (Using external consultant)
  - No (Need guidance on hiring)

User Selection: Consulting
```

### Step 3: HIPAA-Compliant Blueprint

Creates `.spec/architecture-blueprint.md` with enhanced security:

```markdown
# Architecture Blueprint - HIPAA Compliant

**Project**: Patient Management System
**Type**: Greenfield (HIPAA-Compliant)
**Created**: 2025-10-31
**Status**: Active
**Compliance**: HIPAA Security Rule

---

## 1. System Overview

### Architecture (HIPAA-Compliant Design)

```
┌────────────────────────────────────────────────┐
│              DMZ / Public Zone                 │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │ CloudFront (HTTPS only, TLS 1.3)         │ │
│  └────────────┬─────────────────────────────┘ │
└───────────────┼────────────────────────────────┘
                │
┌───────────────▼────────────────────────────────┐
│         Application Zone (Private)             │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │ ALB (WAF enabled, TLS termination)       │ │
│  └────────────┬─────────────────────────────┘ │
│               │                                │
│  ┌────────────▼─────────────────────────────┐ │
│  │   ECS Fargate (Application servers)      │ │
│  │   - Patient Portal (React SPA)           │ │
│  │   - API Server (Node.js)                 │ │
│  │   - Auth Service (Separate)              │ │
│  └────────────┬─────────────────────────────┘ │
└───────────────┼────────────────────────────────┘
                │
┌───────────────▼────────────────────────────────┐
│            Data Zone (Isolated)                │
│                                                │
│  ┌──────────────┐        ┌──────────────────┐ │
│  │ RDS          │        │ S3 (Documents)   │ │
│  │ PostgreSQL   │        │ - Encryption:    │ │
│  │ - Encrypted  │        │   KMS AES-256    │ │
│  │ - Multi-AZ   │        │ - Versioning ON  │ │
│  │ - Backup 30d │        │ - Audit logging  │ │
│  └──────────────┘        └──────────────────┘ │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │ Audit Log Storage (S3 + Glacier)         │ │
│  │ - Immutable logs                         │ │
│  │ - 7-year retention (HIPAA requirement)   │ │
│  └──────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
```

### HIPAA Compliance Zones

**DMZ (Public Zone)**:
- CloudFront CDN with HTTPS-only
- WAF rules for DDoS protection
- No PHI stored or processed

**Application Zone (Private Subnet)**:
- ECS Fargate tasks (no EC2 to patch)
- All services authenticate via Auth Service
- Audit logging on all API calls
- No direct internet access

**Data Zone (Isolated Subnet)**:
- RDS in private subnet (no public access)
- S3 buckets with encryption
- Access only from Application Zone
- All access logged to audit trail

### Key Security Controls

1. **Encryption**: All PHI encrypted at rest (AES-256) and in transit (TLS 1.3)
2. **Access Control**: Role-based access with principle of least privilege
3. **Audit Logging**: All PHI access logged with 7-year retention
4. **Authentication**: Multi-factor authentication required
5. **Data Integrity**: Checksums, versioning, immutable logs

---

## 2. Technology Stack (HIPAA-Eligible Services)

### Backend

**Runtime**: Node.js 20 LTS
- HIPAA Compliant: Yes (application-level)

**Framework**: Express.js + NestJS
- Security Features: Helmet.js for headers, CORS controls

**ORM**: Prisma
- Security: Parameterized queries (SQL injection prevention)

### Data Storage (HIPAA-Eligible)

**Primary Database**: AWS RDS PostgreSQL 15
- **HIPAA Eligible**: YES (with BAA)
- **Encryption**: AES-256 at rest (KMS), TLS 1.3 in transit
- **Backups**: Automated daily, encrypted, 30-day retention
- **Multi-AZ**: Enabled for high availability
- **Audit**: All queries logged to CloudWatch

**Document Storage**: AWS S3
- **HIPAA Eligible**: YES (with BAA)
- **Encryption**: SSE-KMS (AES-256)
- **Versioning**: Enabled (immutability)
- **Access Logs**: All access logged to separate bucket
- **Lifecycle**: Transition to Glacier after 90 days

**Cache**: AWS ElastiCache Redis
- **HIPAA Eligible**: YES (with BAA)
- **Encryption**: At rest and in transit
- **Usage**: Session tokens only (NO PHI cached)

### Infrastructure (HIPAA-Eligible)

**Compute**: AWS ECS with Fargate
- **HIPAA Eligible**: YES (with BAA)
- **Networking**: Private subnets only, no public IPs
- **Logging**: All container logs to CloudWatch

**Load Balancer**: AWS Application Load Balancer
- **HIPAA Eligible**: YES
- **TLS**: Version 1.3 only
- **WAF**: Enabled with OWASP rules

**Monitoring**: AWS CloudWatch + CloudTrail
- **HIPAA Eligible**: YES
- **Retention**: CloudTrail 7 years (compliance)

**Identity**: AWS Cognito + Custom Auth Service
- **HIPAA Eligible**: Cognito YES (with BAA)
- **MFA**: Required for all users
- **Password**: Minimum 14 characters, complexity enforced

### HIPAA Business Associate Agreement (BAA)

Required with:
- AWS (primary infrastructure)
- Datadog (monitoring) - if used
- Twilio (SMS for MFA) - if used
- Any other service processing PHI

---

## 3. Architecture Patterns

### Defense in Depth (Security Layers)

```
┌─────────────────────────────────────┐
│ Layer 1: Network (VPC, Subnets)     │  Isolation
├─────────────────────────────────────┤
│ Layer 2: Infrastructure (WAF, ALB)  │  DDoS protection
├─────────────────────────────────────┤
│ Layer 3: Authentication (MFA)       │  Identity verification
├─────────────────────────────────────┤
│ Layer 4: Authorization (RBAC)       │  Access control
├─────────────────────────────────────┤
│ Layer 5: Application (Input valid.) │  Data validation
├─────────────────────────────────────┤
│ Layer 6: Data (Encryption)          │  PHI protection
├─────────────────────────────────────┤
│ Layer 7: Audit (Logging)            │  Compliance trail
└─────────────────────────────────────┘
```

### Data Classification Pattern

**PHI (Protected Health Information)**:
- Encrypted at rest (AES-256)
- Encrypted in transit (TLS 1.3)
- All access logged
- Minimum retention (patient can request deletion)
- Access: RBAC required

**PII (Personally Identifiable Information)**:
- Encrypted at rest
- Encrypted in transit
- Access logged
- Retention: per business need

**Non-Sensitive**:
- Standard security controls
- Normal retention

### Audit Trail Pattern

Every PHI access logged:
```json
{
  "timestamp": "2025-10-31T12:00:00Z",
  "event": "phi.access",
  "user": {
    "id": "user-123",
    "role": "physician",
    "npi": "1234567890"
  },
  "patient": {
    "id": "patient-456",
    "mrn": "MRN-789"
  },
  "resource": {
    "type": "medical_record",
    "id": "record-999"
  },
  "action": "read",
  "ip_address": "10.0.1.100",
  "session_id": "session-abc",
  "purpose_of_use": "treatment"
}
```

---

## 4. API Conventions (Security-First)

### Authentication (Multi-Factor)

**Primary**: OAuth 2.0 with MFA
1. Username + password (14+ chars, complexity)
2. Second factor: TOTP (Google Authenticator) OR SMS

**Tokens**: JWT with short expiry
- Access token: 15 minutes
- Refresh token: 24 hours
- Stored: httpOnly, secure cookies

**Session Management**:
- Idle timeout: 15 minutes (HIPAA recommendation)
- Absolute timeout: 8 hours
- Concurrent sessions: Limited to 3 per user

### Authorization (Role-Based)

**Roles**:
- **Physician**: Full patient access (assigned patients)
- **Nurse**: Read/write (assigned patients)
- **Admin**: User management, reports (NO patient access)
- **Billing**: Billing information only (NO medical records)
- **Patient**: Own records only

**Permissions** (Granular):
- `patient:read` - View patient demographics
- `phi:read` - View medical records
- `phi:write` - Update medical records
- `phi:export` - Download patient data
- `audit:read` - View audit logs (admin only)

**Access Control**:
```typescript
// Every API endpoint checks:
if (!user.hasPermission('phi:read')) {
  throw ForbiddenError();
}

// AND patient relationship:
if (!user.hasAccessToPatient(patientId)) {
  throw ForbiddenError();
}

// Log access:
auditLog.record({
  event: 'phi.access',
  user: user.id,
  patient: patientId,
  action: 'read'
});
```

### API Security Headers

```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
Content-Security-Policy: default-src 'self'; script-src 'self'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Referrer-Policy: no-referrer
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

### Rate Limiting (Abuse Prevention)

**Per User**:
- Authentication: 5 attempts per 15 minutes
- API calls: 100 requests per minute
- Export/Download: 10 per hour

**Per IP**:
- Unauthenticated: 20 requests per minute
- Blocked after threshold, alert security

---

## 5. Data Model Principles (HIPAA-Compliant)

### PHI Encryption at Application Level

```typescript
// All PHI fields encrypted before DB storage
class Patient {
  id: string;                    // Plain
  mrn: string;                   // Plain (indexed)

  // PHI - Encrypted at application level
  firstName: EncryptedString;    // AES-256-GCM
  lastName: EncryptedString;
  ssn: EncryptedString;
  dateOfBirth: EncryptedDate;
  address: EncryptedString;
  phone: EncryptedString;
  email: EncryptedString;

  createdAt: Date;               // Plain
  updatedAt: Date;               // Plain
}
```

**Encryption Library**: `@47ng/cloak` or similar
- Algorithm: AES-256-GCM
- Key management: AWS KMS
- Key rotation: Annual (automatic)

### Database Schema (PostgreSQL)

```sql
-- Patient table with encrypted PHI
CREATE TABLE patients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mrn VARCHAR(50) UNIQUE NOT NULL,  -- Medical Record Number

  -- PHI (encrypted before storage)
  first_name_encrypted TEXT NOT NULL,
  last_name_encrypted TEXT NOT NULL,
  ssn_encrypted TEXT,
  dob_encrypted TEXT NOT NULL,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID NOT NULL REFERENCES users(id),

  -- Audit columns
  last_accessed_at TIMESTAMPTZ,
  last_accessed_by UUID REFERENCES users(id)
);

-- Medical records (PHI)
CREATE TABLE medical_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id),

  -- Clinical data (encrypted)
  diagnosis_encrypted TEXT,
  treatment_plan_encrypted TEXT,
  notes_encrypted TEXT,

  provider_id UUID NOT NULL REFERENCES users(id),
  encounter_date TIMESTAMPTZ NOT NULL,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Audit log (immutable)
CREATE TABLE audit_log (
  id BIGSERIAL PRIMARY KEY,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  event_type VARCHAR(100) NOT NULL,
  user_id UUID NOT NULL REFERENCES users(id),
  patient_id UUID REFERENCES patients(id),
  resource_type VARCHAR(100),
  resource_id UUID,
  action VARCHAR(50) NOT NULL,
  ip_address INET,
  session_id UUID,
  purpose_of_use VARCHAR(100),
  data JSONB  -- Event details
);

-- Prevent updates/deletes on audit log
CREATE POLICY audit_log_immutable ON audit_log
  FOR UPDATE, DELETE
  TO ALL
  USING (false);
```

### Data Retention (HIPAA Requirements)

**Medical Records**: Minimum 7 years from last treatment
**Audit Logs**: 7 years (HIPAA requirement)
**Backups**: 30 days online, 7 years archived

**Deletion Process** (Patient Right to be Forgotten):
1. Patient requests deletion
2. Legal review (retention requirements)
3. Soft delete (mark as deleted, encrypt name)
4. After retention: Hard delete + backup scrubbing

---

## 6. Security & Compliance (HIPAA Security Rule)

### Administrative Safeguards

**Security Management Process**:
- Risk analysis: Annual
- Risk management: Ongoing
- Sanction policy: Documented for violations
- Information system activity review: Monthly audit log review

**Workforce Security**:
- Access authorization: Manager approval required
- Workforce clearance: Background checks for PHI access
- Termination procedures: Immediate access revocation

**Training**:
- HIPAA training: All employees, annual
- Security awareness: Quarterly updates
- Incident response: Simulations twice yearly

### Physical Safeguards

**Facility Access**:
- AWS data centers: ISO 27001, SOC 2 certified
- Office access: Badge-controlled, visitor logs

**Workstation Security**:
- Full disk encryption: Required
- Screen locks: 5-minute timeout
- Clean desk policy: No PHI on desks

**Device and Media Controls**:
- Disposal: Certified data destruction
- Media re-use: Secure wiping
- Backup: Encrypted, offsite

### Technical Safeguards (Primary Focus)

**Access Control** (§164.312(a)):
- Unique user identification: Yes (UUID per user)
- Emergency access: Break-glass procedure with full audit
- Automatic logoff: 15 minutes idle
- Encryption: AES-256 at rest, TLS 1.3 in transit

**Audit Controls** (§164.312(b)):
- All PHI access logged
- Logs immutable (no deletion)
- 7-year retention
- Monthly review by security officer

**Integrity** (§164.312(c)):
- Checksums for documents
- Database constraints
- Version control for records

**Transmission Security** (§164.312(e)):
- TLS 1.3 for all communications
- VPN for admin access
- No PHI in emails (secure portal only)

### Breach Notification

**Detection**:
- Automated alerts for unusual access patterns
- Failed login monitoring
- Data export tracking

**Response Plan** (if breach occurs):
1. Immediate containment (revoke access)
2. Investigation (determine scope, affected patients)
3. Notification to affected individuals (<60 days)
4. HHS notification if >500 affected
5. Media notification if >500 affected
6. Root cause analysis and remediation

**Reporting**: security@company.com (monitored 24/7)

---

## 7. Development Standards (Security-First)

### Secure Coding Practices

**Input Validation**:
- Whitelist approach (allow known-good)
- Reject invalid input early
- Sanitize all outputs (XSS prevention)
- Parameterized queries only (SQL injection prevention)

**Authentication**:
```typescript
// Password hashing: Argon2id (OWASP recommendation)
import argon2 from 'argon2';

const hashedPassword = await argon2.hash(password, {
  type: argon2.argon2id,
  memoryCost: 65536,  // 64 MB
  timeCost: 3,
  parallelism: 4
});
```

**Session Security**:
- Regenerate session ID on login
- Invalidate on logout
- Store minimal data in session
- Secure, httpOnly cookies

### Code Review Requirements

**Security Checklist**:
- [ ] No hardcoded secrets (use environment variables)
- [ ] All inputs validated
- [ ] PHI encrypted before storage
- [ ] Audit logging added for PHI access
- [ ] Error messages don't leak PHI
- [ ] RBAC checks present
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (sanitized outputs)

**Review Process**:
- 2 reviewers required (1 must be security-trained)
- Security scan passes (Snyk, SonarQube)
- No secrets detected (git-secrets, TruffleHog)

### Testing Standards

**Security Testing**:
- SAST (Static): SonarQube, Semgrep
- DAST (Dynamic): OWASP ZAP, Burp Suite
- Dependency scanning: Snyk, npm audit
- Penetration testing: Annual (third-party)

**Compliance Testing**:
- Encryption verification (at rest and in transit)
- Access control testing (role-based)
- Audit log verification (completeness)
- Session timeout testing

---

## 8. Deployment Architecture (HIPAA-Compliant AWS)

### Network Architecture

```
┌────────────────────────────────────────────────┐
│ VPC: 10.0.0.0/16 (Isolated network)            │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │ Public Subnets (10.0.1.0/24, 10.0.2.0/24)│ │
│  │ - ALB (internet-facing)                  │ │
│  │ - NAT Gateway                            │ │
│  └──────────────────────────────────────────┘ │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │ Private Subnets (10.0.10.0/24, .11.0/24) │ │
│  │ - ECS Fargate tasks                      │ │
│  │ - Application servers                    │ │
│  └──────────────────────────────────────────┘ │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │ Data Subnets (10.0.20.0/24, .21.0/24)    │ │
│  │ - RDS PostgreSQL (Multi-AZ)              │ │
│  │ - ElastiCache Redis                      │ │
│  └──────────────────────────────────────────┘ │
│                                                │
│  Security Groups:                              │
│  - ALB: 443 from Internet                      │
│  - App: 8080 from ALB only                     │
│  - DB: 5432 from App only                      │
└────────────────────────────────────────────────┘
```

### Encryption Strategy

**At Rest**:
- RDS: KMS encryption enabled
- S3: SSE-KMS (customer-managed key)
- EBS: Encrypted (for any EC2)
- ElastiCache: At-rest encryption enabled
- Backups: Encrypted automatically

**In Transit**:
- Internet to ALB: TLS 1.3
- ALB to ECS: TLS 1.2+ (internal)
- ECS to RDS: TLS 1.2+
- ECS to S3: HTTPS only

**Key Management** (AWS KMS):
- Customer-managed keys (CMK)
- Automatic rotation: Enabled (annual)
- Access: IAM policies (least privilege)

### Monitoring & Alerting (HIPAA-Focused)

**CloudWatch Alarms**:
- Failed login attempts: >5 in 15 min
- Unusual PHI access: Access outside normal hours
- Data export: Large downloads
- Configuration changes: Security group modifications
- Failed API calls: >10% error rate

**CloudTrail** (Audit All AWS Actions):
- Enabled on all regions
- Log file validation: Enabled (integrity)
- Retention: 7 years (S3 + Glacier)
- Alerts: Unauthorized API calls

**Application Logs** (CloudWatch Logs):
- All API requests
- Authentication events
- Authorization failures
- PHI access
- Errors and exceptions

**Retention**:
- CloudWatch Logs: 7 years
- CloudTrail: 7 years
- Application audit logs: 7 years

### Backup & Disaster Recovery

**RDS Backups**:
- Automated daily snapshots
- Retention: 30 days
- Manual snapshots: Before major changes
- Cross-region replication: Enabled (DR)

**S3 Versioning**:
- Enabled on all PHI buckets
- MFA delete: Required for permanent deletion
- Lifecycle: Archive to Glacier after 90 days

**Disaster Recovery**:
- RTO (Recovery Time Objective): 4 hours
- RPO (Recovery Point Objective): 1 hour
- DR Region: us-west-2 (primary: us-east-1)
- DR Testing: Quarterly

---

## HIPAA Compliance Checklist

### Technical Safeguards
- [x] Unique user IDs (§164.312(a)(2)(i))
- [x] Emergency access procedure (§164.312(a)(2)(ii))
- [x] Automatic logoff (§164.312(a)(2)(iii))
- [x] Encryption of PHI (§164.312(a)(2)(iv))
- [x] Audit controls (§164.312(b))
- [x] Integrity controls (§164.312(c)(1))
- [x] Transmission security (§164.312(e)(1))

### Administrative Safeguards
- [x] Security management process (§164.308(a)(1))
- [x] Workforce security (§164.308(a)(3))
- [x] Information access management (§164.308(a)(4))
- [x] Security training (§164.308(a)(5))
- [x] Contingency plan (§164.308(a)(7))

### Physical Safeguards
- [x] Facility access controls (§164.310(a)(1))
- [x] Workstation security (§164.310(c))
- [x] Device and media controls (§164.310(d)(1))

### Business Associate Agreements
- [ ] AWS BAA signed (required before production)
- [ ] Datadog BAA signed (if using)
- [ ] Twilio BAA signed (if using for SMS)

---

## ADRs (HIPAA-Focused)

See `.spec-memory/DECISIONS-LOG.md`:

1. **ADR-001**: AWS as cloud provider (HIPAA-eligible services)
2. **ADR-002**: AES-256-GCM for application-level PHI encryption
3. **ADR-003**: TLS 1.3 for all data in transit
4. **ADR-004**: 15-minute session timeout (HIPAA best practice)
5. **ADR-005**: 7-year audit log retention (HIPAA requirement)
6. **ADR-006**: Multi-factor authentication required for all users
7. **ADR-007**: Role-based access control with least privilege
8. **ADR-008**: Immutable audit logs (prevent tampering)

---

**Status**: Active (HIPAA-Compliant)
**Compliance Review**: Quarterly
**Next Audit**: [Schedule external HIPAA audit]
**Security Officer**: [To be assigned]
**Privacy Officer**: [To be assigned]
```

### Output

```
Architecture Blueprint Created (HIPAA-Compliant)

Location: .spec/architecture-blueprint.md
Type: Greenfield with Compliance Requirements
ADRs Created: 8 security-focused decisions logged

HIPAA Compliance:
  ✓ Technical Safeguards: Encryption, access control, audit logs
  ✓ Administrative Safeguards: Policies, training, risk management
  ✓ Physical Safeguards: AWS certified data centers
  ✓ Breach Notification: Detection and response plan

Encryption Strategy:
  • At Rest: AES-256 (KMS) for all PHI
  • In Transit: TLS 1.3 for all communications
  • Application-level: PHI fields encrypted before DB storage

Access Controls:
  • Authentication: OAuth 2.0 + MFA (required)
  • Authorization: RBAC with 5 roles defined
  • Session: 15-minute timeout, automatic logoff
  • Audit: All PHI access logged (7-year retention)

Infrastructure (AWS HIPAA-Eligible):
  • Compute: ECS Fargate (private subnets)
  • Database: RDS PostgreSQL (encrypted, Multi-AZ)
  • Storage: S3 with KMS encryption
  • Monitoring: CloudWatch + CloudTrail (7-year logs)

Security Features:
  • Defense in depth (7 layers)
  • Immutable audit logs
  • Automated breach detection
  • Quarterly compliance testing

Next Steps:
  1. Sign AWS Business Associate Agreement (BAA)
  2. Assign Security and Privacy Officers
  3. Complete HIPAA training for all team members
  4. Review blueprint with compliance consultant
  5. Schedule external HIPAA audit
  6. Run `spec:generate "Patient Registration"` to begin development

Compliance Reminder:
  - All code changes require security review
  - Penetration testing annually
  - Audit log review monthly
  - Risk assessment annually
```

**Files Created**:
- `.spec/architecture-blueprint.md` (4,500 tokens, compliance-focused)
- `.spec-memory/DECISIONS-LOG.md` (8 security ADRs)
- `.spec-memory/WORKFLOW-PROGRESS.md` (Feature 000 completed)

---

## Example 5: Real-Time Collaborative Application

**Context**: Building a real-time collaborative document editor (like Google Docs or Notion).

**User Request**:
```
"Create architecture blueprint for a real-time collaborative document editor"
```

**Skill Execution**:

### Step 1: Real-Time Requirements Analysis

```bash
WebSearch: "CRDT conflict-free replicated data types"
Results: Yjs, Automerge, comparison of CRDT libraries

WebSearch: "WebSocket scaling patterns"
Results: Sticky sessions, Redis pub/sub, horizontal scaling

WebSearch: "operational transformation vs CRDT"
Results: Trade-offs, use cases, implementation complexity
```

### Step 2: Technology Selection

The skill creates a specialized blueprint focused on real-time architecture.

**Output** (excerpt from `.spec/architecture-blueprint.md`):

```markdown
# Architecture Blueprint - Real-Time Collaborative Editor

**Project**: Collaborative Document Editor
**Type**: Greenfield (Real-Time Architecture)
**Created**: 2025-10-31
**Status**: Active
**Special Requirements**: Low-latency, conflict resolution, horizontal scaling

---

## 1. System Overview

### Real-Time Architecture

```
┌────────────────────────────────────────────────────┐
│            Clients (Web + Mobile)                  │
│  React + Yjs (local CRDT state)                    │
└──────────┬─────────────────────────────────────────┘
           │ WebSocket (persistent connection)
           │
┌──────────▼─────────────────────────────────────────┐
│         Load Balancer (Sticky Sessions)            │
│  AWS ALB with target group stickiness              │
└──────────┬─────────────────────────────────────────┘
           │
┌──────────▼─────────────────────────────────────────┐
│       WebSocket Server Cluster (ECS)               │
│                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │ WS Node  │  │ WS Node  │  │ WS Node  │         │
│  │  (Pod 1) │  │  (Pod 2) │  │  (Pod 3) │         │
│  │          │  │          │  │          │         │
│  │ Yjs CRDT │  │ Yjs CRDT │  │ Yjs CRDT │         │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘         │
└───────┼─────────────┼─────────────┼────────────────┘
        │             │             │
        └─────────────▼─────────────┘
                      │
        ┌─────────────▼──────────────┐
        │   Redis Pub/Sub            │
        │   (Server-to-server sync)  │
        └─────────────┬──────────────┘
                      │
        ┌─────────────▼──────────────┐
        │   Document Persistence     │
        │   MongoDB (CRDT snapshots) │
        │   S3 (Full doc backups)    │
        └────────────────────────────┘
```

### Performance Targets

**Latency**:
- Local edits: <50ms (optimistic updates)
- Remote edits: <200ms (network sync)
- Document load: <500ms (initial state)

**Scalability**:
- Concurrent users per document: 50
- Total documents: 1M+
- WebSocket connections: 100K+

**Availability**: 99.9% uptime

---

## 2. Technology Stack (Real-Time Optimized)

### CRDT Library

**Technology**: Yjs
- **Why**: Battle-tested, TypeScript support, excellent performance
- **CRDT Type**: Conflict-free Replicated Data Type
- **Features**: Rich text, undo/redo, awareness (cursors)
- **Alternatives**: Automerge (slower), custom OT (complex implementation)

**ADR**: See ADR-001 for detailed rationale

### WebSocket Communication

**Technology**: Socket.io 4.x
- **Why**: Fallbacks (long-polling), reconnection logic, rooms support
- **Alternatives**: Native WebSocket (no fallbacks), uWebSockets (lower-level)

**Connection Management**:
- Heartbeat: Every 30 seconds
- Reconnection: Exponential backoff (max 5 attempts)
- Compression: Per-message deflate

### Server-to-Server Sync

**Technology**: Redis Pub/Sub
- **Why**: Low latency, simple API, horizontal scaling support
- **Channels**: One per document (e.g., `doc:123`)
- **Alternatives**: RabbitMQ (overkill), Kafka (too heavy)

### Document Storage

**Primary**: MongoDB 6.x
- **Why**: Flexible schema, good for CRDT snapshots, document-oriented
- **Collections**:
  - `documents`: Document metadata
  - `snapshots`: CRDT state snapshots (every 100 updates)
  - `updates`: Individual CRDT updates (for history)

**Backup**: AWS S3
- **Why**: Durable, cheap, versioning support
- **Format**: Full document exports (HTML, Markdown, JSON)

### Frontend

**Framework**: React 18
**CRDT Integration**: y-react bindings
**Editor**: TipTap (Yjs-compatible)
**State**: Yjs handles document state, React Query for metadata

---

## 3. Architecture Patterns

### CRDT Pattern (Conflict-Free Editing)

**How it works**:
1. User types "Hello"
2. Yjs captures as operations: `insert("H", 0), insert("e", 1)...`
3. Operations applied locally (optimistic update)
4. Operations broadcast to server via WebSocket
5. Server broadcasts to other clients
6. Each client applies operations to their CRDT state
7. CRDTs converge to same state (no conflicts!)

**Example**:
```typescript
// Initialize Yjs document
const ydoc = new Y.Doc();
const ytext = ydoc.getText('content');

// Listen for local changes
ytext.observe((event) => {
  // Send updates to server
  const update = Y.encodeStateAsUpdate(ydoc);
  socket.emit('doc-update', { docId, update });
});

// Apply remote changes
socket.on('doc-update', ({ update }) => {
  Y.applyUpdate(ydoc, update);
  // UI updates automatically via y-react bindings
});
```

### Sticky Session Pattern (WebSocket Affinity)

**Problem**: WebSocket connections need consistent server
**Solution**: ALB target group stickiness

```
Client 1 → ALB → Server A (stays on Server A)
Client 2 → ALB → Server B (stays on Server B)
Client 3 → ALB → Server A (can go to any server)
```

**Configuration**:
```json
{
  "stickinessEnabled": true,
  "stickinessDuration": 86400,  // 24 hours
  "stickinessType": "lb_cookie"
}
```

### Presence Awareness Pattern (Live Cursors)

**Yjs Awareness API**:
```typescript
const awareness = new Awareness(ydoc);

// Set local user info
awareness.setLocalStateField('user', {
  name: 'Alice',
  color: '#FF5733',
  cursor: { line: 5, column: 10 }
});

// Listen for remote users
awareness.on('change', (changes) => {
  changes.added.forEach(clientId => {
    const state = awareness.getStates().get(clientId);
    // Render cursor for state.user
  });
});
```

### Snapshot Pattern (Performance Optimization)

**Problem**: Replaying all updates slow for large documents
**Solution**: Periodic snapshots

```typescript
// Every 100 updates, save snapshot
let updateCount = 0;

ytext.observe(() => {
  updateCount++;

  if (updateCount % 100 === 0) {
    const snapshot = Y.encodeStateAsUpdate(ydoc);
    await saveSnapshot(docId, snapshot);
  }
});

// Load document: snapshot + recent updates
async function loadDocument(docId) {
  const snapshot = await getLatestSnapshot(docId);
  const updates = await getUpdatesSinceSnapshot(docId, snapshot.id);

  Y.applyUpdate(ydoc, snapshot.data);
  updates.forEach(update => Y.applyUpdate(ydoc, update.data));
}
```

---

## 4. API Conventions

### WebSocket API

**Connection**:
```typescript
// Client connects with auth token
const socket = io('wss://api.editor.com', {
  auth: { token: jwtToken }
});

// Server authenticates
io.use((socket, next) => {
  const token = socket.handshake.auth.token;
  // Verify JWT
  if (valid) next();
  else next(new Error('Authentication failed'));
});
```

**Events**:

```typescript
// Client → Server
socket.emit('doc-join', { docId: '123' });
socket.emit('doc-update', { docId: '123', update: Uint8Array });
socket.emit('awareness-update', { docId: '123', state: {...} });

// Server → Client
socket.on('doc-state', { snapshot: Uint8Array });  // Initial state
socket.on('doc-update', { update: Uint8Array });   // Remote updates
socket.on('awareness-update', { clientId, state });  // Cursor positions
socket.on('error', { code, message });
```

**Room Pattern** (Socket.io):
```typescript
// Join document room
socket.on('doc-join', async ({ docId }) => {
  // Check permission
  if (!canAccess(socket.userId, docId)) {
    return socket.emit('error', { code: 'FORBIDDEN' });
  }

  // Join room
  socket.join(`doc:${docId}`);

  // Send initial state
  const state = await getDocumentState(docId);
  socket.emit('doc-state', { snapshot: state });

  // Notify others
  socket.to(`doc:${docId}`).emit('user-joined', {
    userId: socket.userId
  });
});

// Broadcast updates to room
socket.on('doc-update', ({ docId, update }) => {
  socket.to(`doc:${docId}`).emit('doc-update', { update });

  // Persist update
  saveUpdate(docId, update);
});
```

### REST API (Metadata Only)

```
GET    /api/documents              List documents
POST   /api/documents              Create document
GET    /api/documents/:id          Get metadata
PATCH  /api/documents/:id          Update metadata
DELETE /api/documents/:id          Delete document
GET    /api/documents/:id/export   Export to PDF/HTML
POST   /api/documents/:id/share    Share document
```

---

## 5. Scaling Strategy

### Horizontal Scaling (WebSocket Servers)

**Auto-Scaling Triggers**:
- CPU >70%: Add pod
- Active connections >1000 per pod: Add pod
- CPU <30%: Remove pod (graceful shutdown)

**Graceful Shutdown**:
```typescript
process.on('SIGTERM', async () => {
  console.log('Shutting down gracefully...');

  // Stop accepting new connections
  io.close();

  // Wait for existing connections to close (max 30s)
  await waitForConnections(30000);

  // Exit
  process.exit(0);
});
```

### Redis Pub/Sub Scaling

**Pattern**: One Redis instance per cluster
- Pub/Sub channels: One per document
- Memory: ~100 bytes per channel
- Throughput: 100K messages/sec

**Optimization**: Lazy channel creation
```typescript
// Only subscribe to active documents
socket.on('doc-join', async ({ docId }) => {
  if (!redis.hasChannel(`doc:${docId}`)) {
    redis.subscribe(`doc:${docId}`);
  }
});
```

### Database Scaling (MongoDB)

**Sharding Strategy**: Shard by `docId`
- Shard key: `docId` (hash-based)
- Initial shards: 3
- Scale: Add shards as data grows

**Indexes**:
```javascript
// Documents collection
db.documents.createIndex({ docId: 1 });
db.documents.createIndex({ owner: 1, createdAt: -1 });

// Snapshots collection
db.snapshots.createIndex({ docId: 1, version: -1 });

// Updates collection (TTL for old updates)
db.updates.createIndex({ docId: 1, timestamp: 1 });
db.updates.createIndex({ timestamp: 1 }, { expireAfterSeconds: 2592000 });  // 30 days
```

---

## 6. Monitoring & Observability

### Real-Time Metrics

**WebSocket Metrics**:
- Active connections
- Messages per second (in/out)
- Average latency (client → server → client)
- Connection duration
- Reconnection rate

**CRDT Metrics**:
- Document size (operations count)
- Snapshot frequency
- Update propagation time
- Conflict rate (should be 0!)

**Dashboard** (Datadog):
```
┌─────────────────────────────────────┐
│ Active Connections: 45,231          │
│ Messages/sec: 12,450                │
│ Avg Latency: 87ms                   │
│ Documents Active: 3,421             │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Top Documents by Connections        │
│ doc-abc: 50 users                   │
│ doc-xyz: 48 users                   │
│ doc-123: 42 users                   │
└─────────────────────────────────────┘
```

### Alerts

**P1 (Critical)**:
- WebSocket server down: >1 pod unreachable
- Redis pub/sub failure: Messages not delivering
- Average latency >500ms: Performance degradation

**P2 (Warning)**:
- Connection rate high: >10K new connections/min
- Memory usage >80%: Potential OOM
- Reconnection rate >5%: Network issues

---

## ADRs (Real-Time Specific)

1. **ADR-001**: Yjs CRDT for conflict-free editing
2. **ADR-002**: Socket.io for WebSocket with fallbacks
3. **ADR-003**: Redis pub/sub for server-to-server sync
4. **ADR-004**: Sticky sessions for WebSocket connections
5. **ADR-005**: MongoDB for CRDT snapshot storage
6. **ADR-006**: Snapshot every 100 updates (performance)

---

**Status**: Active (Real-Time Architecture)
**Last Updated**: 2025-10-31
**Performance SLA**: <200ms sync latency (p95)
```

### Output

```
Architecture Blueprint Created (Real-Time Collaborative)

Location: .spec/architecture-blueprint.md
Type: Greenfield (Real-Time Architecture)
ADRs Created: 6 decisions logged

Real-Time Architecture:
  ✓ CRDT: Yjs for conflict-free editing
  ✓ Transport: WebSocket (Socket.io) with fallbacks
  ✓ Sync: Redis pub/sub for multi-server coordination
  ✓ Storage: MongoDB (snapshots) + S3 (backups)
  ✓ Scaling: Horizontal with sticky sessions

Performance Targets:
  • Local edits: <50ms (optimistic UI updates)
  • Remote edits: <200ms (network synchronization)
  • Document load: <500ms (initial state)
  • Concurrent users: 50 per document
  • Total capacity: 100K+ WebSocket connections

Key Patterns:
  • CRDT for automatic conflict resolution
  • Sticky sessions for WebSocket affinity
  • Snapshot every 100 updates (performance optimization)
  • Presence awareness (live cursors, user colors)

Scaling Strategy:
  • WebSocket servers: Auto-scale on CPU and connections
  • Redis pub/sub: One instance per cluster
  • MongoDB: Sharded by docId
  • Graceful shutdown for zero-downtime deploys

Monitoring:
  • Real-time dashboard: Active connections, latency, messages/sec
  • Alerts: Latency >500ms, server down, Redis failure
  • Metrics: CRDT performance, update propagation time

Next Steps:
  1. Review real-time architecture with team
  2. Prototype CRDT integration with TipTap editor
  3. Load test WebSocket scaling (target: 10K concurrent users)
  4. Run `spec:generate "Document Collaboration"` to begin development
```

**Files Created**:
- `.spec/architecture-blueprint.md` (3,400 tokens, real-time focus)
- `.spec-memory/DECISIONS-LOG.md` (6 ADRs)
- `.spec-memory/WORKFLOW-PROGRESS.md` (Feature 000 completed)

---

## Summary: Common Patterns Across Examples

### Pattern Recognition

**Greenfield Projects** (Examples 1, 4, 5):
1. Interactive questions to gather requirements
2. Research best practices (WebSearch)
3. Define ideal architecture
4. Create comprehensive ADRs for all decisions
5. No [TODO] tags (clean slate)

**Brownfield Projects** (Example 2):
1. Automated codebase analysis (Glob, Grep, Read)
2. Extract current technology stack
3. Document existing patterns
4. Identify technical debt with [TODO] tags
5. Create ADRs documenting existing decisions

**Migration Projects** (Example 3):
1. Read existing blueprint
2. Design target architecture
3. Create phased migration plan
4. Update sections (not full rewrite)
5. ADRs explain migration rationale

**Compliance-Focused** (Example 4):
1. Research compliance requirements (WebSearch)
2. Security-first architecture
3. Detailed security sections
4. Compliance checklist
5. ADRs justify security decisions

**Specialized Architecture** (Example 5):
1. Domain-specific patterns (real-time, ML, etc.)
2. Performance targets defined
3. Specialized technology choices
4. Monitoring focused on domain metrics
5. ADRs explain specialized decisions

---

**Token Size**: ~8,700 tokens (detailed, comprehensive examples)
**Updated**: 2025-10-31
**Skills Referenced**: spec:init, spec:generate, spec:update
**Next**: See REFERENCE.md for section templates and brownfield analysis patterns
