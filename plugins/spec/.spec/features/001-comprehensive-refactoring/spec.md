---
feature: 001
name: comprehensive-refactoring
jira_id: null
jira_url: null
created: 2025-11-03
last_synced: null
sync_direction: local-only
---

# Feature Specification: Comprehensive Codebase Refactoring

**Branch**: `refactor/comprehensive-v3.3-cleanup` | **Number**: 001 | **JIRA**: N/A
**Status**: In Progress | **Created**: 2025-11-03

## Project Artifacts

References (peer model):
- Analysis Reports: `COMPREHENSIVE-ANALYSIS.md`, `UX-ANALYSIS.md`, `UX-ANALYSIS-FLOWCHARTS.md`
- Configuration: `.claude/.spec-config.yml`
- Current Documentation: `CLAUDE.md`, `quick-start.md`

## Epics & User Stories

### Epic 1: Documentation Consistency (CRITICAL - Launch Blocker)

**Goal**: Ensure all documentation describes the actual v3.3 system, not outdated v2.x commands
**Success Metrics**:
- 0 references to deprecated commands (/spec-*, spec:specify)
- 100% alignment between CLAUDE.md and quick-start.md
- All examples use current /workflow:spec menu system

#### Story 1.1 – Rewrite Quick-Start Guide (P1)
**As a** new user **I want to** follow the quick-start guide successfully **So that** I can onboard without errors

**GitHub Issue**: #TBD
**External Tracker**: None

**Acceptance Criteria**:
- **Scenario**: New user follows quick-start
  - **Given** fresh installation
  - **When** user runs commands from quick-start.md
  - **Then** all commands work as documented
- **Scenario**: Command consistency
  - **Given** quick-start.md and CLAUDE.md
  - **When** comparing command references
  - **Then** both documents describe same /workflow:spec system

**Notes**: Complete rewrite of quick-start.md (485 lines). Remove all /spec-* commands, replace with menu-based workflow.

#### Story 1.2 – Update All Examples to Current Commands (P1)
**As a** user reading documentation **I want to** see correct command examples **So that** I can copy-paste working commands

**GitHub Issue**: #TBD
**External Tracker**: None

**Acceptance Criteria**:
- **Scenario**: Phase guide examples
  - **Given** any guide.md in phases/
  - **When** reading command examples
  - **Then** all use /workflow:spec menus, not /spec-*
- **Scenario**: Reference documentation
  - **Given** reference.md files
  - **When** searching for command references
  - **Then** 0 occurrences of deprecated commands

**Notes**: Affects 15+ files (all examples.md, reference.md, and guide.md files)

#### Story 1.3 – Remove Premature Migration Documentation (P1)
**As a** developer **I want** clean version history **So that** users aren't confused by non-existent migrations

**GitHub Issue**: #TBD
**External Tracker**: None

**Acceptance Criteria**:
- **Scenario**: Version references
  - **Given** codebase search for "migration" or "deprecated"
  - **When** reviewing results
  - **Then** only current v3.3 version documented
- **Scenario**: Hook migration mappings
  - **Given** restore-session.ts
  - **When** checking migration logic
  - **Then** no mappings for commands that never existed publicly

**Notes**: Remove version history from reference.md files, clean hooks/src/

---

### Epic 2: State Management Implementation (CRITICAL - Workflow Blocker)

**Goal**: Make state management system actually work
**Success Metrics**:
- State files created on init
- State persists across sessions
- Commands can detect and resume workflow

#### Story 2.1 – Create State File Templates (P1)
**As a** user **I want** state files automatically created **So that** workflow tracking works

**GitHub Issue**: #TBD
**External Tracker**: None

**Acceptance Criteria**:
- **Scenario**: Fresh initialization
  - **Given** no .spec/ directory
  - **When** running /workflow:spec → Initialize
  - **Then** creates current-session.md, WORKFLOW-PROGRESS.md, DECISIONS-LOG.md, etc.
- **Scenario**: Template content
  - **Given** newly created state files
  - **When** inspecting content
  - **Then** valid structure with placeholders

**Notes**: Create templates/ directory with state file templates

#### Story 2.2 – Update Init Guide to Create State Files (P1)
**As the** init process **I want to** copy templates to state directories **So that** state tracking begins immediately

**GitHub Issue**: #TBD
**External Tracker**: None

**Acceptance Criteria**:
- **Scenario**: Init execution
  - **Given** init/guide.md instructions
  - **When** following step-by-step
  - **Then** includes copying template files
- **Scenario**: Directory structure
  - **Given** completed init
  - **When** checking .spec/state/ and .spec/memory/
  - **Then** all required files exist with valid content

**Notes**: Modify phases/1-initialize/init/guide.md

#### Story 2.3 – Implement State Update Logic (P1)
**As** each phase guide **I want to** update state files **So that** progress is tracked

**GitHub Issue**: #TBD
**External Tracker**: None

**Acceptance Criteria**:
- **Scenario**: Phase completion
  - **Given** phase completes successfully
  - **When** checking current-session.md
  - **Then** phase and progress updated
