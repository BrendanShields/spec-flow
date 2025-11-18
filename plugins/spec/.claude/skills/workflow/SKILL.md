---
name: workflow
description: Use when navigating spec workflow phases, need workflow guidance, starting features, understanding current phase, or user mentions "workflow", "spec process", "what's next" - intelligent router that provides context-aware navigation through initialization, definition, design, implementation, and tracking phases with progressive disclosure
allowed-tools: Read, AskUserQuestion, AskUserAgent, Skill, Bash
---

# Spec Workflow Navigator

Interactive, context-aware navigation for the complete specification-driven development workflow.

## What This Skill Does

- Detects current workflow phase from session state
- Presents context-aware interactive menus
- Executes selected workflow phases
- Provides auto mode with checkpoints
- Shows "where am I" orientation
- Progressively discloses relevant information
- Maintains efficient token usage

## When to Use

1. User asks "where am I in the workflow?"
2. User needs guidance on "what's next?"
3. User mentions "spec workflow" or "spec process"
4. Starting new feature and needs workflow overview
5. Needs to understand workflow phases
6. Wants to jump to specific workflow phase

## Workflow Phases

The Spec workflow consists of 5 main phases:

### Phase 1: Initialize
**Purpose**: Set up project structure and architecture
**Functions**: `/spec init`, `/spec discover`, `/spec blueprint`
**When**: Starting new project or analyzing existing codebase
**Output**: `{config.paths.spec_root}/` structure, architecture blueprint
**→ Next**: Phase 2 (Define Requirements)

### Phase 2: Define
**Purpose**: Create and validate feature specifications
**Functions**: `/spec generate`, `/spec clarify`, `/spec checklist`
**When**: Starting new feature development
**Output**: `spec.md` with validated requirements
**→ Next**: Phase 3 (Design Solution)

### Phase 3: Design
**Purpose**: Create technical plan and validate consistency
**Functions**: `/spec plan`, `/spec analyze`
**When**: Have approved specification
**Output**: `plan.md` with architecture decisions
**→ Next**: Phase 4 (Build Feature)

### Phase 4: Build
**Purpose**: Break down and execute implementation
**Functions**: `/spec tasks`, `/spec implement`
**When**: Technical plan complete
**Output**: Implemented feature with passing tests
**→ Next**: Phase 5 (Track Progress)

### Phase 5: Track
**Purpose**: Maintain specs and monitor progress
**Functions**: `/spec update`, `/spec metrics`, `/spec orchestrate`
**When**: Throughout development lifecycle
**Output**: Updated specs, progress metrics

## Interactive Menu Implementation

### Step 1: Detect Current State

State detection is two-tiered:

1. **Read cached hint**  
   Hooks compute `.spec/state/NEXT-STEP.json` after SessionStart and PostToolUse events.  
   ```bash
   if test -f {config.paths.state}/NEXT-STEP.json; then
     jq -r '.phase,.feature,.action' {config.paths.state}/NEXT-STEP.json
   fi
   ```
   Use the cached `action`/`phase`/`feature` to pre-select the recommended option.

2. **Fallback to live inspection**  
   If the cache is missing or empty:
   - Check for `.spec/`; if missing → **NOT_INITIALIZED**.
   - Read `{config.paths.state}/current-session.md` frontmatter (`feature`, `phase`).
   - Map `phase` to a menu state:
     - `none` → **NO_FEATURE**
     - `specification` → **IN_SPECIFICATION**
     - `planning` → **IN_PLANNING**
     - `tasks` → **IN_TASKING**
     - `implementation` → **IN_IMPLEMENTATION**
     - `validate` → **VALIDATION**
     - `complete` → **COMPLETE**

Keep the detection logic in sync with the hooks—if the hook schema changes, update this section immediately.

### Step 2: Present Context-Aware Menu (via AskUserAgent)

Instead of hand-building separate menus for each workflow state, I now send a **single option catalog** to **AskUserAgent** along with the detected state, feature info, and cached recommendation. AskUserAgent ranks the options, highlights the most relevant subset, and returns the user’s choice. This keeps the prompts short and ensures Claude can dynamically adapt to unusual states.

