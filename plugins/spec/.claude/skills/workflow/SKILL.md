---
name: workflow
description: Use when navigating spec workflow phases, need workflow guidance, starting features, understanding current phase, or user mentions "workflow", "spec process", "what's next" - intelligent router that provides context-aware navigation through initialization, definition, design, implementation, and tracking phases with progressive disclosure
allowed-tools: Read, AskUserQuestion, Skill, Bash
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

I'll detect the workflow state by checking:

1. **Does `.spec/` exist?**
   ```bash
   test -d .spec && echo "INITIALIZED" || echo "NOT_INITIALIZED"
   ```

2. **If initialized, read session state:**
   ```
   Read {config.paths.state}/current-session.md
   Parse YAML frontmatter fields:
   - feature: (feature ID or "none")
   - phase: (current phase or "none")
   ```

3. **Map to workflow state:**
   - `.spec/` doesn't exist → **NOT_INITIALIZED**
   - feature = "none" → **NO_FEATURE**
   - phase = "specification" → **IN_SPECIFICATION**
   - phase = "planning" → **IN_PLANNING**
   - phase = "implementation" → **IN_IMPLEMENTATION**
   - All tasks complete → **COMPLETE**

### Step 2: Present Context-Aware Menu

Based on the detected state, I'll use AskUserQuestion to present appropriate options:

**State: NOT_INITIALIZED**
```
Question: "Welcome to Spec Workflow! You haven't initialized Spec yet. What would you like to do?"

Options:
- 🚀 Initialize Project → Set up Spec in this project
- 📚 Learn About Spec → Understand the workflow
- ❓ Ask a Question → Get specific help
```

**State: NO_FEATURE**
```
Question: "Spec is ready! What would you like to work on?"

Options:
- 🚀 Auto Mode → Full automation for new feature
- 📝 Define Feature → Create new specification
- 📊 Track Progress → View metrics and status
- ❓ Get Help → Guidance or questions
```

**State: IN_SPECIFICATION**
```
Question: "📍 Current: Specification Phase\nFeature: {feature-name}\nStatus: {spec-status}\n\nWhat would you like to do next?"

Options:
- 🚀 Auto Mode → Continue automatically to design → build
- 🎨 Move to Design → Create technical plan
- 🔄 Refine Specification → Improve quality, resolve [CLARIFY] tags
- 📊 View Specification → Read spec.md
- ❓ Get Help → Specification best practices
```

**State: IN_PLANNING**
```
Question: "📍 Current: Planning Phase\nFeature: {feature-name}\nStatus: {plan-status}\n\nWhat would you like to do next?"

Options:
- 🚀 Auto Mode → Continue automatically to build
- 🔨 Move to Build → Break down into tasks and implement
- 🔄 Refine Design → Review architecture, improve plan
- 📊 View Plan → Read plan.md
- ❓ Get Help → Planning best practices
```

**State: IN_IMPLEMENTATION**
```
Question: "📍 Current: Implementation\nFeature: {feature-name}\nProgress: {completed}/{total} tasks ({percentage}%)\n\nWhat would you like to do?"

Options:
- 🚀 Auto Mode → Continue implementation automatically
- 🔨 Continue Building → Resume task execution
- 🔄 Refine Approach → Improve code quality, add tests
- 📊 View Progress → Detailed task status
- ✅ Validate → Check consistency and quality
- ❓ Get Help → Implementation strategies
```

**State: COMPLETE**
```
Question: "🎉 Feature Complete!\nFeature: {feature-name}\nAll tasks completed\n\nWhat would you like to do next?"

Options:
- ✅ Validate & Finalize → Run consistency checks and quality review
- 📊 View Metrics → Development stats and performance
- 📝 Start New Feature → Define next specification
- 📦 Track & Maintain → Update docs, sync external systems
- ❓ Get Help → Next steps guidance
```

### Step 3: Execute User Selection

Based on menu selection, I'll route to the appropriate action:

**Phase Invocation (via Skill tool)**:
- "Initialize Project" → Invoke skill targeting `phases/1-initialize/init/guide.md`
- "Define Feature" → Invoke skill targeting `phases/2-define/generate/guide.md`
- "Move to Design" → Invoke skill targeting `phases/3-design/plan/guide.md`
- "Move to Build" → Invoke skill targeting `phases/4-build/tasks/guide.md`
- "Continue Building" → Invoke skill targeting `phases/4-build/implement/guide.md`
- "Validate" → Invoke skill targeting `phases/3-design/analyze/guide.md`
- "View Metrics" → Invoke skill targeting `phases/5-track/metrics/guide.md`

