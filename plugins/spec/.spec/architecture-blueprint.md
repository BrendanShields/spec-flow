# Architecture Blueprint: Spec Plugin

**Status**: Active | **Version**: 3.3.0 | **Updated**: 2025-11-03

This document defines **HOW** we build the Spec plugin. Features reference this for guidance (peer artifact, not enforced but strongly recommended).

---

## Core Principles

### Principle 1: Human Oversight Required
**Guideline**: Never proceed through workflow without explicit user confirmation via AskUserQuestion
**Rationale**: Ensures users maintain control, can review/refine at each step, prevents runaway automation
**Application**: 45+ checkpoints throughout workflow, every phase/story/task has checkpoint before/after

### Principle 2: State Over Configuration
**Guideline**: Workflow state drives behavior, not hard-coded logic
**Rationale**: Enables resumption, context-aware menus, flexible workflows
**Application**: Dual-layer state (session + memory), state detection before every menu, graceful fallback

### Principle 3: Progressive Disclosure
**Guideline**: Load detail on-demand (guide → examples → reference)
**Rationale**: Minimizes token usage, keeps context focused, improves performance
**Application**: Base guides < 1,500 tokens, examples/reference loaded separately, conditional TDD loading

### Principle 4: Documentation as Single Source of Truth
**Guideline**: Docs describe actual system, not aspirational features
**Rationale**: Reduces confusion, ensures reliability, builds trust
**Application**: Documentation updated before code, no features documented until implemented

---

## Architecture Patterns

**Overall Style**: Layered Architecture with Command-State-Guide pattern
**Rationale**: Clear separation of concerns, testable components, extensible design

**Layers**:
| Layer | Responsibility | Exposes | Dependencies |
|-------|---|---|---|
| **Command Layer** | User interaction, menu presentation | /workflow:spec, /workflow:track | State Layer, Guide Layer |
| **State Layer** | Workflow position tracking | current-session.md, memory files | File system, Config |
| **Guide Layer** | Phase execution logic | 13 phase guides | Tools (Read, Write, Edit, Bash) |
| **Template Layer** | Artifact generation | Templates for spec/plan/tasks/state | None |
| **Agent Layer** | Complex task delegation | spec-implementer, spec-researcher, spec-analyzer | Guide Layer |

**Communication**:
- Sync: Commands → State (read current-session.md) → Menus → User → Guide execution
- State Updates: Guide → Write → State files (current-session.md, memory/)
- No async or real-time components

---

## Data Flow

```
User Input
  ↓
/workflow:spec command
  ↓
[Step 1] Check .spec/ directory exists
  ↓
[Step 2] Read .spec/state/current-session.md (State Layer)
  ↓
[Step 3] Parse YAML frontmatter (feature, phase, progress)
  ↓
[Step 4] Determine context-aware menu options
  ↓
[Step 5] Present AskUserQuestion menu
  ↓
User selects option
  ↓
[Step 6] Load corresponding phase guide (Guide Layer)
  ↓
[Step 7] Execute guide instructions (Tools: Read, Write, Edit, Bash)
  ↓
[Step 8] Update state files (Write to current-session.md, memory/)
  ↓
[Step 9] Checkpoint: AskUserQuestion for next step
  ↓
[Loop back to Step 2 or Exit]
```

---

## Technology Stack

| Layer | Component | Version | Why |
|-------|-----------|---------|-----|
| **Language** | Markdown | CommonMark | Declarative, readable, version-controllable |
| | YAML | 1.2 | Config + frontmatter, human-editable |
| | TypeScript | 5.x | Hooks only (optional), type safety |
| **Runtime** | Claude Code | Latest | Plugin host environment |
| **Storage** | File System | - | Git-friendly, no database needed |
| | Templates | Markdown | Artifact generation, customizable |
| **State** | YAML + Markdown | - | Dual format: frontmatter + body |
| **Tools** | Read/Write/Edit | Claude Code | File operations |
| | Bash | System | Git, file operations, external tools |
| | AskUserQuestion | Claude Code | Interactive menus, checkpoints |

---

## Component Architecture

### Command Layer (.claude/commands/)

**Components**:
- `workflow:spec.md` (398 lines) - Main workflow command, context-aware menus
- `workflow:track.md` (426 lines) - Metrics and maintenance command

**Responsibilities**:
1. Detect workflow state (read .spec/state/current-session.md)
2. Present context-appropriate menus (AskUserQuestion)
3. Route to phase guides based on user selection
4. Manage auto-mode orchestration with checkpoints

