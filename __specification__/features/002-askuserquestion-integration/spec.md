# Feature Specification: AskUserQuestion Tool Integration

**Feature ID**: 002-askuserquestion-integration
**Created**: 2025-10-28
**Status**: Draft
**Priority**: P1 (High Value UX Improvement)

## Overview

Uplift Flow to use Claude Code's AskUserQuestion tool for interactive user experiences, replacing text-based prompts with visual selection interfaces where appropriate. This improves usability by allowing users to click/select options rather than typing responses.

## Problem Statement

Currently, Flow documentation mentions using AskUserQuestion in flow:init, but:
1. The `/flow` command shows a text-only menu (not interactive selections)
2. Other skills could benefit from visual selections
3. User experience could be more intuitive with clickable options
4. Multi-step workflows would benefit from guided selections

## User Stories

### P1 - Must Have (Core Interactive Experiences)

#### US1: Interactive /flow Command Menu
**As a** developer using Flow
**I want** to select my next action from a visual menu when I run `/flow`
**So that** I don't have to remember exact command names and can see what's available

**Acceptance Criteria**:
- Running `/flow` with no args shows AskUserQuestion with workflow options
- Options are phase-aware (show only relevant commands)
- Selected option automatically executes (e.g., selecting "specify" runs flow:specify)
- Status indicators show completion (✅ done, ➡️ next, ⏳ not ready)
- "Other" option allows typing custom command
- Menu respects current workflow phase

**Technical Notes**:
- Update `.claude/commands/flow.md` to use AskUserQuestion
- Single select (multiSelect: false)
- Options: init, specify, plan, tasks, implement, validate, status, help
- Header: "Flow Action" (max 12 chars)
- Description for each option explains what it does

---

#### US2: Enhanced flow:init Interactive Prompts
**As a** developer initializing Flow
**I want** visual selections for configuration options
**So that** I can easily choose settings without typing exact values

**Acceptance Criteria**:
- Project type selection uses AskUserQuestion (Greenfield vs Brownfield)
- JIRA integration uses yes/no AskUserQuestion
- Confluence integration uses yes/no AskUserQuestion
- JIRA key input uses "Other" option for text entry
- Confluence page ID uses "Other" option for text entry
- All questions have clear descriptions
- Multi-question flow with conditional logic (only ask for keys if integration enabled)

**Technical Notes**:
- Already documented in flow:init skill but may need refinement
- Can ask 1-4 questions per AskUserQuestion call
- Consider chunking: Q1 (project type + integrations yes/no) then Q2 (keys if needed)
- Validate inputs after collection

---

#### US3: Interactive Phase Transitions
**As a** developer progressing through workflow
**I want** visual confirmation prompts at major transitions
**So that** I understand what's happening and can make informed choices

**Acceptance Criteria**:
- After `/flow specify`, ask "Ready to plan?" with options: "Yes, create plan", "No, review spec first", "Validate spec first"
- After `/flow plan`, ask "Ready to break down tasks?" with options: "Yes, create tasks", "No, review plan first", "Update plan"
- After `/flow tasks`, ask "Ready to implement?" with options: "Yes, start implementation", "No, review tasks first", "Estimate effort first"
- Each prompt includes option to cancel/go back
- Selected action executes automatically

**Technical Notes**:
- Add to end of each workflow skill
- Single select
- Max 4 options per question
- Could be opt-in via config: `preferences.interactive_transitions: true`

---

### P2 - Should Have (Enhanced Experiences)

#### US4: Multi-Select Feature Options
**As a** developer specifying a feature
**I want** to select multiple feature flags/options visually
**So that** I can quickly configure what aspects to include

**Acceptance Criteria**:
- When running `/flow specify`, optionally ask "Which aspects?" with multi-select
- Options: "API endpoints", "Database models", "UI components", "Tests", "Documentation"
- Selected aspects influence generated spec structure
- Can select 0-5 options (all optional)
- Works with both interactive and `--quick` mode

**Technical Notes**:
- Use multiSelect: true
- Header: "Features"
- This is optional/enhancement - don't block core workflow
- Could be enabled via `--interactive` flag

---

#### US5: Validation Issue Resolution
**As a** developer running `/flow validate`
**I want** visual options to fix issues found
**So that** I can quickly resolve problems without remembering commands

