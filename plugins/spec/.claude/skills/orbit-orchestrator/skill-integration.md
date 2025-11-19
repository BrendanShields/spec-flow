# Skill Integration Guide for Auto-Mode

This document defines how workflow skills integrate with auto-mode orchestration by returning structured completion data.

## Overview

Auto-mode orchestrator invokes skills sequentially and reads their completion status from:
1. **Exit code** (0 = success, non-zero = failure)
2. **State files** (updated by skill execution)
3. **Completion markers** (created artifacts, resolved tags)

Skills don't need to return JSON or special formats - they simply complete their work and auto-mode detects completion via file system checks.

---

## Skill Integration Pattern

### Standard Workflow Skills

**orbit-lifecycle**:
```bash
# Completion detection:
# - File exists: .spec/features/{id}/spec.md
# - Contains user stories: grep "^### US-" spec.md
# - Exit code: 0

# Auto-mode checks:
has_spec() {
  local feature_dir=$(get_current_feature_dir)
  [ -f "$feature_dir/spec.md" ] && grep -q "^### US-" "$feature_dir/spec.md"
}
```

**orbit-lifecycle (Clarify branch)**:
```bash
# Completion detection:
# - [CLARIFY] tags resolved: ! grep "\[CLARIFY\]" spec.md
# - Or user skipped clarifications
# - Exit code: 0

# Auto-mode checks:
has_clarifications() {
  local feature_dir=$(get_current_feature_dir)
  [ -f "$feature_dir/spec.md" ] && grep -q "\[CLARIFY\]" "$feature_dir/spec.md"
}

clarifications_resolved() {
  local feature_dir=$(get_current_feature_dir)
  ! has_clarifications
}
```

**orbit-planning (Plan branch)**:
```bash
# Completion detection:
# - File exists: .spec/features/{id}/plan.md
# - Contains ADRs: grep "^## ADR-" plan.md
# - Exit code: 0

# Auto-mode checks:
has_plan() {
  local feature_dir=$(get_current_feature_dir)
  [ -f "$feature_dir/plan.md" ] && grep -q "^## ADR-" "$feature_dir/plan.md"
}
```

**orbit-planning (Tasks branch)**:
```bash
# Completion detection:
# - File exists: .spec/features/{id}/tasks.md
# - Contains tasks: grep "^### T[0-9]" tasks.md
# - Exit code: 0

# Auto-mode checks:
has_tasks() {
  local feature_dir=$(get_current_feature_dir)
  [ -f "$feature_dir/tasks.md" ] && grep -q "^### T[0-9]" "$feature_dir/tasks.md"
}
```

**orbit-lifecycle (Implement branch)**:
```bash
# Completion detection:
# - All tasks marked complete in tasks.md
# - Or user exits implementation
# - Exit code: 0

# Auto-mode checks:
implementation_complete() {
  local feature_dir=$(get_current_feature_dir)
  local tasks_file="$feature_dir/tasks.md"

  # Count total vs completed tasks
  local total=$(grep -c "^### T[0-9]" "$tasks_file")
  local complete=$(grep -c "^- \[x\].*T[0-9]" "$tasks_file")

  [ "$complete" -eq "$total" ]
}
```

---

## Phase Sequencing Logic

Auto-mode uses these checks to sequence phases:

### Phase 1: Specification
```bash
function phase_specification() {
  echo "[Auto-Mode] Phase 1/5: SPECIFICATION"

  # Invoke orbit-lifecycle skill
  # Skill creates .spec/features/{id}/spec.md

  # Wait for completion (skill returns)

  # Verify completion
  if ! has_spec; then
    echo "Error: Specification phase failed to create spec.md"
    rollback_on_error "specification"
    return 1
  fi

  # Mark complete
  add_completed_phase "specification"

  return 0
}
```

### Phase 2: Clarification (Conditional)
```bash
function phase_clarification() {
  # Check if clarifications needed
  if ! has_clarifications; then
    echo "[Auto-Mode] Skipping clarifications (none needed)"
    return 0
  fi

  echo "[Auto-Mode] Phase 2/5: CLARIFICATIONS"

  # Invoke orbit-lifecycle (Clarify branch) skill
  # Skill resolves [CLARIFY] tags in spec.md

  # Wait for completion

  # Verify completion
  if ! clarifications_resolved; then
    echo "Warning: Some clarifications may still be unresolved"
    # Non-fatal, continue
  fi

  # Mark complete
  add_completed_phase "clarification"

  return 0
}
```

### Phase 3: Planning
```bash
function phase_planning() {
  echo "[Auto-Mode] Phase 3/5: PLANNING"

  # Invoke orbit-planning (Plan branch) skill
  # Skill creates .spec/features/{id}/plan.md

  # Wait for completion

  # Verify completion
  if ! has_plan; then
    echo "Error: Planning phase failed to create plan.md"
    rollback_on_error "planning"
    return 1
  fi

  # Mark complete
  add_completed_phase "planning"

  return 0
}
```

