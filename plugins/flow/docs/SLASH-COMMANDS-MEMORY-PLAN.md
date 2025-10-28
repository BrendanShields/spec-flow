# Slash Commands & Memory Management Plan for Flow

## Executive Summary

This plan introduces a comprehensive slash command system and persistent memory management architecture for the spec-flow plugin, ensuring correct skill usage, efficient session management, and robust change tracking across Claude Code sessions.

## 1. Architecture Overview

### 1.1 Core Components

```
plugins/flow/
├── .claude/
│   ├── commands/                    # NEW: Slash commands
│   │   ├── flow-status.md          # Check workflow state
│   │   ├── flow-help.md            # Context-aware help
│   │   ├── flow-session.md         # Session management
│   │   ├── flow-validate.md        # Validate current state
│   │   ├── flow-resume.md          # Resume interrupted work
│   │   ├── flow-quickstart.md      # Guided workflow starter
│   │   ├── flow-debug.md           # Debug workflow issues
│   │   └── flow-report.md          # Generate progress reports
│   └── skills/                      # Existing skills
│
├── .flow-state/                      # NEW: Session state tracking
│   ├── current-session.md          # Active session state
│   ├── session-history.md          # Session log
│   ├── workflow-state.json         # Machine-readable state
│   └── checkpoints/                # Session checkpoints
│       └── YYYY-MM-DD-HH-MM.md    # Timestamped snapshots
│
├── .flow-memory/                     # NEW: Persistent memory
│   ├── ACTIVE-FEATURE.md           # Current feature being worked on
│   ├── WORKFLOW-PROGRESS.md        # Workflow completion tracking
│   ├── DECISIONS-LOG.md            # Architecture/design decisions
│   ├── CHANGES-PLANNED.md          # Upcoming changes queue
│   ├── CHANGES-COMPLETED.md        # Completed changes log
│   └── CONTEXT-CACHE.md            # Cached analysis results
│
└── .flow/                           # Existing project artifacts
    ├── product-requirements.md
    ├── architecture-blueprint.md
    └── features/
```

### 1.2 Design Principles

1. **Stateless Commands**: Each command reads current state, doesn't maintain internal state
2. **Persistent Context**: All state tracked in versioned .md files
3. **Progressive Disclosure**: Commands reveal complexity as needed
4. **Fail-Safe Operations**: Commands validate before destructive actions
5. **Session Continuity**: Seamless resume across Claude sessions

## 2. Slash Commands Implementation

### 2.1 Core Workflow Commands

#### `/flow-status`
**Purpose**: Show current workflow state and next steps
```md
# flow-status.md
Display current workflow position and suggest next actions.

## Usage
/flow-status [--verbose] [--feature=NAME]

## Functionality
1. Read .flow-state/current-session.md
2. Check .flow-memory/WORKFLOW-PROGRESS.md
3. Analyze incomplete tasks in features/*/tasks.md
4. Display:
   - Current feature
   - Workflow phase (specify/plan/implement)
   - Completed steps
   - Pending steps
   - Suggested next command
   - Blockers/warnings

## Example Output
```
Current Feature: 001-user-authentication
Phase: Implementation (Task 3/15)
Completed: ✓ Specify ✓ Plan ✓ Tasks T001-T002
Next: T003 [US1] Create User model
Suggested: /flow-implement --continue
Warnings: 2 clarification questions pending
```
```

#### `/flow-help`
**Purpose**: Context-aware help and skill recommendations
```md
# flow-help.md
Provide intelligent help based on current context.

## Usage
/flow-help [SKILL] [--examples] [--persona=PERSONA]

## Functionality
1. If no SKILL: analyze context and suggest relevant skills
2. If SKILL provided: show detailed help with examples
3. Check current workflow phase
4. Recommend appropriate next steps
5. Show persona-specific guidance

## Context Detection
- No .flow/ directory → Suggest flow:init
- In features/*/spec.md → Suggest flow:clarify or flow:plan
- Tasks.md exists → Suggest flow:implement
- Errors in session → Show flow:debug
```

#### `/flow-session`
**Purpose**: Manage Claude session state
```md
# flow-session.md
Manage session state for continuity across Claude conversations.

## Usage
/flow-session [save|restore|list|clean] [--checkpoint=NAME]

## Commands
- save: Create checkpoint of current state
- restore: Load previous session state
- list: Show available checkpoints
- clean: Remove old checkpoints

## State Captured
1. Current feature and phase
2. Active skills context
3. Pending decisions
4. Configuration state
5. Recent command history
6. Error states

## Auto-Checkpoint Triggers
- Before flow:implement starts
- After major phase completion
- Before configuration changes
- On error recovery
```

