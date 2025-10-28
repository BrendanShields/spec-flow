# Implementation Tasks: AskUserQuestion Integration

**Feature ID**: 002-askuserquestion-integration
**Created**: 2025-10-28
**Based on**: plan.md, spec.md
**Total Tasks**: 18
**Estimated Duration**: 5-6 hours

## Task Overview

| Phase | Tasks | Priority | Parallel | Estimated Time |
|-------|-------|----------|----------|----------------|
| Phase 1: Foundation | 4 | P1 | 3 | 30 min |
| Phase 2: US1 - Interactive Menu | 4 | P1 | 2 | 1.5 hours |
| Phase 3: US2 - Enhanced Init | 3 | P1 | 1 | 1 hour |
| Phase 4: US3 - Phase Transitions | 3 | P1 | 3 | 1.5 hours |
| Phase 5: Documentation | 3 | P1 | 2 | 45 min |
| Phase 6: Testing & Validation | 1 | P1 | 0 | 45 min |
| **Total** | **18** | - | **11** | **5-6 hours** |

---

## Phase 1: Foundation (US2, US3 Support)

**Goal**: Update config schema and add helper functions for interactive prompts.
**Dependencies**: None
**Estimated Time**: 30 minutes

### Tasks

#### T001 [P] [US2] Add interactive preferences to config schema
**Priority**: P1
**Type**: enhancement
**Estimated Time**: 10 minutes
**Dependencies**: None
**Parallel**: Yes (with T002, T003)

**Description**:
Update `init_flow_config()` in config.sh to include new interactive preferences.

**Acceptance Criteria**:
- [x] Add `preferences.interactive_mode` (default: `true`)
- [x] Add `preferences.interactive_transitions` (default: `false`)
- [x] Existing configs work without new fields
- [x] Validate config schema includes new fields

**Implementation Notes**:
```bash
# Add to config.sh init_flow_config()
"preferences": {
  "auto_checkpoint": true,
  "validate_on_save": true,
  "interactive_mode": true,
  "interactive_transitions": false
}
```

**Files to Modify**:
- `.flow/scripts/config.sh` (lines ~30-35)
- `plugins/flow/.flow/scripts/config.sh`

---

#### T002 [P] [US2] Create should_prompt_interactive helper
**Priority**: P1
**Type**: feature
**Estimated Time**: 10 minutes
**Dependencies**: T001
**Parallel**: Yes (with T001, T003)

**Description**:
Add helper function to detect if interactive prompts should be shown.

**Acceptance Criteria**:
- [x] Function `should_prompt_interactive()` created
- [x] Returns 0 (true) if should prompt, 1 (false) if skip
- [x] Checks CLI arguments first
- [x] Checks config `preferences.interactive_mode`
- [x] Checks global flag `FLOW_NO_INTERACTIVE`

**Implementation Notes**:
```bash
should_prompt_interactive() {
  # Check for CLI args
  if [ $# -gt 0 ]; then
    return 1  # Skip prompts
  fi

  # Check config
  local interactive=$(get_flow_config "preferences.interactive_mode")
  if [ "$interactive" = "false" ]; then
    return 1
  fi

  # Check global flag
  if [ "$FLOW_NO_INTERACTIVE" = "true" ]; then
    return 1
  fi

  return 0  # Show prompts
}
```

**Files to Modify**:
- `.flow/scripts/config.sh` (add function at end)
- `plugins/flow/.flow/scripts/config.sh`

---

#### T003 [P] [US3] Create should_prompt_transitions helper
**Priority**: P1
**Type**: feature
**Estimated Time**: 5 minutes
**Dependencies**: T001
**Parallel**: Yes (with T001, T002)

**Description**:
Add helper function to check if phase transition prompts are enabled.

**Acceptance Criteria**:
- [x] Function `should_prompt_transitions()` created
- [x] Reads `preferences.interactive_transitions` from config
- [x] Returns 0 if enabled, 1 if disabled

**Implementation Notes**:
```bash
should_prompt_transitions() {
  local enabled=$(get_flow_config "preferences.interactive_transitions")
  [ "$enabled" = "true" ]
}
```

**Files to Modify**:
- `.flow/scripts/config.sh` (add after should_prompt_interactive)
- `plugins/flow/.flow/scripts/config.sh`

---

#### T004 [US2] Export new helper functions
**Priority**: P1
**Type**: configuration
**Estimated Time**: 5 minutes
**Dependencies**: T002, T003
**Parallel**: No

**Description**:
Export new helper functions for use in commands and skills.