- **Scenario**: Memory persistence
  - **Given** significant milestone (spec created, plan created)
  - **When** checking WORKFLOW-PROGRESS.md
  - **Then** milestone logged with timestamp

**Notes**: Update all phase guides to include state updates

---

### Epic 3: Token Optimization (HIGH PRIORITY - Performance)

**Goal**: Reduce token usage by 66% through strategic optimizations
**Success Metrics**:
- Worst-case: 115K → 40K tokens (75K saved)
- Per-workflow: 11.3K → 8.4K tokens (2.9K saved)
- Blueprint examples: 15K → 500 tokens

#### Story 3.1 – Delete Redundant Blueprint Examples (P1)
**As** the system **I want** minimal token usage **So that** context windows aren't wasted

**GitHub Issue**: #TBD
**External Tracker**: None

**Acceptance Criteria**:
- **Scenario**: Blueprint examples
  - **Given** phases/1-initialize/blueprint/examples.md
  - **When** measuring token count
  - **Then** < 1,000 tokens (was 15,392)
- **Scenario**: Template reference
  - **Given** trimmed examples.md
  - **When** users need template
  - **Then** link to templates/ directory works

**Notes**: Replace 15K token duplication with link

#### Story 3.2 – Trim Orchestrate Examples (P1)
**As** the system **I want** concise examples **So that** users get value without bloat

**GitHub Issue**: #TBD
**External Tracker**: None

**Acceptance Criteria**:
- **Scenario**: Example count
  - **Given** orchestrate/examples.md
  - **When** counting examples
  - **Then** 1-2 examples (was 7)
- **Scenario**: Coverage
  - **Given** remaining examples
  - **When** assessing usefulness
  - **Then** cover most common and most complex cases only

**Notes**: 9,841 → 2,000 tokens

#### Story 3.3 – Remove Redundant State Reads (P1)
**As** phase guides **I want** state passed from commands **So that** I don't re-read files

**GitHub Issue**: #TBD
**External Tracker**: None

**Acceptance Criteria**:
- **Scenario**: Guide execution
  - **Given** any phase guide
  - **When** searching for state file reads
  - **Then** 0 occurrences of "Read {config.paths.state}/current-session.md"
- **Scenario**: Context passing
  - **Given** command invokes guide
  - **When** guide executes
  - **Then** receives state as context parameter

**Notes**: Fix all 13 guide.md files, align with CLAUDE.md:129 principle

#### Story 3.4 – Extract TDD Documentation (P2)
**As** implement/guide.md **I want** conditional TDD loading **So that** non-TDD users save tokens

**GitHub Issue**: #TBD
**External Tracker**: None

**Acceptance Criteria**:
- **Scenario**: TDD disabled
  - **Given** workflow.tdd.enabled: false in config
  - **When** loading implement/guide.md
  - **Then** < 1,000 tokens (was 2,583, save 2,000)
- **Scenario**: TDD enabled
  - **Given** workflow.tdd.enabled: true in config
  - **When** user requests TDD details
  - **Then** load implement/tdd-guide.md progressively

**Notes**: Extract lines 47-323 to new file

#### Story 3.5 – Extract Hook Setup Documentation (P2)
**As** init/guide.md **I want** lean initialization **So that** tokens focus on essentials

**GitHub Issue**: #TBD
**External Tracker**: None

**Acceptance Criteria**:
- **Scenario**: Basic init
  - **Given** user runs init
  - **When** loading init/guide.md
  - **Then** < 1,000 tokens (was 2,034, save 1,200)
- **Scenario**: Hook customization
  - **Given** user wants hook details
  - **When** requesting reference
  - **Then** load init/hooks-setup-guide.md or reference.md

**Notes**: Extract lines 106-348 to separate file

---

### Epic 4: Command Implementation (HIGH PRIORITY - UX)

**Goal**: Implement the menu system described in command files
**Success Metrics**:
- AskUserQuestion menus functional
- State detection working
- Auto-mode with checkpoints operational

#### Story 4.1 – Implement Menu System in workflow:spec (P1)
**As** workflow:spec command **I want** executable AskUserQuestion calls **So that** users see menus

**GitHub Issue**: #TBD
**External Tracker**: None

**Acceptance Criteria**:
- **Scenario**: First-time user
  - **Given** no .spec/ directory
  - **When** running /workflow:spec
  - **Then** sees "Welcome! Initialize / Learn / Help" menu
- **Scenario**: Returning user
  - **Given** existing .spec/ with current-session.md
  - **When** running /workflow:spec
  - **Then** sees context-aware menu with current phase

**Notes**: Commands are currently aspirational, need implementation

#### Story 4.2 – Implement State Detection Logic (P1)
**As** commands **I want** to detect current workflow state **So that** I show appropriate menus

**GitHub Issue**: #TBD
**External Tracker**: None

**Acceptance Criteria**:
- **Scenario**: State file exists
  - **Given** .spec/state/current-session.md with phase: "planning"
  - **When** command reads state
  - **Then** correctly identifies phase and feature
- **Scenario**: State file missing
  - **Given** .spec/ exists but no current-session.md
  - **When** command checks state
  - **Then** gracefully handles, offers initialization

