# Technical Plan: Artifact Auto-Update Hooks

**Feature**: 003-artifact-auto-update-hooks
**Created**: 2024-10-31
**Target Version**: 3.1.0
**Estimated Duration**: 2 weeks (80 hours)
**Risk Level**: Medium

---

## Executive Summary

Build an intelligent hook system that automatically maintains consistency across Specter artifacts (session state, workflow progress, decisions, changes) through event-driven automation. This eliminates manual synchronization overhead and ensures reliable state management for team collaboration.

**Key Metrics**:
- Time Savings: 30-45 seconds per command (no manual sync)
- Error Reduction: 90% fewer state inconsistencies
- Hook Performance: < 100ms for typical updates
- Coverage: 100% of workflow events auto-update state

---

## Architecture Decisions

### ADR-007: Hook Execution Architecture

**Decision**: Event-driven hook system with synchronous critical hooks and asynchronous optional hooks

**Context**:
- Some hooks are critical (pre-commit validation) and must block
- Other hooks are optional (metrics) and shouldn't slow commands
- Need predictable execution order with clear failure modes
- Must support custom user-defined hooks

**Implementation**:

```bash
# Hook Runner Architecture
specter_run_hooks() {
  local event=$1        # post-command, pre-commit, post-merge, on-task-complete
  local mode=$2         # sync|async
  local context=$3      # JSON context for hooks

  # Load hook configuration
  local config=".specter/hooks/config.json"
  local hooks=$(jq -r ".hooks[\"$event\"].scripts[]" "$config")

  if [[ "$mode" == "async" ]]; then
    # Background execution for optional hooks
    {
      for hook in $hooks; do
        run_single_hook "$hook" "$context" || log_hook_error "$hook"
      done
    } &
    SPECTER_HOOK_PID=$!
  else
    # Synchronous execution for critical hooks
    for hook in $hooks; do
      run_single_hook "$hook" "$context" || {
        local blocking=$(jq -r ".hooks[\"$event\"].blocking" "$config")
        if [[ "$blocking" == "true" ]]; then
          echo "❌ Critical hook failed: $hook"
          return 1
        else
          log_hook_error "$hook"
        fi
      }
    done
  fi

  return 0
}

# Single Hook Execution with Timeout and Sandboxing
run_single_hook() {
  local hook=$1
  local context=$2
  local timeout=$(jq -r ".hooks[\"$event\"].timeout" .specter/hooks/config.json)

  # Sandbox environment
  local sandbox_env="PATH=/usr/bin:/bin"
  sandbox_env="$sandbox_env SPECTER_ROOT=$SPECTER_ROOT"
  sandbox_env="$sandbox_env SPECTER_FEATURE=$(jq -r '.activeFeature.id' .specter-state/session.json)"

  # Execute with timeout
  timeout ${timeout}ms env -i $sandbox_env bash ".specter/hooks/$hook" <<< "$context" 2>&1 | \
    tee -a .specter/logs/hooks.log

  return ${PIPESTATUS[0]}
}
```

**Hook Events**:
- `post-command`: After every `/specter` command (async)
- `on-task-complete`: When task marked complete (sync)
- `pre-commit`: Before git commit (sync, blocking)
- `post-merge`: After git pull/merge (sync)

**Benefits**:
- Critical hooks block to prevent bad commits
- Optional hooks run in background for speed
- Timeout prevents hung hooks
- Sandboxing prevents security issues
- Clear failure modes

**Effort**: 16-24 hours

---

### ADR-008: State Synchronization Strategy

**Decision**: Atomic JSON updates with automatic markdown regeneration

