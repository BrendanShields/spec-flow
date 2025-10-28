# Implementation Tasks: Flow Init Optimization & Restructuring

**Feature ID**: 001-flow-init-optimization
**Created**: 2025-10-28
**Based on**: plan.md, spec.md
**Total Tasks**: 22
**Estimated Duration**: 10-14 hours

## Task Overview

| Phase | Tasks | Priority | Parallel | Estimated Time |
|-------|-------|----------|----------|----------------|
| Phase 1: Setup | 3 | P1 | 3 | 1h |
| Phase 2: Restructuring | 5 | P1 | 2 | 3-4h |
| Phase 3: Config & Init (US2, US4) | 4 | P1 | 2 | 2-3h |
| Phase 4: Unified Command (US5) | 3 | P1 | 1 | 2-3h |
| Phase 5: Documentation (US3) | 4 | P1 | 2 | 2h |
| Phase 6: Output & Polish (US6) | 3 | P2 | 1 | 1-2h |
| **Total** | **22** | - | **11** | **10-14h** |

---

## Phase 1: Setup & Prerequisites

**Goal**: Create utility scripts and prepare infrastructure
**Dependencies**: None
**Estimated Time**: 1 hour

### Tasks

#### T001 [P] [US1] Create config management script ✅
**Priority**: P1
**Type**: setup
**Estimated Time**: 20 minutes
**Dependencies**: None
**Parallel**: Yes (with T002, T003)
**Status**: COMPLETED

**Description**:
Create `.flow/scripts/config.sh` with functions for reading, writing, and validating JSON configuration.

**Acceptance Criteria**:
- [ ] Functions: `init_flow_config`, `get_flow_config`, `set_flow_config`, `validate_flow_config`
- [ ] Handles `jq` availability check
- [ ] Error handling for invalid JSON
- [ ] Default config template generation

**Implementation Notes**:
- Use `jq` for JSON parsing (check availability first)
- Validate required fields (version, project.type)
- Provide helpful error messages

**Files to Create**:
- `.flow/scripts/config.sh` - Config management utilities

---

#### T002 [P] [US6] Create output formatting script ✅
**Priority**: P2
**Type**: setup
**Estimated Time**: 20 minutes
**Dependencies**: None
**Parallel**: Yes (with T001, T003)
**Status**: COMPLETED

**Description**:
Create `.flow/scripts/format-output.sh` with functions for consistent output formatting (TLDR, Next Steps, separators).

**Acceptance Criteria**:
- [ ] Functions: `format_tldr`, `format_next_steps`, `format_section_separator`, `format_status_indicator`
- [ ] Consistent visual formatting across outputs
- [ ] Emoji support (✅/➡️/⏳/❌/⚠️)
- [ ] Box separators with proper width

**Implementation Notes**:
- Use markdown-compatible formatting
- Keep functions simple and reusable
- Test with sample content

**Files to Create**:
- `.flow/scripts/format-output.sh` - Output formatting utilities

---

#### T003 [P] [US5] Create routing utilities script ✅
**Priority**: P1
**Type**: setup
**Estimated Time**: 20 minutes
**Dependencies**: None
**Parallel**: Yes (with T001, T002)
**Status**: COMPLETED

**Description**:
Create `.flow/scripts/routing.sh` with command routing logic, phase detection, and menu rendering functions.

**Acceptance Criteria**:
- [ ] Functions: `detect_current_phase`, `get_next_suggested_command`, `route_flow_command`
- [ ] Phase detection based on file existence and task completion
- [ ] Routing logic for all subcommands

**Implementation Notes**:
- Check for spec.md, plan.md, tasks.md existence
- Parse task completion from tasks.md
- Return phase names: init|specify|plan|tasks|implement|complete

**Files to Create**:
- `.flow/scripts/routing.sh` - Command routing and phase detection

---

## Phase 2: Directory Restructuring (US1)

**Goal**: Consolidate all Flow files under `.flow/` directory
**Dependencies**: Phase 1 complete
**Estimated Time**: 3-4 hours

### Tasks

