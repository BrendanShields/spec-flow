# plan phase - Planning Examples

This file contains concrete scenarios demonstrating the plan phase skill in action.

## Example 1: REST API Planning

### Input Scenario

**Specification** ({config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}):
```markdown
# Feature 002: Product Search

## User Stories
- US2.1: User can search products by keyword [P1]
- US2.2: User can filter by category, price range [P2]
- US2.3: User sees autocomplete suggestions [P2]

## Acceptance Criteria
- Search returns results in <200ms
- Supports 10,000+ concurrent users
- Handles typos with fuzzy matching
```

**Context**:
- Existing tech stack: Node.js, Express, PostgreSQL
- No search infrastructure yet
- Need to support e-commerce scale

### Skill Execution

**Step 1: Research**
- Invokes spec:researcher: "Best practices for product search at scale"
- Findings: Elasticsearch recommended for full-text search
- Alternatives: PostgreSQL full-text (rejected - performance at scale)

**Step 2: Generate Plan**

Creates `{config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan}`:
```markdown
# Product Search - Technical Plan

## Overview
Implement full-text search using Elasticsearch 8.x. Products indexed from PostgreSQL via change data capture. Search API exposes REST endpoint with pagination, filtering, and autocomplete.

## Data Model

### Elasticsearch Index: products
```json
{
  "mappings": {
    "properties": {
      "id": { "type": "keyword" },
      "name": { "type": "text", "analyzer": "standard" },
      "description": { "type": "text" },
      "category": { "type": "keyword" },
      "price": { "type": "float" },
      "in_stock": { "type": "boolean" },
      "tags": { "type": "keyword" }
    }
  }
}
```

## API Contracts

### GET /api/search
**Request**:
```json
{
  "query": "laptop",
  "filters": {
    "category": ["electronics"],
    "price_range": [500, 2000]
  },
  "page": 1,
  "limit": 20
}
```

**Response**:
```json
{
  "results": [...],
  "total": 143,
  "page": 1,
  "pages": 8
}
```

### GET /api/search/autocomplete
[Autocomplete endpoint specification...]

## Architecture

**Components**:
1. Search Service (Node.js + Elasticsearch client)
2. Indexing Pipeline (PostgreSQL → Elasticsearch sync)
3. API Gateway (Express routes)

**Data Flow**:
Product Created → PostgreSQL → CDC → Elasticsearch → Search Query → API Response

## Implementation Notes

**Setup**:
1. Deploy Elasticsearch cluster (Docker Compose for dev)
2. Create index with mappings
3. Implement bulk indexing script
4. Set up CDC with pg_notify

**Key Files**:
- src/services/search-service.ts
- src/config/elasticsearch.ts
- scripts/index-products.ts

## Testing Strategy
- Unit: Search query builder logic
- Integration: Elasticsearch index operations
- E2E: Full search workflow with test data
```

**Step 3: Document ADRs**

Appends to `{config.paths.memory}/DECISIONS-LOG.md`:
```markdown
## ADR-003: Use Elasticsearch for Product Search

**Date**: 2025-10-31
**Status**: Accepted
**Context**: Feature 002 - Need fast, scalable product search

### Decision
Implement search using Elasticsearch 8.x instead of PostgreSQL full-text search.

### Rationale
- Sub-200ms response at scale (tested: 10K+ products)
- Built-in relevance scoring and fuzzy matching
- Autocomplete support out of box
- Horizontal scaling for traffic spikes

### Consequences
**Positive**:
- Meets performance requirements
- Rich search features (facets, suggestions)
- Proven at e-commerce scale

**Negative**:
- Additional infrastructure to maintain
- Data sync complexity (CDC required)
- Team learning curve (~1 week)

**Alternatives Considered**:
- PostgreSQL full-text: Good for <1K products, slow at scale
- Algolia: Great DX but cost prohibitive ($500/mo vs $50/mo ES)
```

### Output

```
Plan created for Feature 002: Product Search

Files generated:
  - {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan} (1,847 tokens)
  - {config.paths.memory}/DECISIONS-LOG.md (updated with 1 ADR)

Architecture decisions documented:
  - ADR-003: Use Elasticsearch for Product Search

Technology choices researched:
  - Elasticsearch 8.x (selected)
  - PostgreSQL full-text (evaluated)
  - Algolia (evaluated)

Next steps:
  1. Review plan.md for technical accuracy
  2. Validate Elasticsearch setup requirements
  3. Run: tasks phase (to create task breakdown)
```

---

## Example 2: Frontend Component Planning

### Input Scenario

**Specification** ({config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}):
```markdown
# Feature 005: Analytics Dashboard

## User Stories
- US5.1: User sees real-time sales metrics [P1]
- US5.2: User can filter by date range [P1]
- US5.3: User exports data as CSV [P2]
```

**Context**:
- React + TypeScript frontend
- Backend API already provides metrics endpoint
- Need responsive design

### Plan Output (Condensed)

