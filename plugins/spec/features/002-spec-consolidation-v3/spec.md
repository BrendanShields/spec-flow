# Feature Specification: Spec v3.0 - Unified Workflow & Team Collaboration

**Feature ID**: 002-spec-consolidation-v3
**Priority**: P1 (Critical - Major Version)
**Created**: 2024-10-31
**Status**: Specification

## Executive Summary

Transform Spec from a single-user, multi-command workflow tool into a unified, team-collaborative development platform with 80% token efficiency improvement and a single intuitive entry point.

## Background & Context

### Current State (v2.1.0)
- **8 separate commands** (`/spec-init`, `/spec-specify`, etc.)
- **14 skills** with some overlap
- **Single-user optimized** with limited team support
- **88,700 token load** across all components
- **183-line session state** template
- **Manual coordination** required for teams

### Analysis Findings

**Codebase Analysis** (spec-analyzer):
- Command consolidation: 8→4 possible (6,200 token savings)
- Skill merging: 14→10 possible (4,000 token savings)
- State simplification: 183→80 lines (1,800 token savings)
- Total optimization potential: ~15% token reduction

**Research Findings** (spec-researcher):
- Hub command pattern proven (git, docker, kubectl)
- Interactive CLI patterns reduce friction
- Lazy loading achieves 80% token reduction
- Feature-level locking prevents conflicts
- Living documentation patterns enable master specs

### Problem Statement

**For Individual Developers**:
- Too many commands to learn (8 entry points)
- High token load impacts performance
- Session state complexity
- No master spec (only per-feature specs)

**For Teams**:
- No task assignment or ownership
- Merge conflicts in memory files
- Duplicate work on same tasks
- No visibility into team progress
- Cannot share session context

### Success Criteria

#### P1 - Must Have
- [ ] Single `/spec` command with intelligent routing
- [ ] 80% token reduction (88,700 → 17,740 tokens)
- [ ] Master specification auto-generated from features
- [ ] Task ownership and locking
- [ ] Team status visibility
- [ ] Zero merge conflicts in memory files

#### P2 - Should Have
- [ ] Interactive mode for beginners
- [ ] Progressive help system
- [ ] Real-time progress tracking
- [ ] Conflict-free collaboration (Level 2)

#### P3 - Nice to Have
- [ ] Shell completion
- [ ] Visual dashboard
- [ ] AI-powered task assignment
- [ ] Predictive analytics

---

## User Stories

### P1: Must Have

#### Story 1: Single Entry Point
**As a** developer new to Spec
**I want to** use a single `/spec` command
**So that** I don't have to remember 8 different commands

**Acceptance Criteria**:
- [ ] `/spec` with no args shows intelligent context-based help
- [ ] `/spec init` replaces `/spec-init`
- [ ] `/spec "Add user auth"` auto-detects specification intent
- [ ] `/spec status` replaces `/spec-status`
- [ ] `/spec help` provides progressive assistance
- [ ] `/spec validate` replaces `/spec-validate`
- [ ] All 8 current commands accessible via unified interface
- [ ] Backward compatibility maintained (old commands still work)

**Current**:
```bash
/spec-init
/spec-specify "Feature"
/spec-plan
/spec-tasks
/spec-implement
```

**New**:
```bash
/spec init
/spec "Feature"              # Auto-invokes specify
/spec                        # Auto-continues workflow
```

#### Story 2: Token Efficiency (80% Reduction)
**As a** Claude Code user
**I want** Spec to use minimal tokens
**So that** I can work on larger codebases within context limits

**Acceptance Criteria**:
- [ ] Skills lazy-loaded only when needed
- [ ] Session state reduced from 183→80 lines
- [ ] Command documentation compressed
- [ ] Agent examples externalized
- [ ] Templates loaded on-demand
- [ ] Total load: 88,700→17,740 tokens (80% reduction)
- [ ] No functionality lost in optimization