**Acceptance Criteria**:
- [x] `should_prompt_interactive` exported
- [x] `should_prompt_transitions` exported
- [x] Functions available in other scripts

**Implementation Notes**:
```bash
# At end of config.sh
export -f should_prompt_interactive
export -f should_prompt_transitions
```

**Files to Modify**:
- `.flow/scripts/config.sh` (export section)
- `plugins/flow/.flow/scripts/config.sh`

---

## Phase 2: US1 - Interactive /flow Command Menu

**Goal**: Implement visual selection menu when running `/flow` with no arguments.
**Dependencies**: Phase 1 complete
**Estimated Time**: 1.5 hours

### Tasks

#### T005 [P] [US1] Add AskUserQuestion to /flow command
**Priority**: P1
**Type**: feature
**Estimated Time**: 45 minutes
**Dependencies**: T002, T004
**Parallel**: Yes (with T006)

**Description**:
Update `.claude/commands/flow.md` to use AskUserQuestion for interactive menu.

**Acceptance Criteria**:
- [x] Check `should_prompt_interactive()` before showing menu
- [x] Build phase-aware options list using `detect_current_phase()`
- [x] Use AskUserQuestion with single-select
- [x] Header: "Flow Action" (11 chars, within limit)
- [x] Options: init, specify, plan, tasks, implement, validate, status, help
- [x] Each option has clear description
- [x] Parse response and route to skill

**Implementation Notes**:
```markdown
## Implementation

# Check if should prompt
if should_prompt_interactive; then
  # Get current phase
  current_phase=$(detect_current_phase)

  # Use AskUserQuestion tool
  {
    "questions": [{
      "question": "What would you like to do?",
      "header": "Flow Action",
      "multiSelect": false,
      "options": [...]
    }]
  }

  # Parse response and route
  case "$selected" in
    "Specify") echo "Please run: flow:specify" ;;
    ...
  esac
else
  # Show text menu (current behavior)
  render_flow_menu
fi
```

**Files to Modify**:
- `.claude/commands/flow.md` (replace implementation section)
- `plugins/flow/.claude/commands/flow.md`

---

#### T006 [P] [US1] Build phase-aware option list
**Priority**: P1
**Type**: feature
**Estimated Time**: 20 minutes
**Dependencies**: T005
**Parallel**: Yes (with T005)

**Description**:
Create logic to build options based on current workflow phase.

**Acceptance Criteria**:
- [x] Detect current phase
- [x] Include completed phases with ✅ indicator in description
- [x] Highlight next recommended step
- [x] Filter or gray out irrelevant options (future: just mark for now)
- [x] Options change based on phase

**Implementation Notes**:
```bash
current_phase=$(detect_current_phase)
suggested=$(get_next_suggested_command)

# Build options array based on phase
# Mark completed: "✅ Completed"
# Mark next: "➡️ Recommended"
# Mark not ready: "⏳ Not ready yet"
```

**Files to Modify**:
- `.claude/commands/flow.md` (option building logic)
- `plugins/flow/.claude/commands/flow.md`

---

#### T007 [US1] Handle AskUserQuestion response
**Priority**: P1
**Type**: feature
**Estimated Time**: 15 minutes
**Dependencies**: T005
**Parallel**: No

**Description**:
Parse AskUserQuestion response and route to appropriate skill or command.

**Acceptance Criteria**:
- [x] Parse selected option label
- [x] Handle "Other" option (custom text)
- [x] Route to correct skill/command
- [x] Output indication message (for Claude to invoke skill)
- [x] Handle errors gracefully

**Implementation Notes**:
```bash
# Parse response
selected=$(parse_askuserquestion_response "$response")

# Route based on selection
case "$selected" in
  "Specify")
    echo "Invoking flow:specify skill..."
    echo "Please run: flow:specify"
    ;;
  "Other:"*)
    # Custom command
    custom="${selected#Other:}"
    route_flow_command "$custom"
    ;;
esac
```

**Files to Modify**:
- `.claude/commands/flow.md` (response handling)
- `plugins/flow/.claude/commands/flow.md`

---

#### T008 [US1] Test interactive menu in all phases
**Priority**: P1
**Type**: testing
**Estimated Time**: 15 minutes
**Dependencies**: T007
**Parallel**: No

**Description**:
Test interactive `/flow` menu works correctly in each workflow phase.

**Acceptance Criteria**:
- [x] Test in init phase (no features yet)
- [x] Test in specify phase (feature exists, no spec)
- [x] Test in plan phase (spec exists, no plan)
- [x] Test in tasks phase (plan exists, no tasks)
- [x] Test in implement phase (tasks incomplete)
- [x] Test in complete phase (all done)
- [x] Verify CLI args bypass (`/flow plan` goes direct)

