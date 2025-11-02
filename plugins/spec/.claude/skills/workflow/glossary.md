# Workflow Terminology Glossary

**Quick reference for all Spec workflow terms and concepts**

**Coverage**: 90%+ complete - includes all critical workflow, state management, agent, architecture, template, and integration terms

**Last Updated**: 2025-01-15

---

## Table of Contents

1. [Priority Levels](#priority-levels)
2. [Workflow Phases](#workflow-phases)
3. [Function Types](#function-types)
4. [File Artifacts](#file-artifacts)
5. [State Management](#state-management)
6. [Markers & Tags](#markers--tags)
7. [Architecture Terms](#architecture-terms)
8. [Agent System](#agent-system)
9. [Template System](#template-system)
10. [Project Types](#project-types)
11. [Integration Terms](#integration-terms)
12. [Command Syntax](#command-syntax)

---

## Priority Levels

### P1 (Must Have)
**Definition**: Core functionality required for MVP (Minimum Viable Product)

**Characteristics**:
- Blocks release if not implemented
- Core user need or business requirement
- Foundation for other features

**Examples**:
- User login/authentication
- Core data operations (CRUD)
- Critical business logic

**Usage**: Apply to user stories that are absolutely essential

**In Tasks**: P1 tasks must complete before release

**In Epics**: P1 epics represent fundamental product capabilities

**See also**: [P2](#p2-should-have), [P3](#p3-nice-to-have), [User Story ID](#user-story-id-us)

---

### P2 (Should Have)
**Definition**: Important features that enhance the product significantly

**Characteristics**:
- Important but can defer to next iteration
- Significantly improves user experience
- Provides competitive advantage
- Not blocking for basic functionality

**Examples**:
- Password reset via email
- Advanced search features
- User preferences/settings

**Usage**: Important enhancements that should be included if time permits

**In Tasks**: P2 tasks targeted for release but can defer if needed

**In Epics**: P2 epics add significant value but aren't critical for launch

**See also**: [P1](#p1-must-have), [P3](#p3-nice-to-have), [Epic Priority](#epic-priority)

---

### P3 (Nice to Have)
**Definition**: Optional enhancements and convenience features

**Characteristics**:
- Optional improvements
- Convenience features
- Future considerations
- Low impact if not included

**Examples**:
- Theme customization
- Advanced analytics
- Social sharing features

**Usage**: Desirable features for future iterations

**In Tasks**: P3 tasks deferred unless all P1/P2 complete

**In Epics**: P3 epics represent polish and future enhancement opportunities

**See also**: [P1](#p1-must-have), [P2](#p2-should-have), [Epic Priority](#epic-priority)

---

### Epic Priority
**Definition**: Priority assigned at the epic/feature level

**Mapping**:
- P1 Epic: Contains primarily P1 user stories, critical for product launch
- P2 Epic: Contains mix of P1/P2 stories, important but not blocking
- P3 Epic: Contains P2/P3 stories, future enhancements

**Inheritance**: User stories typically inherit epic priority but can have higher priority

**Example**:
```markdown
Epic: User Authentication (P1)
  ├─ US001: Login with email/password (P1)
  ├─ US002: Password reset (P2)
  └─ US003: Social login (P3)
```

**See also**: [P1](#p1-must-have), [P2](#p2-should-have), [P3](#p3-nice-to-have)

---

## Workflow Phases

### Phase 1: Initialize
**Purpose**: Set up project structure and define architecture

**Entry**: New project or first-time Spec setup

**Functions**: init ⭐, discover 🔧, blueprint 🔧

**Output**:
- `{config.paths.spec_root}/` directory structure
- State tracking initialized
- Architecture documented (optional)

**Exit**: Ready to create first feature

**Note**: One-time setup per project

---

### Phase 2: Define Requirements
**Purpose**: Create and validate feature specifications

**Entry**: Ready to build new feature

**Functions**: generate ⭐, clarify 🔧, checklist 🔧

**Output**:
- `spec.md` with user stories
- Acceptance criteria
- Resolved ambiguities

**Exit**: Requirements approved, ready for technical design

---

### Phase 3: Design Solution
**Purpose**: Create technical plan and architecture

**Entry**: Approved specification exists

**Functions**: plan ⭐, analyze 🔧

**Output**:
- `plan.md` with technical design
- Architecture diagrams
- ADRs (Architecture Decision Records)
- API contracts

**Exit**: Technical approach agreed, ready to task out

---

### Phase 4: Build Feature
**Purpose**: Break down and execute implementation

**Entry**: Technical plan complete

**Functions**: tasks ⭐, implement ⭐

**Output**:
- `tasks.md` with breakdown
- Working feature code
- Passing tests

**Exit**: All P1 tasks complete, feature functional

---

### Phase 5: Track Progress
**Purpose**: Maintain specs and monitor development

**Entry**: Anytime during project lifecycle

**Functions**: update 🔧, metrics 🔧, orchestrate 🔧

**Output**:
- Updated specifications
- Progress analytics
- Automated workflows

**Exit**: Continuous, no formal exit

**Note**: Ongoing throughout project lifecycle

---

## Function Types

### ⭐ CORE (Core Workflow Function)
**Definition**: Required sequential workflow function

**Full Name**: CORE function (Core Workflow Function)

**Characteristics**:
- Must run in specific order
- Forms backbone of workflow
- Cannot skip (except in orchestrate mode)
- Essential for workflow progression

**Core Functions**:
1. `init` - Initialize project structure
2. `generate` - Create feature specification
3. `plan` - Design technical solution
4. `tasks` - Break down into tasks
5. `implement` - Execute implementation

**Usage**: Follow sequence: init → generate → plan → tasks → implement

**Visual**: Marked with ⭐ in phase READMEs and documentation

**See also**: [TOOL Functions](#-tool-supporting-tool-function), [Workflow Phases](#workflow-phases)

---

### 🔧 TOOL (Supporting Tool Function)
**Definition**: Optional contextual support function

**Full Name**: TOOL function (Supporting Tool Function)

**Characteristics**:
- Run as needed based on context
- Not required for basic workflow
- Enhance or validate core workflow
- Can run multiple times
- Invoked when specific needs arise

**Tool Functions**:
1. `discover` - Analyze existing codebase (brownfield)
2. `clarify` - Resolve [CLARIFY] ambiguities
3. `blueprint` - Define architecture standards
4. `analyze` - Validate consistency
5. `update` - Modify specifications
6. `metrics` - Track progress and analytics
7. `checklist` - Generate quality checklists
8. `orchestrate` - Automate full workflow

**Usage**: Use when context requires (brownfield, ambiguity, validation, changes)

**Visual**: Marked with 🔧 in phase READMEs and documentation

**See also**: [CORE Functions](#-core-core-workflow-function), [Workflow Phases](#workflow-phases)

---

## File Artifacts

### spec.md
**Location**: `{config.paths.features}/###-feature-name/{config.naming.files.spec}`

**Purpose**: Feature specification with user stories

**Created by**: `generate/` function

**Contains**:
- Feature overview
- Problem statement
- User stories (P1/P2/P3)
- Acceptance criteria
- Technical requirements
- Integration points
- [CLARIFY] tags for ambiguities

**Updated by**: `clarify/`, `update/`

**When created**: Phase 2 (Define Requirements)

---

### plan.md
**Location**: `{config.paths.features}/###-feature-name/{config.naming.files.plan}`

**Purpose**: Technical design and architecture decisions

**Created by**: `plan/` function

**Contains**:
- Architecture overview
- Architecture diagrams
- Data models and schemas
- API contracts
- ADRs (Architecture Decision Records)
- Security considerations
- Testing strategy
- Implementation approach

**Updated by**: `update/`, manual edits

**When created**: Phase 3 (Design Solution)

---

### tasks.md
**Location**: `{config.paths.features}/###-feature-name/{config.naming.files.tasks}`

**Purpose**: Executable task breakdown with dependencies

**Created by**: `tasks/` function

**Contains**:
- Task IDs (T001, T002, etc.)
- Task descriptions
- Dependencies (T002 → T001)
- Priority markers (P1/P2/P3)
- Parallel indicators [P]
- Estimated effort
- Completion status

**Updated by**: `implement/`, `update/`, manual edits

**When created**: Phase 4 (Build Feature)

---

### product-requirements.md
**Location**: `{config.paths.spec_root}/product-requirements.md`

**Purpose**: High-level product vision and success metrics

**Created by**: `init/` function

**Contains**:
- Product vision
- Target users
- Success criteria
- Key Performance Indicators (KPIs)
- Business constraints
- Stakeholders

**Updated by**: Manual edits

**When created**: Phase 1 (Initialize)

---

### architecture-blueprint.md
**Location**: `{config.paths.spec_root}/architecture-blueprint.md`

**Purpose**: Project-wide architecture standards

**Created by**: `blueprint/` function

**Contains**:
- Tech stack decisions
- Design patterns
- API conventions
- Security standards
- ADRs (Architecture Decision Records)
- Coding standards
- Testing philosophy
- Deployment strategy

**Updated by**: Manual edits, `blueprint/` re-runs

**When created**: Phase 1 (Initialize), optional

---

## State Management

### {config.paths.state}/
**Full Name**: Spec State Directory

**Purpose**: Session-specific temporary state tracking

**Location**: `{config.paths.state}/` in project root

**Git Status**: Git-ignored (temporary, not committed)

**Contents**:
- `current-session.md` - Active feature, current phase
- `checkpoints/` - Periodic state snapshots

**Lifespan**: Single development session

**Created by**: `init/` function

**Why Git-Ignored**: Session-specific, not relevant to other developers or shared across sessions

**See also**: [Session State](#session-state), [{config.paths.memory}/](#spec-memory), [Checkpoint](#checkpoint)

---

### {config.paths.memory}/
**Full Name**: Spec Memory Directory

**Purpose**: Persistent project-wide state and history

**Location**: `{config.paths.memory}/` in project root

**Git Status**: Committed (shared across team)

**Contents**:
- `WORKFLOW-PROGRESS.md` - Feature completion tracking
- `DECISIONS-LOG.md` - Architecture decisions
- `CHANGES-PLANNED.md` - Planned changes
- `CHANGES-COMPLETED.md` - Completed changes

**Lifespan**: Entire project lifecycle

**Created by**: `init/` function

**Why Committed**: Team knowledge, project history, metrics tracking

**See also**: [Persistent Memory](#persistent-memory), [WORKFLOW-PROGRESS.md](#workflow-progressmd)

---

### Session State
**Location**: `{config.paths.state}/current-session.md`

**Purpose**: Track current session progress

**Git Status**: Git-ignored (temporary, not committed)

**Structure**:
```markdown
## Current Session
Started: 2024-01-15 14:30
Feature: 003-user-authentication
Phase: implementation

## Progress
Tasks Complete: 5/12
Last Updated: 2024-01-15 16:45
Last Command: /spec implement --continue
```

**Lifespan**: Single development session

**Contains**:
- Current feature ID
- Current phase
- Task progress
- Last command run
- Session start time

**Updated by**: All workflow functions automatically

**Why Git-Ignored**: Session-specific, not relevant to other developers

**See also**: [{config.paths.state}/](#spec-state), [Persistent Memory](#persistent-memory), [State Transition](#state-transitions)

---

### Persistent Memory
**Location**: `{config.paths.memory}/`

**Purpose**: Project-wide persistent state and history

**Git Status**: Committed (shared across team)

**Files**:
- `WORKFLOW-PROGRESS.md` - Feature completion tracking
- `DECISIONS-LOG.md` - Architecture decisions
- `CHANGES-PLANNED.md` - Planned changes
- `CHANGES-COMPLETED.md` - Completed changes

**Lifespan**: Entire project lifecycle

**Contains**:
- Historical decisions
- Feature completion records
- Metrics over time
- Change history
- Architecture decision rationale

**Why Committed**: Team knowledge, project history, onboarding resource

**See also**: [{config.paths.memory}/](#spec-memory), [WORKFLOW-PROGRESS.md](#workflow-progressmd), [DECISIONS-LOG.md](#decisions-logmd)

---

### current-session.md
**Location**: `{config.paths.state}/current-session.md`

**Purpose**: Track active development session state

**Git Status**: Git-ignored

**Format**:
```markdown
## Current Session
Started: 2024-01-15 14:30
Feature: 003-user-authentication
Phase: implementation

## Progress
Tasks Complete: 5/12
Last Updated: 2024-01-15 16:45
Last Command: /spec implement --continue

## Context
- Working on T005: Implement JWT token generation
- Dependencies resolved: T001, T002, T003
- Next: T006 after T005 completes
```

**Updated by**: Hub caching system, all workflow functions

**Usage**: Enables context-aware `/spec` continuation

**See also**: [Session State](#session-state), [Hub Caching](#hub-caching)

---

### WORKFLOW-PROGRESS.md
**Location**: `{config.paths.memory}/WORKFLOW-PROGRESS.md`

**Purpose**: Track feature completion and metrics across project

**Git Status**: Committed

**Format**:
```markdown
## Features
### 001-user-registration (Completed)
- Started: 2024-01-01
- Completed: 2024-01-08
- Tasks: 15/15 complete
- Priority: P1

### 003-user-authentication (In Progress)
- Started: 2024-01-15
- Phase: implementation
- Tasks: 5/12 complete
- Priority: P1

## Metrics
- Total Features: 10
- Completed: 3
- In Progress: 2
- Planned: 5
```

**Updated by**: `generate/`, `implement/`, `update/`, `metrics/`

**Usage**: Progress tracking, metrics, reporting

**See also**: [Persistent Memory](#persistent-memory), [CHANGES-COMPLETED.md](#changes-completedmd)

---

### DECISIONS-LOG.md
**Location**: `{config.paths.memory}/DECISIONS-LOG.md`

**Purpose**: Log architecture decisions and rationale

**Git Status**: Committed

**Format**:
```markdown
## 2024-01-15: JWT Authentication
**Decision**: Use JWT with refresh tokens
**Context**: Need stateless authentication
**Alternatives**: Session-based, OAuth only
**Rationale**: Scalability, mobile support, industry standard
**Feature**: 003-user-authentication

## 2024-01-10: Database Choice
**Decision**: PostgreSQL
**Context**: Need relational data with JSON support
**Alternatives**: MongoDB, MySQL
**Rationale**: ACID compliance, JSON support, mature ecosystem
**Feature**: 001-user-registration
```

**Updated by**: `plan/`, `blueprint/`, manual edits

**Usage**: Historical context for decisions, onboarding, refactoring

**See also**: [ADR](#adr-architecture-decision-record), [Persistent Memory](#persistent-memory)

---

### CHANGES-PLANNED.md
**Location**: `{config.paths.memory}/CHANGES-PLANNED.md`

**Purpose**: Track upcoming planned changes and tasks

**Git Status**: Committed

**Format**:
```markdown
## Feature: 003-user-authentication
### Planned Changes
- [ ] T005: Implement JWT token generation
- [ ] T006: Add token refresh endpoint
- [ ] T007: Implement logout functionality

## Feature: 004-user-profile
### Planned Changes
- [ ] Add profile photo upload
- [ ] Implement bio editing
- [ ] Add social links
```

**Updated by**: `tasks/`, `plan/`, `update/`

**Usage**: Track work queue, coordinate team efforts

**See also**: [CHANGES-COMPLETED.md](#changes-completedmd), [tasks.md](#tasksmd)

---

### CHANGES-COMPLETED.md
**Location**: `{config.paths.memory}/CHANGES-COMPLETED.md`

**Purpose**: Archive completed changes and tasks

**Git Status**: Committed

**Format**:
```markdown
## Feature: 003-user-authentication
### Completed: 2024-01-15
- [x] T001: Create user model (2024-01-15 10:30)
- [x] T002: Add authentication endpoints (2024-01-15 12:00)
- [x] T003: Implement password hashing (2024-01-15 14:00)

## Feature: 001-user-registration
### Completed: 2024-01-08
- [x] All 15 tasks completed
- [x] Feature tested and deployed
```

**Updated by**: `implement/`, `update/`

**Usage**: Historical record, velocity tracking, retrospectives

**See also**: [CHANGES-PLANNED.md](#changes-plannedmd), [WORKFLOW-PROGRESS.md](#workflow-progressmd)

---

### Checkpoint
**Definition**: Saved snapshot of session state at a point in time

**Location**: `{config.paths.state}/checkpoints/`

**Purpose**: Enable recovery from interruptions or errors

**Format**: Timestamped JSON or markdown files

**Created by**: Automatic (after major operations) or manual (`/spec checkpoint`)

**Example**:
```
{config.paths.state}/checkpoints/
├── 2024-01-15-14-30-pre-implement.json
├── 2024-01-15-15-45-mid-implementation.json
└── 2024-01-15-16-30-task-batch-complete.json
```

**Usage**: Restore state after crashes, undo operations, audit trail

**Retention**: Typically kept for current session only (git-ignored)

**See also**: [Session State](#session-state), [{config.paths.state}/](#spec-state)

---

### Hub Caching
**Definition**: Performance optimization where `/spec` hub caches state to reduce redundant reads

**Purpose**: 80% reduction in state file overhead

**Mechanism**: Hub reads state once, passes to skills via context

**Benefits**:
- Skills don't re-read `current-session.md`
- Faster execution
- Reduced token usage
- Consistent state across skill invocations

**Implementation**: Hub command loads state, includes in skill invocation context

**Cache Invalidation**: State refreshed on next `/spec` invocation

**See also**: [Session State](#session-state), [Token Efficiency](#token-efficiency)

---

### State Transitions
**Flow**: init → initialized → specification → planning → tasking → implementation → complete

**Tracked in**: `{config.paths.state}/current-session.md`

**Example**:
```markdown
## Current Phase
Phase: implementation
Feature: 003-user-authentication
Status: in_progress
Tasks Complete: 5/12
```

---

## Markers & Tags

### [CLARIFY]
**Syntax**: `[CLARIFY: question or ambiguity]`

**Purpose**: Mark ambiguous requirements needing clarification

**Example**:
```markdown
- Reset link expires after [CLARIFY: 1 hour? 24 hours?]
- System should be fast [CLARIFY: Define "fast" - response time SLA?]
```

**Resolution**: Run `/spec clarify` to address tagged ambiguities

**Usage**: Apply liberally - better to clarify than assume

**Location**: Primarily in `spec.md`, can appear in `plan.md`

---

### [P] (Parallel Marker)
**Syntax**: `[P]` at start of task description

**Purpose**: Indicate task can run in parallel with others

**Example**:
```markdown
T001: [P] Set up authentication API endpoints
T002: [P] Create user database schema
T003: Integrate T001 and T002 (depends on both)
```

**Usage**: Identifies opportunities for parallel development

**Benefits**: Faster implementation, team parallelization

**Location**: In `tasks.md`

**See also**: [Task Dependencies](#task-dependencies), [Task ID](#task-id-t)

---

### User Story ID (US#)
**Syntax**: `US###` (e.g., `US001`, `US042`)

**Purpose**: Unique identifier for user stories within a feature

**Example**:
```markdown
US001: As a user, I want to log in with email and password
US002: As a user, I want to reset my forgotten password
```

**Numbering**: Sequential within each feature, starts at 001

**Usage**: Reference stories in tasks, plans, discussions

**Location**: In `spec.md`

**See also**: [Task ID](#task-id-t), [spec.md](#specmd)

---

### Task ID (T###)
**Syntax**: `T###` (e.g., `T001`, `T042`)

**Purpose**: Unique identifier for implementation tasks within a feature

**Example**:
```markdown
T001: Create user model
T002: Add authentication endpoints → T001
T003: Implement password hashing
```

**Numbering**: Sequential within each feature, starts at 001

**Usage**: Track dependencies, progress, discussions

**Location**: In `tasks.md`

**See also**: [User Story ID](#user-story-id-us), [Task Dependencies](#task-dependencies)

---

### {VARIABLE} Syntax
**Syntax**: `{VARIABLE_NAME}` in templates

**Purpose**: Placeholder for customization values in templates

**Example**:
```markdown
# {FEATURE_NAME}

## Overview
{FEATURE_DESCRIPTION}

## Priority
{PRIORITY_LEVEL}
```

**Common Variables**:
- `{FEATURE_NAME}` - Feature title
- `{FEATURE_ID}` - Feature number
- `{PRIORITY_LEVEL}` - P1/P2/P3
- `{PROJECT_NAME}` - Project name
- `{TECH_STACK}` - Technology choices

**Resolution**: Replaced during template instantiation by `/spec generate` or other functions

**See also**: [Template Variable](#template-variable), [Template Customization](#template-customization)

---

### Task Dependencies
**Syntax**: `T002 → T001` (T002 depends on T001)

**Purpose**: Show task execution order requirements

**Example**:
```markdown
T001: Create user model
T002: Create auth service → T001
T003: Create login endpoint → T002
```

**Usage**: Defines task execution order

**Validation**: Circular dependencies caught by `analyze/`

**Location**: In `tasks.md`

---

## Architecture Terms

### ADR (Architecture Decision Record)
**Full Name**: Architecture Decision Record

**Purpose**: Document significant architectural decisions

**Format**:
```markdown
### ADR-001: Use JWT for Authentication

**Context**: Need stateless authentication
**Decision**: Use JWT tokens with refresh mechanism
**Rationale**: Scalability, stateless servers, industry standard
**Consequences**:
- ✅ Scalable across multiple servers
- ✅ No session storage needed
- ⚠️ Token invalidation complexity
```

**Created by**: `plan/` function, `blueprint/` function

**Location**: In `plan.md` or `architecture-blueprint.md`

**Why Important**: Tracks "why" decisions were made for future reference

**See also**: [DECISIONS-LOG.md](#decisions-logmd), [Blueprint](#blueprint)

---

### Blueprint
**Definition**: Project-wide architecture standards and conventions

**Purpose**: Define consistent technical approach across all features

**Artifact**: `architecture-blueprint.md`

**Created by**: `/spec blueprint` function

**Contains**:
- Tech stack decisions
- Design patterns
- API conventions
- Security standards
- Coding standards
- Testing philosophy
- Deployment strategy
- Project-level ADRs

**When to Create**: During Phase 1 (Initialize), especially for new projects

**Updates**: Evolves as project architecture decisions are made

**See also**: [ADR](#adr-architecture-decision-record), [architecture-blueprint.md](#architecture-blueprintmd)

---

### Phase-First Architecture
**Definition**: Architectural approach where workflow phases drive structure

**Principle**: Features progress through phases: Initialize → Generate → Plan → Tasks → Implement

**Benefits**:
- Predictable workflow
- Clear phase transitions
- Consistent artifact structure
- Easy progress tracking

**Contrast**: Task-first (ad-hoc) or documentation-first approaches

**Implementation**: Spec workflow enforces phase progression

**See also**: [Workflow Phases](#workflow-phases), [Progressive Disclosure](#progressive-disclosure)

---

### Progressive Disclosure
**Definition**: Documentation loading strategy that reveals detail only when needed

**Purpose**: Token efficiency - load minimal docs by default, expand on demand

**Levels**:
1. **SKILL.md** (~1,500 tokens) - Core workflow and instructions
2. **EXAMPLES.md** (~3,000 tokens) - Comprehensive usage scenarios
3. **REFERENCE.md** (~2,000 tokens) - Full technical API reference

**Usage**:
```bash
/spec plan                    # Level 1 only
/spec plan --examples         # Level 1 + 2
/spec plan --reference        # Level 1 + 3
```

**Benefits**:
- 81% token reduction (default case)
- Faster execution
- Load detail only when needed
- Scalable documentation

**See also**: [Token Efficiency](#token-efficiency), [Command Syntax](#command-syntax)

---

### Token Efficiency
**Definition**: Optimization strategy to minimize token usage while maintaining functionality

**v3.0 Achievements**:
- 81% reduction in per-skill tokens (6,800 → 1,283)
- 80% reduction in state overhead (10,000 → 2,000)
- 3-5x faster execution

**Techniques**:
1. Progressive disclosure (3-tier docs)
2. Hub caching (state read once)
3. Lazy loading (load on demand)
4. Shared resources (DRY principle)

**Impact**: Enables complex workflows within context limits

**See also**: [Progressive Disclosure](#progressive-disclosure), [Hub Caching](#hub-caching)

---

### API Contract
**Definition**: Formal specification of API endpoints

**Includes**:
- Endpoint paths
- HTTP methods
- Request/response formats
- Authentication requirements
- Error codes

**Example**:
```
POST /api/auth/login
Request: { email: string, password: string }
Response: { token: string, user: UserObject }
Errors: 401 (invalid credentials), 400 (validation)
```

**Created by**: `plan/` function

**Location**: In `plan.md`

---

### Data Model
**Definition**: Structure of database entities and relationships

**Includes**:
- Entity names
- Fields and types
- Relationships
- Constraints
- Indexes

**Example**:
```
User
- id: UUID (primary key)
- email: String (unique, indexed)
- password_hash: String
- created_at: Timestamp
- profile: Profile (1:1 relationship)
```

**Created by**: `plan/` function

**Location**: In `plan.md`

---

## Agent System

### Agent
**Definition**: Autonomous AI worker specialized for complex, multi-step operations

**Purpose**: Handle tasks requiring deep analysis, research, or parallel execution

**Characteristics**:
- Independent decision-making
- Access to full tool suite
- Can invoke other agents
- Persistent context across operations

**Available Agents**:
- `spec-implementer` - Parallel task execution
- `spec-researcher` - Research-backed decisions
- `spec-analyzer` - Deep consistency validation

**Invocation**: Automatically delegated by parent skills, or manual via skill commands

**See also**: [Subagent](#subagent), [Agent Delegation](#agent-delegation)

---

### Subagent
**Definition**: Specialized agent invoked by a parent skill or agent

**Purpose**: Offload complex subtasks requiring specialized expertise

**Relationship**: Parent skill/agent → delegates to → Subagent

**Example Flow**:
```
User: /spec implement
  → implement phase skill
    → delegates to spec-implementer agent
      → executes parallel tasks
      → reports back to skill
```

**Benefits**:
- Separation of concerns
- Specialized expertise
- Parallel execution capability
- Context isolation

**Communication**: Parent passes context, receives results

**See also**: [Agent](#agent), [Agent Delegation](#agent-delegation), [Context Passing](#context-passing)

---

### spec-implementer
**Type**: Subagent

**Parent Skill**: `implement phase`

**Purpose**: Execute implementation tasks with parallel execution and progress tracking

**Capabilities**:
- Parallel task execution (respects [P] markers)
- Dependency resolution
- Progress tracking
- Error recovery
- State updates

**Invocation**: Automatic when `/spec implement` is run

**Configuration**: `SPEC_IMPLEMENT_MAX_PARALLEL` (default: 3)

**Workflow**:
1. Receives task list from `implement phase`
2. Analyzes dependencies
3. Executes tasks in parallel where possible
4. Updates progress in real-time
5. Returns completion status

**See also**: [implement phase](#specimplement), [Agent](#agent), [[P] Marker](#p-parallel-marker)

---

### spec-researcher
**Type**: Subagent

**Parent Skill**: `plan phase`

**Purpose**: Provide research-backed technical decisions and best practices

**Capabilities**:
- Web research for best practices
- Technology comparison
- Security analysis
- Performance considerations
- Industry standard research

**Invocation**: Automatic when `/spec plan` encounters complex architectural decisions

**Workflow**:
1. Receives research questions from `plan phase`
2. Performs web searches
3. Analyzes findings
4. Generates recommendations with citations
5. Returns research summary

**Output**: Research-backed ADRs with sources

**See also**: [plan phase](#specplan), [ADR](#adr-architecture-decision-record)

---

### spec-analyzer
**Type**: Subagent

**Parent Skill**: `analyze phase`

**Purpose**: Deep consistency validation across all artifacts

**Capabilities**:
- Cross-artifact consistency checking
- Dependency validation
- Completeness verification
- Conflict detection
- Quality assessment

**Invocation**: Automatic when `/spec analyze` is run

**Checks**:
- User stories match tasks
- Plan covers all requirements
- No circular dependencies
- All [CLARIFY] tags resolved
- State consistency

**Output**: Detailed validation report with actionable issues

**See also**: [analyze phase](#specanalyze), [Validation](#validation)

---

### Agent Delegation
**Definition**: Process where a skill or agent transfers work to a specialized subagent

**Purpose**: Leverage specialized expertise without bloating parent skill

**Pattern**:
```
Parent Skill
  ├─ Validates input
  ├─ Prepares context
  ├─ Delegates to subagent
  ├─ Receives results
  └─ Processes output
```

**Benefits**:
- Token efficiency (load subagent only when needed)
- Specialized capabilities
- Separation of concerns
- Parallel execution potential

**Common Delegations**:
- `implement phase` → `spec-implementer`
- `plan phase` → `spec-researcher`
- `analyze phase` → `spec-analyzer`

**See also**: [Agent](#agent), [Subagent](#subagent), [Context Passing](#context-passing)

---

### Context Passing
**Definition**: Mechanism for transferring state and information between skills and agents

**Purpose**: Enable subagents to work with necessary context without re-reading files

**Components**:
- Current feature information
- Session state
- Relevant artifacts
- User preferences
- Configuration

**Flow**:
```
Hub → reads state → caches
  → Skill invoked → receives cached state
    → Delegates to subagent → passes context
      → Subagent executes → uses context
        → Returns results → updates state
```

**Benefits**:
- No redundant file reads
- Consistent state
- Token efficiency
- Faster execution

**See also**: [Hub Caching](#hub-caching), [Agent Delegation](#agent-delegation)

---

## Template System

### Template Variable
**Definition**: Placeholder in templates replaced during instantiation

**Syntax**: `{VARIABLE_NAME}`

**Common Variables**:
- `{FEATURE_NAME}` - Feature title
- `{FEATURE_ID}` - Feature number (001, 002, etc.)
- `{PRIORITY_LEVEL}` - P1/P2/P3
- `{PROJECT_NAME}` - Project name
- `{TECH_STACK}` - Technology choices
- `{TIMESTAMP}` - Current date/time
- `{AUTHOR}` - Developer name

**Resolution**: Replaced when template is instantiated by workflow functions

**Example**:
```markdown
# {FEATURE_NAME}
Created: {TIMESTAMP}
Priority: {PRIORITY_LEVEL}
```
becomes:
```markdown
# User Authentication
Created: 2024-01-15
Priority: P1
```

**See also**: [{VARIABLE} Syntax](#variable-syntax), [Template Customization](#template-customization)

---

### Template Customization
**Definition**: Process of adapting templates to project-specific needs

**Location**: `{config.paths.spec_root}/templates/`

**Customizable Templates**:
- `spec-template.md` - Feature specification
- `plan-template.md` - Technical plan
- `tasks-template.md` - Task breakdown
- `adr-template.md` - Architecture Decision Record

**Customization Methods**:
1. Edit template files directly
2. Add project-specific sections
3. Define custom variables
4. Change structure/format

**Example Customization**:
```markdown
# Add project-specific section to spec-template.md

## Compliance Requirements
{COMPLIANCE_NOTES}

## Accessibility Checklist
{A11Y_REQUIREMENTS}
```

**Persistence**: Templates committed to `{config.paths.spec_root}/templates/`, used for all future features

**See also**: [Template Variable](#template-variable), [Auto-loading](#auto-loading)

---

### Auto-loading
**Definition**: Automatic loading of templates and configurations during workflow functions

**Mechanism**: Functions check `{config.paths.spec_root}/templates/` for custom templates, fall back to defaults

**Files Auto-loaded**:
- Template files (spec, plan, tasks)
- Configuration from `CLAUDE.md`
- State files
- Architecture blueprints

**Benefits**:
- No manual template selection
- Consistent project standards
- Seamless customization
- Zero-config for defaults

**Override Hierarchy**:
1. Project-specific template (`{config.paths.spec_root}/templates/`)
2. Plugin default template
3. Built-in fallback

**See also**: [Template Customization](#template-customization), [Template Categories](#template-categories)

---

### Template Categories
**Definition**: Organizational structure for templates by purpose

**Categories**:

1. **artifacts** - Feature artifacts
   - `spec-template.md`
   - `plan-template.md`
   - `tasks-template.md`

2. **project-setup** - Initialization
   - `product-requirements-template.md`
   - `architecture-blueprint-template.md`

3. **quality** - Quality assurance
   - `checklist-template.md`
   - `test-plan-template.md`

4. **integrations** - External systems
   - `jira-sync-template.md`
   - `confluence-page-template.md`

5. **internal** - System use
   - `session-state-template.md`
   - `checkpoint-template.json`

**Location**: Organized in `{config.paths.spec_root}/templates/{category}/`

**Usage**: Functions load from appropriate category automatically

**See also**: [Auto-loading](#auto-loading), [Template Customization](#template-customization)

---

## Project Types

### Greenfield
**Definition**: New project starting from scratch

**Characteristics**:
- No existing code
- Clean slate architecture
- Freedom to choose tech stack
- No legacy constraints

**Workflow**: `init → generate → plan → tasks → implement`

**Considerations**: Must establish all standards and patterns from scratch

---

### Brownfield
**Definition**: Existing project with established codebase

**Characteristics**:
- Significant existing code
- Established patterns and conventions
- Legacy constraints
- Integration with existing systems

**Workflow**: `discover → init → blueprint → generate → plan → tasks → implement`

**Considerations**: Must understand existing architecture before adding features (requires upfront analysis)

**Special Function**: `discover/` - Analyzes existing codebase

---

## Integration Terms

### MCP (Model Context Protocol)
**Full Name**: Model Context Protocol

**Purpose**: Standard for AI-tool integrations

**Examples**:
- JIRA integration
- Confluence integration
- GitHub integration

**Configuration**: In project's `CLAUDE.md` file

**Benefits**: Seamless external system integration

**Used by**: Various workflow functions for syncing

---

### JIRA Integration
**Purpose**: Sync features with JIRA issues/epics

**Configuration**:
```markdown
SPEC_ATLASSIAN_SYNC=enabled
SPEC_JIRA_PROJECT_KEY=PROJ
```

**Features**:
- Auto-create epics from specs
- Link user stories to JIRA tickets
- Sync progress updates

**Used by**: `generate/`, `update/` functions

---

### Confluence Integration
**Purpose**: Publish documentation to Confluence

**Configuration**:
```markdown
SPEC_CONFLUENCE_ROOT_PAGE_ID=123456
```

**Features**:
- Publish specs as Confluence pages
- Auto-update on changes
- Maintain page hierarchy

**Used by**: `generate/`, `plan/`, `update/` functions

**See also**: [MCP](#mcp-model-context-protocol), [Bidirectional Sync](#bidirectional-sync)

---

### Graceful Degradation
**Definition**: Ability to function without optional integrations

**Principle**: Core workflow works without MCP integrations; integrations enhance but don't block

**Behavior**:
- MCP unavailable → workflow continues, skips sync
- JIRA unreachable → local artifacts created, sync attempted later
- Confluence down → documentation saved locally

**Configuration Check**:
```markdown
SPEC_ATLASSIAN_SYNC=enabled  # If MCP available
# No config → graceful degradation, local-only mode
```

**Benefits**:
- No integration dependencies for core workflow
- Resilient to external service failures
- Works offline

**See also**: [Fallback Behavior](#fallback-behavior), [MCP](#mcp-model-context-protocol)

---

### Fallback Behavior
**Definition**: Default action when preferred integration or feature is unavailable

**Examples**:

1. **MCP Integration Unavailable**:
   - Fallback: Create local artifacts only
   - Skip: External sync

2. **Template Not Found**:
   - Fallback: Use built-in default template
   - Skip: Custom formatting

3. **State File Missing**:
   - Fallback: Initialize new state
   - Skip: Resume from checkpoint

**Implementation**: Try preferred approach, catch errors, execute fallback

**User Experience**: Transparent - user may not notice fallback occurred

**See also**: [Graceful Degradation](#graceful-degradation), [Auto-loading](#auto-loading)

---

### Integration Sync
**Definition**: Process of synchronizing Spec artifacts with external systems

**Supported Integrations**:
- JIRA (epics, stories, tasks)
- Confluence (documentation pages)
- GitHub Issues (optional)

**Sync Direction**: Typically unidirectional (Spec → External) or bidirectional with conflict resolution

**Trigger Points**:
- After `generate/` - create epic/stories
- After `plan/` - publish plan to Confluence
- After `tasks/` - create task tickets
- After `implement/` - update task status

**Configuration**: Via `CLAUDE.md` in project root

**See also**: [Bidirectional Sync](#bidirectional-sync), [MCP](#mcp-model-context-protocol)

---

### Bidirectional Sync
**Definition**: Two-way synchronization between Spec artifacts and external systems

**Mechanism**:
- Spec changes → push to external system
- External system changes → pull to Spec (with conflict resolution)

**Conflict Resolution**:
1. Detect conflicts (both changed)
2. Prompt user for resolution
3. Apply chosen resolution
4. Sync resolved state

**Use Cases**:
- JIRA: Tasks updated by team members
- Confluence: Docs edited by stakeholders
- GitHub: Issues created externally

**Configuration**:
```markdown
SPEC_ATLASSIAN_SYNC=enabled
SPEC_SYNC_MODE=bidirectional  # vs unidirectional
SPEC_CONFLICT_RESOLUTION=prompt  # vs auto, manual
```

**See also**: [Integration Sync](#integration-sync), [JIRA Integration](#jira-integration)

---

## Command Syntax

### Function Invocation
**Standard Format**: `/spec function-name`

**Examples**:
- `/spec init`
- `/spec generate "Feature description"`
- `/spec plan`
- `/spec implement`

**With Parameters**:
- `/spec clarify --max-questions=4`
- `/spec implement --continue`
- `/spec tasks --update`

---

### Progressive Disclosure Flags
**Purpose**: Load additional documentation levels

**Flags**:
- `--examples` - Load EXAMPLES.md (~3,000 extra tokens)
- `--reference` - Load REFERENCE.md (~2,000 extra tokens)
- `--verbose` - Detailed execution output

**Examples**:
```bash
/spec plan                    # Guide only (~1,500 tokens)
/spec plan --examples         # Guide + Examples (~4,500 tokens)
/spec plan --reference        # Guide + Reference (~3,500 tokens)
```

**Usage**: Use when you need deeper context

---

### Status Commands
**Purpose**: Check current workflow state

**Commands**:
```bash
/spec status                  # Current phase, feature, progress
/spec metrics                 # Analytics and progress tracking
/spec validate                # Check artifact consistency
```

**Output**: Current state, next recommended action

---

## Quick Lookup

### Most Common Terms

| Term | Short Definition | See Section |
|------|------------------|-------------|
| P1/P2/P3 | Priority levels (Must/Should/Nice) | [Priority Levels](#priority-levels) |
| [CLARIFY] | Ambiguity marker tag | [Markers & Tags](#markers--tags) |
| [P] | Parallel task marker | [Markers & Tags](#markers--tags) |
| ADR | Architecture Decision Record | [Architecture Terms](#architecture-terms) |
| ⭐ CORE | Required workflow function | [Function Types](#function-types) |
| 🔧 TOOL | Optional support function | [Function Types](#function-types) |
| spec.md | Feature specification file | [File Artifacts](#file-artifacts) |
| plan.md | Technical design file | [File Artifacts](#file-artifacts) |
| tasks.md | Task breakdown file | [File Artifacts](#file-artifacts) |
| {config.paths.state}/ | Session state directory | [State Management](#state-management) |
| {config.paths.memory}/ | Persistent memory directory | [State Management](#state-management) |
| Agent | Autonomous AI worker | [Agent System](#agent-system) |
| Subagent | Specialized delegated agent | [Agent System](#agent-system) |
| Greenfield | New project from scratch | [Project Types](#project-types) |
| Brownfield | Existing codebase | [Project Types](#project-types) |
| MCP | Model Context Protocol | [Integration Terms](#integration-terms) |
| Progressive Disclosure | Lazy-loading documentation | [Architecture Terms](#architecture-terms) |
| Hub Caching | State caching optimization | [State Management](#state-management) |

---

## Term Index (Alphabetical)

- **{VARIABLE} Syntax**: [Markers & Tags](#markers--tags)
- **[CLARIFY]**: [Markers & Tags](#markers--tags)
- **[P] Parallel Marker**: [Markers & Tags](#markers--tags)
- **{config.paths.memory}/**: [State Management](#state-management)
- **{config.paths.state}/**: [State Management](#state-management)
- **ADR**: [Architecture Terms](#architecture-terms)
- **Agent**: [Agent System](#agent-system)
- **Agent Delegation**: [Agent System](#agent-system)
- **API Contract**: [Architecture Terms](#architecture-terms)
- **Architecture Blueprint**: [File Artifacts](#file-artifacts)
- **Auto-loading**: [Template System](#template-system)
- **Bidirectional Sync**: [Integration Terms](#integration-terms)
- **Blueprint**: [Architecture Terms](#architecture-terms)
- **Brownfield**: [Project Types](#project-types)
- **CHANGES-COMPLETED.md**: [State Management](#state-management)
- **CHANGES-PLANNED.md**: [State Management](#state-management)
- **Checkpoint**: [State Management](#state-management)
- **Confluence Integration**: [Integration Terms](#integration-terms)
- **Context Passing**: [Agent System](#agent-system)
- **CORE Functions**: [Function Types](#function-types)
- **current-session.md**: [State Management](#state-management)
- **Data Model**: [Architecture Terms](#architecture-terms)
- **DECISIONS-LOG.md**: [State Management](#state-management)
- **Epic Priority**: [Priority Levels](#priority-levels)
- **Fallback Behavior**: [Integration Terms](#integration-terms)
- **Graceful Degradation**: [Integration Terms](#integration-terms)
- **Greenfield**: [Project Types](#project-types)
- **Hub Caching**: [State Management](#state-management)
- **Integration Sync**: [Integration Terms](#integration-terms)
- **JIRA Integration**: [Integration Terms](#integration-terms)
- **MCP**: [Integration Terms](#integration-terms)
- **P1/P2/P3**: [Priority Levels](#priority-levels)
- **Persistent Memory**: [State Management](#state-management)
- **Phase 1-5**: [Workflow Phases](#workflow-phases)
- **Phase-First Architecture**: [Architecture Terms](#architecture-terms)
- **plan.md**: [File Artifacts](#file-artifacts)
- **Progressive Disclosure**: [Architecture Terms](#architecture-terms)
- **Session State**: [State Management](#state-management)
- **spec-analyzer**: [Agent System](#agent-system)
- **spec-implementer**: [Agent System](#agent-system)
- **spec-researcher**: [Agent System](#agent-system)
- **spec.md**: [File Artifacts](#file-artifacts)
- **State Transitions**: [State Management](#state-management)
- **Subagent**: [Agent System](#agent-system)
- **Task Dependencies**: [Markers & Tags](#markers--tags)
- **Task ID (T###)**: [Markers & Tags](#markers--tags)
- **tasks.md**: [File Artifacts](#file-artifacts)
- **Template Categories**: [Template System](#template-system)
- **Template Customization**: [Template System](#template-system)
- **Template Variable**: [Template System](#template-system)
- **Token Efficiency**: [Architecture Terms](#architecture-terms)
- **TOOL Functions**: [Function Types](#function-types)
- **User Story ID (US#)**: [Markers & Tags](#markers--tags)
- **WORKFLOW-PROGRESS.md**: [State Management](#state-management)

---

## Related Resources

- **Quick Start**: `quick-start.md` - Get started in 5 commands
- **Error Recovery**: `error-recovery.md` - Troubleshooting guide
- **Workflow Map**: `navigation/workflow-map.md` - Visual workflow guide
- **Review**: `workflow-review.md` - Comprehensive analysis

---

**Can't find a term?**

Ask Claude: "What does [term] mean in the Spec workflow?"

Or read the full documentation in the relevant phase README or function guide.
