---
feature: [###]
name: [feature-name]
jira_id: [JIRA-ID or null]
jira_url: [JIRA URL or null]
created: [DATE]
last_synced: [DATE or null]
sync_direction: [bidirectional/local-only]
---

# Feature Specification: [FEATURE NAME]

**Branch**: `[BRANCH-NAME]` | **Number**: [###] | **JIRA**: [JIRA-ID](JIRA-URL)
**Status**: Draft | **Created**: [DATE]

## Project Artifacts

References (peer model): Product Requirements | Architecture Blueprint | API Contracts | Data Models

See [_shared/user-story-format.md](_shared/user-story-format.md) for standard format.
See [_shared/metadata-frontmatter.md](_shared/metadata-frontmatter.md) for header conventions.

## Epics & User Stories

Epics are derived from the Product Requirements Document and Architecture Blueprint listed in Project Artifacts. Ensure no two epics target the same capability area; if overlap occurs create a new epic. All stories must have a parent epic and reference the governing documents.

### Epic 1: [Name] (PRD §[section] / Blueprint [ID])

**Goal**: [Business or user outcome]
**Success Metrics**: [Primary indicators]

#### Story 1.1 – [Title] (P1)
**As a** [persona] **I want to** [capability] **So that** [benefit]

**GitHub Issue**: #[Issue Number] (auto-generated with sub task checklist)
**External Tracker**: [JIRA-123 / None]

**Acceptance Criteria**:
- **Scenario**: [Short name]
  - **Given** [state]
  - **When** [action]
  - **Then** [outcome]
- **Scenario**: [Short name]
  - **Given** [state]
  - **When** [action]
  - **Then** [outcome]

**Notes**: [Dependencies, design references]

#### Story 1.2 – [Title] (P2)
[Repeat format]

### Epic 2: [Name] (PRD §[section] / Blueprint [ID])
[Add additional epics and stories as required. If a story cannot align to an existing epic, create a new epic rather than forcing overlap.]

---

### Edge Cases

- When [boundary condition]? [Expected behavior]
- How to handle [error scenario]? [Expected behavior]

## Requirements

### Functional

- **FR-001**: System MUST [capability]
- **FR-002**: System MUST [capability]
- **FR-003**: Users MUST [interaction]
- **FR-004**: System MUST [data/behavior]

*Unclear requirements:*
- **FR-005**: System MUST [NEEDS CLARIFICATION: what exactly?]

### Key Entities

- **[Entity]**: [What + attributes + relationships]
- **[Entity]**: [What + attributes + relationships]

## Success Criteria

- **SC-001**: [Measurable metric]
- **SC-002**: [Measurable metric]
- **SC-003**: [User satisfaction metric]
- **SC-004**: [Business metric]

---

## JIRA Integration

**Frontmatter metadata**: feature_id, jira_id, sync_direction (see header above)
**Workflow**: Sync TO/FROM JIRA with user approval | Branch: JIRA-ID-feature-name | Dir: features/###-name/

