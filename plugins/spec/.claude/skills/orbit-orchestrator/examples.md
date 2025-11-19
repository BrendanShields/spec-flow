# Orchestrating Workflow: Usage Examples

This document provides real-world examples of using auto-mode workflow orchestration.

---

## Example 1: First-Time Auto-Mode Usage

**Scenario**: New user wants to create a feature using auto-mode for the first time.

**User Action**:
```
$ /spec
```

**Auto-Mode Offering**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 SPEC WORKFLOW

No active feature. Start a new one?

→ 🚀 Auto Mode (Recommended)
  Runs Spec → Clarify → Plan → Tasks automatically
  Pauses at checkpoints for review

  🎯 Interactive Mode
  Step-by-step control through each phase

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Which mode?
> Auto Mode
```

**Feature Input**:
```
[Auto-Mode] Starting workflow...

Describe your feature in natural language:

  Examples:
  • "Auth system for end users, P1"
  • "User dashboard showing metrics (critical)"
  • "Dark mode theme (nice to have)"

  Tips:
  • Include priority: P1/critical, P2/should, P3/nice
  • Mention personas: users, admins, developers
  • Context auto-detected from codebase

> Authentication system for end users with OAuth2 support, critical priority
```

**Workflow Execution**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Auto-Mode] Phase 1/5: SPECIFICATION

Generating feature specification...
✓ Analyzed input (confidence: 95%)
✓ Created 5 user stories (4 P1, 1 P2)
✓ Identified 2 clarifications needed
✓ Wrote .spec/features/003-auth/spec.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ CHECKPOINT: Specification Complete

Created:
  📄 .spec/features/003-auth/spec.md (5 user stories)
  📋 2 clarifications needed

Next: Clarifications (Phase 2/5)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Continue to clarifications? (auto in 10s)
→ Continue    Refine    Pause    Exit

> [User presses Enter or waits 10s]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Auto-Mode] Phase 2/5: CLARIFICATIONS

Resolving 2 clarifications...

Q1: OAuth2 provider support (Google, GitHub, both)?
  → Google only    GitHub only    Both

> Both

Q2: Session duration?
  → 1 hour    24 hours    7 days    Custom

> 24 hours

✓ Clarifications resolved
✓ Updated spec.md with decisions

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ CHECKPOINT: Clarifications Complete

Resolved:
  ✓ OAuth2 providers: Google + GitHub
  ✓ Session duration: 24 hours

Next: Technical Plan (Phase 3/5)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Continue to planning? (auto in 10s)
→ Continue    Review    Pause    Exit

> [Auto-continues after 10s]

[... continues through Planning and Tasks phases ...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ CHECKPOINT: Tasks Ready

Created:
  🎯 .spec/features/003-auth/tasks.md (24 tasks)
  📊 Critical path: 16-20h (T001→T024)
  ⚡ Parallel execution: ~8 days

Next: Implementation (Phase 5/5)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Begin implementation?
→ Start Implementation    Review Tasks    Exit

> Review Tasks

[Opens tasks.md for user to review]

Run /spec to continue when ready.
```

**Result**: User completed Spec → Clarify → Plan → Tasks in ~7 minutes with 4 interactions (vs 15+ minutes and 50+ interactions in interactive mode).

---

## Example 2: Resuming After Interruption

**Scenario**: User's auto-mode session was interrupted during planning phase (network issue, Ctrl+C, etc.).

**Next Session**:
```
$ /spec

⚠️  Auto-mode interrupted during Planning phase

Progress saved:
  ✓ Specification (5 user stories)
  ✓ Clarifications (2 resolved)
  ⚠️ Planning (interrupted at ~60%)

Time remaining: 18h until expiry

Resume from Planning phase?
→ Resume    Restart    Interactive

> Resume

Resuming from Planning phase...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Auto-Mode] Phase 3/5: PLANNING

Creating technical implementation plan...
✓ Designed AuthService component
✓ Documented 3 architecture decisions
✓ Identified 2 technical risks
✓ Wrote .spec/features/003-auth/plan.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ CHECKPOINT: Planning Complete
[... continues from where interrupted ...]
```

**Result**: User seamlessly resumed workflow without losing any progress.

