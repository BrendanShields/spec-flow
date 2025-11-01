---
name: workflow
description: Use when navigating spec workflow phases, need workflow guidance, starting features, understanding current phase, or user mentions "workflow", "spec process", "what's next" - intelligent router that provides context-aware navigation through initialization, definition, design, implementation, and tracking phases with progressive disclosure
allowed-tools: Read
---

# Spec Workflow Navigator

Context-aware router for the complete specification-driven development workflow.

## What This Skill Does

- Detects current workflow phase from session state
- Routes to appropriate phase documentation
- Provides "where am I" orientation
- Shows next steps based on context
- Progressively discloses relevant information
- Maintains minimal token overhead (~300 tokens)

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
**Output**: `.spec/` structure, architecture blueprint
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

## Context-Aware Navigation

**Determine Current Phase**:
1. Read `.spec-state/current-session.md`
2. Extract current phase indicator
3. Identify completed vs pending phases
4. Show relevant next steps

**Navigation Commands**:
- "Where am I?" → Show current phase and progress
- "What's next?" → Show next skill to run
- "Show phase X" → Load phase X documentation
- "Workflow overview" → Show complete map

## Execution Flow

### Step 1: Detect Context

Read session state:
```
Read .spec-state/current-session.md
Extract: current_phase, current_feature, last_skill_run
```

### Step 2: Route to Phase Guide

Based on current phase, load appropriate documentation:
- **Phase 1** → See `phases/1-initialize/README.md`
- **Phase 2** → See `phases/2-define/README.md`
- **Phase 3** → See `phases/3-design/README.md`
- **Phase 4** → See `phases/4-build/README.md`
- **Phase 5** → See `phases/5-track/README.md`

### Step 3: Provide Orientation

Show:
- Current phase and progress
- Skills available in this phase
- Recommended next action
- Exit criteria for current phase

### Step 4: Progressive Disclosure

If user needs more detail:
- **Function guide** → Load individual function guide.md
- **Examples** → Load function examples.md
- **Technical details** → Load function reference.md
- **Complete map** → Load `navigation/workflow-map.md`

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
- **Quick Start**: `QUICK-START.md` - Get your first feature built in 5 commands (~800 tokens)
- **Glossary**: `GLOSSARY.md` - Understand all terminology and concepts (~600 tokens)

**Troubleshooting**:
- **Error Recovery**: `ERROR-RECOVERY.md` - Solutions for common problems (~1,000 tokens)
- **Workflow Review**: `WORKFLOW-REVIEW.md` - Comprehensive analysis and improvements

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