**Refinement Actions**:
- "Refine Specification" → Invoke skill for `phases/2-define/clarify/guide.md`
- "Refine Design" → Invoke skill for `phases/3-design/analyze/guide.md`
- "Refine Approach" → Invoke skill for `phases/3-design/analyze/guide.md`

**View Actions** (via Read tool):
- "View Specification" → Read and display spec.md
- "View Plan" → Read and display plan.md
- "View Progress" → Read and display tasks.md with status

**Auto Mode**:
- "Auto Mode" → Invoke skill targeting `phases/5-track/orchestrate/guide.md`
- The orchestrate skill provides full end-to-end workflow automation with checkpoints
- See Step 4 below for auto mode details

**Help Mode** (see Step 5)

### Step 4: Auto Mode Execution

When user selects "Auto Mode", I delegate to the orchestrate skill for full workflow automation.

**Delegation**:
```
Invoke skill targeting `phases/5-track/orchestrate/guide.md`
```

**What Orchestrate Does**:

The orchestrate skill provides comprehensive end-to-end workflow execution:

1. **Assessment**: Determines starting point based on current state
   - New project → Runs blueprint if needed
   - New feature → Starts at generate
   - Mid-workflow → Resumes from current phase

2. **Phase Execution**: Runs complete workflow with intelligent routing
   - generate → clarify (if [CLARIFY] tags) → plan → analyze (if complex) → tasks → implement
   - Each phase invoked via Skill tool
   - Progress tracked in state files

3. **Checkpoints**: Saves state between phases for recovery
   - post-generate, post-clarify, post-plan, post-analyze, post-tasks, complete
   - Enables resume from interruptions

4. **Completion Summary**: Provides execution report
   - Duration, phases executed, artifacts created
   - Metrics and next steps

**State-Aware Behavior**:
- **NO_FEATURE**: Full workflow (generate → implement)
- **IN_SPECIFICATION**: Resumes from planning
- **IN_PLANNING**: Resumes from tasks
- **IN_IMPLEMENTATION**: Continues implementation

**User Experience**:
```
User: Selects "🚀 Auto Mode"
Claude: [Invokes orchestrate skill]
Orchestrate: [Executes workflow phases]
Orchestrate: [Shows completion summary]
Claude: [Returns to main menu or shows next steps]
```

For detailed orchestrate implementation, see `phases/5-track/orchestrate/guide.md`

### Step 5: Help Mode

When user selects "Get Help" or "Ask a Question":

**If NOT_INITIALIZED state:**
```
Question: "How can I help you?"

Options:
- 📚 What is Spec? → Overview of spec-driven development
- 🚀 How do I start? → Step-by-step getting started
- 💡 Show examples → See Spec in action
- ❓ Ask a question → Type your specific question
```

**If in workflow (other states):**
```
Question: "Help Topics:"

Options:
- 📖 Explain current phase → What is {phase-name}?
- 🎯 What should I do next? → Recommended next steps
- 🔧 Troubleshooting → Common issues and solutions
- 💡 Best practices → Tips for {phase-name}
- 📚 Full workflow → Understand all phases
- ❓ Ask a question → Type your specific question
```

**Handling "Ask a question":**
If selected, I'll ask: "What would you like to know?" and provide a detailed, context-aware answer based on their current workflow state.

**Handling other help topics:**
- Load and display relevant documentation sections
- Use Read tool to fetch specific guide content
- Provide concise, actionable answers

### Step 6: State Persistence

After executing any phase:
1. Phase guides update `{config.paths.state}/current-session.md` automatically
2. Progress recorded in `{config.paths.memory}/WORKFLOW-PROGRESS.md`
3. Next invocation of workflow skill will detect new state

## Practical Execution Guide

When invoked via `/workflow:spec`, I'll:

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

All paths are configurable via `.claude/.spec-config.yml`:

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
2. Read from `.claude/.spec-config.yml` directly if needed
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
- **Phase 1**: See `phases/1-initialize/README.md` (init, discover, blueprint)
- **Phase 2**: See `phases/2-define/README.md` (generate, clarify, checklist)
- **Phase 3**: See `phases/3-design/README.md` (plan, analyze)
- **Phase 4**: See `phases/4-build/README.md` (tasks, implement)
- **Phase 5**: See `phases/5-track/README.md` (update, metrics, orchestrate)

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

Need more detail? Load phases/2-define/README.md
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
- **Template Guide**: `templates/README.md` - All 11 templates documented

**For developers**: See `CLAUDE.md` in plugin root
**For users**: See `README.md` in plugin root
**For migration**: See `docs/MIGRATION-V2-TO-V3.md`

---

**Token Budget**: ~300 tokens
**Progressive Disclosure**: Context → Phase → Skill → Examples → Reference