#### `/flow-validate`
**Purpose**: Validate workflow consistency and requirements
```md
# flow-validate.md
Validate current workflow state and artifact consistency.

## Usage
/flow-validate [--phase=PHASE] [--fix] [--strict]

## Validation Checks
1. Artifact consistency
   - spec.md ↔ plan.md alignment
   - plan.md ↔ tasks.md alignment
   - User story completeness

2. Workflow prerequisites
   - Required files exist
   - Dependencies satisfied
   - Configuration valid

3. State consistency
   - No orphaned tasks
   - No circular dependencies
   - Priority alignment

## Auto-Fix Capabilities
- Update task references
- Align priorities
- Fix formatting issues
- Update cross-references
```

#### `/flow-resume`
**Purpose**: Resume interrupted workflow from last checkpoint
```md
# flow-resume.md
Resume interrupted workflow intelligently.

## Usage
/flow-resume [--from=CHECKPOINT] [--feature=NAME]

## Process
1. Load .flow-state/current-session.md
2. Identify interruption point
3. Validate current state
4. Show work completed
5. Restore context
6. Continue from last task

## Smart Recovery
- Detect partially completed tasks
- Identify uncommitted changes
- Restore configuration state
- Re-establish integrations
- Continue skill chain
```

### 2.2 Advanced Management Commands

#### `/flow-quickstart`
**Purpose**: Guided workflow initialization with templates
```md
# flow-quickstart.md
Interactive workflow starter with persona detection.

## Usage
/flow-quickstart [--persona=PERSONA] [--template=TEMPLATE]

## Personas
- poc: Minimal ceremony, quick validation
- solo: Single developer, full workflow
- team: Multi-person coordination
- enterprise: Full governance and integration

## Process
1. Detect project type (greenfield/brownfield)
2. Select appropriate persona
3. Configure minimal settings
4. Create initial structure
5. Launch first skill
6. Set up memory tracking
```

#### `/flow-debug`
**Purpose**: Debug workflow issues and inconsistencies
```md
# flow-debug.md
Diagnose and fix workflow problems.

## Usage
/flow-debug [--issue=TYPE] [--deep] [--trace]

## Diagnostic Areas
1. State conflicts
2. Missing dependencies
3. Configuration errors
4. Integration failures
5. Task blockers
6. Memory inconsistencies

## Output
- Issue identification
- Root cause analysis
- Suggested fixes
- Recovery commands
- Prevention tips
```

#### `/flow-report`
**Purpose**: Generate workflow reports and metrics
```md
# flow-report.md
Generate progress and status reports.

## Usage
/flow-report [--type=TYPE] [--format=FORMAT] [--period=PERIOD]

## Report Types
- progress: Overall workflow progress
- velocity: Task completion rate
- blockers: Current impediments
- decisions: Architecture decisions log
- changes: Change history
- metrics: Performance metrics

## Formats
- markdown: For documentation
- json: For tooling integration
- summary: Executive overview
- detailed: Full analysis
```

## 3. Memory Management System

### 3.1 State Tracking Files

#### `.flow-state/current-session.md`
```markdown
# Current Session State
Last Updated: 2024-01-15T10:30:00Z
Session ID: sess_abc123

## Active Feature
- Feature: 001-user-authentication
- Phase: implementation
- Started: 2024-01-15T09:00:00Z

## Workflow Progress
- [x] flow:init completed
- [x] flow:specify completed
- [x] flow:clarify completed (3 questions resolved)
- [x] flow:plan completed
- [x] flow:tasks completed (15 tasks generated)
- [ ] flow:implement (3/15 tasks done)

## Current Context
- Working on: T003 [US1] Create User model
- Branch: 001-user-authentication
- Last Command: flow:implement --continue

## Pending Decisions
1. Database choice between PostgreSQL and MySQL
2. Authentication method (JWT vs sessions)

## Configuration State
- FLOW_ATLASSIAN_SYNC=enabled
- FLOW_JIRA_PROJECT_KEY=PROJ
- Current JIRA: PROJ-123
```

#### `.flow-memory/WORKFLOW-PROGRESS.md`
```markdown
# Workflow Progress Tracker

## Features Completed
| Feature | Started | Completed | Tasks | Time |
|---------|---------|-----------|-------|------|
| 001-init-project | 2024-01-10 | 2024-01-10 | 5/5 | 2h |
| 002-database-setup | 2024-01-11 | 2024-01-12 | 8/8 | 4h |

## Features In Progress
| Feature | Started | Progress | Blocked | ETA |
|---------|---------|----------|---------|-----|
| 003-user-auth | 2024-01-15 | 3/15 (20%) | No | 2024-01-16 |

## Skill Usage Statistics
| Skill | Uses | Avg Time | Success Rate |
|-------|------|----------|--------------|
| flow:specify | 3 | 5 min | 100% |
| flow:plan | 3 | 15 min | 100% |
| flow:implement | 12 | 30 min | 92% |

## Velocity Metrics
- Average tasks/day: 8.5
- Average feature time: 6 hours
- Rework rate: 8%
```