**State Machine**:
```
Not Initialized → [Initialize] → No Active Feature
No Active Feature → [Define] → Specification Phase
Specification → [Plan] → Planning Phase
Planning → [Tasks] → Implementation Phase (Task Breakdown)
Implementation (Tasks) → [Implement] → Implementation Phase (Execution)
Implementation (Execution) → [Validate] → Complete
Complete → [New Feature] → No Active Feature
```

### State Layer (.spec/state/, .spec/memory/)

**Components**:
- `current-session.md` (session-specific, git-ignored) - Active feature, phase, progress
- `WORKFLOW-PROGRESS.md` (persistent, committed) - Feature list, metrics
- `DECISIONS-LOG.md` (persistent, committed) - ADRs, architectural decisions
- `CHANGES-PLANNED.md` (persistent, committed) - Pending tasks from all features
- `CHANGES-COMPLETED.md` (persistent, committed) - Completed work, audit trail

**Format**:
```yaml
---
feature: 001-feature-name
phase: planning
started: 2025-11-03T00:00:00Z
last_updated: 2025-11-03T01:30:00Z
---

# Markdown Body

Current details, progress, notes
```

**Update Protocol**:
- Atomic updates (write entire file)
- Update after every phase transition
- Update after every significant milestone
- Include timestamp on every update

### Guide Layer (.claude/skills/workflow/phases/)

**Structure**:
```
phases/
├── 1-initialize/
│   ├── init/guide.md         (Setup .spec/, state, memory)
│   ├── discover/guide.md     (Brownfield analysis)
│   └── blueprint/guide.md    (Architecture docs)
├── 2-define/
│   ├── generate/guide.md     (Create spec.md)
│   ├── clarify/guide.md      (Resolve [CLARIFY] tags)
│   └── checklist/guide.md    (Quality validation)
├── 3-design/
│   ├── plan/guide.md         (Create plan.md)
│   └── analyze/guide.md      (Consistency validation)
├── 4-build/
│   ├── tasks/guide.md        (Create tasks.md)
│   └── implement/guide.md    (Execute implementation)
└── 5-track/
    ├── metrics/guide.md      (View progress)
    ├── update/guide.md       (Modify specs)
    └── orchestrate/guide.md  (Full automation)
```

**Guide Format**:
- Frontmatter: model, allowed-tools, description
- Implementation section: Step-by-step instructions
- No state reading (state passed from command as context)
- Size target: < 1,500 tokens per guide

### Template Layer (.claude/skills/workflow/templates/)

**Components**:
- `artifacts/spec-template.md` - User story format, acceptance criteria
- `artifacts/plan-template.md` - Technical design structure
- `artifacts/tasks-template.md` - Task breakdown format
- `state/*.template` - State file templates (current-session, memory files)
- `project-setup/*.template` - PRD, Blueprint templates

**Usage**: Copy template → Fill placeholders → Write to feature directory

### Agent Layer (.claude/agents/)

**Components**:
- `spec-implementer/` - Parallel task execution, progress tracking
- `spec-researcher/` - Research-backed decision making, ADR generation
- `spec-analyzer/` - Deep consistency validation, pattern extraction

**Delegation Pattern**:
```
Guide detects complex task
  ↓
Guide invokes Task tool with subagent_type
  ↓
Agent receives task context + tools
  ↓
Agent executes autonomously (no human in loop)
  ↓
Agent returns completion report to guide
  ↓
Guide presents results + checkpoint to user
```

---

## Configuration System

**File**: `.claude/.spec-config.yml`

**Structure**:
```yaml
version: "3.3.0"
paths:
  spec_root: ".spec"              # Root directory
  features: "features"            # Relative to spec_root
  state: "state"                  # Relative to spec_root
  memory: "{state}/memory"        # Variable interpolation
naming:
  feature_directory: "{id:000}-{slug}"  # Template syntax
  files:
    spec: "spec.md"
    plan: "plan.md"
    tasks: "tasks.md"
```

**Path Resolution**:
1. Simple relative paths resolve relative to spec_root
2. Variable interpolation: `{state}` → resolved path value
3. Explicit paths (starting with `.` or `/`) used as-is

---

## Integration Points

### Git Integration
- State files (.spec/state/) are git-ignored (session-specific)
- Memory files (.spec/memory/) are committed (persistent history)
- Feature artifacts (spec/plan/tasks) are committed
- Hooks can trigger git operations (optional)

### Hook System (Optional)
- TypeScript hooks in `.claude/hooks/`
- Auto-detection on init (finds package managers, tools)
- Session hooks (startup, restore, cleanup)
- Tool hooks (pre/post Read, Write, Edit, Bash)

