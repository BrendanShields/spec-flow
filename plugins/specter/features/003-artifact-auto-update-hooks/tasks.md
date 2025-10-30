# Tasks: Artifact Auto-Update Hooks

**Feature**: 003-artifact-auto-update-hooks
**Created**: 2024-10-31
**Total Tasks**: 30
**Estimated Duration**: 80 hours (2 weeks)
**Dependencies**: Feature 002 (specter-consolidation-v3) must be complete

---

## Task Legend

- `[P]` = Parallelizable (can run concurrently with other [P] tasks in same phase)
- `@username` = Assigned to specific team member
- `⏱️` = Time estimate
- `🔗` = Dependencies (must complete before this task)

---

## Phase 1: Hook Infrastructure (1 week, 40 hours)

### P1.1: Directory Structure & Configuration (6 hours)

#### T001: Create hook directory structure
**Description**: Set up `.specter/hooks/` directory with subdirectories
**Priority**: P1
**Effort**: 2 hours
**Dependencies**: None
**Acceptance Criteria**:
- [ ] Directory `.specter/hooks/core/` exists
- [ ] Directory `.specter/hooks/custom/` exists
- [ ] Directory `.specter/cache/master-spec/` exists
- [ ] Directory `.specter/logs/` exists
- [ ] README in each directory explaining purpose

**Implementation**:
```bash
mkdir -p .specter/hooks/{core,custom}
mkdir -p .specter/cache/master-spec
mkdir -p .specter/logs
```

---

#### T002: Create hook configuration schema [P]
**Description**: Define JSON schema for hook configuration
**Priority**: P1
**Effort**: 4 hours
**Dependencies**: T001
**Acceptance Criteria**:
- [ ] File `.specter/hooks/config.json` created
- [ ] Schema includes all hook events
- [ ] Includes timeout, blocking, enabled settings
- [ ] Validation rules defined
- [ ] Example provided in comments

**Implementation**:
```json
{
  "hooks": {
    "post-command": {
      "enabled": true,
      "mode": "async",
      "blocking": false,
      "timeout": 5000,
      "scripts": ["core/post-command.sh"]
    },
    "on-task-complete": {
      "enabled": true,
      "mode": "sync",
      "blocking": false,
      "timeout": 2000,
      "scripts": ["core/on-task-complete.sh"]
    },
    "pre-commit": {
      "enabled": true,
      "mode": "sync",
      "blocking": true,
      "timeout": 10000,
      "scripts": ["core/pre-commit.sh"]
    },
    "post-merge": {
      "enabled": true,
      "mode": "sync",
      "blocking": false,
      "timeout": 5000,
      "scripts": ["core/post-merge.sh"]
    }
  },
  "validation": {
    "schema": true,
    "consistency": true,
    "locks": true
  },
  "performance": {
    "budgets": {
      "post-command": 100,
      "on-task-complete": 50,
      "pre-commit": 500,
      "post-merge": 200
    }
  }
}
```

---

### P1.2: Hook Runner Engine (16 hours)

#### T003: Implement core hook runner
**Description**: Create `specter_run_hooks()` function with sync/async execution
**Priority**: P1
**Effort**: 8 hours
**Dependencies**: T002
**Acceptance Criteria**:
- [ ] Function `specter_run_hooks()` in `.specter/lib/hook-runner.sh`
- [ ] Supports sync and async modes
- [ ] Reads configuration from config.json
- [ ] Executes hooks in order
- [ ] Returns appropriate exit codes
- [ ] Logs to `.specter/logs/hooks.log`

