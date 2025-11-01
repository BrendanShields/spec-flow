# Phase 3: Design Solution

Create technical plan with architecture decisions and validate consistency.

## Purpose

Transform requirements into detailed technical design with architecture decisions, data models, API contracts, and implementation strategy.

## Core Workflow

### plan/ ⭐ REQUIRED
**Purpose**: Create technical design from specification
**Invocation**: `/spec plan`
**When**: Have approved specification from Phase 2
**Duration**: 30-90 minutes
**Output**: `plan.md` with architecture, data models, API contracts, ADRs

**Usage**: Always run to create technical plan - uses researcher agent for best practices

## Supporting Tools

### analyze/ 🔧 VALIDATION
**Purpose**: Validate consistency across spec/plan/tasks
**Invocation**: `/spec analyze`
**When**: Before implementation, after updates, complex features
**Duration**: 10-20 minutes
**Output**: Analysis report with CRITICAL/HIGH/MEDIUM/LOW issues

**Usage**: Recommended for complex features (>15 tasks) - catches gaps before implementation

## Workflow Patterns

**Standard Flow**:
```
plan/ ⭐ → analyze/ 🔧 → Fix CRITICAL issues → Ready for Phase 4
```

**Quick Flow** (simple features <10 tasks):
```
plan/ ⭐ → Ready for Phase 4 (skip validation)
```

**Research-Heavy**:
```
plan/ ⭐ --research-depth=deep → analyze/ 🔧 → Ready for Phase 4
```

## Exit Criteria

Ready for Phase 4 when:
- ✅ `plan.md` exists with complete technical design (plan/ complete)
- ✅ All major architecture decisions documented as ADRs
- ✅ Data models defined with schemas
- ✅ API contracts specified
- ✅ analyze/ shows no CRITICAL issues (if run)
- ✅ Security considerations addressed
- ✅ Testing strategy defined
- ✅ Team reviewed technical approach

## Navigation

**Functions in this phase**:
- [plan/](./plan/) - Create technical plan ⭐
- [analyze/](./analyze/) - Validate consistency 🔧

**Previous phase**: [Phase 2: Define Requirements](../2-define/)  
**Next phase**: [Phase 4: Build Feature](../4-build/)

---

⭐ = Core workflow (required)  
🔧 = Supporting tool (contextual)