**Implementation**:
```
BEFORE (per specify invocation):
Command: /spec-specify (186 lines) = 2,800 tokens
Skill: spec:specify (249 lines) = 3,700 tokens
Agent: spec-researcher (221 lines) = 3,300 tokens
Template: spec-template (92 lines) = 1,400 tokens
State: session + progress (~80 lines) = 1,200 tokens
TOTAL: ~12,400 tokens

AFTER (lazy-loaded):
Command: /spec (core: 50 lines) = 750 tokens
Skill: spec:specify (compressed: 80 lines) = 1,200 tokens
Agent: (loaded on-demand)
Template: (loaded on-demand)
State: (pointer-based: 20 lines) = 300 tokens
TOTAL: ~2,250 tokens (82% reduction)
```

#### Story 3: Master Specification
**As a** team lead
**I want** a single master spec that consolidates all features
**So that** I can see the complete system design in one place

**Acceptance Criteria**:
- [ ] `.spec/master-spec.md` auto-generated from all features
- [ ] Updates automatically when features added/modified
- [ ] Includes: Vision, architecture, all features, decisions
- [ ] Versioned (major.minor.patch)
- [ ] Supports incremental updates (not full regeneration)
- [ ] Command: `/spec sync master-spec`

**Structure**:
```markdown
# Project Master Specification v2.3.0

## Product Vision
[Auto-extracted from .spec/config/product-requirements.md]

## Architecture
[Auto-extracted from .spec/config/architecture-blueprint.md]

## Features

### ✅ Completed (5)
- [001] User Authentication (Completed: 2024-10-15)
  Priority: P1 | Status: Production
  [Summary from features/001-user-auth/spec.md]

### 🔄 In Progress (2)
- [006] Payment Integration (Started: 2024-10-28)
  Priority: P1 | Progress: 60% (12/20 tasks)
  [Summary from features/006-payment/spec.md]

### 📋 Planned (3)
- [009] Admin Dashboard
  Priority: P2 | Estimated: 25 tasks, 40h
  [Summary from features/009-admin/spec.md]

## Architecture Decisions
[Auto-extracted from .spec-memory/DECISIONS-LOG.md]

## Change History
[Auto-generated from git commits + feature completions]
```

#### Story 4: Task Ownership
**As a** team member
**I want to** assign tasks to specific developers
**So that** we don't duplicate work

**Acceptance Criteria**:
- [ ] Tasks support `@username` assignment
- [ ] Command: `/spec assign T005 @alice`
- [ ] Auto-assignment based on skills (optional)
- [ ] Unassigned tasks clearly marked
- [ ] Status shows who's working on what
- [ ] Lock automatically acquired when task started
- [ ] Lock released when task completed or abandoned

**Format**:
```markdown
features/006-payment/tasks.md:

### Phase 1: Integration Setup

- [ ] T001 [P1] @alice Setup Stripe SDK
  Status: In Progress
  Started: 2024-10-30T14:30:00Z
  Lock: alice-macbook-pro.local

- [ ] T002 [P1] @bob Create payment models
  Status: Not Started

- [ ] T003 [P1] (unassigned) Add webhook handlers
  Status: Available
```

#### Story 5: Feature-Level Locking
**As a** team member
**I want** automatic locking when I start a task
**So that** others don't work on the same thing

**Acceptance Criteria**:
- [ ] Lock created when `/spec implement --task=T005` invoked
- [ ] Lock file: `.spec/locks/006-T005.lock`
- [ ] Lock contains: user, machine, timestamp, feature, task
- [ ] Lock auto-expires after 4 hours (configurable)
- [ ] Command: `/spec locks` lists all active locks
- [ ] Command: `/spec unlock T005 --force` breaks lock (requires reason)
- [ ] Warning shown if trying to work on locked task

**Lock Format** (`.spec/locks/006-T005.lock`):
```json
{
  "feature": "006-payment",
  "task": "T005",
  "user": "alice",
  "machine": "alice-macbook-pro.local",
  "started": "2024-10-30T14:30:00Z",
  "expires": "2024-10-30T18:30:00Z",
  "pid": 12345
}
```