**Implementation**:
```bash
# .specter/lib/hook-runner.sh

specter_run_hooks() {
  local event=$1        # post-command, pre-commit, etc.
  local context=$2      # JSON context for hooks

  # Load configuration
  local config=".specter/hooks/config.json"

  if ! jq -e ".hooks[\"$event\"]" "$config" >/dev/null 2>&1; then
    echo "⚠️  Unknown hook event: $event" >&2
    return 1
  fi

  local enabled=$(jq -r ".hooks[\"$event\"].enabled" "$config")
  if [[ "$enabled" != "true" ]]; then
    return 0  # Hook disabled
  fi

  local mode=$(jq -r ".hooks[\"$event\"].mode" "$config")
  local blocking=$(jq -r ".hooks[\"$event\"].blocking" "$config")
  local scripts=$(jq -r ".hooks[\"$event\"].scripts[]" "$config")

  if [[ "$mode" == "async" ]]; then
    {
      for script in $scripts; do
        _run_single_hook "$event" "$script" "$context" "$blocking"
      done
    } &
    echo $! > ".specter/logs/hook-${event}.pid"
  else
    for script in $scripts; do
      if ! _run_single_hook "$event" "$script" "$context" "$blocking"; then
        if [[ "$blocking" == "true" ]]; then
          return 1
        fi
      fi
    done
  fi

  return 0
}
```

---

#### T004: Implement single hook execution with timeout [P]
**Description**: Create `_run_single_hook()` helper with sandboxing and timeout
**Priority**: P1
**Effort**: 8 hours
**Dependencies**: T003
**Acceptance Criteria**:
- [ ] Function `_run_single_hook()` implemented
- [ ] Timeout enforcement from config
- [ ] Sandboxed environment (limited PATH)
- [ ] Context passed via stdin (JSON)
- [ ] Output logged to hooks.log
- [ ] Exit code captured and handled
- [ ] Performance measured and logged

**Implementation**:
```bash
_run_single_hook() {
  local event=$1
  local script=$2
  local context=$3
  local blocking=$4

  local timeout=$(jq -r ".hooks[\"$event\"].timeout" .specter/hooks/config.json)
  local hook_path=".specter/hooks/$script"

  if [[ ! -f "$hook_path" ]]; then
    echo "⚠️  Hook not found: $hook_path" >&2
    return 1
  fi

  # Sandbox environment
  local sandbox_env="PATH=/usr/bin:/bin"
  sandbox_env="$sandbox_env SPECTER_ROOT=$(pwd)"
  sandbox_env="$sandbox_env SPECTER_EVENT=$event"

  # Execute with timeout
  local start_time=$(date +%s%N)

  if timeout "${timeout}ms" env -i $sandbox_env bash "$hook_path" <<< "$context" \
      >> ".specter/logs/hooks.log" 2>&1; then
    local exit_code=0
  else
    local exit_code=$?
  fi

  local end_time=$(date +%s%N)
  local elapsed_ms=$(( (end_time - start_time) / 1000000 ))

  # Log performance
  echo "[$(date -Iseconds)] $event:$script - ${elapsed_ms}ms - exit:$exit_code" \
    >> ".specter/logs/hook-performance.log"

  return $exit_code
}
```

---

### P1.3: Atomic State Updates (12 hours)

#### T005: Implement atomic state update function
**Description**: Create `specter_update_state()` with file locking and validation
**Priority**: P1
**Effort**: 8 hours
**Dependencies**: None
**Acceptance Criteria**:
- [ ] Function `specter_update_state()` in `.specter/lib/state-sync.sh`
- [ ] File locking with flock
- [ ] Atomic writes (temp + mv)
- [ ] JSON validation before and after update
- [ ] Automatic markdown regeneration
- [ ] Error handling and rollback
- [ ] Lock timeout (10 seconds)

