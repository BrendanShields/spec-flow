# Discovering Architecture - Examples

## Example 1: Enterprise React + Node.js Microservices Discovery

**Scenario**: New engineer joining a large enterprise project with microservices architecture.

**Starting state**:
```bash
enterprise-app/
├── services/
│   ├── auth-service/
│   ├── user-service/
│   ├── payment-service/
│   └── notification-service/
├── frontend/
│   └── react-app/
├── docker-compose.yml
├── kubernetes/
└── package.json (monorepo)
```

**Execution**:
```bash
/spec → "🔍 Discover Existing" --mode=standard
```

**Analysis process**:
1. **Tech stack detection**:
   - Frontend: React 18.2, TypeScript 5.0, Redux Toolkit
   - Backend: Node.js 20, Express 4.18, each service independent
   - Database: PostgreSQL (3 services), MongoDB (1 service)
   - Infrastructure: Docker, Kubernetes, AWS ECS

2. **Architecture pattern** (90% confidence: Microservices):
   - 4 independent services with separate deployments
   - Each service has own package.json
   - API Gateway pattern detected (nginx config)
   - Event-driven communication (Kafka topics found)

3. **API catalog**:
   - auth-service: 8 REST endpoints (POST /login, /register, etc.)
   - user-service: 12 REST endpoints (CRUD for users, profiles)
   - payment-service: 6 REST endpoints + Stripe webhook
   - notification-service: 4 REST endpoints + WebSocket server

4. **Data models**:
   - Users table (PostgreSQL) - 15 columns, 3 indexes
   - Payments table (PostgreSQL) - 12 columns, 2 foreign keys
   - Notifications collection (MongoDB) - document schema detected

5. **Code quality**:
   - Test coverage: 72% (auth: 85%, user: 78%, payment: 65%, notification: 60%)
   - Technical debt: 234 TODO comments
   - Complexity hotspots: payment-service/stripe-integration.ts (120 lines, cyclomatic 15)

**Generated reports**:

**discovery/project-overview.md**:
```markdown
# Enterprise App - Discovery Report

**Analyzed**: 2025-11-18
**Codebase Age**: 3.2 years (first commit: 2022-03)
**Contributors**: 24 developers
**Health Score**: 82/100 ⭐⭐⭐⭐

## Key Metrics
- **Lines of Code**: 128,450
- **Services**: 4 microservices
- **Test Coverage**: 72%
- **Technical Debt**: 234 items
- **Active Contributors**: 12 (last 6 months)

## Technology Stack
- **Frontend**: React 18.2 + TypeScript 5.0
- **Backend**: Node.js 20 + Express 4.18
- **Databases**: PostgreSQL 15, MongoDB 6
- **Infrastructure**: Kubernetes + AWS ECS
- **Message Queue**: Kafka 3.4

## Architecture
**Pattern**: Microservices (90% confidence)
**Communication**: REST + Event-driven (Kafka)
**Deployment**: Containerized (Docker) → Kubernetes
```

**discovery/technical-landscape.md** (excerpt):
```markdown
# Technical Landscape

## Service Architecture

### auth-service
- **Purpose**: Authentication and authorization
- **Tech**: Express + JWT + bcrypt
- **Database**: PostgreSQL (users, sessions tables)
- **External**: None
- **API**: 8 endpoints (all POST except /verify GET)

### payment-service
- **Purpose**: Payment processing
- **Tech**: Express + Stripe SDK
- **Database**: PostgreSQL (payments, transactions tables)
- **External**: Stripe API, SendGrid (email)
- **API**: 6 endpoints + 1 webhook

## Communication Patterns

### Synchronous (REST)
- Frontend → API Gateway → Services
- Auth header propagation via middleware

### Asynchronous (Kafka)
- user.created → notification-service (welcome email)
- payment.completed → user-service (update subscription)
- payment.failed → notification-service (alert)

## Dependency Graph
```
frontend → api-gateway → auth-service
                      → user-service → Kafka → notification-service
                      → payment-service → Kafka → notification-service
```
```

