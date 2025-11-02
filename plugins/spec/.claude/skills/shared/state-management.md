# Shared: State Management System

Complete specification for Spec's state management architecture, file schemas, lifecycle, and recovery procedures.

## Overview

Spec maintains workflow state across two distinct systems:

1. **Session State** (`.spec-state/`) - Temporary session tracking (git-ignored)
2. **Persistent Memory** (`.spec-memory/`) - Long-term project history (git-committed)

This dual-layer approach enables:
- Resuming work after interruptions or crashes
- Tracking progress within and across Claude sessions
- Maintaining architectural decision history
- Recovery from failures using checkpoints
- Context preservation across conversations
- Token-efficient state loading (80% reduction in v3.0)

## Directory Structure

```
Project Root/
├── .spec-state/                 # Session state (gitignored)
│   ├── current-session.md         # Active session tracking
│   └── checkpoints/                # Session checkpoints
│       ├── 2025-10-31-14-30.md   # Timestamped checkpoints
│       └── ...
│
├── .spec-memory/                # Persistent memory (committed)
│   ├── WORKFLOW-PROGRESS.md       # Feature tracking
│   ├── DECISIONS-LOG.md           # Architecture decisions
│   ├── CHANGES-PLANNED.md         # Planned tasks
│   └── CHANGES-COMPLETED.md       # Completed work
│
└── features/                       # Feature artifacts (committed)
    └── ###-feature-name/
        ├── spec.md                # Requirements
        ├── plan.md                # Technical design
        └── tasks.md               # Task breakdown
```

## Session State Files

### current-session.md

**Purpose**: Track active feature and current work

**Structure**:
```markdown
# Current Spec Session

**Started**: 2025-10-31 14:30:00
**Last Updated**: 2025-10-31 15:45:00
**Active Feature**: 001-user-authentication

## Current Phase

**Phase**: implementation
**Status**: in_progress
**Progress**: 15/23 tasks complete (65%)

## Active Feature Details

**Feature ID**: 001
**Feature Name**: User Authentication System
**Priority**: P1 (Must Have)
**Started**: 2025-10-30
**Target**: 2025-11-05

### User Stories In Progress

- [ ] US1.1: User can register with email/password
- [x] US1.2: User can log in with credentials
- [x] US1.3: User can log out
- [ ] US1.4: User can reset forgotten password

## Current Tasks

### In Progress (3 tasks)

**T001**: Implement password reset email service
- Status: in_progress
- Started: 2025-10-31 14:30
- Assigned: spec:implement
- Dependencies: None
- Files: src/services/email-service.ts

**T002**: Add password validation rules
- Status: in_progress
- Started: 2025-10-31 15:00
- Assigned: spec:implement
- Dependencies: T001
- Files: src/utils/validators.ts

**T003**: Write unit tests for auth service
- Status: in_progress
- Started: 2025-10-31 15:30
- Assigned: spec:implement
- Dependencies: T001, T002
- Files: tests/services/auth.test.ts

### Queued (5 tasks)

- T004: Implement OAuth integration [P]
- T005: Add rate limiting to login endpoint [P]
- T006: Create user profile page
- T007: Add remember me functionality
- T008: Write integration tests

## Session Context

**Working Directory**: /Users/dev/project-name
**Git Branch**: feat/user-auth
**Last Checkpoint**: 2025-10-31-15-00
**MCP Integrations**: jira (enabled), confluence (enabled)

## Quick Stats

- Features: 1 active, 0 completed
- User Stories: 2/4 complete (50%)
- Tasks: 15/23 complete (65%)
- Files Modified: 12 files
- Lines Added: +1,247
- Lines Deleted: -83

## Next Actions

1. Complete T001 (password reset email)
2. Complete T002 (password validation)
3. Complete T003 (unit tests)
4. Run test suite
5. Move to next queued task
```

**Update Frequency**: After every command/phase change

**Updated By**: spec:generate, spec:plan, spec:tasks, spec:implement

### checkpoints/ Directory

**Purpose**: Save workflow state at key moments

