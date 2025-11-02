---
description: "Task list for comprehensive refactoring implementation"
---

# Tasks: Comprehensive Codebase Refactoring

**Input**: plan.md, spec.md, COMPREHENSIVE-ANALYSIS.md, UX-ANALYSIS.md
**Organisation**: Epic → Story → Sub Task hierarchy (no overlaps between epics)
**Sub Task Naming**: `ST-[Epic#].[Story#].[Sequence]`

---

## Tracking Guidelines

- **GitHub Issues**: Every story should have a matching GitHub issue with the sub-task checklist below
- **External Tracker**: None (local development only)
- **Documentation Updates**: On completion of each epic, update COMPREHENSIVE-ANALYSIS.md status

---

## Epic 0: Pre-Implementation (GUARD - PREREQUISITE)

**Objective**: Create missing Product Requirements and Architecture Blueprint
**Dependencies**: None (must run first)
**Estimated**: 4 hours

**GUARD**: This epic MUST complete successfully before any other epic. Without PRD and Blueprint, implementation cannot proceed with proper governance.

### Story 0.1 – Create Product Requirements Document (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: PRD exists and complete
  - **Given** `.spec/product-requirements.md`
  - **When** reading document
  - **Then** contains vision, users, features, metrics, constraints, timeline

#### Sub Tasks
- [ ] ST-0.1.1 Read template: `.claude/skills/workflow/templates/project-setup/product-requirements-template.md` [0.25h]
- [ ] ST-0.1.2 Document v3.3 vision and goals [0.5h]
- [ ] ST-0.1.3 Define target users and user needs [0.25h]
- [ ] ST-0.1.4 List key features (state mgmt, menus, token optimization) [0.5h]
- [ ] ST-0.1.5 Define success metrics (0% errors, 66% token savings, 9/10 score) [0.25h]
- [ ] ST-0.1.6 Document constraints (no breaking changes, pre-launch) [0.25h]

### Story 0.2 – Create Architecture Blueprint (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: Blueprint exists and complete
  - **Given** `.spec/architecture-blueprint.md`
  - **When** reading document
  - **Then** contains architecture pattern, components, data flow, tech stack, integrations

#### Sub Tasks
- [ ] ST-0.2.1 Read template: `.claude/skills/workflow/templates/project-setup/architecture-blueprint-template.md` [0.25h]
- [ ] ST-0.2.2 Document architecture pattern (Command → State → Menus → Guides) [0.5h]
- [ ] ST-0.2.3 List all components (commands, guides, templates, state) [0.5h]
- [ ] ST-0.2.4 Map data flow (user → command → state → menu → guide → update) [0.5h]
- [ ] ST-0.2.5 Document tech stack (Markdown, YAML, Claude Code plugin) [0.25h]
- [ ] ST-0.2.6 Define integration points (templates, state files, config) [0.25h]

---

## Epic 1: Documentation Consistency (CRITICAL - Launch Blocker)

**Objective**: Ensure all documentation describes actual v3.3 system
**Dependencies**: None (can start immediately)
**Estimated**: 16 hours

### Story 1.1 – Rewrite Quick-Start Guide (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: New user follows guide
  - **Given** fresh installation
  - **When** following quick-start.md steps
  - **Then** all commands work without errors

#### Sub Tasks
- [ ] ST-1.1.1 Backup current quick-start.md to docs/archive/ [0.5h]
- [ ] ST-1.1.2 Rewrite "Your First Feature" section with /workflow:spec menus [2h]
- [ ] ST-1.1.3 Update all command examples (40+ occurrences of /spec-*) [2h]
- [ ] ST-1.1.4 Rewrite decision tree for menu-based workflow [1h]
- [ ] ST-1.1.5 Update troubleshooting section with menu navigation [1h]
- [ ] ST-1.1.6 Add visual menu flow examples [1h]
- [ ] ST-1.1.7 Manual walkthrough test of updated guide [0.5h]