**discovery/onboarding-checklist.md** (excerpt):
```markdown
# Onboarding Checklist

## Week 1: Environment Setup & Overview
- [ ] Clone repository: `git clone ...`
- [ ] Install dependencies: `npm install` (root), then each service
- [ ] Run local stack: `docker-compose up`
- [ ] Access frontend: http://localhost:3000
- [ ] Read discovery/project-overview.md (this report)
- [ ] Review architecture diagram: discovery/technical-landscape.md

## Week 2: Core Services Deep Dive
- [ ] Study auth-service: services/auth-service/README.md
- [ ] Understand JWT flow: src/middleware/auth.ts
- [ ] Study user-service: CRUD operations in src/controllers/user.controller.ts
- [ ] Trace a request: POST /login → database → JWT creation
- [ ] Run service tests: `npm test` in each service directory

## Week 3: Integration Points
- [ ] Study API Gateway: kubernetes/nginx-ingress.yaml
- [ ] Understand Kafka topics: config/kafka-topics.json
- [ ] Trace async flow: payment completion → notification sent
- [ ] Study external integrations: Stripe (payment-service), SendGrid (notification-service)
- [ ] Review error handling patterns: src/middleware/error-handler.ts

## Week 4: Advanced Patterns & Contributing
- [ ] Study deployment process: .github/workflows/deploy.yml
- [ ] Understand monitoring: Prometheus metrics in each service
- [ ] Review security patterns: rate limiting, input validation
- [ ] Make first contribution: Pick "good first issue" from JIRA
- [ ] Pair with team member on feature development
```

**Result**:
```
✅ Discovery complete!

📊 Reports generated:
   discovery/project-overview.md (executive summary)
   discovery/technical-landscape.md (microservices architecture)
   discovery/api-catalog.md (34 endpoints across 4 services)
   discovery/quality-assessment.md (72% coverage, 234 debt items)
   discovery/onboarding-checklist.md (4-week learning plan)

🎯 Key Findings:
   - Architecture: Microservices (90% confidence)
   - Health Score: 82/100
   - Tech Stack: React + Node.js + PostgreSQL/MongoDB
   - Services: 4 (auth, user, payment, notification)
   - Communication: REST + Kafka event-driven

🚀 Next steps:
   1. Review: discovery/project-overview.md
   2. Onboard: Follow discovery/onboarding-checklist.md
   3. Create blueprint: /spec → "📐 Create Blueprint" --from-discovery
   4. Add feature: /spec → "📝 Define Feature"
```

---

## Example 2: Python Django Monolith Analysis

**Scenario**: Planning refactoring of legacy Django monolith into modular architecture.

**Starting state**:
```bash
django-monolith/
├── myapp/
│   ├── users/
│   ├── products/
│   ├── orders/
│   ├── payments/
│   └── settings.py
├── templates/
├── static/
├── requirements.txt
└── manage.py
```

**Execution**:
```bash
/spec → "🔍 Discover Existing" --mode=deep --focus=architecture
```

**Analysis process**:
1. **Tech stack**:
   - Python 3.10, Django 4.2
   - Database: PostgreSQL (main), Redis (cache)
   - Frontend: Django templates + jQuery

2. **Architecture pattern** (95% confidence: Monolith - Modular):
   - Single Django project with multiple apps
   - Apps have clear boundaries (users, products, orders, payments)
   - Each app has models, views, urls - follows Django conventions
   - Apps communicate via direct imports (tight coupling detected)

3. **Modularity assessment**:
   - **users**: 8 models, 15 views, low coupling (score: 8/10)
   - **products**: 5 models, 12 views, medium coupling (score: 6/10)
   - **orders**: 12 models, 20 views, high coupling (score: 3/10 - imports from 3 other apps)
   - **payments**: 4 models, 8 views, medium coupling (score: 5/10 - Stripe integration)

4. **Technical debt**:
   - 456 TODO comments
   - orders/views.py: 780 lines (recommended: split)
   - Circular dependencies: orders ↔ payments
   - Missing tests: payments app has 0% coverage

**Generated reports**:

**discovery/technical-landscape.md** (excerpt):
```markdown
# Architecture Analysis

## Current Pattern: Monolith (Modular)
**Confidence**: 95%

## App Dependency Graph
```
users (independent)
  ↑
products (depends on users)
  ↑
orders (depends on users, products, payments) ← CIRCULAR
  ↑↓
