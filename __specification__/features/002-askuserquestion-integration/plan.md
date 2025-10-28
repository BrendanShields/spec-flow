# Technical Plan: AskUserQuestion Tool Integration

**Feature ID**: 002-askuserquestion-integration
**Created**: 2025-10-28
**Est. Duration**: 4-6 hours
**Complexity**: Medium
**Dependencies**: Feature 001 (Flow Init Optimization) - Complete ✅

---

## Executive Summary

Enhance Flow's user experience by integrating Claude Code's AskUserQuestion tool for visual, interactive selections throughout the workflow. This replaces text-only menus with clickable options, reduces errors, and improves discoverability for new users while maintaining CLI efficiency for power users.

**Key Changes**:
- Interactive `/flow` menu with visual selections
- Enhanced flow:init prompts (refine existing implementation)
- Phase transition prompts after each workflow step
- Backward compatible with CLI arguments
- Optional interactive mode (configurable)

---

## Architecture Decisions (ADRs)

### ADR-007: Use AskUserQuestion for Interactive Menus

**Context**: Flow currently shows text-only menus that require users to remember and type exact commands.

**Decision**: Integrate AskUserQuestion tool for visual selections where appropriate.

**Rationale**:
- **Better UX**: Click/select vs typing reduces errors
- **Discoverability**: New users see all available options
- **Guidance**: Descriptions explain what each option does
- **Built-in**: AskUserQuestion is native to Claude Code
- **Flexible**: Supports single-select, multi-select, and text input

**Alternatives Considered**:
- Keep text-only menus (rejected - poor UX for new users)
- Build custom UI (rejected - not supported, unnecessary complexity)
- Use bash `select` (rejected - not visual, inconsistent with Claude Code UX)

**Impact**:
- Commands must detect and handle AskUserQuestion responses
- CLI arguments skip interactive prompts (backward compatibility)
- Config option to disable: `preferences.interactive_mode: false`

**Trade-offs**:
- **Pro**: Much better user experience
- **Pro**: Faster onboarding
- **Con**: Slightly more complex command logic
- **Con**: Users must click/select (not scriptable unless using CLI args)

---

### ADR-008: Interactive by Default with CLI Override

**Context**: Should interactive mode be opt-in or opt-out?

**Decision**: Interactive by default, disable with `--no-interactive` flag or CLI arguments.

**Rationale**:
- **Prioritize new users**: Better first impression
- **Natural for GUI**: Claude Code is visual tool
- **Easy opt-out**: Single flag or use direct arguments
- **Detectable**: Presence of CLI args = skip prompts automatically

**Alternatives Considered**:
- Opt-in with `--interactive` flag (rejected - extra step for most users)
- Always interactive (rejected - breaks automation/scripting)
- Config-only control (rejected - too slow to toggle)

**Impact**:
- All commands must check for CLI arguments first
- If any relevant args present, skip interactive prompts
- Config setting overrides for persistent preference

**Example**:
```bash
/flow                          # Interactive menu
/flow init                     # Interactive prompts
/flow init --type=greenfield   # Skip prompts, use args
/flow --no-interactive init    # Force non-interactive
```

---

### ADR-009: Conditional Multi-Step Prompts

**Context**: flow:init needs to ask 5 questions but AskUserQuestion supports max 4 per call.

**Decision**: Use conditional multi-step approach - ask initial questions, then follow-up based on responses.

**Rationale**:
- **Better flow**: Don't ask for JIRA key if JIRA not enabled
- **Less overwhelming**: Split into logical groups
- **Flexible**: Can skip unnecessary questions
- **Tool limit**: Works within 1-4 question constraint

**Implementation**:
```
Step 1: Ask 3 questions
  Q1: Project type (Greenfield/Brownfield)
  Q2: Enable JIRA? (Yes/No)
  Q3: Enable Confluence? (Yes/No)

If JIRA=Yes OR Confluence=Yes:
  Step 2: Ask for keys
    If JIRA=Yes: Q1: JIRA project key
    If Confluence=Yes: Q2: Confluence page ID
```