**Implementation**:
```bash
# .specter/lib/state-sync.sh

specter_update_state() {
  local state_file=$1
  local jq_expression=$2

  # Acquire lock
  local lock_file="${state_file}.lock"
  exec 200>"$lock_file"

  if ! flock -x -w 10 200; then
    echo "❌ Failed to acquire lock on $state_file" >&2
    return 1
  fi

  # Validate current state
  if ! jq empty "$state_file" 2>/dev/null; then
    echo "❌ Invalid JSON in $state_file" >&2
    flock -u 200
    return 1
  fi

  # Create temp file with update
  local temp_file="${state_file}.tmp"
  if ! jq "$jq_expression" "$state_file" > "$temp_file"; then
    echo "❌ jq update failed" >&2
    rm -f "$temp_file"
    flock -u 200
    return 1
  fi

  # Validate updated state
  if ! jq empty "$temp_file" 2>/dev/null; then
    echo "❌ Update produced invalid JSON" >&2
    rm -f "$temp_file"
    flock -u 200
    return 1
  fi

  # Atomic move
  mv "$temp_file" "$state_file"

  # Regenerate markdown
  local md_file="${state_file%.json}.md"
  specter_generate_md "$state_file" > "${md_file}.tmp"
  mv "${md_file}.tmp" "$md_file"

  # Release lock
  flock -u 200
  exec 200>&-
  rm -f "$lock_file"

  return 0
}
```

---

#### T006: Implement markdown generator [P]
**Description**: Create `specter_generate_md()` to convert JSON to markdown
**Priority**: P1
**Effort**: 4 hours
**Dependencies**: T005
**Acceptance Criteria**:
- [ ] Function `specter_generate_md()` implemented
- [ ] Supports session.json → current-session.md
- [ ] Supports workflow.json → WORKFLOW-PROGRESS.md
- [ ] Preserves formatting and structure
- [ ] Handles missing/null fields gracefully
- [ ] Performance < 100ms for typical files

**Implementation**:
```bash
specter_generate_md() {
  local json_file=$1

  case "$(basename $json_file)" in
    session.json)
      _generate_session_md "$json_file"
      ;;
    workflow.json)
      _generate_workflow_md "$json_file"
      ;;
    decisions.json)
      _generate_decisions_md "$json_file"
      ;;
    *)
      echo "❌ Unknown JSON file: $json_file" >&2
      return 1
      ;;
  esac
}

_generate_session_md() {
  local json_file=$1

  cat <<EOF
# Specter Plugin Development Session

## Session Information
- **Session ID**: $(jq -r '.sessionId' "$json_file")
- **Started**: $(jq -r '.started' "$json_file")
- **Type**: $(jq -r '.type' "$json_file")

## Current Context

### Active Feature
**Feature**: $(jq -r '.activeFeature.name' "$json_file")
**Phase**: $(jq -r '.activeFeature.phase' "$json_file")
**Progress**: $(jq -r '.activeFeature.progress' "$json_file")%

## Feature Pipeline

$(jq -r '.features[] | "| \(.id) | \(.name) | \(.priority) | \(.status) | \(.progress)% |"' "$json_file")

## Task Progress

**Total Tasks**: $(jq -r '.tasks.total' "$json_file")
**Completed**: $(jq -r '.tasks.completed' "$json_file")
**In Progress**: $(jq -r '.tasks.inProgress' "$json_file")

---

*Auto-generated from session.json*
*Last updated: $(date +%Y-%m-%d)*
EOF
}
```

---

### P1.4: Logging & Error Handling (6 hours)

#### T007: Implement logging system [P]
**Description**: Create comprehensive logging for hook execution
**Priority**: P2
**Effort**: 4 hours
**Dependencies**: T003
**Acceptance Criteria**:
- [ ] Function `specter_log_hook()` implemented
- [ ] Logs to `.specter/logs/hooks.log`
- [ ] Includes timestamp, event, script, status
- [ ] Separate performance log
- [ ] Log rotation (keep last 7 days)
- [ ] Configurable log level

**Implementation**:
```bash
specter_log_hook() {
  local level=$1    # INFO, WARN, ERROR
  local event=$2
  local script=$3
  local message=$4

  local timestamp=$(date -Iseconds)
  local log_file=".specter/logs/hooks.log"

  echo "[$timestamp] $level [$event:$script] $message" >> "$log_file"

  # Rotate logs if > 7 days old
  find .specter/logs -name "hooks.log.*" -mtime +7 -delete
}
```

---

