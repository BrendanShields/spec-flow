# Product Requirements: [PROJECT_NAME]

**Project Type**: [Greenfield/Brownfield]
**Domain**: [E-commerce/SaaS/API/Analytics/Fintech/Other]
**Created**: [DATE]
**Last Updated**: [DATE]
**Status**: [Draft/Active/Archived]

## Vision & Goals

### Product Vision
[What is this product? What problem does it solve? Who is it for?]

### Business Goals
- **BG-001**: [Measurable business objective, e.g., "Reduce customer support tickets by 40%"]
- **BG-002**: [Revenue/growth goal, e.g., "Enable 10,000 concurrent users"]
- **BG-003**: [Market positioning, e.g., "First-to-market for X feature"]

## User Personas

### Primary Persona: [Role Name]
**Who**: [Description of user type]
**Goals**: [What they want to achieve]
**Pain Points**: [Current problems they face]
**Success**: [How they measure success]

### Secondary Persona: [Role Name]
**Who**: [Description]
**Goals**: [Objectives]
**Pain Points**: [Challenges]

## User Stories (Prioritized)

<!--
  CRITICAL: User stories define the WHAT (product requirements).
  Features will implement these stories.
  Each story must be:
  - Independently valuable
  - Testable
  - Prioritized (P1 = MVP, P2 = Important, P3 = Nice-to-have)

  JIRA Integration: If Atlassian enabled, stories can sync bidirectionally with JIRA
-->

### Epic 1: [Epic Name]

#### User Story 1.1 - [Title] (Priority: P1)

**As a** [persona]
**I want to** [capability]
**So that** [benefit]

**Why P1**: [Value justification - why is this MVP?]

**Acceptance Criteria**:
- **Given** [state], **When** [action], **Then** [outcome]
- **Given** [state], **When** [action], **Then** [outcome]

**Success Metrics**:
- [How to measure if this delivers value, e.g., "80% of users complete onboarding"]

---

#### User Story 1.2 - [Title] (Priority: P2)

**As a** [persona]
**I want to** [capability]
**So that** [benefit]

**Why P2**: [Why important but not MVP?]

**Acceptance Criteria**:
- **Given** [state], **When** [action], **Then** [outcome]

**Success Metrics**:
- [Measurement criteria]

---

### Epic 2: [Epic Name]

#### User Story 2.1 - [Title] (Priority: P1)

[Follow same format as above]

---

## Key Entities (Domain Model)

<!--
  Define the core business entities (not technical implementation).
  Features will reference these entities.
  See .flow/data-models/entities.md for technical details.
-->

### Entity: [Name]
**Purpose**: [What this represents in the domain]
**Key Attributes**:
- [Attribute 1]: [Description, e.g., "Unique identifier"]
- [Attribute 2]: [Description, e.g., "User-facing name"]

**Relationships**:
- [Relationship to other entity, e.g., "Belongs to Organization"]

**Business Rules**:
- [Rule 1, e.g., "Email must be unique per organization"]
- [Rule 2, e.g., "Cannot delete if has active subscriptions"]

---

### Entity: [Name]
[Follow same format]

---

## Functional Requirements (Cross-Cutting)

<!--
  Requirements that span multiple user stories.
  Features must comply with these.
-->

### Security & Compliance
- **FR-SEC-001**: System MUST [security requirement]
- **FR-SEC-002**: System MUST [compliance requirement]

### Performance & Scalability
- **FR-PERF-001**: System MUST [performance requirement, e.g., "respond within 200ms for 95th percentile"]
- **FR-PERF-002**: System MUST [scalability requirement]

### Accessibility
- **FR-A11Y-001**: System MUST [accessibility requirement, e.g., "meet WCAG 2.1 AA standards"]

### Integration
- **FR-INT-001**: System MUST [integration requirement]

## Non-Functional Requirements

### Availability
- **NFR-001**: [Uptime requirement, e.g., "99.9% uptime"]

### Reliability
- **NFR-002**: [Data integrity, backup requirements]

### Usability
- **NFR-003**: [User experience standards]

### Maintainability
- **NFR-004**: [Code quality, documentation standards]

## Success Criteria (Product-Level)

<!--
  How do we know the product is successful?
  These are product-level metrics (not story-level).
-->

- **PC-001**: [User adoption metric, e.g., "1000 active users within 6 months"]
- **PC-002**: [Engagement metric, e.g., "Average session duration > 10 minutes"]
- **PC-003**: [Business metric, e.g., "Customer acquisition cost < $50"]
- **PC-004**: [Quality metric, e.g., "Customer satisfaction score > 4.5/5"]

## Out of Scope (V1)

<!--
  Explicitly define what is NOT included.
  Prevents scope creep.
-->

- [Feature/capability that is deferred]
- [Integration that is not included]
- [Use case that is out of scope]

## Constraints & Assumptions

### Technical Constraints
- [Constraint 1, e.g., "Must support browsers released in last 2 years"]
- [Constraint 2, e.g., "Data must remain in EU region"]

### Business Constraints
- [Budget constraint]
- [Timeline constraint]
- [Resource constraint]

### Assumptions
- [Assumption 1, e.g., "Users have stable internet connection"]
- [Assumption 2, e.g., "Third-party API will remain available"]

## Dependencies

### External Dependencies
- [Dependency 1, e.g., "Payment gateway API (Stripe)"]
- [Dependency 2, e.g., "Email service provider"]

### Internal Dependencies
- [Dependency 1, e.g., "Shared authentication service"]
- [Dependency 2, e.g., "Design system components"]

## Glossary

| Term | Definition |
|------|------------|
| [Term 1] | [Definition] |
| [Term 2] | [Definition] |

---

## Change Log

| Date | Version | Change | Author |
|------|---------|--------|--------|
| [DATE] | 1.0.0 | Initial PRD | [NAME] |
| [DATE] | 1.1.0 | [Change description] | [NAME] |

---

**Related Artifacts**:
- Architecture: `.flow/architecture-blueprint.md`
- API Contracts: `.flow/contracts/openapi.yaml` (if API project)
- Data Models: `.flow/data-models/entities.md`

**JIRA Integration** (if enabled):
- Stories from this PRD can sync bidirectionally with JIRA
- User approval required before syncing TO JIRA
- See individual feature specs for JIRA story links
