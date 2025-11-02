# Decisions Log

Architecture Decision Records and significant choices.

---

## 2025-11-03: Feature 001 Planning Decisions

### ADR-001: State Passed from Commands, Not Re-Read in Guides

**Context**: Guides currently re-read state files, wasting tokens.

**Decision**: Commands read state once, pass to guides as context.

**Rationale**:
- Eliminates redundant reads (400 tokens/phase)
- Aligns with stated architecture (CLAUDE.md:129)
- Simpler mental model

**Implementation**: Remove Read calls from guides, document state passing convention.

**Status**: Planned

---

### ADR-002: Progressive Disclosure via Extraction, Not Inline

**Context**: Implement/guide.md has 277 lines of TDD docs loaded unconditionally.

**Decision**: Extract conditional content to separate files, load on demand.

**Rationale**:
- Base guide stays lean (< 1,000 tokens)
- Users get details only when needed
- Follows progressive disclosure principle

**Implementation**: Extract to implement/tdd-guide.md, add "See also" link.

**Status**: Planned

---

### ADR-003: Template Links over Duplication

**Context**: blueprint/examples.md duplicates entire 15K token template.

**Decision**: Replace with link to templates/ directory.

**Rationale**:
- Single source of truth
- Massive token savings (91%)
- Users get same information via link

**Implementation**: Edit blueprint/examples.md to 500-token link + brief example.

**Status**: Planned

---

### ADR-004: Remove Workflow Skill Abstraction (For Now)

**Context**: Commands reference "workflow skill" but no dispatcher exists.

**Decision**: Commands directly Read and execute phase guides.

**Rationale**:
- Simpler implementation
- Matches current reality
- Can add dispatcher later if needed

**Alternative**: Implement workflow skill dispatcher (8 hours additional work).

**Status**: Planned

---

## Decision Categories

**Architecture**: ADR-001, ADR-004
**Performance**: ADR-002, ADR-003
**UX**: (None yet)
**Infrastructure**: (None yet)
