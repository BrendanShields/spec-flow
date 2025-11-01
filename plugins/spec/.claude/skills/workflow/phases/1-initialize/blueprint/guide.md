---
name: spec:blueprint
description: Use when defining project architecture, user mentions "architecture blueprint", "technical standards", "architecture decisions", or need to document tech stack and patterns - creates comprehensive architecture blueprint with technology choices, design patterns, API conventions, and security guidelines
allowed-tools: Read, Write, Edit, WebSearch, Bash
---

# spec:blueprint

Define project architecture and technical standards before feature development.

## What This Skill Does

- Creates `.spec/architecture-blueprint.md` with complete architecture documentation
- Documents technology stack, design patterns, API conventions, data models
- Analyzes existing codebases for brownfield projects to extract current architecture
- Generates Architecture Decision Records (ADRs) for foundational choices
- Establishes development standards and security guidelines
- Integrates with MCP to publish to Confluence (optional)

## When to Use

1. Starting new project and need to define architecture
2. User mentions "create architecture blueprint" or "define technical standards"
3. Adding Spec to existing project (brownfield) and need to document current architecture
4. Team needs alignment on technical decisions before feature development
5. Before running `spec:generate` for the first time
6. When establishing API conventions, data model principles, or security standards

## Execution Flow

### Phase 1: Context Analysis

1. Check if `.spec/` exists (run `spec:init` if missing)
2. Determine project type:
   - **Greenfield**: New project, define ideal architecture
   - **Brownfield**: Existing code, analyze and document current state
3. For brownfield projects:
   - Use Glob to find key files (package.json, requirements.txt, etc.)
   - Use Read to analyze tech stack from dependencies
   - Use Grep to identify patterns (API routes, database usage, etc.)
   - Use WebSearch for current best practices if needed

### Phase 2: Blueprint Creation

Create `.spec/architecture-blueprint.md` with 8 sections:

**1. System Overview**
- High-level architecture diagram (text-based)
- Key components and responsibilities
- Integration points

**2. Technology Stack**
- Languages, frameworks, libraries (with versions)
- Justification for each choice
- Alternative options considered

**3. Architecture Patterns**
- Layered, microservices, event-driven, etc.
- Component organization and boundaries
- Communication patterns between layers

**4. API Conventions**
- REST/GraphQL/RPC standards
- Naming conventions, versioning strategy
- Request/response formats, error handling
- Authentication/authorization approach

**5. Data Model Principles**
- Database choice and rationale
- Schema design patterns
- Data access patterns
- Caching strategy

**6. Security & Compliance**
- Authentication/authorization mechanisms
- Data encryption (at rest, in transit)
- Security headers, input validation
- Compliance requirements (GDPR, HIPAA, etc.)

**7. Development Standards**
- Code style, linting rules
- Testing requirements (unit, integration, e2e)
- Git workflow and branching strategy
- CI/CD pipeline overview

**8. Deployment Architecture**
- Infrastructure (cloud provider, containers, etc.)
- Environment strategy (dev, staging, prod)
- Monitoring and observability
- Scaling strategy

### Phase 3: ADR Generation

For each major architectural decision:
1. Create ADR entry in `.spec-memory/DECISIONS-LOG.md`
2. Document: decision, context, rationale, consequences, alternatives

See `shared/state-management.md` for ADR format.

### Phase 4: State Update

1. Update `.spec-memory/WORKFLOW-PROGRESS.md`:
   - Add Feature 000: Architecture Blueprint
   - Mark as completed
2. Create checkpoint: Save to `.spec-state/checkpoints/`

### Phase 5: MCP Integration (Optional)

If Confluence MCP enabled:
1. Check for `SPEC_ATLASSIAN_SYNC=enabled` in CLAUDE.md
2. Ask user: "Publish blueprint to Confluence?"
3. If yes: Use confluence_create_page to publish
4. Store Confluence URL in blueprint metadata

See `shared/integration-patterns.md` for MCP patterns.

### Phase 6: Next Steps

Guide user to:
- Review and refine blueprint
- Get team approval on architecture decisions
- Run `spec:generate` to create first feature
- Reference blueprint in all future planning

## Error Handling

**Missing .spec/**: Prompt user to run `spec:init` first

**Brownfield analysis fails**: Fall back to interview mode, ask user about tech stack

**MCP publish fails**: Continue locally, save blueprint file, notify user

**Incomplete information**: Mark sections with [TODO] tags, document what's missing

## Output Format

**Console Output**:
```
Architecture Blueprint Created

Location: .spec/architecture-blueprint.md
Type: [Greenfield/Brownfield]
ADRs Created: 5 decisions logged

Sections:
  ✓ System Overview
  ✓ Technology Stack
  ✓ Architecture Patterns
  ✓ API Conventions
  ✓ Data Model Principles
  ✓ Security & Compliance
  ✓ Development Standards
  ✓ Deployment Architecture

[Confluence URL if published]

Next: Run `spec:generate "Your First Feature"` to begin development
```

**File Created**: `.spec/architecture-blueprint.md`

**State Updated**:
- `.spec-memory/DECISIONS-LOG.md` (ADRs added)
- `.spec-memory/WORKFLOW-PROGRESS.md` (Feature 000 complete)

## Related Resources

For complete blueprint template and ADR examples, see: `EXAMPLES.md`

For detailed section specifications and brownfield analysis patterns, see: `REFERENCE.md`

For workflow integration patterns, see: `shared/workflow-patterns.md`

For MCP publishing to Confluence, see: `shared/integration-patterns.md`

For state management details, see: `shared/state-management.md`
