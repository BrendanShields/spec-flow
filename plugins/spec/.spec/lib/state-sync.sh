#!/bin/bash
# Spec State Synchronization
# Atomic updates with file locking and markdown regeneration

set -euo pipefail

# Source directory
SPEC_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPEC_ROOT="$(cd "$SPEC_LIB_DIR/../.." && pwd)"

##
# Atomically update a JSON state file
#
# Usage: spec_update_state <state_file> <jq_expression>
#
# Arguments:
#   state_file: Path to JSON file (session.json, workflow.json, etc.)
#   jq_expression: jq expression to apply
#
# Returns:
#   0 on success, 1 on failure
#
# Example:
#   spec_update_state .spec-state/session.json '.activeFeature.phase = "planning"'
#
spec_update_state() {
  local state_file=$1
  local jq_expression=$2

  # Convert relative to absolute path
  if [[ ! "$state_file" = /* ]]; then
    state_file="$SPEC_ROOT/$state_file"
  fi

  # Validate file exists
  if [[ ! -f "$state_file" ]]; then
    echo "❌ State file not found: $state_file" >&2
    return 1
  fi

  # Acquire lock
  local lock_file="${state_file}.lock"
  exec 200>"$lock_file"

  if ! flock -x -w 10 200; then
    echo "❌ Failed to acquire lock on $state_file (timeout after 10s)" >&2
    return 1
  fi

  # Validate current state
  if ! jq empty "$state_file" 2>/dev/null; then
    echo "❌ Invalid JSON in $state_file" >&2
    flock -u 200
    exec 200>&-
    rm -f "$lock_file"
    return 1
  fi

  # Create temp file with update
  local temp_file="${state_file}.tmp"
  if ! jq "$jq_expression" "$state_file" > "$temp_file" 2>/dev/null; then
    echo "❌ jq update failed: $jq_expression" >&2
    rm -f "$temp_file"
    flock -u 200
    exec 200>&-
    rm -f "$lock_file"
    return 1
  fi

  # Validate updated state
  if ! jq empty "$temp_file" 2>/dev/null; then
    echo "❌ Update produced invalid JSON" >&2
    rm -f "$temp_file"
    flock -u 200
    exec 200>&-
    rm -f "$lock_file"
    return 1
  fi

  # Atomic move
  mv "$temp_file" "$state_file"

  # Regenerate markdown (if corresponding .md exists or should exist)
  local md_file="${state_file%.json}.md"
  if spec_generate_md "$state_file" > "${md_file}.tmp" 2>/dev/null; then
    mv "${md_file}.tmp" "$md_file"
  else
    rm -f "${md_file}.tmp"
  fi

  # Release lock
  flock -u 200
  exec 200>&-
  rm -f "$lock_file"

  return 0
}

##
# Generate markdown from JSON state file
#
# Usage: spec_generate_md <json_file>
#
# Arguments:
#   json_file: Path to JSON file
#
# Outputs markdown to stdout
#
spec_generate_md() {
  local json_file=$1

  # Convert relative to absolute path
  if [[ ! "$json_file" = /* ]]; then
    json_file="$SPEC_ROOT/$json_file"
  fi

  if [[ ! -f "$json_file" ]]; then
    echo "❌ JSON file not found: $json_file" >&2
    return 1
  fi

  # Determine which generator to use based on filename
  local basename=$(basename "$json_file")
  case "$basename" in
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
      echo "❌ Unknown JSON file type: $basename" >&2
      return 1
      ;;
  esac
}

##
# Generate current-session.md from session.json
#
_generate_session_md() {
  local json_file=$1

  cat <<EOF
# Spec Plugin Development Session

## Session Information
- **Session ID**: $(jq -r '.sessionId // "unknown"' "$json_file")
- **Started**: $(jq -r '.started // "unknown"' "$json_file")
- **Type**: $(jq -r '.type // "unknown"' "$json_file")

## Current Context

### Active Feature
**Feature**: $(jq -r '.activeFeature.id // "none"' "$json_file")-$(jq -r '.activeFeature.name // "none"' "$json_file")
**Description**: $(jq -r '.activeFeature.description // ""' "$json_file")
**Priority**: $(jq -r '.activeFeature.priority // "P1"' "$json_file")
**Status**: $(jq -r '.activeFeature.status // "active"' "$json_file")

### Current Phase
**Phase**: $(jq -r '.activeFeature.phase // "specification"' "$json_file")
**Started**: $(jq -r '.phaseStarted // "unknown"' "$json_file")
**Progress**: $(jq -r '.activeFeature.progress // 0' "$json_file")%

## Feature Pipeline

| Feature ID | Name | Priority | Status | Progress |
|------------|------|----------|--------|----------|
$(jq -r '.features[]? // [] | "| \(.id) | \(.name) | \(.priority) | \(.status) | \(.progress)% |"' "$json_file")

## Task Progress

### Current Sprint
**Total Tasks**: $(jq -r '.tasks.total // 0' "$json_file")
**Completed**: $(jq -r '.tasks.completed // 0' "$json_file")
**In Progress**: $(jq -r '.tasks.inProgress // 0' "$json_file")
**Remaining**: $(jq -r '.tasks.remaining // 0' "$json_file")

### Task List

| Task | Description | Status | Assigned To |
|------|-------------|--------|-------------|
$(jq -r '.taskList[]? // [] | "| \(.id) | \(.description) | \(.status) | \(.assignedTo // "-") |"' "$json_file")

## Environment
- **Working Directory**: $(jq -r '.environment.workingDir // "unknown"' "$json_file")
- **Git Branch**: $(jq -r '.environment.gitBranch // "unknown"' "$json_file")
- **Version**: $(jq -r '.environment.version // "unknown"' "$json_file")

---

*Auto-generated by Spec from session.json*
*Do not edit manually - changes will be overwritten*
*Last updated: $(date +"%Y-%m-%d %H:%M:%S")*
EOF
}

##
# Generate WORKFLOW-PROGRESS.md from workflow.json
#
_generate_workflow_md() {
  local json_file=$1

  cat <<EOF
# Spec Workflow Progress

**Last Updated**: $(date +"%Y-%m-%d %H:%M:%S")
**Project Started**: $(jq -r '.projectStarted // "unknown"' "$json_file")

## Feature Progress Overview

### 🎯 Active Features

| Feature | Phase | Progress | Started | ETA | Blocked |
|---------|-------|----------|---------|-----|---------|
$(jq -r '.activeFeatures[]? // [] | "| \(.id)-\(.name) | \(.phase) | \(.progress)% | \(.started) | \(.eta) | \(.blocked) |"' "$json_file")

### ✅ Completed Features

| Feature | Completed | Duration | Tasks | Velocity |
|---------|-----------|----------|-------|----------|
$(jq -r '.completedFeatures[]? // [] | "| \(.id)-\(.name) | \(.completed) | \(.duration) | \(.tasksCompleted)/\(.tasksTotal) | \(.velocity) tasks/day |"' "$json_file")

## Workflow Metrics

### Overall Statistics
- **Features Completed**: $(jq -r '.metrics.featuresCompleted // 0' "$json_file")
- **Total Tasks Completed**: $(jq -r '.metrics.totalTasksCompleted // 0' "$json_file")
- **Average Velocity**: $(jq -r '.metrics.avgVelocity // 0' "$json_file") tasks/day
- **Success Rate**: $(jq -r '.metrics.successRate // 100' "$json_file")%

---

*Maintained by Spec Workflow System*
*Auto-generated from workflow.json*
EOF
}

##
# Generate DECISIONS-LOG.md from decisions.json
#
_generate_decisions_md() {
  local json_file=$1

  cat <<EOF
# Spec Architecture Decisions Log

**Last Updated**: $(date +"%Y-%m-%d %H:%M:%S")

This log tracks all significant architectural decisions made during Spec development.

---

EOF

  jq -r '.[]? // [] | "## \(.id): \(.title)\n\n**Date**: \(.date)\n**Feature**: \(.feature)\n\n**Decision**: \(.decision)\n\n**Context**: \(.context)\n\n---\n"' "$json_file"

  cat <<EOF

---

*Auto-generated from decisions.json*
*Do not edit manually - changes will be overwritten*
EOF
}

##
# Regenerate markdown if JSON changed
#
# Usage: spec_generate_md_if_changed <json_file>
#
spec_generate_md_if_changed() {
  local json_file=$1
  local md_file="${json_file%.json}.md"

  # Convert to absolute paths
  if [[ ! "$json_file" = /* ]]; then
    json_file="$SPEC_ROOT/$json_file"
  fi
  if [[ ! "$md_file" = /* ]]; then
    md_file="$SPEC_ROOT/$md_file"
  fi

  # Check if MD needs regeneration
  if [[ ! -f "$md_file" ]]; then
    # MD doesn't exist, generate it
    spec_generate_md "$json_file" > "$md_file"
    echo "✅ Generated $(basename $md_file)"
    return 0
  fi

  # Compare modification times
  if [[ "$json_file" -nt "$md_file" ]]; then
    spec_generate_md "$json_file" > "$md_file"
    echo "✅ Regenerated $(basename $md_file)"
  fi
}

##
# Validate state file consistency
#
# Usage: spec_validate_state <state_file>
#
# Returns:
#   0 if valid, 1 if invalid
#
spec_validate_state() {
  local state_file=$1

  # Convert to absolute path
  if [[ ! "$state_file" = /* ]]; then
    state_file="$SPEC_ROOT/$state_file"
  fi

  # Validate JSON
  if ! jq empty "$state_file" 2>/dev/null; then
    echo "❌ Invalid JSON: $state_file" >&2
    return 1
  fi

  # Check JSON ↔ MD consistency
  local md_file="${state_file%.json}.md"
  if [[ -f "$md_file" ]]; then
    local temp_md=$(mktemp)
    spec_generate_md "$state_file" > "$temp_md" 2>/dev/null

    if ! diff -q "$temp_md" "$md_file" >/dev/null 2>&1; then
      echo "❌ Inconsistency detected: $(basename $state_file) ↔ $(basename $md_file)" >&2
      rm "$temp_md"
      return 1
    fi

    rm "$temp_md"
  fi

  return 0
}

# Export functions for use in other scripts
export -f spec_update_state
export -f spec_generate_md
export -f spec_generate_md_if_changed
export -f spec_validate_state
