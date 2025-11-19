---
name: orbit-orchestrator
description: Orchestrates automatic Orbit workflow progression through lifecycle + planning phases with strategic checkpoints and resume capability
category: project
activation_patterns:
  - user says "auto mode"
  - user says "orchestrate workflow"
  - user says "run automatically"
  - command /spec with auto-mode selection
  - resuming interrupted auto-mode session
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Skill
  - AskUserQuestion
---

# Orbit Orchestrator Skill

**Purpose**: Automatically progress through workflow phases with minimal user interaction, strategic checkpoints, and robust interruption handling.

**When to activate**:
- User selects "Auto Mode" from `/spec` command
- User types "auto mode" or "orchestrate" in conversation
- Resuming an interrupted auto-mode session
- User types "continue" after a phase completion (keyword detection)

**What this skill does**:
1. **Phase Orchestration**: Automatically transitions through Spec → Clarify → Plan → Tasks phases
2. **Smart Checkpoints**: Pauses at strategic points for user review (configurable timeouts)
3. **Interruption Handling**: Saves state on Ctrl+C, errors, or crashes
4. **Resume Capability**: Offers resume after interruptions with progress summary
5. **Keyword Detection**: Responds to "continue" to progress to next phase

---

## Activation Flow

### Scenario 1: Starting Auto-Mode

**Trigger**: User selects "Auto Mode" from `/spec` command or types "auto mode"

**Steps**:
1. Check for interrupted session first (offer resume if found)
2. Prompt for feature description (single text input)
3. Generate session ID and initialize state
4. Execute phases sequentially with checkpoints
5. Mark session complete when finished

### Scenario 2: Resuming Interrupted Session

**Trigger**: Auto-mode session interrupted (status = "interrupted" or "paused")

**Steps**:
1. Detect interrupted session on startup (via session-start hook or `/spec`)
2. Display resume prompt with progress summary
3. If user chooses "Resume", continue from interruption point
4. If user chooses "Restart", clear session and start fresh
5. If user chooses "Interactive", remove session and return to menu

### Scenario 3: Keyword-Driven Continuation

**Trigger**: User types "continue", "next", "proceed", "go", or "yes" after phase completion

**Steps**:
1. Detect keyword in user message (first 50 characters)
2. Load next phase from state
3. Automatically invoke next skill without showing menu
4. Continue auto-mode orchestration

---

## Execution Logic

### Main Orchestration Flow

```bash
# Pseudocode for orchestration

function orchestrate_auto_mode() {
  # 1. Initialize
  session_id = generate_session_id()
  save_auto_mode_state(session_id, "running", "specification")

  # 2. Gather feature input (single text prompt)
  feature_description = prompt_for_feature()

  # 3. Phase 1: Specification
  run_phase("specification", "orbit-lifecycle", feature_description)
  if checkpoint("spec_complete", timeout=10, next="clarification") == EXIT:
    return

  # 4. Phase 2: Clarification (conditional)
  if has_clarifications():
    run_phase("clarification", "orbit-lifecycle")
    if checkpoint("clarify_complete", timeout=10, next="planning") == EXIT:
      return

  # 5. Phase 3: Planning
  run_phase("planning", "orbit-planning")
  if checkpoint("plan_complete", timeout=10, next="tasks") == EXIT:
    return

  # 6. Phase 4: Tasks
  run_phase("tasks", "orbit-planning")
  if checkpoint("tasks_complete", timeout=0, next="implementation") == EXIT:
    return

  # 7. Phase 5: Implementation (opt-in via checkpoint)
  if user_chose("start_implementation"):
    run_phase("implementation", "orbit-lifecycle")

  # 8. Complete
  mark_session_complete(session_id)
  display_completion_summary()
}
```

### Phase Execution

```bash
function run_phase(phase_name, skill_name, initial_input="") {
  echo "[Auto-Mode] Phase: $phase_name"

  # Update state
  update_auto_mode_state(phase_name, "running")
  backup_state()

  # Invoke skill (using Skill tool)
  if [ -n "$initial_input" ]; then
    skill_output = invoke_skill(skill_name, input=initial_input)
  else
    skill_output = invoke_skill(skill_name)
  fi

  # Check for errors
  if skill_failed(skill_output):
    handle_skill_error(phase_name, skill_output)
    return ERROR

  # Mark complete
  update_auto_mode_state(phase_name, "complete")
  add_completed_phase(phase_name)

  return SUCCESS
}
```