**Acceptance Criteria**:
- When validation finds issues, show AskUserQuestion
- Options based on issue type: "Fix automatically", "Show details", "Ignore for now", "Get help"
- Multi-select if multiple issues (fix which ones?)
- Selected actions execute in sequence
- Can re-run validation after fixes

**Technical Notes**:
- flow:validate (or flow:analyze) would need this
- Context-aware options based on what's wrong
- May require issue categorization first

---

#### US6: Implementation Mode Selection
**As a** developer starting implementation
**I want** visual options for how to implement
**So that** I can choose my workflow style easily

**Acceptance Criteria**:
- When running `/flow implement`, ask "How would you like to proceed?"
- Options: "Autonomous (hands-off)", "Guided (review each task)", "Manual (I'll code)", "Pair programming"
- Single select
- Sets execution mode for session
- Mode affects how tasks are presented

**Technical Notes**:
- Affects flow:implement behavior
- Could store in session state
- Different modes = different user interaction levels

---

### P3 - Nice to Have (Future Enhancements)

#### US7: Template Selection
**As a** developer creating specifications
**I want** to visually select from templates
**So that** I can quickly start with the right structure

**Acceptance Criteria**:
- When feature type is unclear, show template options
- Options: "CRUD feature", "API integration", "UI component", "Background job", "Custom"
- Selected template pre-fills spec structure
- Templates stored in `.flow/templates/`

**Technical Notes**:
- Requires template system
- Could be part of flow:specify
- Low priority - text input works fine

---

#### US8: Skill Discovery Menu
**As a** developer exploring Flow
**I want** to browse available skills visually
**So that** I can discover what Flow can do

**Acceptance Criteria**:
- Command like `/flow discover` shows all skills
- Multi-select to learn about multiple skills
- Each selection shows help for that skill
- Can execute skill directly from menu

**Technical Notes**:
- Nice-to-have for learning
- Could replace `/flow-help --all`
- Lower priority than core workflow

---

## Success Criteria

1. **Improved Usability**: Users can navigate Flow without memorizing commands
2. **Reduced Errors**: Visual selections prevent typos and invalid inputs
3. **Faster Onboarding**: New users can explore Flow through menus
4. **Maintained Efficiency**: Power users can still use direct commands (e.g., `/flow specify "feature"`)
5. **Consistent UX**: All interactive prompts use same AskUserQuestion pattern

## Technical Constraints

1. **AskUserQuestion Limits**:
   - 1-4 questions per call
   - 2-4 options per question (+ automatic "Other")
   - Header max 12 characters
   - Must handle "Other" text input

2. **Backward Compatibility**:
   - Existing command-line usage must still work
   - CLI arguments should skip interactive prompts
   - Text-based workflows remain supported

3. **Performance**:
   - Interactive prompts should be skippable with flags (e.g., `--no-interactive`)
   - Config option to disable: `preferences.interactive_mode: false`

4. **Implementation Files**:
   - Update `.claude/commands/flow.md` (P1)
   - Update `.claude/skills/flow-init/SKILL.md` (already has structure, may need refinement)
   - Update other workflow skills for transitions (P1-P2)
   - No changes to bash scripts in `.flow/scripts/` (they work as-is)

## Non-Functional Requirements

1. **Accessibility**: Options should have clear, descriptive labels
2. **Discoverability**: Menu options should guide users to next logical steps
3. **Flexibility**: Users can choose interactive OR command-line workflows
4. **Documentation**: Update docs to show interactive examples

## Dependencies

