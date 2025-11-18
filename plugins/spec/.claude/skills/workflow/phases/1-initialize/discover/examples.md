# Spec Discover - Examples

Concrete usage scenarios for brownfield codebase analysis.

## Example 1: New Team Member Onboarding

**Context**: Junior developer joins team, needs to understand existing Node.js microservices project.

**Command**:
```bash
discover phase --mode standard
```

**Workflow**:
1. Detects Node.js with Express, TypeScript, PostgreSQL, Redis
2. Identifies microservices architecture (6 services)
3. Maps REST API endpoints across services
4. Discovers database schema (15 tables)
5. Finds 68% test coverage
6. Generates onboarding checklist

**Output** (`discovery/project-overview.md`):
```markdown
# Project Discovery Report

## Executive Summary
- **Project Age**: ~2.5 years (based on git history)
- **Technology**: Node.js 18 + TypeScript + Express
- **Architecture**: Microservices (6 services)
- **Database**: PostgreSQL 14 with TypeORM
- **Test Coverage**: 68%
- **Health Score**: 73/100

## Key Metrics
- Total LOC: ~45,000
- Services: 6 (auth, user, order, payment, notification, analytics)
- API Endpoints: 89 REST endpoints
- Dependencies: 47 npm packages
- Technical Debt: Medium (estimated 2 weeks)

## Quick Start
New developers should focus on:
1. Week 1: Review `services/user` (simplest service)
2. Week 1: Understand shared `lib/` utilities
3. Week 2: Trace order flow across services
4. Week 2: First contribution: bug fix in backlog
```

**Generated Checklist** (`discovery/onboarding-checklist.md`):
```markdown
# Onboarding Checklist

## Week 1: Foundation
- [ ] Set up local environment (Docker Compose)
- [ ] Review architecture diagram
- [ ] Study `services/user` (simplest service)
- [ ] Understand database schema
- [ ] Read API documentation
- [ ] Run test suite locally

## Week 2: First Contributions
- [ ] Fix P3 bug from backlog
- [ ] Add unit test to increase coverage
- [ ] Review PR for another team member
- [ ] Shadow senior dev on feature work

## Month 1: Independent Work
- [ ] Implement small P2 feature end-to-end
- [ ] Write technical documentation
- [ ] Participate in sprint planning
- [ ] Contribute to code reviews
```

---

## Example 2: Sprint Planning with JIRA Analysis

**Context**: Product team needs velocity and capacity planning for upcoming sprint. JIRA integration available.

**Command**:
```bash
discover phase --focus backlog
```

**Workflow**:
1. Connects to JIRA via MCP
2. Analyzes last 6 sprints
3. Extracts velocity trends
4. Identifies blocked items
5. Reviews P1 bugs
6. Generates sprint readiness report

**Output** (`discovery/backlog-analysis.md`):
```markdown
# JIRA Backlog Analysis

## Sprint Velocity (Last 6 Sprints)
- Sprint 23: 34 points (completed 32)
- Sprint 24: 38 points (completed 36)
- Sprint 25: 35 points (completed 33)
- Sprint 26: 40 points (completed 38)
- Sprint 27: 36 points (completed 35)
- Sprint 28: 42 points (completed 40)

**Average Velocity**: 36 points/sprint
**Trend**: Increasing (+15% over 6 sprints)
**Confidence**: High (low variance)

## Current Sprint Capacity
- **Recommended**: 38-42 points
- **Team Availability**: 4 developers × 8 days = 32 dev-days
- **Velocity per Dev-Day**: 1.15 points

## Work Distribution
- **Epics**: 8 active
- **Stories**: 45 (12 ready, 23 refinement needed, 10 blocked)
- **Bugs**: 18 (4 P1, 8 P2, 6 P3)
- **Tech Debt**: 12 items (estimated 3 sprints)

## Sprint Readiness
✅ **Ready for Sprint** (12 stories, 45 points):
- PROJ-234: User profile redesign (8 pts)
- PROJ-189: Email notification system (13 pts)
- PROJ-256: Search filter improvements (5 pts)
- ... (9 more stories)

⚠️ **Needs Refinement** (23 stories):
- Missing acceptance criteria: 8 stories
- Dependencies unclear: 5 stories
- Estimates missing: 10 stories

🚫 **Blocked** (10 stories):
- PROJ-145: Waiting on API design review
- PROJ-167: Dependent on infrastructure setup
- PROJ-203: UX mockups not finalized

## Recommendations
1. **This Sprint**: Commit to 40 points from "Ready" list
2. **Refinement Session**: Focus on 10 stories needing criteria
3. **Unblock**: Schedule design review for PROJ-145
4. **Tech Debt**: Allocate 20% capacity (1 dev for 2 days)
```

---

## Example 3: Python Monolith Refactoring Assessment

**Context**: Legacy Python/Django monolith needs microservices migration plan. Need technical debt assessment.

**Command**:
```bash
discover phase --mode deep --focus quality
```

**Workflow**:
1. Scans Django project structure
2. Analyzes module coupling
3. Identifies code complexity hotspots
4. Detects technical debt patterns
5. Suggests service boundaries
6. Estimates refactoring effort