### Checkpoint Display

```bash
function checkpoint(checkpoint_id, timeout, next_phase) {
  # Load configuration
  config = load_checkpoint_config()

  # Check if checkpoint should be shown
  if config.skip_checkpoint(checkpoint_id):
    return CONTINUE

  # Display checkpoint UI
  display_checkpoint_header(checkpoint_id)
  display_checkpoint_summary(checkpoint_id)
  display_next_phase(next_phase)

  # Prompt with timeout (if applicable)
  if timeout > 0:
    response = prompt_with_timeout(timeout, next_phase)
  else:
    response = prompt_without_timeout(next_phase)

  # Process response
  case response:
    "continue" | "start" | "":
      return CONTINUE
    "refine" | "review":
      handle_refine_request()
      return CONTINUE  # After refine, continue
    "pause":
      handle_pause_request()
      return PAUSE
    "exit":
      handle_exit_request()
      return EXIT
}
```

---

## Interruption Handling

### Signal Traps

Auto-mode sets up signal handlers to catch interruptions:

```bash
trap 'handle_interruption SIGINT' SIGINT
trap 'handle_interruption SIGTERM' SIGTERM
trap 'handle_interruption ERR' ERR

function handle_interruption(signal) {
  echo ""
  echo "⚠️  Auto-mode interrupted ($signal)"
  echo "Saving progress..."

  # Update state
  current_phase = get_current_phase()
  update_auto_mode_state(current_phase, "interrupted")
  increment_interruption_count()

  echo "Progress saved. Run /spec to resume."
  exit 130
}
```

### Resume Logic

When resuming an interrupted session:

```bash
function resume_auto_mode() {
  # Load session
  session = load_auto_mode_session()

  # Check expiry
  if is_expired(session.expires_at):
    echo "Session expired. Please start fresh."
    remove_session()
    return

  # Display resume prompt
  display_resume_prompt(session)

  # Get user decision
  read response

  case response:
    "resume" | "":
      orchestrate_from_phase(session.current_phase)
    "restart":
      remove_session()
      orchestrate_auto_mode()
    "interactive":
      remove_session()
      return
}

function orchestrate_from_phase(start_phase) {
  # Resume from specific phase
  # (Skips already-completed phases)

  case start_phase:
    "specification":
      run_phase("specification", "orbit-lifecycle")
      checkpoint("spec_complete", 10, "clarification")
      # Continue to remaining phases...

    "clarification":
      run_phase("clarification", "orbit-lifecycle")
      checkpoint("clarify_complete", 10, "planning")
      # Continue to remaining phases...

    "planning":
      run_phase("planning", "orbit-planning")
      checkpoint("plan_complete", 10, "tasks")
      # Continue to remaining phases...

    "tasks":
      run_phase("tasks", "orbit-planning")
      checkpoint("tasks_complete", 0, "implementation")
}
```

---

## State Management

### State Files

1. **`.spec/state/auto-mode-session.json`**
   - Session ID, status, current phase
   - Completed phases array
   - Timestamps (started, expires)
   - Interruption count
   - Checkpoint configuration

2. **`.spec/state/backups/`**
   - Automatic backups before each phase
   - Rollback capability on errors
   - Keep last 10 backups

### State Schema

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "mode": "auto",
  "status": "running|paused|interrupted|complete",
  "started_at": "2025-11-19T12:00:00Z",
  "current_phase": "planning",
  "completed_phases": ["specification", "clarification"],
  "checkpoint_strategy": {
    "after_spec": true,
    "timeout": 10
  },
  "interruption_count": 0,
  "expires_at": "2025-11-20T12:00:00Z",
  "metadata": {
    "feature_id": "003-feature-name",
    "feature_name": "Feature Name"
  }
}
```

---

## Resume & Interruption Handling

### Overview

Auto-mode workflow is designed to be resilient to interruptions. Sessions can be interrupted at any point (Ctrl+C, network issues, system crashes) and seamlessly resumed later without losing progress.

### Interruption Types

1. **User Interruption (Ctrl+C)**
   - Signal: SIGINT
   - State saved immediately
   - Status: `"interrupted"`
   - Resume: Automatic detection on next `/spec`

2. **System Interruption**
   - Signal: SIGTERM, errors, crashes
   - State saved via signal handlers
   - Status: `"interrupted"`
   - Resume: Automatic detection with progress summary

3. **User Pause**
   - Triggered by "Pause" action at checkpoint
   - Status: `"paused"`
   - Resume: User-initiated via `/spec`

4. **Session Expiry**
   - After 24 hours (configurable)
   - State preserved but resume disabled
   - User must start new session

### Interruption Flow

```bash
# 1. User starts auto-mode
/spec
→ Auto Mode
→ "Authentication system, P1"