**Alternatives Considered**:
- Ask all 5 questions (rejected - violates 4-question limit)
- Use "Other" for everything (rejected - poor UX)
- Separate commands (rejected - breaks flow)

---

### ADR-010: Phase Transitions Opt-In via Config

**Context**: Should we prompt "Ready to plan?" after every specification?

**Decision**: Make phase transitions opt-in via config: `preferences.interactive_transitions: true`

**Rationale**:
- **Power users don't want**: Interrupts flow for experienced users
- **New users benefit**: Guidance on what's next
- **Configurable**: Easy to enable/disable
- **Detectable**: Check config before prompting

**Default**: `false` (opt-in) for P1, consider changing to `true` after user feedback.

**Alternatives Considered**:
- Always prompt (rejected - annoying for power users)
- Never prompt (rejected - misses UX opportunity)
- Detect user experience level (rejected - too complex)

---

### ADR-011: Command Routing After Selection

**Context**: What happens after user selects an option in AskUserQuestion?

**Decision**: Commands indicate which skill to run, Claude Code executes it automatically.

**Rationale**:
- **Claude Code behavior**: When command outputs "Please run: flow:specify", Claude sees it and invokes the skill
- **Consistent**: Same pattern as current routing
- **Simple**: No additional infrastructure needed

**Implementation Pattern**:
```markdown
User selects "Specify" from menu
↓
Command outputs: "Invoking flow:specify skill..."
↓
Claude Code sees output and runs flow:specify
↓
Skill executes with context
```

**Alternatives Considered**:
- Return selected value for command to handle (rejected - requires complex state management)
- Use skill invocation directly (rejected - not how commands work)

---

## Component Design

### Component 1: Interactive Flow Menu (US1)

**Purpose**: Visual menu when running `/flow` with no arguments.

**Location**: `.claude/commands/flow.md`

**Interface**:
```typescript
Input: /flow (no args)
Output: AskUserQuestion → selected action → execute skill
```

**Behavior**:
1. Detect current phase using `routing.sh`
2. Build phase-aware options list
3. Show AskUserQuestion with workflow options
4. Parse selected option
5. Route to appropriate skill or command

**AskUserQuestion Structure**:
```json
{
  "questions": [{
    "question": "What would you like to do?",
    "header": "Flow Action",
    "multiSelect": false,
    "options": [
      {
        "label": "Specify",
        "description": "Create feature specification"
      },
      {
        "label": "Plan",
        "description": "Design technical approach"
      },
      {
        "label": "Tasks",
        "description": "Break down into tasks"
      },
      {
        "label": "Implement",
        "description": "Execute implementation"
      },
      {
        "label": "Validate",
        "description": "Check consistency"
      },
      {
        "label": "Status",
        "description": "Show current progress"
      },
      {
        "label": "Help",
        "description": "Get context-aware help"
      }
    ]
  }]
}
```

**Phase Awareness**:
- Options marked as completed (✅) if phase done
- Current/next phase highlighted in descriptions
- Irrelevant options grayed or hidden (future enhancement)

**Dependencies**:
- `routing.sh` - `detect_current_phase()`
- `format-output.sh` - Status indicators (informational only)

---

### Component 2: Enhanced flow:init Prompts (US2)

**Purpose**: Refine existing interactive configuration prompts.

**Location**: `.claude/skills/flow-init/SKILL.md`

**Current State**: Already documented with AskUserQuestion structure, may need refinement.

**Enhanced Flow**:

**Step 1: Core Configuration (3 questions)**
```json
{
  "questions": [
    {
      "question": "What type of project is this?",
      "header": "Project",
      "multiSelect": false,
      "options": [
        {"label": "Greenfield", "description": "New project - full architecture setup"},
        {"label": "Brownfield", "description": "Existing codebase - feature-focused"}
      ]
    },
    {
      "question": "Enable JIRA integration?",
      "header": "JIRA",
      "multiSelect": false,
      "options": [
        {"label": "Yes", "description": "Sync specs and tasks with JIRA"},
        {"label": "No", "description": "Use Flow without JIRA"}
      ]
    },
    {
      "question": "Enable Confluence integration?",
      "header": "Confluence",
      "multiSelect": false,
      "options": [
        {"label": "Yes", "description": "Sync documentation to Confluence"},
        {"label": "No", "description": "Use Flow without Confluence"}
      ]
    }
  ]
}
```