#### T008: Add error recovery mechanism [P]
**Description**: Implement retry logic for failed hooks
**Priority**: P2
**Effort**: 2 hours
**Dependencies**: T003, T007
**Acceptance Criteria**:
- [ ] Failed hooks logged to retry queue
- [ ] Retry on next command execution
- [ ] Max 3 retry attempts
- [ ] Exponential backoff
- [ ] Clear error messages to user

---

## Phase 2: Core Hooks (3 days, 24 hours)

### P2.1: Post-Command Hook (6 hours)

#### T009: Implement post-command hook
**Description**: Create hook that runs after every `/specter` command
**Priority**: P1
**Effort**: 6 hours
**Dependencies**: T005, T006
**Acceptance Criteria**:
- [ ] File `.specter/hooks/core/post-command.sh` created
- [ ] Updates session.json with current phase
- [ ] Updates workflow.json with metrics
- [ ] Regenerates markdown files
- [ ] Performance < 100ms
- [ ] Non-blocking on failure

**Implementation**:
```bash
#!/bin/bash
# .specter/hooks/core/post-command.sh

set -euo pipefail

source .specter/lib/state-sync.sh

# Read context from stdin
context=$(cat)

event=$(echo "$context" | jq -r '.event')
feature_id=$(echo "$context" | jq -r '.activeFeature.id // empty')
phase=$(echo "$context" | jq -r '.activeFeature.phase // empty')

# Update session.json
if [[ -n "$phase" ]]; then
  specter_update_state .specter-state/session.json \
    ".activeFeature.phase = \"$phase\" | .lastUpdated = \"$(date -Iseconds)\""
fi

# Update workflow.json metrics
specter_update_state .specter-memory/workflow.json \
  ".lastCommandRun = \"$(date -Iseconds)\" | .commandCount += 1"

echo "✅ State synchronized"
```

---

### P2.2: Task Completion Hook (6 hours)

#### T010: Implement on-task-complete hook [P]
**Description**: Create hook that runs when tasks are marked complete
**Priority**: P1
**Effort**: 6 hours
**Dependencies**: T005, T006
**Acceptance Criteria**:
- [ ] File `.specter/hooks/core/on-task-complete.sh` created
- [ ] Updates task status in session.json
- [ ] Moves task from planned to completed
- [ ] Recalculates feature progress
- [ ] Updates velocity metrics
- [ ] Performance < 50ms

**Implementation**:
```bash
#!/bin/bash
# .specter/hooks/core/on-task-complete.sh

set -euo pipefail

source .specter/lib/state-sync.sh

context=$(cat)
task_id=$(echo "$context" | jq -r '.taskId')
feature_id=$(echo "$context" | jq -r '.featureId')

# Mark task complete in session.json
specter_update_state .specter-state/session.json \
  "(.tasks[] | select(.id == \"$task_id\") | .status) = \"complete\""

# Update workflow metrics
specter_update_state .specter-memory/workflow.json \
  ".metrics.completedTasks += 1"

# Move to CHANGES-COMPLETED
task_desc=$(jq -r ".tasks[] | select(.id == \"$task_id\") | .description" .specter-state/session.json)
echo "- [$task_id] $task_desc ($(date +%Y-%m-%d))" >> .specter-memory/CHANGES-COMPLETED.md

# Recalculate progress
total_tasks=$(jq -r '.tasks | length' .specter-state/session.json)
completed_tasks=$(jq -r '[.tasks[] | select(.status == "complete")] | length' .specter-state/session.json)
progress=$(( completed_tasks * 100 / total_tasks ))

specter_update_state .specter-state/session.json \
  ".activeFeature.progress = $progress"

echo "✅ Task $task_id complete ($completed_tasks/$total_tasks = $progress%)"
```

---

### P2.3: Decision Capture (6 hours)

#### T011: Implement decision extraction from plan.md [P]
**Description**: Parse ADRs from plan.md and log to decisions.json
**Priority**: P1
**Effort**: 6 hours
**Dependencies**: T005, T006
**Acceptance Criteria**:
- [ ] Function `specter_extract_decisions()` implemented
- [ ] Parses ADR-XXX sections
- [ ] Extracts title, decision, context
- [ ] Updates decisions.json
- [ ] Regenerates DECISIONS-LOG.md
- [ ] Handles various ADR formats

