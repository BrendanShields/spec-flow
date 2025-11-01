# Phase 1: Initialize

Setup project structure and define architecture foundation.

## Purpose

Establish Spec workflow infrastructure and architectural guidelines before feature development begins.

## Core Workflow

### init/ ⭐ REQUIRED
**Purpose**: Initialize Spec workflow in project  
**When**: Starting new project or adding Spec to existing code  
**Duration**: 15-30 minutes  
**Output**: `.spec/` structure, state management, workflow files

**Usage**: Always run first, creates foundation for all other phases

## Supporting Tools

### discover/ 🔧 BROWNFIELD ONLY
**Purpose**: Analyze existing codebase architecture  
**When**: Adding Spec to project with significant existing code  
**Duration**: 30-60 minutes  
**Output**: Discovery reports, architecture insights, JIRA analysis (if enabled)

**Usage**: Run before init on brownfield projects to inform architecture decisions

### blueprint/ 🔧 ARCHITECTURE DOCS
**Purpose**: Define project architecture and technical standards  
**When**: Need comprehensive architecture documentation  
**Duration**: 45-90 minutes  
**Output**: `.spec/architecture-blueprint.md` with 8 sections + ADRs

**Usage**: Optional but recommended - establishes team alignment on technical decisions

## Workflow Patterns

**Greenfield (New Project)**:
```
init/ ⭐ → blueprint/ 🔧 → Ready for Phase 2
```

**Brownfield (Existing Code)**:
```
discover/ 🔧 → init/ ⭐ → blueprint/ 🔧 → Ready for Phase 2
```

**Minimal Setup**:
```
init/ ⭐ → Ready for Phase 2 (can add blueprint later)
```

## Exit Criteria

Ready for Phase 2 when:
- ✅ `.spec/` directories exist (init/ complete)
- ✅ State management initialized
- ✅ Architecture documented OR decision to skip
- ✅ Team aligned on standards
- ✅ `.gitignore` updated

## Navigation

**Functions in this phase**:
- [init/](./init/) - Core initialization ⭐
- [discover/](./discover/) - Brownfield analysis 🔧
- [blueprint/](./blueprint/) - Architecture definition 🔧

**Next phase**: [Phase 2: Define Requirements](../2-define/)

---

⭐ = Core workflow (required)  
🔧 = Supporting tool (contextual)