---

## Example 3: Keyword-Driven Continuation

**Scenario**: User completed planning phase and notification suggests next action.

**After Planning Phase**:
```
[Auto-Mode] Planning phase complete.

[Spec Workflow] ✅ Planning complete → Next: Tasks
Say 'continue' or run /spec for options
```

**User Types**:
```
> continue

Continuing to task breakdown...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Auto-Mode] Phase 4/5: TASK BREAKDOWN

Breaking plan into atomic tasks...
[... continues automatically ...]
```

**Result**: No need to manually run `/spec`, just type "continue" to progress.

---

## Example 4: Pausing Mid-Workflow

**Scenario**: User wants to pause after spec to discuss with team before continuing.

**At Spec Checkpoint**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ CHECKPOINT: Specification Complete

Created:
  📄 .spec/features/004-dashboard/spec.md (8 user stories)
  📋 3 clarifications needed

Next: Clarifications (Phase 2/5)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Continue to clarifications? (auto in 10s)
→ Continue    Refine    Pause    Exit

> Pause

⏸️  Auto-mode paused

Progress saved. Run /spec to:
  • Resume auto-mode
  • Switch to interactive mode
  • Review current state
```

**Later (After Team Discussion)**:
```
$ /spec

⚠️  Auto-mode paused at Clarifications phase

Resume auto-mode?
→ Resume    Restart    Interactive

> Resume

[... continues from clarifications ...]
```

**Result**: User can pause at any checkpoint and resume later.

---

## Example 5: Refining Specification

**Scenario**: User reviews spec and wants to make changes before continuing.

**At Spec Checkpoint**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ CHECKPOINT: Specification Complete

Created:
  📄 .spec/features/005-reporting/spec.md (6 user stories)
  📋 1 clarification needed

Next: Clarifications (Phase 2/5)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Continue to clarifications? (auto in 10s)
→ Continue    Refine    Pause    Exit

> Refine

Refining specification...

Options:
1. Re-run specification phase
2. Edit spec.md manually
3. Cancel refine, continue to next phase

Choose (1-3): 2

Opening .spec/features/005-reporting/spec.md for editing.
Run /spec to continue when ready.
```

**After Manual Edits**:
```
$ /spec

Continue auto-mode from Clarifications?
→ Resume    Restart

> Resume

[... continues with updated spec ...]
```

**Result**: User can refine work at checkpoints and continue auto-mode.

---

## Example 6: Skipping Clarifications

**Scenario**: Spec has no `[CLARIFY]` tags, auto-mode skips clarification phase.

**Workflow**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Auto-Mode] Phase 1/5: SPECIFICATION

✓ Created 4 user stories (all P1)
✓ No clarifications needed
✓ Wrote .spec/features/006-simple/spec.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ CHECKPOINT: Specification Complete

Created:
  📄 .spec/features/006-simple/spec.md (4 user stories)
  ✅ No clarifications needed

Next: Technical Plan (Phase 3/5)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Continue to planning? (auto in 10s)
→ Continue    Refine    Pause    Exit

> [Auto-continues]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Auto-Mode] Phase 3/5: PLANNING
(Skipped Phase 2: Clarifications - not needed)

[... continues directly to planning ...]
```

**Result**: Auto-mode intelligently skips unnecessary phases.

---

## Example 7: Customized Checkpoint Strategy

**Scenario**: Experienced user customizes checkpoints to minimize interruptions.

**Configuration** (`.spec/.spec-config.yml`):
```yaml
auto_mode:
  checkpoints:
    after_spec: false      # Skip spec checkpoint
    after_clarify: false   # Skip clarify checkpoint
    after_plan: true       # Keep plan checkpoint
    after_tasks: true      # Keep tasks checkpoint
    before_implement: true # Always required
    timeout: 5             # Faster timeout (5s instead of 10s)
    default_action: continue
```

**Workflow**:
```
[Auto-Mode] Phase 1/5: SPECIFICATION
✓ Created spec.md
[No checkpoint - auto-continues]

[Auto-Mode] Phase 2/5: CLARIFICATIONS
✓ Resolved clarifications
[No checkpoint - auto-continues]