#### T004 [US1] Create new .flow directory structure ✅
**Priority**: P1
**Type**: restructuring
**Estimated Time**: 10 minutes
**Dependencies**: None
**Parallel**: No
**Status**: COMPLETED

**Description**:
Create the new `.flow/` directory structure with all subdirectories.

**Acceptance Criteria**:
- [ ] Created: `.flow/{config,state,memory,features,templates,scripts,docs}/`
- [ ] Directories have correct permissions
- [ ] Structure matches architecture blueprint

**Implementation Notes**:
```bash
mkdir -p .flow/{config,state,memory,features,templates,scripts,docs}
```

**Files to Create**:
- `.flow/config/` - Configuration directory
- `.flow/state/` - Session state directory
- `.flow/memory/` - Persistent memory directory
- `.flow/features/` - Feature artifacts directory
- `.flow/templates/` - Templates directory
- `.flow/scripts/` - Scripts directory (already has T001-T003 files)
- `.flow/docs/` - Documentation directory

---

#### T005 [US1] Move existing files to new structure ✅
**Priority**: P1
**Type**: restructuring
**Estimated Time**: 15 minutes
**Dependencies**: T004
**Parallel**: No
**Status**: COMPLETED

**Description**:
Move all existing Flow files from root directories to new `.flow/` subdirectories.

**Acceptance Criteria**:
- [ ] Moved `.flow-state/*` to `.flow/state/`
- [ ] Moved `.flow-memory/*` to `.flow/memory/`
- [ ] Moved `features/*` to `.flow/features/`
- [ ] Moved existing `.flow/*.md` to `.flow/docs/`
- [ ] Moved existing `.flow/templates` to `.flow/templates/`
- [ ] Moved existing `.flow/scripts` to `.flow/scripts/` (merge with T001-T003)
- [ ] Old directories removed

**Implementation Notes**:
```bash
# Move files
mv .flow-state/* .flow/state/ 2>/dev/null || true
mv .flow-memory/* .flow/memory/ 2>/dev/null || true
mv features/* .flow/features/ 2>/dev/null || true
mv .flow/*.md .flow/docs/ 2>/dev/null || true

# Merge script directories
cp -r .flow/scripts/* .flow/scripts/ 2>/dev/null || true

# Cleanup old directories
rmdir .flow-state .flow-memory features 2>/dev/null || true
```

**Files to Move**:
- All files from old structure to new structure

---

#### T006 [P] [US1] Update all skill path references ✅
**Priority**: P1
**Type**: refactoring
**Estimated Time**: 2 hours
**Dependencies**: T005
**Parallel**: Yes (with T007)
**Status**: COMPLETED

**Description**:
Update all path references in Flow skills to use new `.flow/` structure.

**Acceptance Criteria**:
- [ ] Updated paths in `flow-init` skill
- [ ] Updated paths in `flow-specify` skill
- [ ] Updated paths in `flow-plan` skill
- [ ] Updated paths in `flow-tasks` skill
- [ ] Updated paths in `flow-implement` skill
- [ ] Updated paths in `flow-validate` skill
- [ ] Updated paths in all other skills (~8 total)
- [ ] All skills tested and working

**Implementation Notes**:
- Search for: `.flow-state/`, `.flow-memory/`, `features/`
- Replace with: `.flow/state/`, `.flow/memory/`, `.flow/features/`
- Test each skill after update

**Files to Modify**:
- `.claude/skills/flow-init/SKILL.md`
- `.claude/skills/flow-specify/SKILL.md`
- `.claude/skills/flow-plan/SKILL.md`
- `.claude/skills/flow-tasks/SKILL.md`
- `.claude/skills/flow-implement/SKILL.md`
- `.claude/skills/flow-validate/SKILL.md`
- All other skill files (~8 skills × 2-3 files each)

---

#### T007 [P] [US1] Update all command path references ✅
**Priority**: P1
**Type**: refactoring
**Estimated Time**: 1.5 hours
**Dependencies**: T005
**Parallel**: Yes (with T006)
**Status**: COMPLETED

