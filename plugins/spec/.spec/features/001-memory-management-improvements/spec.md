# Feature: Memory Management and State Transition Improvements

**Feature ID**: 001
**Priority**: P1 (Must Have)
**Owner**: Spec Plugin Team
**Created**: 2025-01-03
**Status**: Specification

---

## Problem Statement

The Spec workflow plugin currently has memory and state management spread across multiple systems:

1. **State files** (`.spec/state/`) - Session tracking, current work
2. **Memory files** (`.spec/memory/`) - Persistent history, decisions, changes
3. **Session files** (`.spec/.session.json`) - Legacy session storage
4. **Hooks system** - Automated state transitions and tracking

This distributed approach leads to:
- Inconsistent state updates across different files
- Manual synchronization required between state systems
- Potential for state drift when hooks fail
- Lack of atomic state transitions
- No guaranteed consistency between session state and memory files
- Unclear ownership of state update responsibilities

**Desired Outcome:**
A unified, hook-driven memory management system that ensures all state transitions and documentation updates are automatic, consistent, and atomic.

---

## User Stories

### P1 (Must Have)

#### US1.1: Automated State Transitions
**As a** workflow developer
**I want** all state transitions to be managed automatically through hooks
**So that** state is always consistent and synchronized across all files

**Acceptance Criteria:**
- [ ] All phase transitions automatically update `current-session.md`
- [ ] Memory files (`WORKFLOW-PROGRESS.md`, `DECISIONS-LOG.md`, etc.) update atomically
- [ ] Failed state transitions roll back completely
- [ ] State changes are validated before persisting
- [ ] Hooks handle all state updates; phase guides never write state directly

#### US1.2: Centralized Memory Management
**As a** workflow developer
**I want** a single memory manager component that coordinates all state writes
**So that** I don't have duplicate or conflicting state updates

**Acceptance Criteria:**
- [ ] Memory manager class coordinates all state file operations
- [ ] Single source of truth for current session state
- [ ] Atomic transactions for multi-file updates
- [ ] Validation layer ensures state consistency
- [ ] Clear API for state queries and mutations

#### US1.3: Hook-Based Documentation Updates
**As a** user working through the workflow
**I want** documentation files to update automatically as I progress
**So that** I don't have to manually maintain multiple tracking files

**Acceptance Criteria:**
- [ ] `WORKFLOW-PROGRESS.md` updates automatically on phase completion
- [ ] `DECISIONS-LOG.md` appends when ADRs are created
- [ ] `CHANGES-PLANNED.md` updates when tasks are generated
- [ ] `CHANGES-COMPLETED.md` updates when tasks complete
- [ ] All updates triggered by hooks, not manual writes

#### US1.4: State Validation and Recovery
**As a** workflow developer
**I want** state validation and automatic recovery from corrupted state
**So that** the workflow is resilient to interruptions and errors

**Acceptance Criteria:**
- [ ] Schema validation for all state files
- [ ] Automatic recovery from corrupted YAML/Markdown
- [ ] State snapshots for rollback capability
- [ ] Warning notifications when state inconsistencies detected
- [ ] Recovery suggestions provided to users

#### US1.5: Session Continuity
**As a** user resuming work after interruption
**I want** the system to restore my exact context from before
**So that** I can continue seamlessly without losing progress

**Acceptance Criteria:**
- [ ] Session restoration loads feature, phase, and task context
- [ ] Recent file changes tracked and surfaced
- [ ] Pending work highlighted automatically
- [ ] Time tracking persists across sessions
- [ ] Context-aware suggestions provided on resume

### P2 (Should Have)

#### US2.1: State Change History
**As a** workflow analyst
**I want** complete audit trail of all state changes
**So that** I can debug issues and analyze workflow patterns

**Acceptance Criteria:**
- [ ] All state mutations logged with timestamp and context
- [ ] Change history stored in `.spec/state/history/`
- [ ] Queryable change log via tracking commands
- [ ] Rollback to previous state possible
- [ ] Export history for analysis

#### US2.2: Cross-Session Analytics
**As a** project manager
**I want** analytics across multiple sessions and features
**So that** I can understand team velocity and bottlenecks

**Acceptance Criteria:**
- [ ] Session metrics aggregated over time
- [ ] Phase duration analytics
- [ ] Bottleneck detection (phases taking longest)
- [ ] Velocity trends visualization
- [ ] Export to external analytics tools

#### US2.3: State Migration Support
**As a** plugin maintainer
**I want** automatic state schema migration
**So that** users can upgrade without manual intervention

**Acceptance Criteria:**
- [ ] Detect state schema version
- [ ] Automatic migration from old to new formats
- [ ] Backup before migration
- [ ] Migration success/failure reporting
- [ ] Rollback capability if migration fails

### P3 (Nice to Have)

