# Architecture Decisions Log

Record of all significant technical and architectural decisions made during development.

**Project**: Spec Plugin
**Created**: 2025-01-03
**Last Updated**: 2025-01-03

---

## Decision Index

| ID | Date | Title | Status | Impact | Feature |
|----|------|-------|--------|--------|---------|
| ADR-001 | 2025-01-03 | Singleton Pattern for MemoryManager | Accepted | High | 001 |
| ADR-002 | 2025-01-03 | File-Based Persistence Over Database | Accepted | High | 001 |
| ADR-003 | 2025-01-03 | Hooks as Enforcement Layer | Accepted | High | 001 |
| ADR-004 | 2025-01-03 | 30-Day Snapshot Retention | Accepted | Medium | 001 |

---

## Decisions

### ADR-001: Singleton Pattern for MemoryManager

**Date**: 2025-01-03
**Status**: Accepted
**Deciders**: Spec Plugin Team
**Feature**: 001-memory-management-improvements

#### Context
Need single source of truth for session state. Multiple MemoryManager instances would cause cache inconsistencies and race conditions across hooks and phase guides.

#### Decision
Implement MemoryManager as singleton with `getInstance()` factory method. Single instance initialized on SessionStart, shared across all hooks and phase operations.

#### Rationale
- Ensures single in-memory cache for session state
- Simplifies hook coordination and prevents race conditions
- Standard pattern for state managers in TypeScript/Node.js
- Enables consistent state validation across all operations

#### Consequences

**Positive**:
- Cache coherency guaranteed across all operations
- Simplified testing (can reset singleton between tests)
- No race conditions from concurrent state access
- Clear ownership model for state mutations

**Negative**:
- Global state pattern (acceptable for single-user CLI)
- Harder to parallelize operations (not a concern for workflow)

**Neutral**:
- Requires explicit initialization in SessionStart hook
- Testing requires singleton reset between test cases

#### Alternatives Considered

1. **Dependency injection** - Rejected: Overly complex for CLI use case, adds boilerplate
2. **Multiple instances with locking** - Rejected: Unnecessary complexity, no real parallelism needed
3. **Static methods only** - Rejected: No state caching, repeated file reads

#### Implementation Notes
- Use lazy initialization on first `getInstance()` call
- Throw error if accessed before config available
- Provide `resetInstance()` for testing
- Cache session state in memory, refresh on explicit reload

#### Related Decisions
- Related to: ADR-003 (Hooks enforce singleton access)

---

### ADR-002: File-Based Persistence Over Database

**Date**: 2025-01-03
**Status**: Accepted
**Deciders**: Spec Plugin Team
**Feature**: 001-memory-management-improvements

#### Context
Need to persist state across sessions. Options include SQLite database, JSON files, or Markdown files with YAML frontmatter. State must be human-readable, git-friendly, and debuggable.

#### Decision
Use Markdown files with YAML frontmatter for state persistence. Session state stored in `current-session.md`, snapshots in separate `.md` files.

#### Rationale
- Human-readable and manually editable if needed
- Git-friendly: diff-able, merge-able, reviewable
- No external dependencies (no SQLite driver needed)
- Consistent with existing Spec file formats (spec.md, plan.md, tasks.md)
- Easy debugging: `cat .spec/state/current-session.md`
- YAML frontmatter provides structured metadata

#### Consequences

**Positive**:
- Zero database setup or dependencies
- Easy to inspect, debug, and manually fix if corrupted
- Version control friendly (meaningful diffs)
- No migration needed from existing format

**Negative**:
- Slower than binary database (not performance-critical for our use case)
- No ACID guarantees (mitigated by atomic write operations)
- File size grows with history (mitigated by snapshot cleanup)

**Neutral**:
- Requires careful atomic write implementation
- Need schema validation to catch manual edits

#### Alternatives Considered

1. **SQLite database** - Rejected: Overkill, adds dependency, not human-readable
2. **Pure JSON files** - Rejected: Not as human-friendly, no markdown context
3. **Binary formats** - Rejected: Not inspectable, debugging nightmare

#### Implementation Notes
- YAML frontmatter for structured metadata (feature, phase, timestamps)
- Markdown body for human-readable context
- Atomic writes using temp file + rename pattern
- Schema validation on every read/write
- Backup before destructive operations

#### Related Decisions
- Supersedes: Legacy `.session.json` format (deprecated)
- Related to: ADR-004 (Snapshot retention for history)

---

### ADR-003: Hooks as Enforcement Layer

**Date**: 2025-01-03
**Status**: Accepted
**Deciders**: Spec Plugin Team
**Feature**: 001-memory-management-improvements

#### Context
Need to prevent phase guides from bypassing MemoryManager and writing state files directly. Pure documentation of the pattern is not enforced, leading to inevitable violations.

#### Decision
Use PreToolUse hooks to intercept and block direct writes to `.spec/state/` files. All state mutations must flow through MemoryManager API, which emits events for hooks.