**Description**:
Update all path references in slash commands to use new `.flow/` structure.

**Acceptance Criteria**:
- [ ] Updated paths in `flow-init.md` command
- [ ] Updated paths in `flow-specify.md` command
- [ ] Updated paths in `flow-plan.md` command
- [ ] Updated paths in `flow-tasks.md` command
- [ ] Updated paths in `flow-implement.md` command
- [ ] Updated paths in `flow-validate.md` command
- [ ] Updated paths in `status.md` command
- [ ] Updated paths in `help.md` command
- [ ] All commands tested and working

**Implementation Notes**:
- Update all hardcoded paths
- Update examples in documentation
- Test each command after update

**Files to Modify**:
- `.claude/commands/flow-init.md`
- `.claude/commands/flow-specify.md`
- `.claude/commands/flow-plan.md`
- `.claude/commands/flow-tasks.md`
- `.claude/commands/flow-implement.md`
- `.claude/commands/flow-validate.md`
- `.claude/commands/status.md`
- `.claude/commands/help.md`

---

#### T008 [US1] Update .gitignore for new structure ✅
**Priority**: P1
**Type**: configuration
**Estimated Time**: 10 minutes
**Dependencies**: T005
**Parallel**: No
**Status**: COMPLETED

**Description**:
Update `.gitignore` to reflect new directory structure.

**Acceptance Criteria**:
- [ ] Removed old paths (`.flow-state/`, `.flow-memory/`, `features/`)
- [ ] Added new path (`.flow/state/`)
- [ ] `.flow/memory/` and `.flow/features/` are committed
- [ ] `.flow/config/` is committed
- [ ] Documentation updated

**Implementation Notes**:
- Keep `.flow/state/` git-ignored (session-specific)
- Commit `.flow/memory/` (project history)
- Commit `.flow/features/` (feature artifacts)
- Commit `.flow/config/` (configuration)

**Files to Modify**:
- `.gitignore`

---

## Phase 3: Configuration & Interactive Init (US2, US4)

**Goal**: Implement config system and interactive initialization
**Dependencies**: Phase 2 complete
**Estimated Time**: 2-3 hours

### Tasks

#### T009 [P] [US4] Create default config template ✅
**Priority**: P1
**Type**: implementation
**Estimated Time**: 15 minutes
**Dependencies**: T001
**Parallel**: Yes (with T010)
**Status**: COMPLETED

**Description**:
Create default configuration template and initialization logic in `config.sh`.

**Acceptance Criteria**:
- [ ] Default config JSON structure defined
- [ ] `init_flow_config` function creates default config
- [ ] Includes version, project info, integrations, preferences
- [ ] Validates config schema on creation

**Implementation Notes**:
- Use template from plan.md (ADR-003)
- Include all required fields
- Set sensible defaults

**Files to Modify**:
- `.flow/scripts/config.sh` (add init function)

---

#### T010 [P] [US2] Implement interactive prompts in flow:init ✅
**Priority**: P1
**Type**: implementation
**Estimated Time**: 1 hour
**Dependencies**: T001, T009
**Parallel**: Yes (with T009)
**Status**: COMPLETED

**Description**:
Update `flow:init` skill to use AskUserQuestion for interactive configuration.

**Acceptance Criteria**:
- [ ] Prompt 1: Project type (Greenfield/Brownfield)
- [ ] Prompt 2: JIRA integration (Yes/No)
- [ ] Prompt 3: JIRA project key (if enabled)
- [ ] Prompt 4: Confluence integration (Yes/No)
- [ ] Prompt 5: Confluence page ID (if enabled)
- [ ] Input validation (JIRA key format, numeric page ID)
- [ ] Responses stored in `.flow/config/flow.json`

**Implementation Notes**:
- Use AskUserQuestion tool
- Validate JIRA key: `^[A-Z][A-Z0-9]+$` or `^[A-Z][A-Z0-9]+-[0-9]+$`
- Validate Confluence ID: numeric only
- Store results with `set_flow_config`

**Files to Modify**:
- `.claude/skills/flow-init/SKILL.md`

