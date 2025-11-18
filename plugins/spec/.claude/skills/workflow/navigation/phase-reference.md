# Phase Reference Guide

Complete reference for all 5 workflow phases with decision trees and transition logic.

## Phase Overview

```
Phase 1: Initialize    (1-2 hours, one-time)
   ↓
Phase 2: Define        (30min-2h per feature)
   ↓
Phase 3: Design        (45min-3h per feature)
   ↓
Phase 4: Build         (2-20h per feature)
   ↓
Phase 5: Track         (ongoing)
```

## Phase 1: Initialize

**Goal**: Setup project infrastructure
**Frequency**: Once per project
**Duration**: 1-2 hours
**Skills**: init ⭐ CORE | discover 🔧, blueprint 🔧

### Entry Criteria
- [ ] New project OR adding Spec to existing code
- [ ] Git repository initialized
- [ ] Team ready to adopt workflow

### Decision Tree
```
Is this a new project?
├─ Yes (Greenfield)
│  ├─ initialize phase
│  └─ blueprint phase (define ideal architecture)
│
└─ No (Brownfield)
   ├─ discover phase (analyze existing code)
   ├─ initialize phase
   └─ blueprint phase --from-discovery
```

### Exit Criteria
- [x] `{config.paths.spec_root}/` structure exists
- [x] State management initialized
- [x] Architecture documented (or consciously skipped)
- [x] Team aligned on standards

### Artifacts Created
- `{config.paths.spec_root}/product-requirements.md`
- `{config.paths.spec_root}/architecture-blueprint.md` (if blueprint run)
- `{config.paths.state}/current-session.md`
- `{config.paths.memory}/workflow-progress.md`
- `{config.paths.memory}/decisions-log.md`
- `discovery/` reports (if discover run)

### Next Phase
→ Phase 2 (Define Requirements)

---

## Phase 2: Define Requirements

**Goal**: Create validated feature specifications
**Frequency**: Once per feature
**Duration**: 30 minutes - 2 hours
**Skills**: generate ⭐ CORE | clarify 🔧, checklist 🔧

### Entry Criteria
- [ ] Phase 1 complete (`{config.paths.spec_root}/` initialized)
- [ ] Feature idea or requirement identified
- [ ] Product requirements understood

### Decision Tree
```
Have requirements?
└─ generate phase "Feature description"
   │
   Has [CLARIFY] tags or vague terms?
   ├─ Yes → clarify phase
   │        ├─ Repeat if needed
   │        └─ Continue
   │
   Need quality validation?
   ├─ Yes → checklist phase
   │        ├─ Review checklists
   │        ├─ Fix gaps
   │        └─ Continue
   │
   └─ Ready for Phase 3
```

### Exit Criteria
- [x] `spec.md` exists with user stories
- [x] All [CLARIFY] tags resolved (or deferred)
- [x] Acceptance criteria specific and measurable
- [x] Priorities assigned (P1/P2/P3)
- [x] Quality checklists validated (if required)
- [x] Stakeholders approved

### Artifacts Created
- `{config.paths.features}/NNN-feature-name/{config.naming.files.spec}`
- `{config.paths.features}/NNN-feature-name/checklists/` (if checklist run)
- Updated `{config.paths.memory}/decisions-log.md` (clarifications)

### Next Phase
→ Phase 3 (Design Solution)

---

## Phase 3: Design Solution

**Goal**: Create technical design and validate
**Frequency**: Once per feature
**Duration**: 45 minutes - 3 hours
**Skills**: plan ⭐ CORE | analyze 🔧

### Entry Criteria
- [ ] Phase 2 complete (`spec.md` approved)
- [ ] Requirements clear and measurable
- [ ] Architecture blueprint available (if exists)

### Decision Tree
```
plan phase (create technical design)
   │
   Complex feature (>15 tasks) OR team requires validation?
   ├─ Yes → analyze phase
   │        │
   │        Has CRITICAL or HIGH issues?
   │        ├─ Yes → Fix issues
   │        │        └─ Re-run analyze phase
   │        └─ No → Continue
   │
   └─ Ready for Phase 4
```

### Exit Criteria
- [x] `plan.md` exists with complete technical design
- [x] ADRs documented for major decisions
- [x] Data models defined
- [x] API contracts specified
- [x] `analyze phase` shows no CRITICAL issues
- [x] Security considerations addressed
- [x] Team approved technical approach

### Artifacts Created
- `{config.paths.features}/NNN-feature-name/{config.naming.files.plan}`
- `{config.paths.memory}/decisions-log.md` (ADRs)
- `{config.paths.state}/analysis-report-{timestamp}.md` (if analyze run)

### Next Phase
→ Phase 4 (Build Feature)

---

## Phase 4: Build Feature

**Goal**: Implement and test feature
**Frequency**: Once per feature
**Duration**: 2-20 hours (varies)
**Skills**: tasks ⭐ CORE, implement ⭐ CORE

### Entry Criteria
- [ ] Phase 3 complete (`plan.md` approved)
- [ ] Technical approach agreed
- [ ] Dependencies available

### Decision Tree
```
tasks phase (break down into tasks)
   │
   Large feature OR parallel work possible?
   ├─ implement phase --parallel
   └─ implement phase
      │
      Interrupted?
      ├─ implement phase --continue
      │
      Need specific priority?
      ├─ implement phase --filter=P1
      │
      All tasks complete AND tests passing?
      └─ Ready for Phase 5
```

