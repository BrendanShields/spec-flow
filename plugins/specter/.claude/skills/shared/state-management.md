# Shared: State Management Specification

This file defines the state management system used by all Spec skills for session tracking and workflow progress.

## Overview

Spec maintains two types of state:
1. **Session State** (`.specter-state/`) - Current session, git-ignored, temporary
2. **Persistent Memory** (`.specter-memory/`) - Project history, git-committed, permanent

## Directory Structure

```
Project Root/
├── .specter-state/                 # Session state (gitignored)
│   ├── current-session.md         # Active session tracking
│   └── checkpoints/                # Session checkpoints
│       ├── 2025-10-31-14-30.md   # Timestamped checkpoints
│       └── ...
│
├── .specter-memory/                # Persistent memory (committed)
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
  - .specter/product-requirements.md
  - .specter/architecture-blueprint.md
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
   - Use Read tool: .specter-state/current-session.md
   - Parse: current feature, phase, progress

2. Load workflow progress:
   - Use Read tool: .specter-memory/WORKFLOW-PROGRESS.md
   - Parse: feature list, status, metrics

3. Load decisions (if planning):
   - Use Read tool: .specter-memory/DECISIONS-LOG.md
   - Parse: existing ADRs

4. Load tasks (if implementing):
   - Use Read tool: .specter-memory/CHANGES-PLANNED.md
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
1. Create .specter-state/ directory
2. Create .specter-state/checkpoints/ directory
3. Create current-session.md from template
4. Create .specter-memory/ directory
5. Create WORKFLOW-PROGRESS.md with header
6. Create DECISIONS-LOG.md with header
7. Create CHANGES-PLANNED.md with header
8. Create CHANGES-COMPLETED.md with header
9. Add .specter-state/ to .gitignore
10. Commit .specter-memory/ files
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

## Best Practices

1. **Always read before write** - Prevent overwriting concurrent changes
2. **Update timestamps** - Track when state changed
3. **Atomic updates** - Write to temp file, then rename
4. **Validate format** - Ensure state files remain parseable
5. **Create checkpoints** - Save state before risky operations
6. **Append for logs** - Don't truncate historical data
7. **Keep session clean** - Archive completed features from current-session.md

## Related Files

- `shared/workflow-patterns.md` - How skills use state
- `shared/integration-patterns.md` - MCP state synchronization
- Individual skill REFERENCEs for skill-specific state usage

---

**Last Updated**: 2025-10-31
**Used By**: All spec:* skills
**Token Size**: ~1,600 tokens