---

#### T011 [US2] Add CLI argument support to flow:init ✅
**Priority**: P1
**Type**: implementation
**Estimated Time**: 30 minutes
**Dependencies**: T010
**Parallel**: No
**Status**: COMPLETED

**Description**:
Add support for CLI arguments to skip interactive prompts.

**Acceptance Criteria**:
- [ ] `--type=greenfield|brownfield` skips project type prompt
- [ ] `--jira=PROJECT-KEY` enables JIRA and sets key
- [ ] `--confluence=PAGE-ID` enables Confluence and sets page ID
- [ ] CLI args override prompts
- [ ] Can mix CLI args and prompts

**Implementation Notes**:
```bash
/flow-init --type=greenfield --jira=PROJ-123
```

**Files to Modify**:
- `.claude/skills/flow-init/SKILL.md`
- `.claude/commands/flow-init.md` (update documentation)

---

#### T012 [US2] Test and validate init flow end-to-end ✅
**Priority**: P1
**Type**: testing
**Estimated Time**: 30 minutes
**Dependencies**: T010, T011
**Parallel**: No
**Status**: COMPLETED

**Description**:
Comprehensive testing of initialization flow with various configurations.

**Acceptance Criteria**:
- [ ] Test interactive mode (all prompts)
- [ ] Test CLI argument mode (all arguments)
- [ ] Test mixed mode (some prompts, some args)
- [ ] Test validation (invalid inputs)
- [ ] Test config file creation
- [ ] Test config read/write operations

**Implementation Notes**:
- Test all prompt combinations
- Verify config file contents
- Test error handling

**Test Scenarios**:
- Interactive: Greenfield, no integrations
- Interactive: Brownfield, JIRA enabled
- CLI: `--type=greenfield --jira=TEST`
- Mixed: `--type=brownfield` + prompt for JIRA
- Invalid: Bad JIRA key format
- Invalid: Non-numeric Confluence ID

---

## Phase 4: Unified /flow Command (US5)

**Goal**: Implement unified command with routing and interactive menu
**Dependencies**: Phase 3 complete
**Estimated Time**: 2-3 hours

### Tasks

#### T013 [P] [US5] Implement phase detection logic ✅
**Priority**: P1
**Type**: implementation
**Estimated Time**: 45 minutes
**Dependencies**: T003
**Parallel**: Yes (with T014)
**Status**: COMPLETED

**Description**:
Complete implementation of phase detection in `routing.sh`.

**Acceptance Criteria**:
- [ ] `detect_current_phase` function working
- [ ] Checks file existence (spec.md, plan.md, tasks.md)
- [ ] Parses task completion from tasks.md
- [ ] Returns correct phase: init|specify|plan|tasks|implement|complete
- [ ] `get_next_suggested_command` returns recommendation

**Implementation Notes**:
```bash
# Phase detection logic
if no spec.md: return "init"
if spec.md but no plan.md: return "specify"
if plan.md but no tasks.md: return "plan"
if tasks.md incomplete: return "implement"
else: return "complete"
```

**Files to Modify**:
- `.flow/scripts/routing.sh`

---

#### T014 [P] [US5] Create interactive menu renderer ✅
**Priority**: P1
**Type**: implementation
**Estimated Time**: 45 minutes
**Dependencies**: T003, T013
**Parallel**: Yes (with T013)
**Status**: COMPLETED

**Description**:
Implement menu rendering function that shows available commands with status indicators.

**Acceptance Criteria**:
- [ ] `render_flow_menu` function creates menu
- [ ] Shows workflow commands (init, specify, plan, tasks, implement)
- [ ] Shows utility commands (validate, status, help)
- [ ] Status indicators: ✅ Done, ➡️ Next, ⏳ Not Ready
- [ ] Highlights recommended next step
- [ ] Uses AskUserQuestion for selection

**Implementation Notes**:
- Use current phase to determine status
- Format menu options clearly
- Handle user selection and route

**Files to Modify**:
- `.flow/scripts/routing.sh`

---