#### Story 6: Conflict-Free Memory
**As a** team member
**I want** to update progress without merge conflicts
**So that** I can push/pull freely

**Acceptance Criteria**:
- [ ] Memory files use JSON for machine-readable data
- [ ] Markdown auto-generated from JSON (read-only)
- [ ] Git merge driver for automatic conflict resolution
- [ ] Append-only log for completed changes
- [ ] Atomic updates via file locking
- [ ] Zero manual conflict resolution required

**Structure**:
```
.spec-memory/
├── progress.json           # Machine-writable, merge-friendly
├── decisions.json          # Structured ADRs
├── changes-log.jsonl       # Append-only (one JSON per line)
│
├── WORKFLOW-PROGRESS.md    # Auto-generated from progress.json
├── DECISIONS-LOG.md        # Auto-generated from decisions.json
└── CHANGES-COMPLETED.md    # Auto-generated from changes-log.jsonl
```

### P2: Should Have

#### Story 7: Interactive Mode
**As a** developer unfamiliar with Spec
**I want** an interactive wizard
**So that** I can discover features without reading docs

**Acceptance Criteria**:
- [ ] `/spec` with no args and no context shows menu
- [ ] Menu options based on current state
- [ ] Progressive disclosure (show next logical steps)
- [ ] Keyboard shortcuts for power users
- [ ] Supports both menu and direct command modes

**Example**:
```
$ /spec

👻 Spec Workflow Assistant
━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Current Status:
  Feature: 006-payment-integration
  Phase: Implementation
  Progress: 12/20 tasks complete (60%)

What would you like to do?

  1. Continue implementation (Task T013)
  2. Check team status
  3. Start new feature
  4. Sync master spec
  5. Validate current feature
  6. Get help

→
```

#### Story 8: Team Status Dashboard
**As a** team lead
**I want** to see what everyone is working on
**So that** I can coordinate and unblock the team

**Acceptance Criteria**:
- [ ] Command: `/spec status --team`
- [ ] Shows all active features and assignments
- [ ] Highlights blocked tasks
- [ ] Displays velocity metrics
- [ ] Updates in real-time (or on-demand)
- [ ] Exportable to JSON/Markdown

**Output**:
```
$ /spec status --team

👻 Team Status - Project Alpha
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Active Features (3):

📦 006-payment-integration (P1) - 60% complete
  ├─ @alice: T013 [In Progress] Setup webhook handlers
  ├─ @bob: T015 [In Progress] Add refund logic
  └─ (unassigned): 6 tasks available

🔐 007-user-permissions (P2) - 25% complete
  ├─ @charlie: T004 [Blocked] → Waiting on 006-T020
  └─ (unassigned): 15 tasks available

📊 008-analytics (P3) - 5% complete
  └─ @diana: T002 [In Progress] Choose analytics provider

Metrics:
  Team Velocity: 8.2 tasks/day (↗ +12% this week)
  Blockers: 1
  Available Tasks: 27
```

#### Story 9: Progressive Help
**As a** developer learning Spec
**I want** context-aware help
**So that** I get relevant guidance without information overload

**Acceptance Criteria**:
- [ ] Three help levels: quick, command, detailed
- [ ] `/spec help` shows context-based quick help
- [ ] `/spec help <command>` shows command-specific help
- [ ] `/spec help --full` shows comprehensive guide
- [ ] Help suggests next steps based on current phase
- [ ] Examples tailored to current project type

**Levels**:
```
Level 1 (Quick): 5-10 lines
$ /spec help
Next step: Continue implementing 006-payment
Command: /spec (auto-continues)
Or: /spec help implement (detailed help)

Level 2 (Command): 20-30 lines
$ /spec help implement
[Command-specific syntax, options, examples]

Level 3 (Full): Complete guide
$ /spec help --full
[Comprehensive documentation with all commands, patterns, best practices]
```

### P3: Nice to Have

#### Story 10: Shell Completion
**As a** terminal power user
**I want** tab completion for Spec commands
**So that** I can work faster

