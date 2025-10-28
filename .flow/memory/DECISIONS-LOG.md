# Architecture Decisions Log

**Project**: Spec-Flow Marketplace
**Started**: 2025-10-28

## How to Use This Log

This file tracks all significant architecture and design decisions made during development. Each decision includes:
- **Context**: Why was this decision needed?
- **Decision**: What was decided?
- **Rationale**: Why was this the best choice?
- **Consequences**: What are the trade-offs?
- **Status**: Accepted, Proposed, Deprecated, Superseded

---

## Decisions

### ADR-001: Initialize Flow at Marketplace Root

**Date**: 2025-10-28
**Status**: Accepted
**Context**: Needed to track marketplace-level development work
**Decision**: Initialize Flow at repository root, separate from plugin's own Flow setup
**Rationale**:
- Enables tracking marketplace features (new plugins, infrastructure)
- Separates marketplace concerns from plugin concerns
- Allows using Flow to develop Flow plugin itself

**Consequences**:
- ✅ Clear separation of concerns
- ✅ Can track marketplace-level work
- ✅ Can use Flow dogfooding approach
- ⚠️ Two Flow instances in repo (root and plugin)

**Alternatives Considered**:
1. No Flow at root - rejected (can't track marketplace work)
2. Single Flow in plugin - rejected (mixes concerns)

**Related Files**:
- `.flow/` (marketplace Flow)
- `plugins/flow/.flow/` (plugin Flow)

---

### ADR-002: Consolidate Under Single .flow/ Directory

**Date**: 2025-10-28
**Feature**: 001-flow-init-optimization
**Status**: Accepted
**Context**: Currently Flow creates multiple top-level directories which clutters project roots
**Decision**: Move all Flow artifacts under `.flow/` directory with subdirectories

**Rationale**:
- Cleaner project root (single `.flow/` instead of 3+ directories)
- Logical grouping of related files
- Industry standard (similar to `.git/`, `.vscode/`)
- Easier to find Flow-related files

**Consequences**:
- ✅ Cleaner project structure
- ✅ Easier navigation
- ✅ More professional appearance
- ⚠️ Need to update all path references

---

### ADR-003: Use JSON for Configuration Storage

**Date**: 2025-10-28
**Feature**: 001-flow-init-optimization
**Status**: Accepted
**Context**: Need to store user configuration in a way that's both human-readable and script-parseable
**Decision**: Use plain JSON format stored at `.flow/config/flow.json`

**Rationale**:
- Native support in bash with `jq` (available on most systems)
- Standard format, no learning curve
- Easy to validate and parse
- Can add comments via separate documentation

**Consequences**:
- ✅ Easy to parse in bash with `jq`
- ✅ Standard format, no special tooling
- ⚠️ No inline comments (mitigate with documentation)

---

### ADR-004: Unified /flow Command with Routing

**Date**: 2025-10-28
**Feature**: 001-flow-init-optimization
**Status**: Accepted
**Context**: Users need to remember multiple commands and the correct order
**Decision**: Create single `/flow` command that routes to subcommands or shows interactive menu

**Rationale**:
- Single entry point reduces cognitive load
- Smart menu guides users through workflow
- Better token efficiency (load menu first, then skill)
- Backward compatible

**Consequences**:
- ✅ Easier to learn and use
- ✅ Self-documenting (menu shows options)
- ✅ Reduces user errors
- ⚠️ Slightly more complex implementation

---

### ADR-005: Progressive Disclosure in CLAUDE.md

**Date**: 2025-10-28
**Feature**: 001-flow-init-optimization
**Status**: Accepted
**Context**: Current CLAUDE.md files are verbose, loading thousands of tokens
**Decision**: Use progressive disclosure pattern with brief root CLAUDE.md linking to detailed docs

**Rationale**:
- Massive token reduction (thousands → hundreds for common operations)
- Faster Claude response times
- Only loads details when actually needed
- Better organization of documentation

**Consequences**:
- ✅ 50%+ token reduction for most operations
- ✅ Faster init and common commands
- ⚠️ Need to maintain clear linking structure

---

### ADR-006: Interactive Prompts with AskUserQuestion

**Date**: 2025-10-28
**Feature**: 001-flow-init-optimization
**Status**: Accepted
**Context**: Init requires configuration but users shouldn't need to read docs
**Decision**: Use Claude's `AskUserQuestion` tool for interactive configuration

**Rationale**:
- Better UX (guided vs. reading docs)
- Prevents invalid configuration
- Self-documenting (prompts explain options)
- Power users can skip with CLI args

**Consequences**:
- ✅ Much better user experience
- ✅ Prevents configuration errors
- ⚠️ Requires AskUserQuestion tool access

---

## Decision Categories

### Architecture Decisions
- ADR-001: Initialize Flow at Marketplace Root
- ADR-002: Consolidate Under Single .flow/ Directory
- ADR-005: Progressive Disclosure in CLAUDE.md

### Technical Decisions
- ADR-003: Use JSON for Configuration Storage
- ADR-006: Interactive Prompts with AskUserQuestion

### UX Decisions
- ADR-004: Unified /flow Command with Routing
- ADR-006: Interactive Prompts with AskUserQuestion

### Technical Decisions

None yet.

### Process Decisions

None yet.

### Integration Decisions

None yet.

---

## Pending Decisions

No pending decisions requiring resolution.

---

## Deprecated Decisions

No deprecated decisions yet.

---

## Notes

- Keep this log updated as architectural decisions are made
- Reference ADR numbers in commit messages and documentation
- Revisit decisions periodically to validate they still hold