### Exit Criteria
- [x] All P1 tasks completed
- [x] All tests passing
- [x] Code committed to version control
- [x] Acceptance criteria satisfied
- [x] No critical bugs
- [x] Feature functional

### Artifacts Created
- `{config.paths.features}/NNN-feature-name/{config.naming.files.tasks}`
- Implemented code changes
- Updated `{config.paths.memory}/changes-completed.md`
- Updated `{config.paths.state}/current-session.md`

### Next Phase
→ Phase 5 (Track) OR new feature

---

## Phase 5: Track Progress

**Goal**: Maintain specs and monitor progress
**Frequency**: Ongoing throughout project
**Duration**: Varies by task
**Skills**: update 🔧, metrics 🔧, orchestrate 🔧 (all tools)

### Entry Criteria
- [ ] Anytime during or after Phases 1-4

### Decision Tree
```
What do you need?

├─ Requirements changed?
│  └─ update phase
│     └─ analyze phase
│        └─ tasks phase --update
│
├─ Check progress?
│  └─ metrics phase
│
├─ Automate feature?
│  └─ orchestrate phase
│     ├─ Interrupted? → orchestrate phase --resume
│     └─ Quick mode? → orchestrate phase --auto
│
└─ Continue existing workflow
   └─ Return to appropriate phase
```

### No Exit Criteria
Phase 5 is continuous throughout project lifecycle

### Artifacts Modified
- `spec.md` (via update phase)
- `plan.md` (propagated from updates)
- `tasks.md` (propagated from updates)
- `{config.paths.memory}/workflow-progress.md` (metrics)
- `{config.paths.state}/checkpoints/` (orchestrate)

---

## Phase Transitions

### Automatic Transitions
These happen naturally in workflow:
- Phase 1 → Phase 2: After initialization
- Phase 2 → Phase 3: After spec approval
- Phase 3 → Phase 4: After plan approval
- Phase 4 → Complete: After implementation

### Manual Transitions
These require explicit decisions:
- Phase 2 ↔ Phase 5: Requirements change → update phase
- Phase 3 ↔ Phase 5: Design change → update phase → plan phase
- Phase 4 ↔ Phase 5: Implementation change → update phase → tasks phase

### Skipped Transitions
Optional phases that can be skipped:
- Phase 1 blueprint: Skip for minimal setup
- Phase 2 clarify: Skip if no [CLARIFY] tags
- Phase 2 checklist: Skip if no quality gates
- Phase 3 analyze: Skip for simple features (<10 tasks)

## State Tracking

### Phase Indicators in `{config.paths.state}/current-session.md`

```markdown
## Active Work
### Current Feature
- **Feature ID**: 003
- **Feature Name**: user-authentication
- **Phase**: planning        ← Current phase
- **Started**: 2025-10-31
```

**Phase values**:
- `initialized` - Phase 1 complete
- `specification` - Phase 2 in progress
- `clarification` - Phase 2 clarifying
- `planning` - Phase 3 in progress
- `analysis` - Phase 3 analyzing
- `tasking` - Phase 4 breaking down
- `implementation` - Phase 4 implementing
- `complete` - Phase 4 done

### Progress Tracking in `{config.paths.memory}/workflow-progress.md`

```markdown
### Active Features
| Feature | Phase | Progress | Started | ETA |
|---------|-------|----------|---------|-----|
| 003-user-auth | Planning | 60% | Oct 31 | Nov 2 |
```

## Time Estimates

**By Phase** (typical feature):
- Phase 1: 1-2 hours (one-time)
- Phase 2: 30min - 2 hours
- Phase 3: 45min - 3 hours
- Phase 4: 2-20 hours
- Phase 5: 2-45 minutes per task

**Total Feature Cycle**:
- Simple feature: 3-5 hours
- Medium feature: 8-15 hours
- Complex feature: 20-30 hours

**Automation** (orchestrate phase):
- Automates Phases 2-4
- Duration: Same as manual but hands-off
- Requires periodic prompts and decisions

## Common Phase Issues

### Phase 1: Initialize
**Issue**: Already initialized error
**Solution**: `initialize phase --force` or skip to Phase 2

### Phase 2: Define
**Issue**: Too many [CLARIFY] tags
**Solution**: Run `clarify phase` multiple times (4 questions/session)

### Phase 3: Design
**Issue**: Validation shows CRITICAL issues
**Solution**: Fix issues, update spec/plan, re-analyze

### Phase 4: Build
**Issue**: Implementation blocked
**Solution**: `implement phase --continue` after unblocking

### Phase 5: Track
**Issue**: Metrics show no data
**Solution**: Need ≥1 completed feature for metrics

## Quick Phase Selection

**I need to...**
- Setup project → Phase 1 (Initialize)
- Define feature → Phase 2 (Define)
- Design solution → Phase 3 (Design)
- Build feature → Phase 4 (Build)
- Change requirements → Phase 5 (Track: update phase)
- Check progress → Phase 5 (Track: metrics phase)
- Automate everything → Phase 5 (Track: orchestrate phase)

**I'm stuck in...**
- Phase 2 (too many ambiguities) → Load `spec-clarify/EXAMPLES.md`
- Phase 3 (plan too vague) → Load `spec-plan/EXAMPLES.md`
- Phase 4 (tasks too large) → Load `spec-tasks/EXAMPLES.md`

---

**For visual workflow**: See `workflow-map.md`
**For skill details**: See `skill-index.md`
**For phase deep-dive**: See `phases/[N]-[name].md`