### Story 1.2 – Update All Examples to Current Commands (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: All examples use correct commands
  - **Given** any guide.md, examples.md, reference.md
  - **When** searching for command references
  - **Then** 0 occurrences of deprecated /spec-* commands

#### Sub Tasks
- [ ] ST-1.2.1 Find all files with /spec-* references: `grep -r "/spec-" .claude/skills/` [0.5h]
- [ ] ST-1.2.2 Update phases/2-define/generate/guide.md examples [0.5h]
- [ ] ST-1.2.3 Update phases/2-define/clarify/guide.md examples [0.5h]
- [ ] ST-1.2.4 Update phases/3-design/plan/guide.md examples [0.5h]
- [ ] ST-1.2.5 Update all examples.md files (13 files) [3h]
- [ ] ST-1.2.6 Update all reference.md files command refs [2h]
- [ ] ST-1.2.7 Verify with grep: 0 results for "/spec-\|/spec " [0.5h]

### Story 1.3 – Remove Premature Migration Documentation (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: Clean version history
  - **Given** codebase search for "migration|deprecated|legacy"
  - **When** reviewing results
  - **Then** only references to database migrations (not command migrations)

#### Sub Tasks
- [ ] ST-1.3.1 Find all version/migration references [0.5h]
- [ ] ST-1.3.2 Remove version history from phases/2-define/generate/reference.md:839 [0.5h]
- [ ] ST-1.3.3 Clean migration mappings from hooks/src/hooks/session/restore-session.ts:48 [0.5h]
- [ ] ST-1.3.4 Search and remove other "deprecated" references [1h]
- [ ] ST-1.3.5 Verify with grep: only database migration refs remain [0.5h]

---

## Epic 2: State Management Implementation (CRITICAL - Workflow Blocker)

**Objective**: Make state management system functional
**Dependencies**: None (can run parallel to Epic 1)
**Estimated**: 8 hours

### Story 2.1 – Create State File Templates (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: Templates exist and valid
  - **Given** templates/state/ directory
  - **When** listing files
  - **Then** all 5 template files present with valid structure

#### Sub Tasks
- [ ] ST-2.1.1 Create .claude/skills/workflow/templates/state/ directory [0.25h]
- [ ] ST-2.1.2 Create current-session.md.template (YAML + Markdown) [0.5h]
- [ ] ST-2.1.3 Create WORKFLOW-PROGRESS.md.template [0.5h]
- [ ] ST-2.1.4 Create DECISIONS-LOG.md.template [0.5h]
- [ ] ST-2.1.5 Create CHANGES-PLANNED.md.template [0.5h]
- [ ] ST-2.1.6 Create CHANGES-COMPLETED.md.template [0.5h]
- [ ] ST-2.1.7 Add README.md in templates/state/ explaining each file [0.25h]

### Story 2.2 – Update Init Guide to Create State Files (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: Init creates all state files
  - **Given** phases/1-initialize/init/guide.md execution
  - **When** following steps
  - **Then** all state/memory files created from templates

#### Sub Tasks
- [ ] ST-2.2.1 Read current init/guide.md to understand flow [0.5h]
- [ ] ST-2.2.2 Add step to copy current-session.md template to .spec/state/ [1h]
- [ ] ST-2.2.3 Add step to copy memory templates to .spec/state/memory/ [1h]
- [ ] ST-2.2.4 Add validation that files were created successfully [0.5h]
- [ ] ST-2.2.5 Update init/guide.md examples section [0.5h]

### Story 2.3 – Implement State Update Logic (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: Phase completion updates state
  - **Given** any phase completes
  - **When** checking current-session.md
  - **Then** phase and timestamp updated

#### Sub Tasks
- [ ] ST-2.3.1 Add state update to phases/2-define/generate/guide.md [0.5h]
- [ ] ST-2.3.2 Add state update to phases/3-design/plan/guide.md [0.5h]
- [ ] ST-2.3.3 Add state update to phases/4-build/tasks/guide.md [0.5h]
- [ ] ST-2.3.4 Add state update to phases/4-build/implement/guide.md [0.5h]
- [ ] ST-2.3.5 Test state updates manually through workflow [1h]

