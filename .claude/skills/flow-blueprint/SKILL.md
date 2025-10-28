---
name: flow:blueprint
description: Define project architecture and technical standards. Use when 1) Setting up new project architecture, 2) User says "define/document architecture", 3) Team needs tech stack alignment, 4) Documenting architectural decisions (ADRs), 5) Establishing API/data/security guidelines. Creates architecture-blueprint.md.
allowed-tools: Write, Read, Edit, AskUserQuestion
---

# Flow Blueprint

Define and document your project's architecture, technical standards, and development practices.

## Core Workflow

### 1. Interactive Mode (Greenfield)

Prompts for architecture decisions:
- **Architecture patterns**: Monolith, microservices, modular monolith
- **Technology stack**: Frontend, backend, database choices
- **API design**: REST, GraphQL, versioning strategy
- **Data modeling**: Naming conventions, primary keys, timestamps
- **Development principles**: TDD, code review, testing standards

Suggests based on project type and domain.

Documents in `.flow/architecture-blueprint.md`

### 2. Extract Mode (Brownfield)

Analyzes existing codebase:
- Infers architecture patterns from structure
- Identifies technology stack from dependencies
- Documents discovered conventions
- Extracts API patterns if present

Creates baseline blueprint from current state.

### 3. Update Mode

Version control for architecture evolution:
- Semantic versioning (MAJOR.MINOR.PATCH)
- Tracks architecture decisions (ADRs)
- Updates existing blueprint
- Maintains decision history

## Blueprint Structure

```markdown
# Architecture Blueprint: [PROJECT_NAME]

## Core Principles
### Principle 1: [Name]
**Guideline**: [Description]
**Rationale**: [Why]
**Application**: [How applied]
**Flexibility**: [When deviations allowed]

## Architecture Patterns
**Pattern**: [Monolith/Microservices/etc.]
**Rationale**: [Why chosen]
**Key Characteristics**: [List]

## Technology Stack
**Frontend**: [Framework, rationale]
**Backend**: [Framework, rationale]
**Database**: [Choice, rationale]

## API Design Guidelines
**Versioning Strategy**: [e.g., URI versioning]
**Resource Naming**: [Conventions]
**Authentication**: [Method]

## Data Modeling Guidelines
**Naming Conventions**: [Tables, fields]
**Primary Keys**: [Strategy]
**Timestamps**: [Required fields]

## Security Guidelines
[Standards for authentication, data protection]

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

## Command Modes

### Interactive Creation
```bash
flow:blueprint
```

Prompts for all architecture decisions with recommendations.

### Extract from Codebase
```bash
flow:blueprint --extract
```

Analyzes existing code and generates blueprint from discovered patterns.

### Update Existing
```bash
flow:blueprint --update
```

Adds new decisions, increments version, maintains history.

## Blueprint vs Old Constitution

**Scope Expansion**:
- Old: Development principles only
- New: Principles + Architecture + Tech Stack + API + Data Guidelines

**Enforcement**:
- Old: CRITICAL errors, strict enforcement
- New: Guidance-based (flat peer model), user approval for deviations

**Relationship to Features**:
- Features CAN reference blueprint for guidance
- Flat peer model - not strictly enforced
- Manual consistency (tools help detect drift)

## When to Update

- Architecture pattern changes (e.g., monolith → microservices)
- New technology adopted (e.g., adding GraphQL)
- Team agrees to change principles
- New compliance requirements
- Scaling forces changes

**Not for**: Individual feature decisions, one-off experiments

## Example Blueprints

**Solo Developer**:
```markdown
## Core Principles
### I. Simplicity First
**Guideline**: Start with simplest solution
**Rationale**: Faster iteration, easier debugging
**Flexibility**: Complex solutions OK when simple proven insufficient

## Architecture Patterns
**Pattern**: Monolithic with modular design
**Rationale**: Faster to build, easier to understand

## Technology Stack
**Frontend**: React + Vite
**Backend**: Node.js + Express
**Database**: PostgreSQL
```

**Enterprise Team**:
```markdown
## Core Principles
### I. API-First Design
**Guideline**: Design APIs before implementation
**Rationale**: Enables parallel development, better contracts
**Application**: Use OpenAPI specs, review before coding

### II. Security by Default
**Guideline**: All endpoints authenticated, all data encrypted
**Rationale**: Compliance requirements, customer trust

## Architecture Patterns
**Pattern**: Microservices with event-driven communication
**Rationale**: Team scalability, independent deployment
```

## Integration with Flow

**At Initialization**:
```bash
flow:init    # Creates skeleton blueprint
flow:blueprint  # Define architecture
```

**During Development**:
- `flow:specify`: Can reference blueprint for context
- `flow:plan`: Can check alignment (user approval for deviations)
- `flow:implement`: Can reference blueprint standards

**Note**: Flat peer model - blueprint provides guidance, not strict enforcement

## Versioning

**Semantic Versioning**:
- **MAJOR**: Breaking architecture changes
- **MINOR**: New patterns/guidelines added
- **PATCH**: Clarifications, wording fixes

## Examples

See [EXAMPLES.md](./EXAMPLES.md) for:
- Solo developer greenfield setup
- Enterprise team architecture
- Brownfield extraction
- Adding new ADR
- Version updates

## Reference

See [REFERENCE.md](./REFERENCE.md) for:
- Complete blueprint template
- ADR format details
- Versioning guidelines
- Governance models
- Integration patterns

## Related Skills

- **flow:init**: Creates blueprint skeleton (run first)
- **flow:specify**: Can reference blueprint (run after)
- **flow:plan**: Can align with blueprint

## Validation

Test this skill:
```bash
scripts/validate.sh
```
