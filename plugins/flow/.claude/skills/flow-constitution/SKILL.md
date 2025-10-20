---
name: flow:constitution
description: Create or update project constitution defining development principles, quality standards, and governance. Acts as the project's development contract with version control.
---

# Flow Constitution: Project Governance

Define and enforce project-level development principles and standards.

## When to Use

- **First time** setting up a new project
- When team needs to align on practices
- When extracting patterns from brownfield projects
- When updating core development principles

## What This Skill Does

1. **Interactive Mode**:
   - Prompts for key principles
   - Suggests based on project type
   - Documents in `.specify/memory/constitution.md`

2. **Extract Mode** (brownfield):
   - Analyzes existing codebase
   - Infers practices from code patterns
   - Documents discovered conventions

3. **Update Mode**:
   - Version control (semantic versioning)
   - Tracks amendments
   - Validates impact on existing specs

## Constitution Structure

```markdown
# Project Constitution

## Core Principles

### I. Principle Name
[Description of non-negotiable rule]
[Rationale]

### II. Another Principle
[Description]
[Rationale]

## Governance
- Amendment procedure
- Versioning policy
- Compliance review

**Version**: 1.0.0
**Ratified**: 2025-10-20
**Last Amended**: 2025-10-20
```

## Example Principles

### For Solo Developer
```markdown
### I. Tests Required (Not TDD)
Tests must exist for all features but can be written after implementation.
Rationale: Balance between quality and velocity for solo work.

### II. Monolith First
Start with monolithic architecture, extract services only when scaling demands it.
Rationale: Faster iteration, simpler deployment, easier debugging.
```

### For Enterprise Team
```markdown
### I. TDD Mandatory (NON-NEGOTIABLE)
Tests written → User approved → Tests fail → Then implement
Rationale: Team quality standard, prevents regressions.

### II. Code Review Required
All PRs require 2 approvals before merge.
Rationale: Knowledge sharing, quality assurance, compliance.

### III. Security Gates
All features must pass security checklist before deployment.
Rationale: Compliance requirements, customer trust.
```

## Constitution Authority

- **CRITICAL ERROR**: Constitution violations block workflow
- **Cannot bypass**: Must fix violation OR update constitution
- **Version controlled**: All changes tracked with rationale
- **Team agreement**: Amendments require consensus

## Versioning

**Semantic Versioning**:
- **MAJOR**: Backward incompatible changes
- **MINOR**: New principles added
- **PATCH**: Clarifications, wording fixes

## Modes

```bash
# Interactive creation
flow:constitution

# Extract from existing code
flow:constitution --extract

# Update existing
flow:constitution --update
```

## When to Update

- Team agrees to change core principle
- New compliance requirement
- Scaling forces architecture change
- Tool/framework standardization

**Not for**: Individual feature decisions, temporary choices

## Integration

All workflow skills validate against constitution:
- **flow:specify**: Checks requirements compliance
- **flow:plan**: Validates architecture decisions
- **flow:implement**: Enforces development practices

## Related Skills

- **flow:specify**: Create specifications (after constitution)
- **flow:analyze**: Validates constitution compliance