**Output** (`discovery/quality-assessment.md`):
```markdown
# Code Quality Assessment

## Overall Health: 58/100 (Needs Improvement)

## Test Coverage
- **Unit Tests**: 42% coverage
- **Integration Tests**: 18% coverage
- **Overall**: 45% coverage
- **Critical Paths Uncovered**: Payment processing, user authentication

## Technical Debt Hotspots

### High Priority (Refactor Soon)
1. **`payments/processor.py`** (Risk: 0.89)
   - 450 LOC in single file
   - Cyclomatic complexity: 28
   - Changed 47 times in last 6 months
   - Zero test coverage
   - Handles payment transactions (critical path)

2. **`users/models.py`** (Risk: 0.82)
   - God object with 35 methods
   - Circular dependencies with 4 other modules
   - Database queries in model methods
   - Changed 38 times

3. **`core/utils.py`** (Risk: 0.76)
   - 850 LOC of unrelated utilities
   - 23 TODO comments
   - Used by 42 other modules
   - No clear responsibility

### Architectural Issues
- **Tight Coupling**: 68% of modules depend on `core/utils.py`
- **Database Layer**: Direct SQL in views (12 instances)
- **Business Logic**: Scattered across views, models, utils
- **Circular Dependencies**: 5 circular import chains detected

### Code Smells
- **TODO/FIXME**: 89 instances
- **Commented Code**: 234 blocks
- **Long Functions**: 23 functions >100 LOC
- **Duplicate Code**: 15% similarity across modules

## Refactoring Recommendations

### Service Boundary Suggestions
Based on module coupling analysis:

**Service 1: Authentication & Users**
- Modules: `users/`, `auth/`, `permissions/`
- APIs: 12 endpoints
- Estimated Effort: 3 weeks

**Service 2: Payments**
- Modules: `payments/`, `billing/`, `invoices/`
- APIs: 8 endpoints
- Estimated Effort: 4 weeks (high complexity)

**Service 3: Product Catalog**
- Modules: `products/`, `inventory/`, `pricing/`
- APIs: 15 endpoints
- Estimated Effort: 2 weeks

**Service 4: Orders**
- Modules: `orders/`, `cart/`, `checkout/`
- APIs: 10 endpoints
- Estimated Effort: 3 weeks

### Migration Strategy
1. **Phase 1** (2 weeks): Extract shared libraries, add tests
2. **Phase 2** (3 weeks): Split Product Catalog service
3. **Phase 3** (3 weeks): Split Authentication service
4. **Phase 4** (4 weeks): Refactor and split Payments (highest risk)
5. **Phase 5** (3 weeks): Split Orders service
6. **Total Estimated**: 15 weeks

### Pre-Refactoring Work
- Add unit tests to payment processor (2 weeks)
- Document business logic in `payments/` (1 week)
- Set up service infrastructure (Docker, CI/CD) (1 week)
```

---

## Example 4: React + Express Full-Stack Analysis

**Context**: Need complete understanding of React frontend + Express backend for new feature planning.

**Command**:
```bash
discover phase --mode standard
```

**Workflow**:
1. Detects monorepo structure
2. Analyzes frontend (React + Redux)
3. Analyzes backend (Express + TypeScript)
4. Maps API contracts between frontend/backend
5. Discovers shared types
6. Generates comprehensive landscape