**Step 2: Integration Keys (conditional)**
Only if JIRA or Confluence enabled:
```json
{
  "questions": [
    // If JIRA enabled
    {
      "question": "Enter your JIRA project key (e.g., FLOW, PROJ-123):",
      "header": "JIRA Key",
      "multiSelect": false,
      "options": [
        {"label": "FLOW", "description": "Use FLOW as project key"},
        {"label": "PROJ", "description": "Use PROJ as project key"}
        // "Other" automatically provided for text input
      ]
    },
    // If Confluence enabled
    {
      "question": "Enter your Confluence root page ID (numeric only):",
      "header": "Page ID",
      "multiSelect": false,
      "options": [
        {"label": "123456", "description": "Example page ID"}
        // "Other" automatically provided
      ]
    }
  ]
}
```

**Validation**:
- After collecting responses, validate using `validate_jira_key()` and `validate_confluence_page_id()`
- If validation fails, re-prompt with error message

**CLI Bypass**:
```bash
# Skip all prompts
/flow init --type=greenfield --jira=FLOW --confluence=123456

# Skip some prompts
/flow init --type=brownfield
# Still prompts for JIRA/Confluence
```

---

### Component 3: Phase Transition Prompts (US3)

**Purpose**: Guide users to next step after completing each phase.

**Location**: End of each workflow skill (flow:specify, flow:plan, flow:tasks)

**Trigger**: Check config `preferences.interactive_transitions`

**Example Implementation** (flow:specify):

```markdown
## After Specification Complete

Check config:
```bash
source .flow/scripts/config.sh
interactive_transitions=$(get_flow_config "preferences.interactive_transitions")
```

If enabled, show AskUserQuestion:
```json
{
  "questions": [{
    "question": "Specification complete! What's next?",
    "header": "Next Step",
    "multiSelect": false,
    "options": [
      {
        "label": "Create Plan",
        "description": "Design technical architecture"
      },
      {
        "label": "Review Spec",
        "description": "Check specification first"
      },
      {
        "label": "Validate",
        "description": "Run quality checks"
      },
      {
        "label": "Exit",
        "description": "Continue later"
      }
    ]
  }]
}
```

Handle selection:
- "Create Plan" → Invoke flow:plan
- "Review Spec" → Show spec file path, exit
- "Validate" → Invoke flow:analyze
- "Exit" → Show success message, exit
```

**Skills to Update**:
1. `flow:specify` → prompt for plan/validate
2. `flow:plan` → prompt for tasks/review
3. `flow:tasks` → prompt for implement/review

---

## Data Model

### Config Schema Changes

Add to `.flow/config/flow.json`:

```json
{
  "version": "2.0",
  "project": { ... },
  "integrations": { ... },
  "preferences": {
    "auto_checkpoint": true,
    "validate_on_save": true,
    "interactive_mode": true,          // NEW: Enable interactive prompts
    "interactive_transitions": false    // NEW: Prompt after each phase
  }
}
```

**New Fields**:
- `preferences.interactive_mode` (boolean): Master toggle for all interactive features
- `preferences.interactive_transitions` (boolean): Enable phase transition prompts

**Defaults**:
- `interactive_mode`: `true` (interactive by default)
- `interactive_transitions`: `false` (opt-in for transitions)

---

### Response Handling Pattern

**Structure**:
```typescript
// AskUserQuestion returns
answers: {
  [questionId]: selectedLabel | "Other:user-typed-text"
}

// Example
answers: {
  "question_0": "Greenfield",
  "question_1": "Yes",
  "question_2": "Other:MYPROJ-123"
}
```

