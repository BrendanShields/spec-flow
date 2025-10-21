---
name: flow:plan
description: Create technical implementation plan from specification. Use when: 1) Spec is complete and need technical design, 2) Determining architecture for feature, 3) Designing components/APIs/data models, 4) Before breaking down into tasks. Creates plan.md with technical decisions and component design.
allowed-tools: Read, Write, Edit, Task, WebSearch
---

# Flow Plan: Technical Planning

Create comprehensive implementation plans with architecture decisions and technical design.

## What This Skill Does

1. Loads specification from `spec.md`
2. **Researches** technical decisions using `flow-researcher` subagent
3. Generates implementation plan with:
   - Architecture patterns
   - Technology stack recommendations
   - Data model design
   - API contracts
   - Integration patterns
4. Validates against project constitution
5. Updates agent context files

## Execution Phases

### Phase 0: Research & Decisions
- Resolve technical unknowns
- Evaluate technology alternatives
- Document decisions in `research.md`
- Create Architecture Decision Records (ADRs)

### Phase 1: Design & Contracts
- Generate `data-model.md` with entities
- Create API contracts in `contracts/`
- Write `quickstart.md` for testing

## Output Artifacts

- `plan.md` - Main implementation plan
- `research.md` - Technical research and decisions
- `data-model.md` - Entity definitions
- `contracts/` - API specifications
- `quickstart.md` - Test scenarios

## MCP Integration (Confluence)

If `FLOW_ATLASSIAN_SYNC=enabled` in CLAUDE.md, automatically syncs implementation plan to Confluence:

### Confluence Page Sync

**After plan generation**:
1. Read existing feature Confluence page (created by `flow:specify`)
2. Create "Implementation Plan" subpage under feature page
3. Sync plan artifacts to Confluence:

```javascript
// Create or update Implementation Plan page
const planPage = await mcp.confluence.createPage({
  parentId: featurePageId,
  title: 'Implementation Plan',
  body: {
    architecture: plan.architecture,
    techStack: plan.techStack,
    dataModel: plan.dataModel,
    apiContracts: plan.contracts,
    timeline: plan.phases
  }
});
```

### Content Sections

**Architecture Decisions**:
- Sync ADRs from `research.md`
- Format as Confluence decision tables
- Link to related JIRA stories

**Data Model**:
- Sync `data-model.md` with entity diagrams
- Create interactive entity tables
- Add relationships visualization

**API Contracts**:
- Sync OpenAPI/GraphQL schemas from `contracts/`
- Format as collapsible code blocks
- Add request/response examples

**Implementation Timeline**:
- Create Gantt chart from phases
- Link each phase to JIRA subtasks
- Show dependencies visually

### Benefits

- Team reviews plan in familiar Confluence interface
- Architects can comment directly on decisions
- Historical record of technical choices
- Linked to JIRA for complete traceability

## Subagents Used

- **flow-researcher**: Researches best practices and evaluates alternatives
- **flow-analyzer**: Analyzes existing code for brownfield projects