# User Story Format

Stories are organised under **Epics**, which are derived from the most recent Product Requirements Document (PRD) and the Architecture Blueprint. Every story must reference a single parent epic and map to the blueprint capabilities that epic represents.

## Standard Format

**Parent Epic**: `[Epic Name]`

**As a** [persona/role]
**I want to** [capability/feature]
**So that** [benefit/value]

**Primary Reference**: `[PRD section or page]`
**Blueprint Alignment**: `[Blueprint capability/diagram ID]`

## Acceptance Criteria (BDD)

Capture behaviour using Given/When/Then scenarios. Each scenario should be independently testable and traceable back to the PRD or blueprint reference.

- **Scenario**: [Short name]
  - **Given** [initial context/state]
  - **When** [action/trigger]
  - **Then** [expected outcome]

Add additional **And** clauses only when they clarify results without changing the main outcome.

## Issue Tracking

- **GitHub**: Create one issue per story containing the story narrative, acceptance criteria, links to parent epic, and a checklist of the associated sub tasks.
- **External trackers (e.g., JIRA)**: Mirror the story into the configured tracker and cross-link the tracker ID in the GitHub issue. When no external system is available, note `External Tracker: None` in the issue body.

## Priority Levels

- **P1** (Must Have): Core functionality, blocks release
- **P2** (Should Have): Important but can defer
- **P3** (Nice to Have): Optional enhancements

## Example

**Parent Epic**: Password Recovery

**As a** registered user
**I want to** reset my password
**So that** I can regain access if I forget it

**Primary Reference**: PRD §4.1 Password Recovery
**Blueprint Alignment**: Auth Flows → Reset Sequence Diagram

**Acceptance Criteria**:
- **Scenario**: Request reset link
  - **Given** I am on the login page
  - **When** I click "Forgot Password"
  - **Then** I see the password reset form

- **Scenario**: Receive reset email
  - **Given** I submit a valid email
  - **When** the system processes the request
  - **Then** I receive a reset link via email

**Priority**: P1