[Auto-Mode] Phase 3/5: PLANNING
✓ Created plan.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ CHECKPOINT: Planning Complete
[... only shows plan and tasks checkpoints ...]

Continue to tasks? (auto in 5s)
→ Continue    Review    Pause    Exit

> [Auto-continues after 5s]
```

**Result**: User optimizes workflow to their preferences (faster, fewer interruptions).

---

## Example 8: Expired Session

**Scenario**: User interrupted auto-mode 2 days ago, session expired (24h limit).

**Attempting Resume**:
```
$ /spec

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

> Yes (Auto Mode)

[Starts fresh auto-mode session]
```

**Result**: Expired sessions handled gracefully with helpful guidance.

---

## Example 9: Multiple Interruptions

**Scenario**: User's workflow interrupted multiple times (network issues, power loss, etc.).

**First Interruption**:
```
[Auto-Mode] Phase 2/5: CLARIFICATIONS

^C
⚠️  Auto-mode interrupted (SIGINT)
Saving progress...
Progress saved. Run /spec to resume.
```

**Resume and Second Interruption**:
```
$ /spec

Resume from Clarifications? (interrupted 1 time)
> Resume

[Auto-Mode] Phase 2/5: CLARIFICATIONS
[... working ...]

[Network disconnects]

⚠️  Auto-mode interrupted (connection lost)
Saving progress...
Progress saved (interrupted 2 times).
```

**Final Resume**:
```
$ /spec

Resume from Clarifications? (interrupted 2 times)
> Resume

[... completes successfully ...]
```

**Result**: Multiple interruptions handled robustly, state preserved each time.

---

## Example 10: Switching from Auto to Interactive

**Scenario**: User starts with auto-mode but wants to switch to interactive mid-workflow.

**Mid-Workflow**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ CHECKPOINT: Planning Complete

[...]

Continue to tasks? (auto in 10s)
→ Continue    Review    Pause    Exit

> Exit

🛑 Exiting auto-mode

Options:
1. Save progress and exit (can resume later)
2. Discard auto-mode session (switch to interactive)

Choose (1-2): 2

Auto-mode session discarded.
Switching to interactive mode...

[Shows traditional /spec menu with current progress]
```

**Result**: User can exit auto-mode and continue manually if needed.

---

## Common Patterns

### Pattern 1: Rapid Prototyping
**Use Case**: Quick spec → plan → tasks for small features
**Config**: Disable all checkpoints except before_implement, timeout=0
**Result**: Full workflow in ~2 minutes

### Pattern 2: Team Collaboration
**Use Case**: Pause after each phase to review with team
**Config**: Enable all checkpoints, timeout=0 (manual approval)
**Result**: Controlled progression with team sign-off

### Pattern 3: Solo Deep Work
**Use Case**: Uninterrupted flow for complex features
**Config**: Disable spec/clarify checkpoints, keep plan/tasks, timeout=10
**Result**: Balance between automation and control

---

## Tips for Effective Auto-Mode Usage

1. **First Run**: Use all checkpoints enabled to understand workflow
2. **After Familiarity**: Disable early checkpoints, keep critical ones
3. **Complex Features**: Keep all checkpoints for thorough review
4. **Simple Features**: Use minimal checkpoints for speed
5. **Team Projects**: Use longer timeouts (15-30s) for discussion time
6. **Solo Projects**: Use shorter timeouts (5s) for rapid progression

---

## Troubleshooting

### Auto-Mode Not Offered
**Symptom**: `/spec` doesn't show auto-mode option
**Solution**: Check `.spec/.spec-config.yml` has `auto_mode.enabled: true`

### Checkpoint Skipped
**Symptom**: Expected checkpoint didn't appear
**Solution**: Check checkpoint configuration in `.spec-config.yml`

### Resume Failed
**Symptom**: Resume option not working
**Solution**: Check `.spec/state/auto-mode-session.json` exists and not expired

### Keyword Not Detected
**Symptom**: Typing "continue" doesn't progress
**Solution**: Ensure keyword is in first 50 characters of message

---

**See Also**:
- SKILL.md: Core functionality and logic
- reference.md: Function implementations
- ../../docs/patterns/workflow-patterns.md: Integration patterns
