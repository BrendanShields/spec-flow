# Flow Plan Reference

## Output Artifacts

### plan.md
Main implementation plan with:
- Architecture overview
- Technology stack with rationale
- Component breakdown
- Integration patterns
- Implementation phases
- Risk mitigation strategies

### research.md
Technical research and decisions:
- Architecture Decision Records (ADRs)
- Technology evaluations
- Alternative approaches considered
- Best practices research
- Performance considerations

### data-model.md
Entity definitions:
- Database schema
- Entity relationships
- Field specifications
- Validation rules
- Migration strategies

### contracts/
API specifications:
- `openapi.yaml` - REST API contracts
- `graphql.schema` - GraphQL schemas
- `events.yaml` - Event definitions (microservices)
- `webhooks.yaml` - Webhook specifications

### quickstart.md
Test scenarios:
- cURL examples for API testing
- Sample requests/responses
- Authentication flows
- Error cases
- Integration test scenarios

## ADR Format

Architecture Decision Records follow this structure:

```markdown
### ADR-### : [Decision Title]

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Deprecated | Superseded by ADR-###

**Context**:
[What problem are we solving? What constraints exist?]

**Decision**:
[What did we decide to do?]

**Alternatives Considered**:
1. **[Option A]**: [Why rejected]
2. **[Option B]**: [Why rejected]

**Rationale**:
[Why this choice over alternatives?]

**Consequences**:
- Positive: [Benefits]
- Negative: [Trade-offs, technical debt]

**Implementation Notes**:
[Specific guidance for implementing this decision]
```

## Research Process

### Phase 0: Technical Research

The `flow-researcher` subagent executes research for:

1. **Technology Evaluation**
   - Identify candidate libraries/frameworks
   - Compare features, maturity, community support
   - Performance benchmarks
   - License compatibility
   - Team expertise considerations

2. **Architecture Patterns**
   - Evaluate patterns for the problem domain
   - Consider scalability requirements
   - Assess testability implications
   - Integration complexity

3. **Best Practices**
   - Industry standards (REST, GraphQL conventions)
   - Security guidelines (OWASP, etc.)
   - Performance optimization patterns
   - Error handling strategies

### Research Triggers

Researcher runs when spec contains:
- "TBD" or "TODO" markers
- Multiple technology options mentioned
- Undefined architecture patterns
- Performance requirements without approach
- Security requirements needing strategy

### Research Output

`research.md` contains:
- Summary of research findings
- Recommendations with justification
- ADRs for major decisions
- Links to external resources
- Code examples from research

## MCP Integration (Confluence)

### Confluence Sync Configuration

Enable in `CLAUDE.md`:
```
FLOW_ATLASSIAN_SYNC=enabled
FLOW_CONFLUENCE_SYNC_PLAN=true
FLOW_CONFLUENCE_ROOT_PAGE_ID=123456
```

### Sync Process

**After plan generation**:

1. **Locate Feature Page**
   ```javascript
   // Find feature page created by flow:specify
   const featurePage = await mcp.confluence.getPageByTitle({
     spaceKey: config.FLOW_CONFLUENCE_SPACE,
     title: featureName
   });
   ```

2. **Create Implementation Plan Subpage**
   ```javascript
   const planPage = await mcp.confluence.createPage({
     parentId: featurePage.id,
     title: 'Implementation Plan',
     body: convertToConfluenceFormat(plan)
   });
   ```

3. **Sync Architecture Decisions**
   ```javascript
   // Format ADRs as Confluence decision table
   const adrTable = {
     type: 'table',
     headers: ['Decision', 'Status', 'Rationale', 'Consequences'],
     rows: research.adrs.map(adr => ({
       decision: adr.title,
       status: adr.status,
       rationale: adr.rationale,
       consequences: adr.consequences
     }))
   };

   await mcp.confluence.appendContent({
     pageId: planPage.id,
     section: 'Architecture Decisions',
     content: adrTable
   });
   ```

4. **Sync Data Model**
   ```javascript
   // Convert data-model.md to entity relationship diagram
   const entityDiagram = generateMermaidDiagram(dataModel);

   await mcp.confluence.appendContent({
     pageId: planPage.id,
     section: 'Data Model',
     content: {
       type: 'mermaid',
       diagram: entityDiagram
     }
   });
   ```