**Acceptance Criteria**:
- [ ] Bash/Zsh/Fish completion scripts
- [ ] Autocomplete commands and subcommands
- [ ] Autocomplete task IDs and feature names
- [ ] Context-aware suggestions
- [ ] Installation: `/spec completion --install`

#### Story 11: AI Task Assignment
**As a** team lead
**I want** AI to suggest optimal task assignments
**So that** work is distributed efficiently

**Acceptance Criteria**:
- [ ] Analyzes developer skills and history
- [ ] Suggests assignments based on expertise
- [ ] Balances workload across team
- [ ] Command: `/spec assign --auto`
- [ ] Can override suggestions manually

---

## Technical Requirements

### Architecture Changes

#### 1. Command Structure

```
BEFORE (v2.1.0):
.claude/commands/
├── 👻 init.md (155 lines)
├── 👻 specify.md (186 lines)
├── 👻 implement.md (205 lines)
├── 👻 status.md (101 lines)
├── 👻 help.md (139 lines)
├── 👻 session.md (220 lines)
├── 👻 resume.md (132 lines)
└── 👻 validate.md (123 lines)
Total: 8 commands, 1,261 lines

AFTER (v3.0):
.claude/commands/
└── 👻 spec.md (250 lines)
    ├── Hub logic (50 lines)
    ├── Routing (40 lines)
    ├── Context detection (60 lines)
    ├── Subcommands reference (100 lines)
    └── Examples (minimal)

Subcommands (implemented in skill):
├── init        → spec:init
├── <text>      → spec:specify
├── continue    → smart-continue (tasks/implement based on phase)
├── status      → spec:status
├── validate    → spec:validate
├── help        → progressive-help
├── session     → session-manager
├── assign      → task-manager
├── locks       → lock-manager
└── sync        → master-spec-sync

Savings: 1,011 lines (80%)
```

#### 2. Skill Consolidation

```
BEFORE (v2.1.0):
14 skills, 2,931 lines

CONSOLIDATION:
├── spec:specify (249) + spec:clarify (118)
│   → spec:specify-v3 (280 lines)
│
├── spec:analyze (113) + spec:checklist (116)
│   → spec:validate-v3 (150 lines)
│
├── spec:blueprint (239) + spec:discover (186)
│   → spec:architecture (300 lines)
│
├── skill-builder (384) → EXTRACT to separate plugin
│
├── Keep as-is (core workflow):
│   ├── spec:init (376)
│   ├── spec:plan (149)
│   ├── spec:tasks (170)
│   ├── spec:implement (115)
│   ├── spec:update (299)
│   ├── spec:metrics (203)
│   └── spec:orchestrate (214)

AFTER (v3.0):
10 core skills, 2,256 lines (23% reduction)
```

#### 3. State Architecture

```
BEFORE (v2.1.0):
.spec-state/
└── current-session.md (183 lines, git-ignored)

.spec-memory/
├── WORKFLOW-PROGRESS.md (markdown table)
├── DECISIONS-LOG.md (markdown)
├── CHANGES-PLANNED.md (markdown)
└── CHANGES-COMPLETED.md (markdown)

AFTER (v3.0):
.spec/
├── session.md (80 lines, git-ignored)
│   └── Pointers only (feature ID, task ID, phase)
│
├── sessions/ (git-committed for team visibility)
│   ├── alice-session.md
│   ├── bob-session.md
│   └── team-progress.json
│
├── locks/
│   ├── 006-T013.lock
│   └── 007-T004.lock
│
└── master-spec.md (auto-generated)

.spec-memory/
├── progress.json (machine-readable)
├── decisions.json (structured ADRs)
├── changes-log.jsonl (append-only)
│
└── [auto-generated markdown]
    ├── WORKFLOW-PROGRESS.md
    ├── DECISIONS-LOG.md
    └── CHANGES-COMPLETED.md
```

#### 4. Token Optimization Strategy