### Phase 4: Tasks
```bash
function phase_tasks() {
  echo "[Auto-Mode] Phase 4/5: TASKS"

  # Invoke orbit-planning (Tasks branch) skill
  # Skill creates .spec/features/{id}/tasks.md

  # Wait for completion

  # Verify completion
  if ! has_tasks; then
    echo "Error: Tasks phase failed to create tasks.md"
    rollback_on_error "tasks"
    return 1
  fi

  # Mark complete
  add_completed_phase "tasks"

  return 0
}
```

### Phase 5: Implementation (Opt-in)
```bash
function phase_implementation() {
  echo "[Auto-Mode] Phase 5/5: IMPLEMENTATION"

  # Invoke orbit-lifecycle (Implement branch) skill
  # Skill executes tasks incrementally

  # Wait for completion (or user exit)

  # Check if complete (non-fatal if incomplete)
  if implementation_complete; then
    echo "✓ All tasks completed!"
  else
    echo "⚠️  Implementation partially complete"
    echo "   Run /spec to continue building"
  fi

  # Mark complete
  add_completed_phase "implementation"

  return 0
}
```

---

## Main Orchestration Flow

The orchestrator chains phases together:

```bash
function orchestrate_auto_mode() {
  local feature_description="${1:-}"
  local session_id=$(generate_session_id)

  # Initialize session
  save_auto_mode_state "$session_id" "running" "specification"

  # Set up interruption handlers
  trap 'handle_interruption SIGINT' SIGINT
  trap 'handle_interruption SIGTERM' SIGTERM

  # Gather feature input if not provided
  if [ -z "$feature_description" ]; then
    echo ""
    echo "Describe your feature in natural language:"
    echo ""
    echo "  Examples:"
    echo "  • \"Auth system for end users, P1\""
    echo "  • \"User dashboard showing metrics (critical)\""
    echo "  • \"Dark mode theme (nice to have)\""
    echo ""
    echo "  Tips:"
    echo "  • Include priority: P1/critical, P2/should, P3/nice"
    echo "  • Mention personas: users, admins, developers"
    echo "  • Context auto-detected from codebase"
    echo ""
    read -p "> " feature_description
  fi

  # Store feature description in metadata
  update_auto_mode_metadata "feature_description" "$feature_description"

  # Phase 1: Specification
  phase_specification || return 1
  checkpoint "spec_complete" "" "clarification" || return 1

  # Phase 2: Clarification (conditional)
  if has_clarifications; then
    phase_clarification || return 1
    checkpoint "clarify_complete" "" "planning" || return 1
  fi

  # Phase 3: Planning
  phase_planning || return 1
  checkpoint "plan_complete" "" "tasks" || return 1

  # Phase 4: Tasks
  phase_tasks || return 1
  checkpoint "tasks_complete" 0 "implementation" || return 1

  # Phase 5: Implementation (opt-in at checkpoint)
  # Checkpoint above offers "Start Implementation" or "Exit"
  # If user chose "Start Implementation", continue:
  if [ "$CHECKPOINT_RESPONSE" = "start" ]; then
    phase_implementation
  fi

  # Mark session complete
  mark_session_complete "$session_id"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ Auto-mode workflow complete!"
  echo ""
  echo "Created:"
  echo "  📄 Specification"
  echo "  📐 Technical Plan"
  echo "  🎯 Task Breakdown"
  if [ "$CHECKPOINT_RESPONSE" = "start" ]; then
    echo "  🔨 Implementation (in progress)"
  fi
  echo ""
  echo "Run /spec to continue or start a new feature"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  return 0
}
```

---

## Skill Exit Codes

Skills should follow standard Unix exit codes:

- **0**: Success, phase completed
- **1**: Fatal error, cannot continue
- **2**: Non-fatal error, user may retry
- **130**: User interrupted (Ctrl+C)

Auto-mode handles each:

```bash
run_phase() {
  local phase_name="$1"
  local skill_name="$2"

  # Invoke skill (pseudo-code)
  invoke_skill "$skill_name"
  local exit_code=$?

  case $exit_code in
    0)
      echo "✓ Phase $phase_name complete"
      return 0
      ;;
    1)
      echo "✗ Fatal error in $phase_name"
      rollback_on_error "$phase_name"
      return 1
      ;;
    2)
      echo "⚠️  Non-fatal error in $phase_name"
      # Offer retry
      echo "Retry $phase_name? (y/n)"
      read retry
      [ "$retry" = "y" ] && run_phase "$phase_name" "$skill_name"
      ;;
    130)
      echo "⚠️  User interrupted"
      handle_interruption "SIGINT"
      return 130
      ;;
  esac
}
```

---

## Skill Metadata (Optional)

Skills may optionally write metadata for auto-mode to display:

### Completion Metadata Format

