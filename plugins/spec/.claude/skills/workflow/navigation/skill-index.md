# Skill Index

Quick reference to all 13 workflow skills organized by category and phase.

## By Phase

### Phase 1: Initialize
| Skill | Type | Purpose | Duration | Location |
|-------|------|---------|----------|----------|
| **spec:init** | ⭐ CORE | Initialize workflow structure | 15-30m | `phases/1-initialize/init/guide.md` |
| **spec:discover** | 🔧 TOOL | Analyze existing codebase (brownfield) | 30-60m | `phases/1-initialize/discover/guide.md` |
| **spec:blueprint** | 🔧 TOOL | Define architecture standards | 45-90m | `phases/1-initialize/blueprint/guide.md` |

### Phase 2: Define Requirements
| Skill | Type | Purpose | Duration | Location |
|-------|------|---------|----------|----------|
| **spec:generate** | ⭐ CORE | Create feature specifications | 20-45m | `phases/2-define/generate/guide.md` |
| **spec:clarify** | 🔧 TOOL | Resolve ambiguities | 10-30m | `phases/2-define/clarify/guide.md` |
| **spec:checklist** | 🔧 TOOL | Validate requirement quality | 15-30m | `phases/2-define/checklist/guide.md` |

### Phase 3: Design Solution
| Skill | Type | Purpose | Duration | Location |
|-------|------|---------|----------|----------|
| **spec:plan** | ⭐ CORE | Create technical design | 30-90m | `phases/3-design/plan/guide.md` |
| **spec:analyze** | 🔧 TOOL | Validate consistency | 10-20m | `phases/3-design/analyze/guide.md` |

### Phase 4: Build Feature
| Skill | Type | Purpose | Duration | Location |
|-------|------|---------|----------|----------|
| **spec:tasks** | ⭐ CORE | Break down into tasks | 20-45m | `phases/4-build/tasks/guide.md` |
| **spec:implement** | ⭐ CORE | Execute implementation | 2-20h | `phases/4-build/implement/guide.md` |

### Phase 5: Track Progress
| Skill | Type | Purpose | Duration | Location |
|-------|------|---------|----------|----------|
| **spec:update** | 🔧 TOOL | Modify specifications | 15-45m | `phases/5-track/update/guide.md` |
| **spec:metrics** | 🔧 TOOL | View progress analytics | 2-5m | `phases/5-track/metrics/guide.md` |
| **spec:orchestrate** | 🔧 TOOL | Automate full workflow | 3-25h | `phases/5-track/orchestrate/guide.md` |

## By Category

### ⭐ Core Workflow (Required, Sequential)
1. **spec:init** - Setup → `.spec/` structure
2. **spec:generate** - Define → `spec.md`
3. **spec:plan** - Design → `plan.md`
4. **spec:tasks** - Task → `tasks.md`
5. **spec:implement** - Build → Working feature

**6 total core functions** (init, generate, plan, tasks, implement + implement as second Phase 4 core)

### 🔧 Supporting Tools (Optional, Contextual)

**Phase 1 Tools**:
- **spec:discover** - Codebase analysis (brownfield only)
- **spec:blueprint** - Architecture definition (documentation)

**Phase 2 Tools**:
- **spec:clarify** - Resolve ambiguities (when [CLARIFY] tags present)
- **spec:checklist** - Quality gates (enterprise/compliance)

**Phase 3 Tools**:
- **spec:analyze** - Validation (complex features, pre-implementation)

**Phase 5 Tools** (all tools, no core):
- **spec:update** - Requirement changes (ongoing)
- **spec:metrics** - Progress tracking (ongoing)
- **spec:orchestrate** - Full automation (alternative to manual workflow)

**7 total supporting tools** (discover, blueprint, clarify, checklist, analyze, update, metrics, orchestrate)

## By Use Case

### Starting New Project
```
spec:init → spec:blueprint → spec:generate
```

### Analyzing Existing Codebase
```
spec:discover → spec:init → spec:blueprint
```

### Building Feature
```
spec:generate → spec:clarify → spec:plan → spec:tasks → spec:implement
```

### Automating Workflow
```
spec:orchestrate (runs: generate → clarify → plan → tasks → implement)
```

### Changing Requirements
```
spec:update → spec:analyze → spec:tasks --update
```

### Tracking Progress
```
spec:metrics (view analytics anytime)
```

## Skill Details

### spec:init
**Purpose**: Initialize Spec workflow in project
**When**: Starting new project or adding Spec to existing code
**Tools**: Read, Write, Bash, Grep
**Inputs**: None (detects project type)
**Outputs**: `.spec/`, `.spec-state/`, `.spec-memory/`
**Next**: spec:discover (brownfield) or spec:blueprint (greenfield)

### spec:discover
**Purpose**: Analyze existing codebase architecture and patterns
**When**: Brownfield projects, onboarding, refactoring planning
**Tools**: Read, Grep, Bash (uses spec:analyzer subagent)
**Inputs**: Existing codebase, JIRA config (optional)
**Outputs**: `discovery/` reports, architecture insights
**Next**: spec:init, then spec:blueprint