#### US3.1: State Visualization Dashboard
**As a** user
**I want** visual representation of workflow state
**So that** I can quickly understand where I am and what's next

**Acceptance Criteria:**
- [ ] ASCII/Markdown state diagram generation
- [ ] Progress bars for current phase
- [ ] Timeline visualization
- [ ] Dependency graph rendering
- [ ] Export to HTML/SVG

#### US3.2: State Diff and Comparison
**As a** developer debugging state issues
**I want** ability to diff state between points in time
**So that** I can identify what changed and when

**Acceptance Criteria:**
- [ ] Diff two state snapshots
- [ ] Highlight changes between sessions
- [ ] Show what changed during a phase
- [ ] Export diff reports
- [ ] Visual diff rendering

---

## Technical Requirements

### Architecture

**Memory Management System Components:**

1. **MemoryManager Class** (Core TypeScript class)
   - Singleton instance managing all state operations
   - Coordinates hooks and direct state access
   - Provides transaction API for atomic updates
   - Handles validation and error recovery

2. **State Store** (File-based persistence)
   - `current-session.md` - Active session state (YAML + Markdown)
   - `session-history/` - Historical session snapshots
   - `.session.json` - Deprecated, migrate to current-session.md

3. **Memory Store** (Git-committed history)
   - `WORKFLOW-PROGRESS.md` - Feature progress tracking
   - `DECISIONS-LOG.md` - Architecture decision records
   - `CHANGES-PLANNED.md` - Pending implementation tasks
   - `CHANGES-COMPLETED.md` - Completed work audit trail

4. **Hooks Integration**
   - `update-memory.ts` - Generic memory update hook
   - `validate-state.ts` - State validation hook
   - `track-transitions.ts` - Phase transition tracking
   - `snapshot-state.ts` - Periodic state snapshots

### Data Flow

```
Phase Guide/Command
   ↓
Memory Manager API
   ↓
Transaction Validation
   ↓
Hooks Triggered (PostToolUse)
   ↓
Atomic File Updates
   ↓
State Validation
   ↓
Success/Rollback
```

### API Surface

```typescript
// Memory Manager API
interface MemoryManager {
  // Session management
  getCurrentSession(): SessionState;
  updateSession(updates: Partial<SessionState>): Promise<void>;
  saveSession(): Promise<void>;
  restoreSession(): Promise<SessionState | null>;

  // Phase transitions
  transitionPhase(from: Phase, to: Phase, metadata?: object): Promise<void>;
  recordPhaseCompletion(phase: Phase, stats: PhaseStats): Promise<void>;

  // Memory file operations
  appendWorkflowProgress(entry: ProgressEntry): Promise<void>;
  appendDecisionLog(adr: DecisionRecord): Promise<void>;
  movePlannedToCompleted(changeId: string): Promise<void>;

  // State snapshots
  createSnapshot(label?: string): Promise<string>;
  listSnapshots(): Promise<Snapshot[]>;
  restoreSnapshot(snapshotId: string): Promise<void>;

  // Validation
  validateState(): Promise<ValidationResult>;
  detectInconsistencies(): Promise<Inconsistency[]>;
  repairState(): Promise<RepairReport>;
}
```

### Hook Event Mapping

| Event | Hook | Responsibility |
|-------|------|----------------|
| `SessionStart` | `session-init.ts` | Initialize memory manager, restore session |
| `SessionStop` | `save-session.ts` | Save session snapshot |
| `PostToolUse` (Skill) | `track-transitions.ts` | Record phase transitions |
| `PostToolUse` (Write/Edit) | `track-changes.ts` | Update CHANGES files |
| `SubagentStop` | `aggregate-results.ts` | Consolidate subagent state |
| `PreToolUse` (Validate) | `validate-state.ts` | Pre-validate state consistency |

### File Locations

All paths configurable via `.claude/.spec-config.yml`:

- State files: `{config.paths.state}/` (default: `.spec/state/`)
- Memory files: `{config.paths.memory}/` (default: `.spec/state/memory/`)
- Snapshots: `{config.paths.state}/snapshots/` (new)
- History: `{config.paths.state}/history/` (new)

### Performance Considerations

- Cache session state in memory (singleton)
- Debounce rapid state updates (max 1 write/second)
- Lazy-load historical data
- Background snapshot creation (non-blocking)
- Incremental validation (not full scan each time)

---

## Integration Points

### With Existing Systems

1. **Phase Guides** - Call Memory Manager API instead of direct file writes
2. **Hooks System** - Enhanced with new memory management hooks
3. **Config System** - Memory paths configurable in `.spec-config.yml`
4. **Subagents** - Report state changes to Memory Manager
5. **Templates** - Source of truth for state file structure

### With External Tools