**Parsing Logic**:
```bash
# Get answer
answer=$(echo "$answers" | jq -r '.question_0')

# Check if "Other" was used
if [[ "$answer" == Other:* ]]; then
  # Extract user text
  user_input="${answer#Other:}"
  # Validate
  validate_input "$user_input"
else
  # Use selected label directly
  selected="$answer"
fi
```

---

## Implementation Phases

### Phase 1: Foundation (30 min)

**Goal**: Update config schema and add helper functions.

**Tasks**:
1. Add new config fields to `config.sh` `init_flow_config()`
2. Add config getter/setter for new preferences
3. Add helper function `should_prompt_interactive()`
4. Update documentation

**Files**:
- `.flow/scripts/config.sh`
- `.flow/docs/CLAUDE-FLOW.md`

**Acceptance**:
- Config file includes new preference fields
- `get_flow_config "preferences.interactive_mode"` works
- Helper function detects CLI args and config

---

### Phase 2: Interactive /flow Menu (1.5 hours)

**Goal**: Implement US1 - interactive menu for `/flow` command.

**Tasks**:
1. Update `.claude/commands/flow.md`:
   - Add AskUserQuestion call
   - Build phase-aware options
   - Handle response and route
2. Test with different phases
3. Verify CLI args bypass (e.g., `/flow plan` goes direct)
4. Update tests

**Files**:
- `.claude/commands/flow.md`
- `.claude/commands/flow.md` (plugin copy)

**Acceptance**:
- `/flow` shows interactive menu
- Selecting option executes skill
- Options reflect current phase
- `/flow plan` bypasses menu

---

### Phase 3: Refine flow:init (1 hour)

**Goal**: Enhance US2 - improve existing init prompts.

**Tasks**:
1. Review current flow:init AskUserQuestion structure
2. Implement conditional two-step prompts
3. Add validation error handling with re-prompts
4. Test with all combinations
5. Verify CLI args skip prompts

**Files**:
- `.claude/skills/flow-init/SKILL.md`
- `.claude/skills/flow-init/SKILL.md` (plugin copy)

**Acceptance**:
- Two-step prompts work correctly
- Only asks for keys if integration enabled
- Validation errors re-prompt
- CLI args skip all prompts

---

### Phase 4: Phase Transitions (1.5 hours)

**Goal**: Implement US3 - prompts after each workflow step.

**Tasks**:
1. Add transition prompt to `flow:specify`
2. Add transition prompt to `flow:plan`
3. Add transition prompt to `flow:tasks`
4. Check config before showing prompts
5. Handle all response options correctly
6. Test complete workflow with transitions

**Files**:
- `.claude/skills/flow-specify/SKILL.md`
- `.claude/skills/flow-plan/SKILL.md`
- `.claude/skills/flow-tasks/SKILL.md`
- Plugin copies

**Acceptance**:
- Prompts appear after each phase (if enabled)
- Selections execute correctly
- Disabled by default (opt-in)
- Config toggle works

---

### Phase 5: Documentation & Polish (45 min)

**Goal**: Update all documentation and add examples.

**Tasks**:
1. Update `.flow/docs/CLAUDE-FLOW.md`:
   - Add interactive mode section
   - Document new config options
   - Show examples
2. Update `.flow/docs/COMMANDS.md`:
   - Add interactive examples
   - Document --no-interactive flag
3. Update root `CLAUDE.md` if needed
4. Add troubleshooting section

**Files**:
- `.flow/docs/CLAUDE-FLOW.md`
- `.flow/docs/COMMANDS.md`
- `.flow/docs/ARCHITECTURE.md` (add ADRs)

**Acceptance**:
- All docs reflect new interactive features
- Examples show both interactive and CLI modes
- Config options documented
- Troubleshooting covers common issues

---

### Phase 6: Testing & Validation (45 min)

**Goal**: Comprehensive testing of all interactive flows.

**Tasks**:
1. Test interactive `/flow` menu in all phases
2. Test flow:init with various combinations
3. Test phase transitions (enabled and disabled)
4. Test CLI argument bypass
5. Test `--no-interactive` flag
6. Test config toggles
7. Verify backward compatibility

