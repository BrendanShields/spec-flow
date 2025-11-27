---
id: 004-workflow-phase-gates
title: Workflow Phase Gates
status: complete
priority: P1
created: 2025-11-27
updated: 2025-11-27
progress:
  tasks_total: 8
  tasks_done: 7
tags:
  - workflow
  - enforcement
  - quality
archived: true
archived_date: 2025-11-26
---

# Feature: Workflow Phase Gates

## Overview

Enforce phase progression in the Orbit workflow to prevent skipping required artifacts. Currently, nothing prevents jumping from plan.md directly to implementation, bypassing tasks.md creation.

**Root cause:** During feature 003, Claude skipped tasks.md and went straight to writing skill files after completing plan.md.

## User Stories

### US1: Skill-Level Validation

As a developer using Orbit, I want the orbit-workflow skill to validate phase prerequisites so that I'm warned before skipping required steps.

**Acceptance Criteria:**
- [ ] AC1.1: Skill checks for spec.md before allowing plan creation
- [ ] AC1.2: Skill checks for plan.md before allowing tasks creation
- [ ] AC1.3: Skill checks for tasks.md before allowing implementation
- [ ] AC1.4: Warning message explains what's missing and suggests next action

### US2: Agent-Level Gate

As a developer using Orbit, I want the implementing-tasks agent to verify tasks.md exists so that implementation cannot proceed without defined tasks.

**Acceptance Criteria:**
- [ ] AC2.1: Agent checks for tasks.md at start of execution
- [ ] AC2.2: Agent fails with clear error if tasks.md missing
- [ ] AC2.3: Error suggests running orbit-workflow to create tasks

### US3: Status Consistency

As a developer using Orbit, I want frontmatter status to match actual artifacts so that phase detection is reliable.

**Acceptance Criteria:**
- [ ] AC3.1: Status can only advance when prerequisites exist
- [ ] AC3.2: Context loader validates status matches artifacts
- [ ] AC3.3: Mismatches are flagged in suggestion

## Technical Constraints

- Must not break existing workflows
- Validation should be fast (no heavy file scanning)
- Gates should be bypassable with explicit user override
- Error messages must be actionable

## Out of Scope

- Blocking at hook level (too restrictive)
- Rollback of invalid status changes
- Multi-feature dependency tracking