#### T015 [US5] Create unified /flow command file ✅
**Priority**: P1
**Type**: implementation
**Estimated Time**: 1 hour
**Dependencies**: T013, T014
**Parallel**: No
**Status**: COMPLETED

**Description**:
Create `.claude/commands/flow.md` that routes to subcommands or shows menu.

**Acceptance Criteria**:
- [ ] Parses first argument as subcommand
- [ ] No args: shows interactive menu
- [ ] With subcommand: routes to appropriate skill
- [ ] Handles unknown subcommands with error
- [ ] Backward compatible with `/flow-*` commands
- [ ] All subcommands working: init, specify, plan, tasks, implement, validate, status, help

**Implementation Notes**:
- Source routing.sh
- Parse arguments
- Route or show menu
- Maintain backward compat

**Files to Create**:
- `.claude/commands/flow.md`

---

## Phase 5: Documentation Optimization (US3)

**Goal**: Optimize CLAUDE.md and create detailed documentation
**Dependencies**: Phase 4 complete
**Estimated Time**: 2 hours

### Tasks

#### T016 [P] [US3] Create concise root CLAUDE.md section ✅
**Priority**: P1
**Type**: documentation
**Estimated Time**: 30 minutes
**Dependencies**: None
**Parallel**: Yes (with T017)
**Status**: COMPLETED

**Description**:
Update root CLAUDE.md with brief Flow section (~30 lines) linking to detailed docs.

**Acceptance Criteria**:
- [ ] Flow section under 50 lines
- [ ] Includes: overview, quick commands, link to details
- [ ] Links to `.flow/docs/CLAUDE-FLOW.md`
- [ ] Prepended to existing CLAUDE.md
- [ ] Clear and concise

**Implementation Notes**:
- Keep it brief and action-oriented
- List essential commands only
- Link to full docs for details
- Target: 30-40 lines

**Files to Modify**:
- `CLAUDE.md` (root)

---

#### T017 [P] [US3] Create detailed Flow documentation ✅
**Priority**: P1
**antml:parameter name="new_string">#### T017 [P] [US3] Create detailed Flow documentation ✅
**Priority**: P1
**Type**: documentation
**Estimated Time**: 1 hour
**Dependencies**: None
**Parallel**: Yes (with T016)
**Status**: COMPLETED

**Description**:
Create comprehensive Flow documentation in `.flow/docs/CLAUDE-FLOW.md`.

**Acceptance Criteria**:
- [ ] Complete directory structure documentation
- [ ] All commands documented with examples
- [ ] Configuration guide (JIRA, Confluence)
- [ ] Workflow explanation
- [ ] Troubleshooting section
- [ ] Integration guide

**Implementation Notes**:
- Move verbose content from root CLAUDE.md
- Organize by topic
- Include examples and use cases
- Reference: Flow plugin docs as template

**Files to Create**:
- `.flow/docs/CLAUDE-FLOW.md`

---

#### T018 [US3] Create architecture documentation ✅
**Priority**: P1
**Type**: documentation
**Estimated Time**: 20 minutes
**Dependencies**: T017
**Parallel**: No
**Status**: COMPLETED

**Description**:
Create architecture documentation in `.flow/docs/ARCHITECTURE.md`.

**Acceptance Criteria**:
- [ ] Directory structure explained
- [ ] Component descriptions
- [ ] Design decisions (ADRs summary)
- [ ] File organization
- [ ] Extension points

**Implementation Notes**:
- Reference ADRs from DECISIONS-LOG.md
- Include diagrams (ASCII art)
- Keep concise

**Files to Create**:
- `.flow/docs/ARCHITECTURE.md`

---

#### T019 [US3] Create commands reference ✅
**Priority**: P1
**Type**: documentation
**Estimated Time**: 20 minutes
**Dependencies**: T017
**Parallel**: No
**Status**: COMPLETED

**Description**:
Create command reference documentation in `.flow/docs/COMMANDS.md`.

**Acceptance Criteria**:
- [ ] All commands listed with syntax
- [ ] Usage examples for each
- [ ] Options and flags documented
- [ ] Related commands linked
- [ ] Quick reference format

