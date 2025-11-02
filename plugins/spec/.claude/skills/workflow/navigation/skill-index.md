# Skill Index

Quick reference to all 13 workflow skills organized by category and phase.

## By Phase

### Phase 1: Initialize
| Skill | Type | Purpose | Duration | Location |
|-------|------|---------|----------|----------|
| **initialize phase** | ⭐ CORE | Initialize workflow structure | 15-30m | `phases/1-initialize/init/guide.md` |
| **discover phase** | 🔧 TOOL | Analyze existing codebase (brownfield) | 30-60m | `phases/1-initialize/discover/guide.md` |
| **blueprint phase** | 🔧 TOOL | Define architecture standards | 45-90m | `phases/1-initialize/blueprint/guide.md` |

### Phase 2: Define Requirements
| Skill | Type | Purpose | Duration | Location |
|-------|------|---------|----------|----------|
| **generate phase** | ⭐ CORE | Create feature specifications | 20-45m | `phases/2-define/generate/guide.md` |
| **clarify phase** | 🔧 TOOL | Resolve ambiguities | 10-30m | `phases/2-define/clarify/guide.md` |
| **checklist phase** | 🔧 TOOL | Validate requirement quality | 15-30m | `phases/2-define/checklist/guide.md` |

### Phase 3: Design Solution
| Skill | Type | Purpose | Duration | Location |
|-------|------|---------|----------|----------|
| **plan phase** | ⭐ CORE | Create technical design | 30-90m | `phases/3-design/plan/guide.md` |
| **analyze phase** | 🔧 TOOL | Validate consistency | 10-20m | `phases/3-design/analyze/guide.md` |

### Phase 4: Build Feature
| Skill | Type | Purpose | Duration | Location |
|-------|------|---------|----------|----------|
| **tasks phase** | ⭐ CORE | Break down into tasks | 20-45m | `phases/4-build/tasks/guide.md` |
| **implement phase** | ⭐ CORE | Execute implementation | 2-20h | `phases/4-build/implement/guide.md` |

### Phase 5: Track Progress
| Skill | Type | Purpose | Duration | Location |
|-------|------|---------|----------|----------|
| **update phase** | 🔧 TOOL | Modify specifications | 15-45m | `phases/5-track/update/guide.md` |
| **metrics phase** | 🔧 TOOL | View progress analytics | 2-5m | `phases/5-track/metrics/guide.md` |
| **orchestrate phase** | 🔧 TOOL | Automate full workflow | 3-25h | `phases/5-track/orchestrate/guide.md` |

## By Category

### ⭐ Core Workflow (Required, Sequential)
1. **initialize phase** - Setup → `{config.paths.spec_root}/` structure
2. **generate phase** - Define → `spec.md`
3. **plan phase** - Design → `plan.md`
4. **tasks phase** - Task → `tasks.md`
5. **implement phase** - Build → Working feature

**6 total core functions** (init, generate, plan, tasks, implement + implement as second Phase 4 core)

### 🔧 Supporting Tools (Optional, Contextual)

**Phase 1 Tools**:
- **discover phase** - Codebase analysis (brownfield only)
- **blueprint phase** - Architecture definition (documentation)

**Phase 2 Tools**:
- **clarify phase** - Resolve ambiguities (when [CLARIFY] tags present)
- **checklist phase** - Quality gates (enterprise/compliance)

**Phase 3 Tools**:
- **analyze phase** - Validation (complex features, pre-implementation)

**Phase 5 Tools** (all tools, no core):
- **update phase** - Requirement changes (ongoing)
- **metrics phase** - Progress tracking (ongoing)
- **orchestrate phase** - Full automation (alternative to manual workflow)

**7 total supporting tools** (discover, blueprint, clarify, checklist, analyze, update, metrics, orchestrate)

## By Use Case

### Starting New Project
```
initialize phase → blueprint phase → generate phase
```

### Analyzing Existing Codebase
```
discover phase → initialize phase → blueprint phase
```

### Building Feature
```
generate phase → clarify phase → plan phase → tasks phase → implement phase
```

### Automating Workflow
```
orchestrate phase (runs: generate → clarify → plan → tasks → implement)
```

### Changing Requirements
```
update phase → analyze phase → tasks phase --update
```

### Tracking Progress
```
metrics phase (view analytics anytime)
```

## Skill Details