---

## Epic 3: Token Optimization (HIGH PRIORITY - Performance)

**Objective**: Reduce token usage by 50%+ immediately
**Dependencies**: None (independent optimizations)
**Estimated**: 8 hours

### Story 3.1 – Delete Redundant Blueprint Examples (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: Blueprint examples < 1,000 tokens
  - **Given** phases/1-initialize/blueprint/examples.md
  - **When** measuring tokens
  - **Then** < 1,000 (was 15,392, save 14,392)

#### Sub Tasks
- [ ] ST-3.1.1 Backup blueprint/examples.md [0.25h]
- [ ] ST-3.1.2 Replace content with link to templates/project-setup/architecture-blueprint-template.md [0.5h]
- [ ] ST-3.1.3 Keep one concise example showing template usage [0.25h]

### Story 3.2 – Trim Orchestrate Examples (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: Orchestrate examples ~ 2,000 tokens
  - **Given** phases/5-track/orchestrate/examples.md
  - **When** measuring tokens
  - **Then** ~2,000 (was 9,841, save 7,841)

#### Sub Tasks
- [ ] ST-3.2.1 Backup orchestrate/examples.md [0.25h]
- [ ] ST-3.2.2 Keep Example 1 (simple case) [0.25h]
- [ ] ST-3.2.3 Keep Example 7 (complex case) [0.25h]
- [ ] ST-3.2.4 Delete Examples 2-6 [0.25h]

### Story 3.3 – Remove Redundant State Reads (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: No guides re-read state
  - **Given** all 13 phase guide.md files
  - **When** searching for "Read {config.paths.state}/current-session"
  - **Then** 0 occurrences

#### Sub Tasks
- [ ] ST-3.3.1 Find all state read occurrences in guides: `grep -r "current-session" .claude/skills/workflow/phases/*/guide.md` [0.25h]
- [ ] ST-3.3.2 Document state-passing convention in shared/state-management.md [0.5h]
- [ ] ST-3.3.3 Update phases/2-define/generate/guide.md (remove Read, note "state passed") [0.25h]
- [ ] ST-3.3.4 Update phases/3-design/plan/guide.md [0.25h]
- [ ] ST-3.3.5 Update phases/4-build/tasks/guide.md [0.25h]
- [ ] ST-3.3.6 Update phases/4-build/implement/guide.md [0.25h]
- [ ] ST-3.3.7 Update remaining 9 guides [1h]
- [ ] ST-3.3.8 Verify with grep: 0 state reads in guides [0.25h]

### Story 3.4 – Clean Deprecated Command References (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: No spec:specify references
  - **Given** full codebase search
  - **When** grepping for "spec:specify"
  - **Then** 0 results

#### Sub Tasks
- [ ] ST-3.4.1 Find all spec:specify occurrences: `grep -r "spec:specify" .claude/` [0.5h]
- [ ] ST-3.4.2 Replace in all guide.md files (10 files) [1h]
- [ ] ST-3.4.3 Replace in hooks/src/ TypeScript files [0.5h]
- [ ] ST-3.4.4 Verify with grep: 0 results [0.25h]

---

## Epic 4: Command Implementation (HIGH PRIORITY - UX)

**Objective**: Implement menu system described in command files
**Dependencies**: Epic 2 (state management) must complete first
**Estimated**: 8 hours

### Story 4.1 – Implement Menu System in workflow:spec (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: Interactive menus functional
  - **Given** user runs /workflow:spec
  - **When** command executes
  - **Then** AskUserQuestion displays context-aware menu

#### Sub Tasks
- [ ] ST-4.1.1 Read current workflow:spec.md command structure [0.5h]
- [ ] ST-4.1.2 Add state detection code block in Implementation section [1.5h]
- [ ] ST-4.1.3 Add AskUserQuestion calls for each menu state [2h]
- [ ] ST-4.1.4 Add phase guide loading logic based on selection [1.5h]
- [ ] ST-4.1.5 Test: no .spec/ → initialization menu works [0.5h]
- [ ] ST-4.1.6 Test: existing .spec/ → context-aware menu works [0.5h]