**Test Scenarios**:
```bash
# Scenario 1: No features
/flow → Shows init as recommended

# Scenario 2: With spec
/flow → Shows plan as recommended

# Scenario 3: With CLI arg
/flow plan → Skips menu, runs flow:plan
```

**Files to Test**:
- `.claude/commands/flow.md`

---

## Phase 3: US2 - Enhanced flow:init Interactive Prompts

**Goal**: Refine existing flow:init prompts with conditional multi-step approach.
**Dependencies**: Phase 1 complete
**Estimated Time**: 1 hour

### Tasks

#### T009 [P] [US2] Implement two-step init prompts
**Priority**: P1
**Type**: enhancement
**Estimated Time**: 30 minutes
**Dependencies**: T002, T004
**Parallel**: Yes (with T010)

**Description**:
Update flow:init to use conditional two-step AskUserQuestion prompts.

**Acceptance Criteria**:
- [x] Step 1: Ask 3 questions (project type, JIRA yes/no, Confluence yes/no)
- [x] Step 2: Only ask for keys if integration enabled
- [x] Use clear headers (within 12 char limit)
- [x] Descriptions explain each option
- [x] Store responses in variables

**Implementation Notes**:
```markdown
## Step 1: Core Configuration
{
  "questions": [
    {"question": "What type of project?", "header": "Project", ...},
    {"question": "Enable JIRA integration?", "header": "JIRA", ...},
    {"question": "Enable Confluence?", "header": "Confluence", ...}
  ]
}

## Step 2: Integration Keys (conditional)
if jira_enabled or confluence_enabled:
  {
    "questions": [
      // Only include if enabled
      {"question": "Enter JIRA project key:", "header": "JIRA Key", ...},
      {"question": "Enter Confluence page ID:", "header": "Page ID", ...}
    ]
  }
```

**Files to Modify**:
- `.claude/skills/flow-init/SKILL.md` (update workflow section)
- `plugins/flow/.claude/skills/flow-init/SKILL.md`

---

#### T010 [P] [US2] Add validation with re-prompts
**Priority**: P1
**Type**: enhancement
**Estimated Time**: 20 minutes
**Dependencies**: T009
**Parallel**: Yes (with T009)

**Description**:
Add validation for JIRA keys and Confluence page IDs, re-prompt on errors.

**Acceptance Criteria**:
- [x] Validate JIRA key format after collection
- [x] Validate Confluence page ID format
- [x] Re-prompt with error message if invalid
- [x] Use existing validation functions from config.sh
- [x] Max 3 retry attempts

**Implementation Notes**:
```bash
# After collecting response
if [ -n "$jira_key" ]; then
  if ! validate_jira_key "$jira_key"; then
    # Re-prompt with error shown
    echo "❌ Invalid JIRA key format. Please try again."
    # Show AskUserQuestion again
  fi
fi
```

**Files to Modify**:
- `.claude/skills/flow-init/SKILL.md` (validation section)
- `plugins/flow/.claude/skills/flow-init/SKILL.md`

---

#### T011 [US2] Verify CLI args skip init prompts
**Priority**: P1
**Type**: testing
**Estimated Time**: 10 minutes
**Dependencies**: T009, T010
**Parallel**: No

**Description**:
Test that providing CLI arguments skips all interactive prompts in flow:init.

**Acceptance Criteria**:
- [x] `/flow init --type=greenfield` skips project type prompt
- [x] `/flow init --jira=PROJ` skips JIRA prompts
- [x] All args provided = no prompts shown
- [x] Partial args = only remaining prompts shown

**Test Scenarios**:
```bash
# Full args - no prompts
/flow init --type=greenfield --jira=FLOW --confluence=123456

# Partial args - some prompts
/flow init --type=brownfield
# Should prompt for JIRA/Confluence only

# No args - all prompts (if interactive_mode=true)
/flow init
```

**Files to Test**:
- `.claude/skills/flow-init/SKILL.md`

---

## Phase 4: US3 - Interactive Phase Transitions

**Goal**: Add optional prompts after each workflow phase to guide next steps.
**Dependencies**: Phase 1 complete
**Estimated Time**: 1.5 hours

### Tasks

#### T012 [P] [US3] Add transition prompt to flow:specify
**Priority**: P1
**Type**: feature
**Estimated Time**: 30 minutes
**Dependencies**: T003, T004
**Parallel**: Yes (with T013, T014)

**Description**:
Add phase transition prompt at end of flow:specify skill.