payments (depends on orders, users) ← CIRCULAR
```

## Refactoring Opportunities

### 1. Break Circular Dependency (orders ↔ payments)
**Problem**: orders imports payments.models.Payment, payments imports orders.models.Order

**Solution**: Introduce event-driven decoupling
- orders emits "order.completed" signal
- payments listens and creates Payment record
- Remove direct import from payments to orders

**Impact**: Reduces coupling score from 3/10 to 7/10

### 2. Split Large View File (orders/views.py - 780 lines)
**Current**: Single file with 25 view functions

**Suggested Split**:
- orders/views/list_views.py (list, filter, search)
- orders/views/detail_views.py (view, edit)
- orders/views/checkout_views.py (cart, checkout, confirmation)

**Impact**: Improves maintainability, reduces merge conflicts

### 3. Add Missing Tests (payments app - 0% coverage)
**Current**: No tests for Stripe integration

**Recommended**:
- Unit tests: payment model methods
- Integration tests: Stripe webhook handling
- Mock Stripe API in tests

**Impact**: Reduces risk for payment processing
```

**discovery/suggested-blueprint.md** (excerpt):
```markdown
# Suggested Architecture Blueprint

## Target: Modular Monolith → Microservices (Phased)

### Phase 1: Decouple Apps (within monolith)
1. Break circular dependencies (orders ↔ payments)
2. Introduce event-driven communication (Django signals)
3. Add API layer for inter-app communication

### Phase 2: Extract Independent Services
1. Extract **users** (most independent, score 8/10)
   - Create users-service with REST API
   - Migrate authentication to separate service
   - Use JWT for cross-service auth

2. Extract **payments** (external dependency: Stripe)
   - Create payments-service
   - Expose webhook endpoint
   - Communicate with orders via events

### Phase 3: Gradual Migration
1. Keep **products** and **orders** in monolith (tightly coupled to business logic)
2. Use strangler fig pattern: New features as microservices
3. Migrate when ready

## Recommended Tech Stack for Services
- **Framework**: FastAPI (modern Python, async)
- **Database**: PostgreSQL (consistent with current)
- **Communication**: REST + RabbitMQ (async events)
- **Auth**: JWT (centralized in users-service)
```

**Result**:
```
✅ Deep analysis complete!

📊 Reports generated:
   discovery/technical-landscape.md (modularity assessment)
   discovery/quality-assessment.md (456 debt items, hotspots identified)
   discovery/suggested-blueprint.md (refactoring roadmap)

🎯 Key Findings:
   - Architecture: Modular Monolith (95% confidence)
   - Health Score: 65/100 ⚠️
   - Modularity: 4 apps, 2 circular dependencies
   - Technical Debt: 456 items (high)
   - Refactoring Opportunity: Extract users + payments first

🚀 Recommended Next Steps:
   1. Fix circular dependency (orders ↔ payments)
   2. Add tests to payments app (0% → 70% target)
   3. Split orders/views.py (780 lines → 3 files)
   4. Create blueprint: /spec → "📐 Create Blueprint" --from-discovery
   5. Plan extraction: /spec → "📝 Define Feature" (Phase 1: Decouple Apps)
```

---

## Example 3: Java Spring Boot + Kubernetes Discovery

**Scenario**: Team needs documentation for undocumented Java microservices before adding new features.

**Starting state**:
```bash
java-microservices/
├── api-gateway/          (Spring Cloud Gateway)
├── user-service/         (Spring Boot + JPA)
├── product-service/      (Spring Boot + MongoDB)
├── order-service/        (Spring Boot + JPA)
├── kubernetes/
│   ├── deployments/
│   └── services/
└── pom.xml (parent)
```

**Execution**:
```bash
/spec → "🔍 Discover Existing" --mode=standard --output=both
```

**Analysis process**:
1. **Tech stack**:
   - Java 17, Spring Boot 3.1
   - Databases: PostgreSQL (user, order), MongoDB (product)
   - Infrastructure: Kubernetes, Istio service mesh

2. **Architecture** (92% confidence: Microservices with API Gateway):
   - 3 business services + 1 gateway
   - Service discovery via Kubernetes DNS
   - Istio handles load balancing, circuit breaking

3. **API catalog** (generated from annotations):
   ```java
   // user-service
   @GetMapping("/users/{id}")         → GET /api/users/{id}
   @PostMapping("/users")             → POST /api/users
   @PutMapping("/users/{id}")         → PUT /api/users/{id}

   // product-service
   @GetMapping("/products")           → GET /api/products
   @GetMapping("/products/{id}")      → GET /api/products/{id}

   // order-service
   @PostMapping("/orders")            → POST /api/orders
   @GetMapping("/orders/{userId}")    → GET /api/orders/{userId}
   ```

4. **Code quality**:
   - Test coverage: 81% (user: 85%, product: 78%, order: 80%)
   - Technical debt: 89 TODO comments (low)
   - No circular dependencies (good service boundaries)