**Implementation**:
```bash
specter_extract_decisions() {
  local plan_file=$1
  local feature_id=$2

  awk '
    BEGIN { in_adr=0; adr_id=""; title=""; decision=""; context="" }

    /^### ADR-[0-9]+:/ {
      # Save previous ADR if exists
      if (in_adr && adr_id != "") {
        printf "{\"id\":\"%s\",\"title\":\"%s\",\"decision\":\"%s\",\"context\":\"%s\",\"feature\":\"%s\",\"date\":\"%s\"},\n",
          adr_id, title, decision, context, feature_id, date
      }

      # Start new ADR
      in_adr=1
      adr_id=$2
      title=$0
      gsub(/^### ADR-[0-9]+: /, "", title)
      decision=""
      context=""
      mode=""
      next
    }

    /^\*\*Decision\*\*:/ { mode="decision"; next }
    /^\*\*Context\*\*:/ { mode="context"; next }
    /^\*\*/ { mode=""; next }

    in_adr && mode=="decision" { decision = decision " " $0 }
    in_adr && mode=="context" { context = context " " $0 }

    END {
      # Save last ADR
      if (in_adr && adr_id != "") {
        printf "{\"id\":\"%s\",\"title\":\"%s\",\"decision\":\"%s\",\"context\":\"%s\",\"feature\":\"%s\",\"date\":\"%s\"}",
          adr_id, title, decision, context, feature_id, date
      }
    }
  ' feature_id="$feature_id" date="$(date +%Y-%m-%d)" "$plan_file" | \
  while IFS= read -r line; do
    specter_update_state .specter-memory/decisions.json \
      ". += [$line]"
  done

  # Regenerate DECISIONS-LOG.md
  specter_generate_md .specter-memory/decisions.json > .specter-memory/DECISIONS-LOG.md
}
```

---

### P2.4: Master Spec Generation (6 hours)

#### T012: Implement master spec generator [P]
**Description**: Create incremental master spec aggregator
**Priority**: P1
**Effort**: 6 hours
**Dependencies**: T005, T011
**Acceptance Criteria**:
- [ ] Function `specter_generate_master_spec()` implemented
- [ ] Incremental regeneration with caching
- [ ] Aggregates all features
- [ ] Includes decisions and metrics
- [ ] Atomic writes
- [ ] Performance < 2s for 50 features

**Implementation**: See plan.md ADR-010 for full implementation

---

## Phase 3: Git Hooks (2 days, 16 hours)

### P3.1: Pre-Commit Hook (8 hours)

#### T013: Implement pre-commit validation
**Description**: Create hook to validate state before git commit
**Priority**: P1
**Effort**: 6 hours
**Dependencies**: T005
**Acceptance Criteria**:
- [ ] File `.specter/hooks/core/pre-commit.sh` created
- [ ] Validates session.json schema
- [ ] Validates workflow.json schema
- [ ] Checks JSON ↔ MD consistency
- [ ] Validates no stale locks
- [ ] Blocks commit on failure
- [ ] Clear error messages