**When to Create**:
- Before phase transitions (spec → plan → tasks → implement)
- After completing major milestones
- Before potentially destructive operations
- On user request (`/spec checkpoint save`)

**Naming**: `YYYY-MM-DD-HH-MM.md` (timestamp-based)

**Structure**: Same as current-session.md snapshot

## Persistent Memory Files

### WORKFLOW-PROGRESS.md

**Purpose**: Track all features across project lifetime

**Structure**:
```markdown
# Workflow Progress Tracker

**Project**: My SaaS Application
**Started**: 2025-10-15
**Last Updated**: 2025-10-31 15:45:00

## Summary

- Total Features: 5
- Completed: 2 (40%)
- In Progress: 1 (20%)
- Not Started: 2 (40%)

## Features

### ✅ Completed Features

#### Feature 000: Project Initialization
- **Status**: completed
- **Completed**: 2025-10-15
- **Duration**: 2 hours
- **Artifacts**:
  - .spec/product-requirements.md
  - .spec/architecture-blueprint.md
- **JIRA**: PROJ-100 (closed)
- **Notes**: Initial Spec setup for existing codebase

#### Feature 001: User Authentication System
- **Status**: completed
- **Completed**: 2025-10-25
- **Duration**: 5 days
- **Artifacts**:
  - features/001-user-auth/spec.md
  - features/001-user-auth/plan.md
  - features/001-user-auth/tasks.md
- **User Stories**: 4/4 (100%)
- **Tasks**: 23/23 (100%)
- **JIRA**: PROJ-101 (closed)
- **Confluence**: https://company.atlassian.net/wiki/pages/123456
- **PR**: #42 (merged)
- **Notes**: OAuth integration deferred to v2.0

### 🚧 In Progress Features

#### Feature 002: Product Search
- **Status**: in_progress
- **Started**: 2025-10-30
- **Progress**: 65%
- **Artifacts**:
  - features/002-search/spec.md ✅
  - features/002-search/plan.md ✅
  - features/002-search/tasks.md ✅
- **User Stories**: 2/4 (50%)
- **Tasks**: 15/23 (65%)
- **JIRA**: PROJ-102 (in progress)
- **Target**: 2025-11-05
- **Notes**: Elasticsearch integration complex

### 📋 Planned Features

#### Feature 003: Payment Processing
- **Status**: not_started
- **Priority**: P1
- **Artifacts**:
  - features/003-payments/spec.md ✅
- **Target**: 2025-11-10
- **Notes**: Waiting for stripe account setup

#### Feature 004: Notification System
- **Status**: not_started
- **Priority**: P2
- **Artifacts**: None yet
- **Target**: TBD
- **Notes**: Depends on Feature 002 completion

## Metrics

### Velocity
- Average Feature Duration: 4.2 days
- Average Tasks per Feature: 23
- Average Story Points per Feature: 13

### Quality
- Test Coverage: 87%
- Bugs Found: 12
- Bugs Fixed: 10
- Tech Debt Items: 5

### Efficiency
- Spec Time: 15% of feature time
- Planning Time: 20% of feature time
- Implementation Time: 65% of feature time

## Historical Trends

- Sprint 1: 2 features completed
- Sprint 2: 1 feature completed (current)
- Projected Sprint 3: 2 features

---

**Last Updated**: 2025-10-31 15:45:00
**Updated By**: spec:implement
```

**Update Frequency**: After phase completions, feature milestones

**Updated By**: All spec:* skills

### DECISIONS-LOG.md

**Purpose**: Record architecture and technical decisions (ADRs)

