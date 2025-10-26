---
name: flow:plan
description: Create technical implementation plan from specification. Use when 1) Spec is complete and need technical design, 2) Determining architecture for feature, 3) Designing components/APIs/data models, 4) Before breaking down into tasks, 5) Need research-backed technical decisions and ADRs. Creates plan.md with technical decisions and component design.
allowed-tools: Read, Write, Edit, Task, WebSearch
---

# Flow Plan

Create comprehensive implementation plans with architecture decisions, technical design, and research-backed recommendations.

## Core Capability

Transforms specifications into actionable technical plans:
- Loads `spec.md` and analyzes requirements
- Executes technical research via `flow-researcher` subagent
- Generates complete implementation design
- Validates against blueprint (if exists)
- Creates detailed artifacts for implementation

## Execution Phases

### Phase 0: Research & Decisions
- Resolve technical unknowns
- Evaluate technology alternatives
- Document decisions in `research.md`
- Create Architecture Decision Records (ADRs)

Uses **flow-researcher** subagent for:
- Technology stack evaluation
- Architecture pattern recommendations
- Best practices research
- Performance/security strategies

### Phase 1: Design & Contracts
- Generate `data-model.md` with entity definitions
- Create API contracts in `contracts/` (OpenAPI, GraphQL, events)
- Write `quickstart.md` with test scenarios
- Define integration patterns

## Output Artifacts

| File | Purpose |
|------|---------|
| `plan.md` | Main implementation plan with architecture and phases |
| `research.md` | Technical research findings and ADRs |
| `data-model.md` | Database schema and entity relationships |
| `contracts/` | API specifications (OpenAPI, GraphQL, webhooks) |
| `quickstart.md` | Test scenarios and cURL examples |

## MCP Integration (Confluence)

When `FLOW_ATLASSIAN_SYNC=enabled`, syncs plan to Confluence:
- Creates "Implementation Plan" subpage under feature
- Formats ADRs as decision tables
- Embeds data model with entity diagrams
- Includes interactive API contract viewers
- Generates Gantt chart from implementation timeline

See [REFERENCE.md](./REFERENCE.md#mcp-integration-confluence) for detailed sync process.

## Blueprint Validation

If `.flow/architecture-blueprint.md` exists:
- Validates technology choices against approved stack
- Ensures API design follows guidelines
- Confirms data modeling conventions
- Documents deviations with rationale (requires user approval)

## Examples

See [EXAMPLES.md](./EXAMPLES.md) for:
- Greenfield API feature planning
- Brownfield integration planning
- Microservices architecture design
- Confluence sync workflow
- Minimal POC mode planning

## Reference

See [REFERENCE.md](./REFERENCE.md) for:
- ADR format specification
- Research process details
- MCP/Confluence integration
- Configuration options (`--minimal`, `--update`)
- Data model guidelines
- API contract templates
- Performance and security guidelines

## Related Skills

- **flow-researcher** (subagent): Executes technical research
- **flow-analyzer** (subagent): Analyzes existing code for brownfield
- **flow:specify**: Creates specification (run before)
- **flow:tasks**: Generates tasks from plan (run after)

## Validation

Test this skill:
```bash
scripts/validate.sh
```