**Lazy Loading**:
```
Load on command invocation:
├── Core hub: 750 tokens
├── Skill (compressed): 1,200 tokens
├── State (pointers): 300 tokens
└── Template (on-demand): 500 tokens

TOTAL INITIAL LOAD: ~2,750 tokens (78% reduction)

Load on-demand:
├── Agent examples (when needed): +2,000 tokens
├── Extended help (when requested): +1,500 tokens
└── Full template (when creating): +1,000 tokens
```

**Progressive Disclosure**:
```
Skill structure:
├── Core logic (always loaded): 80 lines
├── Examples (load on --examples): 100 lines
└── Reference (load on --help): 120 lines

Default: 80 lines = 1,200 tokens
Full: 300 lines = 4,500 tokens (when needed)
```

### Data Models

#### Master Spec Structure
```typescript
interface MasterSpec {
  version: string;           // Semver
  project: ProjectInfo;
  architecture: ArchitectureRef;
  features: {
    completed: FeatureSummary[];
    inProgress: FeatureSummary[];
    planned: FeatureSummary[];
  };
  decisions: ADRReference[];
  metrics: ProjectMetrics;
  lastUpdated: timestamp;
}

interface FeatureSummary {
  id: string;                // "006"
  name: string;              // "payment-integration"
  priority: "P1" | "P2" | "P3";
  status: FeatureStatus;
  progress?: number;         // 0-100
  assignees?: string[];
  summary: string;           // From spec.md
  dependencies?: string[];
  startedDate?: timestamp;
  completedDate?: timestamp;
}
```

#### Task Assignment Model
```typescript
interface Task {
  id: string;                // "T005"
  feature: string;           // "006"
  title: string;
  priority: "P1" | "P2" | "P3";
  assignee?: string;         // "@alice"
  status: TaskStatus;
  started?: timestamp;
  completed?: timestamp;
  blockedBy?: string[];
  estimatedHours?: number;
}

type TaskStatus =
  | "available"
  | "assigned"
  | "in_progress"
  | "blocked"
  | "completed"
  | "skipped";
```

#### Lock Model
```typescript
interface Lock {
  feature: string;           // "006-payment"
  task: string;              // "T005"
  user: string;              // "alice"
  machine: string;           // "alice-macbook-pro.local"
  started: timestamp;
  expires: timestamp;
  pid?: number;
  reason?: string;           // For force-unlock
}
```

### API Changes

#### Command Interface
```bash
# Before (v2.1)
/spec-init
/spec-specify "Add user auth"
/spec-plan
/spec-tasks
/spec-implement

# After (v3.0)
/spec init
/spec "Add user auth"    # Auto-detects specify
/spec                    # Auto-continues workflow
/spec status --team      # Team dashboard
/spec assign T005 @alice # Task assignment
/spec locks              # View locks
/spec sync master-spec   # Update master spec
```

#### Skill Interface (Unchanged)
```
Skills remain invocable:
- spec:init
- spec:specify
- spec:plan
- spec:tasks
- spec:implement
- spec:validate
- spec:architecture
- spec:metrics
- spec:orchestrate
- spec:update
```

---

## Implementation Notes

### Phase 1: Command Consolidation (Weeks 1-2)

**Tasks**:
1. Create hub command (`👻 spec.md`)
2. Implement routing logic
3. Add context detection
4. Migrate subcommands
5. Add backward compatibility
6. Test all workflows

**Token Target**: 17,740 total (80% reduction)

### Phase 2: State Simplification (Weeks 2-3)

**Tasks**:
1. Reduce session template (183→80 lines)
2. Implement pointer-based state
3. Create JSON-based memory
4. Add git merge driver
5. Implement auto-generation of markdown
6. Test state persistence

**Conflict Target**: Zero merge conflicts

### Phase 3: Team Collaboration (Weeks 3-4)

**Tasks**:
1. Add task assignment (@username)
2. Implement locking mechanism
3. Create team status dashboard
4. Add session sharing
5. Test multi-developer scenarios