**Test Scenarios**:
- New user first-time flow (all interactive)
- Power user with CLI args (no prompts)
- Mixed mode (some interactive, some CLI)
- Config disabled (all text-based)
- Invalid "Other" inputs (re-prompts)

**Acceptance**:
- All scenarios work correctly
- No broken workflows
- Backward compatible
- Error handling works

---

## API Contracts

### AskUserQuestion Tool Interface

**Input**:
```typescript
{
  questions: Question[]  // 1-4 questions
}

interface Question {
  question: string        // The question text
  header: string         // Short label (max 12 chars)
  multiSelect: boolean   // true = checkboxes, false = radio
  options: Option[]      // 2-4 options (+ auto "Other")
}

interface Option {
  label: string         // Button/option text (1-5 words)
  description: string   // Explanation of choice
}
```

**Output**:
```typescript
{
  answers: {
    [questionId: string]: string  // Selected label or "Other:text"
  }
}
```

---

### Config Functions

**New Functions**:
```bash
# Check if interactive mode enabled
should_prompt_interactive() {
  # Returns 0 (true) if should prompt, 1 (false) if skip

  # Check for CLI args
  if [ $# -gt 0 ]; then
    return 1  # Skip prompts
  fi

  # Check config
  local interactive=$(get_flow_config "preferences.interactive_mode")
  if [ "$interactive" = "false" ]; then
    return 1  # Skip prompts
  fi

  # Check global flag
  if [ "$FLOW_NO_INTERACTIVE" = "true" ]; then
    return 1  # Skip prompts
  fi

  return 0  # Show prompts
}

# Check if phase transitions enabled
should_prompt_transitions() {
  local enabled=$(get_flow_config "preferences.interactive_transitions")
  [ "$enabled" = "true" ]
}
```

---

## Performance Considerations

**Prompt Response Time**:
- AskUserQuestion is synchronous (waits for user selection)
- No impact on execution speed once selected
- CLI args bypass entirely (zero overhead)

**Config Reads**:
- Config reads are fast (jq parsing)
- Cache config in command if multiple checks needed

**Optimization**:
- Only read config once per command execution
- Skip unnecessary checks if CLI args present

---

## Security Considerations

**Input Validation**:
- Validate "Other" text inputs before using
- JIRA key format: `^[A-Z][A-Z0-9]+(-[0-9]+)?$`
- Confluence page ID: `^[0-9]+$`
- Re-prompt on validation failure

**No Security Risks**:
- AskUserQuestion output is trusted (user-driven)
- No code injection possible (text only)
- Config file format unchanged (JSON)

---

## Testing Strategy

### Unit Testing

**Config Functions**:
```bash
# Test should_prompt_interactive
test_prompt_detection() {
  # With no args
  should_prompt_interactive && echo "PASS: Prompts when no args"

  # With CLI args
  should_prompt_interactive --type=greenfield || echo "PASS: Skips with args"

  # With config disabled
  set_flow_config "preferences.interactive_mode" "false"
  should_prompt_interactive || echo "PASS: Respects config"
}
```

### Integration Testing

**Test Cases**:
1. **Interactive /flow menu**:
   - Run `/flow`, select each option, verify skill executes
   - Test in different phases (init, specify, plan, etc.)

2. **flow:init prompts**:
   - Test greenfield + JIRA + Confluence
   - Test brownfield + no integrations
   - Test "Other" text input for keys
   - Test validation error re-prompts

3. **Phase transitions**:
   - Enable in config, complete spec, verify prompt appears
   - Disable in config, complete spec, verify no prompt
   - Test each transition option

4. **CLI bypass**:
   - Run commands with args, verify no prompts
   - Mix interactive and args

### End-to-End Testing

**Scenario 1: New User (Full Interactive)**:
```bash
/flow                    # Interactive menu
→ Select "Init"
→ Greenfield, No JIRA, No Confluence
→ Success

/flow                    # Menu again
→ Select "Specify"
→ Enter "User auth"
→ Spec created
→ Transition prompt appears (if enabled)
→ Select "Create Plan"
→ Plan created
```