**Acceptance Criteria**:
- [x] Check `should_prompt_transitions()` before showing
- [x] Ask "Specification complete! What's next?"
- [x] Options: "Create Plan", "Review Spec", "Validate Spec", "Exit"
- [x] Route based on selection
- [x] Only show if config enabled

**Implementation Notes**:
```markdown
## After Specification Complete

if should_prompt_transitions; then
  {
    "questions": [{
      "question": "Specification complete! What's next?",
      "header": "Next Step",
      "multiSelect": false,
      "options": [
        {"label": "Create Plan", "description": "Design technical architecture"},
        {"label": "Review Spec", "description": "Check specification first"},
        {"label": "Validate", "description": "Run quality checks"},
        {"label": "Exit", "description": "Continue later"}
      ]
    }]
  }

  # Handle response
  case "$selected" in
    "Create Plan") echo "Please run: flow:plan" ;;
    "Review Spec") cat "$spec_file"; exit 0 ;;
    "Validate") echo "Please run: flow:analyze" ;;
    "Exit") echo "✅ Specification saved."; exit 0 ;;
  esac
fi
```

**Files to Modify**:
- `.claude/skills/flow-specify/SKILL.md` (add at end)
- `plugins/flow/.claude/skills/flow-specify/SKILL.md`

---

#### T013 [P] [US3] Add transition prompt to flow:plan
**Priority**: P1
**Type**: feature
**Estimated Time**: 30 minutes
**Dependencies**: T003, T004
**Parallel**: Yes (with T012, T014)

**Description**:
Add phase transition prompt at end of flow:plan skill.

**Acceptance Criteria**:
- [x] Check `should_prompt_transitions()` before showing
- [x] Ask "Plan complete! What's next?"
- [x] Options: "Create Tasks", "Review Plan", "Update Plan", "Exit"
- [x] Route based on selection

**Implementation Notes**:
Similar to T012, but for plan → tasks transition.

**Files to Modify**:
- `.claude/skills/flow-plan/SKILL.md` (add at end)
- `plugins/flow/.claude/skills/flow-plan/SKILL.md`

---

#### T014 [P] [US3] Add transition prompt to flow:tasks
**Priority**: P1
**Type**: feature
**Estimated Time**: 30 minutes
**Dependencies**: T003, T004
**Parallel**: Yes (with T012, T013)

**Description**:
Add phase transition prompt at end of flow:tasks skill.

**Acceptance Criteria**:
- [x] Check `should_prompt_transitions()` before showing
- [x] Ask "Tasks ready! What's next?"
- [x] Options: "Start Implementation", "Review Tasks", "Estimate Effort", "Exit"
- [x] Route based on selection

**Implementation Notes**:
Similar to T012, but for tasks → implement transition.

**Files to Modify**:
- `.claude/skills/flow-tasks/SKILL.md` (add at end)
- `plugins/flow/.claude/skills/flow-tasks/SKILL.md`

---

## Phase 5: Documentation Updates

**Goal**: Update all documentation to reflect new interactive features.
**Dependencies**: Phase 2, 3, 4 complete
**Estimated Time**: 45 minutes

### Tasks

#### T015 [P] [US1,US2,US3] Update CLAUDE-FLOW.md with interactive mode
**Priority**: P1
**Type**: documentation
**Estimated Time**: 20 minutes
**Dependencies**: T008, T011, T014
**Parallel**: Yes (with T016)

**Description**:
Add interactive mode section to main Flow documentation.

**Acceptance Criteria**:
- [x] Add "Interactive Mode" section
- [x] Document new config options
- [x] Show interactive and CLI examples side-by-side
- [x] Explain how to disable interactive mode
- [x] Document phase transitions

**Implementation Notes**:
```markdown
## Interactive Mode

Flow provides visual menus and selections for better UX.

### Configuration
- `preferences.interactive_mode`: Enable/disable all interactive prompts
- `preferences.interactive_transitions`: Enable prompts after each phase

### Usage
# Interactive (default)
/flow                    # Shows visual menu
/flow init              # Shows interactive prompts

# CLI (bypass prompts)
/flow plan              # Direct execution
/flow init --type=...   # Args skip prompts
/flow --no-interactive  # Force non-interactive
```

**Files to Modify**:
- `.flow/docs/CLAUDE-FLOW.md` (add new section)
- `plugins/flow/.flow/docs/CLAUDE-FLOW.md`

---

#### T016 [P] [US1,US2] Update COMMANDS.md with interactive examples
**Priority**: P1
**Type**: documentation
**Estimated Time**: 15 minutes
**Dependencies**: T008, T011
**Parallel**: Yes (with T015)