**Generated reports**:

**discovery/api-catalog.md** (excerpt):
```markdown
# API Catalog

## API Gateway Routes
**Endpoint**: https://api.example.com

| Route | Service | Method | Description |
|-------|---------|--------|-------------|
| /api/users/* | user-service | * | User management |
| /api/products/* | product-service | * | Product catalog |
| /api/orders/* | order-service | * | Order processing |

## user-service Endpoints

### GET /api/users/{id}
**Description**: Get user by ID
**Auth**: Required (JWT)
**Response**:
```json
{
  "id": "uuid",
  "username": "string",
  "email": "string",
  "createdAt": "datetime"
}
```

### POST /api/users
**Description**: Create new user
**Auth**: Public
**Request**:
```json
{
  "username": "string",
  "email": "string",
  "password": "string"
}
```
**Response**: 201 Created + user object
```

**discovery/technical-landscape.md** (excerpt with JSON):
```markdown
# Technical Landscape

## Service Inventory

[See JSON output: discovery/technical-landscape.json for machine-readable format]

### user-service
- **Port**: 8081
- **Database**: PostgreSQL (users, profiles tables)
- **Dependencies**: None (leaf service)
- **Dependents**: order-service (for user validation)
- **Health**: 85% test coverage, 23 TODO items

### product-service
- **Port**: 8082
- **Database**: MongoDB (products collection)
- **Dependencies**: None (leaf service)
- **Dependents**: order-service (for product catalog)
- **Health**: 78% test coverage, 31 TODO items

### order-service
- **Port**: 8083
- **Database**: PostgreSQL (orders, order_items tables)
- **Dependencies**: user-service, product-service (REST calls)
- **Dependents**: None
- **Health**: 80% test coverage, 35 TODO items

## Deployment Architecture (Kubernetes)

**Namespace**: production

**Resources**:
- 3 Deployments (1 per service)
- 3 Services (ClusterIP)
- 1 Ingress (api-gateway)
- Istio VirtualService for routing

**Scalability**:
- user-service: 3 replicas
- product-service: 2 replicas
- order-service: 2 replicas
```

**discovery/technical-landscape.json** (excerpt):
```json
{
  "project": {
    "name": "java-microservices",
    "analyzed_at": "2025-11-18T10:30:00Z",
    "health_score": 84,
    "contributors": 12,
    "age_years": 1.8
  },
  "tech_stack": {
    "language": "Java 17",
    "framework": "Spring Boot 3.1",
    "databases": ["PostgreSQL 15", "MongoDB 6"],
    "infrastructure": ["Kubernetes", "Istio"]
  },
  "services": [
    {
      "name": "user-service",
      "port": 8081,
      "database": "PostgreSQL",
      "endpoints": 5,
      "test_coverage": 0.85,
      "dependencies": [],
      "dependents": ["order-service"]
    }
    // ... other services
  ],
  "architecture": {
    "pattern": "microservices",
    "confidence": 0.92,
    "communication": "REST + Istio service mesh",
    "deployment": "Kubernetes"
  }
}
```

**Result**:
```
✅ Discovery complete!

📊 Reports generated (markdown + JSON):
   discovery/project-overview.md + .json
   discovery/technical-landscape.md + .json (Kubernetes architecture)
   discovery/api-catalog.md + .json (16 endpoints across 3 services)
   discovery/quality-assessment.md + .json (81% coverage)

🎯 Key Findings:
   - Architecture: Microservices + API Gateway (92% confidence)
   - Health Score: 84/100
   - Services: 3 business + 1 gateway
   - Deployment: Kubernetes + Istio service mesh
   - Quality: High (81% coverage, low debt)

💡 JSON files available for tooling integration

🚀 Next steps:
   1. Use JSON for automated doc generation
   2. Create blueprint: /spec → "📐 Create Blueprint" --from-discovery
   3. Add feature: /spec → "📝 Define Feature"
```

---

## Example 4: Legacy PHP Application with JIRA Integration

**Scenario**: Assessing legacy PHP app before migration, including backlog analysis for sprint planning.

**Starting state**:
```bash
legacy-php/
├── public/
│   ├── index.php
│   └── api.php
├── includes/
│   ├── db.php
│   ├── auth.php
│   └── functions.php
├── templates/
└── composer.json
```

**Execution**:
```bash
SPEC_ATLASSIAN_SYNC=enabled
SPEC_JIRA_PROJECT_KEY=LEGACY

/spec → "🔍 Discover Existing" --mode=deep
```