#### Rationale
- Enforces architecture at runtime, not just in documentation
- Fails fast with clear errors when contract violated
- Visible error messages guide developers to correct API
- No way to accidentally bypass system
- Hooks already part of infrastructure, no new dependency

#### Consequences

**Positive**:
- Architecture is enforced, not just documented
- Clear, actionable error messages when pattern violated
- Prevents state drift from manual writes
- Forces correct usage of MemoryManager API

**Negative**:
- Adds hook execution overhead (~50ms per operation, acceptable)
- Requires updating all existing phase guides

**Neutral**:
- Hook matchers need maintenance if state file paths change
- Errors may confuse new contributors (mitigated by docs)

#### Alternatives Considered

1. **Documentation only** - Rejected: Not enforced, violations will happen
2. **File permissions (read-only)** - Rejected: Breaks legitimate updates via MemoryManager
3. **Code reviews** - Rejected: Human error prone, doesn't scale

#### Implementation Notes
- PreToolUse hook with matcher: `{ "tool": "Write", "path": "**/.spec/state/**" }`
- Hook checks if caller is MemoryManager (via environment variable)
- If not MemoryManager, return error with API usage instructions
- Allow writes from MemoryManager by setting `MEMORY_MANAGER_WRITE=1`

#### Related Decisions
- Enforces: ADR-001 (Singleton usage)
- Enables: ADR-002 (Atomic file operations)

---

### ADR-004: 30-Day Snapshot Retention

**Date**: 2025-01-03
**Status**: Accepted
**Deciders**: Spec Plugin Team
**Feature**: 001-memory-management-improvements

#### Context
Need to balance state history retention with disk usage. Snapshots can accumulate quickly (potentially one per phase per feature). Need policy for cleanup.

#### Decision
Retain snapshots for 30 days with tiered retention:
- Keep last 10 snapshots always (granular rollback)
- Keep 1 snapshot per day for older history (space efficiency)
- Delete snapshots older than 30 days
- Run cleanup automatically on SessionStart

Policy is configurable via `.spec-config.yml` for power users.

#### Rationale
- 30 days covers most recovery scenarios (interrupted work, bugs)
- Last 10 snapshots enable fine-grained rollback for recent work
- 1 per day reduces storage for older history
- Automatic cleanup prevents manual maintenance
- Configurable for projects with special needs

#### Consequences

**Positive**:
- Bounded disk usage (~10MB typical, ~30MB worst case)
- Fast rollback for recent changes
- Long-term recovery still possible (30 days)
- No manual cleanup required

**Negative**:
- Very old snapshots not available (acceptable tradeoff)
- Cleanup overhead on SessionStart (~100ms)

**Neutral**:
- Requires configuration if users want different retention
- Snapshot size depends on feature complexity

#### Alternatives Considered

1. **Keep all snapshots** - Rejected: Unbounded disk growth
2. **7-day retention** - Rejected: Too short for long-running projects
3. **Compression** - Rejected: Adds complexity, marginal benefit (~30% reduction)
4. **Cloud backup** - Rejected: Out of scope, privacy concerns

#### Implementation Notes
- Retention config: `snapshot_retention_days: 30` in `.spec-config.yml`
- Cleanup algorithm:
  1. Sort snapshots by timestamp
  2. Keep last 10 always
  3. For older: Keep 1 per day (latest in each day)
  4. Delete remainder older than retention period
- Log cleanup summary: "Deleted 5 snapshots older than 30 days"

#### Related Decisions
- Supports: ADR-002 (File-based persistence)
- Enables: State recovery and debugging

---

## How to Use This Log

### Adding a Decision
1. Copy the template below
2. Assign next ADR number (ADR-005, ADR-006, etc.)
3. Fill in all sections
4. Update the index table above
5. Commit to git

### Decision Statuses
- **Proposed**: Under consideration
- **Accepted**: Approved and implemented
- **Deprecated**: No longer recommended
- **Superseded**: Replaced by newer decision

---

## Decision Template

```markdown
### ADR-XXX: [Decision Title]

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Deprecated | Superseded
**Deciders**: [Names/Roles]
**Feature**: [Feature ID or "Global"]

#### Context
[What is the issue or situation that motivates this decision?]

#### Decision
[What is the change or approach we're proposing/have agreed to?]

#### Rationale
[Why did we choose this option?]

#### Consequences
**Positive**:
- [Benefit 1]
- [Benefit 2]

**Negative**:
- [Tradeoff 1]
- [Tradeoff 2]

**Neutral**:
- [Impact 1]

#### Alternatives Considered
1. **Option A**: [Brief description] - Rejected because [reason]
2. **Option B**: [Brief description] - Rejected because [reason]

#### Implementation Notes
- [Technical detail 1]
- [Technical detail 2]

#### Related Decisions
- Supersedes: (None)
- Related to: (None)
- See also: (None)
```

---

*Maintained by Spec Workflow System*
*Use `/workflow:track` → "📋 Decision Log" to add new decisions*