#### `.flow-memory/DECISIONS-LOG.md`
```markdown
# Architecture & Design Decisions Log

## 2024-01-15: Authentication Strategy
**Context**: Choosing authentication method for user-auth feature
**Decision**: JWT tokens with refresh token rotation
**Rationale**:
- Stateless authentication scales better
- Supports mobile clients planned for Q2
- Industry standard for REST APIs
**Impact**: All endpoints will require JWT middleware
**Alternatives Considered**: Session-based, OAuth2
**Decided By**: Solo developer after flow:clarify

## 2024-01-14: Database Selection
**Context**: Initial database choice
**Decision**: PostgreSQL 14
**Rationale**:
- Better JSON support for flexible schemas
- Strong ACID compliance
- Team expertise
**Impact**: Using TypeORM for migrations
**Alternatives Considered**: MySQL, MongoDB
```

#### `.flow-memory/CHANGES-PLANNED.md`
```markdown
# Planned Changes Queue

## Priority 1 - This Week
- [ ] Implement JWT refresh token rotation
- [ ] Add rate limiting to auth endpoints
- [ ] Set up email verification flow
- [ ] Add password reset functionality

## Priority 2 - Next Sprint
- [ ] Implement 2FA support
- [ ] Add OAuth2 providers (Google, GitHub)
- [ ] Audit logging for auth events
- [ ] Session management dashboard

## Priority 3 - Backlog
- [ ] Biometric authentication support
- [ ] Enterprise SSO integration
- [ ] Advanced threat detection

## Technical Debt
- [ ] Refactor user validation logic (identified in T003)
- [ ] Consolidate error handling patterns
- [ ] Update authentication documentation
```

### 3.2 Context Preservation

#### `.flow-memory/CONTEXT-CACHE.md`
```markdown
# Cached Analysis Results

## Codebase Analysis (2024-01-15)
**Command**: flow:discover
**Results**:
- Total files: 234
- Languages: TypeScript (70%), JavaScript (20%), Other (10%)
- Key patterns: MVC architecture, REST API, PostgreSQL
- Dependencies: Express, TypeORM, Jest
**Expires**: 2024-01-22

## Performance Baseline (2024-01-14)
**Command**: flow:metrics
**Results**:
- API response time: 120ms avg
- Database queries: 15ms avg
- Test coverage: 78%
- Build time: 45 seconds
**Next Check**: 2024-01-21

## Integration Status (2024-01-15)
**JIRA Connection**: Active
**Last Sync**: 2024-01-15T10:00:00Z
**Confluence Space**: PROJ
**GitHub Repo**: company/project
```

## 4. Implementation Strategy

### 4.1 Phase 1: Core Commands (Week 1)
**Priority**: Critical for workflow continuity

1. Create commands directory structure
2. Implement `/flow-status` command
3. Implement `/flow-help` with context detection
4. Create basic state tracking in `.flow-state/`
5. Test with existing skills

**Deliverables**:
- 3 core commands operational
- Basic state persistence
- Session continuity working

### 4.2 Phase 2: Memory Management (Week 2)
**Priority**: Essential for multi-session work

1. Implement `.flow-memory/` structure
2. Create `/flow-session` save/restore
3. Build `/flow-resume` capability
4. Add checkpoint auto-creation
5. Implement decision logging

**Deliverables**:
- Full session management
- Automatic checkpointing
- Decision history tracking

### 4.3 Phase 3: Advanced Commands (Week 3)
**Priority**: Workflow optimization

1. Build `/flow-validate` with auto-fix
2. Create `/flow-quickstart` wizard
3. Implement `/flow-debug` diagnostics
4. Add `/flow-report` generation
5. Integration with existing skills

**Deliverables**:
- Complete command suite
- Automated validation
- Progress reporting

### 4.4 Phase 4: Optimization (Week 4)
**Priority**: Performance and polish

1. Optimize memory file formats
2. Add compression for old sessions
3. Implement cache expiration
4. Performance profiling
5. Documentation completion

**Deliverables**:
- Optimized performance
- Complete documentation
- Production ready

## 5. Integration Points