**Analysis process**:
1. **Tech stack**:
   - PHP 7.4 (outdated, security risk)
   - MySQL 5.7
   - No framework (procedural PHP)
   - jQuery 1.11 (very outdated)

2. **Architecture** (88% confidence: Monolith - Spaghetti):
   - No clear structure, mixed concerns
   - Business logic in templates
   - Direct database queries in presentation layer
   - Global functions file (1,200 lines)

3. **Code quality**:
   - Test coverage: 0% (no tests)
   - Technical debt: 789 TODO/FIXME comments
   - Security issues: SQL injection risks (no prepared statements)
   - Outdated dependencies: 12 critical vulnerabilities

4. **JIRA backlog analysis** (via MCP):
   - 45 open bugs (12 critical)
   - 23 feature requests
   - 8 tech debt items logged
   - Velocity: Declining (18 → 12 → 8 story points last 3 sprints)

**Generated reports**:

**discovery/project-overview.md** (excerpt):
```markdown
# Legacy PHP App - Discovery Report

**Analyzed**: 2025-11-18
**Codebase Age**: 8.5 years (first commit: 2016-05)
**Contributors**: 3 developers (1 active)
**Health Score**: 32/100 ⚠️⚠️ CRITICAL

## ⚠️ Critical Issues
1. **Security**: 12 critical vulnerabilities, SQL injection risks
2. **PHP Version**: 7.4 (EOL Nov 2022, no security updates)
3. **No Tests**: 0% coverage, high regression risk
4. **Architecture**: Spaghetti code, no separation of concerns

## Recommendation
**Immediate**: Security patches, upgrade PHP to 8.2
**Short-term**: Add tests for critical paths, refactor high-risk areas
**Long-term**: Migrate to Laravel/Symfony framework
```

**discovery/quality-assessment.md** (excerpt):
```markdown
# Code Quality Assessment

## Security Vulnerabilities

### Critical (12 issues)
1. **SQL Injection** (8 instances)
   - Location: includes/db.php:45, public/api.php:78, etc.
   - Example: `mysqli_query("SELECT * FROM users WHERE id=$id")`
   - Fix: Use prepared statements

2. **XSS Vulnerabilities** (4 instances)
   - Location: templates/user-profile.php:23
   - Example: `echo $_GET['name']` (no sanitization)
   - Fix: Use htmlspecialchars() or templating engine

### High (23 issues)
- Outdated dependencies with known vulnerabilities
- Weak password hashing (MD5 instead of bcrypt)
- No CSRF protection on forms

## Technical Debt Hotspots

### includes/functions.php (1,200 lines)
**Issues**:
- God object anti-pattern
- 47 functions, many unrelated
- No namespaces or organization

**Recommended Refactoring**:
- Split into: user-functions.php, product-functions.php, auth-functions.php
- Introduce classes and namespaces
- Use dependency injection instead of globals

### public/index.php (580 lines)
**Issues**:
- Mixed concerns (routing, business logic, presentation)
- No MVC separation

**Recommended Refactoring**:
- Introduce front controller pattern
- Separate routes, controllers, views
- Consider migrating to Laravel/Symfony
```

**discovery/backlog-analysis.md** (excerpt):
```markdown
# JIRA Backlog Analysis

**Project**: LEGACY
**Analyzed**: 2025-11-18
**Data Source**: JIRA via MCP

## Sprint Velocity Trends

| Sprint | Planned | Completed | Velocity |
|--------|---------|-----------|----------|
| Sprint 23 | 20 | 18 | 18 pts |
| Sprint 24 | 18 | 12 | 12 pts ⬇️ |
| Sprint 25 | 15 | 8 | 8 pts ⬇️⬇️ |

**Trend**: Declining velocity (-55% over 3 sprints)
**Likely cause**: Technical debt slowing development

## Bug Distribution

| Severity | Count | % |
|----------|-------|---|
| Critical | 12 | 27% ⚠️ |
| High | 18 | 40% |
| Medium | 12 | 27% |
| Low | 3 | 6% |

**Critical Bugs** (12 items):
1. LEGACY-234: SQL injection in user login (reported 45 days ago)
2. LEGACY-189: Session hijacking vulnerability
3. LEGACY-221: Payment processing fails intermittently
... [9 more]

## Technical Debt Items (8 logged)
1. LEGACY-156: Upgrade PHP 7.4 → 8.2 (8 story points)
2. LEGACY-178: Add automated tests (13 story points)
3. LEGACY-201: Refactor includes/functions.php (5 story points)
... [5 more]

## Recommendations for Sprint Planning

### Immediate (Next Sprint)
1. **Fix Critical Security Bugs** (LEGACY-234, LEGACY-189)
   - Estimated: 8 story points
   - Impact: Reduces security risk

2. **Upgrade PHP to 8.2** (LEGACY-156)
   - Estimated: 8 story points
   - Impact: Security patches, performance improvement

### Short-term (Next 2-3 Sprints)
1. **Add Tests for Critical Paths** (LEGACY-178)
   - Estimated: 13 story points (split into 3 tasks)
   - Impact: Reduces regression risk, enables safer refactoring

2. **Refactor includes/functions.php** (LEGACY-201)
   - Estimated: 5 story points
   - Impact: Improves maintainability

### Long-term (Quarter)
1. **Migrate to Framework** (new epic to be created)
   - Estimated: 80-100 story points
   - Impact: Modernizes codebase, improves velocity
```