- AskUserQuestion tool must be available (it is - it's built into Claude Code)
- Flow init optimization (001) must be complete (✅ done)
- Current directory structure must be in place (✅ done)

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Users prefer command-line | Medium | Keep both modes, make interactive optional |
| Too many prompts slow workflow | Medium | Add `--quick` mode to skip prompts |
| "Other" option UX unclear | Low | Provide clear placeholder text |
| Breaking existing automation | High | Detect CLI args and skip prompts automatically |

## Out of Scope

- ❌ Custom UI beyond AskUserQuestion (no web interfaces)
- ❌ Keyboard shortcuts (not supported by AskUserQuestion)
- ❌ Persistent user preferences (config file only)
- ❌ Undo/redo functionality
- ❌ Visual progress bars during execution (formatting only)

## Open Questions

1. **Should `/flow` with no args be interactive by default, or require `--interactive` flag?**
   - Recommendation: Interactive by default (better UX), add `--no-interactive` to disable

2. **How many questions should flow:init ask in one call?**
   - Option A: Ask all 5 questions at once (project type + 2 integrations + 2 keys)
   - Option B: Ask 2 rounds (type + yes/no for integrations, then keys if needed)
   - Recommendation: Option B (conditional logic, less overwhelming)

3. **Should phase transitions be interactive by default?**
   - Recommendation: Yes for new users, no for power users (detect via config or command pattern)

4. **What happens if user selects "Other" but provides invalid input?**
   - Recommendation: Re-prompt with validation error shown

## Examples

### Example 1: Interactive /flow Menu
```
User: /flow

Claude shows AskUserQuestion:
┌─────────────────────────────────────────┐
│ What would you like to do?             │
├─────────────────────────────────────────┤
│ ○ Specify - Create feature spec        │
│ ○ Plan - Design technical approach     │
│ ○ Tasks - Break down into tasks        │
│ ○ Implement - Execute implementation   │
│ ○ Validate - Check consistency         │
│ ○ Status - Show current progress       │
│ ○ Help - Get context-aware help        │
│ ○ Other (type command)                 │
└─────────────────────────────────────────┘

User selects: "Specify"
Result: Automatically runs flow:specify
```

### Example 2: Enhanced flow:init
```
User: /flow init

Claude shows AskUserQuestion (Round 1):
┌─────────────────────────────────────────┐
│ Question 1: What type of project?      │
├─────────────────────────────────────────┤
│ ○ Greenfield - New project, full setup │
│ ○ Brownfield - Existing codebase       │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Question 2: Enable JIRA integration?   │
├─────────────────────────────────────────┤
│ ○ Yes - Sync with JIRA                 │
│ ○ No - Flow only                       │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Question 3: Enable Confluence?         │
├─────────────────────────────────────────┤
│ ○ Yes - Sync documentation             │
│ ○ No - Flow only                       │
└─────────────────────────────────────────┘

User selects: Brownfield, Yes (JIRA), No (Confluence)

Claude shows AskUserQuestion (Round 2):
┌─────────────────────────────────────────┐
│ Enter your JIRA project key            │
├─────────────────────────────────────────┤
│ ○ FLOW                                 │
│ ○ PROJ                                 │
│ ○ Other (type your key)               │
└─────────────────────────────────────────┘

User types in Other: "MYPROJ"
Result: Config created with brownfield + JIRA MYPROJ
```

### Example 3: Phase Transition
```
User: /flow specify "User authentication"

Claude creates spec, then shows:
┌─────────────────────────────────────────┐
│ Specification complete! What's next?   │
├─────────────────────────────────────────┤
│ ○ Create Plan - Design architecture    │
│ ○ Review Spec - Check spec first       │
│ ○ Validate Spec - Run quality checks   │
│ ○ Exit - Continue later                │
└─────────────────────────────────────────┘

User selects: "Create Plan"
Result: Automatically runs flow:plan
```

## Implementation Notes

### Priority Order
1. **P1.US1**: Interactive `/flow` menu (highest impact, most visible)
2. **P1.US2**: Refine flow:init prompts (already partially done)
3. **P1.US3**: Phase transitions (high value, smooth workflow)
4. **P2**: Remaining features as time permits

### Files to Modify
- `.claude/commands/flow.md` - Add AskUserQuestion for menu
- `.claude/skills/flow-init/SKILL.md` - Refine existing prompts
- `.claude/skills/flow-specify/SKILL.md` - Add transition prompt
- `.claude/skills/flow-plan/SKILL.md` - Add transition prompt
- `.claude/skills/flow-tasks/SKILL.md` - Add transition prompt
- Documentation updates in `.flow/docs/`

### Testing Approach
- Manual testing of each interactive flow
- Test "Other" option text inputs
- Test CLI arguments still skip prompts
- Test with `--no-interactive` flag
- Verify backward compatibility

---

**Next Steps**: Review spec, run `/flow plan` to design implementation approach.