# 2. Workflow running...
[Auto-Mode] Phase 1/5: SPECIFICATION
✓ Created spec.md
[Auto-Mode] Phase 2/5: CLARIFICATIONS
Q1: OAuth2 providers?
→ Both

# 3. Interruption occurs (Ctrl+C)
^C
⚠️  Auto-mode interrupted (SIGINT)
Saving progress...
Progress saved. Run /spec to resume.

# 4. Resume later
/spec

⚠️  Auto-mode interrupted during Clarifications phase

Progress saved:
  ✓ Specification (6 user stories)
  ⚠️ Clarifications (interrupted at 50%)

Time remaining: 18h until expiry

Resume from Clarifications phase?
→ Resume    Restart    Interactive

→ Resume

[Auto-Mode] Phase 2/5: CLARIFICATIONS (Resuming...)
```

### Resume Detection

When `/spec` is run, auto-mode checks for interrupted sessions in this order:

1. **Check Session File**: `.spec/state/auto-mode-session.json` exists?
2. **Check Status**: `status` is `"interrupted"` or `"paused"`?
3. **Check Expiry**: Session < 24 hours old?
4. **Offer Resume**: Show progress summary and resume options

**Code Example**:
```bash
function detect_resumable_session() {
  local session_file=".spec/state/auto-mode-session.json"

  [ ! -f "$session_file" ] && return 1

  local status=$(jq -r '.status' "$session_file")
  [ "$status" != "interrupted" ] && [ "$status" != "paused" ] && return 1

  local expires_at=$(jq -r '.expires_at' "$session_file")
  is_expired "$expires_at" && return 1

  return 0  # Resumable session found
}
```

### Resume Options

When resumable session detected, user sees:

```
⚠️  Auto-mode interrupted during Planning phase

Progress saved:
  ✓ Specification (6 user stories)
  ✓ Clarifications (2 resolved)
  ⚠️ Planning (interrupted at ~60%)

Time remaining: 18h until expiry

Resume from Planning phase?
→ Resume    Restart    Interactive
```

**Options:**

1. **Resume** (default)
   - Continue from interruption point
   - Preserve completed phases
   - Re-run interrupted phase from beginning
   - Maintain session ID and metadata

2. **Restart**
   - Discard interrupted session
   - Start fresh auto-mode workflow
   - New session ID
   - User prompted for feature description again

3. **Interactive**
   - Exit auto-mode
   - Return to manual `/spec` menu
   - Session file removed
   - User controls each step

### State Preservation

Auto-mode saves state at these points:

1. **Before Each Phase**: Backup created in `.spec/state/backups/`
2. **After Phase Complete**: Completed phases array updated
3. **On Checkpoint**: State checkpoint before user prompt
4. **On Interruption**: Immediate atomic write to session JSON
5. **On Pause**: Status updated to `"paused"`

**Backup Example**:
```bash
.spec/state/backups/
├── auto-mode-20251119-120000.json  # Oldest
├── auto-mode-20251119-121500.json
├── auto-mode-20251119-123000.json
└── auto-mode-20251119-124500.json  # Newest (last 10 kept)
```

### Rollback Capability

If phase fails or produces incorrect output, users can roll back:

**Manual Rollback**:
```bash
# From checkpoint, select "Refine"
→ Refine

Refining planning...

Options:
1. Re-run current phase
2. Edit plan.md manually
3. Cancel refine, continue to next phase

Choose (1-3): 1

Re-running planning...
```

**Automatic Rollback on Error**:
```bash
⚠️  Phase planning failed

Error: orbit-planning skill returned error

Options:
1. Rollback to last backup (phase: clarification, time: 2min ago)
2. Retry current phase
3. Exit auto-mode

Choose (1-3): 1

