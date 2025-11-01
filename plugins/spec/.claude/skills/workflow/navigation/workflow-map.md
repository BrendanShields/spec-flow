# Spec Workflow Map

Visual guide to the complete specification-driven development workflow.

## Workflow Visualization

```
┌─────────────────────────────────────────────────────────────────┐
│                     SPEC WORKFLOW v3.0                         │
└─────────────────────────────────────────────────────────────────┘

START
  │
  ├─[New Project]────────────────┐
  │                               ▼
  │                        ┌──────────────┐
  │                        │ spec:discover│◄──[Brownfield]
  │                        └──────┬───────┘
  │                               ▼
  ├──────────────────────►┌──────────────┐
  │                        │  spec:init   │
  │                        └──────┬───────┘
  │                               ▼
  │                        ┌──────────────┐
  │                        │spec:blueprint│◄──[Define Architecture]
  │                        └──────┬───────┘
  │                               │
  ▼                               │
┌─────────────────────────────────┴────────────────────┐
│              PHASE 1: INITIALIZE                     │
│  Setup project structure and architecture            │
└──────────────────────────┬───────────────────────────┘
                           ▼
                    ┌──────────────┐
                    │spec:generate │◄──[New Feature]
                    └──────┬───────┘
                           ▼
                    ┌──────────────┐
              ┌────►│spec:clarify  │
              │     └──────┬───────┘
              │            ▼
   [Questions]│     ┌──────────────┐
              └─────┤spec:checklist│
                    └──────┬───────┘
┌─────────────────────────┴────────────────────┐
│         PHASE 2: DEFINE REQUIREMENTS         │
│  Create and validate feature specifications  │
└──────────────────────┬───────────────────────┘
                       ▼
                ┌──────────────┐
                │  spec:plan   │
                └──────┬───────┘
                       ▼
                ┌──────────────┐
                │spec:analyze  │◄──[Validation]
                └──────┬───────┘
┌───────────────────────┴──────────────────────┐
│       PHASE 3: DESIGN SOLUTION               │
│  Technical planning and validation           │
└──────────────────────┬───────────────────────┘
                       ▼
                ┌──────────────┐
                │  spec:tasks  │
                └──────┬───────┘
                       ▼
                ┌──────────────┐
                │spec:implement│
                └──────┬───────┘
┌───────────────────────┴──────────────────────┐
│          PHASE 4: BUILD FEATURE              │
│  Task breakdown and implementation           │
└──────────────────────┬───────────────────────┘
                       ▼
                  ┌─────────┐
                  │COMPLETE │
                  └─────────┘

┌────────────────────────────────────────────────────┐
│      PHASE 5: TRACK PROGRESS (Anytime)            │
├────────────────────────────────────────────────────┤
│ spec:update    - Modify specifications            │
│ spec:metrics   - View progress and analytics      │
│ spec:orchestrate - Automate full workflow         │
└────────────────────────────────────────────────────┘
```

## Phase Progression

### Phase 1: Initialize (1-2 hours)
**Entry**: New project or new to Spec
**Skills**: init → discover/blueprint
**Output**: `.spec/` structure, architecture blueprint
**Exit**: Ready to create features

### Phase 2: Define (30min - 2 hours)
**Entry**: Need to build new feature
**Skills**: generate → clarify → checklist
**Output**: Validated `spec.md` with clear requirements
**Exit**: Requirements approved, no [CLARIFY] tags

### Phase 3: Design (45min - 3 hours)
**Entry**: Approved specification exists
**Skills**: plan → analyze
**Output**: Technical `plan.md` with ADRs, validation passed
**Exit**: Technical approach agreed, ready to task out

### Phase 4: Build (2-20 hours)
**Entry**: Technical plan complete
**Skills**: tasks → implement
**Output**: Working feature with passing tests
**Exit**: All P1 tasks complete, tests pass

### Phase 5: Track (Ongoing)
**Entry**: Anytime during development
**Skills**: update, metrics, orchestrate
**Output**: Updated specs, progress insights
**Exit**: Continuous throughout project

## Quick Navigation

**Starting Points**:
- New project? → `spec:init`
- Existing codebase? → `spec:discover` then `spec:init`
- New feature? → `spec:generate`
- Mid-feature? → Check `.spec-state/current-session.md`

