# User Story Format

## Standard Format

**As a** [persona/role]
**I want to** [capability/feature]
**So that** [benefit/value]

## Acceptance Criteria

Use Given-When-Then format:

- **Given** [initial context/state]
  **When** [action/trigger]
  **Then** [expected outcome]

## Priority Levels

- **P1** (Must Have): Core functionality, blocks release
- **P2** (Should Have): Important but can defer
- **P3** (Nice to Have): Optional enhancements

## Example

**As a** registered user
**I want to** reset my password
**So that** I can regain access if I forget it

**Acceptance Criteria**:
- **Given** I am on the login page
  **When** I click "Forgot Password"
  **Then** I see the password reset form

- **Given** I submit a valid email
  **When** the system processes the request
  **Then** I receive a reset link via email

**Priority**: P1