**Structure**:
```markdown
# Architecture Decisions Log

## ADR-001: Use JWT for Authentication

**Date**: 2025-10-20
**Status**: Accepted
**Context**: Feature 001 - User Authentication
**Deciders**: Engineering team

### Decision
We will use JSON Web Tokens (JWT) for authentication instead of session-based auth.

### Rationale
- Stateless: No server-side session storage needed
- Scalable: Works across multiple servers
- Mobile-friendly: Easy to use in mobile apps
- Industry standard: Well-understood and supported

### Consequences
**Positive**:
- Horizontal scaling simplified
- No session storage infrastructure needed
- Better mobile app support

**Negative**:
- Token revocation more complex
- Larger payload than session cookies
- Must manage token refresh carefully

**Alternatives Considered**:
- Session-based auth (rejected - scaling issues)
- OAuth only (rejected - want first-party auth)

---

## ADR-002: Choose PostgreSQL for Database

**Date**: 2025-10-21
**Status**: Accepted
**Context**: Feature 001 - Data Storage
**Deciders**: Engineering team + DBA

### Decision
Use PostgreSQL 14+ as primary database.

### Rationale
- ACID compliance for financial data
- JSON support for flexible schemas
- Excellent performance at our scale
- Team expertise

### Consequences
**Positive**:
- Data integrity guaranteed
- Rich query capabilities
- Strong ecosystem

**Negative**:
- More complex than NoSQL for some cases
- Vertical scaling limits

---

## ADR-003: Elasticsearch for Product Search

**Date**: 2025-10-30
**Status**: Accepted
**Context**: Feature 002 - Search Functionality
**Deciders**: Engineering team

### Decision
Implement product search using Elasticsearch.

### Rationale
- Full-text search with relevance
- Faceted search out of box
- Autocomplete support
- Scales horizontally

### Consequences
**Positive**:
- Rich search features
- Fast query performance
- Flexible schema

**Negative**:
- Additional infrastructure
- Data synchronization complexity
- Learning curve

---

**Total Decisions**: 3
**Active**: 3
**Superseded**: 0
**Last Updated**: 2025-10-30
```

**Update Frequency**: When architecture decisions made

**Updated By**: spec:plan (primarily)

### CHANGES-PLANNED.md

**Purpose**: Track all planned changes/tasks

**Structure**:
```markdown
# Changes Planned

**Last Updated**: 2025-10-31 15:45:00

## Feature 002: Product Search (In Progress)

### Pending Tasks (8 tasks)

**T004**: Implement Elasticsearch integration [P]
- Priority: P1
- Estimate: 4 hours
- Dependencies: None
- Files: src/services/search-service.ts
- Notes: Can run in parallel with T005

**T005**: Add search API endpoint [P]
- Priority: P1
- Estimate: 2 hours
- Dependencies: T004
- Files: src/api/routes/search.ts
- Notes: Can run in parallel with T004

**T006**: Create search UI component
- Priority: P1
- Estimate: 3 hours
- Dependencies: T005
- Files: src/components/SearchBar.tsx

**T007**: Add search result pagination
- Priority: P2
- Estimate: 2 hours
- Dependencies: T006
- Files: src/components/SearchResults.tsx

**T008**: Implement faceted search filters
- Priority: P2
- Estimate: 4 hours
- Dependencies: T004
- Files: src/services/search-service.ts, src/components/SearchFilters.tsx

**T009**: Add search autocomplete
- Priority: P2
- Estimate: 3 hours
- Dependencies: T004, T006
- Files: src/components/SearchBar.tsx

**T010**: Write search service tests
- Priority: P1
- Estimate: 2 hours
- Dependencies: T004, T005
- Files: tests/services/search.test.ts

**T011**: Add search analytics tracking
- Priority: P3
- Estimate: 2 hours
- Dependencies: T006
- Files: src/analytics/search-events.ts

### Parallel Work Opportunities

**Group 1** (can run in parallel):
- T004: Elasticsearch integration
- T005: API endpoint
- T010: Tests (stub-based)

**Group 2** (after Group 1):
- T006: UI component
- T008: Faceted filters

**Group 3** (after Group 2):
- T007: Pagination
- T009: Autocomplete
- T011: Analytics

## Feature 003: Payment Processing (Not Started)

### All Tasks (15 tasks)

[Complete task list for future feature...]

---

**Total Planned**: 23 tasks
**P1**: 12 tasks
**P2**: 8 tasks
**P3**: 3 tasks
```