**Implementation**:
```bash
#!/bin/bash
# .specter/hooks/core/pre-commit.sh

set -euo pipefail

echo "🔍 Validating Specter state..."

errors=0

# Validate JSON schemas
for json_file in .specter-state/*.json .specter-memory/*.json; do
  if [[ -f "$json_file" ]]; then
    if ! jq empty "$json_file" 2>/dev/null; then
      echo "❌ Invalid JSON: $json_file"
      ((errors++))
    fi
  fi
done

# Check JSON ↔ MD consistency
if [[ -f .specter-state/session.json ]]; then
  temp_md=$(mktemp)
  specter_generate_md .specter-state/session.json > "$temp_md"

  if ! diff -q "$temp_md" .specter-state/current-session.md >/dev/null 2>&1; then
    echo "❌ session.json and current-session.md out of sync"
    echo "   Run: specter_generate_md .specter-state/session.json > .specter-state/current-session.md"
    ((errors++))
  fi

  rm "$temp_md"
fi

# Check for stale locks
if [[ -d .specter-state/locks ]]; then
  for lock_file in .specter-state/locks/*.lock; do
    if [[ -f "$lock_file" ]]; then
      ttl=$(jq -r '.ttl' "$lock_file")
      locked_at=$(jq -r '.lockedAt' "$lock_file")

      now=$(date -u +%s)
      locked_ts=$(date -jf "%Y-%m-%dT%H:%M:%SZ" "$locked_at" +%s)
      elapsed=$((now - locked_ts))

      if [[ $elapsed -gt $ttl ]]; then
        echo "❌ Stale lock detected: $lock_file (${elapsed}s old)"
        ((errors++))
      fi
    fi
  done
fi

if [[ $errors -gt 0 ]]; then
  echo ""
  echo "❌ Pre-commit validation failed ($errors errors)"
  echo "   Fix errors above or commit with --no-verify to skip"
  exit 1
fi

echo "✅ Validation passed"
exit 0
```

---

#### T014: Create git hook installer [P]
**Description**: Install pre-commit hook in .git/hooks/
**Priority**: P1
**Effort**: 2 hours
**Dependencies**: T013
**Acceptance Criteria**:
- [ ] Function `specter_install_git_hooks()` implemented
- [ ] Installs pre-commit hook
- [ ] Checks for existing hooks
- [ ] Provides uninstall capability
- [ ] Documentation in README

**Implementation**: See plan.md ADR-011

---

### P3.2: Post-Merge Hook (8 hours)

#### T015: Implement post-merge synchronization [P]
**Description**: Create hook to sync state after git pull/merge
**Priority**: P1
**Effort**: 6 hours
**Dependencies**: T005, T006
**Acceptance Criteria**:
- [ ] File `.specter/hooks/core/post-merge.sh` created
- [ ] Regenerates all markdown from JSON
- [ ] Detects conflicting locks
- [ ] Warns if active feature modified
- [ ] Updates team dashboard
- [ ] Non-blocking on errors

**Implementation**:
```bash
#!/bin/bash
# .specter/hooks/core/post-merge.sh

set -euo pipefail

echo "🔄 Syncing Specter state after merge..."

# Regenerate all markdown files
for json_file in .specter-state/*.json .specter-memory/*.json; do
  if [[ -f "$json_file" ]]; then
    md_file="${json_file%.json}.md"
    specter_generate_md "$json_file" > "$md_file"
    echo "✅ Regenerated $(basename $md_file)"
  fi
done

# Check for conflicting locks
if [[ -d .specter-state/locks ]]; then
  my_user=$(git config user.name)

  for lock_file in .specter-state/locks/*.lock; do
    if [[ -f "$lock_file" ]]; then
      locked_by=$(jq -r '.lockedBy' "$lock_file")
      feature_id=$(jq -r '.featureId' "$lock_file")

      if [[ "$locked_by" != "$my_user" ]]; then
        echo "⚠️  Feature $feature_id is locked by $locked_by"
        echo "   Consider: /specter team (view status)"
      fi
    fi
  done
fi

echo "✅ State synchronized"
```

---

#### T016: Implement conflict detection [P]
**Description**: Detect when teammate modified current feature
**Priority**: P2
**Effort**: 2 hours
**Dependencies**: T015
**Acceptance Criteria**:
- [ ] Compares pre-merge and post-merge state
- [ ] Detects changes to active feature
- [ ] Shows clear warning message
- [ ] Suggests resolution steps

---

## Phase 4: Testing & Polish (2 days, 16 hours)

### P4.1: Unit Tests (8 hours)

#### T017: Create hook runner tests
**Description**: Unit tests for hook execution engine
**Priority**: P1
**Effort**: 3 hours
**Dependencies**: T003, T004
**Acceptance Criteria**:
- [ ] File `tests/unit/test-hook-runner.sh` created
- [ ] Tests sync execution
- [ ] Tests async execution
- [ ] Tests timeout handling
- [ ] Tests error handling
- [ ] Tests configuration loading
- [ ] All tests passing