**Option Catalog (maintained in one place)**

| Option ID | Label | Description | Valid States | Action |
|-----------|-------|-------------|--------------|--------|
| `init` | 🚀 Initialize Project | Bootstrap `.spec/`, state, config | `NOT_INITIALIZED` | `phases/1-initialize/init/guide.md` |
| `learn` | 📚 Learn Workflow | Explain phases, best practices | any | help topic |
| `define` | 📝 Define Feature | Create new specification | `NO_FEATURE`, `COMPLETE` | `phases/2-define/generate/guide.md` |
| `auto` | 🚀 Auto Mode | Run orchestrate skill (resume-aware) | any (except NOT_INITIALIZED) | `phases/5-track/orchestrate/guide.md` |
| `plan` | 🎨 Move to Design | Create/expand plan | `IN_SPECIFICATION` | `phases/3-design/plan/guide.md` |
| `refine-spec` | 🔄 Refine Spec | Resolve [CLARIFY] tags | `IN_SPECIFICATION` | `phases/2-define/clarify/guide.md` |
| `tasks` | 🔨 Move to Build | Produce tasks | `IN_PLANNING` | `phases/4-build/tasks/guide.md` |
| `refine-plan` | 🔄 Refine Design | Analyze consistency | `IN_PLANNING`, `IN_IMPLEMENTATION` | `phases/3-design/analyze/guide.md` |
| `implement` | 🛠 Continue Building | Run implementation guide | `IN_IMPLEMENTATION` | `phases/4-build/implement/guide.md` |
| `validate` | ✅ Validate | Analyze alignment before completing | `IN_IMPLEMENTATION`, `COMPLETE` | `phases/3-design/analyze/guide.md` |
| `metrics` | 📊 View Metrics | Show tracking dashboards | any initialized state | `phases/5-track/metrics/guide.md` |
| `update` | 📝 Update Spec | Maintain docs mid-flight | any initialized state | `phases/5-track/update/guide.md` |
| `docs` | 📂 View Docs | Read key artifacts | any initialized state | Read tool |
| `help` | ❓ Get Help | Context-aware FAQ | any | help topic |

Additional options (e.g., sync external tools) can be appended to the table above without touching runtime logic.

**AskUserAgent Invocation**
1. Build a payload with:
   - `state_summary`: phase, feature, next step, progress string
   - `options`: array of objects from the table (id, label, description, valid_states, action metadata)
2. Filter out invalid options (state mismatch, missing files) but keep the payload ordering stable.
3. Call `AskUserAgent` once. It decides how many options to surface and may highlight one as “Recommended” based on `NEXT-STEP.json`.
4. Capture the returned option ID and feed it into Step 3.

### Step 3: Execute User Selection

After AskUserAgent returns an `option_id`, look it up in a compact dispatch table (kept adjacent to the catalog so we only edit one area when flows change):

| Option ID | Tool | Target |
|-----------|------|--------|
| `init` | Skill | `phases/1-initialize/init/guide.md` |
| `define` | Skill | `phases/2-define/generate/guide.md` |
| `plan` | Skill | `phases/3-design/plan/guide.md` |
| `refine-spec` | Skill | `phases/2-define/clarify/guide.md` |
| `tasks` | Skill | `phases/4-build/tasks/guide.md` |
| `refine-plan` \| `validate` | Skill | `phases/3-design/analyze/guide.md` |
| `implement` | Skill | `phases/4-build/implement/guide.md` |
| `auto` | Skill | `phases/5-track/orchestrate/guide.md` |
| `metrics` | Skill | `phases/5-track/metrics/guide.md` |
| `update` | Skill | `phases/5-track/update/guide.md` |
| `docs` | Read | spec/plan/tasks/decision files (prompt user for which artifact) |
| `help` | AskUserQuestion | Route to Help Mode (Step 5) |