1. **Git** - Memory files committed, state files git-ignored
2. **JIRA** - Optional sync of progress to JIRA stories
3. **Confluence** - Optional publish of decision log
4. **CI/CD** - State validation in pre-commit hooks

### Breaking Changes

- `.spec/.session.json` deprecated → Migrate to `current-session.md`
- Direct state file writes disallowed → Use Memory Manager API
- Hook signature changes for state validation hooks

### Migration Path

1. Detect legacy `.session.json` on first run
2. Migrate to `current-session.md` format automatically
3. Log migration completion
4. Preserve `.session.json` as backup for 30 days
5. Update all phase guides to use Memory Manager

---

## Non-Functional Requirements

### Reliability
- State writes must be atomic (all or nothing)
- Corruption recovery within 100ms
- Zero data loss on crashes
- 99.9% state consistency

### Performance
- State reads < 10ms (cached)
- State writes < 50ms (validated)
- Snapshot creation < 200ms
- Memory footprint < 5MB

### Maintainability
- Clear separation of concerns (Memory Manager vs Hooks)
- Comprehensive TypeScript types
- Unit tests for all state operations
- Integration tests for hook workflows

### Observability
- Structured logging for all state changes
- Error reporting with context
- Metrics for state operation performance
- Debug mode for verbose state tracking

---

## Out of Scope

### Explicitly NOT Included

- Real-time collaboration (multiple users editing same state)
- Cloud synchronization of state (local-only)
- Distributed state management across machines
- UI/Dashboard (Markdown-only for v1)
- State encryption (future consideration)
- External database integration (file-based only)

### Future Considerations

- GraphQL API for state queries
- WebSocket-based real-time updates
- Cloud backup integration
- State compression for large histories
- AI-powered state recovery suggestions

---

## Open Questions

### [CLARIFY: Snapshot Retention Policy]
How long should state snapshots be retained?
- Option A: Last 10 snapshots only
- Option B: 30 days of history
- Option C: Configurable per-project

**Recommendation**: Start with Option B (30 days), make configurable later

### [CLARIFY: Hook Failure Handling]
What happens when a memory hook fails?
- Option A: Block operation, force fix
- Option B: Log warning, continue (current behavior)
- Option C: Retry 3 times, then degrade gracefully

**Recommendation**: Option C for production resilience

### [CLARIFY: State Schema Versioning]
How do we handle schema version mismatches?
- Include version in state file frontmatter
- Auto-migrate on version bump
- Manual migration for major versions only

**Status**: Need decision on auto-migration safety

### [CLARIFY: Memory Manager Initialization]
When should Memory Manager be initialized?
- On plugin load (singleton pattern)
- On first command invocation (lazy)
- Via explicit init hook (SessionStart)

**Recommendation**: SessionStart hook initialization

---

## Success Metrics

### Development Metrics
- Zero manual state file edits in phase guides
- 100% hook coverage for state transitions
- < 5 state inconsistencies per 1000 operations
- All state tests passing

### User Experience Metrics
- 95% session restoration accuracy
- < 1 second state load time
- Zero data loss incidents
- Positive user feedback on reliability

### Code Quality Metrics
- 90% code coverage for memory system
- Zero critical state bugs in production
- TypeScript strict mode compliance
- All ESLint rules passing

---

## Dependencies

### Required Before Implementation
- TypeScript hooks system (v3.3.0) ✅ Complete
- Config-driven paths (`.spec-config.yml`) ✅ Complete
- State file templates ✅ Complete

### Blocks These Features
- Real-time collaboration (needs state foundation)
- Advanced metrics dashboard (needs state history)
- AI-powered workflow suggestions (needs state patterns)

### Parallel Work Opportunities
- Can implement Memory Manager while refactoring hooks
- State validation can be developed independently
- Snapshot system can be added incrementally

---

## Timeline Estimate

- **Specification & Design**: 2 hours (this document)
- **Memory Manager Core**: 4-6 hours
- **Hook Integration**: 3-4 hours
- **Migration Logic**: 2-3 hours
- **Testing & Validation**: 3-4 hours
- **Documentation Updates**: 1-2 hours

**Total Estimated Effort**: 15-21 hours (2-3 working days)

---

## Notes

This specification focuses on creating a robust, hook-driven memory management system that will serve as the foundation for all future state-dependent features. The design prioritizes reliability and consistency over features, with clear extension points for future enhancements.

Key design principles:
1. **Hooks-first** - All state changes flow through hooks
2. **Atomic operations** - All or nothing for multi-file updates
3. **Fail-safe** - Graceful degradation when things go wrong
4. **Observable** - Everything logged and traceable
5. **Extensible** - Clear APIs for future features

---

*Generated by Spec Workflow System v3.3.0*
*Next Step: Create technical plan → `/workflow:spec` → "🎨 Move to Design"*