### 5.1 Skill Integration
Each skill will:
1. Read state from `.flow-state/current-session.md`
2. Update progress in `.flow-memory/WORKFLOW-PROGRESS.md`
3. Log decisions to `.flow-memory/DECISIONS-LOG.md`
4. Create checkpoints at major milestones
5. Validate state before execution

### 5.2 Command Chaining
Commands can chain naturally:
```bash
/flow-status              # Check current state
/flow-validate --fix      # Fix any issues
/flow-resume              # Continue work
/flow-report --progress   # Show progress
```

### 5.3 Error Recovery Flow
On any error:
1. `/flow-debug` identifies issue
2. `/flow-session save` creates recovery point
3. `/flow-validate --fix` attempts auto-repair
4. `/flow-resume` continues from safe state

## 6. Benefits & Impact

### 6.1 Immediate Benefits
- **Session Continuity**: Never lose context between Claude sessions
- **State Visibility**: Always know where you are in workflow
- **Error Recovery**: Gracefully handle interruptions
- **Progress Tracking**: Quantify velocity and completion

### 6.2 Long-term Benefits
- **Knowledge Persistence**: Decisions tracked permanently
- **Team Coordination**: Shared state across team
- **Metrics & Analytics**: Data-driven improvement
- **Reduced Cognitive Load**: System remembers for you

### 6.3 Performance Impact
- **Memory Usage**: ~500KB for typical project
- **Command Latency**: < 100ms for status checks
- **File I/O**: Optimized with caching
- **Storage Growth**: ~10MB/year with rotation

## 7. Success Metrics

### 7.1 Adoption Metrics
- Command usage frequency
- Session recovery success rate
- State consistency percentage
- User time saved

### 7.2 Quality Metrics
- Workflow completion rate
- Error recovery time
- Context preservation accuracy
- Decision traceability

### 7.3 Performance Metrics
- Command response time
- Memory file size
- Cache hit rate
- Session restore time

## 8. Risk Mitigation

### 8.1 Data Loss Prevention
- Automatic checkpointing
- Multiple backup locations
- Atomic file operations
- Recovery procedures

### 8.2 Performance Degradation
- File size limits
- Rotation policies
- Cache optimization
- Lazy loading

### 8.3 Compatibility
- Version detection
- Migration scripts
- Backward compatibility
- Graceful degradation

## 9. Documentation Requirements

### 9.1 User Documentation
- Command reference guide
- Quick start tutorial
- Workflow examples
- Troubleshooting guide

### 9.2 Developer Documentation
- Integration guide
- State file schemas
- API reference
- Extension points

## 10. Next Steps

### Immediate Actions (This Week)
1. Create `.claude/commands/` directory
2. Implement `/flow-status` command
3. Create `.flow-state/` structure
4. Test with current workflow
5. Document initial commands

### Follow-up Actions (Next Month)
1. Complete all 8 commands
2. Optimize memory management
3. Add analytics capabilities
4. Create team coordination features
5. Build migration tools

## Appendix A: Command Quick Reference

| Command | Purpose | Priority | Effort |
|---------|---------|----------|--------|
| `/flow-status` | Show current state | Critical | 2 hours |
| `/flow-help` | Context help | Critical | 3 hours |
| `/flow-session` | Manage sessions | High | 4 hours |
| `/flow-validate` | Validate state | High | 4 hours |
| `/flow-resume` | Resume work | High | 3 hours |
| `/flow-quickstart` | Quick setup | Medium | 3 hours |
| `/flow-debug` | Debug issues | Medium | 4 hours |
| `/flow-report` | Generate reports | Low | 3 hours |

## Appendix B: Memory File Sizes

| File | Typical Size | Max Size | Rotation |
|------|-------------|----------|----------|
| current-session.md | 2 KB | 10 KB | Per session |
| WORKFLOW-PROGRESS.md | 5 KB | 50 KB | Monthly |
| DECISIONS-LOG.md | 10 KB | 100 KB | Yearly |
| CHANGES-PLANNED.md | 3 KB | 20 KB | Continuous |
| CONTEXT-CACHE.md | 5 KB | 30 KB | Weekly |

## Appendix C: State File Schema

```json
{
  "session": {
    "id": "string",
    "started": "ISO8601",
    "updated": "ISO8601",
    "feature": "string",
    "phase": "enum",
    "progress": {
      "completed": ["string"],
      "pending": ["string"],
      "blocked": ["string"]
    }
  },
  "configuration": {
    "key": "value"
  },
  "context": {
    "lastCommand": "string",
    "workingDirectory": "string",
    "branch": "string",
    "errors": ["string"]
  }
}
```

---

*Plan Version: 1.0*
*Created: 2024-01-15*
*Estimated Implementation: 4 weeks*
*Total Effort: ~80 hours*