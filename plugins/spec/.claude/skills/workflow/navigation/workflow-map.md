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
  │                        │ discover phase│◄──[Brownfield]
  │                        └──────┬───────┘
  │                               ▼
  ├──────────────────────►┌──────────────┐
  │                        │  initialize phase   │
  │                        └──────┬───────┘
  │                               ▼
  │                        ┌──────────────┐
  │                        │blueprint phase│◄──[Define Architecture]
  │                        └──────┬───────┘
  │                               │
  ▼                               │
┌─────────────────────────────────┴────────────────────┐
│              PHASE 1: INITIALIZE                     │
│  Setup project structure and architecture            │
└──────────────────────────┬───────────────────────────┘
                           ▼
                    ┌──────────────┐
                    │generate phase │◄──[New Feature]
                    └──────┬───────┘
                           ▼
                    ┌──────────────┐
              ┌────►│clarify phase  │
              │     └──────┬───────┘
              │            ▼
   [Questions]│     ┌──────────────┐
              └─────┤checklist phase│
                    └──────┬───────┘
┌─────────────────────────┴────────────────────┐
│         PHASE 2: DEFINE REQUIREMENTS         │
│  Create and validate feature specifications  │
└──────────────────────┬───────────────────────┘
                       ▼
                ┌──────────────┐
                │  plan phase   │
                └──────┬───────┘
                       ▼
                ┌──────────────┐
                │analyze phase  │◄──[Validation]
                └──────┬───────┘
┌───────────────────────┴──────────────────────┐
│       PHASE 3: DESIGN SOLUTION               │
│  Technical planning and validation           │
└──────────────────────┬───────────────────────┘
                       ▼
                ┌──────────────┐
                │  tasks phase  │
                └──────┬───────┘
                       ▼
                ┌──────────────┐
                │implement phase│
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
│ update phase    - Modify specifications            │
│ metrics phase   - View progress and analytics      │
│ orchestrate phase - Automate full workflow         │
└────────────────────────────────────────────────────┘
```

## Phase Progression

### Phase 1: Initialize (1-2 hours)
**Entry**: New project or new to Spec
**Skills**: init → discover/blueprint
**Output**: `{config.paths.spec_root}/` structure, architecture blueprint
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
- New project? → `initialize phase`
- Existing codebase? → `discover phase` then `initialize phase`
- New feature? → `generate phase`
- Mid-feature? → Check `{config.paths.state}/current-session.md`

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
│  ├─ New project? → initialize phase
│  └─ Existing code? → discover phase → initialize phase
│
├─ Define architecture?
│  └─ → blueprint phase
│
├─ Build feature?
│  ├─ Have spec?
│  │  ├─ Yes → plan phase
│  │  └─ No → generate phase
│  │
│  ├─ Have plan?
│  │  ├─ Yes → tasks phase
│  │  └─ No → plan phase
│  │
│  └─ Have tasks?
│     ├─ Yes → implement phase
│     └─ No → tasks phase
│
├─ Modify requirements?
│  └─ → update phase
│
├─ Check progress?
│  └─ → metrics phase
│
└─ Automate everything?
   └─ → orchestrate phase
```

## Time Estimates

**By Phase**:
- Initialize: 1-2 hours (one-time per project)
- Define: 30min - 2 hours per feature
- Design: 45min - 3 hours per feature
- Build: 2-20 hours per feature (varies by complexity)
- Track: 5-10 min per check-in

**By Skill** (average):
- `initialize phase`: 15-30 min
- `discover phase`: 30-60 min
- `blueprint phase`: 45-90 min
- `generate phase`: 20-45 min
- `clarify phase`: 10-30 min
- `checklist phase`: 15-30 min
- `plan phase`: 30-90 min
- `analyze phase`: 10-20 min
- `tasks phase`: 20-45 min
- `implement phase`: 2-20 hours
- `update phase`: 15-45 min
- `metrics phase`: 2-5 min
- `orchestrate phase`: Full feature cycle (3-25 hours)

## Parallel Work Opportunities

Skills that can run independently:
- `discover phase` + `blueprint phase` (analyze then document)
- `clarify phase` + `checklist phase` (validation in parallel)
- `analyze phase` + `tasks phase` (validate while tasking)
- `metrics phase` (anytime, non-blocking)

## State Transitions

Workflow phase changes are tracked in `{config.paths.state}/current-session.md`:

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
- Load `phase-reference.md` for detailed phase guide
- Load specific skill's `EXAMPLES.md` for patterns
- Check `claude.md` in plugin root for troubleshooting

**I want to understand everything**:
- Read `readme.md` in plugin root
- Read `docs/MIGRATION-V2-TO-V3.md` for architecture
- Load each skill's `REFERENCE.md` for deep dive

**I just want to build**:
- Run `orchestrate phase` and let automation handle workflow
- Interactive prompts will guide you through

---

**Token cost**: ~600 tokens (loaded on demand)
**Use case**: Comprehensive workflow understanding
