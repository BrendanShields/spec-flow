---
id: 008-enforce-planning-phase
title: Enforce Planning Phase in Workflow
status: complete
priority: P1
created: 2025-11-27
updated: 2025-11-27
progress:
  tasks_total: 7
  tasks_done: 7
owner: spec-flow
tags:
  - workflow
  - process
  - fix
archived: true
archived_date: 2025-11-26
---

# Feature: Enforce Planning Phase in Workflow

## Problem

Claude skips the planning phase (plan.md, tasks.md) and jumps straight to implementation. This defeats the purpose of specification-driven development where **artifacts are the source of truth**.

## Root Causes

1. Eagerness to deliver results quickly
2. Treating "simple" features as not needing plans
3. Mental planning not translated to artifacts
4. No enforcement mechanism in the workflow skill

## User Stories

### US1: Enforce Phase Gates

As a workflow user, I want the system to prevent skipping phases so that all decisions are documented in artifacts.

**Acceptance Criteria:**
- [ ] AC1.1: Cannot start implementation without plan.md existing
- [ ] AC1.2: Cannot start implementation without tasks.md existing
- [ ] AC1.3: Clear error message when phase is skipped
- [ ] AC1.4: Validation script checks phase prerequisites

### US2: Quick Planning for Simple Features

As a developer, I want a streamlined planning process for simple features so that I don't feel tempted to skip it.

**Acceptance Criteria:**
- [ ] AC2.1: Minimal plan.md template for simple features
- [ ] AC2.2: Tasks can be inline in plan for small scope
- [ ] AC2.3: Still creates artifacts, just lighter weight

## Proposed Solution

1. Add phase validation to `orbit-workflow` skill
2. Use the existing `validate-phase.sh` script before phase transitions
3. Make the skill refuse to implement without plan.md + tasks.md
4. Add "quick plan" template for simple features

## Out of Scope

- Automated plan generation (requires user decisions)
- Removing planning phase entirely