### initialize phase
**Purpose**: Initialize Spec workflow in project
**When**: Starting new project or adding Spec to existing code
**Tools**: Read, Write, Bash, Grep
**Inputs**: None (detects project type)
**Outputs**: `{config.paths.spec_root}/`, `{config.paths.state}/`, `{config.paths.memory}/`
**Next**: discover phase (brownfield) or blueprint phase (greenfield)

### discover phase
**Purpose**: Analyze existing codebase architecture and patterns
**When**: Brownfield projects, onboarding, refactoring planning
**Tools**: Read, Grep, Bash (uses analyze phaser subagent)
**Inputs**: Existing codebase, JIRA config (optional)
**Outputs**: `discovery/` reports, architecture insights
**Next**: initialize phase, then blueprint phase

### blueprint phase
**Purpose**: Define project architecture and technical standards
**When**: Need architecture documentation, team alignment
**Tools**: Read, Write, Edit, WebSearch, Bash
**Inputs**: `{config.paths.spec_root}/`, discovery reports (optional)
**Outputs**: `{config.paths.spec_root}/architecture-blueprint.md`, ADRs
**Next**: generate phase (start features)

### generate phase
**Purpose**: Create feature specifications with user stories
**When**: Starting new feature development
**Tools**: Read, Write, Edit, AskUserQuestion, WebSearch, Bash
**Inputs**: Feature description, product requirements
**Outputs**: `{config.paths.features}/NNN-name/{config.naming.files.spec}`, user stories (P1/P2/P3)
**Next**: clarify phase (if [CLARIFY] tags) or plan phase

### clarify phase
**Purpose**: Resolve ambiguities and vague requirements
**When**: [CLARIFY] tags present, vague terms detected
**Tools**: Read, Edit, AskUserQuestion
**Inputs**: `spec.md` with ambiguities
**Outputs**: Clarified `spec.md`, decision log
**Next**: checklist phase (validation) or plan phase

### checklist phase
**Purpose**: Validate requirement quality with domain checklists
**When**: Quality gates, enterprise compliance, pre-planning
**Tools**: Read, Write
**Inputs**: `spec.md`
**Outputs**: `checklists/` (ux.md, api.md, security.md, performance.md)
**Next**: Review checklists, then plan phase

### plan phase
**Purpose**: Create technical design with architecture decisions
**When**: Have approved specification
**Tools**: Read, Write, Edit, WebSearch, Bash (uses spec:researcher)
**Inputs**: `spec.md`, architecture blueprint
**Outputs**: `plan.md`, ADRs, technical approach
**Next**: analyze phase (validation) or tasks phase

### analyze phase
**Purpose**: Validate consistency across spec/plan/tasks
**When**: Before implementation, after updates, complex features
**Tools**: Read, Grep, Bash (uses analyze phaser subagent)
**Inputs**: `spec.md`, `plan.md`, `tasks.md` (if exists)
**Outputs**: Analysis report with CRITICAL/HIGH/MEDIUM/LOW issues
**Next**: Fix issues or proceed to tasks phase

### tasks phase
**Purpose**: Break down plan into executable tasks
**When**: Technical plan complete
**Tools**: Read, Write, Edit, Bash
**Inputs**: `plan.md`, `spec.md`
**Outputs**: `tasks.md` with task IDs, priorities, dependencies
**Next**: implement phase

### implement phase
**Purpose**: Execute implementation tasks with progress tracking
**When**: Tasks defined in tasks.md
**Tools**: Read, Write, Edit (delegates to implement phaseer subagent)
**Inputs**: `tasks.md`
**Outputs**: Working feature, test results, completed tasks
**Next**: New feature or metrics phase

### update phase
**Purpose**: Modify existing specifications
**When**: Requirements change, add/remove stories, priority shifts
**Tools**: Read, Write, Edit, AskUserQuestion, WebSearch, Bash
**Inputs**: `spec.md`, change description
**Outputs**: Updated `spec.md`, `plan.md`, `tasks.md`, migration plan
**Next**: analyze phase → tasks phase --update

### metrics phase
**Purpose**: View development analytics and progress
**When**: Need progress report, sprint planning, process optimization
**Tools**: Read, Bash
**Inputs**: `{config.paths.memory}/WORKFLOW-PROGRESS.md`
**Outputs**: Analytics dashboard, CSV/JSON exports
**Next**: Use insights to optimize workflow

### orchestrate phase
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

**Need overview?** → Load `workflow-map.md`
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
