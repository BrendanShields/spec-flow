# Product Requirements: [PROJECT_NAME]

**Type**: [Greenfield/Brownfield] | **Domain**: [E-commerce/SaaS/API/etc.] | **Status**: [Draft/Active]
**Updated**: [DATE]

## Vision

**What**: [Problem solved, target users]
**Why**: [Value proposition]

## Goals

- **BG-001**: [Business objective, e.g., "Reduce support tickets by 40%"]
- **BG-002**: [Revenue/growth goal]
- **BG-003**: [Market positioning]

## User Personas

| Persona | Who | Goals | Pain Points |
|---------|-----|-------|------------|
| [Primary] | [Description] | [Objectives] | [Challenges] |
| [Secondary] | [Description] | [Objectives] | [Challenges] |

## Epics & User Stories

Derive epics directly from this PRD and the Architecture Blueprint. Each epic must map to a unique capability area—avoid overlap by referencing the blueprint section identifier. All user stories live under an epic parent and should follow the standard format in [_shared/user-story-format.md](_shared/user-story-format.md).

### Epic 1: [Name] (Blueprint Ref: [ID])

**PRD Alignment**: [Section/requirement]
**Outcome**: [Business or user result]

#### Story 1.1 – [Title] (P1)
**As a** [persona] **I want** [capability] **So that** [benefit]
**Acceptance**:
- **Scenario**: [Short name]
  - **Given** [state]
  - **When** [action]
  - **Then** [outcome]
**Metrics**: [Success measures]
**Issue Tracking**: GitHub #[ID] | External: [JIRA-123 / None]

#### Story 1.2 – [Title] (P2)
[Follow same format]

### Epic 2: [Name] (Blueprint Ref: [ID])
[Add more epics as needed. Duplicate stories that do not map cleanly should trigger creation of a new epic instead.]

## Key Entities

| Entity | Purpose | Key Attributes | Business Rules |
|--------|---------|-----------------|-----------------|
| [Name] | [What] | id, name, ... | Unique, Cannot delete if... |
| [Name] | [What] | [Attributes] | [Rules] |

## Cross-Cutting Requirements

**Security**: [Requirements] | **Performance**: [Requirements] | **Accessibility**: [Requirements]
**Availability**: [Uptime], **Reliability**: [RTO/RPO], **Usability**: [Standards]

## Success Criteria

- **PC-001**: [Adoption metric]
- **PC-002**: [Engagement metric]
- **PC-003**: [Business metric]
- **PC-004**: [Quality metric]

## Out of Scope (V1)

- [Feature deferred]
- [Integration deferred]
- [Use case deferred]

## Constraints & Assumptions

**Technical**: [Constraints] | **Business**: [Constraints]
**Assumptions**: [Key assumptions]

## Dependencies

**External**: [APIs, services] | **Internal**: [Services, components]

## Glossary

| Term | Definition |
|------|------------|
| [Term] | [Definition] |

---

**Related**: Architecture | Contracts | Data Models | See docs for details