### Story 4.2 – Implement State Detection Logic (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: State detection accurate
  - **Given** various .spec/ states
  - **When** command runs
  - **Then** correct menu displayed for each state

#### Sub Tasks
- [ ] ST-4.2.1 Add .spec/ directory check [0.25h]
- [ ] ST-4.2.2 Add current-session.md read with error handling [0.5h]
- [ ] ST-4.2.3 Add YAML frontmatter parsing [0.5h]
- [ ] ST-4.2.4 Add phase/feature detection logic [0.5h]
- [ ] ST-4.2.5 Test edge cases (corrupted state, missing fields) [0.25h]

---

## Epic 5: Guide Refactoring (MEDIUM PRIORITY - Token Optimization)

**Objective**: Extract conditional content for progressive disclosure
**Dependencies**: Epic 3 complete (builds on optimization work)
**Estimated**: 16 hours

### Story 5.1 – Extract TDD Documentation (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: TDD docs separate
  - **Given** phases/4-build/implement/guide.md
  - **When** measuring tokens
  - **Then** < 1,000 (was 2,583, save 1,583)

#### Sub Tasks
- [ ] ST-5.1.1 Create phases/4-build/implement/tdd-guide.md [0.25h]
- [ ] ST-5.1.2 Copy lines 47-323 from implement/guide.md to tdd-guide.md [0.5h]
- [ ] ST-5.1.3 Replace copied section with 1-paragraph summary + link [0.5h]
- [ ] ST-5.1.4 Add progressive disclosure note: "For TDD details, ask to load tdd-guide.md" [0.25h]
- [ ] ST-5.1.5 Test: guide still functional without TDD details [0.5h]
- [ ] ST-5.1.6 Update implement/reference.md to mention tdd-guide.md [0.5h]

### Story 5.2 – Extract Hook Setup Documentation (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: Hook docs separate
  - **Given** phases/1-initialize/init/guide.md
  - **When** measuring tokens
  - **Then** < 1,000 (was 2,034, save 1,034)

#### Sub Tasks
- [ ] ST-5.2.1 Create phases/1-initialize/init/hooks-setup-guide.md OR add to reference.md [0.25h]
- [ ] ST-5.2.2 Move lines 106-348 (hook detection and generation) [0.5h]
- [ ] ST-5.2.3 Replace with high-level flow + link [0.5h]
- [ ] ST-5.2.4 Test: init still works with high-level instructions [0.5h]
- [ ] ST-5.2.5 Update init/reference.md navigation [0.25h]

### Story 5.3 – Trim Command Files (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: Commands concise
  - **Given** workflow:spec.md and workflow:track.md
  - **When** measuring tokens
  - **Then** each < 1,000 (was 2,100 and 2,050)

#### Sub Tasks
- [ ] ST-5.3.1 Remove verbatim menu duplication from workflow:spec.md lines 41-78 [0.5h]
- [ ] ST-5.3.2 Remove duplicate auto-mode description lines 186-230 [0.5h]
- [ ] ST-5.3.3 Keep only 1 example instead of 3 (lines 294-368) [0.5h]
- [ ] ST-5.3.4 Trim workflow:track.md similarly [1h]
- [ ] ST-5.3.5 Verify commands still provide enough guidance [0.5h]

### Story 5.4 – Update CLAUDE.md (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: CLAUDE.md reflects reality
  - **Given** updated codebase
  - **When** reading CLAUDE.md
  - **Then** accurate descriptions, no duplication

#### Sub Tasks
- [ ] ST-5.4.1 Remove duplicate command descriptions [1h]
- [ ] ST-5.4.2 Add section on state-passing convention [0.5h]
- [ ] ST-5.4.3 Update progressive disclosure explanation [0.5h]
- [ ] ST-5.4.4 Add lessons learned section [1h]
- [ ] ST-5.4.5 Update token efficiency notes [0.5h]