---

#### T018: Create atomic update tests [P]
**Description**: Unit tests for state update mechanism
**Priority**: P1
**Effort**: 3 hours
**Dependencies**: T005
**Acceptance Criteria**:
- [ ] File `tests/unit/test-atomic-updates.sh` created
- [ ] Tests file locking
- [ ] Tests atomic writes
- [ ] Tests validation
- [ ] Tests concurrent access
- [ ] All tests passing

---

#### T019: Create decision parser tests [P]
**Description**: Unit tests for ADR extraction
**Priority**: P1
**Effort**: 2 hours
**Dependencies**: T011
**Acceptance Criteria**:
- [ ] File `tests/unit/test-decision-parser.sh` created
- [ ] Tests various ADR formats
- [ ] Tests edge cases
- [ ] Tests error handling
- [ ] All tests passing

---

### P4.2: Integration Tests (4 hours)

#### T020: Create workflow integration tests [P]
**Description**: End-to-end tests with hooks enabled
**Priority**: P1
**Effort**: 2 hours
**Dependencies**: All core hooks
**Acceptance Criteria**:
- [ ] File `tests/integration/test-workflow-with-hooks.sh` created
- [ ] Tests full workflow (init → implement)
- [ ] Verifies state updates at each step
- [ ] Verifies markdown regeneration
- [ ] Verifies master spec updates
- [ ] All tests passing

---

#### T021: Create git workflow tests [P]
**Description**: Tests for git hook integration
**Priority**: P1
**Effort**: 2 hours
**Dependencies**: T013, T015
**Acceptance Criteria**:
- [ ] File `tests/integration/test-git-workflow.sh` created
- [ ] Tests pre-commit validation
- [ ] Tests post-merge sync
- [ ] Tests conflict detection
- [ ] Tests with invalid state (should block)
- [ ] All tests passing

---

### P4.3: Performance Tests (4 hours)

#### T022: Implement performance benchmarks [P]
**Description**: Validate hook performance budgets
**Priority**: P1
**Effort**: 4 hours
**Dependencies**: All hooks
**Acceptance Criteria**:
- [ ] File `tests/performance/test-hook-performance.sh` created
- [ ] Tests each hook individually
- [ ] Validates against budgets
- [ ] Measures full workflow impact
- [ ] Generates performance report
- [ ] All budgets met

**Implementation**: See plan.md ADR-012

---

## Phase 5: Documentation (8 hours)

#### T023: Write user guide for hooks [P]
**Description**: Document hook system for users
**Priority**: P1
**Effort**: 3 hours
**Dependencies**: All implementation complete
**Acceptance Criteria**:
- [ ] File `docs/HOOKS-USER-GUIDE.md` created
- [ ] Explains what hooks do
- [ ] How to enable/disable hooks
- [ ] Configuration options
- [ ] Troubleshooting section
- [ ] Examples provided

---

#### T024: Write custom hook API docs [P]
**Description**: Document how to create custom hooks
**Priority**: P2
**Effort**: 3 hours
**Dependencies**: T023
**Acceptance Criteria**:
- [ ] File `docs/CUSTOM-HOOKS-API.md` created
- [ ] Hook event reference
- [ ] Context format documented
- [ ] Example custom hooks
- [ ] Security best practices
- [ ] Testing guidelines

---

#### T025: Update main README [P]
**Description**: Add hooks section to main README
**Priority**: P1
**Effort**: 1 hour
**Dependencies**: T023
**Acceptance Criteria**:
- [ ] Hooks section added to README
- [ ] Quick example provided
- [ ] Links to detailed docs
- [ ] Migration notes (if applicable)

---

#### T026: Create troubleshooting guide [P]
**Description**: Common hook issues and solutions
**Priority**: P2
**Effort**: 1 hour
**Dependencies**: T023
**Acceptance Criteria**:
- [ ] Section added to TROUBLESHOOTING.md
- [ ] Common errors documented
- [ ] Solutions provided
- [ ] Debug tips included