**`.spec/state/skill-metadata.json`** (optional):
```json
{
  "skill": "orbit-lifecycle",
  "phase": "specification",
  "completed_at": "2025-11-19T12:34:56Z",
  "artifacts": [
    ".spec/features/003-auth/spec.md"
  ],
  "stats": {
    "user_stories": 6,
    "clarifications": 4,
    "priorities": {
      "P1": 4,
      "P2": 2,
      "P3": 0
    }
  },
  "next_action": "clarification"
}
```

Auto-mode can read this to enhance checkpoint summaries:

```bash
display_checkpoint_summary() {
  local checkpoint_id="$1"

  # Try to read skill metadata
  if [ -f ".spec/state/skill-metadata.json" ]; then
    local user_stories=$(jq -r '.stats.user_stories' .spec/state/skill-metadata.json)
    local clarifications=$(jq -r '.stats.clarifications' .spec/state/skill-metadata.json)

    echo "Created:"
    echo "  📄 spec.md ($user_stories user stories)"
    echo "  📋 $clarifications clarifications needed"
  else
    # Fallback: count manually
    count_user_stories
  fi
}
```

---

## Integration Checklist

For each workflow skill to integrate with auto-mode:

- [ ] **Exit code 0** on successful completion
- [ ] **Create expected artifacts** (spec.md, plan.md, tasks.md)
- [ ] **Update state files** if needed
- [ ] **Handle interruptions** gracefully (save work on Ctrl+C)
- [ ] **(Optional)** Write metadata to `.spec/state/skill-metadata.json`
- [ ] **(Optional)** Support resume mode (detect partial work)

---

## Testing Skill Integration

Test that skills work with auto-mode:

```bash
# Test individual skill
function test_skill_integration() {
  local skill_name="orbit-lifecycle"

  # Set up test environment
  mkdir -p .spec/features/test-001

  # Invoke skill
  invoke_skill "$skill_name"
  local exit_code=$?

  # Verify exit code
  assert_equals 0 $exit_code "Skill returns success"

  # Verify artifacts
  assert_file_exists ".spec/features/test-001/spec.md"

  # Verify content
  grep -q "^### US-" .spec/features/test-001/spec.md
  assert_equals 0 $? "Spec contains user stories"

  # Clean up
  rm -rf .spec/features/test-001
}
```

---

## Examples

### Example 1: Successful Phase Sequence

```bash
# User runs auto-mode
/spec
→ Auto Mode
→ "User dashboard, P1"

[Auto-Mode] Phase 1/5: SPECIFICATION
Analyzing input (confidence: 95%)
✓ Created 5 user stories (4 P1, 1 P2)
✓ Identified 2 clarifications needed
✓ Wrote .spec/features/003-dashboard/spec.md

✅ CHECKPOINT: Specification Complete
Continue to clarifications? (auto in 10s)
→ [Auto-continues]

[Auto-Mode] Phase 2/5: CLARIFICATIONS
Q1: Dashboard metrics (real-time or daily summary)?
→ Real-time
Q2: User roles (all users or admins only)?
→ All users
✓ Clarifications resolved

✅ CHECKPOINT: Clarifications Complete
Continue to planning? (auto in 10s)
→ [Auto-continues]

[Auto-Mode] Phase 3/5: PLANNING
✓ Designed DashboardService component
✓ Documented 3 architecture decisions
✓ Identified 2 technical risks
✓ Wrote .spec/features/003-dashboard/plan.md

✅ CHECKPOINT: Planning Complete
Continue to tasks? (auto in 10s)
→ [Auto-continues]

[Auto-Mode] Phase 4/5: TASKS
✓ Created 24 tasks
✓ Critical path: 16-20h
✓ Wrote .spec/features/003-dashboard/tasks.md

✅ CHECKPOINT: Tasks Ready
Begin implementation?
→ Review Tasks

[Opens tasks.md]
Run /spec to continue when ready.
```

### Example 2: Interruption During Planning

```bash
[Auto-Mode] Phase 3/5: PLANNING
Creating technical implementation plan...
^C

⚠️  Auto-mode interrupted (SIGINT)
Saving progress...
Progress saved. Run /spec to resume.

# Later...
/spec

⚠️  Auto-mode interrupted during Planning phase

Progress saved:
  ✓ Specification (5 user stories)
  ✓ Clarifications (2 resolved)
  ⚠️ Planning (interrupted at ~40%)

Resume from Planning phase?
→ Resume

[Auto-Mode] Phase 3/5: PLANNING (Resuming...)
✓ Created plan.md
[Continues from where interrupted]
```

---

## Summary

**Key Points**:
1. Skills don't need special auto-mode awareness
2. Completion detected via exit codes + file checks
3. Orchestrator handles sequencing, checkpoints, state
4. Skills focus on their domain logic
5. Optional metadata enhances UX but not required

**Benefits**:
- Skills remain simple and focused
- Auto-mode handles orchestration complexity
- Easy to add new skills to workflow
- Testable in isolation
- Works with existing skills unchanged
