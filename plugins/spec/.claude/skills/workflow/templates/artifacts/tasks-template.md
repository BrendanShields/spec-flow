---
description: "Task list for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: plan.md, spec.md, research.md, data-model.md, contracts/
**Organisation**: Epic → Story → Sub Task hierarchy (no overlaps between epics)
**Sub Task Naming**: `ST-[Epic#].[Story#].[Sequence]`

---

## Tracking Guidelines

- **GitHub Issues**: Every story must have a matching GitHub issue with the sub-task checklist below.
- **External Tracker (e.g., JIRA)**: When configured, mirror the story as a JIRA issue and cross-link IDs. If no external tracker exists, document `External Tracker: None` within the GitHub issue.
- **Documentation Updates**: On completion of a story, update project-level docs (`{config.paths.memory}/WORKFLOW-PROGRESS.md`, blueprints, PRD) before closing the issue.

---

## Epic 1: [Name]

**Objective**: [Outcome tied to PRD/Blueprint]
**Dependencies**: [Shared setup or prerequisites]

### Story 1.1 – [Title] (GitHub #[Issue] | External: [JIRA-123/None])

**Acceptance Summary**:
- **Scenario**: [Short name]
  - **Given** [state]
  - **When** [action]
  - **Then** [outcome]

#### Sub Tasks
- [ ] ST-1.1.1 Prepare environment [dependency notes]
- [ ] ST-1.1.2 Implement [component/service]
- [ ] ST-1.1.3 Write tests in `[path]`
- [ ] ST-1.1.4 Update docs (`docs/[file]`) after verification

### Story 1.2 – [Title] (GitHub #[Issue] | External: [JIRA-123/None])

**Acceptance Summary**:
- **Scenario**: [Short name]
  - **Given** [state]
  - **When** [action]
  - **Then** [outcome]

#### Sub Tasks
- [ ] ST-1.2.1 …

---

## Epic 2: [Name]

Repeat the pattern for each additional epic. Ensure foundational work is called out once (e.g., `ST-0.0.x`) and referenced as dependencies by downstream sub tasks rather than duplicating effort.

---

## Completion Checklist

- [ ] All sub tasks complete with linked commits
- [ ] Story-level GitHub issues updated and closed
- [ ] External tracker statuses reconciled (if applicable)
- [ ] Project-level documentation refreshed
- [ ] Release notes or changelog entries prepared (if required)