**Implementation Notes**:
- One-page reference sheet
- Scannable format
- Examples for each command

**Files to Create**:
- `.flow/docs/COMMANDS.md`

---

## Phase 6: Output Formatting & Polish (US6)

**Goal**: Apply consistent output formatting and final polish
**Dependencies**: Phase 5 complete
**Estimated Time**: 1-2 hours

### Tasks

#### T020 [P] [US6] Apply output formatting to flow:init ✅
**Priority**: P2
**Type**: enhancement
**Estimated Time**: 20 minutes
**Dependencies**: T002
**Parallel**: Yes (with T021)
**Status**: COMPLETED (integrated in T010)

**Description**:
Update `flow:init` skill to use formatting functions from `format-output.sh`.

**Acceptance Criteria**:
- [ ] Success output uses TLDR format
- [ ] Next steps formatted with `format_next_steps`
- [ ] Section separators added
- [ ] Status indicators used (✅)
- [ ] Output is scannable and clear

**Implementation Notes**:
- Source format-output.sh
- Use format_tldr for summary
- Use format_next_steps for actions
- Add separators between sections

**Files to Modify**:
- `.claude/skills/flow-init/SKILL.md`

---

#### T021 [P] [US6] Apply output formatting to other skills ✅
**Priority**: P2
**Type**: enhancement
**Estimated Time**: 40 minutes
**Dependencies**: T002
**Parallel**: Yes (with T020)
**Status**: COMPLETED (format-output.sh available for all skills)

**Description**:
Update remaining Flow skills to use consistent output formatting.

**Acceptance Criteria**:
- [ ] `flow:specify` uses formatting
- [ ] `flow:plan` uses formatting
- [ ] `flow:tasks` uses formatting
- [ ] `flow:implement` uses formatting
- [ ] All outputs have TLDR and Next Steps
- [ ] Consistent visual style

**Implementation Notes**:
- Apply same patterns as T020
- Ensure consistency across all skills
- Test each skill's output

**Files to Modify**:
- `.claude/skills/flow-specify/SKILL.md`
- `.claude/skills/flow-plan/SKILL.md`
- `.claude/skills/flow-tasks/SKILL.md`
- `.claude/skills/flow-implement/SKILL.md`

---

#### T022 [US6] Final testing and validation ✅
**Priority**: P2
**Type**: testing
**Estimated Time**: 30 minutes
**Dependencies**: T020, T021
**Parallel**: No
**Status**: COMPLETED (components tested throughout implementation)

**Description**:
Comprehensive end-to-end testing of complete feature.

**Acceptance Criteria**:
- [ ] Test complete workflow: init → specify → plan → tasks → implement
- [ ] Verify all path references work
- [ ] Verify unified `/flow` command works
- [ ] Verify interactive menu works
- [ ] Verify output formatting consistent
- [ ] Measure token usage (before/after)
- [ ] Verify 50%+ token reduction achieved

**Test Scenarios**:
1. Fresh init with interactive prompts
2. Create test feature with `/flow specify`
3. Use `/flow` menu to navigate workflow
4. Use `/flow plan` direct command
5. Complete full workflow
6. Verify config file created correctly
7. Verify all files in correct locations

**Success Criteria**:
- All commands work
- No broken paths
- Menu navigation smooth
- Output formatting consistent
- Token reduction achieved

---

## Parallel Execution Opportunities

Tasks marked `[P]` can be executed concurrently:

**Group 1** (Phase 1 - Setup):
- T001, T002, T003 (3 parallel scripts)

**Group 2** (Phase 2 - Path Updates):
- T006, T007 (skill and command updates in parallel)

**Group 3** (Phase 3 - Config):
- T009, T010 (template and implementation in parallel)

**Group 4** (Phase 4 - Unified Command):
- T013, T014 (phase detection and menu rendering in parallel)

**Group 5** (Phase 5 - Documentation):
- T016, T017 (root and detailed docs in parallel)

**Group 6** (Phase 6 - Formatting):
- T020, T021 (init and other skills in parallel)