---

## Epic 6: Auto-Mode & Checkpoints (MEDIUM PRIORITY - UX Enhancement)

**Objective**: Implement auto-mode with checkpoints as described
**Dependencies**: Epic 4 (command implementation) complete
**Estimated**: 16 hours

### Story 6.1 – Design Checkpoint System (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: Checkpoint design documented
  - **Given** design doc
  - **When** reviewing checkpoint flow
  - **Then** clear state machine and resume logic

#### Sub Tasks
- [ ] ST-6.1.1 Document checkpoint state machine (phase → checkpoint → next) [2h]
- [ ] ST-6.1.2 Define checkpoint state storage in current-session.md [1h]
- [ ] ST-6.1.3 Design resume detection logic [1h]

### Story 6.2 – Implement Phase Orchestration (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: Auto-mode executes phases
  - **Given** user selects Auto Mode
  - **When** workflow executes
  - **Then** phases run sequentially with checkpoints

#### Sub Tasks
- [ ] ST-6.2.1 Create orchestration loop in workflow:spec command [2h]
- [ ] ST-6.2.2 Implement phase execution: init → generate → plan → tasks → implement [2h]
- [ ] ST-6.2.3 Add conditional phases: clarify (if [CLARIFY]), analyze (if requested) [1h]
- [ ] ST-6.2.4 Add progress tracking between phases [1h]

### Story 6.3 – Test Auto-Mode (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: Full auto-mode functional
  - **Given** user runs auto-mode
  - **When** workflow completes or pauses
  - **Then** all scenarios work (complete, pause, resume, refine)

#### Sub Tasks
- [ ] ST-6.3.1 Test: Full workflow init → implement completes [1h]
- [ ] ST-6.3.2 Test: Exit at checkpoint, resume successfully [1h]
- [ ] ST-6.3.3 Test: Refine at checkpoint, re-runs phase [1h]
- [ ] ST-6.3.4 Test: Error mid-phase, recovery works [1h]

---

## Epic 7: Configuration Enhancement (LOW PRIORITY - Polish)

**Objective**: Make configuration robust and well-documented
**Dependencies**: None (can run anytime)
**Estimated**: 12 hours

### Story 7.1 – Document Path Interpolation (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: Config self-explanatory
  - **Given** .claude/.spec-config.yml
  - **When** user reads file
  - **Then** understands {state}, {spec_root} syntax

#### Sub Tasks
- [ ] ST-7.1.1 Add header comment explaining interpolation [0.5h]
- [ ] ST-7.1.2 Add inline comments for each path [0.5h]
- [ ] ST-7.1.3 Add examples of custom paths [0.5h]
- [ ] ST-7.1.4 Update CLAUDE.md config section with interpolation rules [0.5h]

### Story 7.2 – Implement Config Validation (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: Invalid configs rejected
  - **Given** malformed config
  - **When** init runs
  - **Then** helpful error message shown

#### Sub Tasks
- [ ] ST-7.2.1 Define validation rules (required fields, path formats) [1h]
- [ ] ST-7.2.2 Implement validation in init/guide.md or hooks [3h]
- [ ] ST-7.2.3 Create helpful error messages with examples [1h]
- [ ] ST-7.2.4 Test: invalid spec_root → clear error [0.5h]
- [ ] ST-7.2.5 Test: missing paths.features → clear error [0.5h]

---

## Epic 8: Reference Trimming (LOW PRIORITY - Token Optimization)

**Objective**: Trim all reference.md files by 60%
**Dependencies**: None (can run anytime)
**Estimated**: 8 hours

### Story 8.1 – Trim All Reference Documentation (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: References concise
  - **Given** all 13 reference.md files
  - **When** measuring total tokens
  - **Then** 37,426 → 15,000 (22,426 saved)