**Result**:
```
✅ Discovery complete (with critical warnings)

📊 Reports generated:
   discovery/project-overview.md (HEALTH: 32/100 ⚠️)
   discovery/technical-landscape.md (spaghetti architecture)
   discovery/quality-assessment.md (12 critical vulnerabilities)
   discovery/backlog-analysis.md (45 bugs, declining velocity)
   discovery/onboarding-checklist.md (4-week plan + cautions)

🎯 Key Findings:
   - Architecture: Monolith - Spaghetti (88% confidence)
   - Health Score: 32/100 ⚠️ CRITICAL
   - Security: 12 critical vulnerabilities, SQL injection risks
   - Tech Debt: 789 items, declining velocity
   - JIRA: 45 bugs (12 critical), velocity down 55%

⚠️  CRITICAL ACTIONS REQUIRED:
   1. Fix SQL injection (LEGACY-234, LEGACY-189) - THIS SPRINT
   2. Upgrade PHP 7.4 → 8.2 (security EOL) - THIS SPRINT
   3. Add tests before refactoring - NEXT SPRINT
   4. Plan framework migration - NEXT QUARTER

🚀 Next steps:
   1. Review: discovery/quality-assessment.md (security issues)
   2. Create spec for security fixes: /spec → "📝 Define Feature"
   3. After fixes: Create migration blueprint: /spec → "📐 Create Blueprint"
```

---

## Common Patterns

### Pattern 1: Quick Tech Stack Check
**Use case**: Just need to know what frameworks/languages are used

```bash
/spec → "🔍 Discover Existing" --focus=tech-stack --mode=quick
```

**Output**: 5-minute analysis with tech stack summary only.

### Pattern 2: API Documentation Generation
**Use case**: Need API docs for frontend team

```bash
/spec → "🔍 Discover Existing" --focus=api --output=both
```

**Output**: Markdown + JSON API catalog for documentation site.

### Pattern 3: Refactoring Planning
**Use case**: Planning major refactoring, need quality metrics

```bash
/spec → "🔍 Discover Existing" --focus=quality --mode=deep
```

**Output**: Detailed technical debt, complexity hotspots, refactoring suggestions.

### Pattern 4: Sprint Planning with JIRA
**Use case**: Need backlog insights for sprint planning

```bash
SPEC_ATLASSIAN_SYNC=enabled

/spec → "🔍 Discover Existing" --focus=backlog
```

**Output**: JIRA analysis with velocity trends, bug distribution, recommendations.

### Pattern 5: Onboarding New Team Member
**Use case**: New engineer needs to understand codebase

```bash
/spec → "🔍 Discover Existing" --mode=standard
```

**Output**: Comprehensive reports including 4-week onboarding checklist.

---

## Troubleshooting Examples

### Large Codebase (>100k LOC)
**Issue**: Analysis taking too long

**Solution**: Use progressive scanning
```bash
/spec → "🔍 Discover Existing" --mode=quick
# For deep analysis of specific areas:
/spec → "🔍 Discover Existing" --focus=architecture --mode=deep
```

### No Test Coverage Tool
**Warning**: Cannot analyze test coverage

**Workaround**: Reports will skip coverage section, analysis continues.

### JIRA MCP Not Available
**Warning**: Skipping JIRA analysis

**Solution**: Install JIRA MCP or use --skip-jira flag.