Rolling back to backup...
State restored from auto-mode-20251119-124500.json
Resuming from clarification phase...
```

### Multiple Interruptions

Sessions track interruption count for debugging:

```json
{
  "interruption_count": 3,
  "status": "interrupted"
}
```

**Behavior:**
- Interruptions < 10: Normal resume
- Interruptions ≥ 10: Warning shown (may indicate instability)
- No automatic session invalidation (user decides)

### Session Expiry

Sessions expire after 24 hours (configurable):

```
⚠️  Auto-mode session expired

Session from: 2025-11-17T10:00:00Z
Expired: 2025-11-18T10:00:00Z (25 hours ago)

Progress was saved at:
  ✓ Specification
  ✓ Clarifications
  ⚠️ Planning (interrupted)

Session too old to resume automatically.
Please start a new workflow.

Review saved files at:
  .spec/features/007-old-feature/spec.md
  .spec/state/backups/ (manual inspection)

Start new feature?
→ Yes (Auto Mode)    Yes (Interactive)    No
```

**Rationale:**
- Prevents stale sessions from accumulating
- Encourages timely completion
- Avoids conflicts with newer work
- Configurable via `.spec-config.yml`

### Error Recovery

Auto-mode includes automatic error recovery:

1. **Skill Failure**: Offer retry, rollback, or exit
2. **State Corruption**: Restore from most recent backup
3. **Partial Artifacts**: Clean up incomplete files
4. **Network Issues**: Interruption handling kicks in
5. **User Cancellation**: Clean pause/exit

**Cleanup Example**:
```bash
# After failed planning phase
clean_partial_artifacts "planning"

Cleaning partial artifacts from planning...
  Removing incomplete plan.md
✓ Cleanup complete
```

### Best Practices

**For Users:**
1. Don't manually edit `.spec/state/auto-mode-session.json`
2. Resume within 24 hours to avoid expiry
3. Use "Pause" for planned breaks (cleaner than Ctrl+C)
4. Review backups if unexpected behavior occurs
5. Use "Restart" if multiple interruptions occur

**For Developers:**
1. All state writes are atomic (temp file + rename)
2. Signal handlers registered at workflow start
3. Backups created before destructive operations
4. Session expiry enforced on resume attempt
5. Interruption count tracked for diagnostics

### Configuration

Resume behavior configured in `.spec/.spec-config.yml`:

```yaml
auto_mode:
  session:
    expiry_hours: 24          # Session lifetime
    max_interruptions: 10     # Warning threshold
    auto_resume: true         # Offer resume automatically
    cleanup_expired: true     # Remove expired sessions on startup
```

### Troubleshooting

**Resume Not Offered**
- Check `.spec/state/auto-mode-session.json` exists
- Verify `status` is `"interrupted"` or `"paused"`
- Check session not expired (< 24 hours)

**Multiple Interrupted Sessions**
- Only one session supported at a time
- Newest session takes precedence
- Old sessions cleaned up automatically

**Resume Fails**
- Check backups in `.spec/state/backups/`
- Manually restore if needed: `cp backup.json auto-mode-session.json`
- Verify JSON is valid: `jq . auto-mode-session.json`

**State Corruption**
- Automatic restore from backup attempted
- Manual intervention: delete session file, restart
- Backups preserved for recovery

---

## Checkpoint UI Examples

### After Specification

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ CHECKPOINT: Specification Complete

Created:
  📄 .spec/features/003-auth/spec.md (6 user stories)
  📋 4 clarifications needed

Next: Clarifications (Phase 2/5)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Continue to clarifications? (auto in 10s)
→ Continue    Refine    Pause    Exit

>
```

### Before Implementation

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ CHECKPOINT: Tasks Ready

Created:
  🎯 .spec/features/003-auth/tasks.md (28 tasks)
  📊 Critical path: 18-22h (T001→T028)
  ⚡ Parallel execution: ~10 days

Next: Implementation (Phase 5/5)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Begin implementation?
→ Start Implementation    Review Tasks    Exit