**Update Frequency**: When tasks created/modified

**Updated By**: spec:tasks, spec:update

### CHANGES-COMPLETED.md

**Purpose**: Historical record of completed work

**Structure**:
```markdown
# Changes Completed

**Last Updated**: 2025-10-31 15:45:00

## Feature 002: Product Search (In Progress - 15/23 complete)

### Recently Completed (Last 7 Days)

**T001**: Set up Elasticsearch cluster ✅
- Completed: 2025-10-30 16:30
- Duration: 3 hours
- PR: #45
- Files Modified: docker-compose.yml, src/config/elasticsearch.ts
- Notes: Using ES 8.x with Docker Compose

**T002**: Create product index mapping ✅
- Completed: 2025-10-30 18:00
- Duration: 2 hours
- PR: #45
- Files Modified: src/config/es-mappings.ts
- Notes: Optimized for text search

**T003**: Implement bulk indexing script ✅
- Completed: 2025-10-31 10:00
- Duration: 4 hours
- PR: #46
- Files Modified: scripts/index-products.ts
- Notes: Processes 1000 products in 2.3 seconds

[... more completed tasks ...]

### Week Summary (2025-10-24 to 2025-10-31)
- Tasks Completed: 15
- Total Duration: 47 hours
- PRs Merged: 4
- Files Modified: 28
- Lines Added: +2,145
- Lines Deleted: -127

## Feature 001: User Authentication (Completed)

### All Completed Tasks (23 tasks)

[Complete history of Feature 001...]

---

**Total Completed**: 38 tasks across 2 features
**Total Time**: 142 hours
```

**Update Frequency**: As tasks complete

**Updated By**: spec:implement (primarily)

## Access Patterns

### Reading State

**From skills**:
```markdown
1. Load current session:
   - Use Read tool: .spec-state/current-session.md
   - Parse: current feature, phase, progress

2. Load workflow progress:
   - Use Read tool: .spec-memory/WORKFLOW-PROGRESS.md
   - Parse: feature list, status, metrics

3. Load decisions (if planning):
   - Use Read tool: .spec-memory/DECISIONS-LOG.md
   - Parse: existing ADRs

4. Load tasks (if implementing):
   - Use Read tool: .spec-memory/CHANGES-PLANNED.md
   - Parse: pending tasks, priorities
```

### Writing State

**From skills**:
```markdown
1. Update current session:
   - Read current content first
   - Modify relevant sections
   - Write back with Edit tool
   - Update "Last Updated" timestamp

2. Append to logs:
   - Use Edit tool to append new entries
   - Maintain chronological order
   - Add separator lines

3. Move completed tasks:
   - Read from CHANGES-PLANNED.md
   - Write to CHANGES-COMPLETED.md
   - Remove from CHANGES-PLANNED.md
```

## State Initialization

**On spec:init**:
```
1. Create .spec-state/ directory
2. Create .spec-state/checkpoints/ directory
3. Create current-session.md from template
4. Create .spec-memory/ directory
5. Create WORKFLOW-PROGRESS.md with header
6. Create DECISIONS-LOG.md with header
7. Create CHANGES-PLANNED.md with header
8. Create CHANGES-COMPLETED.md with header
9. Add .spec-state/ to .gitignore
10. Commit .spec-memory/ files
```

## Usage in Skills

**Common references**:

```markdown
For state file specifications and access patterns, see: `shared/state-management.md`
```

**When to load**:
- Every skill reads current-session.md to understand context
- Planning skills read/write DECISIONS-LOG.md
- Task skills read/write CHANGES-PLANNED.md
- Implementation skills read CHANGES-PLANNED.md, write CHANGES-COMPLETED.md

## State Transitions Between Phases

### Function → State I/O Table