**Scenario 2: Power User (CLI Only)**:
```bash
/flow init --type=brownfield
/flow specify "Feature"
/flow plan
/flow tasks
/flow implement
# No prompts, direct execution
```

---

## Rollout Plan

### Rollout Phases

**Phase 1: Soft Launch** (P1 features only)
- Deploy interactive `/flow` menu
- Refine flow:init prompts
- Document in changelog
- Default: interactive_mode = true, interactive_transitions = false

**Phase 2: User Feedback** (2 weeks)
- Collect feedback on UX
- Identify pain points
- Measure adoption (how many use interactive vs CLI)

**Phase 3: Transitions** (P1.US3)
- Enable phase transitions based on feedback
- Consider making default if well-received

**Phase 4: Enhancements** (P2 features)
- Add multi-select options
- Add validation resolution prompts
- Add implementation mode selection

---

## Migration Notes

**No Breaking Changes**:
- All existing command-line usage still works
- Config format backward compatible (new fields optional)
- Legacy `/flow-*` commands unchanged

**User Communication**:
- Update docs to highlight interactive mode
- Add examples showing both modes
- Mention in release notes

**Config Migration**:
- Old configs work without new fields (defaults apply)
- No migration script needed
- Users can opt-in to new features via config

---

## Monitoring & Metrics

**Success Metrics**:
1. **Adoption Rate**: % of users using interactive mode
2. **Error Reduction**: Fewer invalid command/input errors
3. **Time to Complete**: Faster workflow completion for new users
4. **User Feedback**: Positive sentiment in feedback

**Monitoring**:
- Track config settings (how many enable/disable interactive)
- Track "Other" usage (do users type or select?)
- Track transition prompt usage (if enabled, do users use it?)

---

## Future Enhancements (P2/P3)

**Not in Initial Release**:
1. Multi-select feature options (US4)
2. Validation issue resolution (US5)
3. Implementation mode selection (US6)
4. Template selection (US7)
5. Skill discovery menu (US8)

**Consider for Later**:
- Keyboard shortcuts (if AskUserQuestion supports)
- Recent selections memory
- Favorite commands quick access
- Voice commands (far future)

---

## Dependencies

**External**:
- AskUserQuestion tool (built-in to Claude Code) ✅
- No additional tools required

**Internal**:
- Feature 001 (Flow Init Optimization) complete ✅
- `routing.sh` for phase detection ✅
- `config.sh` for configuration management ✅
- `format-output.sh` for status indicators (informational) ✅

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Users dislike interactive prompts | Low | Medium | Keep CLI mode, make interactive optional |
| Too many prompts slow workflow | Medium | Medium | Config toggles, smart defaults |
| "Other" option UX confusing | Low | Low | Clear labels, examples, validation |
| Breaking automation | Very Low | High | Auto-detect CLI args, skip prompts |
| Performance degradation | Very Low | Low | Prompts are async, no performance impact |

---

## Success Criteria

**MVP Complete When**:
1. ✅ Interactive `/flow` menu works (US1)
2. ✅ flow:init prompts refined (US2)
3. ✅ Phase transitions implemented (US3)
4. ✅ All tests passing
5. ✅ Documentation updated
6. ✅ Backward compatible

**Definition of Done**:
- All P1 user stories implemented
- Tests passing
- Docs updated
- Plugin and marketplace both updated
- No regressions in existing functionality

---

## Timeline Estimate

| Phase | Duration | Dependencies |
|-------|----------|--------------|
| Phase 1: Foundation | 30 min | None |
| Phase 2: /flow Menu | 1.5 hours | Phase 1 |
| Phase 3: flow:init | 1 hour | Phase 1 |
| Phase 4: Transitions | 1.5 hours | Phase 1, 2, 3 |
| Phase 5: Documentation | 45 min | Phase 2, 3, 4 |
| Phase 6: Testing | 45 min | All phases |
| **Total** | **5-6 hours** | |

**Critical Path**: Phase 1 → Phase 2 → Phase 5 → Phase 6

---

**Next Step**: Run `/flow tasks` to break this plan into actionable implementation tasks.