### External Tools (Future)
- JIRA sync (bidirectional issue tracking)
- Confluence sync (documentation updates)
- Deferred to v3.4+

---

## Security & Performance

**Security**:
- No secrets in templates or state files (use environment variables)
- Input validation on user-provided feature names (sanitize for file paths)
- Bash operations use safe quoting and validation
- No eval or code execution from user input

**Performance**:
- P50: < 2,000 tokens per phase (target: 1,500)
- P95: < 2,500 tokens per phase
- P99: < 3,500 tokens per phase (with examples)
- Worst-case: 40,000 tokens (full context with all references)

**Token Optimization**:
- Progressive disclosure (guide → examples → reference)
- State caching (read once per invocation)
- Conditional loading (TDD only when enabled)
- Link over duplicate (blueprint examples → template link)

**Testing**:
- Manual workflow validation (5 test scenarios)
- Token measurement via token counter
- grep validation (deprecated references = 0)
- State file structure validation

---

## Operations

**Deployment**:
1. Update plugin files in `.claude/`
2. Update templates in `.claude/skills/workflow/templates/`
3. Update CLAUDE.md with any new patterns
4. Validate with test scenarios
5. Tag version in git
6. Update plugin marketplace entry

**Rollback**:
- Git revert specific files (isolated changes)
- State files preserved (users can continue work)
- Document breaking changes in CHANGELOG.md

**Monitoring**:
- No runtime monitoring (offline plugin)
- User feedback via GitHub issues
- Token usage self-reported in analysis reports

**Alerting**: N/A (offline tool, no real-time alerts)

---

## ADRs (Architecture Decision Records)

### ADR-001: State Passed from Commands, Not Re-Read in Guides
**Status**: Accepted | **Date**: 2025-11-03
**Context**: Guides were reading state files redundantly, wasting ~400 tokens per phase
**Decision**: Commands read state once, pass to guides as context
**Rationale**: Eliminates redundancy, aligns with documented architecture, improves performance

### ADR-002: Progressive Disclosure via File Extraction
**Status**: Accepted | **Date**: 2025-11-03
**Context**: Guides loading conditional content (TDD, hooks) even when not needed
**Decision**: Extract to separate files, load on-demand
**Rationale**: Base guides stay lean, users get detail only when requested, ~3,200 token savings

### ADR-003: Template Links over Duplication
**Status**: Accepted | **Date**: 2025-11-03
**Context**: blueprint/examples.md duplicating 15K token template
**Decision**: Replace with link to templates/ directory
**Rationale**: Single source of truth, 91% token savings, users get same info via link

### ADR-004: Commands Directly Load Guides (No Dispatcher)
**Status**: Accepted | **Date**: 2025-11-03
**Context**: Commands reference "workflow skill" but no dispatcher exists
**Decision**: Commands directly Read phase guides (no abstraction layer)
**Rationale**: Simpler implementation, matches current reality, can add dispatcher later if needed

### ADR-005: Dual-Layer State Management (Session + Memory)
**Status**: Accepted | **Date**: 2025-11-03
**Context**: Need session-specific state AND persistent history
**Decision**: .spec/state/ git-ignored (session), .spec/memory/ committed (persistent)
**Rationale**: Session state enables resumption, memory provides audit trail, git-ignored prevents conflicts

### ADR-006: AskUserQuestion Checkpoints Mandatory
**Status**: Accepted | **Date**: 2025-11-03
**Context**: Users need oversight and control over workflow automation
**Decision**: 45+ checkpoints throughout workflow, never proceed without user confirmation
**Rationale**: Prevents runaway automation, enables review/refine, builds user trust

### ADR-007: Phase 0 Guard for PRD and Blueprint
**Status**: Accepted | **Date**: 2025-11-03
**Context**: Implementation proceeding without proper governance documents
**Decision**: Phase 0 MUST create PRD and Blueprint before any other work
**Rationale**: Ensures architectural oversight, provides reference for all decisions, maintains quality

---

**Related**:
- Product Requirements: `.spec/product-requirements.md` (WHAT and WHY)
- Feature Spec: `.spec/features/001-comprehensive-refactoring/spec.md` (detailed requirements)
- Implementation Plan: `.spec/features/001-comprehensive-refactoring/plan.md` (execution strategy)
- Configuration: `.claude/.spec-config.yml` (runtime configuration)
- Analysis: `COMPREHENSIVE-ANALYSIS.md`, `UX-ANALYSIS.md` (technical findings)