| Function | Reads | Writes | Appends | Updates |
|----------|-------|--------|---------|---------|
| spec:init | - | current-session.md<br>All memory files | - | .gitignore |
| spec:generate | current-session.md<br>WORKFLOW-PROGRESS.md | spec.md | - | current-session.md<br>WORKFLOW-PROGRESS.md |
| spec:clarify | current-session.md<br>spec.md | - | - | spec.md<br>current-session.md |
| spec:plan | current-session.md<br>spec.md<br>DECISIONS-LOG.md | plan.md<br>checkpoint/*.md | DECISIONS-LOG.md | current-session.md<br>WORKFLOW-PROGRESS.md |
| spec:tasks | current-session.md<br>spec.md<br>plan.md | tasks.md<br>checkpoint/*.md | CHANGES-PLANNED.md | current-session.md<br>WORKFLOW-PROGRESS.md |
| spec:implement | current-session.md<br>tasks.md<br>CHANGES-PLANNED.md | checkpoint/*.md<br>implementation.log | CHANGES-COMPLETED.md | current-session.md<br>CHANGES-PLANNED.md<br>WORKFLOW-PROGRESS.md |
| spec:update | current-session.md<br>spec.md<br>plan.md<br>tasks.md | - | DECISIONS-LOG.md | All artifacts<br>All state files |
| spec:metrics | WORKFLOW-PROGRESS.md<br>current-session.md<br>CHANGES-COMPLETED.md | - | - | - |

### Phase Transition Flow

```
spec:init
  ├─ Create: .spec-state/ directory
  ├─ Create: .spec-state/checkpoints/ directory
  ├─ Write: current-session.md (empty template)
  ├─ Create: .spec-memory/ directory
  ├─ Write: WORKFLOW-PROGRESS.md (project header)
  ├─ Write: DECISIONS-LOG.md (empty)
  ├─ Write: CHANGES-PLANNED.md (empty)
  ├─ Write: CHANGES-COMPLETED.md (empty)
  └─ Update: .gitignore (add .spec-state/)

spec:generate "Feature"
  ├─ Read: current-session.md (check for existing feature)
  ├─ Read: WORKFLOW-PROGRESS.md (get next feature ID)
  ├─ Write: features/###-name/spec.md
  ├─ Update: current-session.md (set feature, phase="specification")
  └─ Update: WORKFLOW-PROGRESS.md (add feature entry)

spec:plan
  ├─ Read: current-session.md (active feature)
  ├─ Read: spec.md (requirements)
  ├─ Read: DECISIONS-LOG.md (existing ADRs)
  ├─ Write: plan.md (technical design)
  ├─ Append: DECISIONS-LOG.md (new ADRs)
  ├─ Update: current-session.md (phase="planning")
  ├─ Update: WORKFLOW-PROGRESS.md (mark plan complete)
  └─ Write: checkpoints/YYYY-MM-DD-HH-MM.md

spec:tasks
  ├─ Read: current-session.md, spec.md, plan.md
  ├─ Write: tasks.md (task breakdown)
  ├─ Append: CHANGES-PLANNED.md (add all tasks)
  ├─ Update: current-session.md (phase="implementation", task list)
  ├─ Update: WORKFLOW-PROGRESS.md (mark tasks complete)
  └─ Write: checkpoints/YYYY-MM-DD-HH-MM.md

spec:implement
  ├─ Read: current-session.md, tasks.md, CHANGES-PLANNED.md
  ├─ Update: current-session.md (task progress, real-time)
  ├─ Update: CHANGES-PLANNED.md (mark in-progress)
  ├─ Append: CHANGES-COMPLETED.md (as tasks finish)
  ├─ Update: WORKFLOW-PROGRESS.md (metrics)
  ├─ Write: checkpoints/* (every 30 min)
  └─ Write: implementation.log (execution details)
```

### When State Files Are Created/Updated/Deleted

| Event | Creates | Updates | Deletes |
|-------|---------|---------|---------|
| Project init | All state files | - | - |
| New feature | spec.md | current-session.md<br>WORKFLOW-PROGRESS.md | - |
| Phase change | checkpoint/*.md | current-session.md | - |
| Task complete | - | CHANGES-PLANNED.md<br>CHANGES-COMPLETED.md<br>current-session.md | - |
| Feature complete | - | WORKFLOW-PROGRESS.md | - |
| Requirements update | - | spec.md<br>plan.md<br>tasks.md<br>DECISIONS-LOG.md | - |
| Session end | - | - | current-session.md (optional) |
| Manual reset | - | - | .spec-state/* (keep memory/) |

## Best Practices

### For Skill Developers

1. **Read State Once Per Session**
   ```markdown
   # At skill start:
   1. Read .spec-state/current-session.md
   2. Cache in memory for session
   3. Don't re-read unless explicitly invalidated
   ```

2. **Update State Atomically**
   ```bash
   # Write to temp file first
   cat > .spec-state/current-session.tmp.md << 'EOF'
   [updated content]
   EOF

   # Atomic move (prevents corruption)
   mv .spec-state/current-session.tmp.md .spec-state/current-session.md
   ```

3. **Create Checkpoints Before Risky Operations**
   ```bash
   # Before --force, --update, or destructive operations
   cp .spec-state/current-session.md \
      .spec-state/checkpoints/$(date +%Y-%m-%d-%H-%M).md
   ```

4. **Append to Logs, Don't Overwrite**
   ```markdown
   # DECISIONS-LOG.md and CHANGES-COMPLETED.md grow over time
   # Always append, never replace entire file

   cat >> .spec-memory/DECISIONS-LOG.md << 'EOF'

   ## ADR-XXX: New Decision
   ...
   EOF
   ```

5. **Validate State Format**
   ```bash
   # Check required sections exist before using
   grep -q "## Active Work" .spec-state/current-session.md
   grep -q "## Current Phase" .spec-state/current-session.md
   ```

### For Users

1. **Don't Manually Edit State Files**
   - State files are managed by workflow
   - Manual edits can corrupt parsing
   - Use workflow commands (spec:update) instead

2. **Commit Memory, Ignore Session**
   ```bash
   # .gitignore should contain:
   .spec-state/

   # .spec-memory/ should be committed:
   git add .spec-memory/
   git commit -m "feat: Update workflow progress"
   ```

3. **Backup Before Major Changes**
   ```bash
   # Before major refactoring or updates:
   cp -r .spec-memory .spec-memory.backup-$(date +%Y%m%d)
   ```

4. **Review Progress Regularly**
   ```bash
   # Check project health:
   /spec metrics

   # Or read directly:
   cat .spec-memory/WORKFLOW-PROGRESS.md
   ```

## Troubleshooting

### Problem: Corrupted Session State

**Symptoms**:
- current-session.md missing or malformed
- "Session not found" errors
- Workflow doesn't recognize current feature

**Solution A: Restore from Checkpoint**
```bash
# 1. List available checkpoints
ls -lt .spec-state/checkpoints/

# 2. View checkpoint content
cat .spec-state/checkpoints/2025-11-01-15-25.md

# 3. Restore most recent
cp .spec-state/checkpoints/2025-11-01-15-25.md \
   .spec-state/current-session.md

# 4. Verify restoration
/spec status
```

**Solution B: Reconstruct from Artifacts**
```bash
# 1. Find feature artifacts
ls features/*/

