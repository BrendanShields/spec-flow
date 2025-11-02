# Implementation Plan: [FEATURE]

**Branch**: `[BRANCH-NAME]` | **Feature**: [###] | **Spec**: `{config.paths.features}/[###-feature-name]/{config.naming.files.spec}`

## Summary

[Primary requirement + technical approach from research]

## Technical Context

**Language**: [Version] | **Dependencies**: [List] | **Storage**: [DB or N/A]
**Testing**: [Framework] | **Platform**: [Target environment] | **Type**: [single/web/mobile]
**Performance**: [Goals] | **Constraints**: [Key limits] | **Scale**: [Scope]

## Project Artifacts

References (flat peer model, user approval required to modify):
- Architecture: `{config.paths.spec_root}/architecture-blueprint.md`
- API Contracts: `{config.paths.spec_root}/contracts/openapi.yaml`
- Data Models: `{config.paths.spec_root}/data-models/entities.md`

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
{config.paths.features}/[###-feature-name]/
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

## {config.paths.spec_root}/ Updates

**Approval Required** before modifying project-level artifacts:

| Artifact | Changes | Status |
|----------|---------|--------|
| blueprint.md | [None/List proposed] | [Pending/Approved] |
| contracts/ | [None/List endpoints] | [Pending/Approved] |
| entities.md | [None/List entities] | [Pending/Approved] |
| product-requirements.md | [None/Changes] | [Pending/Approved] |