**Common Paths**:
- **Full workflow**: orchestrate (automates everything)
- **Feature addition**: generate → clarify → plan → tasks → implement
- **Requirement change**: update → analyze → tasks
- **Progress check**: metrics

**Emergency Exits**:
- Stuck in clarify? → Skip to plan, add [CLARIFY] tags
- Plan too complex? → Use plan EXAMPLES.md for patterns
- Implementation blocked? → Use implement --continue

## Skill Relationships

```
⭐ CORE WORKFLOW (Required, Sequential):
init ──► generate ──► plan ──► tasks ──► implement

🔧 SUPPORTING TOOLS (Optional, Contextual):
├─ Phase 1: discover, blueprint
├─ Phase 2: clarify, checklist
├─ Phase 3: analyze
├─ Phase 4: (no supporting tools)
└─ Phase 5: update, metrics, orchestrate

CORE vs TOOL by Phase:
Phase 1: init ⭐ | discover 🔧, blueprint 🔧
Phase 2: generate ⭐ | clarify 🔧, checklist 🔧
Phase 3: plan ⭐ | analyze 🔧
Phase 4: tasks ⭐, implement ⭐ (2 core functions)
Phase 5: (all tools - no core workflow)

AUTOMATION:
orchestrate 🔧 ──► Runs: generate→clarify→plan→tasks→implement
```

## Decision Tree

```
START: Need to...

├─ Setup project?
│  ├─ New project? → spec:init
│  └─ Existing code? → spec:discover → spec:init
│
├─ Define architecture?
│  └─ → spec:blueprint
│
├─ Build feature?
│  ├─ Have spec?
│  │  ├─ Yes → spec:plan
│  │  └─ No → spec:generate
│  │
│  ├─ Have plan?
│  │  ├─ Yes → spec:tasks
│  │  └─ No → spec:plan
│  │
│  └─ Have tasks?
│     ├─ Yes → spec:implement
│     └─ No → spec:tasks
│
├─ Modify requirements?
│  └─ → spec:update
│
├─ Check progress?
│  └─ → spec:metrics
│
└─ Automate everything?
   └─ → spec:orchestrate
```

## Time Estimates

**By Phase**:
- Initialize: 1-2 hours (one-time per project)
- Define: 30min - 2 hours per feature
- Design: 45min - 3 hours per feature
- Build: 2-20 hours per feature (varies by complexity)
- Track: 5-10 min per check-in

**By Skill** (average):
- `spec:init`: 15-30 min
- `spec:discover`: 30-60 min
- `spec:blueprint`: 45-90 min
- `spec:generate`: 20-45 min
- `spec:clarify`: 10-30 min
- `spec:checklist`: 15-30 min
- `spec:plan`: 30-90 min
- `spec:analyze`: 10-20 min
- `spec:tasks`: 20-45 min
- `spec:implement`: 2-20 hours
- `spec:update`: 15-45 min
- `spec:metrics`: 2-5 min
- `spec:orchestrate`: Full feature cycle (3-25 hours)

## Parallel Work Opportunities

Skills that can run independently:
- `spec:discover` + `spec:blueprint` (analyze then document)
- `spec:clarify` + `spec:checklist` (validation in parallel)
- `spec:analyze` + `spec:tasks` (validate while tasking)
- `spec:metrics` (anytime, non-blocking)

## State Transitions

Workflow phase changes are tracked in `.spec-state/current-session.md`:

```
init → initialized
generate → specification
clarify → clarification (optional)
checklist → validation (optional)
plan → planning
analyze → analysis (optional)
tasks → tasking
implement → implementation
COMPLETE → ready_for_next_feature
```

## Navigation by Context

**I'm stuck, need help**:
- Load `navigation/phase-reference.md` for detailed phase guide
- Load specific skill's `EXAMPLES.md` for patterns
- Check `CLAUDE.md` in plugin root for troubleshooting

**I want to understand everything**:
- Read `README.md` in plugin root
- Read `docs/MIGRATION-V2-TO-V3.md` for architecture
- Load each skill's `REFERENCE.md` for deep dive

**I just want to build**:
- Run `spec:orchestrate` and let automation handle workflow
- Interactive prompts will guide you through

---

**Token cost**: ~600 tokens (loaded on demand)
**Use case**: Comprehensive workflow understanding