5. **Sync API Contracts**
   ```javascript
   // Embed OpenAPI spec as interactive viewer
   await mcp.confluence.appendContent({
     pageId: planPage.id,
     section: 'API Contracts',
     content: {
       type: 'code',
       language: 'yaml',
       code: fs.readFileSync('contracts/openapi.yaml'),
       collapsible: true
     }
   });
   ```

6. **Create Timeline**
   ```javascript
   // Generate Gantt chart from implementation phases
   const ganttChart = convertToGantt(plan.phases);

   await mcp.confluence.appendContent({
     pageId: planPage.id,
     section: 'Implementation Timeline',
     content: {
       type: 'chart',
       chartType: 'gantt',
       data: ganttChart
     }
   });
   ```

### Confluence Page Structure

```
Feature: User Authentication (Epic Page)
├── Specification (created by flow:specify)
│   ├── User Stories
│   ├── Acceptance Criteria
│   └── Non-functional Requirements
└── Implementation Plan (created by flow:plan)
    ├── Architecture Overview
    ├── Architecture Decisions (ADRs as table)
    ├── Technology Stack (with rationale)
    ├── Data Model (entity diagram + tables)
    ├── API Contracts (collapsible code blocks)
    ├── Integration Patterns
    ├── Implementation Timeline (Gantt chart)
    └── Risk Mitigation
```

### Bidirectional Sync

**Plan updates flow both ways**:

1. **Local → Confluence**
   - Re-run `flow:plan` → Updates Confluence page
   - Preserves Confluence comments
   - Version history maintained

2. **Confluence → Local** (future)
   - Architect adds comments on Confluence
   - `flow:sync --from-confluence` pulls comments
   - Integrates feedback into local plan

### Collaboration Features

**Confluence Comments**:
- Architects review and comment on decisions
- PM questions specific technical choices
- Flow syncs back comment resolutions

**Page Watchers**:
- Auto-watch feature: entire team notified of plan updates
- Links to JIRA stories for complete context

**Version History**:
- Each plan update creates new Confluence version
- Compare versions to see technical evolution
- Restore previous plan if needed

### Benefits

| Benefit | Description |
|---------|-------------|
| Team Visibility | Non-developers review plan in familiar interface |
| Async Review | Architects comment without blocking Flow |
| Audit Trail | Complete history of technical decisions |
| Traceability | Linked JIRA stories + Confluence docs + code |
| Knowledge Base | Plans become searchable documentation |

## Configuration Options

### Flag: `--minimal`

Skip research phase, use obvious choices:
```bash
flow:plan --minimal
```

Behavior:
- No `flow-researcher` subagent execution
- No ADRs generated
- Uses existing project patterns
- Faster execution (~30s vs ~2min)

Use when:
- POC/prototype code
- Technology stack already determined
- Simple CRUD features
- Tight deadlines

### Flag: `--update`

Update existing plan:
```bash
flow:plan --update
```

Behavior:
- Loads existing `plan.md`
- Highlights changes from previous version
- Preserves completed phases
- Generates new ADRs only for changed decisions

Use when:
- Spec changed mid-implementation
- New requirements added
- Technology decision revised
- Integration approach changed

## Blueprint Integration

If `__specification__/architecture-blueprint.md` exists:

**Validation**:
- Checks plan adheres to blueprint patterns
- Validates technology choices against approved stack
- Ensures API design follows guidelines
- Confirms data modeling conventions

**Guidance**:
- References blueprint principles in plan
- Suggests blueprint-compliant approaches
- Documents deviations (with user approval)

**Example**:
```markdown
## Architecture Approach

Following blueprint principle "Modular Monolith Pattern":
- Organize by domain modules (auth, users, orders)
- Shared database with clear boundaries
- Internal service layer (not microservices)

Technology Stack (per blueprint):
- Backend: Node.js + Express (approved)
- Database: PostgreSQL (approved)
- Auth: JWT (aligns with "Stateless APIs" guideline)
```

## Data Model Guidelines

### Entity Definition Format