```markdown
# Analytics Dashboard - Technical Plan

## Overview
React dashboard using Recharts for visualization. Real-time updates via WebSocket. State management with React Query for server state, Zustand for UI state.

## Component Hierarchy
```
Dashboard (page)
├── MetricsCards (sales, revenue, users)
├── DateRangeFilter (date picker)
├── SalesChart (line chart, real-time)
└── ExportButton (CSV download)
```

## Data Model

**API Response**:
```typescript
interface MetricsData {
  timestamp: string;
  sales: number;
  revenue: number;
  activeUsers: number;
}
```

## Architecture

**State Management**:
- Server state: React Query (caching, refetching)
- UI state: Zustand (filters, date range)
- Real-time: WebSocket hook

**Key Libraries**:
- recharts: Charting (12KB gzipped)
- date-fns: Date manipulation (2KB gzipped)
- react-query: Server state (9KB gzipped)

## Implementation Notes

**File Structure**:
```
src/pages/Dashboard/
├── Dashboard.tsx (main component)
├── components/
│   ├── MetricsCards.tsx
│   ├── SalesChart.tsx
│   └── DateRangeFilter.tsx
├── hooks/
│   ├── useMetrics.ts (React Query)
│   └── useWebSocket.ts
└── Dashboard.test.tsx
```

## Testing Strategy
- Unit: Individual components (Jest + RTL)
- Integration: Dashboard with mocked API
- Visual: Storybook for all components
```

**ADR**: ADR-008: Use Recharts for dashboard visualization

---

## Example 3: Microservice Architecture Planning

### Input Scenario

**Specification** ({config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}):
```markdown
# Feature 010: Notification System

## User Stories
- US10.1: User receives email notifications [P1]
- US10.2: User receives in-app notifications [P1]
- US10.3: User manages notification preferences [P2]
```

**Context**:
- Microservices architecture
- Event-driven with RabbitMQ
- Multi-tenant SaaS

### Plan Output (Condensed)