>
```

---

## Checkpoint System

### Overview

Checkpoints are strategic pause points in the auto-mode workflow where users can review progress and decide how to proceed. They balance automation with control, allowing users to:

- **Review**: Inspect generated artifacts (spec, plan, tasks)
- **Refine**: Re-run phase or manually edit outputs
- **Continue**: Auto-proceed to next phase (default)
- **Pause**: Save progress and exit (resume later)
- **Exit**: Abandon auto-mode and return to interactive

### Checkpoint Locations

1. **After Specification** (`spec_complete`)
   - Review generated user stories and acceptance criteria
   - Check clarification tags before continuing
   - Default: 10-second timeout, auto-continue

2. **After Clarifications** (`clarify_complete`)
   - Review resolved clarifications
   - Ensure decisions align with requirements
   - Default: 10-second timeout, auto-continue

3. **After Planning** (`plan_complete`)
   - Review technical design and ADRs
   - Check component architecture and risks
   - Default: 10-second timeout, auto-continue

4. **After Tasks** (`tasks_complete`)
   - Review task breakdown and dependencies
   - Verify effort estimates and critical path
   - Default: 10-second timeout, auto-continue

5. **Before Implementation** (`before_implement`)
   - Final review before code execution
   - Always required (cannot be disabled)
   - Default: No timeout, manual approval required

### Checkpoint Actions

Each checkpoint offers four actions:

#### Continue
- **Purpose**: Proceed to next phase automatically
- **When to use**: Happy with current output, trust automation
- **Result**: Workflow advances to next phase
- **Shortcut**: Press Enter or wait for timeout

#### Refine
- **Purpose**: Improve current phase output
- **Options**:
  1. **Re-run Phase**: Regenerate artifacts (useful if LLM produced suboptimal output)
  2. **Manual Edit**: Open files in editor, resume when ready
  3. **Cancel**: Continue to next phase without changes
- **Result**: Returns to checkpoint after refinement

#### Pause
- **Purpose**: Save progress and exit gracefully
- **When to use**: Need to discuss with team, take a break, review offline
- **Result**: Session saved to `.spec/state/auto-mode-session.json`
- **Resume**: Run `/spec` again, select "Resume"

#### Exit
- **Purpose**: Abandon auto-mode permanently
- **Options**:
  1. **Save Progress**: Can resume later (same as Pause)
  2. **Discard Session**: Switch to interactive mode, delete auto-mode state
- **Result**: Returns to manual workflow

### Configuration

Checkpoints are fully customizable via `.spec/.spec-config.yml`:

```yaml
auto_mode:
  checkpoints:
    # Enable/disable individual checkpoints
    after_spec: true          # Show after specification
    after_clarify: true       # Show after clarifications
    after_plan: true          # Show after planning
    after_tasks: true         # Show after tasks
    before_implement: true    # Always required, cannot disable

    # Timeout behavior
    timeout: 10               # Seconds (0 = no timeout, wait indefinitely)
    default_action: continue  # Action when timeout expires (continue or pause)
```

### Customization Examples

#### Example 1: Rapid Prototyping (Minimal Interruptions)
```yaml
auto_mode:
  checkpoints:
    after_spec: false       # Skip spec review
    after_clarify: false    # Skip clarify review
    after_plan: true        # Review plan (important)
    after_tasks: true       # Review tasks (important)
    before_implement: true  # Always required
    timeout: 5              # Fast timeout (5s)
    default_action: continue
```

**Result**: Spec → Clarify run automatically, pause only at Plan, Tasks, Implementation

#### Example 2: Team Collaboration (Maximum Control)
```yaml
auto_mode:
  checkpoints:
    after_spec: true
    after_clarify: true
    after_plan: true
    after_tasks: true
    before_implement: true
    timeout: 0              # No timeout, manual approval only
    default_action: pause
```

**Result**: Every checkpoint requires manual approval, no auto-continue

#### Example 3: Solo Deep Work (Balanced)
```yaml
auto_mode:
  checkpoints:
    after_spec: false       # Trust LLM
    after_clarify: false    # Trust LLM
    after_plan: true        # Review architecture
    after_tasks: true       # Review task breakdown
    before_implement: true  # Always required
    timeout: 10             # Standard timeout
    default_action: continue