### spec:blueprint
**Purpose**: Define project architecture and technical standards
**When**: Need architecture documentation, team alignment
**Tools**: Read, Write, Edit, WebSearch, Bash
**Inputs**: `.spec/`, discovery reports (optional)
**Outputs**: `.spec/architecture-blueprint.md`, ADRs
**Next**: spec:generate (start features)

### spec:generate
**Purpose**: Create feature specifications with user stories
**When**: Starting new feature development
**Tools**: Read, Write, Edit, AskUserQuestion, WebSearch, Bash
**Inputs**: Feature description, product requirements
**Outputs**: `features/NNN-name/spec.md`, user stories (P1/P2/P3)
**Next**: spec:clarify (if [CLARIFY] tags) or spec:plan

### spec:clarify
**Purpose**: Resolve ambiguities and vague requirements
**When**: [CLARIFY] tags present, vague terms detected
**Tools**: Read, Edit, AskUserQuestion
**Inputs**: `spec.md` with ambiguities
**Outputs**: Clarified `spec.md`, decision log
**Next**: spec:checklist (validation) or spec:plan

### spec:checklist
**Purpose**: Validate requirement quality with domain checklists
**When**: Quality gates, enterprise compliance, pre-planning
**Tools**: Read, Write
**Inputs**: `spec.md`
**Outputs**: `checklists/` (ux.md, api.md, security.md, performance.md)
**Next**: Review checklists, then spec:plan

### spec:plan
**Purpose**: Create technical design with architecture decisions
**When**: Have approved specification
**Tools**: Read, Write, Edit, WebSearch, Bash (uses spec:researcher)
**Inputs**: `spec.md`, architecture blueprint
**Outputs**: `plan.md`, ADRs, technical approach
**Next**: spec:analyze (validation) or spec:tasks

### spec:analyze
**Purpose**: Validate consistency across spec/plan/tasks
**When**: Before implementation, after updates, complex features
**Tools**: Read, Grep, Bash (uses spec:analyzer subagent)
**Inputs**: `spec.md`, `plan.md`, `tasks.md` (if exists)
**Outputs**: Analysis report with CRITICAL/HIGH/MEDIUM/LOW issues
**Next**: Fix issues or proceed to spec:tasks

### spec:tasks
**Purpose**: Break down plan into executable tasks
**When**: Technical plan complete
**Tools**: Read, Write, Edit, Bash
**Inputs**: `plan.md`, `spec.md`
**Outputs**: `tasks.md` with task IDs, priorities, dependencies
**Next**: spec:implement

### spec:implement
**Purpose**: Execute implementation tasks with progress tracking
**When**: Tasks defined in tasks.md
**Tools**: Read, Write, Edit (delegates to spec:implementer subagent)
**Inputs**: `tasks.md`
**Outputs**: Working feature, test results, completed tasks
**Next**: New feature or spec:metrics

### spec:update
**Purpose**: Modify existing specifications
**When**: Requirements change, add/remove stories, priority shifts
**Tools**: Read, Write, Edit, AskUserQuestion, WebSearch, Bash
**Inputs**: `spec.md`, change description
**Outputs**: Updated `spec.md`, `plan.md`, `tasks.md`, migration plan
**Next**: spec:analyze → spec:tasks --update

### spec:metrics
**Purpose**: View development analytics and progress
**When**: Need progress report, sprint planning, process optimization
**Tools**: Read, Bash
**Inputs**: `.spec-memory/WORKFLOW-PROGRESS.md`
**Outputs**: Analytics dashboard, CSV/JSON exports
**Next**: Use insights to optimize workflow

### spec:orchestrate
**Purpose**: Automate complete workflow from spec to implementation
**When**: Want full automation, quick prototyping
**Tools**: Read, Write, Edit, AskUserQuestion
**Inputs**: Feature description
**Outputs**: Complete feature (all artifacts + implementation)
**Next**: Review implementation, create PR

## Progressive Disclosure

Each skill has 3 documentation levels:

**Level 1: SKILL.md** (~1,500 tokens)
- Core workflow and execution steps
- Load this first for basic understanding

**Level 2: EXAMPLES.md** (~3,000 tokens)
- Concrete usage scenarios
- Load when you need patterns and examples

**Level 3: REFERENCE.md** (~2,000 tokens)
- Technical specifications and APIs
- Load for deep dive and edge cases

**Total per skill**: ~6,500 tokens
**Smart loading**: Only load what you need when you need it

## Navigation Tips

**Need overview?** → Load `navigation/workflow-map.md`
**Need phase details?** → Load `phases/[N]-[name]/README.md`
**Need skill details?** → Load `phases/[N]-[name]/[function]/guide.md`
**Need examples?** → Load `phases/[N]-[name]/[function]/examples.md`
**Need specs?** → Load `phases/[N]-[name]/[function]/reference.md`

**Token efficiency**:
- Start with phase README.md (~500 tokens)
- Load function guide.md when needed (~1,500 tokens)
- Load examples.md only if stuck (~3,000 tokens)
- Load reference.md only for edge cases (~2,000 tokens)

---

**Total skills**: 13
**Total documentation**: ~84,500 tokens (if all loaded)
**Smart navigation**: ~300-2,000 tokens (context-aware loading)
