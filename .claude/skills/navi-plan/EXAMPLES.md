# Flow Plan Examples

## 1. Greenfield API Feature

**Input**: `features/001-user-auth/spec.md` with authentication requirements

**Execution**:
```
flow:plan

Phase 0: Research & Decisions
  → Researching authentication patterns...
  → Evaluating: JWT vs Session-based vs OAuth2
  → Decision: JWT with refresh tokens
  → ADR-001 created in research.md

Phase 1: Design & Contracts
  → Generating data model...
  → Creating API contracts...
  → Writing quickstart scenarios...

✅ Planning complete
```

**Outputs**:
- `plan.md`: Technical implementation approach
- `research.md`: ADR-001 (JWT decision with rationale)
- `data-model.md`: User, Token, RefreshToken entities
- `contracts/auth-api.yaml`: OpenAPI specification
- `quickstart.md`: cURL test scenarios

**Duration**: ~2 minutes

## 2. Brownfield Integration

**Input**: Adding payment gateway to existing e-commerce app

**Execution**:
```
flow:plan

Phase 0: Research & Decisions
  → Analyzing existing codebase...
  → Found: Express.js, PostgreSQL, REST API
  → Researching payment gateways...
  → Evaluating: Stripe vs PayPal vs Square
  → Decision: Stripe (matches existing patterns)
  → ADR-002 created

Phase 1: Design & Contracts
  → Designing payment entities...
  → Extending existing User model...
  → Creating webhook handlers...
  → Defining API endpoints...
```

**Outputs**:
- Integration plan aligned with existing architecture
- Payment entity design extending current data model
- Webhook specification for Stripe events

## 3. Microservices Architecture

**Input**: Notification service specification

**Execution**:
```
Phase 0: Research
  → Architecture pattern: Event-driven microservice
  → Technology: Node.js + Redis + WebSockets
  → Message queue: RabbitMQ for reliability
  → ADR-003: Why event-driven over REST polling

Phase 1: Design
  → Data model: Notification, Subscription entities
  → Event contracts: user.created, order.completed, etc.
  → API: REST + WebSocket endpoints
  → Integration: Publishes to shared event bus
```

**Outputs**:
- Microservice architecture plan
- Event schema definitions
- Service boundaries and responsibilities

## 4. Confluence Sync (Enterprise)

**With `FLOW_ATLASSIAN_SYNC=enabled`**:

```
flow:plan

✅ Planning complete

📄 Syncing to Confluence...
  → Creating "Implementation Plan" page under feature
  → Uploading architecture decisions...
  → Formatting data model as entity tables...
  → Embedding API contracts...
  → Creating phase timeline diagram...

✅ Confluence sync complete
View: https://company.atlassian.net/wiki/spaces/PROJ/pages/12345
```

**Confluence page includes**:
- Architecture decisions formatted as decision tables
- Interactive data model with entity relationships
- Collapsible API contract code blocks
- Gantt chart showing implementation phases
- Links to related JIRA stories

## 5. Minimal Plan (POC Mode)

**Input**: Quick POC without extensive research

**Execution**:
```
flow:plan --minimal

Skipping research phase...
Using obvious technical choices...

✅ Minimal plan created
- Simple architecture approach
- Technology: defaults to existing stack
- No ADRs (POC code)
```

**Duration**: ~30 seconds

For detailed MCP integration and configuration options, see [REFERENCE.md](./REFERENCE.md).
