# Orbit Planning Reference

## Architecture Blueprint Outline
1. System Overview (diagram + integrations)
2. Technology Stack (frontend/backend/runtime, with rationale)
3. Patterns & Modules (layered, hexagonal, microservices, etc.)
4. API Conventions (method, auth, error format)
5. Data Models (schema, migrations, caching)
6. Security & Compliance (authN/Z, PII handling)
7. Deployment & Observability (environments, monitoring, alerting)
8. Risks & Open Questions

Use `templates/architecture-blueprint.md` as the starting document. Record every major decision in `architecture-decision-record.md`.

## Technical Plan Sections
- System Architecture
- Component Design
- Data Models
- API Contracts
- Implementation Phases (with dependencies + milestones)
- Technical Risks & Mitigations
- ADR Summary / External Links

Helper script: `scripts/plan_sections.sh` writes numbered headings and placeholder checklists for each section.

## Task Breakdown Guidance
- Atomic size: 1–4 h each.
- Include dependencies using IDs (`depends_on: [T001, T002]`).
- Provide estimates and parallelization hints.
- `scripts/task_graph.sh` can accept pairs such as `T001>T002` to output a Mermaid graph.

### Table Template (see `templates/tasks.md`)
```
| ID | Description | Priority | Est. | Depends On | Notes |
| --- | --- | --- | --- | --- | --- |
```

## Consistency Checks
When running `consistency-analyzer`, ensure the prompt includes:
- Spec path
- Plan path
- Architecture path
- PASS criteria (coverage ≥90 %, 0 critical conflicts, ≤2 medium issues)

Output: `{feature}/consistency-analysis.md` summarizing coverage, conflicts, drift, recommendations.

## ADR Examples
Reuse the samples in Orbit Lifecycle `templates/state/architecture-decision-record.md`. Each ADR should link back to the spec/plan sections and note consequences.

## MCP Touchpoints
- Blueprint/plan updates → Confluence sync.
- Task creation → Jira/Linear issue creation.
- Validation → Post status notes to the monitoring dashboard or external systems if configured.
