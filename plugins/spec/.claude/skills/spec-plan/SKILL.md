---
name: spec:plan
description: Use when creating technical plan from specification, designing system architecture, making technology decisions, need technical design document, user says "create plan" or "design the system" - generates detailed plan.md with architecture decisions, data models, API contracts, researches best practices, documents ADRs
allowed-tools: Read, Write, Edit, WebSearch, Bash
model: sonnet
---

# Technical Planning from Specification

Create comprehensive technical plan from specification with architecture decisions, data models, and implementation strategy.

## What This Skill Does

- Read spec.md to understand requirements and user stories
- Research best practices and technology options (via spec:researcher agent)
- Design data models, API contracts, and system architecture
- Generate Architecture Decision Records (ADRs) for key choices
- Create plan.md with actionable technical design
- Optional: Publish plan to Confluence/external systems

## When to Use

1. User says "create plan", "design the system", "technical design"
2. After spec:generate completes (spec.md exists)
3. User mentions "architecture", "how to build", "technology choices"
4. Current phase is "specification" and ready to plan
5. Updating existing plan with spec:update

## Execution Flow

### Phase 1: Context Loading
1. Read `.spec-state/current-session.md` for active feature
2. Read `features/###-feature-name/spec.md` for requirements
3. Load `.spec-memory/DECISIONS-LOG.md` for existing ADRs
4. Check project's `CLAUDE.md` for tech stack constraints

### Phase 2: Technical Research
1. Invoke `spec:researcher` agent for technology evaluation:
   - Best practices for identified domain
   - Library/framework recommendations
   - Architecture patterns for requirements
   - Security and performance considerations
2. Use WebSearch for current documentation and benchmarks
3. Compile research findings into decision matrix

### Phase 3: Plan Generation
1. Create `plan.md` with sections:
   - **Overview**: High-level approach summary
   - **Data Model**: Entities, relationships, schema design
   - **API Contracts**: Endpoints, request/response formats
   - **Architecture**: Components, layers, integrations
   - **Implementation Notes**: Quickstart guidance
   - **Testing Strategy**: Test types and coverage plan
2. Document architecture decisions as ADRs
3. Include code snippets and examples where helpful

### Phase 4: State Updates
1. Update `.spec-state/current-session.md`:
   - Set phase to "planning"
   - Add plan.md artifact reference
2. Append ADRs to `.spec-memory/DECISIONS-LOG.md`
3. Update `.spec-memory/WORKFLOW-PROGRESS.md` with planning completion
4. Create checkpoint: `.spec-state/checkpoints/YYYY-MM-DD-HH-MM.md`

### Phase 5: MCP Integration (Optional)
1. Detect MCP configuration (SPEC_ATLASSIAN_SYNC, etc.)
2. Ask user: "Publish plan to Confluence?" (if configured)
3. If yes: Use Confluence MCP to create page, store URL in plan metadata
4. If JIRA enabled: Update JIRA issue with plan summary

## Error Handling

**Missing spec.md**:
- Check if spec exists: `features/###-feature-name/spec.md`
- If not found: "No specification found. Run spec:generate first."
- Exit gracefully

**Research failures**:
- If WebSearch unavailable: Use cached knowledge
- If spec:researcher fails: Continue with manual planning
- Log warning but don't block workflow

**ADR conflicts**:
- If decision contradicts existing ADR: Flag for review
- Ask user: "Decision differs from ADR-###. Update or create new?"
- Resolve before proceeding

**MCP errors**:
- If Confluence publish fails: Save plan locally, continue workflow
- Log error: "MCP integration unavailable, plan saved locally"
- Never block on external tool failures

## Output Format

**plan.md structure**:
```markdown
# [Feature Name] - Technical Plan

**Feature ID**: ###
**Created**: YYYY-MM-DD
**Status**: Active
**Confluence**: [URL if published]

## Overview
[High-level technical approach - 3-5 sentences]

## Data Model
[Entities, relationships, schema definitions]

## API Contracts
[REST/GraphQL endpoints with request/response formats]

## Architecture
[System components, layers, integrations, diagrams]

## Security Considerations
[Auth, validation, encryption, compliance]

## Implementation Notes
[Quickstart guidance, key files, setup steps]

## Testing Strategy
[Unit, integration, e2e test approach]

## References
- ADR-###: [Decision title]
- Research: [Links to findings]
```

**Console output**:
```
Plan created for Feature ###: [Feature Name]

Files generated:
  - features/###-feature-name/plan.md
  - .spec-memory/DECISIONS-LOG.md (updated with ADRs)

Architecture decisions documented:
  - ADR-###: [Technology choice]
  - ADR-###: [Architecture pattern]

Next steps:
  1. Review plan.md
  2. Run: spec:tasks (to create task breakdown)
```

## Progressive Disclosure

**Core planning** (this file): ~1,400 tokens

**Examples**: See examples.md for:
- REST API planning scenario
- Frontend component planning
- Microservice architecture planning
- Database design planning

**Reference**: See reference.md for:
- Complete plan.md template
- ADR format specification
- Research integration patterns
- MCP publishing details

## Integration Points

**Shared Resources**:
- See `shared/workflow-patterns.md` for phase transitions
- See `shared/integration-patterns.md` for MCP publishing patterns
- See `shared/state-management.md` for state file specifications

**Subagents**:
- Calls `spec:researcher` agent for technical research and decision documentation

**Commands**:
- Invoked by `/spec-plan` command
- Invoked by `spec:orchestrate` workflow automation

**State Files**:
- Reads: spec.md, current-session.md, DECISIONS-LOG.md
- Writes: plan.md, DECISIONS-LOG.md (append ADRs)
- Updates: current-session.md, WORKFLOW-PROGRESS.md

---

*For detailed examples, see examples.md*
*For technical specifications, see reference.md*