**Description**:
Add interactive examples to commands reference.

**Acceptance Criteria**:
- [x] Update `/flow` command docs with interactive menu info
- [x] Update `/flow init` docs with both modes
- [x] Add `--no-interactive` flag documentation
- [x] Show example outputs

**Files to Modify**:
- `.flow/docs/COMMANDS.md` (update command entries)
- `plugins/flow/.flow/docs/COMMANDS.md`

---

#### T017 [US1,US2,US3] Update ARCHITECTURE.md with ADRs
**Priority**: P1
**Type**: documentation
**Estimated Time**: 10 minutes
**Dependencies**: T015, T016
**Parallel**: No

**Description**:
Add ADR-007 through ADR-011 to architecture documentation.

**Acceptance Criteria**:
- [x] Add all 5 ADRs from plan.md
- [x] Include context, decision, rationale, alternatives
- [x] Link to implementation files
- [x] Update architecture diagram if needed

**Files to Modify**:
- `.flow/docs/ARCHITECTURE.md` (add ADRs section)
- `plugins/flow/.flow/docs/ARCHITECTURE.md`

---

## Phase 6: Testing & Validation

**Goal**: Comprehensive end-to-end testing of all interactive features.
**Dependencies**: All previous phases complete
**Estimated Time**: 45 minutes

### Tasks

#### T018 [US1,US2,US3] End-to-end interactive workflow test
**Priority**: P1
**Type**: testing
**Estimated Time**: 45 minutes
**Dependencies**: All previous tasks
**Parallel**: No

**Description**:
Test complete workflow using interactive mode and verify all features work.

**Acceptance Criteria**:
- [x] Test interactive `/flow` menu in all phases
- [x] Test flow:init with all prompt combinations
- [x] Test phase transitions (enabled and disabled)
- [x] Test CLI args bypass all prompts
- [x] Test `--no-interactive` flag
- [x] Test config toggles
- [x] Test "Other" option text inputs
- [x] Test validation error re-prompts
- [x] Verify backward compatibility (no regressions)

**Test Scenarios**:

**Scenario 1: Full Interactive Workflow**
```bash
# Enable transitions for test
set_flow_config "preferences.interactive_transitions" "true"

# Start fresh
/flow
# Select "Init"
# Answer: Brownfield, No JIRA, No Confluence
# Config created

/flow
# Select "Specify"
# Enter: "Test feature"
# Spec created
# Transition prompt appears
# Select "Create Plan"
# Plan created automatically

# Continue through tasks and implement
```

**Scenario 2: Power User CLI Mode**
```bash
/flow init --type=greenfield --jira=FLOW
/flow specify "Feature"
/flow plan
/flow tasks
# No prompts, direct execution
```

**Scenario 3: Mixed Mode**
```bash
/flow init --type=brownfield
# Prompts for JIRA/Confluence (args not provided)
# Select Yes for JIRA
# Type "PROJ" in Other field
# Validation passes, config created
```

**Scenario 4: Error Handling**
```bash
/flow init
# Select Greenfield
# Select Yes for JIRA
# Type invalid key: "123invalid"
# Validation error shown
# Re-prompted with error message
# Type valid key: "PROJ"
# Success
```

**Scenario 5: Config Disabled**
```bash
set_flow_config "preferences.interactive_mode" "false"
/flow
# Shows text menu (old behavior)
# No AskUserQuestion

/flow init
# No prompts, uses defaults or fails if missing required args
```

**Validation Checklist**:
- [x] No broken workflows
- [x] All commands functional
- [x] Backward compatibility maintained
- [x] Config options work
- [x] Error messages clear
- [x] Performance acceptable
- [x] Documentation accurate

**Files to Test**:
- All updated files from previous phases

---

## Summary

**Total Tasks**: 18
**Parallelizable**: 11 (61%)
**Sequential**: 7 (39%)

**Estimated Time by Priority**:
- P1 Tasks: 18 tasks, 5-6 hours

**Critical Path**:
T001 → T002 → T004 → T005 → T007 → T008 → T018

**Parallel Opportunities**:
- Phase 1: T001, T002, T003 (all parallel)
- Phase 2: T005, T006 (parallel)
- Phase 4: T012, T013, T014 (all parallel)
- Phase 5: T015, T016 (parallel)

**Dependencies**:
- Phase 2-4 depend on Phase 1 (config helpers)
- Phase 5 depends on Phase 2-4 (implementations done)
- Phase 6 depends on everything (comprehensive testing)

---

**Next Step**: Run `/flow implement` to begin executing these tasks autonomously!
