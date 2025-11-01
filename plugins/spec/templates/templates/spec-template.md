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

## User Stories (Prioritized & Independent)

Each story independently testable, developable, deployable (MVP increment).

### User Story 1 - [Title] (P1)

[Description: Plain language user journey]

**Why P1**: [Value and priority justification]
**Test**: [Independent verification method]
**Acceptance**:
1. Given [state] When [action] Then [outcome]
2. Given [state] When [action] Then [outcome]

---

### User Story 2 - [Title] (P2)

[Description]
**Why P2**: [Justification]
**Test**: [Verification]
**Acceptance**: Given [state] When [action] Then [outcome]

---

### User Story 3 - [Title] (P3)

[Description]
**Why P3**: [Justification]
**Test**: [Verification]
**Acceptance**: Given [state] When [action] Then [outcome]

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

