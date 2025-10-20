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

**Feature Branch**: `[BRANCH-NAME]` (e.g., `PROJ-123-feature-name` or `001-feature-name`)
**Feature Number**: [###]
**JIRA Story**: [JIRA-ID](JIRA-URL) (if linked)
**Created**: [DATE]
**Status**: Draft
**Input**: User description: "$ARGUMENTS"

## References to Project Artifacts

<!--
  This feature can reference the following .flow/ artifacts (flat peer model):
  - Product Requirements: .flow/product-requirements.md
  - Architecture Blueprint: .flow/architecture-blueprint.md
  - API Contracts: .flow/contracts/openapi.yaml (if API project)
  - Data Models: .flow/data-models/entities.md

  These are peer documents - reference as needed for context and guidance.
-->

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently - e.g., "Can be fully tested by [specific action] and delivers [specific value]"]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 3 - [Brief Title] (Priority: P3)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- What happens when [boundary condition]?
- How does system handle [error scenario]?

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: System MUST [specific capability, e.g., "allow users to create accounts"]
- **FR-002**: System MUST [specific capability, e.g., "validate email addresses"]  
- **FR-003**: Users MUST be able to [key interaction, e.g., "reset their password"]
- **FR-004**: System MUST [data requirement, e.g., "persist user preferences"]
- **FR-005**: System MUST [behavior, e.g., "log all security events"]

*Example of marking unclear requirements:*

- **FR-006**: System MUST authenticate users via [NEEDS CLARIFICATION: auth method not specified - email/password, SSO, OAuth?]
- **FR-007**: System MUST retain user data for [NEEDS CLARIFICATION: retention period not specified]

### Key Entities *(include if feature involves data)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships to other entities]

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: [Measurable metric, e.g., "Users can complete account creation in under 2 minutes"]
- **SC-002**: [Measurable metric, e.g., "System handles 1000 concurrent users without degradation"]
- **SC-003**: [User satisfaction metric, e.g., "90% of users successfully complete primary task on first attempt"]
- **SC-004**: [Business metric, e.g., "Reduce support tickets related to [X] by 50%"]

---

## JIRA Integration Notes

<!--
  If Atlassian integration is enabled:

  BIDIRECTIONAL SYNC:
  - This spec can sync TO JIRA (creates/updates JIRA story)
  - Can pull FROM JIRA (if started from JIRA URL)
  - User approval required before syncing TO JIRA

  WORKFLOW:
  - flow:specify "https://jira.../PROJ-123" → Pulls JIRA story into this spec
  - flow:specify "Feature description" → Can create JIRA story (asks first)
  - flow:sync --to-jira → Push local changes to JIRA (asks first)
  - flow:sync --from-jira PROJ-123 → Pull JIRA changes (shows diff, asks)

  TRACEABILITY:
  - JIRA ID stored in frontmatter above
  - Git branch prepends JIRA ID: PROJ-123-feature-name
  - Directory stays sequential: features/001-feature-name/
-->

