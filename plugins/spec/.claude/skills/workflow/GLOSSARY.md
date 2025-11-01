# Workflow Terminology Glossary

**Quick reference for all Spec workflow terms and concepts**

---

## Table of Contents

1. [Priority Levels](#priority-levels)
2. [Workflow Phases](#workflow-phases)
3. [Function Types](#function-types)
4. [File Artifacts](#file-artifacts)
5. [State Management](#state-management)
6. [Markers & Tags](#markers--tags)
7. [Architecture Terms](#architecture-terms)
8. [Project Types](#project-types)
9. [Integration Terms](#integration-terms)
10. [Command Syntax](#command-syntax)

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

---

## Workflow Phases

### Phase 1: Initialize
**Purpose**: Set up project structure and define architecture

**Entry**: New project or first-time Spec setup

**Functions**: init ⭐, discover 🔧, blueprint 🔧

**Output**:
- `.spec/` directory structure
- State tracking initialized
- Architecture documented (optional)

**Exit**: Ready to create first feature

**Duration**: 1-2 hours (one-time per project)

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

**Duration**: 30 minutes - 2 hours per feature

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

**Duration**: 45 minutes - 3 hours per feature

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

**Duration**: 2-20 hours per feature (varies by complexity)

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

**Duration**: Ongoing throughout project

---

## Function Types

### ⭐ CORE (Core Workflow Function)
**Definition**: Required sequential workflow function

**Characteristics**:
- Must run in specific order
- Forms backbone of workflow
- Cannot skip (except in orchestrate mode)

**Examples**: init, generate, plan, tasks, implement (6 total)

**Usage**: Follow sequence: init → generate → plan → tasks → implement

**Visual**: Marked with ⭐ in phase READMEs

---

### 🔧 TOOL (Supporting Tool Function)
**Definition**: Optional contextual support function

**Characteristics**:
- Run as needed based on context
- Not required for basic workflow
- Enhance or validate core workflow
- Can run multiple times

**Examples**: discover, clarify, analyze, update (7 total)

**Usage**: Use when context requires (brownfield, ambiguity, validation, changes)

**Visual**: Marked with 🔧 in phase READMEs

---

## File Artifacts

### spec.md
**Location**: `features/###-feature-name/spec.md`

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
**Location**: `features/###-feature-name/plan.md`

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
**Location**: `features/###-feature-name/tasks.md`

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
**Location**: `.spec/product-requirements.md`

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
**Location**: `.spec/architecture-blueprint.md`

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

### Session State
**Location**: `.spec-state/`

**Purpose**: Track current session progress

**Git Status**: Git-ignored (temporary, not committed)

**Files**:
- `current-session.md` - Active feature, current phase
- `checkpoints/` - Periodic state snapshots

**Lifespan**: Single development session

**Contains**:
- Current feature ID
- Current phase
- Task progress
- Last command run
- Session start time

**Why Git-Ignored**: Session-specific, not relevant to other developers

---

### Persistent Memory
**Location**: `.spec-memory/`

**Purpose**: Project-wide persistent state

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

**Why Committed**: Team knowledge, project history

---

### State Transitions
**Flow**: init → initialized → specification → planning → tasking → implementation → complete

**Tracked in**: `.spec-state/current-session.md`

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

## Project Types

### Greenfield
**Definition**: New project starting from scratch

**Characteristics**:
- No existing code
- Clean slate architecture
- Freedom to choose tech stack
- No legacy constraints

**Workflow**: `init → generate → plan → tasks → implement`

**Duration**: Typically faster (no existing code analysis)

**Considerations**: Must establish all standards and patterns

---

### Brownfield
**Definition**: Existing project with established codebase

**Characteristics**:
- Significant existing code
- Established patterns and conventions
- Legacy constraints
- Integration with existing systems

**Workflow**: `discover → init → blueprint → generate → plan → tasks → implement`

**Duration**: +2-3 hours for analysis upfront

**Considerations**: Must understand existing architecture before adding features

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
| ADR | Architecture Decision Record | [Architecture Terms](#architecture-terms) |
| ⭐ CORE | Required workflow function | [Function Types](#function-types) |
| 🔧 TOOL | Optional support function | [Function Types](#function-types) |
| spec.md | Feature specification file | [File Artifacts](#file-artifacts) |
| plan.md | Technical design file | [File Artifacts](#file-artifacts) |
| tasks.md | Task breakdown file | [File Artifacts](#file-artifacts) |
| Greenfield | New project from scratch | [Project Types](#project-types) |
| Brownfield | Existing codebase | [Project Types](#project-types) |
| MCP | Model Context Protocol | [Integration Terms](#integration-terms) |

---

## Term Index (Alphabetical)

- **[CLARIFY]**: [Markers & Tags](#markers--tags)
- **[P] Parallel Marker**: [Markers & Tags](#markers--tags)
- **ADR**: [Architecture Terms](#architecture-terms)
- **API Contract**: [Architecture Terms](#architecture-terms)
- **Architecture Blueprint**: [File Artifacts](#file-artifacts)
- **Brownfield**: [Project Types](#project-types)
- **CORE Functions**: [Function Types](#function-types)
- **Data Model**: [Architecture Terms](#architecture-terms)
- **Greenfield**: [Project Types](#project-types)
- **JIRA Integration**: [Integration Terms](#integration-terms)
- **MCP**: [Integration Terms](#integration-terms)
- **P1/P2/P3**: [Priority Levels](#priority-levels)
- **Phase 1-5**: [Workflow Phases](#workflow-phases)
- **plan.md**: [File Artifacts](#file-artifacts)
- **Session State**: [State Management](#state-management)
- **spec.md**: [File Artifacts](#file-artifacts)
- **Task Dependencies**: [Markers & Tags](#markers--tags)
- **tasks.md**: [File Artifacts](#file-artifacts)
- **TOOL Functions**: [Function Types](#function-types)

---

## Related Resources

- **Quick Start**: `QUICK-START.md` - Get started in 5 commands
- **Error Recovery**: `ERROR-RECOVERY.md` - Troubleshooting guide
- **Workflow Map**: `navigation/workflow-map.md` - Visual workflow guide
- **Review**: `WORKFLOW-REVIEW.md` - Comprehensive analysis

---

**Can't find a term?**

Ask Claude: "What does [term] mean in the Spec workflow?"

Or read the full documentation in the relevant phase README or function guide.
