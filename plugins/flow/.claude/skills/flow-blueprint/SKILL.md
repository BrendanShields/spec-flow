---
name: flow:blueprint
description: Define project architecture and technical standards. Use when: 1) Setting up new project architecture, 2) Team needs to align on tech stack/patterns, 3) Documenting architectural decisions (ADRs), 4) Establishing API/data/security guidelines. Creates architecture-blueprint.md with patterns, stack, and standards.
allowed-tools: Write, Read, Edit, AskUserQuestion
---

# Flow Blueprint: Architecture Definition

Define and document your project's architecture, technical standards, and development practices.

## When to Use

- **First time** setting up a new project
- When team needs to align on architecture and practices
- When extracting patterns from brownfield projects
- When updating architecture decisions or standards

## What This Skill Does

1. **Interactive Mode**:
   - Prompts for architecture patterns
   - Prompts for technology stack choices
   - Prompts for API design guidelines
   - Prompts for data modeling standards
   - Prompts for development principles
   - Suggests based on project type and domain
   - Documents in `.flow/architecture-blueprint.md`

2. **Extract Mode** (brownfield):
   - Analyzes existing codebase
   - Infers architecture patterns
   - Identifies technology stack
   - Documents discovered conventions
   - Extracts API patterns if present

3. **Update Mode**:
   - Version control (semantic versioning)
   - Tracks architecture decisions (ADRs)
   - Updates existing blueprint

## Blueprint Structure

```markdown
# Architecture Blueprint: [PROJECT_NAME]

## Core Principles
### Principle 1: [Name, e.g., "API-First Design"]
**Guideline**: [Description]
**Rationale**: [Why]
**Application**: [How applied]
**Flexibility**: [When deviations allowed]

## Architecture Patterns
**Pattern**: [Monolith/Microservices/Modular Monolith/etc.]
**Rationale**: [Why chosen]
**Key Characteristics**: [List]

## Technology Stack
**Frontend**: [Framework, rationale]
**Backend**: [Framework, rationale]
**Database**: [Choice, rationale]
**Infrastructure**: [Hosting, deployment]

## API Design Guidelines
**Versioning Strategy**: [e.g., URI versioning]
**Resource Naming**: [Conventions]
**Authentication**: [Method]
**Rate Limiting**: [Strategy]

## Data Modeling Guidelines
**Naming Conventions**: [Tables, fields]
**Primary Keys**: [Strategy]
**Timestamps**: [Required fields]

## Security Guidelines
[Standards for authentication, data protection, etc.]

## Performance Guidelines
[Response time targets, optimization practices]

## Testing Guidelines
[Coverage requirements, testing approach]

## Decision Records (ADRs)
### ADR-001: [Decision Title]
**Date**: [DATE]
**Status**: [Accepted/Superseded]
**Context**: [Problem]
**Decision**: [What decided]
**Rationale**: [Why]

## Governance
- Amendment procedure
- Version control policy
- Review process

**Version**: 1.0.0
**Created**: [DATE]
**Last Updated**: [DATE]
```

## Example Blueprints

### For Solo Developer - Greenfield
```markdown
## Core Principles
### I. Simplicity First
**Guideline**: Start with simplest solution, add complexity only when needed
**Rationale**: Faster iteration, easier debugging
**Flexibility**: Complex solutions OK when simple ones proven insufficient

## Architecture Patterns
**Pattern**: Monolithic architecture with modular design
**Rationale**: Faster to build and deploy, easier to understand initially

## Technology Stack
**Frontend**: React + Vite
**Rationale**: Fast development, great tooling, large ecosystem
**Backend**: Node.js + Express
**Rationale**: Same language as frontend, simple to start
**Database**: PostgreSQL
**Rationale**: Robust, well-documented, handles growth

## API Design
**Style**: REST with OpenAPI 3.0
**Versioning**: URI-based (/v1/, /v2/)
**Auth**: JWT tokens
```

### For Enterprise Team
```markdown
## Core Principles
### I. API-First Design
**Guideline**: Design and document APIs before implementation
**Rationale**: Enables parallel frontend/backend development, better contracts
**Application**: Use OpenAPI specs, review before coding
**Flexibility**: Internal services may iterate faster

### II. Security by Default
**Guideline**: All endpoints authenticated, all data encrypted
**Rationale**: Compliance requirements, customer trust
**Application**: No exceptions without security review
**Flexibility**: Public read endpoints with rate limiting

## Architecture Patterns
**Pattern**: Microservices with event-driven communication
**Rationale**: Team scalability, independent deployment, fault isolation

## API Design Guidelines
**Versioning**: Semantic versioning with URI path (/v1/, /v2/)
**Breaking Changes**: 6-month deprecation period minimum
**Rate Limiting**: Per-client token bucket, 100 req/min default
**Security**: OAuth2 + JWT, mTLS for service-to-service
```

## Blueprint vs Old Constitution

**Scope Expansion**:
- Old: Development principles only
- New: Principles + Architecture + Tech Stack + API Guidelines + Data Guidelines

**Enforcement**:
- Old: CRITICAL errors, strict enforcement
- New: Guidance-based (flat peer model), user approval for deviations

**Relationship to Features**:
- Features CAN reference blueprint for guidance
- Flat peer model - not strictly enforced

## Modes

```bash
# Interactive creation
flow:blueprint

# Extract from existing code (brownfield)
flow:blueprint --extract

# Update existing
flow:blueprint --update
```

## When to Update

- Architecture pattern changes (e.g., monolith → microservices)
- New technology adopted (e.g., adding GraphQL)
- Team agrees to change principles
- New compliance requirements
- Scaling forces changes

**Not for**: Individual feature decisions, one-off experiments

## Integration with Other Skills

- **flow:init**: Creates skeleton blueprint during project setup
- **flow:specify**: Can reference blueprint for context
- **flow:plan**: Can check alignment with blueprint (user approval for deviations)
- **flow:implement**: Can reference blueprint standards

**Note**: Flat peer model - blueprint provides guidance, not strict enforcement

## Related Skills

- **flow:init**: Initialize project with blueprint skeleton
- **flow:specify**: Create specifications (can reference blueprint)
- **flow:plan**: Technical planning (can align with blueprint)

## Versioning

**Semantic Versioning**:
- **MAJOR**: Breaking architecture changes
- **MINOR**: New patterns/guidelines added
- **PATCH**: Clarifications, wording fixes

## Flat Peer Model

This blueprint is a **peer artifact** in the `.flow/` directory:
- Not hierarchically enforced
- Features CAN reference for guidance
- Deviations require user approval and documentation
- Manual consistency (tools help detect drift)