**Notes**: Add to workflow:spec.md implementation section

#### Story 4.3 – Implement Auto-Mode with Checkpoints (P1)
**As** auto-mode **I want** to execute phases with checkpoints **So that** users can review and continue

**GitHub Issue**: #TBD
**External Tracker**: None

**Acceptance Criteria**:
- **Scenario**: Auto-mode selected
  - **Given** user selects "Auto Mode"
  - **When** each phase completes
  - **Then** prompts "Continue / Refine / Review / Exit"
- **Scenario**: Resume after exit
  - **Given** user exits auto-mode mid-workflow
  - **When** running /workflow:spec again
  - **Then** offers to resume from last checkpoint

**Notes**: This is the most complex story, may need subtasks

---

### Epic 5: Configuration System Enhancement (MEDIUM PRIORITY - Reliability)

**Goal**: Make configuration robust and self-documenting
**Success Metrics**:
- Config errors show helpful messages
- Path interpolation documented
- Invalid configs rejected on init

#### Story 5.1 – Document Path Interpolation (P2)
**As a** user customizing config **I want** clear documentation **So that** I understand syntax

**GitHub Issue**: #TBD
**External Tracker**: None

**Acceptance Criteria**:
- **Scenario**: Config file
  - **Given** .claude/.spec-config.yml
  - **When** reading header comments
  - **Then** explains {state}, {spec_root} interpolation
- **Scenario**: CLAUDE.md
  - **Given** config documentation section
  - **When** reading path examples
  - **Then** explains when/how interpolation happens

**Notes**: Add comments to config.yml, update CLAUDE.md

#### Story 5.2 – Implement Config Validation (P2)
**As** the init system **I want** to validate config **So that** errors are caught early

**GitHub Issue**: #TBD
**External Tracker**: None

**Acceptance Criteria**:
- **Scenario**: Invalid paths
  - **Given** config with spec_root: "../../../outside"
  - **When** init runs
  - **Then** shows helpful error, suggests fix
- **Scenario**: Missing required fields
  - **Given** config missing paths.features
  - **When** init runs
  - **Then** rejects with clear message

**Notes**: Add validation to init/guide.md or hooks

---

### Epic 6: Reference Cleanup (LOW PRIORITY - Polish)

**Goal**: Trim reference.md files by 60% to save 22K tokens
**Success Metrics**: All reference.md < 600 tokens average (was 1,500)

#### Story 6.1 – Trim All Reference Documentation (P3)
**As** the system **I want** concise references **So that** users get essentials only

**GitHub Issue**: #TBD
**External Tracker**: None

**Acceptance Criteria**:
- **Scenario**: Token reduction
  - **Given** all 13 reference.md files
  - **When** trimming algorithms and redundant content
  - **Then** 37,426 → 15,000 tokens (22K saved)
- **Scenario**: Useful content preserved
  - **Given** trimmed references
  - **When** users need technical details
  - **Then** critical information still present

**Notes**: Focus on removing algorithmic details, link to config for schemas

---

## Edge Cases

- What if user has partially completed feature from old command system? **Migrate state to new format or offer clean start**
- How to handle corrupted state files? **Validate on read, offer recovery or reset**
- What if template files are missing? **Fail gracefully, provide clear error**
- How to handle concurrent features? **Current system supports 1 feature at a time, document limitation**

## Requirements

### Functional

- **FR-001**: System MUST create state files on initialization
- **FR-002**: System MUST update state on phase transitions
- **FR-003**: Commands MUST detect current workflow phase from state
- **FR-004**: System MUST remove all references to deprecated commands
- **FR-005**: Examples MUST use current /workflow:spec menu system
- **FR-006**: Token usage MUST NOT exceed 2,500 per phase (stretch: 1,500)
- **FR-007**: Config validation MUST catch invalid paths and provide helpful errors
- **FR-008**: Auto-mode MUST checkpoint between phases with user prompts

### Key Entities

- **Feature**: Directory in .spec/features/ with spec.md, plan.md, tasks.md
- **State**: current-session.md tracking active feature and phase
- **Memory**: WORKFLOW-PROGRESS.md, DECISIONS-LOG.md, CHANGES-*.md files
- **Phase Guide**: guide.md files in phases/ that execute workflow steps
- **Template**: Artifact templates in templates/ for spec/plan/tasks

## Success Criteria

- **SC-001**: New user completes first feature following quick-start without errors (0% error rate)
- **SC-002**: Token usage reduced by 50%+ (target: 66%)
- **SC-003**: 0 references to deprecated commands across entire codebase
- **SC-004**: State management functional: create, read, update, persist
- **SC-005**: All test scenarios (first-time, returning, auto-mode, token efficiency, config) pass
- **SC-006**: Production ready score: 2/10 → 9/10

---

## JIRA Integration

**Frontmatter metadata**: feature_id=001, jira_id=null, sync_direction=local-only
**Workflow**: Local development only, no external tracker
**Branch**: refactor/comprehensive-v3.3-cleanup
**Dir**: .spec/features/001-comprehensive-refactoring/
