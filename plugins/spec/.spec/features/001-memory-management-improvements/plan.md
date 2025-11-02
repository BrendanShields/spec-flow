# Memory Management and State Transition Improvements - Technical Plan

**Feature ID**: 001
**Created**: 2025-01-03
**Status**: Active
**Priority**: P1 (Must Have)

---

## Overview

This plan implements a centralized, hook-driven memory management system that eliminates manual state synchronization and ensures atomic, consistent state transitions across all workflow phases. The core innovation is a **MemoryManager singleton** that coordinates all state operations through a transactional API, with hooks serving as the enforcement layer that intercepts and validates all state changes before they persist to disk.

**Architecture Philosophy**:
- **Hooks enforce, MemoryManager coordinates** - Hooks are gatekeepers, MemoryManager is the orchestrator
- **Atomic or nothing** - Multi-file updates succeed together or roll back completely
- **Fail-safe by default** - Graceful degradation when state operations fail
- **Observable everything** - All state changes logged for debugging

---

## Architecture

### High-Level Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Phase Guides / Commands                  │
│                  (Never write state directly)                │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ API Calls
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    MemoryManager (Singleton)                 │
│  ┌────────────────┬──────────────┬─────────────────────┐   │
│  │ Session State  │ Transaction  │  Validation Layer   │   │
│  │    Cache       │   Manager    │  Schema Validator   │   │
│  └────────────────┴──────────────┴─────────────────────┘   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ Emit Events
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     Hooks System (TypeScript)                │
│  ┌──────────────────┬─────────────────┬──────────────────┐ │
│  │ update-memory.ts │ validate-state  │ track-transitions│ │
│  │ (Generic update) │ (Pre-validation)│ (Post-tracking)  │ │
│  └──────────────────┴─────────────────┴──────────────────┘ │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ File I/O (Atomic)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    File System Persistence                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ State Files (.spec/state/)      - Git-ignored       │   │
│  │   • current-session.md                              │   │
│  │   • snapshots/*.md                                  │   │
│  │   • history/*.json                                  │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Memory Files (.spec/state/memory/) - Git-committed  │   │
│  │   • WORKFLOW-PROGRESS.md                            │   │
│  │   • DECISIONS-LOG.md                                │   │
│  │   • CHANGES-PLANNED.md                              │   │
│  │   • CHANGES-COMPLETED.md                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

#### 1. MemoryManager (Core TypeScript Class)

**Location**: `.claude/hooks/src/core/memory-manager.ts`

**Responsibilities**:
- Maintain in-memory cache of current session state
- Provide transactional API for atomic multi-file updates
- Validate state changes before persistence
- Emit events for hook integration
- Handle state snapshots and rollbacks
- Coordinate between state and memory files

**Singleton Pattern**:
```typescript
class MemoryManager {
  private static instance: MemoryManager;
  private sessionCache: SessionState | null = null;
  private transactionLog: Transaction[] = [];

  private constructor(config: SpecConfig, cwd: string) { }

  static getInstance(config: SpecConfig, cwd: string): MemoryManager {
    if (!MemoryManager.instance) {
      MemoryManager.instance = new MemoryManager(config, cwd);
    }
    return MemoryManager.instance;
  }
}
```

#### 2. State Files (`.spec/state/`)

**Purpose**: Ephemeral session tracking (git-ignored)

| File | Content | Update Frequency |
|------|---------|------------------|
| `current-session.md` | Active feature, phase, tasks, context | Every state change |
| `snapshots/*.md` | Point-in-time state copies | On phase completion |
| `history/*.json` | State change audit log | Every mutation |

**Schema**: YAML frontmatter + Markdown body
```yaml
---
feature: "001"
phase: "planning"
started: "2025-01-03T10:00:00Z"
last_updated: "2025-01-03T11:30:00Z"
schema_version: "3.3.0"
---
```

#### 3. Memory Files (`.spec/state/memory/`)

**Purpose**: Persistent workflow history (git-committed)

| File | Content | Update Frequency |
|------|---------|------------------|
| `WORKFLOW-PROGRESS.md` | Feature progress, metrics, status | Phase completion |
| `DECISIONS-LOG.md` | Architecture Decision Records (ADRs) | When ADRs created |
| `CHANGES-PLANNED.md` | Pending implementation tasks | Task generation |
| `CHANGES-COMPLETED.md` | Completed work audit trail | Task completion |

**Append-only**: All memory files append new entries, never overwrite history

#### 4. Hooks System

**New Hooks** (to be implemented):

| Hook | Event | Responsibility |
|------|-------|----------------|
| `update-memory.ts` | `PostToolUse` (Skill) | Generic memory file updates |
| `validate-state.ts` | `PreToolUse` (Validate) | Pre-validate state before changes |
| `track-transitions.ts` | `PostToolUse` (Skill) | Track phase transitions |
| `snapshot-state.ts` | Periodic (5min) | Auto-snapshot current state |

**Enhanced Hooks** (existing, to be updated):

| Hook | Change Required |
|------|-----------------|
| `session-init.ts` | Initialize MemoryManager singleton |
| `save-session.ts` | Use MemoryManager.saveSession() |
| `restore-session.ts` | Use MemoryManager.restoreSession() |

---

## Data Models

### Core Types

```typescript
// Session State (current-session.md)
interface SessionState {
  // YAML frontmatter
  feature: string | null;              // "001" or null
  phase: WorkflowPhase | null;         // "specification" | "planning" | ...
  started: string | null;              // ISO 8601 timestamp
  last_updated: string;                // ISO 8601 timestamp
  schema_version: string;              // "3.3.0"

  // Markdown body (structured)
  activeWork: {
    currentFeature: FeatureContext | null;
    currentTask: TaskContext | null;
  };
  workflowProgress: {
    completedPhases: PhaseStatus[];
    taskCompletion: string;
  };
  configState: ConfigState;
  sessionNotes: string;
  blockers: string[];
  nextSteps: string[];
}

// Workflow Phase
type WorkflowPhase =
  | "none"
  | "specification"
  | "planning"
  | "implementation"
  | "validation"
  | "complete";

// Feature Context
interface FeatureContext {
  id: string;                   // "001"
  name: string;                 // "memory-management-improvements"
  phase: WorkflowPhase;
  started: string;
  jiraKey?: string;
}

// Task Context
interface TaskContext {
  id: string;
  description: string;
  userStory: string;
  status: "pending" | "in_progress" | "complete";
  progress: string;             // "3/10 tasks"
}

// State Snapshot
interface StateSnapshot {
  id: string;                   // UUID
  timestamp: string;            // ISO 8601
  label?: string;               // "post-planning-phase"
  state: SessionState;
  files: {
    path: string;
    hash: string;               // SHA-256 of file content
  }[];
}

// Transaction
interface Transaction {
  id: string;                   // UUID
  timestamp: string;
  operation: "update_session" | "append_memory" | "snapshot";
  files: FileOperation[];
  status: "pending" | "committed" | "rolled_back";
  error?: string;
}

// File Operation
interface FileOperation {
  path: string;
  type: "create" | "update" | "append";
  content: string;
  backup?: string;              // Backup path for rollback
}

// Memory Entry (generic)
interface MemoryEntry {
  timestamp: string;
  type: "progress" | "decision" | "change_planned" | "change_completed";
  feature: string;
  data: unknown;
}

// Validation Result
interface ValidationResult {
  valid: boolean;
  errors: ValidationError[];
  warnings: ValidationWarning[];
}

interface ValidationError {
  field: string;
  message: string;
  severity: "critical" | "error";
}

interface ValidationWarning {
  field: string;
  message: string;
  suggestion?: string;
}
```

---

## API Contracts

### MemoryManager Public API

```typescript
class MemoryManager {
  // Singleton Access
  static getInstance(config: SpecConfig, cwd: string): MemoryManager;

  // Session Management
  getCurrentSession(): SessionState | null;
  updateSession(updates: Partial<SessionState>): Promise<void>;
  saveSession(): Promise<void>;
  restoreSession(): Promise<SessionState | null>;

  // Phase Transitions
  transitionPhase(
    from: WorkflowPhase,
    to: WorkflowPhase,
    metadata?: Record<string, unknown>
  ): Promise<void>;

  recordPhaseCompletion(
    phase: WorkflowPhase,
    stats: PhaseStats
  ): Promise<void>;

  // Memory File Operations (Append-only)
  appendWorkflowProgress(entry: ProgressEntry): Promise<void>;
  appendDecisionLog(adr: DecisionRecord): Promise<void>;
  appendPlannedChange(change: PlannedChange): Promise<void>;
  markChangeCompleted(changeId: string, completion: ChangeCompletion): Promise<void>;

  // State Snapshots
  createSnapshot(label?: string): Promise<string>;  // Returns snapshot ID
  listSnapshots(): Promise<StateSnapshot[]>;
  restoreSnapshot(snapshotId: string): Promise<void>;
  deleteOldSnapshots(retentionDays: number): Promise<number>;  // Returns count deleted

  // Validation & Recovery
  validateState(): Promise<ValidationResult>;
  detectInconsistencies(): Promise<Inconsistency[]>;
  repairState(autoFix?: boolean): Promise<RepairReport>;

  // Transactions (Advanced)
  beginTransaction(): Transaction;
  commitTransaction(transaction: Transaction): Promise<void>;
  rollbackTransaction(transaction: Transaction): Promise<void>;
}
```

### Hook Integration API

```typescript
// Hooks call MemoryManager methods
// Example: update-memory.ts

import { MemoryManager } from '../../core/memory-manager';

async function handlePhaseTransition(context: HookContext) {
  const manager = MemoryManager.getInstance(config, cwd);

  await manager.transitionPhase(
    context.fromPhase,
    context.toPhase,
    {
      triggeredBy: context.command,
      timestamp: new Date().toISOString()
    }
  );
}
```

### Phase Guide Integration

```typescript
// Phase guides call MemoryManager via TypeScript utility

// Old way (DEPRECATED - do not use):
// Write .spec/state/current-session.md directly ❌

// New way (REQUIRED):
import { getMemoryManager } from '../core/memory-manager';

async function updatePhaseState(feature: string, phase: string) {
  const manager = getMemoryManager();
  await manager.updateSession({
    feature,
    phase: phase as WorkflowPhase
  });
}
```

**Note**: Phase guides are Markdown files executed by Claude. They'll call hooks via Bash commands that invoke MemoryManager:

```bash
# From phase guide:
node .claude/hooks/dist/utils/update-session.js --feature=001 --phase=planning
```

---

## Implementation Strategy

### Phase 1: Core MemoryManager (P1)

**Files to Create**:
1. `.claude/hooks/src/core/memory-manager.ts` - Main class
2. `.claude/hooks/src/types/memory.ts` - Type definitions
3. `.claude/hooks/src/types/transaction.ts` - Transaction types
4. `.claude/hooks/src/utils/file-transaction.ts` - Atomic file operations

**Key Features**:
- Singleton pattern with lazy initialization
- Session state caching
- Basic transaction support (begin/commit/rollback)
- YAML frontmatter parsing and serialization

**Dependencies**:
- Existing: `config-loader.ts`, `path-resolver.ts`, `logger.ts`
- New: `yaml-utils.ts` enhancements for frontmatter

**Testing**:
```typescript
// Unit tests
describe('MemoryManager', () => {
  it('should maintain singleton instance');
  it('should cache session state');
  it('should validate state before updates');
  it('should rollback on transaction failure');
});
```

### Phase 2: State Validation (P1)

**Files to Create**:
1. `.claude/hooks/src/core/state-validator.ts` - Schema validation
2. `.claude/hooks/src/schemas/session-state.schema.json` - JSON Schema
3. `.claude/hooks/src/core/state-recovery.ts` - Auto-repair logic

**Validation Rules**:
- YAML frontmatter has required fields
- Phase is valid enum value
- Feature ID matches existing feature directory
- Timestamps are valid ISO 8601
- No orphaned state (feature exists but no spec.md)

**Recovery Strategies**:
- Missing field → Use default value
- Invalid phase → Reset to "none"
- Corrupted YAML → Restore from last snapshot
- Missing feature → Clear feature context

### Phase 3: Hook Implementation (P1)

**Files to Create**:
1. `.claude/hooks/src/hooks/memory/update-memory.ts`
2. `.claude/hooks/src/hooks/memory/validate-state.ts`
3. `.claude/hooks/src/hooks/memory/track-transitions.ts`
4. `.claude/hooks/src/hooks/memory/snapshot-state.ts`

**Files to Modify**:
1. `.claude/hooks/src/hooks/session/session-init.ts` - Add MemoryManager init
2. `.claude/hooks/src/hooks/session/save-session.ts` - Use MemoryManager API
3. `.claude/hooks/src/hooks/session/restore-session.ts` - Use MemoryManager API

**Hook Registration** (in `.claude/settings.json`):
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": { "command": "spec:*" },
      "hooks": [{
        "type": "command",
        "command": "node \"$CLAUDE_PROJECT_DIR/.claude/hooks/dist/hooks/memory/update-memory.js\""
      }]
    }],
    "PreToolUse": [{
      "matcher": { "tool": "Write", "path": "**/.spec/**" },
      "hooks": [{
        "type": "command",
        "command": "node \"$CLAUDE_PROJECT_DIR/.claude/hooks/dist/hooks/memory/validate-state.js\""
      }]
    }]
  }
}
```

### Phase 4: Snapshot System (P2)

**Files to Create**:
1. `.claude/hooks/src/core/snapshot-manager.ts`
2. `.claude/hooks/src/utils/hash-utils.ts` - SHA-256 hashing

**Snapshot Storage**:
```
.spec/state/snapshots/
├── 2025-01-03-10-00-spec-complete.md
├── 2025-01-03-11-30-plan-complete.md
└── 2025-01-03-14-45-tasks-complete.md
```

**Snapshot Format** (Markdown with frontmatter):
```yaml
---
snapshot_id: "550e8400-e29b-41d4-a716-446655440000"
timestamp: "2025-01-03T11:30:00Z"
label: "plan-complete"
schema_version: "3.3.0"
---

# State Snapshot: plan-complete

**Created**: 2025-01-03 11:30:00 UTC

## Session State
[Full current-session.md content at time of snapshot]

## File Hashes
- spec.md: abc123...
- plan.md: def456...

## Restore Command
```bash
node .claude/hooks/dist/utils/restore-snapshot.js --id=550e8400...
```
```

**Retention Policy**:
- Keep last 10 snapshots always
- Keep 1 snapshot per day for 30 days
- Delete snapshots older than 30 days
- Run cleanup on SessionStart

### Phase 5: Migration Logic (P1)

**Files to Create**:
1. `.claude/hooks/src/utils/migrate-session.ts`
2. `.claude/hooks/src/migrations/v3.2-to-v3.3.ts`

**Migration Steps**:
1. Detect `.spec/.session.json` exists
2. Parse legacy JSON format
3. Convert to `current-session.md` format
4. Backup original as `.session.json.backup`
5. Log migration success
6. Add 30-day expiry to backup

**Legacy Format** (`.session.json`):
```json
{
  "feature": "001",
  "phase": "planning",
  "started": "2025-01-03T10:00:00Z",
  "context": {
    "featureName": "memory-management-improvements"
  }
}
```

**New Format** (`current-session.md`):
```yaml
---
feature: "001"
phase: "planning"
started: "2025-01-03T10:00:00Z"
last_updated: "2025-01-03T11:30:00Z"
schema_version: "3.3.0"
---

# Current Session State
[Structured Markdown content]
```

### Phase 6: Phase Guide Updates (P1)

**Files to Modify**:
All phase guides must stop writing state files directly.

**Pattern**:
```markdown
<!-- OLD WAY (Remove) -->
Write {config.paths.state}/current-session.md with updated phase

<!-- NEW WAY (Use) -->
Bash: node .claude/hooks/dist/utils/update-session.js --phase=planning
```

**Affected Files** (12 guides):
1. `phases/1-initialize/init/guide.md`
2. `phases/1-initialize/discover/guide.md`
3. `phases/1-initialize/blueprint/guide.md`
4. `phases/2-define/generate/guide.md`
5. `phases/2-define/clarify/guide.md`
6. `phases/2-define/checklist/guide.md`
7. `phases/3-design/plan/guide.md`
8. `phases/3-design/analyze/guide.md`
9. `phases/4-build/tasks/guide.md`
10. `phases/4-build/implement/guide.md`
11. `phases/5-track/update/guide.md`
12. `phases/5-track/metrics/guide.md`

---

## Security Considerations

### State File Access Control

**Risk**: Malicious code could corrupt state files
**Mitigation**:
- Hooks validate all writes before persistence
- Schema validation catches malformed data
- Snapshots enable rollback from corruption
- File permissions: 0600 (user read/write only)

### Sensitive Data in State

**Risk**: API keys, passwords in session notes
**Mitigation**:
- Warn users about sensitive data in git-committed files
- Add `.gitignore` patterns for sensitive state
- Consider encryption for future versions (out of scope)

### Hook Execution Safety

**Risk**: Malicious hooks could modify state
**Mitigation**:
- Hooks run in sandboxed Node.js process
- No shell command execution from hooks
- Strict TypeScript types prevent injection
- All file paths validated via config

---

## Testing Strategy

### Unit Tests

**Framework**: Jest
**Coverage Target**: 90%

**Test Suites**:
1. `memory-manager.test.ts` - Core MemoryManager methods
2. `state-validator.test.ts` - Schema validation
3. `file-transaction.test.ts` - Atomic file operations
4. `snapshot-manager.test.ts` - Snapshot create/restore
5. `migrate-session.test.ts` - Legacy migration

**Example Test**:
```typescript
describe('MemoryManager.transitionPhase', () => {
  it('should update session state atomically', async () => {
    const manager = MemoryManager.getInstance(config, cwd);
    await manager.transitionPhase('specification', 'planning');

    const session = manager.getCurrentSession();
    expect(session?.phase).toBe('planning');
  });

  it('should rollback on validation failure', async () => {
    const manager = MemoryManager.getInstance(config, cwd);

    await expect(
      manager.transitionPhase('invalid', 'planning')
    ).rejects.toThrow();

    // State should be unchanged
    const session = manager.getCurrentSession();
    expect(session?.phase).toBe('specification');
  });
});
```

### Integration Tests

**Scenarios**:
1. Full workflow: init → generate → plan → tasks → implement
2. Session interruption and resume
3. State corruption and recovery
4. Snapshot create and restore
5. Migration from legacy format

**Test Harness**:
```bash
# Run integration tests
npm run test:integration

# Simulates:
# 1. Initialize spec
# 2. Create feature
# 3. Interrupt (kill process)
# 4. Resume session
# 5. Verify state restored
```

### Hook Tests

**Test Individual Hooks**:
```bash
# Simulate hook execution
echo '{"feature": "001", "phase": "planning"}' | \
  node .claude/hooks/dist/hooks/memory/update-memory.js
```

**Verify Outputs**:
- JSON output to stdout
- Structured logs to stderr
- Exit code 0 on success
- State files updated correctly

---

## Performance Targets

### Latency Budgets

| Operation | Target | Max Acceptable |
|-----------|--------|----------------|
| Session read (cached) | < 5ms | 10ms |
| Session read (cold) | < 50ms | 100ms |
| Session update | < 50ms | 150ms |
| Snapshot create | < 200ms | 500ms |
| Validate state | < 100ms | 300ms |
| Migrate legacy | < 1s | 3s |

### Memory Footprint

- MemoryManager singleton: < 2MB
- Session cache: < 500KB
- Total hooks runtime: < 5MB

### Disk Usage

- State files: < 1MB total
- Snapshots (30 days): < 10MB
- History logs: < 5MB/month

---

## Rollout Plan

### Step 1: Development & Testing (Days 1-2)
- Implement MemoryManager core
- Add state validation
- Create new hooks
- Write unit tests
- Test in isolation

### Step 2: Hook Integration (Day 2)
- Update existing hooks
- Register new hooks in settings.json
- Test hook execution
- Verify state updates

### Step 3: Phase Guide Migration (Day 3)
- Update all 12 phase guides
- Remove direct state writes
- Add MemoryManager calls
- Test each phase individually

### Step 4: Migration Testing (Day 3)
- Test legacy `.session.json` migration
- Verify backward compatibility
- Test snapshot restore
- Validate error recovery

### Step 5: Documentation (Day 3)
- Update README.md
- Update CLAUDE.md
- Create migration guide
- Document breaking changes

### Step 6: Release (Day 3)
- Tag version v3.4.0
- Publish release notes
- Notify users of migration

---

## Dependencies & Constraints

### Required Before Implementation

✅ **Completed**:
- TypeScript hooks system (v3.3.0)
- Config-driven paths
- State file templates
- BaseHook infrastructure

❌ **Blockers**:
- None! Ready to implement

### External Dependencies

- **Node.js** >= 18.0.0 (already required)
- **TypeScript** >= 5.0 (already in use)
- **Jest** (testing framework - new)
- **Ajv** (JSON Schema validation - new)

### Breaking Changes

1. **Phase guides cannot write state directly**
   - Migration: Update all guides to use MemoryManager

2. **`.session.json` deprecated**
   - Migration: Auto-migrate on first run

3. **Hook signatures changed**
   - Migration: Update settings.json with new hooks

---

## Architecture Decision Records (ADRs)

### ADR-001: Singleton Pattern for MemoryManager

**Status**: Accepted
**Date**: 2025-01-03

**Context**:
Need single source of truth for session state. Multiple MemoryManager instances would cause cache inconsistencies.

**Decision**:
Implement MemoryManager as singleton with `getInstance()` factory method.

**Rationale**:
- Ensures single in-memory cache
- Simplifies hook coordination
- Prevents race conditions
- Standard pattern for state managers

**Consequences**:
✅ Cache coherency guaranteed
✅ Simplified testing (reset singleton between tests)
❌ Harder to parallelize (not a concern for single-user CLI)
❌ Global state (acceptable for CLI tool)

**Alternatives Considered**:
- Dependency injection (overly complex for use case)
- Multiple instances with locking (unnecessary)

---

### ADR-002: File-Based Persistence Over Database

**Status**: Accepted
**Date**: 2025-01-03

**Context**:
Need to persist state across sessions. Could use SQLite, JSON files, or Markdown files.

**Decision**:
Use Markdown files with YAML frontmatter for state persistence.

**Rationale**:
- Human-readable and editable
- Git-friendly (merge conflicts resolvable)
- No external dependencies
- Consistent with existing Spec files
- Easy debugging (cat file)

**Consequences**:
✅ No database setup required
✅ Easy to inspect and debug
✅ Version control friendly
❌ Slower than binary database (acceptable - not performance critical)
❌ No ACID guarantees (mitigated by atomic writes)

**Alternatives Considered**:
- SQLite (overkill, adds dependency)
- JSON files (not human-friendly)
- Binary formats (not inspectable)

---

### ADR-003: Hooks as Enforcement Layer

**Status**: Accepted
**Date**: 2025-01-03

**Context**:
Need to prevent phase guides from bypassing MemoryManager and writing state directly.

**Decision**:
Use PreToolUse hooks to intercept and block direct writes to `.spec/state/` files.

**Rationale**:
- Enforces architecture at runtime
- Fails fast if guides violate contract
- Visible errors guide developers to correct API
- No way to accidentally bypass system

**Consequences**:
✅ Architecture is enforced, not just documented
✅ Clear error messages when violated
✅ Prevents state drift from manual writes
❌ Adds hook execution overhead (minimal ~50ms)

**Alternatives Considered**:
- Documentation only (not enforced)
- File permissions (breaks legitimate updates)
- Code reviews (human error prone)

---

### ADR-004: 30-Day Snapshot Retention

**Status**: Accepted
**Date**: 2025-01-03

**Context**:
Need to balance state history with disk usage. Snapshots can accumulate quickly.

**Decision**:
Retain snapshots for 30 days, keep last 10 always, 1 per day for older snapshots.

**Rationale**:
- 30 days covers most recovery scenarios
- Last 10 snapshots enable granular rollback
- 1 per day reduces storage for older history
- Configurable via config for power users

**Consequences**:
✅ Bounded disk usage (~10MB typical)
✅ Fast rollback for recent changes
✅ Long-term recovery still possible
❌ Very old snapshots not available (acceptable)

**Alternatives Considered**:
- Keep all snapshots (unbounded growth)
- 7-day retention (too short for long projects)
- Compression (adds complexity)

---

## Open Questions

### Resolved During Planning:

✅ **Snapshot Retention Policy**
→ Decision: 30 days, configurable (see ADR-004)

✅ **Hook Failure Handling**
→ Decision: Retry 3 times, then degrade gracefully with logging

✅ **State Schema Versioning**
→ Decision: Include `schema_version` in frontmatter, auto-migrate on mismatch

✅ **Memory Manager Initialization**
→ Decision: SessionStart hook initializes singleton (lazy initialization)

### Remaining Questions:

None! All clarifications resolved during planning.

---

## Success Metrics

### Development Metrics
- ✅ Zero manual state file edits in phase guides
- ✅ 100% hook coverage for state transitions
- ✅ < 5 state inconsistencies per 1000 operations
- ✅ 90%+ test coverage
- ✅ All TypeScript strict mode passing

### User Experience Metrics
- ✅ 95%+ session restoration accuracy
- ✅ < 1 second state load time
- ✅ Zero data loss incidents
- ✅ Clear error messages on state issues

### Code Quality Metrics
- ✅ All ESLint rules passing
- ✅ No critical bugs in 30 days post-launch
- ✅ All integration tests passing
- ✅ Documentation complete and accurate

---

## Next Steps

1. **Review this plan** - Ensure architecture aligns with goals
2. **Run tasks phase** - Break down into implementation tasks
3. **Begin implementation** - Start with Phase 1 (MemoryManager core)
4. **Iterate with testing** - TDD approach for reliability

**Command to continue**:
```bash
/workflow:spec → "🔨 Move to Build" → Generate tasks
```

---

*Technical Plan v1.0*
*Created by Spec Workflow System v3.3.0*
*Ready for implementation!*