# 2. Determine phase from files
# - spec.md only → completed spec:generate
# - + plan.md → completed spec:plan
# - + tasks.md → completed spec:tasks

# 3. Manually create current-session.md
# Use template from .spec-state/ in plugin
# Fill in feature ID, name, and phase
```

### Problem: Missing Checkpoint Files

**Symptoms**:
- checkpoints/ directory empty
- Can't restore previous state
- Lost work after crash

**Solution: Enable Auto-Checkpoints**
```bash
# Check if checkpoints disabled
grep "SPEC_AUTO_CHECKPOINT" CLAUDE.md

# Enable auto-checkpoints (default: true)
echo "SPEC_AUTO_CHECKPOINT=true" >> CLAUDE.md

# Manually create checkpoint now
cp .spec-state/current-session.md \
   .spec-state/checkpoints/manual-$(date +%Y-%m-%d-%H-%M).md
```

### Problem: WORKFLOW-PROGRESS.md Out of Sync

**Symptoms**:
- Feature shows wrong status
- Metrics don't match reality
- Missing feature entries

**Solution: Manual Reconciliation**
```bash
# 1. Check actual status
ls features/*/tasks.md | xargs grep -c "\[x\]"

# 2. Edit WORKFLOW-PROGRESS.md
# Update feature status to match reality

# 3. Document the fix
cat >> .spec-memory/DECISIONS-LOG.md << 'EOF'

## ADR-XXX: Manual State Reconciliation

**Date**: $(date +%Y-%m-%d)
**Status**: Accepted
**Context**: WORKFLOW-PROGRESS out of sync after [reason]

**Decision**: Manually updated Feature XXX status.

**Consequences**: State now accurate.
EOF
```

### Problem: State Files Too Large

**Symptoms**:
- WORKFLOW-PROGRESS.md > 3,000 tokens
- CHANGES-COMPLETED.md > 2,000 tokens
- Slow state loading

**Solution: Archive Old Data**
```bash
# 1. Archive completed features
grep -A 50 "Status: completed" .spec-memory/WORKFLOW-PROGRESS.md \
  > .spec-memory/archive/WORKFLOW-PROGRESS-2025-Q1.md

# 2. Keep only active + 2 recent completed in main file

# 3. Add archive reference
echo "\n**Archived**: See archive/WORKFLOW-PROGRESS-2025-Q1.md" \
  >> .spec-memory/WORKFLOW-PROGRESS.md
```

### Problem: Version Migration Needed

**Symptoms**:
- Upgrading from Spec v2.x to v3.0
- Old state format (.spec/state.json)
- Missing new state files

**Solution: Run Migration Script**
```bash
# 1. Backup existing state
cp -r .spec .spec.backup.v2

# 2. Run migration (if available)
# or manually convert:

# Convert state.json to current-session.md
if [ -f .spec/state.json ]; then
  # Extract feature, phase, tasks
  # Write to .spec-state/current-session.md format
fi

# Create missing memory files
[ ! -f .spec-memory/CHANGES-PLANNED.md ] && \
  echo "# Changes Planned" > .spec-memory/CHANGES-PLANNED.md

[ ! -f .spec-memory/CHANGES-COMPLETED.md ] && \
  echo "# Changes Completed" > .spec-memory/CHANGES-COMPLETED.md

# 3. Verify migration
/spec status
```

## Token Efficiency

### v3.0 Optimization

**State Loading Costs**:
- **v2.x**: 10,000 tokens per workflow invocation
- **v3.0**: 2,000 tokens per workflow invocation (80% reduction)

**How v3.0 Achieves This**:
1. **Hub-level caching**: State read once at /spec hub, cached for session
2. **Progressive disclosure**: Skills don't re-read state
3. **Minimal schemas**: current-session.md is ~400 tokens (vs 2,000 in v2.x)
4. **Lazy loading**: Memory files only loaded when needed by specific skills

**Best Practices for Token Efficiency**:
```markdown
# In skill SKILL.md:
"State loaded by hub - don't re-read current-session.md"

# Skills receive state as context, not via Read tool
# Only read memory files if skill specifically needs them:
- spec:plan → reads DECISIONS-LOG.md
- spec:tasks → reads CHANGES-PLANNED.md
- spec:implement → reads CHANGES-PLANNED.md
- spec:metrics → reads WORKFLOW-PROGRESS.md + CHANGES-COMPLETED.md
```

## Related Files

- `shared/workflow-patterns.md` - Common workflow patterns using state
- `shared/integration-patterns.md` - MCP integration state tracking
- `ERROR-RECOVERY.md` - Complete error recovery procedures
- Individual skill REFERENCEs for skill-specific state usage

---

**Last Updated**: 2025-11-02
**Used By**: All spec:* skills
**Token Size**: ~2,800 tokens
**Completeness**: ⭐⭐⭐⭐⭐ (comprehensive)