```

**Result**: Auto-run early phases, review critical design decisions

### Technical Implementation

#### Config Loading
1. Check for `.spec/.spec-config.yml`
2. Parse `auto_mode.checkpoints` section (supports `yq` or fallback grep/awk)
3. Fall back to hardcoded defaults if config missing/invalid
4. Return JSON object with checkpoint configuration

#### Checkpoint Flow
1. **Check Config**: Call `should_show_checkpoint(checkpoint_id)`
2. **Skip if Disabled**: Return immediately, auto-continue
3. **Display UI**: Show formatted checkpoint header, summary, next phase
4. **Prompt User**:
   - If `timeout > 0`: Use `read -t` with countdown
   - If `timeout = 0`: Wait indefinitely for input
5. **Process Response**: Map user choice to action (continue/refine/pause/exit)
6. **Return Code**:
   - `0`: Continue to next phase
   - `1`: Exit auto-mode
   - `2`: Re-run current phase (refine)

#### State Updates
- **Pause**: Update `status` to `"paused"` in session JSON
- **Exit**: Update `status` to `"interrupted"` or remove session file
- **Continue**: No state change, workflow proceeds
- **Refine (Re-run)**: Decrement phase counter, mark phase incomplete

### Best Practices

1. **First-Time Users**: Enable all checkpoints to understand workflow
2. **After Familiarity**: Disable early checkpoints for speed
3. **Complex Features**: Keep all checkpoints for thorough review
4. **Simple Features**: Use minimal checkpoints (plan + tasks only)
5. **Team Projects**: Use longer timeouts (15-30s) for discussion
6. **Solo Projects**: Use shorter timeouts (5s) or disable checkpoints

### Troubleshooting

**Checkpoint Not Showing**
- Check `.spec/.spec-config.yml` has `after_X: true`
- Verify checkpoint isn't skipped due to conditions (e.g., no clarifications)

**Timeout Not Working**
- Ensure Bash ≥4.0 (check: `bash --version`)
- Verify `timeout` is a number in config (not string)

**Refine Not Working**
- Ensure feature directory exists (`.spec/features/XXX-name/`)
- Check file permissions for manual editing

**Resume Not Offering After Pause**
- Check `.spec/state/auto-mode-session.json` exists
- Verify session not expired (24 hours default)
- Ensure `status` is `"paused"` or `"interrupted"`

---

## Configuration

Auto-mode behavior is configured in `.spec/.spec-config.yml`:

```yaml
auto_mode:
  enabled: true
  checkpoints:
    after_spec: true
    after_clarify: true
    after_plan: true
    after_tasks: true
    before_implement: true  # Always required
    timeout: 10  # Seconds (0 = no timeout)
    default_action: continue  # or pause
  session:
    expiry_hours: 24
    max_interruptions: 10
  notifications:
    enabled: true
    keywords: ["continue", "next", "proceed", "go", "yes"]
```

---

## Error Handling

### Skill Execution Errors

If a skill fails during auto-mode:

```
⚠️  Phase planning failed

Error: orbit-planning skill returned error

Options:
1. Retry phase
2. Skip phase and continue
3. Exit auto-mode

Choose (1-3):
```

### State Corruption

If state file is corrupted:

```
⚠️  State file corruption detected

Attempting to restore from backup...
✓ Restored from backup (2 minutes ago)

Resuming from planning phase...
```

---

## Success Metrics

**Performance Targets**:
- Phase transition latency: <2s
- Checkpoint display: <500ms
- State persistence: <100ms
- Resume load: <3s

**User Experience**:
- Manual `/spec` runs: 6 → 1-2 (67-83% reduction)
- Total interactions: ~50 → ~10 (80% reduction)
- Workflow time: 15min → 5min (67% faster)

---

## Implementation Details

All core functions (state management, checkpoint display, phase sequencing) are implemented in `reference.md` as bash functions.

See:
- **reference.md**: Detailed function implementations
- **examples.md**: Real-world usage scenarios
- **../../docs/patterns/workflow-patterns.md**: Integration patterns

---

## Notes for Implementation

1. **Skill Invocation**: This skill uses the `Skill` tool to invoke other workflow skills programmatically
2. **State Atomicity**: All state writes use temp-file + rename pattern for atomic updates
3. **Backward Compatibility**: Auto-mode is opt-in; interactive mode remains unchanged
4. **Hook Integration**: Works with session-start, notification, and post-tool-use hooks
5. **Testing**: Comprehensive tests in `tests/test-orchestrator.sh`

---

**Status**: Ready for implementation (T001-T032 in tasks.md)
**Dependencies**: Bash ≥4.0, jq ≥1.6, Claude Code ≥2.0.0
**Estimated Effort**: 72-94 hours (~10 days with parallelization)