**Output** (`discovery/technical-landscape.md`):
```markdown
# Technical Landscape

## Architecture Pattern: Monorepo Full-Stack
**Confidence**: 0.95 (High)

```
┌─────────────────────────────────────────┐
│          Monorepo Root                  │
├─────────────────────────────────────────┤
│  packages/                              │
│    ├── web/           (React Frontend)  │
│    ├── api/           (Express Backend) │
│    ├── shared/        (Common Types)    │
│    └── mobile/        (React Native)    │
└─────────────────────────────────────────┘
```

## Technology Stack

### Frontend (`packages/web/`)
- **Framework**: React 18.2.0
- **State**: Redux Toolkit 1.9.5 + RTK Query
- **Styling**: Tailwind CSS 3.3.0
- **Forms**: React Hook Form 7.45.0
- **Routing**: React Router 6.14.0
- **Build**: Vite 4.4.0

### Backend (`packages/api/`)
- **Runtime**: Node.js 18.17.0
- **Framework**: Express 4.18.2 + TypeScript 5.1.6
- **Database**: PostgreSQL 14 with Prisma ORM 5.1.1
- **Auth**: Passport.js + JWT
- **Validation**: Zod 3.21.4
- **Testing**: Jest 29.6.0

### Shared (`packages/shared/`)
- **Purpose**: TypeScript types shared between frontend/backend
- **Contents**: API contracts, domain models, validation schemas
- **Usage**: Imported by both `web/` and `api/`

## API Catalog

### Discovered Endpoints (32 total)

**Authentication** (`/api/auth/*`)
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `GET /api/auth/me` - Current user profile

**Users** (`/api/users/*`)
- `GET /api/users` - List users (admin)
- `GET /api/users/:id` - Get user details
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

**Products** (`/api/products/*`)
- `GET /api/products` - List products (paginated)
- `POST /api/products` - Create product
- `GET /api/products/:id` - Get product details
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product

[... 20 more endpoints]

## Data Models

### Prisma Schema (`packages/api/prisma/schema.prisma`)

**Core Entities**:
- **User**: id, email, name, role, createdAt
- **Product**: id, name, description, price, stock
- **Order**: id, userId, status, total, createdAt
- **OrderItem**: id, orderId, productId, quantity, price
- **Category**: id, name, slug, parentId

**Relationships**:
- User 1:N Orders
- Order 1:N OrderItems
- Product N:M Categories
- Category 1:N Categories (self-referential)

## Frontend Architecture

### State Management Pattern
- **Redux slices**: auth, products, orders, ui
- **RTK Query APIs**: authApi, productsApi, ordersApi
- **Async logic**: Redux Thunks for complex workflows
- **Persistence**: Redux Persist for auth state

### Component Structure
```
src/
├── components/        (Reusable UI components)
├── {config.paths.features}/          (Feature-specific components)
│   ├── auth/
│   ├── products/
│   └── orders/
├── hooks/             (Custom React hooks)
├── store/             (Redux store setup)
├── routes/            (Route definitions)
└── utils/             (Helper functions)
```

## Code Quality Metrics

### Frontend
- **Test Coverage**: 72%
- **Bundle Size**: 245 KB (gzipped)
- **TypeScript**: 100% (strict mode)
- **Linting**: ESLint (0 errors, 3 warnings)

### Backend
- **Test Coverage**: 81%
- **API Response Time**: Avg 120ms
- **TypeScript**: 100% (strict mode)
- **API Versioning**: v1 (no breaking changes)

## Conventions Detected

### Code Style
- **Formatting**: Prettier with shared config
- **Naming**: camelCase for variables/functions, PascalCase for components
- **File Naming**: kebab-case for files
- **Commit Messages**: Conventional Commits (feat, fix, docs, etc.)

### Development Practices
- **Branching**: Git Flow (main, develop, feature/*, hotfix/*)
- **Code Review**: Required 2 approvals before merge
- **CI/CD**: GitHub Actions (lint, test, build, deploy)
- **Testing**: Jest + React Testing Library (frontend), Jest + Supertest (backend)

## Integration Points

### External Services
- **Stripe**: Payment processing (`packages/api/src/services/stripe.ts`)
- **SendGrid**: Email notifications (`packages/api/src/services/email.ts`)
- **AWS S3**: File uploads (`packages/api/src/services/storage.ts`)
- **Redis**: Session storage and caching

### Environment Configuration
- `.env.example` files document required variables
- Separate configs for dev, staging, production
- Secrets managed via environment variables (not in code)
```

---

## Example 5: Quick Discovery for POC

**Context**: Evaluating an unfamiliar open-source project for potential adoption. Need quick assessment.

**Command**:
```bash
discover phase --mode quick --output json
```

**Workflow**:
1. Rapid file structure scan (5 min)
2. Basic tech stack detection
3. Simple metrics collection
4. JSON output for tooling integration

**Output** (`discovery/project-overview.json`):
```json
{
  "discovered_at": "2024-10-31T14:23:00Z",
  "mode": "quick",
  "project": {
    "type": "web-application",
    "primary_language": "javascript",
    "loc": 28500,
    "files": 234,
    "directories": 45
  },
  "tech_stack": {
    "languages": ["JavaScript", "TypeScript", "HTML", "CSS"],
    "frameworks": ["Vue.js 3.2", "Express 4.18"],
    "databases": ["MongoDB"],
    "testing": ["Vitest", "Cypress"],
    "build_tools": ["Vite", "pnpm"]
  },
  "architecture": {
    "pattern": "spa-with-backend",
    "confidence": 0.85
  },
  "quality": {
    "has_tests": true,
    "has_ci": true,
    "has_documentation": true,
    "estimated_coverage": "60-70%"
  },
  "health_score": 68,
  "recommendation": "Suitable for evaluation - good test coverage and active CI"
}
```

---

## Troubleshooting

### Issue: Discovery Takes Too Long

**Symptom**: Analysis runs for >30 minutes

**Solution**:
```bash
# Use quick mode for initial scan
discover phase --mode quick

# Then focus on specific areas
discover phase --focus architecture
discover phase --focus api
```

### Issue: JIRA Connection Fails

**Symptom**: Error: "MCP JIRA tool not available"

**Solution**:
```bash
# Skip JIRA analysis
discover phase --skip-jira

# Or check MCP configuration
cat ~/.claude/mcp-config.json
```

### Issue: Large Monorepo Performance

**Symptom**: Out of memory or extremely slow

**Solution**:
```bash
# Analyze specific subdirectories
cd services/user-service
discover phase --mode standard

# Exclude large directories in config
# Add to claude.md:
# SPEC_DISCOVER_EXCLUDE_PATHS=node_modules,dist,build,.git
```

---

For complete reference documentation, see [REFERENCE.md](./REFERENCE.md).
