# Implementation Plan: [FEATURE]

**Branch**: `[BRANCH-NAME]` (e.g., `PROJ-123-feature-name` or `001-feature-name`)
**Feature Number**: [###]
**Date**: [DATE]
**Spec**: `features/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `flow:plan` skill. See the flow:plan skill documentation for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## References to Project Artifacts

<!--
  This plan can reference the following .flow/ artifacts (flat peer model):
  - Architecture Blueprint: .flow/architecture-blueprint.md (for patterns, tech stack, guidelines)
  - API Contracts: .flow/contracts/openapi.yaml (if this feature touches APIs)
  - Data Models: .flow/data-models/entities.md (for entity definitions)
  - Product Requirements: .flow/product-requirements.md (for context)

  These are peer documents - reference as needed for consistency and guidance.
  User approval required before modifying any .flow/ artifacts.
-->

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]  
**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]  
**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]  
**Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]  
**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]
**Project Type**: [single/web/mobile - determines source structure]  
**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]  
**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]  
**Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]

## Blueprint Alignment Check

<!--
  OPTIONAL: Reference .flow/architecture-blueprint.md for guidance
  This is a peer artifact - not strictly enforced, but helpful for consistency

  Check alignment with:
  - Core Principles
  - Architecture Patterns
  - Technology Stack choices
  - API Design Guidelines (if applicable)
  - Data Modeling Guidelines
  - Security Guidelines
  - Performance Guidelines
  - Testing Guidelines
-->

**Architecture Pattern**: [Does this align with blueprint? e.g., "Follows modular monolith pattern"]
**Technology Stack**: [Using recommended stack? e.g., "Uses React + Node.js as per blueprint"]
**API Design**: [If applicable, follows API guidelines? e.g., "REST with OpenAPI, versioning per blueprint"]
**Data Modeling**: [Follows naming conventions? e.g., "snake_case tables, UUIDs for PKs per blueprint"]

**Deviations from Blueprint**: [If any, note here and get user approval]
  - [Deviation 1]: [Reason and approval status]
  - [Deviation 2]: [Reason and approval status]

## Project Structure

### Documentation (this feature)

```
features/[###-feature-name]/
├── spec.md              # Feature specification (flow:specify output)
├── plan.md              # This file (flow:plan output)
├── research.md          # Phase 0 output (flow:plan)
├── data-model.md        # Phase 1 output (flow:plan)
├── quickstart.md        # Phase 1 output (flow:plan)
├── contracts/           # Phase 1 output (flow:plan)
└── tasks.md             # Phase 2 output (flow:tasks - NOT created by flow:plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Blueprint Deviations & Justifications

<!--
  Fill ONLY if this feature deviates from .flow/architecture-blueprint.md
  User approval required for blueprint deviations
-->

| Deviation | Why Needed | Alignment Alternative Rejected Because |
|-----------|------------|---------------------------------------|
| [e.g., Using GraphQL instead of REST] | [specific reason] | [why REST insufficient for this case] |
| [e.g., NoSQL instead of PostgreSQL] | [specific need] | [why PostgreSQL doesn't fit] |

**User Approval**: [User approved deviations? Date and notes]

---

## Proposed Updates to .flow/ Artifacts

<!--
  If this feature requires updates to project-level artifacts, note them here
  USER APPROVAL REQUIRED before modifying any .flow/ artifacts

  Potential updates:
  - .flow/architecture-blueprint.md (if new patterns/decisions)
  - .flow/contracts/openapi.yaml (if new/modified APIs)
  - .flow/data-models/entities.md (if new/modified entities)
  - .flow/product-requirements.md (if requirements change)
-->

### Proposed Changes

**Architecture Blueprint** (.flow/architecture-blueprint.md):
- [ ] No changes needed
- [ ] Proposed changes: [Describe what needs to be added/updated]
  - Reason: [Why this change is needed]
  - User approval: [Pending/Approved/Rejected]

**API Contracts** (.flow/contracts/openapi.yaml):
- [ ] No changes needed
- [ ] Proposed changes: [New endpoints, modified schemas, etc.]
  - Endpoints: [List new/modified endpoints]
  - User approval: [Pending/Approved/Rejected]

**Data Models** (.flow/data-models/entities.md):
- [ ] No changes needed
- [ ] Proposed changes: [New entities, modified relationships]
  - Entities: [List new/modified entities]
  - User approval: [Pending/Approved/Rejected]

**Product Requirements** (.flow/product-requirements.md):
- [ ] No changes needed
- [ ] Proposed changes: [Rarely needed from plan level]
  - Changes: [Describe]
  - User approval: [Pending/Approved/Rejected]