The dispatcher is straightforward pseudo-code:
```python
selected = ask_user_agent(...)
action = ACTIONS[selected]
if action.tool == "Skill":
    Skill(action.target)
elif action.tool == "Read":
    Read(requested_file)
elif action.tool == "AskUserQuestion":
    run_help_flow()
```
This keeps the command token-light and guarantees every option stays in sync with the catalog.

### Step 4: Auto Mode Execution

Selecting `auto` simply calls `phases/5-track/orchestrate/guide.md`. That guide already handles:
- State detection (new project vs resume)
- Phase sequencing + checkpoints
- Optional clarify/analyze steps
- Completion summary output

No extra instructions live here—see the guide for full details.

### Step 5: Help Mode

`help` stays a lightweight branch: AskUserQuestion surfaces a few context-aware topics (current phase explainer, what's next, troubleshooting, best practices, ask-anything). Each topic either prints a brief answer inline or reads the relevant section from navigation docs. No extra branching logic elsewhere.

### Step 6: State Persistence

After executing any phase:
1. Phase guides update `{config.paths.state}/current-session.md` automatically
2. Progress recorded in `{config.paths.memory}/workflow-progress.md`
3. Next invocation of workflow skill will detect new state

## Practical Execution Guide

When invoked via `/spec`, I'll:

1. **Check if `.spec/` exists** (Bash tool):
   - If no → Show NOT_INITIALIZED menu
   - If yes → Continue to step 2

2. **Read session state** (Read tool):
   ```
   Read {config.paths.state}/current-session.md
   ```
   Parse YAML to extract `feature` and `phase` fields

3. **Determine state** (logic):
   - Map YAML values to one of 6 states
   - Extract context (feature name, progress, etc.)

4. **Present menu** (AskUserQuestion tool):
   - Build question with context
   - Present 3-6 options based on state
   - Get user selection

5. **Execute selection**:
   - **Phase action** → Use Skill tool to invoke phase guide
   - **View action** → Use Read tool to display artifact
   - **Auto mode** → Execute phase loop with checkpoints
   - **Help** → Show help menu or answer question

6. **Return to menu** (if appropriate):
   - Auto mode checkpoints loop back
   - One-shot actions complete
   - Help returns to main menu

## Configuration Access

All paths are configurable via `.spec/.spec-config.yml`:

**Available config variables**:
- `{config.paths.spec_root}` - Default: `.spec`
- `{config.paths.features}` - Default: `features`
- `{config.paths.state}` - Default: `{config.paths.state}`
- `{config.paths.memory}` - Default: `{config.paths.memory}`
- `{config.paths.templates}` - Default: `.spec/templates`
- `{config.naming.feature_directory}` - Default: `{id:000}-{slug}`
- `{config.naming.files.spec}` - Default: `spec.md`
- `{config.naming.files.plan}` - Default: `plan.md`
- `{config.naming.files.tasks}` - Default: `tasks.md`

**How to access in skills**:
1. Session-init hook provides config in session context
2. Read from `.spec/.spec-config.yml` directly if needed
3. Use config variables in all path references

**Example**:
```bash
# Read current feature spec
Read {config.paths.features}/001-user-auth/{config.naming.files.spec}

# Update session state
Write {config.paths.state}/current-session.md
```

## Quick Reference

**Core Workflow** (sequential):
```
init → generate → clarify → plan → tasks → implement
```

**Full Automation**:
```
orchestrate (runs entire workflow)
```

**Supporting Tools**:
```
discover  - Analyze existing codebase
blueprint - Define architecture
update    - Modify specifications
analyze   - Validate consistency
checklist - Quality validation
metrics   - Progress tracking
```

## Navigation Resources

For detailed phase information:
- **Phase 1**: See `phases/1-initialize/readme.md` (init, discover, blueprint)
- **Phase 2**: See `phases/2-define/readme.md` (generate, clarify, checklist)
- **Phase 3**: See `phases/3-design/readme.md` (plan, analyze)
- **Phase 4**: See `phases/4-build/readme.md` (tasks, implement)
- **Phase 5**: See `phases/5-track/readme.md` (update, metrics, orchestrate)

For complete workflow visualization:
- **Workflow Map**: See `navigation/workflow-map.md`
- **Phase Reference**: See `navigation/phase-reference.md`
- **Skill Index**: See `navigation/skill-index.md`

For individual skill details, navigate to:
- **`phases/1-initialize/init/guide.md`** - Initialize workflow
- **`phases/2-define/generate/guide.md`** - Create specifications
- **`phases/2-define/clarify/guide.md`** - Resolve ambiguities
- **`phases/3-design/plan/guide.md`** - Technical planning
- **`phases/4-build/tasks/guide.md`** - Task breakdown
- **`phases/4-build/implement/guide.md`** - Execute implementation
- **`phases/5-track/orchestrate/guide.md`** - Full automation
- **`phases/1-initialize/discover/guide.md`** - Codebase analysis
- **`phases/1-initialize/blueprint/guide.md`** - Architecture definition
- **`phases/5-track/update/guide.md`** - Update specifications
- **`phases/3-design/analyze/guide.md`** - Validate consistency
- **`phases/2-define/checklist/guide.md`** - Quality validation
- **`phases/5-track/metrics/guide.md`** - Progress tracking

## Error Handling

**No session state found**:
- User hasn't initialized workflow
- Suggest: "Run /spec init to start workflow"

**Phase unclear**:
- Session state incomplete
- Show: Complete phase overview
- Let user choose phase

**Invalid phase request**:
- User asks for non-existent phase
- Show: Available phases (1-5)

## Output Format

**Current Context**:
```
📍 Current Location: Phase 2 (Define Requirements)
🎯 Active Feature: #003-user-authentication
✅ Completed: init, generate
⏳ Current: clarify (2/4 clarifications resolved)
→ Next: /spec plan (after clarifications complete)

Available in this phase:
- /spec generate - Create new specifications
- /spec clarify - Resolve ambiguities (IN PROGRESS)
- /spec checklist - Validate requirements quality

Need more detail? Load phases/2-define/readme.md
```

**Workflow Overview**:
```
Spec Workflow Map

1. Initialize  [✅ Complete]
2. Define      [⏳ In Progress - 60%]
3. Design      [⏸ Pending]
4. Build       [⏸ Pending]
5. Track       [Available anytime]

Current Progress: ████████░░ 40% overall

For visual workflow map: navigation/workflow-map.md
For phase details: phases/[phase-number]-[name].md
```

## Token Efficiency

**This router**: ~300 tokens (lightweight, always loaded)
**Phase guides**: ~500 tokens each (loaded on demand)
**Skill docs**: ~1,500+ tokens each (loaded only when needed)

**Smart loading**:
- Default: Show current context only
- User asks "what's next": Load current phase guide
- User asks for skill: Load specific skill documentation
- User asks "show everything": Load complete workflow map

## Related Resources

**Getting Started**:
- **Quick Start**: `quick-start.md` - Get your first feature built in 5 commands (~800 tokens)
- **Glossary**: `glossary.md` - Understand all terminology and concepts (~600 tokens)

**Troubleshooting**:
- **Error Recovery**: `error-recovery.md` - Solutions for common problems (~1,000 tokens)
- **Workflow Review**: `workflow-review.md` - Comprehensive analysis and improvements

**Navigation**:
- **Workflow Map**: `navigation/workflow-map.md` - Visual workflow guide
- **Skill Index**: `navigation/skill-index.md` - Complete function reference
- **Phase Reference**: `navigation/phase-reference.md` - Detailed phase documentation

**Templates**:
- **Template Guide**: `templates/readme.md` - All 11 templates documented

**For developers**: See `claude.md` in plugin root
**For users**: See `readme.md` in plugin root
**For migration**: See `docs/MIGRATION-V2-TO-V3.md`

---

**Token Budget**: ~300 tokens
**Progressive Disclosure**: Context → Phase → Skill → Examples → Reference
