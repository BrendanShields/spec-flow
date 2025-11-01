# Phase 2: Define Requirements

Create and validate feature specifications with clear, testable requirements.

## Purpose

Transform feature ideas into structured specifications with prioritized user stories, acceptance criteria, and resolved ambiguities.

## Core Workflow

### generate/ ⭐ REQUIRED
**Purpose**: Create feature specifications with user stories
**Invocation**: `/spec generate "Feature description"`
**When**: Starting new feature development
**Output**: `spec.md` with P1/P2/P3 prioritized user stories, acceptance criteria

**Usage**: Always run to create feature specification - foundation for all subsequent phases

## Supporting Tools

### clarify/ 🔧 AS NEEDED
**Purpose**: Resolve ambiguities and vague requirements
**Invocation**: `/spec clarify`
**When**: [CLARIFY] tags present or vague terms detected ("fast", "scalable")
**Output**: Clarified `spec.md` with decisions logged to DECISIONS-LOG.md

**Usage**: Run when spec contains ambiguities - can run multiple times (4 questions per session)

### checklist/ 🔧 QUALITY GATE
**Purpose**: Validate requirement quality and completeness
**Invocation**: `/spec checklist`
**When**: Enterprise compliance, quality validation needed
**Output**: Domain-specific checklists (UX, API, security, performance)

**Usage**: Optional quality gate before planning - ensures specification completeness

## Workflow Patterns

**Standard Flow** (most features):
```
generate/ ⭐ → clarify/ 🔧 (if needed) → Ready for Phase 3
```

**Enterprise/Compliance**:
```
generate/ ⭐ → clarify/ 🔧 → checklist/ 🔧 → Review → Ready for Phase 3
```

**Iterative Clarification**:
```
generate/ ⭐ → clarify/ 🔧 (4 questions) → clarify/ 🔧 (remaining) → Ready for Phase 3
```

## Exit Criteria

Ready for Phase 3 when:
- ✅ `spec.md` exists with user stories (generate/ complete)
- ✅ All [CLARIFY] tags resolved OR consciously deferred
- ✅ Acceptance criteria specific and measurable
- ✅ Priorities assigned (P1/P2/P3)
- ✅ Quality checklists validated (if applicable)
- ✅ Stakeholders approved requirements

## Navigation

**Functions in this phase**:
- [generate/](./generate/) - Create specifications ⭐
- [clarify/](./clarify/) - Resolve ambiguities 🔧
- [checklist/](./checklist/) - Validate quality 🔧

**Previous phase**: [Phase 1: Initialize](../1-initialize/)  
**Next phase**: [Phase 3: Design Solution](../3-design/)

---

⭐ = Core workflow (required)  
🔧 = Supporting tool (contextual)