**Context**:
- Must ensure consistency between JSON (source of truth) and MD (human view)
- Updates must be atomic to prevent corruption during interruption
- Need efficient regeneration (don't regenerate if not changed)
- Must handle concurrent access (team collaboration)

**Implementation**:

```bash
# Atomic State Update
specter_update_state() {
  local state_file=$1    # session.json or workflow.json
  local updater=$2       # jq expression or function

  # Lock for atomic update
  local lock_file="${state_file}.lock"
  exec 200>"$lock_file"
  flock -x 200 || {
    echo "⚠️  State locked, waiting..."
    flock -x -w 10 200 || {
      echo "❌ Failed to acquire state lock"
      return 1
    }
  }

  # Validate current state
  if ! jq empty "$state_file" 2>/dev/null; then
    echo "❌ Invalid JSON in $state_file"
    return 1
  fi

  # Create temp file with update
  local temp_file="${state_file}.tmp"
  jq "$updater" "$state_file" > "$temp_file"

  # Validate updated state
  if ! jq empty "$temp_file" 2>/dev/null; then
    echo "❌ Update produced invalid JSON"
    rm "$temp_file"
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
  rm "$lock_file"

  return 0
}

# Incremental Regeneration (only if changed)
specter_generate_md_if_changed() {
  local json_file=$1
  local md_file=$2

  # Check if MD needs regeneration
  local json_mtime=$(stat -f %m "$json_file")
  local md_mtime=$(stat -f %m "$md_file" 2>/dev/null || echo 0)

  if [[ $json_mtime -gt $md_mtime ]]; then
    specter_generate_md "$json_file" > "$md_file"
    echo "✅ Regenerated $(basename $md_file)"
  fi
}
```

**Benefits**:
- Atomic updates prevent corruption
- File locking prevents concurrent modification
- Validation before commit
- Incremental regeneration for performance
- Clear error handling

**Effort**: 12-16 hours

---

### ADR-009: Decision Capture from Plan

**Decision**: Parse plan.md ADR sections using regex-based extraction

**Context**:
- Users write ADRs in structured format in plan.md
- Need to extract: ADR-XXX, title, decision, context, consequences
- Must handle various markdown formatting
- Should preserve original formatting for references

**Implementation**:

```bash
# Extract ADRs from plan.md
specter_extract_decisions() {
  local plan_file=$1
  local feature_id=$2
  local decisions_json=".specter-memory/decisions.json"

  # Parse ADR sections
  awk '
    /^### ADR-[0-9]+:/ {
      adr_active=1
      adr_id=$2
      adr_title=$0
      gsub(/^### ADR-[0-9]+: /, "", adr_title)
      decision=""
      context=""
      next
    }

    /^\*\*Decision\*\*:/ {
      decision_active=1
      getline
      decision=$0
      next
    }

    /^\*\*Context\*\*:/ {
      context_active=1
      decision_active=0
      getline
      context=$0
      next
    }

    /^###/ {
      if (adr_active && adr_id != "") {
        # Output JSON for this ADR
        printf "{\"id\":\"%s\",\"title\":\"%s\",\"decision\":\"%s\",\"context\":\"%s\",\"feature\":\"%s\",\"date\":\"%s\"},\n",
          adr_id, adr_title, decision, context, feature_id, date
      }
      adr_active=0
      next
    }

    adr_active {
      if (decision_active) decision = decision " " $0
      if (context_active) context = context " " $0
    }
  ' feature_id="$feature_id" date="$(date +%Y-%m-%d)" "$plan_file" | \
  # Append to decisions.json
  while IFS= read -r line; do
    local temp_json=$(mktemp)
    jq ". += [$line]" "$decisions_json" > "$temp_json"
    mv "$temp_json" "$decisions_json"
  done

  # Regenerate DECISIONS-LOG.md
  specter_generate_decisions_log
}

# Generate DECISIONS-LOG.md from decisions.json
specter_generate_decisions_log() {
  local decisions_json=".specter-memory/decisions.json"
  local decisions_md=".specter-memory/DECISIONS-LOG.md"

  cat > "$decisions_md" <<'EOF'
# Specter Architecture Decisions Log

**Last Updated**: $(date +%Y-%m-%d)

This log tracks all significant architectural decisions made during Specter development.

---

EOF

  jq -r '.[] | "## \(.id): \(.title)\n\n**Date**: \(.date)\n**Feature**: \(.feature)\n\n**Decision**: \(.decision)\n\n**Context**: \(.context)\n\n---\n"' \
    "$decisions_json" >> "$decisions_md"
}
```

**Parsing Format**:
```markdown
### ADR-XXX: Decision Title

**Decision**: The decision made

**Context**: Why this decision was needed

**Implementation**: Code examples (ignored for extraction)

**Benefits**: Advantages (ignored for extraction)
```

**Benefits**:
- Structured extraction with clear patterns
- Preserves formatting in JSON
- Easy regeneration of markdown
- Supports various ADR formats

**Effort**: 8-12 hours

---

### ADR-010: Master Spec Aggregation Strategy

**Decision**: Incremental aggregation with caching and dependency tracking

**Context**:
- Master spec can become large (thousands of lines)
- Regenerating from scratch every time is expensive
- Most changes affect only one feature
- Need to track what changed to minimize regeneration

**Implementation**:

```bash
# Incremental Master Spec Generation
specter_generate_master_spec() {
  local master_spec=".specter/master-spec.md"
  local cache_dir=".specter/cache/master-spec"
  mkdir -p "$cache_dir"

  # Check what needs regeneration
  local changed_features=()

  for feature_dir in features/*/; do
    local feature_id=$(basename "$feature_dir")
    local spec_file="$feature_dir/spec.md"
    local cache_file="$cache_dir/${feature_id}.md"

    if [[ "$spec_file" -nt "$cache_file" ]] || [[ ! -f "$cache_file" ]]; then
      # Feature changed, regenerate section
      specter_generate_feature_section "$feature_dir" > "$cache_file"
      changed_features+=("$feature_id")
    fi
  done

  if [[ ${#changed_features[@]} -eq 0 ]] && [[ -f "$master_spec" ]]; then
    echo "✅ Master spec up to date"
    return 0
  fi

  # Aggregate all sections
  local temp_spec="${master_spec}.tmp"

  # Header
  cat > "$temp_spec" <<EOF
# Specter Plugin - Master Specification

**Generated**: $(date '+%Y-%m-%d %H:%M:%S')
**Version**: $(cat .specter/config/version 2>/dev/null || echo "3.0.0")
**Features**: $(count_active_features) active, $(count_completed_features) completed

---

EOF

  # Product Vision
  cat >> "$temp_spec" <<EOF
## Product Vision

$(cat .specter/config/product-requirements.md 2>/dev/null || echo "Not yet defined")

---

EOF

  # Architecture
  cat >> "$temp_spec" <<EOF
## Architecture

$(cat .specter/config/architecture-blueprint.md 2>/dev/null || echo "Not yet defined")

---

## Features

EOF

  # Completed Features
  echo "### ✅ Completed Features" >> "$temp_spec"
  echo "" >> "$temp_spec"
  for cache_file in "$cache_dir"/*.md; do
    local feature_id=$(basename "$cache_file" .md)
    if is_feature_complete "$feature_id"; then
      cat "$cache_file" >> "$temp_spec"
      echo "" >> "$temp_spec"
    fi
  done

  # Active Features
  echo "### 🔄 Active Features" >> "$temp_spec"
  echo "" >> "$temp_spec"
  for cache_file in "$cache_dir"/*.md; do
    local feature_id=$(basename "$cache_file" .md)
    if is_feature_active "$feature_id"; then
      cat "$cache_file" >> "$temp_spec"
      echo "" >> "$temp_spec"
    fi
  done

  # Decisions
  cat >> "$temp_spec" <<EOF
---

## Technical Decisions

$(cat .specter-memory/DECISIONS-LOG.md 2>/dev/null || echo "No decisions logged yet")

---

## Metrics

$(cat .specter-memory/WORKFLOW-PROGRESS.md 2>/dev/null || echo "No metrics available yet")

---

*Auto-generated by Specter*
*Do not edit manually - changes will be overwritten*
EOF

  # Atomic write
  mv "$temp_spec" "$master_spec"

  local line_count=$(wc -l < "$master_spec")
  echo "✅ Master spec regenerated ($line_count lines, ${#changed_features[@]} features updated)"
}

# Generate Individual Feature Section (cached)
specter_generate_feature_section() {
  local feature_dir=$1
  local feature_id=$(basename "$feature_dir")
  local spec_file="$feature_dir/spec.md"
  local status=$(jq -r ".features[] | select(.id == \"$feature_id\") | .status" .specter-state/session.json)

  echo "#### Feature $feature_id"
  echo "**Status**: $status"
  echo ""

  # Embed spec (strip header to avoid nesting)
  tail -n +2 "$spec_file"

  echo ""
  echo "---"
  echo ""
}
```

**Benefits**:
- Only regenerates changed features
- Caching speeds up subsequent generation
- Atomic writes prevent corruption
- Scales to hundreds of features

**Effort**: 16-20 hours

---

### ADR-011: Git Hook Integration

**Decision**: Install hooks via `.git/hooks/` with Specter-specific scripts

**Context**:
- Git hooks provide lifecycle events (pre-commit, post-merge)
- Must not interfere with existing user hooks
- Should be optional but highly recommended
- Need uninstall capability

**Implementation**:

```bash
# Install Git Hooks
specter_install_git_hooks() {
  local git_hooks_dir=".git/hooks"

  if [[ ! -d ".git" ]]; then
    echo "⚠️  Not a git repository, skipping git hooks"
    return 0
  fi

  # Pre-commit hook
  cat > "$git_hooks_dir/pre-commit" <<'EOF'
#!/bin/bash
# Specter Pre-Commit Hook - Validate state before commit

set -euo pipefail

# Check if Specter is initialized
if [[ ! -d ".specter" ]]; then
  exit 0  # Not a Specter project
fi

echo "🔍 Specter: Validating state before commit..."

# Run validation
if ! bash .specter/hooks/core/pre-commit.sh; then
  echo "❌ Specter validation failed"
  echo "   Fix errors above or commit with --no-verify to skip"
  exit 1
fi

echo "✅ Specter validation passed"
exit 0
EOF

  chmod +x "$git_hooks_dir/pre-commit"

  # Post-merge hook
  cat > "$git_hooks_dir/post-merge" <<'EOF'
#!/bin/bash
# Specter Post-Merge Hook - Sync state after merge/pull

set -euo pipefail

if [[ ! -d ".specter" ]]; then
  exit 0
fi

echo "🔄 Specter: Syncing state after merge..."

if bash .specter/hooks/core/post-merge.sh; then
  echo "✅ Specter state synchronized"
else
  echo "⚠️  Specter sync encountered issues (non-blocking)"
fi

exit 0
EOF

  chmod +x "$git_hooks_dir/post-merge"

  echo "✅ Git hooks installed"
  echo "   - pre-commit: State validation"
  echo "   - post-merge: State synchronization"
  echo ""
  echo "To bypass hooks: git commit --no-verify"
}

# Uninstall Git Hooks
specter_uninstall_git_hooks() {
  local git_hooks_dir=".git/hooks"

  for hook in pre-commit post-merge; do
    if [[ -f "$git_hooks_dir/$hook" ]]; then
      if grep -q "Specter" "$git_hooks_dir/$hook"; then
        rm "$git_hooks_dir/$hook"
        echo "✅ Removed $hook hook"
      else
        echo "⚠️  $hook hook exists but not Specter's, leaving intact"
      fi
    fi
  done
}
```

**Hook Behaviors**:

**Pre-Commit**:
- Validate `session.json` schema
- Validate `workflow.json` schema
- Check JSON ↔ MD consistency
- Verify no stale locks (TTL expired)
- Block commit if validation fails

**Post-Merge**:
- Regenerate all `.md` from `.json`
- Detect conflicting locks
- Warn if active feature modified by teammate
- Update team dashboard

**Benefits**:
- Leverages Git's lifecycle events
- Non-invasive installation
- Optional (can skip with --no-verify)
- Easy uninstall

**Effort**: 8-12 hours

---

### ADR-012: Hook Performance Budget

**Decision**: Enforce performance budgets with automated testing

**Context**:
- Slow hooks degrade user experience
- Must measure and enforce performance targets
- Need continuous monitoring in CI
- Should fail fast if budget exceeded

**Implementation**:

```bash
# Performance Budget Test
test_hook_performance() {
  local hook=$1
  local budget_ms=$2
  local context='{"activeFeature":{"id":"002","phase":"planning"}}'

  # Warm-up run
  bash ".specter/hooks/core/$hook.sh" <<< "$context" >/dev/null 2>&1

  # Measured runs (3 samples)
  local total_ms=0
  for i in {1..3}; do
    local start_ns=$(date +%s%N)
    bash ".specter/hooks/core/$hook.sh" <<< "$context" >/dev/null 2>&1
    local end_ns=$(date +%s%N)
    local elapsed_ms=$(( (end_ns - start_ns) / 1000000 ))
    total_ms=$((total_ms + elapsed_ms))
  done

  local avg_ms=$((total_ms / 3))

  if [[ $avg_ms -gt $budget_ms ]]; then
    echo "❌ FAIL: $hook took ${avg_ms}ms (budget: ${budget_ms}ms)"
    return 1
  else
    echo "✅ PASS: $hook took ${avg_ms}ms (budget: ${budget_ms}ms)"
    return 0
  fi
}

# Run all performance tests
test_all_hook_performance() {
  local failures=0

  test_hook_performance "post-command" 100 || ((failures++))
  test_hook_performance "on-task-complete" 50 || ((failures++))
  test_hook_performance "pre-commit" 500 || ((failures++))
  test_hook_performance "post-merge" 200 || ((failures++))

  if [[ $failures -gt 0 ]]; then
    echo ""
    echo "❌ $failures hook(s) exceeded performance budget"
    return 1
  fi

  echo ""
  echo "✅ All hooks within performance budget"
  return 0
}
```

**Performance Budgets**:
- `post-command`: 100ms (runs frequently)
- `on-task-complete`: 50ms (runs very frequently)
- `pre-commit`: 500ms (blocking, rare)
- `post-merge`: 200ms (rare but important)

**CI Integration**:
```yaml
# .github/workflows/test-hooks.yml
- name: Test Hook Performance
  run: |
    source tests/performance/test-hook-performance.sh
    test_all_hook_performance
```

**Benefits**:
- Enforces performance requirements
- Prevents performance regressions
- Continuous monitoring in CI
- Clear performance budgets

**Effort**: 4-8 hours

---

## Implementation Phases

### Phase 1: Hook Infrastructure (1 week, 40 hours)

**Objectives**:
- Build core hook execution engine
- Implement atomic state updates
- Create hook configuration system
- Add logging and error handling

**Deliverables**:
- ✅ Hook runner with sync/async execution
- ✅ Atomic state update mechanism
- ✅ Hook configuration (`hooks/config.json`)
- ✅ Logging infrastructure

**Tasks**:
1. Create `.specter/hooks/` directory structure (2h)
2. Implement `specter_run_hooks()` function (8h)
3. Implement `run_single_hook()` with timeout (6h)
4. Add atomic state update function (8h)
5. Create hook configuration schema (4h)
6. Implement logging system (6h)
7. Add error handling and retry logic (6h)

**Validation**:
```bash
# Test hook execution
specter_run_hooks post-command async '{"feature":"002"}'

# Test atomic updates
specter_update_state session.json '.activeFeature.phase = "planning"'

# Test error handling
# (Trigger hook failure and verify recovery)
```

---

### Phase 2: Core Hooks (3 days, 24 hours)

**Objectives**:
- Implement post-command hook
- Implement on-task-complete hook
- Add decision capture
- Add master spec regeneration

**Deliverables**:
- ✅ `post-command.sh` hook
- ✅ `on-task-complete.sh` hook
- ✅ Decision extraction from plan.md
- ✅ Master spec generator

**Tasks**:
1. Create `post-command.sh` (6h)
   - Update session.json phase/progress
   - Regenerate current-session.md
   - Update workflow metrics
2. Create `on-task-complete.sh` (6h)
   - Update task status
   - Move to CHANGES-COMPLETED
   - Recalculate progress
3. Implement decision capture (6h)
   - Parse ADRs from plan.md
   - Update decisions.json
   - Regenerate DECISIONS-LOG.md
4. Implement master spec generator (6h)
   - Incremental regeneration
   - Feature caching
   - Atomic writes

**Validation**:
```bash
# Test post-command
/specter plan
# Verify session.json updated to "planning" phase

# Test task complete
/specter implement
# Complete a task, verify moved to CHANGES-COMPLETED

# Test decision capture
# Create plan with ADRs, verify decisions.json updated

# Test master spec
/specter "New feature"
# Verify master-spec.md regenerated
```

---

### Phase 3: Git Hooks (2 days, 16 hours)

**Objectives**:
- Implement pre-commit validation
- Implement post-merge synchronization
- Add lock conflict detection
- Test git workflow integration

**Deliverables**:
- ✅ `pre-commit.sh` hook
- ✅ `post-merge.sh` hook
- ✅ Git hook installation
- ✅ Git hook uninstallation

**Tasks**:
1. Create `pre-commit.sh` (6h)
   - Schema validation
   - Consistency checks
   - Lock validation
2. Create `post-merge.sh` (4h)
   - Regenerate markdown
   - Detect conflicts
   - Update dashboard
3. Implement hook installation (4h)
4. Test git workflow (2h)

**Validation**:
```bash
# Test pre-commit
echo "invalid" > .specter-state/session.json
git commit -m "test"
# Should block commit

# Test post-merge
git pull origin main
# Should regenerate markdown, show any conflicts
```

---

### Phase 4: Testing & Polish (2 days, 16 hours)

**Objectives**:
- Comprehensive testing
- Performance validation
- Documentation
- Bug fixes

**Deliverables**:
- ✅ Unit tests for all hooks
- ✅ Integration tests
- ✅ Performance tests passing
- ✅ Documentation complete

**Tasks**:
1. Unit tests for hook runner (4h)
2. Integration tests for workflows (4h)
3. Performance benchmark validation (4h)
4. Documentation (4h)
   - User guide for hooks
   - Custom hook API docs
   - Troubleshooting guide

**Validation**:
```bash
# Run all tests
./tests/unit/test-hooks.sh
./tests/integration/test-workflow-with-hooks.sh
./tests/performance/test-hook-performance.sh

# All tests must pass
```

---

## Risk Assessment & Mitigation

### HIGH Risks

#### Risk: Hook Execution Time Exceeds Budget
**Probability**: Medium
**Impact**: High
**Mitigation**:
- Profile hooks early (Phase 1)
- Optimize hot paths
- Use caching extensively
- Make expensive hooks async

**Contingency**: If budget can't be met, make hook opt-in with `SPECTER_HOOKS_ENABLED=true`

---

#### Risk: State Corruption During Concurrent Access
**Probability**: Medium
**Impact**: High
**Mitigation**:
- File locking for all state updates
- Atomic writes (temp + mv)
- Validation before commit
- Comprehensive error handling

**Contingency**: If corruption occurs, implement automatic state recovery from git history

---

### MEDIUM Risks

#### Risk: Git Hook Conflicts with User Hooks
**Probability**: Low
**Impact**: Medium
**Mitigation**:
- Check for existing hooks before install
- Merge with existing hooks if possible
- Clear documentation
- Easy uninstall

**Contingency**: Provide alternative hook registration (git config core.hooksPath)

---

#### Risk: Decision Parsing Fails on Non-Standard Format
**Probability**: Medium
**Impact**: Low
**Mitigation**:
- Flexible regex patterns
- Fallback to manual logging
- Clear ADR format documentation
- Validation with examples

**Contingency**: Provide manual decision logging command

---

## Testing Strategy

### Unit Tests
```bash
tests/unit/
├── test-hook-runner.sh       # Hook execution engine
├── test-atomic-updates.sh    # State update atomicity
├── test-decision-parser.sh   # ADR extraction
└── test-master-spec-gen.sh   # Master spec generation
```

**Coverage Target**: 85%

---

### Integration Tests
```bash
tests/integration/
├── test-full-workflow-with-hooks.sh  # End-to-end with hooks
├── test-git-workflow.sh              # Git hooks integration
├── test-team-collaboration.sh        # Multi-user scenarios
└── test-hook-failure-recovery.sh     # Error handling
```

**Scenarios**:
- Full workflow with all hooks enabled
- Git commit with validation
- Git merge with conflict detection
- Hook failure and recovery

---

### Performance Tests
```bash
tests/performance/
├── test-hook-performance.sh     # Individual hook timing
├── test-master-spec-perf.sh     # Large spec generation
└── benchmark-full-workflow.sh   # End-to-end timing
```

**Targets**:
- Each hook within budget
- Master spec < 2s for 50 features
- Full workflow < 5% slower with hooks

---

## Success Criteria

### Functional Requirements
- ✅ All workflow events trigger appropriate hooks
- ✅ State files automatically synchronized
- ✅ Decisions automatically logged
- ✅ Master spec auto-regenerates
- ✅ Git hooks validate and sync state
- ✅ Custom hooks supported

### Non-Functional Requirements
- ✅ Hook performance within budgets
- ✅ Zero state corruption
- ✅ Graceful degradation on failure
- ✅ Clear error messages
- ✅ Comprehensive documentation

### Quality Metrics
- ✅ Test coverage > 85%
- ✅ Zero critical bugs
- ✅ Performance benchmarks met
- ✅ User satisfaction > 4.5/5

---

## Dependencies

### Internal
- Feature 002 (Specter v3.0) complete
- JSON state management system
- Schema validation infrastructure

### External
- `jq` 1.6+ for JSON processing
- `flock` for file locking
- Git 2.0+ for git hooks
- Bash 4.0+ for associative arrays

### Tools Required
- Standard Unix utilities (awk, sed, grep, stat)
- Timeout command (GNU coreutils)

---

## Rollout Plan

### Alpha Testing (3 days)
- Internal testing on Specter plugin development
- Bug identification and fixes
- Performance tuning

### Beta Testing (1 week)
- 5-10 early adopters
- Feedback collection
- Documentation refinement

### General Availability
- Full release with v3.1.0
- Migration guide for existing projects
- Video tutorial

---

## Post-Launch Plan

### v3.2.0 (2 months after v3.1)
- Advanced hook triggers (on-feature-start, on-phase-change)
- Hook marketplace (share custom hooks)
- Visual hook debugger

### v3.3.0 (4 months after v3.1)
- Real-time state sync (WebSocket-based)
- Collaborative editing indicators
- Conflict resolution UI

---

## Appendices

### A. Hook Event Reference

| Event | When | Mode | Blocking | Typical Uses |
|-------|------|------|----------|--------------|
| post-command | After /specter | async | No | State updates, metrics |
| on-task-complete | Task done | sync | No | Progress tracking |
| pre-commit | Before commit | sync | Yes | Validation |
| post-merge | After pull/merge | sync | No | Sync, conflict detection |

### B. State Update API

```bash
# Update session state
specter_update_state session.json '.activeFeature.phase = "planning"'

# Update workflow metrics
specter_update_state workflow.json '.metrics.completedTasks += 1'

# Add decision
specter_update_state decisions.json '. += [{"id":"ADR-007",...}]'

# Regenerate markdown
specter_generate_md session.json > current-session.md
```

### C. Custom Hook Example

```bash
# .specter/hooks/custom/slack-notify.sh
#!/bin/bash
# Notify Slack when feature completes

set -euo pipefail

# Read context from stdin
context=$(cat)

# Check if feature complete
status=$(echo "$context" | jq -r '.activeFeature.status')

if [[ "$status" == "complete" ]]; then
  feature_id=$(echo "$context" | jq -r '.activeFeature.id')
  feature_name=$(echo "$context" | jq -r '.activeFeature.name')

  curl -X POST "$SLACK_WEBHOOK_URL" \
    -H 'Content-Type: application/json' \
    -d "{\"text\":\"✅ Feature $feature_id ($feature_name) complete!\"}"
fi
```

**Register**:
```json
{
  "hooks": {
    "post-command": {
      "scripts": [
        "core/post-command.sh",
        "custom/slack-notify.sh"
      ]
    }
  }
}
```

---

**Plan Created**: 2024-10-31
**Author**: Specter v3.1 Planning Team
**Status**: Ready for Task Breakdown
**Next Step**: Create tasks.md with detailed implementation tasks