---

## Additional Tasks

### Optional: Custom Hook Support (8 hours)

#### T027: Implement custom hook registration [P]
**Description**: Allow users to add custom hooks
**Priority**: P3
**Effort**: 4 hours
**Dependencies**: T003
**Acceptance Criteria**:
- [ ] Users can add scripts to `.specter/hooks/custom/`
- [ ] Register in config.json
- [ ] Execute alongside core hooks
- [ ] Sandboxed execution
- [ ] Documentation provided

---

#### T028: Create custom hook examples [P]
**Description**: Example custom hooks for common use cases
**Priority**: P3
**Effort**: 4 hours
**Dependencies**: T027
**Acceptance Criteria**:
- [ ] Slack notification hook
- [ ] Email notification hook
- [ ] Jira update hook
- [ ] Custom metrics hook
- [ ] Documentation for each

---

### Optional: Terminal Integration (8 hours)

#### T029: Implement terminal title updates [P]
**Description**: Show progress in terminal title
**Priority**: P3
**Effort**: 4 hours
**Dependencies**: T009
**Acceptance Criteria**:
- [ ] Updates terminal title after commands
- [ ] Shows feature progress
- [ ] Works on macOS Terminal, iTerm2
- [ ] Configurable (can disable)

---

#### T030: Implement tmux/iTerm integration [P]
**Description**: Integration with terminal multiplexers
**Priority**: P3
**Effort**: 4 hours
**Dependencies**: T029
**Acceptance Criteria**:
- [ ] tmux status bar integration
- [ ] iTerm2 badge integration
- [ ] Configuration examples
- [ ] Documentation

---

## Summary

### Task Breakdown by Phase
| Phase | Tasks | Hours | Parallelization |
|-------|-------|-------|-----------------|
| P1: Hook Infrastructure | T001-T008 | 40 | Medium |
| P2: Core Hooks | T009-T012 | 24 | High |
| P3: Git Hooks | T013-T016 | 16 | Medium |
| P4: Testing | T017-T022 | 16 | High |
| P5: Documentation | T023-T026 | 8 | High |
| **TOTAL (Required)** | **26 tasks** | **104 hours** | - |
| Optional Tasks | T027-T030 | 16 | High |

**Note**: Original estimate was 80 hours, but detailed breakdown reveals 104 hours (30% increase). Recommend:
- 2 weeks with 2 developers (52h each)
- OR 2.5 weeks with 1 developer (40h/week)
- Optional tasks can be deferred to v3.2

### Critical Path
```
T001 (structure) → T002 (config) → T003 (runner) → T004 (single hook) →
T005 (atomic updates) → T009-T012 (core hooks) → T013 (pre-commit) →
T017-T022 (tests) → T023-T026 (docs)
```

**Critical Path Duration**: ~70 hours (parallelization saves ~34 hours)

### Parallelization Opportunities

**Phase 1**: T002, T006, T007, T008 can run in parallel
**Phase 2**: T009-T012 all independent
**Phase 3**: T014, T016 can run in parallel with others
**Phase 4**: T017-T022 all independent
**Phase 5**: T023-T026 all independent

### Risk Mitigation Tasks

**High Priority**:
- T022: Performance testing early to catch issues
- T018: Concurrent access tests to prevent corruption
- T021: Git workflow tests to validate integration

---

## Next Steps

1. **Review tasks**: Ensure all requirements covered
2. **Assign tasks**: Distribute among team members
3. **Begin Phase 1**: Start with T001 (directory structure)
4. **Daily standups**: Track progress and blockers
5. **Weekly reviews**: Adjust timeline as needed

---

**Tasks Created**: 2024-10-31
**Ready for**: Implementation
**Estimated Start**: 2024-11-01
**Estimated Completion**: 2024-11-15 (2 weeks with 1 FTE, or adjust for team size)

---

*Generated by Specter Task Breakdown System*
*Next: `/specter implement` to begin execution*
