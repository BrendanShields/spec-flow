# Implementation Plan: [FEATURE]

**Branch**: `[BRANCH-NAME]` | **Feature**: [###] | **Spec**: `features/[###-feature-name]/spec.md`

## Summary

[Primary requirement + technical approach from research]

## Technical Context

**Language**: [Version] | **Dependencies**: [List] | **Storage**: [DB or N/A]
**Testing**: [Framework] | **Platform**: [Target environment] | **Type**: [single/web/mobile]
**Performance**: [Goals] | **Constraints**: [Key limits] | **Scale**: [Scope]

## Project Artifacts

References (flat peer model, user approval required to modify):
- Architecture: `.spec/architecture-blueprint.md`
- API Contracts: `.spec/contracts/openapi.yaml`
- Data Models: `.spec/data-models/entities.md`

## Blueprint Alignment

**Architecture Pattern**: [Pattern] - [Aligned?]
**Tech Stack**: [Stack] - [Aligned?]
**API Design**: [Style] - [Aligned?]
**Data Modeling**: [Conventions] - [Aligned?]

**Deviations** (user approval required):
| Deviation | Reason | Alternative |
|-----------|--------|-------------|
| [e.g., GraphQL vs REST] | [Reason] | [Why not aligned] |

## Project Structure

**Documentation**:
```
features/[###-feature-name]/
├── spec.md      # Feature specification
├── plan.md      # This file (technical plan)
└── tasks.md     # Task breakdown
```

**Source Code** (choose one):
```
Option 1: Single project (DEFAULT)
src/ → {models/, services/, cli/, lib/}
tests/ → {contract/, integration/, unit/}

Option 2: Web application
backend/src/ → {models/, services/, api/}
frontend/src/ → {components/, pages/, services/}

Option 3: Mobile + API
api/ → [backend structure]
ios/ or android/ → [platform-specific modules]
```

**Selected**: [Document chosen structure with real paths]

## .spec/ Updates

**Approval Required** before modifying project-level artifacts:

| Artifact | Changes | Status |
|----------|---------|--------|
| blueprint.md | [None/List proposed] | [Pending/Approved] |
| contracts/ | [None/List endpoints] | [Pending/Approved] |
| entities.md | [None/List entities] | [Pending/Approved] |
| product-requirements.md | [None/Changes] | [Pending/Approved] |