#### Sub Tasks
- [ ] ST-8.1.1 Audit all reference.md files for redundant content [1h]
- [ ] ST-8.1.2 Trim algorithmic pseudocode (keep high-level only) [2h]
- [ ] ST-8.1.3 Remove duplicated schema definitions (link to config) [1h]
- [ ] ST-8.1.4 Condense examples in reference files [2h]
- [ ] ST-8.1.5 Verify essential information preserved [1h]
- [ ] ST-8.1.6 Measure token reduction, verify 60% goal achieved [1h]

---

## Epic 9: Final Testing & Validation (CRITICAL - Launch Gate)

**Objective**: Validate all scenarios pass before launch
**Dependencies**: All previous epics complete
**Estimated**: 8 hours

### Story 9.1 – Execute All Test Scenarios (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: All 5 test scenarios pass
  - **Given** completed refactoring
  - **When** running test checklist
  - **Then** 100% pass rate

#### Sub Tasks
- [ ] ST-9.1.1 Test Scenario 1: First-time user completes workflow [1h]
- [ ] ST-9.1.2 Test Scenario 2: Returning user resumes work [1h]
- [ ] ST-9.1.3 Test Scenario 3: Auto-mode executes with checkpoints [1h]
- [ ] ST-9.1.4 Test Scenario 4: Token efficiency < 2,500/phase [1h]
- [ ] ST-9.1.5 Test Scenario 5: Configuration validation works [1h]

### Story 9.2 – Production Ready Validation (GitHub #TBD | External: None)

**Acceptance Summary**:
- **Scenario**: Ready for launch
  - **Given** validation checklist
  - **When** reviewing all criteria
  - **Then** score: 2/10 → 9/10

#### Sub Tasks
- [ ] ST-9.2.1 Verify: All P0 issues resolved [0.5h]
- [ ] ST-9.2.2 Verify: Documentation consistent (CLAUDE.md = quick-start.md) [0.5h]
- [ ] ST-9.2.3 Verify: 0 deprecated command references (grep check) [0.5h]
- [ ] ST-9.2.4 Verify: State management functional [0.5h]
- [ ] ST-9.2.5 Verify: Token savings achieved (50%+) [0.5h]
- [ ] ST-9.2.6 Document final production ready score [0.5h]

---

## Completion Checklist

- [ ] All P0 sub tasks complete (Epics 1, 2, 4)
- [ ] All P1 sub tasks complete (Epics 3, 5, 6)
- [ ] All P2 sub tasks complete (Epic 7)
- [ ] All P3 sub tasks complete (Epic 8)
- [ ] All test scenarios pass (Epic 9)
- [ ] COMPREHENSIVE-ANALYSIS.md updated with "IMPLEMENTED" status
- [ ] Git commits organized by epic/story
- [ ] Ready for v3.3 launch

---

## Progress Tracking

**By Epic Priority**:
- [ ] **Epic 0 (GUARD): Pre-Implementation - 4h** ⚠️ MUST COMPLETE FIRST
- [ ] Epic 1 (P0): Documentation Consistency - 16h
- [ ] Epic 2 (P0): State Management - 8h
- [ ] Epic 4 (P0): Command Implementation - 8h
- [ ] Epic 3 (P1): Token Optimization - 8h
- [ ] Epic 5 (P1): Guide Refactoring - 16h
- [ ] Epic 6 (P1): Auto-Mode - 16h
- [ ] Epic 7 (P2): Configuration - 12h
- [ ] Epic 8 (P3): Reference Trimming - 8h
- [ ] Epic 9 (All): Final Testing - 8h

**Total Estimated Hours**: 104 hours

**Critical Path** (must complete for launch):
Epic 0 (GUARD) + Epics 1, 2, 4, 9 = 44 hours minimum for functional v3.3

**Recommended for Launch**:
Epic 0 + Epics 1-6, 9 = 84 hours for quality v3.3

**Complete Package**:
All epics = 104 hours for polished v3.3

**GUARD ENFORCEMENT**: Epic 0 blocks all other epics. Without PRD and Blueprint, proper governance cannot be ensured.