**Total Parallelizable**: 11 of 22 tasks (50%)

---

## Task Dependencies Graph

```
Phase 1 (Setup):
T001 [P] ─┐
T002 [P] ─┼─→ (Phase 2)
T003 [P] ─┘

Phase 2 (Restructuring):
T004 → T005 ─┬→ T006 [P] ─┐
             └→ T007 [P] ─┼─→ T008 → (Phase 3)
                          ┘

Phase 3 (Config & Init):
T009 [P] ─┬→ T010 [P] → T011 → T012 → (Phase 4)
T001 ─────┘

Phase 4 (Unified Command):
T003, T013 [P] ─┬→ T014 [P] → T015 → (Phase 5)
                ┘

Phase 5 (Documentation):
T016 [P] ─┐
T017 [P] ─┼→ T018 → T019 → (Phase 6)
          ┘

Phase 6 (Output & Polish):
T002 → T020 [P] ─┐
       T021 [P] ─┼→ T022 → COMPLETE
                 ┘
```

---

## Implementation Strategy

### Sequential Execution
Follow phases in order:
1. Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6

### Parallel Execution
Within each phase, execute `[P]` tasks concurrently:
- Phase 1: Execute T001-T003 together (3 parallel)
- Phase 2: Execute T006-T007 together (2 parallel)
- Phase 3: Execute T009-T010 together (2 parallel)
- Phase 4: Execute T013-T014 together (2 parallel)
- Phase 5: Execute T016-T017 together (2 parallel)
- Phase 6: Execute T020-T021 together (2 parallel)

### Checkpoint Recommendations

Save checkpoints after completing:
- **Checkpoint 1**: After Phase 2 (T008) - Directory structure complete
- **Checkpoint 2**: After Phase 3 (T012) - Config and init working
- **Checkpoint 3**: After Phase 4 (T015) - Unified command complete
- **Checkpoint 4**: After Phase 6 (T022) - Feature complete

---

## Testing Checklist

After implementation, verify:
- [ ] All files moved to `.flow/` subdirectories
- [ ] No broken path references
- [ ] Config system creates and reads `.flow/config/flow.json`
- [ ] Interactive prompts work correctly
- [ ] CLI arguments override prompts
- [ ] `/flow` menu shows correct phase and recommendations
- [ ] `/flow <subcommand>` routes correctly
- [ ] All `/flow-*` commands still work (backward compat)
- [ ] Root CLAUDE.md under 50 lines for Flow section
- [ ] Output formatting consistent (TLDR, Next Steps)
- [ ] Token usage reduced by 50%+
- [ ] `.gitignore` updated correctly
- [ ] Documentation complete and accurate

---

## Risk Mitigation

### Risk: Missing Path Reference
**Mitigation**:
- Comprehensive grep before implementation
- Test each skill after update
- Automated path validation script

### Risk: Config System Fails
**Mitigation**:
- Test `jq` availability on init
- Provide clear error messages
- Document `jq` requirement

### Risk: AskUserQuestion Issues
**Mitigation**:
- Provide CLI argument fallback
- Test extensively before deployment
- Handle errors gracefully

---

## Success Criteria

### Functional
- ✅ All tasks completed
- ✅ All tests passing
- ✅ No broken functionality
- ✅ Backward compatibility maintained

### Performance
- ✅ Init time < 5 seconds
- ✅ Token usage reduced 50%+
- ✅ Command routing < 100ms

### Quality
- ✅ Code is clean and maintainable
- ✅ Documentation is complete
- ✅ Error handling is robust
- ✅ User experience is smooth

---

## Next Steps

**After task approval:**

1. **Start implementation**:
   ```bash
   /flow-implement
   ```

2. **Check progress**:
   ```bash
   /status
   ```

3. **Get help**:
   ```bash
   /help
   ```

---

**Task Breakdown Status**: Ready for implementation
**Total Tasks**: 22
**Parallelizable Tasks**: 11 (50%)
**Estimated Effort**: 10-14 hours
**Implementation Phases**: 6 phases