```markdown
### User

**Table**: `users`

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| email | VARCHAR(255) | UNIQUE, NOT NULL | User email |
| password_hash | VARCHAR(255) | NOT NULL | Bcrypt hash |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Creation time |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Last update |

**Relationships**:
- `tokens` (1:N) - User has many tokens
- `profile` (1:1) - User has one profile

**Indexes**:
- `idx_users_email` on `email`

**Validation**:
- Email: RFC 5322 format
- Password: Min 8 chars, requires uppercase, lowercase, number
```

### Naming Conventions

Follow blueprint if exists, otherwise:
- Tables: Plural snake_case (`users`, `auth_tokens`)
- Fields: snake_case (`created_at`, `password_hash`)
- Primary keys: `id` (UUID recommended)
- Foreign keys: `{table}_id` (`user_id`, `order_id`)
- Timestamps: `created_at`, `updated_at` (required)

## API Contract Guidelines

### OpenAPI Structure

```yaml
openapi: 3.0.0
info:
  title: Feature API
  version: 1.0.0
  description: Generated by flow:plan

paths:
  /api/v1/resource:
    post:
      summary: Create resource
      tags: [Resources]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateResourceRequest'
      responses:
        201:
          description: Resource created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Resource'
        400:
          $ref: '#/components/responses/BadRequest'
        401:
          $ref: '#/components/responses/Unauthorized'

components:
  schemas:
    Resource:
      type: object
      required: [id, name]
      properties:
        id:
          type: string
          format: uuid
        name:
          type: string
          minLength: 1
          maxLength: 255
        created_at:
          type: string
          format: date-time
```

### Versioning Strategy

Follow blueprint guideline or default:
- **URI versioning**: `/api/v1/resource` (most common)
- **Header versioning**: `Accept: application/vnd.api.v1+json`
- **Query param**: `/api/resource?version=1`

Document chosen strategy in plan with rationale.

## Performance Considerations

### Included in Plan

When spec has performance requirements:
- **Database**: Indexing strategy, query optimization
- **Caching**: Redis layer for hot data
- **API**: Pagination, rate limiting, response compression
- **Async**: Background jobs for heavy operations

### Example Section

```markdown
## Performance Strategy

Requirements: <500ms API response, handle 1000 req/s

Approach:
1. **Database Optimization**
   - Add indexes on frequently queried fields
   - Use connection pooling (max 20 connections)

2. **Caching Layer**
   - Redis for user sessions (TTL: 15 min)
   - Cache invalidation on write operations

3. **API Optimizations**
   - Pagination: 50 items per page
   - Response compression (gzip)
   - Rate limiting: 100 req/min per user

4. **Monitoring**
   - APM for request tracing
   - Alert on >500ms p95 latency
```

## Security Guidelines

### Included When

Spec mentions:
- Authentication/authorization
- Sensitive data (PII, payments)
- External integrations
- Public APIs

### Security Section Template

```markdown
## Security Approach

1. **Authentication**
   - JWT tokens (15 min access, 7 day refresh)
   - Bcrypt password hashing (cost factor: 12)
   - MFA support (TOTP)

2. **Authorization**
   - Role-based access control (RBAC)
   - Resource ownership validation
   - Principle of least privilege

3. **Data Protection**
   - Encrypt sensitive fields at rest (AES-256)
   - TLS 1.3 for data in transit
   - PII handling per GDPR

4. **API Security**
   - Rate limiting (prevent brute force)
   - Input validation (prevent injection)
   - CORS configuration
   - Security headers (CSP, HSTS)
```

## Troubleshooting

### "Plan too generic"
- **Cause**: Research phase skipped or insufficient spec detail
- **Fix**: Re-run with `flow:specify --update` to add detail, then regenerate plan

### "Technology mismatch with blueprint"
- **Cause**: Plan chose tech not in approved stack
- **Fix**: Review blueprint, re-run plan, or update blueprint if tech truly better

### "Confluence sync failed"
- **Cause**: Missing `FLOW_CONFLUENCE_ROOT_PAGE_ID` or permissions
- **Fix**: Check config, verify Confluence space access

### "Research takes too long"
- **Cause**: Complex technical unknowns, many alternatives
- **Fix**: Use `--minimal` flag or specify technology in spec

## Related Files

- `spec.md` - Input specification
- `__specification__/architecture-blueprint.md` - Architecture guidance
- `plan.md` - Output implementation plan
- `research.md` - Research findings and ADRs
- `data-model.md` - Entity definitions
- `contracts/` - API specifications