```markdown
# Notification System - Technical Plan

## Overview
Standalone notification microservice consuming events from RabbitMQ. Supports email (SendGrid), in-app (WebSocket), and push (future). Preferences stored in dedicated PostgreSQL database.

## Architecture

**Services**:
1. Notification Service (Node.js)
   - Event consumer (RabbitMQ)
   - Template renderer (Handlebars)
   - Delivery orchestrator
2. Notification API (Express)
   - REST endpoints for preferences
   - WebSocket server for in-app
3. Notification DB (PostgreSQL)
   - Notification history
   - User preferences

**Event Flow**:
```
User Action → Main Service → RabbitMQ → Notification Service → SendGrid/WebSocket → User
```

## Data Model

### Database Tables

**notifications**:
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL,
  user_id UUID NOT NULL,
  type VARCHAR(50) NOT NULL,
  channel VARCHAR(20) NOT NULL, -- email, in_app, push
  status VARCHAR(20) NOT NULL, -- pending, sent, failed
  template_id VARCHAR(100) NOT NULL,
  data JSONB NOT NULL,
  sent_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**user_preferences**:
```sql
CREATE TABLE user_preferences (
  user_id UUID PRIMARY KEY,
  email_enabled BOOLEAN DEFAULT true,
  in_app_enabled BOOLEAN DEFAULT true,
  preferences JSONB, -- per-notification-type settings
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## API Contracts

### POST /api/notifications/send (internal)
[Internal endpoint for triggering notifications...]

### GET /api/notifications/preferences
[User preference management...]

## Implementation Notes

**RabbitMQ Setup**:
- Exchange: notifications (topic)
- Queue: notification-service
- Routing keys: notification.email.*, notification.in_app.*

**Deployment**:
- Separate service (can scale independently)
- Environment variables for SendGrid API key
- Health check endpoint for k8s

## Testing Strategy
- Unit: Template rendering, event parsing
- Integration: RabbitMQ message flow
- E2E: Full notification delivery
```

**ADRs**:
- ADR-015: Use RabbitMQ for event-driven notifications
- ADR-016: SendGrid for transactional email
- ADR-017: Separate microservice for notifications

---

## Example 4: Database Design Planning

### Input Scenario

**Specification** ({config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}):
```markdown
# Feature 003: Multi-Tenant Data Isolation

## User Stories
- US3.1: Each organization has isolated data [P1]
- US3.2: Users belong to one or more organizations [P1]
- US3.3: Admin can manage organization settings [P2]
```

**Context**:
- PostgreSQL database
- SaaS application with 100+ tenants expected
- Need strong data isolation

### Plan Output (Condensed)

```markdown
# Multi-Tenancy - Technical Plan

## Overview
Schema-per-tenant architecture using PostgreSQL schemas. Tenant context via middleware. Shared tables for auth, tenant metadata in public schema.

## Data Model

### Architecture: Schema-per-Tenant

**Public Schema** (shared):
- users
- tenants
- subscriptions

**Per-Tenant Schema** (isolated):
- products
- orders
- customers
- [all domain data]

### Migration Strategy

**Tenant Creation**:
```sql
-- 1. Create schema
CREATE SCHEMA tenant_<uuid>;

-- 2. Apply migrations
SELECT apply_migrations('tenant_<uuid>');

-- 3. Set up RLS policies
SELECT configure_rls('tenant_<uuid>');
```

## Architecture

**Tenant Context Middleware**:
```typescript
async function tenantContext(req, res, next) {
  const tenantId = req.user.tenantId;

  // Set search_path for this connection
  await db.query(`SET search_path TO tenant_${tenantId}, public`);

  next();
}
```

**Connection Pooling**:
- Use pgBouncer in transaction mode
- One pool per application instance
- search_path set per transaction

## Security Considerations

**Data Isolation**:
- PostgreSQL schemas provide strong isolation
- RLS policies as additional safeguard
- No cross-tenant queries possible

**Performance**:
- Index per schema (automatic)
- Maintenance per tenant (can customize)
- Vacuum/analyze scheduled per schema

## Implementation Notes

**Key Files**:
- src/middleware/tenant-context.ts
- migrations/tenant-template/ (schema setup)
- scripts/create-tenant.ts

**Migration Process**:
1. Apply to public schema (shared tables)
2. Create template migration for tenant schema
3. Apply to all existing tenants
4. Test with multiple tenants

## Testing Strategy
- Unit: Tenant context middleware
- Integration: Schema isolation (can't query other tenant)
- Load: 1000 tenants with realistic data
```

**ADR**: ADR-004: Use schema-per-tenant for data isolation

---

## Example 5: Planning with Constraints

### Input Scenario

**Specification** ({config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}):
```markdown
# Feature 007: Offline Mode

## User Stories
- US7.1: App works without internet [P1]
- US7.2: Changes sync when online [P1]
```

**Project Constraints** (from CLAUDE.md):
```markdown
TECH_STACK=React Native
DATABASE=SQLite (local)
BACKEND=Node.js + PostgreSQL
CONSTRAINT_PLATFORM=iOS + Android
CONSTRAINT_OFFLINE_FIRST=required
```

### Plan Output (Condensed)

```markdown
# Offline Mode - Technical Plan

## Overview
Local-first architecture with SQLite on device. Conflict-free replication using CRDT (WatermelonDB). Background sync when online. Optimistic UI updates.

## Data Model

**Local SQLite Schema**:
- Mirrors server schema
- Additional metadata: sync_status, last_synced_at, version

**Sync Metadata**:
```typescript
interface SyncMetadata {
  entityType: string;
  entityId: string;
  localVersion: number;
  serverVersion: number;
  syncStatus: 'synced' | 'pending' | 'conflict';
  lastSyncedAt: Date;
}
```

## Architecture

**Layers**:
1. UI Layer (React Native components)
2. Data Access Layer (WatermelonDB)
3. Sync Layer (Background sync service)
4. API Layer (REST client with queue)

**Sync Strategy**:
- Pull: Every 30s when online (background)
- Push: Immediate on change (queued if offline)
- Conflict resolution: Last-write-wins with manual review

## Implementation Notes

**Libraries**:
- WatermelonDB: Local database with sync (chosen for React Native + SQLite)
- NetInfo: Network status detection
- react-native-background-task: Background sync

**Sync Flow**:
```
User Action → Local DB (immediate) → Sync Queue → API (when online) → Server DB
              ↓
         Optimistic UI Update
```

**Conflict Handling**:
- Detect: Compare versions during sync
- Resolve: Server version wins, local saved as "conflict" record
- Notify: User sees conflict notification

## Testing Strategy
- Unit: Sync queue logic, conflict detection
- Integration: Full sync cycle (offline → online)
- E2E: User workflow with network toggle
```

**ADR**: ADR-010: Use WatermelonDB for offline-first sync

---

## Common Planning Patterns

### Pattern 1: Technology Selection
1. Identify requirement (e.g., "fast search")
2. Research alternatives (Elasticsearch, PostgreSQL, Algolia)
3. Evaluate criteria (performance, cost, complexity)
4. Document decision as ADR
5. Include in plan with justification

### Pattern 2: API Design
1. Extract endpoints from user stories
2. Define request/response contracts
3. Specify error handling
4. Document authentication/authorization
5. Add OpenAPI spec (if applicable)

### Pattern 3: Data Modeling
1. Identify entities from spec
2. Define relationships
3. Design schema (SQL or NoSQL)
4. Plan migrations
5. Consider indexes and performance

### Pattern 4: Architecture Diagramming
1. Identify system components
2. Define interactions and data flow
3. Document with text-based diagrams (ASCII, Mermaid)
4. Explain rationale for structure

### Pattern 5: Risk Assessment
1. Identify technical risks
2. Propose mitigation strategies
3. Document in plan
4. Track in project management tool

---

## Tips for Effective Planning

1. **Keep spec in focus**: Plan should directly address all user stories
2. **Be specific**: Include code snippets, schema definitions, file paths
3. **Research thoroughly**: Use spec:researcher for unfamiliar domains
4. **Document decisions**: Every major choice should have an ADR
5. **Think about testing**: Include test strategy in every plan
6. **Consider deployment**: How will this be deployed/operated?
7. **Balance detail**: Enough to guide implementation, not prescriptive code

---

*For technical specifications and templates, see reference.md*