**Collaboration Target**: Level 2 (Coordinated)

### Phase 4: Master Spec (Weeks 4-5)

**Tasks**:
1. Design master spec structure
2. Implement auto-generation
3. Add incremental update logic
4. Integrate with sync command
5. Version master spec

**Quality Target**: Single source of truth

### Phase 5: Interactive Mode (Weeks 5-6)

**Tasks**:
1. Design menu system
2. Implement progressive prompts
3. Add context-aware suggestions
4. Create progressive help
5. Add shell completion

**UX Target**: Beginner-friendly

---

## Dependencies

### Technical Dependencies
- Git 2.0+ (for merge drivers)
- Node.js 18+ (for hook scripts)
- Claude Code v2.0+

### Feature Dependencies
- Feature 001 (plugin-stabilization) must be complete
- Current v2.1.0 must be stable

### Knowledge Dependencies
- Understanding of CLI design patterns
- Token optimization techniques
- Team collaboration workflows
- State management strategies

---

## Risks & Mitigations

### Technical Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **Breaking changes** | High | High | Maintain backward compatibility for v2 commands |
| **Token budget exceeded** | High | Medium | Progressive disclosure, lazy loading |
| **Merge conflicts persist** | Medium | Medium | Comprehensive testing with concurrent users |
| **Performance degradation** | Medium | Low | Optimize lazy loading, cache compiled logic |

### User Adoption Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **Learning curve** | Medium | High | Interactive mode, progressive help |
| **Resistance to change** | Medium | Medium | Maintain old commands, migration guide |
| **Team coordination issues** | High | Medium | Clear documentation, locking mechanism |

### Migration Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **Data loss during migration** | High | Low | Auto-backup, migration script validation |
| **Incompatible state formats** | Medium | Medium | State version detection, auto-upgrade |
| **Lost work in progress** | High | Low | Session preservation, checkpoint system |

---

## Success Metrics

### Quantitative

- **Token Reduction**: 88,700 → 17,740 (80% target)
- **Command Simplification**: 8 → 1 entry point
- **Session State**: 183 → 80 lines (56% reduction)
- **Merge Conflicts**: 100% → 0% (zero conflicts)
- **Team Adoption**: 50% of users collaborate (v3.1)

### Qualitative

- **User Feedback**: 4.5+ stars (currently N/A)
- **Learning Time**: <15 min for new users (vs 30 min)
- **Team Satisfaction**: No manual coordination required
- **Documentation Quality**: Master spec always current

---

## Definition of Done

### Feature Complete
- [ ] Single `/spec` command works for all workflows
- [ ] 80% token reduction achieved
- [ ] Master spec auto-generates
- [ ] Task assignment and locking functional
- [ ] Team status dashboard operational
- [ ] Zero merge conflicts in normal usage

### Quality Gates
- [ ] All existing features work with new structure
- [ ] Backward compatibility maintained
- [ ] Performance equal or better than v2.1
- [ ] Documentation complete and accurate
- [ ] Migration guide published

### User Acceptance
- [ ] 5 beta testers validate (solo + team scenarios)
- [ ] No show-stopper bugs
- [ ] Positive feedback on UX improvements
- [ ] Teams successfully collaborate without conflicts

---

## Time Estimate

**Total Estimate**: 6 weeks (240 hours)

### Breakdown
- **Phase 1** (Command consolidation): 40 hours
- **Phase 2** (State simplification): 40 hours
- **Phase 3** (Team collaboration): 60 hours
- **Phase 4** (Master spec): 40 hours
- **Phase 5** (Interactive mode): 40 hours
- **Testing & Documentation**: 20 hours

### Milestones
- **Week 2**: Single command functional
- **Week 3**: Token optimization complete
- **Week 4**: Team collaboration working
- **Week 5**: Master spec generating
- **Week 6**: Interactive mode polished, v3.0 release

---

*Generated by Spec Workflow System*
*Feature Priority: P1 (Major Version)*
*Target Completion: 2024-12-15*
*Estimated Effort: 240 hours*